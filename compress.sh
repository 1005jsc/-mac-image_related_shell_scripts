
#!/bin/bash

# 사용법 명령어
# 1. 권한 풀기
#    입력: chmod +x compress.sh
# 2. 실행하기 (** 마지막 숫자에 1~9의 숫자를 넣으면 된다, 1이면 덜 압축 9면 강하게 압축)
#   예) ./compress.sh 6
# 


# 입력 인자 체크
if [ -z "$1" ]; then
  echo "❌ 압축 레벨을 인자로 입력하세요! 예: ./compress_mozjpeg.sh 6"
  exit 1
fi

LEVEL=$1

if ! [[ "$LEVEL" =~ ^[0-9]$ ]] || [ "$LEVEL" -lt 0 ] || [ "$LEVEL" -gt 9 ]; then
  echo "❌ 압축 레벨은 0~9 사이의 숫자여야 합니다."
  exit 1
fi

# 경로 설정
INPUT_DIR="$(pwd)"
OUTPUT_DIR="$HOME/Desktop/compressed_${LEVEL}"
CJPEG="/opt/homebrew/opt/mozjpeg/bin/cjpeg"

mkdir -p "$OUTPUT_DIR"

# 파일 처리
find "$INPUT_DIR" -maxdepth 1 \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | while read -r file; do
  [ -f "$file" ] || continue

  filename=$(basename "$file")
  extension="${filename##*.}"
  filename="${filename%.*}"

  echo "🛠️  압축 중: $filename.$extension"

  quality=$((100 - LEVEL * 10))
  temp_output="$OUTPUT_DIR/${filename}_temp.jpg"

  if [[ "$extension" =~ ^[Pp][Nn][Gg]$ ]]; then
    # PNG → JPEG 변환 + mozjpeg 압축
    magick "$file" -strip -background white -flatten jpg:- | "$CJPEG" -quality "$quality" > "$temp_output"
  else
    # JPEG → mozjpeg 압축
    "$CJPEG" -quality "$quality" "$file" > "$temp_output"
  fi

  # 용량 계산 및 출력 파일 이름 지정
  size_bytes=$(stat -f %z "$temp_output" 2>/dev/null)

  if [ -z "$size_bytes" ] || [ "$size_bytes" -le 0 ]; then
    echo "⚠️ 오류: $filename 압축 실패 (비어 있거나 손상)"
    rm -f "$temp_output"
    continue
  fi

  if [ "$size_bytes" -ge 1048576 ]; then
    size_mb=$(echo "scale=1; $size_bytes / 1048576" | bc)
    size_label="${size_mb}MB"
  else
    size_kb=$((size_bytes / 1024))
    size_label="${size_kb}KB"
  fi

  output="$OUTPUT_DIR/${filename}_${size_label}.jpg"
  mv "$temp_output" "$output"

  echo "✅ 압축 완료: $filename → ${size_label}"
done

echo "🎉 모든 이미지 압축이 완료되었습니다!"
echo "📁 압축된 이미지는 '$OUTPUT_DIR' 폴더에 저장되었습니다."
