#!/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="ViewBattery"
DMG_NAME="ViewBattery.dmg"
DMG_PATH="$PROJECT_DIR/$DMG_NAME"
TEMP_DMG_DIR="$PROJECT_DIR/.build/dmg_temp"

# 1. Đảm bảo bản build mới nhất đã sẵn sàng
echo "🔨 Đang đảm bảo bản Release mới nhất..."
"$PROJECT_DIR/scripts/build_app.sh"

echo "💿 Đang tạo $DMG_NAME..."
rm -rf "$TEMP_DMG_DIR" "$DMG_PATH"
mkdir -p "$TEMP_DMG_DIR"

# 2. Copy App và tạo shortcut kéo thả vào Applications
cp -R "$PROJECT_DIR/$APP_NAME.app" "$TEMP_DMG_DIR/"
ln -s /Applications "$TEMP_DMG_DIR/Applications"

# 3. Đóng gói file .dmg nén chuẩn định dạng UDZO
hdiutil create -volname "$APP_NAME" \
               -srcfolder "$TEMP_DMG_DIR" \
               -ov \
               -format UDZO \
               "$DMG_PATH"

# 4. Dọn dẹp thư mục tạm
rm -rf "$TEMP_DMG_DIR"

echo "🎉 Đã đóng gói thành công: $DMG_PATH"
echo "📊 Kích thước: $(ls -lh "$DMG_PATH" | awk '{print $5}')"
