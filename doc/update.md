## Auins Script update log

- [**2021.11.16**]  v4.3 Update Notes New additions and improvements：
    1. Script：Redesign some files and directories；
    2. Script：Split "partitions" into external modules；
    3. Script：add add script `Edit_Database`（Change/check information sheet），Configuration tables may be added in the future;
    4. Kernel：Optional installation `Linux` or `Linux-lts`；
    5. Partitions：Custom partitions and directories；
    6. Partitions：Add file system：`ext2/3/4`、`btrfs`、`jfs`、`vfat`、`ntfs-3g`、`f2fs`、`reiserfs`;
- [**2021.07.2**]  v4.2.1 Update Notes New additions and improvements：
    1. Added script record information query, record file：`./Temp_Data/auin.list`;
    3. Tested on 2021.07.01 image, fixed some functional bugs;
- [**2021.03.20**]  v4.2 Update Notes New additions and improvements：
    1. Turn off logging;
    2. Optimize bash syntax;
    3. `Temp_Data/auin.list` add system information;
    4. Secondary menu (4) rearrange the order;
    5. Add a desktop environment: `Openbox`;
    6. Added beautification configuration: `openbox`，`rxvt-unicode`，`slim`;
    7. Added `slim` desktop manager, only open to `Openbox`;
- [**2021.02.08**]  v4.1.1 Update Notes New additions and improvements;
    1. System configuration (4->23) Solve the problem of not being able to boot successfully;
    2. fix syntax errors;
- [**2020.12.23**]  v4.1.0 Update Notes New additions and improvements：
    1. Unable to find config file when configuring `deepin`;
    2. Disk type conversion must enter `y/n` and press any key: the default type is automatically converted；
    3. System installation (4->2) can be executed after mounting the root partition;
    4. Desktop installation (4->22) can be executed after setting up a common user;
    5. The system configuration (4->23) can be executed after the system is installed;
    6. ix syntax errors;
- [**2020.12.16**]  v4.0.5 Update Notes New additions and improvements：
    1. Fix the issue of not being able to create users (thanks to @HelloDream for filing issues);
    2. Solve the problem of automatic exit after entering the password twice；
    3. Script option Enter "shell" or "s" to enter the temporary terminal, you can enter common commands (tested: cd cannot jump to the directory);
    4. Added script process management module: “Module/Process_manage.sh”;
    5. remove module: “Module/setting_xinitrc.sh” 整合至auin.sh;
    6. Disable module: “Wifi_Connect.sh”;
    7. ix syntax errors;
- [**2020.12.11**]  v4.0.4 Update Notes New additions and improvements：
    1. Changed the homepage panel;
    2. Rewrite the capture method network card and IP, more accurate;
    3. `auin.sh -vm` According to the hardware information, install the virtualization toolkit [virtualbox/vmware];
    4. Prompt to convert disk type before disk partition: gpt(Uefi) / dos(Bios);
    5. Add a desktop environment：i3gaps、mate;
    6. According to the hardware information, install the corresponding CPU drive;
    7. update module `useradd.sh`
- [**2020.11.29**]  v4.0.2 Update Notes New additions and improvements：
    1. New and improved partition table (gpt/boot);
    2. Options 4:  (Install System Module) -> Installation VM-tools. 配置vm-tools
    3. Option added： -vm Install Vmware Tools and exit. 
- [**2020.11.28**]  v4.0.1 Update Notes New additions and improvements：
    1. Fix the problem that installing xfce cannot enter lightdm；
    2. Reorganized grammar structure；
    3. Update driver package；
- [**2020-11-21**] v4.0 Update Notes New additions and improvements：
    1. Script log save log address: ```Temp_Data/Arch_install.log```；
    3. Resolved an issue where `Nvme` SSDs could not be matched；
    4. The way of options, the function of completing a single task；
```
      -m   configuration source
      -w   configuration wifi
      -s   start and configure the ssh service
      -L   view logs
      -h   help
      -v   version
```





