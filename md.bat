call markdown -s ../modest.css README.md > index.html
echo ^<meta charset=utf-8^> >> index.html
start index.html

call markdown -s ../modest.css README_en.md > index_en.html
echo ^<meta charset=utf-8^> >> index_en.html
start index_en.html