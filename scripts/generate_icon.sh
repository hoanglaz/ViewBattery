#!/bin/bash
set -e

SOURCE_IMG="${1:-ecology.png}"
OUTPUT_ICNS="Resources/AppIcon.icns"

if [ ! -f "$SOURCE_IMG" ]; then
    echo "❌ Không tìm thấy ảnh nguồn: $SOURCE_IMG"
    exit 1
fi

echo "🎨 Đang tạo bộ icon từ $SOURCE_IMG..."
mkdir -p AppIcon.iconset Resources

# Tạo ảnh chuẩn 1024x1024
sips -z 1024 1024 "$SOURCE_IMG" --out AppIcon.iconset/icon_512x512@2x.png

# Tạo đầy đủ 10 kích thước chuẩn Apple HIG
sips -z 16 16     AppIcon.iconset/icon_512x512@2x.png --out AppIcon.iconset/icon_16x16.png
sips -z 32 32     AppIcon.iconset/icon_512x512@2x.png --out AppIcon.iconset/icon_16x16@2x.png
sips -z 32 32     AppIcon.iconset/icon_512x512@2x.png --out AppIcon.iconset/icon_32x32.png
sips -z 64 64     AppIcon.iconset/icon_512x512@2x.png --out AppIcon.iconset/icon_32x32@2x.png
sips -z 128 128   AppIcon.iconset/icon_512x512@2x.png --out AppIcon.iconset/icon_128x128.png
sips -z 256 256   AppIcon.iconset/icon_512x512@2x.png --out AppIcon.iconset/icon_128x128@2x.png
sips -z 256 256   AppIcon.iconset/icon_512x512@2x.png --out AppIcon.iconset/icon_256x256.png
sips -z 512 512   AppIcon.iconset/icon_512x512@2x.png --out AppIcon.iconset/icon_256x256@2x.png
sips -z 512 512   AppIcon.iconset/icon_512x512@2x.png --out AppIcon.iconset/icon_512x512.png

# Biên dịch ra file .icns
iconutil -c icns AppIcon.iconset -o "$OUTPUT_ICNS"

# Dọn dẹp thư mục tạm
rm -rf AppIcon.iconset

echo "✅ Đã tạo thành công: $OUTPUT_ICNS"
