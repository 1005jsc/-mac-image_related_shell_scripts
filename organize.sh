#!/bin/bash


# 입력 방법

# 예) ./organize.sh /Users/jaesincho/Desktop/my_images
# 인자: 정리할 대상 폴더

# 인자로 받은 정리 대상 폴더 (없으면 현재 디렉토리)


TARGET_DIR=${1:-.}

# 1MB = 1048576 bytes
ONE_MB=1048576

# PNG 파일 순회
find "$TARGET_DIR" -maxdepth 1 -type f -iname '*.png' | while read -r file; do
  # macOS에서는 stat -f %z 사용
  size_bytes=$(stat -f %z "$file")

  # MB로 변환 (소수점 올림)
  size_mb=$(echo "scale=2; $size_bytes / $ONE_MB" | bc)
  size_mb_ceil=$(echo "($size_mb + 0.999)/1" | bc)

  # 1MB 이하이면 특별 폴더 이름
  is_less_than_1=$(echo "$size_mb < 1" | bc)
  if [ "$is_less_than_1" -eq 1 ]; then
    folder_name="1mb이하"
  else
    folder_name="${size_mb_ceil}mb"
  fi

  # 폴더 없으면 생성
  mkdir -p "$TARGET_DIR/$folder_name"

  # 중복 파일 처리
  base_name=$(basename "$file")
  dest_file="$TARGET_DIR/$folder_name/$base_name"
  count=1
  while [ -e "$dest_file" ]; do
    filename="${base_name%.*}"
    extension="${base_name##*.}"
    dest_file="$TARGET_DIR/$folder_name/${filename}_$count.$extension"
    ((count++))
  done

  # 파일 이동
  mv "$file" "$dest_file"
  echo "Moved: $file -> $dest_file"
done
