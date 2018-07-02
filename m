Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id BBF036B027F
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 17:33:42 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id f8-v6so19113310qtb.23
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 14:33:42 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0126.outbound.protection.outlook.com. [104.47.38.126])
        by mx.google.com with ESMTPS id p1-v6si1741422qvn.128.2018.07.02.14.33.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 02 Jul 2018 14:33:41 -0700 (PDT)
From: <andy_purcell@keysight.com>
Subject: need help with slub.c duplicate filename '/kernel/slab/:t-0000048'
 problem
Date: Mon, 2 Jul 2018 21:33:39 +0000
Message-ID: <CY4PR17MB1160BFB32620C1DD5646A9839F430@CY4PR17MB1160.namprd17.prod.outlook.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hello,

I am using a Linux kernel =3D 4.14.13. Debug.=20

The problem:=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
If I attach a USB flash drive and then turn my device power on, then during=
 the boot, I see this: =20
             sysfs: cannot create duplicate filename '/kernel/slab/:t-00000=
48'

Result: the application does not boot successfully.=20
This happens about 50% of the time when booting with the USB flash drive at=
tached.=20
Flash drive is FAT32, 3.7 GBytes.=20

This happens with several different USB flash drives.=20

---------------- more complete output below --------------------
ubi0: attaching mtd13
usb 2-1: new high-speed USB device number 2 using xxx-ehci
ubi0: scanning is finished
usb-storage 2-1:1.0: USB Mass Storage device detected
ubi0: attached mtd13 (name "rootfs", size 104 MiB)
ubi0: PEB size: 131072 bytes (128 KiB), LEB size: 129024 bytes
ubi0: min./max. I/O unit sizes: 2048/2048, sub-page size 512
ubi0: VID header offset: 512 (aligned 512), data offset: 2048
ubi0: good PEBs: 836, bad PEBs: 0, corrupted PEBs: 0
ubi0: user volume: 3, internal volumes: 1, max. volumes count: 128
ubi0: max/mean erase counter: 1/0, WL threshold: 4096, image sequence numbe=
r: 1705465617
ubi0: available PEBs: 180, total reserved PEBs: 656, PEBs reserved for bad =
PEB handling: 40
ubi1: attaching mtd11
ubi0: background thread "ubi_bgt0d" started, PID 714
ubi1: scanning is finished
ubi1: attached mtd11 (name "system-storage", size 8 MiB)
ubi1: PEB size: 131072 bytes (128 KiB), LEB size: 129024 bytes
ubi1: min./max. I/O unit sizes: 2048/2048, sub-page size 512
ubi1: VID header offset: 512 (aligned 512), data offset: 2048
ubi1: good PEBs: 64, bad PEBs: 0, corrupted PEBs: 0
ubi1: user volume: 1, internal volumes: 1, max. volumes count: 128
ubi1: max/mean erase counter: 2/0, WL threshold: 4096, image sequence numbe=
r: 945702109
ubi1: available PEBs: 0, total reserved PEBs: 64, PEBs reserved for bad PEB=
 handling: 40
ubi2: attaching mtd12
------------[ cut here ]------------
WARNING: CPU: 0 PID: 1 at /var/lib/jenkins/workspace/Rocky.Scheduled.Build/=
bitbake/build/tmp/development/tlo/work-shared/xxx/development/kernel-source=
/fs/sysfs/dir.c:31 sysfs_warn_dup+0x54/0x74
sysfs: cannot create duplicate filename '/kernel/slab/:t-0000048'
Modules linked in:
CPU: 0 PID: 1 Comm: swapper Not tainted 4.14.13-andyp-development #1 Hardwa=
re name: xxx (Flattened Device Tree) [<c000f7c4>] (unwind_backtrace) from [=
<c000d758>] (show_stack+0x10/0x14) [<c000d758>] (show_stack) from [<c00174d=
8>] (__warn+0xd4/0xfc) [<c00174d8>] (__warn) from [<c0017538>] (warn_slowpa=
th_fmt+0x38/0x48) [<c0017538>] (warn_slowpath_fmt) from [<c012e5b8>] (sysfs=
_warn_dup+0x54/0x74) [<c012e5b8>] (sysfs_warn_dup) from [<c012e69c>] (sysfs=
_create_dir_ns+0x80/0x94) [<c012e69c>] (sysfs_create_dir_ns) from [<c04ea88=
c>] (kobject_add_internal+0x9c/0x2d8) [<c04ea88c>] (kobject_add_internal) f=
rom [<c04eace8>] (kobject_init_and_add+0x44/0x6c) [<c04eace8>] (kobject_ini=
t_and_add) from [<c00c1a6c>] (sysfs_slab_add+0x124/0x230) [<c00c1a6c>] (sys=
fs_slab_add) from [<c00c2bb8>] (__kmem_cache_create+0x108/0x33c) [<c00c2bb8=
>] (__kmem_cache_create) from [<c009d644>] (kmem_cache_create+0x114/0x22c) =
[<c009d644>] (kmem_cache_create) from [<c031ca3c>] (ubi_attach+0x94/0x1608)=
 [<c031ca3c>] (ubi_attach) from [<c031130c>] (ubi_attach_mtd_dev+0x3e4/0xb7=
4) [<c031130c>] (ubi_attach_mtd_dev) from [<c06732b8>] (ubi_init+0x164/0x21=
c) [<c06732b8>] (ubi_init) from [<c0009978>] (do_one_initcall+0x3c/0x174) [=
<c0009978>] (do_one_initcall) from [<c065dd60>] (kernel_init_freeable+0x108=
/0x1bc)
[<c065dd60>] (kernel_init_freeable) from [<c04fa710>] (kernel_init+0x8/0xf4=
) [<c04fa710>] (kernel_init) from [<c000a740>] (ret_from_fork+0x14/0x34) --=
-[ end trace ba5c8beef5034fec ]--- ------------[ cut here ]------------
WARNING: CPU: 0 PID: 1 at /var/lib/jenkins/workspace/Rocky.Scheduled.Build/=
bitbake/build/tmp/development/tlo/work-shared/xxx/development/kernel-source=
/lib/kobject.c:240 kobject_add_internal+0x230/0x2d8 kobject_add_internal fa=
iled for :t-0000048 with -EEXIST, don't try to register things with the sam=
e name in the same directory.
Modules linked in:
CPU: 0 PID: 1 Comm: swapper Tainted: G        W       4.14.13-andyp-develop=
ment #1
Hardware name: xxx (Flattened Device Tree) [<c000f7c4>] (unwind_backtrace) =
from [<c000d758>] (show_stack+0x10/0x14) [<c000d758>] (show_stack) from [<c=
00174d8>] (__warn+0xd4/0xfc) [<c00174d8>] (__warn) from [<c0017538>] (warn_=
slowpath_fmt+0x38/0x48) [<c0017538>] (warn_slowpath_fmt) from [<c04eaa20>] =
(kobject_add_internal+0x230/0x2d8)
[<c04eaa20>] (kobject_add_internal) from [<c04eace8>] (kobject_init_and_add=
+0x44/0x6c) [<c04eace8>] (kobject_init_and_add) from [<c00c1a6c>] (sysfs_sl=
ab_add+0x124/0x230) [<c00c1a6c>] (sysfs_slab_add) from [<c00c2bb8>] (__kmem=
_cache_create+0x108/0x33c) [<c00c2bb8>] (__kmem_cache_create) from [<c009d6=
44>] (kmem_cache_create+0x114/0x22c) [<c009d644>] (kmem_cache_create) from =
[<c031ca3c>] (ubi_attach+0x94/0x1608) [<c031ca3c>] (ubi_attach) from [<c031=
130c>] (ubi_attach_mtd_dev+0x3e4/0xb74) [<c031130c>] (ubi_attach_mtd_dev) f=
rom [<c06732b8>] (ubi_init+0x164/0x21c) [<c06732b8>] (ubi_init) from [<c000=
9978>] (do_one_initcall+0x3c/0x174) [<c0009978>] (do_one_initcall) from [<c=
065dd60>] (kernel_init_freeable+0x108/0x1bc)
[<c065dd60>] (kernel_init_freeable) from [<c04fa710>] (kernel_init+0x8/0xf4=
) [<c04fa710>] (kernel_init) from [<c000a740>] (ret_from_fork+0x14/0x34) --=
-[ end trace ba5c8beef5034fed ]---
kmem_cache_create(ubi_aeb_slab_cache) failed with error -17
CPU: 0 PID: 1 Comm: swapper Tainted: G        W       4.14.13-andyp-develop=
ment #1
 [<c000f7c4>] (unwind_backtrace) from [<c000d758>] (show_stack+0x10/0x14) [=
<c000d758>] (show_stack) from [<c009d588>] (kmem_cache_create+0x58/0x22c) [=
<c009d588>] (kmem_cache_create) from [<c031ca3c>] (ubi_attach+0x94/0x1608) =
[<c031ca3c>] (ubi_attach) from [<c031130c>] (ubi_attach_mtd_dev+0x3e4/0xb74=
) [<c031130c>] (ubi_attach_mtd_dev) from [<c06732b8>] (ubi_init+0x164/0x21c=
) [<c06732b8>] (ubi_init) from [<c0009978>] (do_one_initcall+0x3c/0x174) [<=
c0009978>] (do_one_initcall) from [<c065dd60>] (kernel_init_freeable+0x108/=
0x1bc)
[<c065dd60>] (kernel_init_freeable) from [<c04fa710>] (kernel_init+0x8/0xf4=
) [<c04fa710>] (kernel_init) from [<c000a740>] (ret_from_fork+0x14/0x34)
ubi2 error: ubi_attach_mtd_dev: failed to attach mtd12, error -12 UBI error=
: cannot attach mtd12 block ubiblock0_0: created from ubi0:0(rootfs)
ubi1: background thread "ubi_bgt1d" started, PID 718 bq32k 0-0068: setting =
system clock to 2018-07-02 09:32:41 UTC (1530523961)
uart-pl011 d0000000.serial: no DMA platform data scsi host0: usb-storage 2-=
1:1.0
VFS: Mounted root (squashfs filesystem) readonly on device 253:0.
devtmpfs: mounted


Additional observation:=20
1. if the ubi background thread starts before the next ubi volume attach ge=
ts started, then the duplicate filename problem does not happen.=20

  Example of PASS
  ubi0: background thread "ubi_bgt0d" started, PID 721                  ...=
.. background thread started before next ubi attaching message...=20
  ubi1: attaching mtd11

2. If the ubi background thread is delayed from starting until after the ne=
xt ubi volume attach is started, the duplicate filename problem does happen=
=20

  Example of FAIL:=20
  ubi0: available PEBs: 180, total reserved PEBs: 656, PEBs reserved for ba=
d PEB handling: 40
  ubi1: attaching mtd11
  ubi0: background thread "ubi_bgt0d" started, PID 714                     =
..... background thread started after next ubi attaching message...
  ...=20
  sysfs: cannot create duplicate filename '/kernel/slab/:t-0000048'


I am looking for suggestions on how to fix this.=20
Any suggestions are greatly appreciated.


Andy Purcell
