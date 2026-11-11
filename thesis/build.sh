set -e
cd "$(dirname "$0")"
{ cat front.md; printf "\n\n"; cat body.md; printf "\n\n"; cat back.md; } > thesis.md
pandoc thesis.md -f markdown+raw_attribute -o raw.docx --reference-doc=ref.docx --resource-path=.
rm -rf rawx && mkdir rawx && cd rawx && unzip -q ../raw.docx && python3 -I ../post.py && rm -f ../thesis.docx && zip -q -X -r -D ../thesis.docx . && cd ..
soffice --headless --convert-to pdf thesis.docx >/dev/null 2>&1
pdfinfo thesis.pdf | grep Pages
