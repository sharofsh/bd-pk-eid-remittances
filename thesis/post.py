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
