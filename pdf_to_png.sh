#!/bin/bash


# 사용하는 툴
# pdftoppm

# 기본 셋팅
# brew install poppler


# 명령하기 가이드

# 1. 입력: chmod +x pdf_to_png.sh
# 2. 입력: ./pdf_to_png.sh png 300 GD_png    
    # 인자는 총 3개: 
    # png로 할꺼냐 jpg로 할꺼냐
    # 해상도 값(300이 가장 표준, 1부터 입력가능)
    # 저장할 파일 이름
    # 예) ./pdf_to_png.sh png 300 GD_png    

# 시작 시간 기록
START_TIME=$(date +%s)

# ========== 사용자 설정: 입력 및 출력 폴더 ==========
INPUT_DIR="/Users/jaesincho/Desktop/shell_script"
BASE_OUTPUT_DIR="/Users/jaesincho/Desktop/shell_script"
# ===================================================

# 인자: 형식, 해상도, 파일 이름 접두사
FORMAT=${1:-png}
DPI=${2:-400}
PREFIX=${3:-pdf_to_png}

# 일단 임시 출력 폴더 생성 (시간은 나중에 붙임)
TEMP_OUTPUT_DIR="${BASE_OUTPUT_DIR}_${DPI}dpi_temp"
mkdir -p "$TEMP_OUTPUT_DIR"

echo "📂 입력 폴더: $INPUT_DIR"
echo "📁 출력 폴더 (임시): $TEMP_OUTPUT_DIR"
echo "📄 저장 형식: $FORMAT"
echo "🖼️  해상도: ${DPI} DPI"
echo "🏷️  파일 접두사: $PREFIX"

# PDF 파일 순회하며 변환
for f in "$INPUT_DIR"/*.pdf; do
  filename=$(basename "$f" .pdf)
  echo "➡️  변환 중: $filename.pdf -> ${PREFIX}_${filename}-01.$FORMAT ..."
  pdftoppm -r "$DPI" -${FORMAT} "$f" "${TEMP_OUTPUT_DIR}/${PREFIX}_${filename}"
done

# 종료 시간 기록 및 계산
END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))

# 분초 계산
MINUTES=$((ELAPSED / 60))
SECONDS=$((ELAPSED % 60))
TIME_LABEL="${MINUTES}m${SECONDS}s"

# 최종 폴더 이름 생성
FINAL_OUTPUT_DIR="${BASE_OUTPUT_DIR}_${DPI}dpi_${TIME_LABEL}"
mv "$TEMP_OUTPUT_DIR" "$FINAL_OUTPUT_DIR"

echo "✅ 변환 완료!"
echo "📁 최종 폴더: $FINAL_OUTPUT_DIR"
