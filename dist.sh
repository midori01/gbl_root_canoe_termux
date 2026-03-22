# gen zip
mkdir release
if [ -z "$2" ]; then
    echo "No readme file provided, skipping copy."
else
    echo $2 > dist/readme.txt
fi
zip -r release/$1.zip dist