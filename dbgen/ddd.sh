# 1. 设置环境变量，指向你的 tpch-kit/dbgen 目录
export DSS_CONFIG=/home/dddtop/workspace/ddd-tpch4pg/dbgen
export DSS_QUERY=$DSS_CONFIG/queries

# 2. 定义目标输出路径
DIR_1G=/home/dddtop/workspace/dddlearn/workloads/TPCH/1g
DIR_10G=/home/dddtop/workspace/dddlearn/workloads/TPCH/10g

# 3. 创建输出文件夹（如果不存在则自动创建）
mkdir -p $DIR_1G
mkdir -p $DIR_10G

# 4. 切换到 dbgen 目录，确保 qgen 可以正确运行
cd $DSS_CONFIG

# 5. 生成 1G 的 SQL (22个模板 * 20条)
echo "开始生成 1G SQL..."
for q in {1..22}; do
  for seed in {1..20}; do
    # -s 1: 对应 1G 规模; -r $seed: 使用不同的随机种子生成变体
    ./qgen -c -s 1 -r $seed $q > $DIR_1G/q${q}_${seed}.sql
  done
done
echo "1G SQL 生成完毕：共 440 个文件已保存至 $DIR_1G"

# 6. 生成 10G 的 SQL (22个模板 * 20条)
echo "开始生成 10G SQL..."
for q in {1..22}; do
  for seed in {1..20}; do
    # -s 10: 对应 10G 规模; -r $seed: 使用不同的随机种子生成变体
    ./qgen -c -s 10 -r $seed $q > $DIR_10G/q${q}_${seed}.sql
  done
done
echo "10G SQL 生成完毕：共 440 个文件已保存至 $DIR_10G"