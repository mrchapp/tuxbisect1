#!/bin/bash

declare -a status
declare -a commits
status_printed=false
num_commits=0
total_commits=0

#SKIP_INERT=false
#STATUS=line
SKIP_INERT=true
STATUS=list

# $1: status
# $2: commit
print_status_line() {
  case $1 in
    inert)      icon="➖"   ;;
    queued)     icon="⏳"   ;;
    building)   icon="⚗️ "   ;;
    testing)    icon="🚀"   ;;
    successful) icon="✔️ "   ;;
    failed)     icon="❌"   ;;
  esac

  if [ ! "${1}" = "inert" ] || [ ! "${SKIP_INERT}" = "true" ]; then
    echo "${icon} $2"
  fi
  unset icon
}

# $1: status
print_status_item() {
  case $1 in
    inert)      icon="➖"   ;;
    queued)     icon="⏳"   ;;
    building)   icon="⚗️ "   ;;
    testing)    icon="🚀"   ;;
    successful) icon="✔️ "   ;;
    failed)     icon="❌"   ;;
  esac

  if [ ! "${1}" = "inert" ] || [ ! "${SKIP_INERT}" = "true" ]; then
    echo -n "${icon}"
  fi
  unset icon
}

new_status() {
  status_printed=false
  total_commits=$((${#commits[@]} - 1))
  num_commits=0

  for i in $(seq 0 "${total_commits[@]}"); do
    if [ ! "${status[${i}]}" = "inert" ] || [ ! "${SKIP_INERT}" = "true" ]; then
      num_commits=$((num_commits + 1))
    fi
  done
}

print_status() {
  case ${STATUS} in
    line)
      if [ "${status_printed}" = "true" ]; then
        echo -ne "\e[1A"
      fi

      for i in $(seq ${total_commits} -1 0); do
        print_status_item "${status[${i}]}"
      done
      echo
      status_printed="true"
      ;;
    list)
      if [ "${status_printed}" = "true" ]; then
        for i in $(seq 1 ${num_commits}); do
          echo -ne "\e[1A"
        done
      fi

      for i in $(seq ${total_commits} -1 0); do
        print_status_line "${status[${i}]}" "${commits[${i}]}"
      done
      status_printed="true"
      ;;
  esac
}

commits[0]="76ccd234269b Merge branch 'perf-urgent-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip"
commits[1]="3f3ee43a4623 Merge branch 'x86-urgent-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip"
commits[2]="c6ac7188c114 Merge tag 'dmaengine-fix-5.6' of git://git.infradead.org/users/vkoul/slave-dma"
commits[3]="018af9be3dd5 dmaengine: ti: k3-udma-glue: Fix an error handling path in 'k3_udma_glue_cfg_rx_flow()'"
commits[4]="01c4df39a2bb MAINTAINERS: Add maintainer for HiSilicon DMA engine driver"
commits[5]="988aad2f111c dmaengine: idxd: fix off by one on cdev dwq refcount"
commits[6]="564200ed8e71 tools headers uapi: Update linux/in.h copy"
commits[7]="db5d85ce8248 Merge tag 'perf-urgent-for-mingo-5.6-20200309' of git://git.kernel.org/pub/scm/linux/kernel/git/acme/linux into perf/urgent"
commits[8]="870b4333a62e x86/ioremap: Fix CONFIG_EFI=n build"
commits[9]="195967c088aa MAINTAINERS: rectify the INTEL IADX DRIVER entry"
commits[10]="f91da3bd2172 dmaengine: move .device_release missing log warning to debug level"
commits[11]="1efde2754275 perf probe: Do not depend on dwfl_module_addrsym()"
commits[12]="6b8d68f1ce92 perf probe: Fix to delete multiple probe event"
commits[13]="05e54e238673 perf parse-events: Fix reading of invalid memory in event parsing"
commits[14]="a7ffd416d804 perf python: Fix clang detection when using CC=clang-version"
commits[15]="db2c549407d4 perf map: Fix off by one in strncpy() size argument"
commits[16]="be40920fbf10 tools: Let O= makes handle a relative path with -C option"
commits[17]="cf7da891b624 docs: dmaengine: provider.rst: get rid of some warnings"
commits[18]="979e52ca0469 Merge branch 'linus' of git://git.kernel.org/pub/scm/linux/kernel/git/herbert/crypto-2.6"
status=(queued inert inert queued inert inert queued inert inert queued inert inert queued inert inert queued inert inert queued)
new_status

cat << EOF
Bisecting with:
OLD behavior: v5.6-rc7-2-g979e52ca0469
NEW behavior: v5.6-rc7-20-g76ccd234269b

Calculating...
EOF

sleep 2

cat << EOF
19 commits
Using 4-commits steps

EOF

sleep 2

echo "Now building:"

# initial status
print_status
sleep 3

# starting to build
status[9]="building"
print_status
sleep 0.5

status[6]="building"
status[0]="building"
print_status
sleep 0.5

status[3]="building"
status[12]="building"
status[15]="building"
print_status
sleep 0.5

status[18]="building"
print_status
sleep 0.5

sleep 4.5

# first results
status[0]="failed"
print_status
sleep 1

status[3]="failed"
status[15]="successful"
print_status
sleep 1

status[12]="failed"
print_status
sleep 1

status[6]="failed"
status[9]="failed"
print_status
sleep 1

status[18]="successful"
print_status
sleep 1

echo
echo "Now building:"

status[13]="queued"
status[14]="queued"
new_status

# initial status
print_status
sleep 3

status[13]="building"
status[14]="building"
print_status
sleep 2

status[13]="failed"
print_status
sleep 2

status[14]="failed"
print_status
sleep 2

echo
echo 'First NEW commit is a7ffd416d804 ("perf python: Fix clang detection when using CC=clang-version").'
echo "Reverting and verifying"
echo

commits=('e5e2b435609a Revert "perf python: Fix clang detection when using CC=clang-version"' "${commits[@]}")
status=("queued" "${status[@]}")
new_status

echo "Now building:"

# initial status
print_status
sleep 3

status[0]="building"
print_status
sleep 3

status[0]="successful"
print_status
sleep 1

echo
echo "Verified."
echo
echo 'First NEW commit is a7ffd416d804 ("perf python: Fix clang detection when using CC=clang-version")'
