## Auins Script update log

[**2022.08.22**]  v4.3.5 Update Notes New additions and improvements：

- Optimize `auin.sh`;
- New `install.conf` Part of the function;
-  Add Kernel selection  `Linux-zen`;
- Remove Script `Edit_Database.sh`;
- Update Script  `Process_manage.sh` `Useradd.sh` `Partition.sh`;
- When starting the script, first record computer information, such as: CPU architecture, LiveCD, environment, network, disk, etc.
- Functional test pass report：
  - - [x] **UEFI** and **BOIS** Installation test (no desktop)
  - - [x] Kernel test
  - - [x] Desktop test（Error：i3wm、openbox）
  - - [x] All external option functions
  - - [x] I/O Drive
  - - [x] Virtualization Extension Tool



- [**2021.11.16**]  v4.3 Update Notes New additions and improvements：

  - Script：Redesign some files and directories；
  - Script：Split "partitions" into external modules；
  - Script：add add script `Edit_Database`（Change/check information sheet），Configuration tables may be added in the future;
  - Kernel：Optional installation `Linux` or `Linux-lts`；
  - Partitions：Custom partitions and directories；
  - Partitions：Add file system：`ext2/3/4`、`btrfs`、`jfs`、`vfat`、`ntfs-3g`、`f2fs`、`reiserfs`;

  

- [**2021.07.2**]  v4.2.1 Update Notes New additions and improvements：
  - Added script record information query, record file：`./Temp_Data/auin.list`;
  - Tested on 2021.07.01 image, fixed some functional bugs;

- [**2021.03.20**]  v4.2 Update Notes New additions and improvements：
  - Turn off logging;
  - Optimize bash syntax;
  - `Temp_Data/auin.list` add system information;
  - Secondary menu (4) rearrange the order;
  - Add a desktop environment: `Openbox`;
  - Added beautification configuration: `openbox`，`rxvt-unicode`，`slim`;
  - Added `slim` desktop manager, only open to `Openbox`;

- [**2021.02.08**]  v4.1.1 Update Notes New additions and improvements;
  - System configuration (4->23) Solve the problem of not being able to boot successfully;
  - fix syntax errors;

- [**2020.12.23**]  v4.1.0 Update Notes New additions and improvements：
  - Unable to find config file when configuring `deepin`;
  - Disk type conversion must enter `y/n` and press any key: the default type is automatically converted；
  - System installation (4->2) can be executed after mounting the root partition;
  - Desktop installation (4->22) can be executed after setting up a common user;
  - The system configuration (4->23) can be executed after the system is installed;
  - ix syntax errors;

- [**2020.12.16**]  v4.0.5 Update Notes New additions and improvements：
  - Fix the issue of not being able to create users (thanks to @HelloDream for filing issues);
  - Solve the problem of automatic exit after entering the password twice；
  - Script option Enter "shell" or "s" to enter the temporary terminal, you can enter common commands (tested: cd cannot jump to the directory);
  - Added script process management module: “Module/Process_manage.sh”;
  - remove module: “Module/setting_xinitrc.sh” 整合至auin.sh;
  - Disable module: “Wifi_Connect.sh”;
  - ix syntax errors;

- [**2020.12.11**]  v4.0.4 Update Notes New additions and improvements：
  - Changed the homepage panel;
  - Rewrite the capture method network card and IP, more accurate;
  - `auin.sh -vm` According to the hardware information, install the virtualization toolkit [virtualbox/vmware];
  - Prompt to convert disk type before disk partition: gpt(Uefi) / dos(Bios);
  - Add a desktop environment：i3gaps、mate;
  - According to the hardware information, install the corresponding CPU drive;
  - update module `useradd.sh`

- [**2020.11.29**]  v4.0.2 Update Notes New additions and improvements：

  - New and improved partition table (gpt/boot);
  - Options 4:  (Install System Module) -> Installation VM-tools. 配置vm-tools
  - Option added： -vm Install Vmware Tools and exit. 
- [**2020.11.28**]  v4.0.1 Update Notes New additions and improvements：
  - Fix the problem that installing xfce cannot enter lightdm；
  - Reorganized grammar structure；
  - Update driver package；
- [**2020-11-21**] v4.0 Update Notes New additions and improvements：
  - Script log save log address: ```Temp_Data/Arch_install.log```；
  - Resolved an issue where `Nvme` SSDs could not be matched；
  - The way of options, the function of completing a single task；

```
      -m   configuration source
      -w   configuration wifi
      -s   start and configure the ssh service
      -L   view logs
      -h   help
      -v   version
```





