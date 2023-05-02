#!/bin/bash

# @输出磁盘表及UUID
function showDisk(){ echo; lsblk -o+UUID | grep -E "sd..|vd..|^nvme[0-9]n[0-9]p[1-9]$|^mmcblk[0-9]p[1-9]$"; }
# @检查磁盘名是否合法
function testDisk(){ echo "${1}" | cut -d"/" -f3 | grep -E "^[a-z]d[a-z]$|^vd[a-z]$|^nvme[0-9]n[0-9]$|^mmcblk[0-9]$" || echo "ERROR"; }
# @检查分区名是否合法
function testPartition(){ echo "${1}" | cut -d"/" -f3 | grep -E "^[a-z]d[a-z][1-9]$|^vd[a-z][1-9]$|^nvme[0-9]n[0-9]p[1-9]$|^mmcblk[0-9]p[1-9]$" || echo "ERROR"; }




sss mmcblk1
sss mmcblk0
sss mmcblk1p1
sss nvme0n1
sss nvme1n1p1
sss sda
sss sda1
sss vda
sss vda2

