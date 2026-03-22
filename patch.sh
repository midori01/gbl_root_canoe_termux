bash clean.sh
python tools/extractfv.py ./images/abl.img ./dist/ABL_original.efi
g++ -o tools/patch_abl tools/patch_abl.cpp
./tools/patch_abl ./dist/ABL_original.efi ./dist/ABL.efi > ./dist/patch_log.txt
rm tools/patch_abl
rm ./dist/ABL_original.efi
cat ./dist/patch_log.txt