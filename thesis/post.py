import re, sys
p = 'word/document.xml'
d = open(p).read()
final = re.findall(r'<w:sectPr [^>]*>.*?</w:sectPr>', d, re.S)[-1]
# front-matter section: roman numerals, no number on title page
front = re.sub(r'<w:sectPr [^>]*>', '<w:sectPr>', final)
front = front.replace('<w:cols ', '<w:pgNumType w:fmt="lowerRoman" w:start="1"/><w:cols ')
front = front.replace('<w:sectPr>', '<w:sectPr><w:type w:val="nextPage"/>', 1) if False else front
assert d.count('<w:p><w:pPr><w:sectPr/></w:pPr></w:p>') == 1
d = d.replace('<w:p><w:pPr><w:sectPr/></w:pPr></w:p>', '<w:p><w:pPr>' + front + '</w:pPr></w:p>')
# main section: arabic from 1, number on first page
main = final.replace('<w:titlePg />', '').replace('<w:cols ', '<w:pgNumType w:fmt="decimal" w:start="1"/><w:cols ')
d = d[:d.rfind(final)] + main + d[d.rfind(final) + len(final):]
# chapter 1 heading follows a section break: no extra page break
d = d.replace('<w:pPr><w:pStyle w:val="Heading1" /></w:pPr><w:r><w:t xml:space="preserve">Chapter 1</w:t>',
              '<w:pPr><w:pStyle w:val="Heading1" /><w:pageBreakBefore w:val="0"/></w:pPr><w:r><w:t xml:space="preserve">Chapter 1</w:t>', 1)
open(p, 'w').write(d)
print('post ok')

# ---- APA tables: full text width, title block above (bold number, italic title), centred header ----
import html as _h
d = open(p).read()
TW = 8640
def fix_tbl(m):
    t = m.group(0)
    cols = [int(x) for x in re.findall(r'<w:gridCol w:w="(\d+)" ?/>', t)]
    if cols:
        rows = re.findall(r'<w:tr>.*?</w:tr>', t, re.S)
        cells = [[''.join(re.findall(r'<w:t[^>]*>([^<]*)</w:t>', c)) for c in re.findall(r'<w:tc>.*?</w:tc>', r, re.S)] for r in rows]
        n = len(cols)
        mins, avg = [], []
        for j in range(n):
            col = [r[j] for r in cells if j < len(r)]
            lw = max([len(w) for c in col for w in c.split()] or [1])
            mins.append(lw * 110 + 200)
            avg.append(sum(len(c) for c in col) / max(len(col), 1) + 1)
        if sum(mins) >= TW:
            new = [round(m * TW / sum(mins)) for m in mins]
        else:
            extra = TW - sum(mins); new = [round(mins[j] + extra * avg[j] / sum(avg)) for j in range(n)]
        new[-1] += TW - sum(new)
        it = iter(new)
        t = re.sub(r'<w:gridCol w:w="\d+" ?/>', lambda _: '<w:gridCol w:w="%d"/>' % next(it), t)
        # cell widths: assign per row in order (no merged cells in this thesis)
        def fix_row(r):
            k = iter(new)
            return re.sub(r'<w:tcW [^>]*/>', lambda _: '<w:tcW w:w="%d" w:type="dxa"/>' % next(k, TW // len(new)), r.group(0))
        t = re.sub(r'<w:tr>.*?</w:tr>', fix_row, t, flags=re.S)
    t = re.sub(r'<w:tblW [^>]*/>', '<w:tblW w:w="%d" w:type="dxa"/><w:tblLayout w:type="fixed"/>' % TW, t, 1)
    # centre header row paragraphs
    first = re.search(r'<w:tr>.*?</w:tr>', t, re.S)
    if first:
        hr = first.group(0)
        hr2 = re.sub(r'<w:p>(?!<w:pPr>)', '<w:p><w:pPr><w:jc w:val="center"/></w:pPr>', hr)
        hr2 = re.sub(r'<w:p><w:pPr>((?:(?!</w:pPr>).)*?)</w:pPr>', lambda q: q.group(0) if 'w:jc' in q.group(1) else '<w:p><w:pPr>%s<w:jc w:val="center"/></w:pPr>' % q.group(1), hr2)
        t = t.replace(hr, hr2, 1)
    # repeat header row; keep small tables on one page
    t = re.sub(r'<w:tr>(<w:trPr>)?', lambda q: '<w:tr><w:trPr><w:cantSplit/>' if q.group(1) else '<w:tr><w:trPr><w:cantSplit/></w:trPr>', t)
    rows = re.findall(r'<w:tr>.*?</w:tr>', t, re.S)
    if len(rows) <= 16:
        for r in rows[:-1]:
            r2 = re.sub(r'<w:p><w:pPr>', '<w:p><w:pPr><w:keepNext/>', r)
            r2 = re.sub(r'<w:p>(?!<w:pPr>)', '<w:p><w:pPr><w:keepNext/></w:pPr>', r2)
            t = t.replace(r, r2, 1)
    return t
d = re.sub(r'<w:tbl>.*?</w:tbl>', fix_tbl, d, flags=re.S)
def fix_cap(m):
    txt = ''.join(re.findall(r'<w:t[^>]*>([^<]*)</w:t>', m.group(0)))
    num, _, title = _h.unescape(txt).partition(': ')
    e = lambda s: _h.escape(s, quote=False)
    return ('<w:p><w:pPr><w:pStyle w:val="TableCaption" /></w:pPr><w:r><w:rPr><w:b/></w:rPr><w:t xml:space="preserve">%s</w:t></w:r>'
            '<w:r><w:br/></w:r><w:r><w:rPr><w:i/></w:rPr><w:t xml:space="preserve">%s</w:t></w:r></w:p>') % (e(num), e(title))
d = re.sub(r'<w:p><w:pPr><w:pStyle w:val="TableCaption" ?/></w:pPr>.*?</w:p>', fix_cap, d, flags=re.S)
open(p, 'w').write(d)
print('apa tables ok')
