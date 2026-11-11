"""Build pre-filled TOC / list-of-tables / list-of-figures fields.
Entries come from the markdown; page numbers from the rendered PDF (thesis.pdf) if present.
Usage: python3 make_toc.py  -> writes front_built.md from front.md"""
import re, subprocess, os, html

def md_entries():
    ents = []  # (kind, level, text)
    for f in ['body.md', 'back.md']:
        for line in open(f):
            m = re.match(r'^(#{1,3}) (.*)$', line)
            if m:
                t = m.group(2)
                t = re.sub(r'`<w:r><w:br/></w:r>`\{=openxml\}', '  ', t).strip()
                ents.append(('toc', len(m.group(1)), t))
            m = re.match(r'^Table: (Table [A-Z0-9.]+: .*)$', line)
            if m: ents.append(('tab', 1, m.group(1).strip()))
            m = re.match(r'^!\[(Figure [A-Z0-9.]+: [^\]]*)\]', line)
            if m: ents.append(('fig', 1, m.group(1).strip()))
    return ents

def clean(t):
    t = t.replace('\\$', '$').replace('**', '').replace('~', '')
    t = re.sub(r'\*([^*\s][^*]*?)\*', r'\1', t)
    return re.sub(r'\s+', ' ', t).strip()

def norm(t):
    return re.sub(r'[^a-z0-9]', '', t.lower())

def pages(ents):
    if not os.path.exists('thesis.pdf'):
        return {}
    n = int(re.search(r'Pages:\s+(\d+)', subprocess.run(['pdfinfo', 'thesis.pdf'], capture_output=True, text=True).stdout).group(1))
    raw = [subprocess.run(['pdftotext', '-f', str(p), '-l', str(p), '-layout', 'thesis.pdf', '-'],
                          capture_output=True, text=True).stdout for p in range(1, n + 1)]
    txt = [norm(r) for r in raw]
    # first page of Chapter 1: the chapter page itself, not a contents page (no dot leaders)
    ch1 = next(i for i, t in enumerate(txt) if 'chapter1introduction' in t and '.....' not in raw[i])
    out, cur = {}, {'toc': ch1, 'tab': 0, 'fig': 0}
    for k, (kind, lvl, t) in enumerate(ents):
        key = norm(clean(t))[:40]
        start = max(cur[kind], ch1)
        for p in range(start, n):
            if key in txt[p]:
                out[k] = p - ch1 + 1
                cur[kind] = p
                if kind != 'toc': cur['toc'] = max(cur['toc'], 0)
                break
    return out

def field(instr, paras):
    """paras: list of (style, text, page)"""
    W = 8640
    xs = []
    for i, (sty, text, pg) in enumerate(paras):
        runs = ''
        if i == 0:
            runs += ('<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> %s </w:instrText></w:r>'
                     '<w:r><w:fldChar w:fldCharType="separate"/></w:r>' % html.escape(instr, quote=False))
        runs += '<w:r><w:t xml:space="preserve">%s</w:t></w:r>' % html.escape(text, quote=False)
        runs += '<w:r><w:tab/></w:r><w:r><w:t>%s</w:t></w:r>' % (pg if pg is not None else '')
        if i == len(paras) - 1:
            runs += '<w:r><w:fldChar w:fldCharType="end"/></w:r>'
        xs.append('<w:p><w:pPr><w:pStyle w:val="%s"/><w:tabs><w:tab w:val="right" w:leader="dot" w:pos="%d"/></w:tabs>'
                  '<w:spacing w:before="0" w:after="60" w:line="276" w:lineRule="auto"/><w:jc w:val="left"/></w:pPr>%s</w:p>' % (sty, W, runs))
    return ''.join(xs)

ents = md_entries()
pg = pages(ents)
toc = [('TOC%d' % lvl, clean(t), pg.get(k)) for k, (kind, lvl, t) in enumerate(ents) if kind == 'toc']
tab = [('TOC1', clean(t), pg.get(k)) for k, (kind, lvl, t) in enumerate(ents) if kind == 'tab']
fig = [('TOC1', clean(t), pg.get(k)) for k, (kind, lvl, t) in enumerate(ents) if kind == 'fig']
f = open('front.md').read()
f = f.replace('TOCMAIN', field('TOC \\o "1-3" \\h \\z \\u', toc))
f = f.replace('TOCTAB', field('TOC \\h \\z \\t "Table Caption,1"', tab))
f = f.replace('TOCFIG', field('TOC \\h \\z \\t "Image Caption,1"', fig))
open('front_built.md', 'w').write(f)
missing = [p[1][:50] for p in toc + tab + fig if p[2] is None]
print('entries', len(toc), len(tab), len(fig), 'missing pages', len(missing), missing[:8])
