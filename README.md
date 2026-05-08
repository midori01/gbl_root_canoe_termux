# Usage

## 1. Extraction
Extract the abl.img from your current active slot and place it in the images folder.
Example: Extract via ADB or Root Shell

```dd if=/dev/block/by-name/abl_a of=/sdcard/abl.img```

## 2. Patching
Execute the patch script to process the image

```make clean```
```make patch```

## 3. Flashing
The patched file will be generated in the dist folder. Flash it to the efisp partition via fastboot

```fastboot flash efisp ./dist/ABL.efi```

## 4. Advanced Options
Build ABL with Superfastboot

```make build```

Build KernelSU/Magisk/APatch module. (located in the release folder)

```make build_module```
