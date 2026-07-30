#!/bin/bash

# نام‌های جدید را اینجا تعریف کنید
NEW_NAME="YourNewAppName"
NEW_OWNER="YourGitHubUsername"

# 1. جایگزینی در تمام فایل‌های متنی (به جز پوشه .git)
find . -type f -not -path "./.git/*" -exec sed -i "s/YourNewAppName/$NEW_NAME/g" {} +
find . -type f -not -path "./.git/*" -exec sed -i "s/YourGitHubUsername/$NEW_OWNER/g" {} +

# 2. تغییر نام فایل‌ها و پوشه‌های خاص (اگر وجود داشته باشند)
# پوشه اصلی پروژه
mv YourNewAppName-Android-Antivirus $NEW_NAME-Android-Antivirus 2>/dev/null || true
# فایل‌های ویندوز (اختیاری)
find Windows -type f -name "*.rc" -exec sed -i "s/YourNewAppName/$NEW_NAME/g" {} +

echo "✅ تغییرات با موفقیت اعمال شد!"
