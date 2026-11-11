import sys, copy
import docx
from docx.shared import Pt, Inches, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH, WD_LINE_SPACING
from docx.enum.style import WD_STYLE_TYPE
from docx.oxml.ns import qn
from docx.oxml import parse_xml

src, out = sys.argv[1], sys.argv[2]
d = docx.Document(src)
# empty the body but keep the final sectPr
body = d.element.body
for el in list(body):
    if el.tag != qn('w:sectPr'):
        body.remove(el)

S = d.styles
def get(name, kind=WD_STYLE_TYPE.PARAGRAPH, base=None):
    try:
        return S[name]
    except KeyError:
        st = S.add_style(name, kind)
        if base: st.base_style = S[base]
        return st

def fmt(name, size=12, bold=None, italic=None, align=None, before=0, after=0, line=None,
        pbb=None, keep=None, base=None, indent_left=None, first=None, kind=WD_STYLE_TYPE.PARAGRAPH):
    st = get(name, kind, base)
    f = st.font
    f.name = 'Times New Roman'; f.size = Pt(size); f.color.rgb = RGBColor(0, 0, 0)
    rpr = st.element.get_or_add_rPr()
    rf = rpr.find(qn('w:rFonts'))
    if rf is None:
        rf = rpr.makeelement(qn('w:rFonts'), {}); rpr.insert(0, rf)
    for a in ['w:asciiTheme', 'w:hAnsiTheme', 'w:eastAsiaTheme', 'w:cstheme']:
        if rf.get(qn(a)) is not None: del rf.attrib[qn(a)]
    for a in ['w:ascii', 'w:hAnsi', 'w:cs']:
        rf.set(qn(a), 'Times New Roman')
    if bold is not None: f.bold = bold
    if italic is not None: f.italic = italic
    if kind == WD_STYLE_TYPE.CHARACTER:
        return st
    pf = st.paragraph_format
    if align is not None: pf.alignment = align
    pf.space_before = Pt(before); pf.space_after = Pt(after)
    if line: pf.line_spacing = line
    if pbb is not None: pf.page_break_before = pbb
    if keep is not None: pf.keep_with_next = keep
    if indent_left is not None: pf.left_indent = indent_left
    if first is not None: pf.first_line_indent = first
    return st

J, C, L = WD_ALIGN_PARAGRAPH.JUSTIFY, WD_ALIGN_PARAGRAPH.CENTER, WD_ALIGN_PARAGRAPH.LEFT
fmt('Normal', 12, align=J, after=4, line=1.5)
fmt('Body Text', 12, align=J, after=8, line=1.5, base='Normal')
fmt('First Paragraph', 12, align=J, after=8, line=1.5, base='Body Text')
fmt('Compact', 10.5, align=L, before=1, after=1, line=1.0, base='Body Text')
fmt('Heading 1', 16, bold=True, align=C, before=0, after=18, line=1.5, pbb=True, keep=True)
fmt('Heading 2', 13, bold=True, align=L, before=14, after=6, keep=True)
fmt('Heading 3', 12, bold=True, italic=True, align=L, before=10, after=4, keep=True)
fmt('TitlePageTitle', 20, bold=True, align=C, before=72, after=24, line=1.15, base='Normal')
fmt('Centered', 13, align=C, before=18, after=6, line=1.5, base='Normal')
fmt('FrontHeading', 18, bold=True, align=C, before=0, after=18, pbb=True, keep=True, base='Normal')
fmt('SignBlock', 12, align=L, before=48, after=6, line=1.5, base='Normal')
fmt('Reference', 12, align=L, after=8, line=1.15, base='Normal', indent_left=Inches(0.5), first=Inches(-0.5))
fmt('Table Caption', 11, bold=True, align=L, before=10, after=4, keep=True, base='Normal')
fmt('Image Caption', 11, bold=True, align=C, before=2, after=12, base='Normal')
fmt('Captioned Figure', 12, align=C, before=8, after=0, keep=True, base='Normal')
fmt('Figure', 12, align=C, before=8, after=0, keep=True, base='Normal')
for i in (1, 2, 3):
    fmt(f'TOC {i}' if f'toc {i}' else '', 11.5, align=L, after=3, base='Normal',
        indent_left=Inches(0.25 * (i - 1)))
# list paragraphs inherit Body Text spacing; pandoc bullets use Compact/Body Text with numbering

# Table style "Table": horizontal rules (booktabs-like) + header bold
xml = ('<w:style xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" '
       'w:type="table" w:styleId="Table"><w:name w:val="Table"/><w:basedOn w:val="TableNormal"/>'
       '<w:uiPriority w:val="59"/><w:pPr><w:spacing w:before="20" w:after="20"/></w:pPr>'
       '<w:rPr><w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:cs="Times New Roman"/><w:sz w:val="21"/></w:rPr>'
       '<w:tblPr><w:tblBorders><w:top w:val="single" w:sz="8" w:space="0" w:color="000000"/>'
       '<w:bottom w:val="single" w:sz="8" w:space="0" w:color="000000"/>'
       '<w:insideH w:val="single" w:sz="2" w:space="0" w:color="BFBFBF"/></w:tblBorders>'
       '<w:tblCellMar><w:left w:w="80" w:type="dxa"/><w:right w:w="80" w:type="dxa"/></w:tblCellMar></w:tblPr>'
       '<w:tblStylePr w:type="firstRow"><w:rPr><w:b/></w:rPr><w:tcPr><w:tcBorders>'
       '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
       '<w:shd w:val="clear" w:color="auto" w:fill="F2F2F2"/></w:tcPr></w:tblStylePr></w:style>')
stl = S.element
for e in stl.findall(qn('w:style')):
    if e.get(qn('w:styleId')) == 'Table':
        stl.remove(e)
stl.append(parse_xml(xml))
d.save(out)
print('ref ok')
