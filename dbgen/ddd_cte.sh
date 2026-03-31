#!/usr/bin/env bash
set -euo pipefail

# 1) 基础路径配置（可通过环境变量覆盖）
# 以脚本所在目录为基准，避免硬编码绝对路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DSS_CONFIG="${DSS_CONFIG:-$SCRIPT_DIR}"
CTE_QUERY_DIR="${CTE_QUERY_DIR:-$DSS_CONFIG/CTE_queries}"
# 默认输出目录：相对于仓库根的 ../../dddlearn/workloads/TPCH_CTE2
OUT_BASE_DIR="${OUT_BASE_DIR:-$SCRIPT_DIR/../../dddlearn/workloads/TPCH_CTE2}"
PYTHON_BIN="${PYTHON_BIN:-python3}"
CUSTOM_GEN_SCRIPT="${CUSTOM_GEN_SCRIPT:-$DSS_CONFIG/generate_custom_sql.py}"

# 2) 生成配置
# 默认每个模板生成多少条（可用 TEMPLATE_DEFAULT_COUNT 覆盖）
TEMPLATE_DEFAULT_COUNT="${TEMPLATE_DEFAULT_COUNT:-5}"
# 起始随机种子（可覆盖）
SEED_START="${SEED_START:-1}"
# 规模列表（可覆盖），例如: SCALES="1 10"
SCALES_STR="${SCALES:-1 10}"

# 3) 模板数量单独配置（按模板名，不带 .sql）
# 示例：让 c1 生成 50 条，把下面改成 ["c1"]=50
# 若没有配置，会回退到 TEMPLATE_DEFAULT_COUNT
# shellcheck disable=SC2034
declare -A TEMPLATE_COUNT_OVERRIDE=(
  # ["c1"]=50
)

# 4) 选择要生成的模板
# 默认扫描 CTE_QUERY_DIR 下全部 *.sql
# 也可通过 TEMPLATE_LIST 覆盖，例如: TEMPLATE_LIST="c1 c2"
if [[ -n "${TEMPLATE_LIST:-}" ]]; then
  read -r -a SELECTED_TEMPLATES <<< "${TEMPLATE_LIST}"
else
  mapfile -t SQL_FILES < <(find "$CTE_QUERY_DIR" -maxdepth 1 -type f -name "*.sql" | sort)
  SELECTED_TEMPLATES=()
  for f in "${SQL_FILES[@]}"; do
    base_name="$(basename "$f" .sql)"
    SELECTED_TEMPLATES+=("$base_name")
  done
fi

if [[ ${#SELECTED_TEMPLATES[@]} -eq 0 ]]; then
  echo "未找到任何 CTE 模板，请检查目录: $CTE_QUERY_DIR"
  exit 1
fi

# 5) 导出 qgen 需要的环境变量，并切换目录
export DSS_CONFIG
export DSS_QUERY="$CTE_QUERY_DIR"
cd "$DSS_CONFIG"

read -r -a SCALE_LIST <<< "$SCALES_STR"

echo "使用模板目录: $DSS_QUERY"
echo "输出根目录: $OUT_BASE_DIR"
echo "规模列表: ${SCALE_LIST[*]}"
echo "默认每模板数量: $TEMPLATE_DEFAULT_COUNT"
echo "自定义模板生成器: $CUSTOM_GEN_SCRIPT"

total_generated=0

# 6) 逐模板、逐规模生成 SQL
for tpl in "${SELECTED_TEMPLATES[@]}"; do
  count="${TEMPLATE_COUNT_OVERRIDE[$tpl]:-$TEMPLATE_DEFAULT_COUNT}"

  if ! [[ "$count" =~ ^[0-9]+$ ]] || [[ "$count" -le 0 ]]; then
    echo "模板 $tpl 的生成数量无效: $count"
    exit 1
  fi

  echo "开始生成模板 $tpl (数量: $count)"

  for scale in "${SCALE_LIST[@]}"; do
    out_dir="$OUT_BASE_DIR/${scale}g"
    mkdir -p "$out_dir"

    end_seed=$((SEED_START + count - 1))
    for ((seed = SEED_START; seed <= end_seed; seed++)); do
      output_sql="$out_dir/${tpl}_${seed}.sql"

      if [[ "$tpl" =~ ^[0-9]+$ ]]; then
        # 数字模板走官方 qgen（如 1..22, 15）
        ./qgen -c -s "$scale" -r "$seed" "$tpl" > "$output_sql"
      else
        # 非数字模板走 Python 参数替换器（如 c1/c2/c3）
        "$PYTHON_BIN" "$CUSTOM_GEN_SCRIPT" \
          --template "$CTE_QUERY_DIR/${tpl}.sql" \
          --output "$output_sql" \
          --seed "$seed" \
          --scale "$scale"
      fi

      total_generated=$((total_generated + 1))
    done

    echo "  规模 ${scale}g 完成: $out_dir"
  done
done

echo "全部完成，总共生成 SQL 文件: $total_generated"
