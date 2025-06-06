#!/bin/bash

# 사용법 명령어
# 1. 권한 풀기
#    입력: chmod +x organize.sh
# 2. 실행하기
#    입력: ./organize.sh


INPUT_DIR="$(pwd)"

echo "📂 현재 디렉토리: $INPUT_DIR"
echo "🛠️  이미지 파일을 용량별로 분류합니다..."

# find로 jpg/jpeg/png 찾기
find "$INPUT_DIR" -maxdepth 1 \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | while read -r file; do
  [ -f "$file" ] || continue

  filename=$(basename "$file")
  size_bytes=$(stat -f %z "$file")
  size_mb=$(echo "scale=1; $size_bytes / 1048576" | bc)

  # 1MB 미만
  if (( $(echo "$size_mb < 1" | bc -l) )); then
    folder_name="1mb이하"
  elif (( $(echo "$size_mb < 10" | bc -l) )); then
    folder_int=$(printf "%.0f" "$size_mb")
    folder_name="${folder_int}mb"
  else
    # 10MB 이상 → 5MB 구간 분류
    lower=$(( ($(echo "$size_mb / 5" | bc) * 5) ))
    upper=$((lower + 5))
    folder_name="${lower}~${upper}mb"
  fi

  dest_folder="$INPUT_DIR/$folder_name"
  mkdir -p "$dest_folder"

  echo "📦 이동: $filename → [$folder_name]"
  mv "$file" "$dest_folder/"
done

echo "🎉 분류 완료! 폴더별로 이미지가 정리되었습니다."
