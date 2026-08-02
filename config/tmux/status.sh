#!/usr/bin/env bash
# Sakura tmux status graphs: CPU / MEM / DSK with sparklines
# Prints:  CPU 35% ▁▃▅▇  MEM 72% ▁▃▅▇  DSK 67% ▁▃▅▇

read_cpu() {
  local line=$(head -n1 /proc/stat)
  local u n s i w x y z idle prev_idle prev_total total
  set -- $line
  u=$2 n=$3 s=$4 i=$5 w=$6 x=$7 y=$8 z=$9
  idle=$((i + w))
  total=$((u + n + s + idle + x + y))
  if [[ -f /tmp/sakura_cpu_prev ]]; then
    read -r prev_idle prev_total < /tmp/sakura_cpu_prev
  else
    prev_idle=$idle
    prev_total=$total
  fi
  echo "$idle $total" > /tmp/sakura_cpu_prev
  local dtotal=$((total - prev_total))
  local didle=$((idle - prev_idle))
  if [[ $dtotal -le 0 ]]; then
    echo 0
  else
    echo $(( (100 * (dtotal - didle)) / dtotal ))
  fi
}

read_mem() {
  awk '/MemTotal/ {t=$2} /MemAvailable/ {a=$2} END {if (t>0) printf "%.0f", (t-a)/t*100; else print 0}' /proc/meminfo
}

read_dsk() {
  df -h / 2>/dev/null | awk 'NR==2 {gsub(/%/,"",$5); print $5}'
}

# sparkline history (10 samples)
spark() {
  local val=$1 file=$2
  local -a data
  if [[ -f "$file" ]]; then
    mapfile -t data < "$file"
  fi
  data+=("$val")
  if [[ ${#data[@]} -gt 10 ]]; then
    data=("${data[@]: -10}")
  fi
  printf '%s\n' "${data[@]}" > "$file"
  local chars=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)
  local out="" v
  for v in "${data[@]}"; do
    local idx=$((v * 7 / 100))
    [[ $idx -gt 7 ]] && idx=7
    out+="${chars[$idx]}"
  done
  echo "$out"
}

CPU=$(read_cpu)
MEM=$(read_mem)
DSK=$(read_dsk)

CPU_SPARK=$(spark "$CPU" /tmp/sakura_cpu_spark)
MEM_SPARK=$(spark "$MEM" /tmp/sakura_mem_spark)
DSK_SPARK=$(spark "$DSK" /tmp/sakura_dsk_spark)

printf 'CPU %s%% %s MEM %s%% %s DSK %s%% %s' \
  "$CPU" "$CPU_SPARK" "$MEM" "$MEM_SPARK" "$DSK" "$DSK_SPARK"