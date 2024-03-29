## Auins Script update log
-   [**2023.8.29**]  v4.7.6 Update Notes New additions and improvements：
      - Fix: i3 desktop installation issue, remove two packages: termite, picom
    - Add: Openbox desktop installation
    - Add: Plasma & Wayland desktop installation
    - Add: Sway & Wayland desktop installation
    - Add: Option to skip desktop manager installation

    
    
-   [**2023.5.12**]  v4.7 Update Notes New additions and improvements：
      - Modify: Configure the system to no longer automatically install fonts, and only prompt after installing the desktop environment;
      - Fix: Resolve not entering Root password and automatically skip? No issues found during code inspection
      - Fix: Resolve the issue of unsuccessful or automatic skip setting of swap size. Note: file systems other than ext[2-4] may not swap files properly;
      - Fix: Unable to recognize nvme name when selecting disk;
      - Fix: When running a script with non root privileges, it will not terminate;
      - Fix: Unable to configure time zone correctly;
      - New: pacman multithreaded download (axel), opening method: configuration file or script option;
      - New: Input method (ibus time), enable method: configuration file or script option;
      - Add: Script option logic, add set option, and classify the set options;
      - New: Independent font installation module;
      - New: Independent information output module;
      - Fix: Process_ Manage cannot shut down multiple processes;
      - Fix: Incomplete homepage information output;
      - Modify: The update prompt for the first month of archiso will only be displayed after the script ends the task;
      - New: Add BlackArch setup script;
      - New: The function of updating scripts at any time can be enabled in profile. conf;
      - Repair: USB wireless network card cannot be recognized properly;
      - Repair: Repair the table and improve the desktop module;
      - New: When there are multiple network cards, display the network card name and IP in order;
      - New: Reflector automatically updates the mirror station in the country where it is located, no longer using fixed
      - Fix: Fixed the issue of probability not displaying the configuration interface when configuring users;
      - Fix: Fix that after creating the swap file, it will not automatically mount;
      - Fix: New “Set user” and“Font installation” options on the home page, prevents the system from being unable to be configured next;
      - Fix: Refactoring part of the code;

    
    
-   [**2022.12.1**]  v4.5.3 Update Notes New additions and improvements：
      - Solve the problem that the script cannot be started for the system under BOIS boot;
      - Solve sudoer configuration problems;
      - Solve the problem that no information is recorded after setting users;
      - Reconstruct livecd version detection;
      - Turn off some Livecd functions such as version check in Normal;

    - New: JetBrains/Fira fonts;
    - New: function auin Sh - c Edit the configuration file profile.conf;
    - New: interface for automatic user configuration, edit profile User settings in conf to automatically configure users;
    - New: Home page guidance mode information;
    - New: CPU information on home page;
    - New: Clean up one click scripts and files generated by scripts;



- [**2022.11.25**]  v4.5.2 Update Notes New additions and improvements：

  - Optimization

    - Increase the scrips source to avoid that a single site cannot be accessed, leading to unavailability;
    - Add sources (arch, aur, blackarch, arch4edu), and use script conf to customize the increase and decrease;
    - Use profile.conf to customize the installation driver;
    - Check the archlinux iso version and remind to update it, which can be closed through profile.conf;
    - The ssh service is set to yes in the configuration file and will be executed again after chroot;
    - 4 - 0 (chroot) Not displayed when in chroot mode;
    - Dependency source of custom configuration script;
    - Fix the boot boot failure;
    - In the case of bios installation, close and select the mount boot directory;
    - Automatically identify the source in the configuration, and install the keyring in the last step of configuring the system;
    - Automatically identify the system environment, and use Livecd and Normal;
    - Create a new multi partition, set it to ON/OFF, and place it in the configuration ;
    - In a normal environment, identify whether the script is executed with root permission;
    - Customize the configuration file and install the driver on demand (audio Bluetooth I/O, etc;
    - Configure the ssh password in the livecd according to Conf;
    - On the premise of being in the livecd environment, part of the livecd functions will be automatically arch chroot if they are not in the chroot environment and executed;
    
    


[**2022.08.22**]  v4.3.5 Update Notes New additions and improvements：

- Optimize `auin.sh`;
- New `install.conf` Part of the function;
-  Add Kernel selection  `Linux-zen`;
- Remove Script `Edit_Database.sh`;
- Update Script  `Process_manage.sh` `Useradd.sh` `Partition.sh`;
- When starting the script, first record computer information, such as: CPU architecture, LiveCD, environment, network, disk, etc.
- Functional test pass report：
  - **UEFI** and **BOIS** Installation test (no desktop)
  - Kernel test
  - Desktop test（Error：i3wm、openbox）
  - All external option functions
  - I/O Drive
  - Virtualization Extension Tool



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





