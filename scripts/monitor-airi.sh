#!/usr/bin/env bash
# monitor-airi.sh — 阶段 A 实测期间的资源采样脚本(macOS)
#
# 用途:在 20 分钟连续对话实测期间后台运行,采样 AIRI 全部相关进程的
#       CPU / 内存,以及系统 swap 使用量,输出 CSV 供事后分析。
#
# 用法:
#   scripts/monitor-airi.sh [间隔秒=5] [输出csv] [持续秒=0(表示一直跑到 Ctrl-C)]
#
# 示例:
#   scripts/monitor-airi.sh 5 airi-20min.csv &          # 后台采样,Ctrl-C 结束
#   scripts/monitor-airi.sh 5 airi-20min.csv 1500       # 采样 25 分钟自动停止
#
# 判读:
#   * AIRI 未运行/崩溃期间,脚本会写入 pid=0 的占位行 —— 时间轴上不会留空洞,
#     可据此判断崩溃/重启时刻。
#   * swap_used 持续增长 + RSS 逼近 8~10GB 视为内存风险信号(16GB 机器)。

set -euo pipefail

INTERVAL="${1:-5}"
OUT="${2:-airi-monitor-$(date +%Y%m%d-%H%M%S).csv}"
DURATION="${3:-0}"

echo "elapsed_s,timestamp,pid,proc,cpu_pct,rss_mb,swap_used_mb,swap_total_mb,note" > "$OUT"
echo "[monitor] 采样中(每 ${INTERVAL}s 一行)→ $OUT ;Ctrl-C 结束"

cleanup() { echo "[monitor] 已停止,数据: $OUT"; exit 0; }
trap cleanup INT TERM

START=$(date +%s)

sample_once() {
  local elapsed="$1" ts="$2"
  local swap_line swap_total swap_used found=0

  swap_line=$(sysctl -n vm.swapusage 2>/dev/null || echo "")
  swap_total=$(sed -E 's/.*total = ([0-9.]+)M.*/\1/' <<<"$swap_line")
  swap_used=$(sed -E 's/.*used = ([0-9.]+)M.*/\1/' <<<"$swap_line")
  [[ "$swap_line" != *total* ]] && { swap_total="NA"; swap_used="NA"; }

  # top 单次采样:pid,cpu,mem,command;mem 形如 845M / 1.2G
  while IFS=, read -r pid cpu mem procname; do
    [[ -z "$pid" ]] && continue
    found=1
    case "$mem" in
      *G) rss=$(awk -v v="${mem%G}" 'BEGIN{printf "%.0f", v*1024}');;
      *M) rss="${mem%M}";;
      *K) rss=$(awk -v v="${mem%K}" 'BEGIN{printf "%.0f", v/1024}');;
      *)  rss="$mem";;
    esac
    echo "${elapsed},${ts},${pid},${procname},${cpu},${rss},${swap_used},${swap_total}," >> "$OUT"
  done < <(top -l 1 -o cpu -stats pid,cpu,mem,command 2>/dev/null \
           | grep -iE '\bairi\b' | grep -v grep | awk '{pid=$1;cpu=$2;mem=$3;$1=$2=$3="";sub(/^ +/,"");print pid","cpu","mem","$0}')

  if [[ "$found" -eq 0 ]]; then
    echo "${elapsed},${ts},0,(no-airi-process),0,0,${swap_used},${swap_total},AIRI_NOT_RUNNING" >> "$OUT"
  fi
}

while :; do
  now=$(date +%s)
  elapsed=$((now - START))
  sample_once "$elapsed" "$(date +%H:%M:%S)"

  if (( DURATION > 0 && elapsed >= DURATION )); then
    echo "[monitor] 达到 ${DURATION}s,自动停止"
    cleanup
  fi
  sleep "$INTERVAL"
done
