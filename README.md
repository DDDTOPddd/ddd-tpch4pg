tpch-kit
========

TPC-H 基准套件（含若干修改/扩展）

官方 TPC-H 基准 - [http://www.tpc.org/tpch](http://www.tpc.org/tpch)

## 修改说明

在官方 TPC-H 套件基础上添加了以下修改：

- 修改 `dbgen`，去除行尾多余分隔符的输出
- 为 `dbgen` 添加输出到 stdout 的选项
- 增加对 macOS 的编译支持
- 为 PostgreSQL 添加宏定义，以便 `qgen` 支持 `LIMIT N`
- 调整 `Makefile` 的默认设置

## 安装与构建

### Linux

请确保已安装所需的开发工具：

Ubuntu:
```
sudo apt-get install git make gcc
```

CentOS/RHEL:
```
sudo yum install git make gcc
```

然后执行以下命令克隆仓库并构建工具：

```
git clone https://github.com/gregrahn/tpch-kit.git
cd tpch-kit/dbgen
make MACHINE=LINUX DATABASE=POSTGRESQL
```

### macOS

请确保已安装所需的开发工具：

```
xcode-select --install
```

然后执行以下命令克隆仓库并构建工具：

```
git clone https://github.com/gregrahn/tpch-kit.git
cd tpch-kit/dbgen
make MACHINE=MACOS DATABASE=POSTGRESQL
```

## 使用 TPC-H 工具

### 环境变量

请正确设置以下环境变量：

```
export DSS_CONFIG=/.../tpch-kit/dbgen
export DSS_QUERY=$DSS_CONFIG/queries
export DSS_PATH=/path-to-dir-for-output-files
```

### SQL 方言

有关有效 `DATABASE` 值，请参阅 `Makefile`。每种方言的详细信息见 `tpcd.h`。如有需要，可调整 `tpch-kit/dbgen/queries` 中的查询模板。

### 数据生成

数据由 `dbgen` 生成。使用 `dbgen -h` 查看所有选项。可通过环境变量 `DSS_PATH` 指定输出位置。

### 查询生成

查询由 `qgen` 生成。使用 `qgen -h` 查看所有选项。

下面的命令可用于按编号顺序生成 1GB 规模（`-s 1`）下的全部 22 个查询，使用默认替换变量（`-d`）：

```
qgen -v -c -d -s 1 > tpch-stream.sql
```

要为 SF 3000（3TB）生成每个查询一个文件，可使用：

```
for ((i=1;i<=22;i++)); do
  ./qgen -v -c -s 3000 ${i} > /tmp/sf3000/tpch-q${i}.sql
done
```
