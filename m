Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id AE0776B0253
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 14:40:06 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 63so134782838pfx.3
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 11:40:06 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id o20si5144679pfi.154.2016.07.11.11.40.04
        for <linux-mm@kvack.org>;
        Mon, 11 Jul 2016 11:40:05 -0700 (PDT)
Date: Tue, 12 Jul 2016 02:39:16 +0800
From: kernel test robot <fengguang.wu@intel.com>
Subject: [mm, kasan] 63495b0c58:  BUG radix_tree_node (Not tainted):
 Object padding overwritten
Message-ID: <5783e7d4.AYUWrKx4KI6M0vD8%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;
 boundary="=_5783e7d4.ghMddX2p1ia9FuZPpuYffA+eyPGef8x3apR7phtXvC9zRAcU"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: LKP <lkp@01.org>, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.orgLinux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, wfg@linux.intel.com

This is a multi-part message in MIME format.

--=_5783e7d4.ghMddX2p1ia9FuZPpuYffA+eyPGef8x3apR7phtXvC9zRAcU
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Greetings,

0day kernel testing robot got the below dmesg and the first bad commit is

https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master

commit 63495b0c58fff45bd94baf23a2f1138de7c20c3e
Author:     Alexander Potapenko <glider@google.com>
AuthorDate: Sat Jun 25 10:10:25 2016 +1000
Commit:     Stephen Rothwell <sfr@canb.auug.org.au>
CommitDate: Sat Jun 25 13:26:56 2016 +1000

    mm, kasan: switch SLUB to stackdepot, enable memory quarantine for SLUB
    
    For KASAN builds:
     - switch SLUB allocator to using stackdepot instead of storing the
       allocation/deallocation stacks in the objects;
     - change the freelist hook so that parts of the freelist can be put
       into the quarantine.
    
    Link: http://lkml.kernel.org/r/1466617421-58518-1-git-send-email-glider@google.com
    Signed-off-by: Alexander Potapenko <glider@google.com>
    Cc: Andrey Konovalov <adech.fo@gmail.com>
    Cc: Dmitry Vyukov <dvyukov@google.com>
    Cc: Steven Rostedt (Red Hat) <rostedt@goodmis.org>
    Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
    Cc: Konstantin Serebryany <kcc@google.com>
    Cc: Christoph Lameter <cl@linux.com>
    Cc: Pekka Enberg <penberg@kernel.org>
    Cc: David Rientjes <rientjes@google.com>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

+---------------------------------------------------------------+------------+------------+---------------+
|                                                               | 8b84dfd7fe | 63495b0c58 | next-20160711 |
+---------------------------------------------------------------+------------+------------+---------------+
| boot_successes                                                | 62         | 0          | 0             |
| boot_failures                                                 | 1          | 22         | 13            |
| Out_of_memory:Kill_process                                    | 1          |            |               |
| BUG_radix_tree_node(Not_tainted):Object_padding_overwritten   | 0          | 22         | 13            |
| INFO:#-#.First_byte#instead_of                                | 0          | 22         | 13            |
| INFO:Slab#objects=#used=#fp=0x(null)flags=                    | 0          | 22         | 13            |
| INFO:Object#@offset=#fp=                                      | 0          | 22         | 13            |
| BUG_inode_cache(Tainted:G_B):Object_padding_overwritten       | 0          | 22         | 13            |
| BUG_sighand_cache(Tainted:G_B):Object_padding_overwritten     | 0          | 22         | 13            |
| BUG_proc_inode_cache(Tainted:G_B):Object_padding_overwritten  | 0          | 22         | 13            |
| BUG_radix_tree_node(Tainted:G_B):Object_padding_overwritten   | 0          | 22         | 13            |
| BUG_shmem_inode_cache(Tainted:G_B):Object_padding_overwritten | 0          | 22         | 13            |
| INFO:Allocated_in_copy_process_age=#cpu=#pid=                 | 0          | 22         | 13            |
| INFO:Slab#objects=#used=#fp=#flags=                           | 0          | 22         | 13            |
| BUG_sock_inode_cache(Tainted:G_B):Object_padding_overwritten  | 0          | 22         | 13            |
| INFO:Object#@offset=#fp=0x(null)                              | 0          | 22         | 13            |
| BUG_kmalloc-#(Tainted:G_B):Object_padding_overwritten         | 0          | 22         | 13            |
| INFO:Allocated_in_acpi_ns_internalize_name_age=#cpu=#pid=     | 0          | 22         | 13            |
| INFO:Allocated_in_pcpu_mem_zalloc_age=#cpu=#pid=              | 0          | 22         | 13            |
| BUG_idr_layer_cache(Tainted:G_B):Object_padding_overwritten   | 0          | 22         | 13            |
| INFO:Allocated_in_ida_pre_get_age=#cpu=#pid=                  | 0          | 22         | 13            |
| backtrace:__radix_tree_insert                                 | 0          | 22         | 13            |
| backtrace:early_irq_init                                      | 0          | 22         | 13            |
| backtrace:vfs_kern_mount                                      | 0          | 22         | 13            |
| backtrace:mnt_init                                            | 0          | 22         | 13            |
| backtrace:vfs_caches_init                                     | 0          | 22         | 13            |
| backtrace:kern_mount_data                                     | 0          | 22         | 13            |
| backtrace:nsfs_init                                           | 0          | 22         | 13            |
| backtrace:_do_fork                                            | 0          | 22         | 13            |
| backtrace:apic_bsp_setup                                      | 0          | 22         | 13            |
| backtrace:APIC_init_uniprocessor                              | 0          | 22         | 13            |
| backtrace:up_late_init                                        | 0          | 22         | 13            |
| backtrace:kernel_init_freeable                                | 0          | 22         | 13            |
| backtrace:shmem_init                                          | 0          | 22         | 13            |
| backtrace:do_exit                                             | 0          | 22         | 13            |
| backtrace:do_mount                                            | 0          | 22         | 13            |
| backtrace:SyS_mount                                           | 0          | 22         | 13            |
| backtrace:devtmpfsd                                           | 0          | 22         | 13            |
| backtrace:debugfs_create_dir                                  | 0          | 22         | 13            |
| backtrace:regulator_init                                      | 0          | 22         | 13            |
| backtrace:debugfs_create_file                                 | 0          | 22         | 13            |
| backtrace:rdev_init_debugfs                                   | 0          | 22         | 13            |
| backtrace:__platform_driver_register                          | 0          | 22         | 13            |
| backtrace:regulator_dummy_init                                | 0          | 22         | 13            |
| backtrace:debugfs_create_u32                                  | 0          | 22         | 13            |
| backtrace:sock_init                                           | 0          | 22         | 13            |
| backtrace:__netlink_kernel_create                             | 0          | 22         | 13            |
| backtrace:rtnetlink_net_init                                  | 0          | 22         | 13            |
| backtrace:ops_init                                            | 0          | 22         | 13            |
| backtrace:register_pernet_subsys                              | 0          | 22         | 13            |
| backtrace:rtnetlink_init                                      | 0          | 22         | 13            |
| backtrace:netlink_proto_init                                  | 0          | 22         | 13            |
| backtrace:bdi_class_init                                      | 0          | 22         | 13            |
| backtrace:uevent_net_init                                     | 0          | 22         | 13            |
| backtrace:kobject_uevent_init                                 | 0          | 22         | 13            |
| backtrace:wakeup_sources_debugfs_init                         | 0          | 22         | 13            |
| backtrace:regmap_initcall                                     | 0          | 22         | 13            |
| backtrace:arch_kdebugfs_init                                  | 0          | 22         | 13            |
| backtrace:sysfs_create_file_ns                                | 0          | 22         | 2             |
| backtrace:param_sysfs_init                                    | 0          | 22         | 2             |
| INFO:Allocated_in__register_sysctl_paths_age=#cpu=#pid=       | 0          | 0          | 13            |
| INFO:Allocated_in_allocate_cgrp_cset_links_age=#cpu=#pid=     | 0          | 0          | 9             |
| INFO:Allocated_in_kthread_create_on_node_age=#cpu=#pid=       | 0          | 0          | 4             |
| backtrace:kmem_cache_create                                   | 0          | 0          | 11            |
| backtrace:uid_cache_init                                      | 0          | 0          | 11            |
| INFO:Allocated_in_alloc_workqueue_attrs_age=#cpu=#pid=        | 0          | 0          | 2             |
| INFO:Allocated_in_apply_wqattrs_prepare_age=#cpu=#pid=        | 0          | 0          | 2             |
| BUG_pid(Tainted:G_B):Object_padding_overwritten               | 0          | 0          | 2             |
| INFO:Allocated_in_alloc_pid_age=#cpu=#pid=                    | 0          | 0          | 2             |
| BUG_signal_cache(Tainted:G_B):Object_padding_overwritten      | 0          | 0          | 2             |
| BUG_task_struct(Tainted:G_B):Object_padding_overwritten       | 0          | 0          | 2             |
| BUG_cred_jar(Tainted:G_B):Object_padding_overwritten          | 0          | 0          | 2             |
| INFO:Allocated_in_prepare_creds_age=#cpu=#pid=                | 0          | 0          | 2             |
| BUG_names_cache(Tainted:G_B):Object_padding_overwritten       | 0          | 0          | 2             |
| INFO:Allocated_in_getname_flags_age=#cpu=#pid=                | 0          | 0          | 2             |
| INFO:Allocated_in_copy_mount_options_age=#cpu=#pid=           | 0          | 0          | 2             |
| INFO:Allocated_in_strndup_user_age=#cpu=#pid=                 | 0          | 0          | 2             |
| backtrace:native_calibrate_cpu                                | 0          | 0          | 2             |
| backtrace:tsc_init                                            | 0          | 0          | 2             |
| backtrace:x86_late_time_init                                  | 0          | 0          | 2             |
+---------------------------------------------------------------+------------+------------+---------------+

[    0.000000] Running RCU self tests
[    0.000000] NR_IRQS:4352 nr_irqs:256 16
[    0.000000] =============================================================================
[    0.000000] BUG radix_tree_node (Not tainted): Object padding overwritten
[    0.000000] -----------------------------------------------------------------------------
[    0.000000] 
[    0.000000] Disabling lock debugging due to kernel taint
[    0.000000] INFO: 0xffff88000c800210-0xffff88000c800210. First byte 0x58 instead of 0x5a
[    0.000000] INFO: Slab 0xffffea0000320000 objects=14 used=14 fp=0x          (null) flags=0x4080
[    0.000000] INFO: Object 0xffff88000c800008 @offset=8 fp=0xffff88000c800238
[    0.000000] 
[    0.000000] Redzone ffff88000c800000: bb bb bb bb bb bb bb bb                          ........
[    0.000000] Object ffff88000c800008: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    0.000000] Object ffff88000c800018: 00 00 00 00 00 00 00 00 20 00 80 0c 00 88 ff ff  ........ .......
[    0.000000] Object ffff88000c800028: 20 00 80 0c 00 88 ff ff 00 00 00 00 00 00 00 00   ...............
[    0.000000] Object ffff88000c800038: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    0.000000] Object ffff88000c800048: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    0.000000] Object ffff88000c800058: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    0.000000] Object ffff88000c800068: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    0.000000] Object ffff88000c800078: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    0.000000] Object ffff88000c800088: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    0.000000] Object ffff88000c800098: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    0.000000] Object ffff88000c8000a8: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    0.000000] Object ffff88000c8000b8: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[    0.000000] Redzone ffff88000c8000c8: bb bb bb bb bb bb bb bb                          ........
[    0.000000] Padding ffff88000c800208: 5a 5a 5a 5a 5a 5a 5a 5a 58 5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZXZZZZZZZ
[    0.000000] Padding ffff88000c800218: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[    0.000000] Padding ffff88000c800228: 5a 5a 5a 5a 5a 5a 5a 5a                          ZZZZZZZZ

git bisect start dd27435af10bb67660f1e9f5689aea1854c20f26 a99cde438de0c4c0cecc1d1af1a55a75b10bfdef --
git bisect good 8fe2e22827c7050f1361354858596a2b94448dcd  # 23:30     22+      0  Merge remote-tracking branch 'slave-dma/next'
git bisect good 9605f7cece91a057a6c7a3f17d3fc26d91c54bf6  # 23:44     22+      0  Merge remote-tracking branch 'spi/for-next'
git bisect good ccd7d3c2c3a8f538e7babeb1cf955730f5cde118  # 23:52     22+      1  Merge remote-tracking branch 'extcon/extcon-next'
git bisect good 938e32d7f884c5baa75d68b2063fd48315a09ccd  # 23:57     22+      1  Merge remote-tracking branch 'userns/for-next'
git bisect good d4656ac2985214dcfad8acc5c841a884a088a2d1  # 00:12     22+      1  Merge remote-tracking branch 'livepatching/for-next'
git bisect good a47bd84d8c1d6498ae3a4c6e74efa26c517e4f85  # 00:33     22+      0  Merge remote-tracking branch 'nvdimm/libnvdimm-for-next'
git bisect  bad 2ffbdc1098912039558a87f665688b45ba220274  # 00:36      0-     22  Merge branch 'akpm-current/current'
git bisect good a137d2de1575885e2b41acd813ca50ad9fd7c1f4  # 00:42     21+      3  thp, mlock: do not mlock PTE-mapped file huge pages
git bisect  bad 73c4a26170c610887770a58163a960d03f199d90  # 00:45      0-      5  lib/iommu-helper: skip to next segment
git bisect good 8611b108d9f74d5c76f2be4f3842498511fe9f32  # 00:50     22+      2  proc, oom: drop bogus sighand lock
git bisect  bad bb3877b284bbec55e0db68be669e8a1c380813de  # 00:54      0-     22  proc_oom_score: remove tasklist_lock and pid_alive()
git bisect good e27d880ea5fa9c569a4945f1e4fc77ec8050e44e  # 00:58     22+      2  mm, oom_reaper: do not attempt to reap a task more than twice
git bisect good d8a354ccd10174801dcf686aaba5bb28d164199e  # 01:04     21+      0  ksm: set anon_vma of first rmap_item of ksm page to page's anon_vma other than vma's anon_vma
git bisect good 8b84dfd7feb26100eb92f3ae227fcf7ee4b14b76  # 01:08     20+      0  mm/compaction: remove unnecessary order check in try_to_compact_pages()
git bisect  bad 63495b0c58fff45bd94baf23a2f1138de7c20c3e  # 01:12      0-     22  mm, kasan: switch SLUB to stackdepot, enable memory quarantine for SLUB
# first bad commit: [63495b0c58fff45bd94baf23a2f1138de7c20c3e] mm, kasan: switch SLUB to stackdepot, enable memory quarantine for SLUB
git bisect good 8b84dfd7feb26100eb92f3ae227fcf7ee4b14b76  # 01:15     63+      1  mm/compaction: remove unnecessary order check in try_to_compact_pages()
# extra tests with CONFIG_DEBUG_INFO_REDUCED
git bisect  bad 63495b0c58fff45bd94baf23a2f1138de7c20c3e  # 01:19      0-     24  mm, kasan: switch SLUB to stackdepot, enable memory quarantine for SLUB
# extra tests on HEAD of linux-next/master
git bisect  bad dd27435af10bb67660f1e9f5689aea1854c20f26  # 01:19      0-     13  Add linux-next specific files for 20160711
# extra tests on tree/branch linux-next/master
git bisect  bad dd27435af10bb67660f1e9f5689aea1854c20f26  # 01:53      0-     13  Add linux-next specific files for 20160711
# extra tests with first bad commit reverted
git bisect good 0ccaf34cb358153063a9e1727dfccd6ad2521c7e  # 02:03     64+      7  Revert "mm, kasan: switch SLUB to stackdepot, enable memory quarantine for SLUB"
# extra tests on tree/branch linus/master
git bisect good 92d21ac74a9e3c09b0b01c764e530657e4c85c49  # 02:08     61+     15  Linux 4.7-rc7
# extra tests on tree/branch linux-next/master
git bisect  bad dd27435af10bb67660f1e9f5689aea1854c20f26  # 02:38      0-     13  Add linux-next specific files for 20160711


This script may reproduce the error.

----------------------------------------------------------------------------
#!/bin/bash

kernel=$1

kvm=(
	qemu-system-x86_64
	-enable-kvm
	-cpu Haswell,+smep,+smap
	-kernel $kernel
	-m 256
	-smp 1
	-device e1000,netdev=net0
	-netdev user,id=net0
	-boot order=nc
	-no-reboot
	-watchdog i6300esb
	-rtc base=localtime
	-serial stdio
	-display none
	-monitor null 
)

append=(
	hung_task_panic=1
	earlyprintk=ttyS0,115200
	systemd.log_level=err
	debug
	apic=debug
	sysrq_always_enabled
	rcupdate.rcu_cpu_stall_timeout=100
	panic=-1
	softlockup_panic=1
	nmi_watchdog=panic
	oops=panic
	load_ramdisk=2
	prompt_ramdisk=0
	console=ttyS0,115200
	console=tty0
	vga=normal
	root=/dev/ram0
	rw
	drbd.minor_count=8
)

"${kvm[@]}" --append "${append[*]}"
----------------------------------------------------------------------------

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/lkp                          Intel Corporation

--=_5783e7d4.ghMddX2p1ia9FuZPpuYffA+eyPGef8x3apR7phtXvC9zRAcU
Content-Type: application/gzip
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="dmesg-yocto-vp-83:20160712011123:x86_64-randconfig-s5-07112049:4.7.0-rc4-00278-g63495b0:2.gz"

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
89Dt2xZuPgCSE7tr3NcRAA==

--=_5783e7d4.ghMddX2p1ia9FuZPpuYffA+eyPGef8x3apR7phtXvC9zRAcU
Content-Type: application/gzip
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="dmesg-quantal-kbuild-12:20160712011329:x86_64-randconfig-s5-07112049:4.7.0-rc4-00277-g8b84dfd:1.gz"

H4sICLfng1cAA2RtZXNnLXF1YW50YWwta2J1aWxkLTEyOjIwMTYwNzEyMDExMzI5Ong4Nl82
NC1yYW5kY29uZmlnLXM1LTA3MTEyMDQ5OjQuNy4wLXJjNC0wMDI3Ny1nOGI4NGRmZDoxAOxd
a3PiSLL97l+RN+bDuvcarNJbRDBxbYy7uX6ucc/M3Y4OQqAS1lhIrB5+TPSPv1klCQN68DBq
70YgRzcgZZ46lVXKzCoVBTUD9xVGvhf6LgXHg5BG8RRPWPTgNvCHjjeG7tkZHFLLavu2DZEP
lhOaQ5d+ajab4D8e0GUI+hIF5igaPNLAo+6B403jaGCZkdkC4UXIDmk0HIqaml52qbdwVTCo
OtSEAz+O8PLCJZK8pJdymmSoEonqB0npg8iPTHcQOn/RxdLVIWUgB2d05E+mAQ1DVtVLx4tf
WL1uzYCf6F6es4+W79HmwanvR+xk9EAhgW8efAM8hGaC+j0BgCeK2r4HclNrCo1gJDcEQdS0
xlgf6rJlW3D4OIwd1/of93Ha8Kggf4LD8Wg001ObpElAFIgqyJIAh2d06Jjp6Qb5BJ/gFwL3
MYX/jV0gIgikJagtmUCnf8/Vlml1/MnE9CxwHQ/t8BB740Fkho+Dqek5ozYB3obTwPGix3YU
vfaFI0IUURAgfA0jOrGarj9GSz9Rt02DACw6jMdgTlE3eYtiwb8GpvtsvoYD6rHuYUEwiqfY
7LSJbwajaTwIsSmwRZwJxbZrYztCUn6DQOjbkeuPHuPpjJM3cQbPZjR6sPxxm58E35+G6VvX
N61BYE6wMz62RZgG2IrR7ISQ9cfF2sydFOBpbLY9P5iYLkCALds+tujTMSIIEDwzSz22j5Nm
akQ0jMLjIPYa/4ppTI8fnybHL7o6UOVGgGZFWNsZN0KlIWiEiIJsHLusH2DTvkStiYkmDFpp
02s2HYoq1p0ODdGWTCqKmj2yNUrlIZGHmtoaOiEdRY0EQTluPk3Y278a6wI0eL/RkAdykaSG
2EhqAUPkOnpov1E7TqjB6c3N/aB3dfK52z6ePo4T8isqiN21oR6vy+k4q0TpHWEFQ6s5cbBB
BiM/9qK2vtyHkc+xPY1bcEnH5ugVP2twfvsVO2OE9qJW7l6cKXzlt/LfqDmmwd+4DlYoQgNA
+OxgB6NhTpfqotCC095Nv4Fd68mxsD9PH15DZ4Td5e7kCibmtLWsxMUTzW8TOlnwZ8nRWDhl
2EPb/g4xd6cbgRn2KA9mMzD0ZDR4otZGcHaem709HFmuKhGHVgK3aVVRk+bBtuZmU5sZbh6O
ndoaLkFbgLNXwQ3R1WTB8hv3uyjHelziNZfFr/+Aw+4LHcURhbM08DJvx/o8hooWYKR1nnIm
/fI6xdKd0A9m90cLLn67Ku7niZ9erl5WrbmWg3b719KaJVgBnfhP81jmG5Zd1QsSdRdd0mBq
e9BGbd78eKu9DMxg9DA7LWcMlyGu7u/usL62GbsRRGiCFjwHTkQbQ3P0WChsOy8sUpnemIZZ
E+Tua3zP62Cc41GBCHDC5U65XOyNzNFDUU0BOlzufA4vbdJCkk9m4HDrr+YJQzOkSFdPLYTG
Cx/h/Hz2uYoVyVK7XNMCiBXXpIprcsU1peKaWnFNK73GXP7tyX0LEx4WseLAZDcJfBMa2vcW
/H4K8Ps9wNdOA/9B7nPuzme2xH7sB6+AKe1k6rP8CcwIvrGOrCdGNQwuzF+AJZogyoqWS8FO
7y6Qx4sgqybTO4L0Pb8jbj/fn5xedit0jDkdY00dc07HXFNnOKczrNLBIHjW61/MnCJLsazk
Tp/5+2Wdk85trwVdPmCIeI/G4Dt6DOMJS30dG6Mrb6+y5k307/pnt4vx61yVugK/SYkMh0/Y
Dqc3nS99+FQKcL8QZE67RJM0DiBxAJICwOkft51EPJXlZ2afSgo4x5elAoQOUmMftHwBifgm
BZzlayAIMjfB6Vm+gLNtatDPFSAkNpZzfjfR6ReQ6ug60zHOtRyp/sakTm57neV2U7VzrqYL
uQIS8U0K+HLbzXUM9TwpQNJzBSTimxRw6bP8kRMzLYuNOrE4m/IcJ2dVTDGnGJy4NA677dmh
2OxGg0NIjwwgVyiOUxojNqzKcuBJGIQgDxVVtpAxGxGmH3KFz6ni0A3QJ6AuCC12m2PSQ44w
CXEmJnpGdplLVkDEvPQQ73YLfNsOaYQvQCRd1mRNVQwNRq8jl4bLEFw99ONghKF8Do9FNTae
t5cOniskUOwyGVmySHF8YQ+P+CXHcunAw2u6ThRDUAwi6xJ4uXL/ieP9NNoWRNmzqxNJZCcL
snyW/BalvnmU63TsCRRHrq8FpdAnZ0TLrl/5T9yB/sWY4sA6iMDGZI9icAePzd4sySdONw1m
TCCtXr5cfhFPFQ5ilqonsIma4upVwJQPEJZhep4TMe1kVopDCu+x+o2XgfB5oanJGhg0VdVy
N0DWzMzALSAin61g2VccYidmtkYaeItW64kk1SpLmhfFOZNE4wgue+c3mM/hALVFlNzNZYYm
Zv8XfBrqJPElfRPNhQlIAA57Y7r4viSG3l417p0JSvZu4NYP+AybKuTG3B/itZJCr+8Gnduv
/eOpH4YO9nQ2gxSC60ycxHegRU3mT5oAt4E/QlLYJOQYb3pwxp4fFEwIpLVh1AbXVz04NEdT
B33CN+ZIvoNlu/wfJnkRniLfc8x6N0z3m4C5JJv8QlXmGLNZO6IdLdiHjw3x+ud+D4SGKBXT
6V3fD/p3ncHNb3dwOMQqYg4fhwMn+Be+G7v+0HT5BzHjl2flYfOx0Q4jgzkqe4kCZ8xeOSC+
9u7+wV95s/TOYPb2GiOYuDEzZZ6ZAg/O+AH49OBqciQlJy2RU0rI5Xr+SnLGPDljJ+SMEnLG
xuTIQqPip13QM0vomZvTIwv0yE7oDUvoDUvo3f1DSLzs8BV8vLsCx6K5m3ntXk9KSidbI0ol
iLk7fG1EuQRRLrWQskMLqSWl58awayNqJYja1oh6CWJJyEIdY7WFZrJkjQ73Jkx2aPtRSb1G
WyNaJYi5TGBtRFqCmEsy10a0SxDtZcRk2MJMD4dXJ2f3n3jm1b+6hdHCDI/j2SydZu8rhnaO
xfIcXdBVU8TxD5sr46MIanHZklQmifrLyQyL7nCYRfmcc7z47SrNWs3w1RvB7TlnzsdSRQOl
MKKmyx6NLYy3RBwdET2nsDAbTcSEQoNVxLaTSRvzyXRcPkBgpd52emDx4UQu38+eaU7NwHxy
gihOssb0+SagaQtmjReGZQG1HY9ajT8d23ZYOr08OFsalGWnl0ZkqqQJsiJqmi7JkqEWjcqm
aJmG6WLhLQgFCASwJFFTdYiTF36pTf7OP1UpYwaHMS9nithxI0wsWSruOmEUsofZfCToBxYN
kK8/dFwneoVx4MdTZjXfw/Tzng0lIBtLKLKcywqSLB277P4p7P4p7H/2U9hbdNkPZviQzt9S
D/076/dIR4dDfqPghyMgqqTLGCKx0XK+8YxpvQJ7EEELwVRFkdQZGiYTiiiLul4C12ND+kY5
WuIcMjRMdkRVJHIZuSs+RYIjfk00FPXiWBJUVRcu5jzqIRFFVb7IXCRbK3MEskK0C+yybJ0L
8jUkET/5ySdD1S/4kByLNgwGNgxxfE8kSRMRJ5saOAK8MpqYjexEjlv/8usphrLf0UePvbaK
WeMNq1RbaGBKeuV4N8M/sdOGbYweOHYO25j6XiM7fJObvY89jzmwu85XDFOuDfzmyj18vBtg
uO63ZEkRwQvYmCBsiYoK+RUm+4Uve5e7d7n7hS/7hS/7hS/7hS/7hS/7hS/7hS8p2H7hy37h
i7Bf+LJf+LJf+LJf+AL7hS/7hS/7hS/s2C982S982S982S982S982S982S982S98WUDcL3zZ
L3zZL3zZP4XdP4X9N3kKu1/4sl/4UrTwZfZIk9/qpY8z1xS7RCeE/m1KPYt6o1d4whqjLf2A
PdmZvmJK8RDB4egTdjtBhTt0c19MtG7PGzXZ/2MfrnzXM4Ofhcs2x7k6+WNwedO5OOveDvpf
TzuXJ/1+t98CyN1D20sPUPz+Swtmh7xLccblovt//ZmCToxcz9lKgVfvy0n/y6Df+2d3npBg
5LrSVgrzlLrX93e9bsqqMBl4v0bny0nvOqs491e70eBSRRUvZbWZRjYFnI1g3KU7giXSLWCz
4/B4ulvlKQY5lu9grhvEoygDszHq86QHfa4hColb3qlyo+TYVu4H9yN8YILjEu45YyeiuScF
68qVlbvN8TOxVx4/IMQ0GX48847yI0heJnFEX/Dac4jjlx8Q8Jefi12nTerELjhOGid4C5oW
fzC2uQaA/8iMucuXg5U0Thqn+LcJ8ZzGzyeeUOjg37rECzU+hjhSYP9vQDyn8XOJv9nuDP/W
sXipxs8nziicbkS8UOOjiHc2Jt75SOJzh+XHbIgWe2u7w0WNDyL+9rwWHqhbtLJvlcbHEB+a
Vmq5ZI5sNfGcxk8iXmdUrhN7/gjoKA5C54myZ99WY40uXqSxIPBj+dOiNdeVrOopBRzgF7GK
eInGzyYOk2RxMOOQLNJdafFijQ8injBYr6sUa/wk4nXeP3Vi4/FgBlaDTYs1fA/+G/BdIzRt
2jg5JiVdvFLjvb6ZTeBvRqdS4710yusqkk2tgxr1WaeMTqXG+wNp+AYI7V/hIS2ptLEqNeqj
U2adSo1dpBm8N6Tw3PorrFOhsQs6vDdsRKdUoz7rlDdWhUZ91qmiU6rxTjqL1Yw9/vYUfiFo
eamQTrXGO+ksVnMdOtUa9VlHKu7K1Rr1WaeETrVGbdYRyaZ9h2nUZp0yOtUa9VlHKr7RqzXq
s04JnWqN2qwjlQSJao3arFNGp1qjPuuUBIlqjfqsU0KnWqMm64gbxyyxzphVTqdaoz7rbBiz
xDpjVjmdao3arLNpzBLrjFnldKo16rPOhjFLrDNmldOp1qjNOpvGLLHOmFVOp1qjPutsGLPE
OmNWOZ1qjXfSeZuu4StBGo6XfhWqNEhUa7ybTjZdsz6dKo36rFMSJKo16rNOKZ0qjdqsUxYk
qjVqs045nSqN+qxTEiSqNeqzTimdKo3arFMWJKo1arNOOZ0qjfqsUzoZV6VRn3VK6VRp7M46
/DlX+qxxvZhVoLGZBdYuskrjfbVcHXsKNN5Xy9XxZdsiyzivEUMKNN5VyzXixLZFlnJeHQsK
NN5Xy9X+ftsiyziv4dMLNN5VyzX89rZFlnJe7ZsLNN5Xy9X+d5si63ziXif2D/jdjz3r+Nl0
omSxdtHK4fWk3lOdqmUayfH8zL71B7bpuHFQuEPNKo13B9F55HQzzZAtInG88So6BRrbE7Ad
zwkf2BL7N9hqAoUa69tjM+u46fr/iRNOTL7T6CrrFGjsjg5A96x7cnZ5gU7Fs9w1GqtAY1tb
1fFSVWH29QC+dMzDuzRdc1i4aeIqjXo8Xm0wK44fw+SbEsC+ggk/0jtgi+9frIvzn2GdtXxH
ocYub8+FAw27AZ1MoyY6w/W/X7KgUQed7D5dn85M4x10tuqAO/tC1jLMZ9+3jtiOByAqEk9E
RmZIQ5iaYUit/8onJRsr7L5mywo3Z93Tr59b/AvIjFDKZUuxhU0pHqY02nYnCmIQIqqCLKta
wSYUP6kYhpyURZ+oF2EmPnbYNgH5eq8vGYWjFpyl20GDqBpSUxF0uPryF9u5IdlCbXsd0jQE
nWjid+iYrjNkG7NgHmNR12RfFPWncBg+OmxDFbZ/NWVbQD6ZbkybTXivviLpRlPW4NQf+1e9
2z4cutM/27qh6ZIqfDpYcTkrnAi6rH2HqWMNsJ1a2T7SLf6VY8zHPGcST1ogZRtHbakiyrqa
bUrT8QO2xv3J4fvHJb/3IIrbycqKKH2HPhursS1KzgNzQp/94DG/F+Dm0oqhKGzLydiLKvZZ
IIIoz7ZZIEfsy+DiwiYLO4bSDENOoaa+82+HJ0qajp15wvxE5/YrhPF06gc46CECXHW6MDS9
x3BbaQV9x3e4NNEb8g1hwLm/PH3jJ1+csi2ExCv+IrOXnehKBK20oGut0j0C8nnXEKrIei+a
qQWFJ3uYmbnp/+ynT5JdjN4cVtE5OLTNieO+co/N9vpBz8N3xSy9cAToZqdTPiYSXsing9yJ
jJuMrgZNfksDvkuVN6LQZb46nONfIRN7aW9AD3xNo2EcoO1YJ+FcQF0t4Plwe/UVrMB5YhsZ
sfmdZxP9CY8YIfie+9o8WEsoo6soAutF2S5D3ZeIbeCFRsVifxE2FjN0du91r09OL3vXn6F3
00g2Bbv7R7iZkIqeFx0Mc2MoMNhGgO39gbkk21gJBGBfMhfQgBFL+D0eBrcSlURW7NwOon2M
YIEf8yiXbIhzKDQINH7FviPxV7ZVGkGHZNGWACf8dx7wzRmmQK25zlUjsqIRbTWymCILGbLw
gci6JAn6amQpRZYyZOkjkTVRXANZTpHlDFn+SGRDE6TVyEqKrGTISoJMPgLZEAVJXY2spshq
hqyutEaNyBohZDWyliJrGbL2kcgGev3VyHqKrGfI+kchizjcIZq+RgsaKbKRIRvVva5eZNlY
B5kIKbQ5c/3Cx2JrkraG9ydZyBrOsMnHYhuauo5NsrA1mmGLq/tfjdhEFIV1MoQsdFkz7BWx
q2ZsUSbGGpGAZOGLzrBXxK+6sVVVXqcPZiHMnmErH4utGwZZTGeJWpTPbigrCURYltV2IUtE
WViS1Xchi6LKkqyxC1lF0rVFWbFwvLCprKpq0pIs2YWsphNjSVbchSz2naVhkyjtQFbGP8I2
xbvvXXXvWvCEl/2gzQcQTJ+0OQBpi/yjyLa8xc/sdbcYEp/iSPaudt9+PCPiv7jheBENgnga
Zb86+aYxmpv4nNNoNnOSdWCLAtFZ7GSbCrrc3hZ1IxPaYEiapGbbwW8kiLeHkgjOfnEkk1Uk
VVe2EhWJIsvfk1rMquV7Wa8I2fS3F8GzEz3MsFrouI0J29KZ7bRt8Z8QEYRJWDOoqrNKcdCk
Mqb1ZxyyeZrIn4NRRdkwZAkOUwN+2iGCpChsYum+Xw3ApvYVomKefygLEg4OBJHsGAQ9pWLw
JsZGTmBS2huJaIqmZiITPt3OjISjc0neUMgQFCETmm/zgIZcRWJH9vMo2yigE39TYBNy/DkN
hFOKlnPC5HmKqBL+QKX5bjVNlORM7cEPI77p/pIu+6kkFmbF3emyrZ5Rdzq2mHtxIgF74adk
k9BxQE3+zC6MzGSv0OgBm8LQxHQ3Z3CpHdWApCnoMb6zXe+jydQOW/kHG2sLGbqoJj8tOZm0
0v2hk6fb/Oce2Y9D6Ven28pLOtFFY+m54g720tdVTSGGQgjePLPniz+/OEMVFWxRM/InzkiV
B6wJW+kTXP7bBGinhirD1DUjNvGdONjOHzr/dTr+od/v1gQnY4dm2cV19//Zu9bntnEk/33/
CtR8ib0nOXgRBLXnq3PsJOOa2PFGyexspVIqiiJtbiRSIaU4nr/+usGnKMnWg/LUTF1mEltU
9w9AAwQaQD8+9siH8t7U5NeNvXhMspP/Mtz1ThygGSnQKLzpHAVW5MK7xdQhEVR47I5GfrIj
tcT47eupJ340341WwLtR3DziRGCSemAaiebt8tbEsI7A8INvi5yEi4k8DC8zXWlS2boeXs+0
xK6Ew5D95/mtj5dOVf0ITGmvTA4H845idkM/yxbh4iKX52RrHUdaGq9Hbqdh3A1spvWPHrkG
hcMlb1CV+5pn7cCUs0V2O+63xG1xqq3tuGVb3LCJZbJM6znC7OqD9/3LI9ihzsd+nvrweFdy
27I0XUFe5YlrgcOWqBAtcYgTSgb98xu86vIjvKtP92VypGU/WrezW1gcbzGM/XI192AGFcpR
pVRWP+VZbp6zq3fZFXlK0rl55YL5GKZB1/s2D/G1MGlPYhfK/9sOLEXR0BwGk++6zxo2OngH
nGdqwr0QvH6YW2MhzcA2hJyCTlIQHpWX8n1K+oL0reMdCDlzdEGYTWF5giGctMoNXHGksz+f
JZi1MGNm2l0SjmCSug+jUXyfkiCJJwb7HyQMCOyroT/c5KGDuhf5aeqFp1HsJelPplcSHxsH
r/pw/szliBMmlbJLoxhcZD7EMO28yor5DA9gbB6N4omLl7Hwh3zOMk91g6BI6NgaiqXhhQZt
xJuG5Ob6hp5R0aO0h6/YeY+871dWHJ/7/u0Er9G/tMOMWaH4GmZj5g8v0NHZ68H1+4+DN+8/
XV8c/yPPqm32//2bq4NAKc2lGQMLnQ9bxEx6AFtk2dqaWjPL4pjGKRzUvu6ZpEGGAfZgRp0l
n8OY5IsO5oT1Ajsffl8OBGZR3LNuATbKsnWhgn1YME3xkHsTsDKnrls0ldLh84E6TNINm70i
69kweEZQVHY2A62mjHa4ORPUsQ13yYkb8h75jDnteowL+DbLv0dhh+eaRLRUIW2rGJzZ+SCt
MFiFYWeWo8sYrG0M0ETkEgarMNgqDEbLlHotYSiuURlexgDNCqhNsr7sbfW4GV3wo9ate7Lb
jm2LVexj0Ou8B3J58ZqgTvW1AGQVIGWBeS9ZYB8QUAvNtwOUFaAI1EGQNHPoVki61kg7a6Rt
Hw5Q4ElD8019HNCrtdVWB0HSjuRLSKJ8WxgTq95aXZs9WsFgIO7l2QMw8mYUlVfZsqNEgEde
bjjJEhfdXF7+Jo32d0BEeFf18oBYRrQzRJuuQuwXJ4UHAdSWbvYEN3MwLAOyx4yB0FJPiPpa
0AqGtCUeqi1j1KaXbIUOskytZoUe5WeUsHWrZsNWsZTFdfO9qWPpCgvUhZrmQIOgdRjJucSj
wXUwgtZh/ArGX25Zq1iC27TZPFHTKCj1V4wAXh8BrWBIbanmSBSre94felWbTN9/aRtGwXLQ
1CvqMNW65GUQHqxPbbFbDN6DRxqx2L+6asRwuX9bxeJcWc23U2azhRtI7OdVswWr93MrGDDe
cj28gbGk0HhUZuK1a83Yk13C1rfZubLRudWEwKoJgdWHWFsweKnZhLG2lGcLGIrjYeUqjBVC
1ZlQh1Uz9mUX2lyPrGVfFCavhMnrwmwLBrTcJXmqLeXZBoZDbdZ819QaoXqZUOvN2I8d915W
U+FRa4UpKmGK4AAwsDA4TQ3R3k6erWAoLkRzD2SvFirLlgZWWxr2ZQf1Sja71F4rTFkJUy4I
sx0YLShbGmB6O3m2giGZ4s01Uq8RarYgsNqCsDe7Q1Vz6tNrhWlVwrQWhNkSjOPwpZMdZ0t5
toDhoC3CSowVQs0WBFZbEPZl59ShTQ3bWStMVQlT1YXZFowtLLvZGHdLebaBASN9afJx1wg1
WxBYvRl7ssOUszTA3bXCtCth2kHbMBJNW83d7ALMsNrzcMsdrpCnrs5BWsKQkltNZXa4bsMT
6Ko58GutOS3BwChTasUJeRyR609XZySKRz6hu5Jrx0Kz9ere77K8OH0XRl/J53fXv5x9IUeV
R+iWTMSC//7OqPnLGPx/fPy3EslR5iDuUaRXzeK3YXq0eEYl1/oJpPNG8VsxmeKxZKwAw7/1
4hk1NoaPIl00i9+G6Yni0YXzCaT+UvFbMJG/O/B/vUhhM6oXLSiaT1/nrtFMkbc3r9GWOLcV
hBd2FhP65kmCqjjYp+O15vdb102GGDBlZsy93ZQM8X4pM8kxzeiVryg/oa3xW5Thy1jwFyZA
aHayzNUZ+R68nOlpGP8XzAud+D4qfzfGiadRHPnPgq0Yw1ueArtudfL0t1xaovo2v8TG4FBJ
PCbTOE1DDB2xUl778NrcqCcNq7tP/bo12o7ElkIrpXk69OLE79Wt2yL/PjM1CVwQfhYpAAmD
tC1ubW4FN+a+mw9b4dVM4xS/jjcfbVWVW2C0LDzgg0lk/oN8D0d+TDx3OpsnflXTHvmOroH7
8cD+Bje/03SQ1dBw39z00aeAQK1OCFs1Cnblc0C7EHW+fhFHwvBYJ+JEkS45j6cPSXh7NyOc
UqsL/9jkQzyKx0FM3obxBKce8t+3+W//O8bCT8LZ/zx/OTbHBeDNzdszMnEj9xb6MSjC5WxL
5TBUkWo2UsYUDg240EVvwXRra3JOmcAZ0pCjPmTC1wygRf4AbVFxOscFQ8nMXn5/PlA9oXq+
5kbJS/3ku08+nF3BBBME0P7K/MMJvML8wwnqOnA7GLatnKcxGC8vMpjIrnvaxWCWg8EWsMe/
zf05TgYYKrabxMMwyoL6+GPfM3bK0IeeP+oQ/8cUnpBpLepLOJm63uzAqJwLPPNY8ALo34cY
cNS49NS+IF+/T7rmc1vcykLvsV/f9HvkIky/km/zeAY6xgh/DtSJqla57Wi1MYfOaPH7RwI4
WYzn8ZtMlCEM11UP39Q6mhAc77fe9LvniAKz6YIW8eT3knJUGafRFJSd6CabCNBbZRsKdOIy
FCTfJN2M57fG0vIGg6wZjmzB6pDLi9RYAw5Byzxyjcfw8SGQHIVhBgokthGSoOKQSJZkOBcU
SHwjpIAdFklL9LEokNBYYjRxCf+yBYWitnQWKDaojb2q11pEspixTMmR5EZI8rBIthCOrpCs
jZBge3JIJC2psbKov909mO9hJSAqh0h3oxaUO7jDXpjN0Rp4MJ00PcJW+oM1vMHQMQSvXHjl
B/ZchWBAzZWmqYVRpXzSnrc9FEeIlSbGBYr1pAVvaygctvX2YyhqY1vd1tEEk2ylkW6BZm9s
nds+msWZ3sDZbw8GvAdbZY37LpyEWQDUMEFdDrTzl3j8NEvcKAWNNG0TQlLFVtriosmYyM+o
EOnGTdMQNWNQOd3UbxFAwPy9CsAEK8miFlz2z8jF1RlGor81+rBrNOG0ZRAlafOy2FhG/Wr2
2/mG3niSpncuDBfo3w/vr9DRrRr1XjXqRwubhEPDW6AFinwvd/6uT2imiHaK0LSwi9uNVigH
5qFPEewiTH4C1CxhfxukZQCJjagYPdHCVqg9vEl8v6QZkYnxk4aZXXApfyFH2C68p2DM4mio
B3v58lG+Czs+JKSyFS5YV6COw06YgFLuYXTc/5h4IEuO4rtx2MJGDxjPnfjjceh2f2g1UKC5
1Ddu6NR6F6Zmp3cfz8cjMoQt+XwYT2fhxB33ar44DZyTZy9H2zb6FnjJw3QWT24T455Njph+
woefCdX04W8fzqHSwldvOI7vgzC921cKDZyT5y/HYXj0OLuPa193xb37sHNZK7D+uPJgCy7N
8de7q0/v/nnxz+71pYm0kszNaUdK8LAvMvcSWXjydlgtaeLA/PobQe/Y1/3n4tUcl3EUWgDD
Gs90XyBQccSavsAIHMhbxvptiVlQB0Nj/RHMQqJhNNDz7QW2F7MllWA58wFZbI6384k378IS
gMLpdbtd0p+5yQyDBWXRKyLMsgWSOmUkCtyv/n0SouBOJc5rs4E52f/ujk8VxaPtYZz6QIms
gyjOdkR3v8OT9G4eBPChpBfAP5/Bh1OLhMm3rBQgDL6lg1EeMOGUmo938XgUB0H+qWDL0kQM
hnGczk7ZS1r7WJVi15+WsBKrMwP1JRqkvpcCMLRlPB5403n997JgRkk0GLpJEvrJwBsiQxzB
F1U5xYOyqv8v5WeVMogZVfy6lMk5LsA4j8PTQf50kAmWzGBP3xJz5mHyNHPVrW0CwA6CahP9
agFgTa1R6kkRlK4N3sbIJm9vzPH+KNva5XfFaB9gXOvxnv5l+pAGqbkmAs7O4dBw4l9AuzAL
O3CPHiLY6Xqgobme3wXlIIxHtYJOWkaBRcjZq4P3BpCw85SP9HKDb6mn9+Z3FG/27XYN2BfA
4pbT7MltWrA3vyVEU4LbNWBvAC3QAWH3FuzJbwu+WQOyNWqx8vsxK4b3QbvXfF9+mODVJpXH
pT5t1H0PXs3Z0rSxRlZLdd6LVxtf1dV1LuubaSqNGu/O6VjisfezEs9ydfdhNd75T9Q306Sa
9d2d0zh3LXCuEs2Kyu7MqOVG6pE3DMYxLIKN+u7H7dhN7lXiWVHpHRkdaUI8B/OZ/2N1diVV
5lbq8g6GS6T1+/TWMJTxxVk7LOviWm7EHsyMKxNrFo+foY9SzCGH0XiBbDIdDMMZ7Eqkue8y
LTiFtgzn3ld/ln+mrQMJaTsYvemrm7pRj/zr7MP15fXbHvnlrH92TUaxn0Yvyh18fq5K7uJZ
1x2NWsWwtOSsxLhaICL34XiMZ0mjXEHck0tjKEzowniCoT8/vL960ydXHy/I0fkxyezEQAf9
2Z11yGXknezJJikmt8MRm/pZ8qGj3I7O5HOzT7g83omWaeaA1OPEjW79IB0gfQ+D06IGbe4R
Rv5wfpvfsfbQ7hV+0F57AMI2MRkLgB5mncKwfEV959N0BtPRpG45uw+fskyMYLMhBgoY+IM7
fwzbA+yOeRSZCR4zc5eXDjsyWRQTjuRMOMn0yMD8HAh+dIzTDibWchPvDs2rxj7G6MrDUMaG
6RBITDCMgFpD+oNxlODWMo6SfxSOI3BHWcMR0FKe52rPIsXuSs2ZhY6kxXhJkCNbd8w1RORD
zU51ZqqAppOntEPSOxhsODtXs217ONIkDfmITLR6I9c+hzcO5xWCkSCxYHTho+Sr/5BuTMJh
4ZcKY/CYzKAf/CCMYJ7AwOB1q79acOzeQtbQtlGUcY9bMCsxkM1IxmsiGnM1EtLxNZdOw8JE
Smo7Ftea6jI/6x9SIgZVNlnmyMfExbnRHRMvxrdgBkV7mK7SH52afupkQyctPuXaUPHRDLHu
f+aTaVoMogPDG8taB4MU/EnhOXfQPpmQC+CdrXohNiSS0jFexkBUxCouj6a5wyjXttSi7PZd
GDCvJy3eetZ7+jlqMo+86huQWCcODlp9oA44MLyC+R92bH9eeGnZqPc+MvA2JHIkN5GJVw42
qfEto7ZVDradGKSNV7LZKOS9p5/rfFpaM/Q2INEnUAdb2gfqgIPDS0WpSarzJ4V3lCMfHXgb
EjkY90yuHmywd6GOZTGpysG2CwMDWTjFKBS9J59zrezH1KQNSJwTR8G+VRyoAw4LzykGyjIp
q/+k8Ba3ufPYwNuUyHZgB71moWYa5igY4BYtBtsuDJoxgQE5z0AMmFnAbBLwnAfmWlQ9bIxG
tSOxMIcZOL7zC0BvniSY6Ki2KcmSKGRXgoyS2R2eTaftYWAU1sxmiuRffBZfejXuQRilfjIb
BJg0PAtJ3QKnYMYNu+Rkz8MpVY1TPw8neoaUnNazcPKFXpHPw8nrEqLPwinsfOznX/VyEEJJ
4s/mSYSPuozvx+Kg6dEqFtYiC+ea1aTgbC6F3Tktzuuc/Hk48bZxlWj4OtHswmJSipT1U1vU
b3dOResysQ/PadmKo5HuKtGI1aLZicXheNGxikW2x+JYXNHVLFZrLApDCOPNZCVeYHAxc9/j
ds3aWk51dhA8h1tqdZPUuiZtzwLLmbNmGrTbY4F5sNxdNlh0iywgSWs1i9Mii21yn/Wzy8Sa
FtXB3xdfy+2IhTDHFOYUfJqE0SzoEXc8JjC0F07Cd2TAOFVcmajexogxnE3cacYAe1CLqhZ5
LGoXFZvPw1HGwXQb1HlqWC/xBO+R8w/ng3evB68uP/bJKVGyY568ek3KJy0wCoqGEzlj6o+D
hZphdjGTxgnzjnHLkXmEBgwRBEqGzRWeI/ve4fA0ZXaO5y23bHs6R2N/FHRbVRAzxDqqUb92
8Vie9MzgDWAzOgzxLlTDfmsZey8mqItJp5zV/MBcmH4CE1b+Phj5Xp5RMb+Krd28bkkpTW6f
BUpjkwI7wcLJzYRmMxfMLyZf4UOdmngA4xD6IsvbiLZf5OTH7yQIMWHYLCZhfuX37IXhpXWe
+G4QzrTdw5vJrJCtaDR30PsujKZzqO5NfO8n5NV8NosjjLf1MnfSfvnu+rf+v/sfr3qU4u83
//rw6hp/N3zZv/SwmMqpMsgtQH4GxjdfdiB0TAryf7kJ3n4CbZmL7qbI2mlcV4n/HQ8RCreK
DhnOZ8bR4g66aVzcyx4G0UG32i/kHBM/oxkenjyFxmXp/OZTkPjfSkMWWPxi8hDPE/LVhzV7
3CqGYMpE2uj7SYieU5pb9CU+o3lIqQ7osiZJWMeEBErv3CTz+K3ZurSJAwsvngjk0Qxms4c+
RdfUy5fvMRJ8oMlRmHyDSR1WNcy/ORi68xF8RI9LSo/RFcglptyzQ0LCSMSUZj+70a3xwuxl
FlgmKV3xLM9/Tk+cE0aOZiH6aqaw9lOYKb04QkVp4ia3sBLAY1U+PT555lJsy7FhzX6TJWKD
cRKEMEl50zmtT207k2smLPTYzawP4vzdIHmsm9BP0OjiITu3u/ho3ADQ14u2iKCZRMuP0Xwy
eehCX5vZEkfhLYzM6ISQT2gGlXw7vd6HxTGJbDaPDvc9nKIbkJuMWoWwHKz4Oynp299IMEbL
RVBsp2baChY7LcvXgg7rWWDADsg0ytPRwyib+4dFlcwx1wfXMfnujsORib/0Pjq/C6dFCJEs
pMjuDJwZO7fPEUy/aTj5Qu6LGRy3KgPUxXpkHmXhrNAhxJ25JJ7PYIEixqKiY5y3fHx5+h/P
Pr4efHh9dvHvfP+EvvJ/SFHKuFL8xYrCyBp/waIUw2SGf7GiJHVQT/+rFWXZeHD+FyvKwuO7
LwRLKqPamlmyQ67caA7rCdqTJ+TyAq3HHN0hZkLNPgqnfRyhMY5WhvMxTu/CoUuuz64v0Ib+
KnxFWEf/SnR3mEeW25lHcQzWkvEAGQG6Dum/O+8QUBnSLH+6seP/Bb8oU6qbaHsd8v79q5Li
oJiKmpA+2aKaf5shb0XCtElOs1BiLZ7mxjTCuNJgTV0YilWDdiOzBJ6wpVmEkrpwtiLJNn4m
sz2J5pMhOl1wxZmU29FoZfJwGBrQnPJCe0TwrWhsytE1A+M/3YcjPOrWm33HFEZ8RLcJPABa
bLLcmkxIPJQoyGq96mxHY1Fdo6nGqNyKRNl4w1kN0ewsBEih0sJiSi906bbkWpuUaVh/dzRK
8KbfjLSFKmxCpKnxAs2F2iATW5NxiVE1MfBIHBnrW8k3+9LhFPPj9VE3NhvhYkJNYBM6ygKw
p7tRK8d20BWhdNFixn1kilvHLKBEHJGfVs+eP/XaRbEZN4FDslB2xZ9u/lFnH0kvB4KVcD52
UeJlMYT+dBAsBbtrvU0s73u3m3htsWuqTFTiOy8c3HmwlmCkdH5CyYvX0R3GuBm9ID9jyvLz
wmE+IUevfz6/PCYXBvAQSDBaeYbUnXphjyCVyUgwLc64Rntz2BqNBopo5Uzw/6Puap/TyJH+
9/wVeu75sEnVQCSNRpqh7rk62zhZ365jX3B292or5RqGwcwaGI4ZbJO//unWvIBtTJBHOAmV
AB7UP6mlVqv11o2F3vVnmB4zI//rUOmjyBK5j6GhcRBO8yvOaFHZ784u3sMfu9WwBQRGGU5c
dmbhFlK2on44tImAByMMEKJBdBlGE3v0UuCGePm4EPiDfpbPwQCtapCcpoN4XCGgmsRUE3g4
yfQa/Emv+wHUejjLKzeFe4bGPZotbvw3RS0YzyxRu9LDrVoT6nwSWSMPlDQp+2QQ+ZTaIhcc
VPXn8mmH3NC2anvktUvfMvoWoyO+6WD7dVfNeboA+Gty2j0CCtJNrpI8HJOjcAIW/t5hlV7r
NKnqTK+4W0SQLpUmQ1uNcHkVT+FLtA8k6amCq6zcYMDaLTYb6k2ONXis8L1gBBJjQuyuu0au
YJaoFdeHU4zKrxFaCzCArMN42lnZ7rzMYJS7s0UeKKqYKRO2IQJK9UHo3ZlYwqz0r7CMVGAJ
wZXMVKo/xgmINekdXZCjClCTReF8QAq/IC+XAfe0f5Sd6yBJL/PEFjVoBdeQuePBVayfX5zA
nEh/K0f7fcO6uP/eAJa/KKwnpGdiacaTWXxli1opzzdkyTaCZPpmz84cDH3GV4tMTcmVFMK0
/HuACISR8XYVzifJ9PJqltmE8LmQ0pCR9xqGvD/vId3bPF/uDc4LqIl5ncxu7dD60jPt9ifn
vyfzeIxrYVE6BcT1Dm8X0GtTKnxm0vTJYnE5G6XxNLmziwGqwJSxfeJgtHETGx8vk83CqT16
lzHT4e2XAoO0yGtc6U0XORkm8wnGU3vzAsASbO9nAm8ajPcD6RZOpZ8FuWkQ3hOk9ISpQVhB
iheDFJQb9ftSxi9ng9AuhsvlcxvgvHtgHccLXPe5VQ042M1mc/hlusCFC1xVf/Mi2NJ1XVP+
/0jmUTohb8nxNIefQnL+vvcdZKKU0frnddpPxpdZGVvPDgLMfamxNJ0dnvyq02UTdHyt53Lw
M9g11erRXpEDro+37L4QGOWXi9oYtQLgCWY6fp/CHPiTfRBfGa0bTNIMZIbaomeMKmNtdJpm
ER4I2Tys7AOSc+WaWMfIpS+oPXov4OqZLCHQW+Vzuk6zvhv0AvjoZsVISu4WmKU1eo8JY11y
evbHAfl0vg8Y4Xsm3KR5In3Pt0YvBfVMDc69YATCaGFiNuYudW2RK+EbN6Z9CFzlMFl1/G8U
Lu5sUUtFTdvQNkLAA2ays/PfaH2TyQpA4AtTHv69CMdgq01WO7Z7gkPvVNuCtj9iLwuH8eV9
Dq1gMCGYMGRrnzicMmYyomZJPJ+H1sgFY6Ydv6chNjSxVTCXUWrSHbJZNPPvPHv0uG9sysz5
0bltDCGE0emULFswSq2RF7dbTZVAHkcj0ut9agGWpsjTzQbV/jPwfGV0TiRbTvrp+EEntQIi
hWu8lFcAWYUIhNEKzk2SpXNL1MoT6PnXqPg/43WAmb4Z+RuCkbfkPBxPyFlv37C+a67he+l0
SY7GSUxgSrkPpMB8i36F5La9PSAF0mxb7jbJRv10+mgktITjUphkmQ5DL4HFaMBNZju3oySP
R3GY20SQ5tsJR+l0irdLL1DntsjvCPrz8cHFtiW9l8uIe+YrrE9ltF9QV3BODVrvLoun2eUk
twcgqBCmg+2eQDxqtF4bDhb5arLVlNxjipn0o3A2G8eDJJuNw6VlEOW7Zqed8lE8n1ijl5z6
JuN5PEm4xBjO5X5i4YNkvj88sLxM+AM8yV8SLxB43n+YD5LLeIyRUKqzJ/CkhU+ek1ShoWdy
0GUfCJIZHXFOBpN0UUaXt0IfCKOV0iS9xSCbK2vTAoLPpWd0ki5Lrkb5ZSUs9nHQ6ZsBDiQc
V5dFLJAHzKg+xwNIaok64IyaDH3QjN5qGtuY3GPC8AQ5+jiyR+8Lo7UMSHgZj7I4v9wDjKAs
8E24yed46epGRxVZdS5rMJ5vdN5L2y03WXUq0Q5CwIzs8uViHt9ZosYoaya6JRqFaXYdLy0C
BEwfXB9ErQIhwgD0GHhMOz8JpyS8CZOx9lXzqXsEo2k4GAD6n9qLYTz/jIs3Y8gTXXLP4qn2
3F5klr1sJlxwzCQBeeAdcv7hHN56b/n6JbQ/4Sl1qdv55bDr4PchczunZ58+o/8keiepA28C
/eAQ5jD+EtAu40JfFwet1SlyIABRbgA/Im1OJ5hHH9AdfPrjKTrenFDAWA6Vpw2EQXxTVp3+
s7r3i7sO6VRPNtCf5KR2+9ac3KMSj8CUHt5gOnoBmigbh+iEohfnhOMpJ+1y6J7Ht+rC51vN
6FvN9T1/b+wlc5AUd1oTHmnyyl3/vcuoBsmUazQRBbzWIEnBvGwteLQPmKLQrVk4R2FqjdF+
6lSnH0i+nMVkMc1mcZQMk3hgh7Q6ubpb4T+m/TR/t/jyhZyB+iG9ItrWCSZ7B8kcctY7efdS
6D5VJkMv1k+eTJetNZPMEghYhTD2zmbZ5RjmxhH0zfMe6Ompjh0ZJTP9dQVtg9DFVca1a4is
dZvAzK4LHR9j3sU5hvZEL6V5GqWVX8BGlJJyoxs53V4gAvrRIr2O19Dtsd9PyS1DVxyTEAEq
ghZ5HelImoL0voT9dBxl5D3YGdepZQwfLwGxFp5wX78vnI+gFntcSUr6IUaxXYJ6nia5vmiX
zNawW/DmOd8whwCvC34mg2jQhzYvPjoYq2RMekuoj0mGvn/CKx0vkRyiB5xSYl7flEE2vbZs
05bb5m/2i+pRTxidaoeEo2Rgk7yYboyS0gvDzyddglgPBhSzpApdwUTzNLuMo8vxLEKvUOW6
I5Qs09XVfnZ6IT2cpxKMf94aTsDcxEUBdJ0zib98CaeoVuhzU/uiCJyHr3UPUZ0C4Abs0tXU
xjS556nAq5Kfz9PBIsrJNMQoNDr5IM6Sq2kLekMrL+LGWCH1A7RdgPenkraGlLJOJa9lXFH0
gTUJ82gE1gWoz33BSRjhC7hLsGRu9HI16Od+jNOAbRlULhy1D554Pgc90Qq8/eMG+iCWNfbt
wilXe1ZBrrXH5ss4nqGL0e3YD5Nrx6EwfCSD2iX4PB7C3zAjQ+Mbzzpn3zbPgOLSvrVqswvn
u9p5L7IIc/E52unbYQu/3AOY1WRRNeH52zaSv32TvAKp0L5Kob3QCzioad08H05PiqFmvpjl
7eelljA/wqtJMK+bg2k2gORH558ogRL9H70bSuaQ2RC+MRSLmwTHU/zLGrnyH5CfVl/Jp9kA
nRYWTd8hN7wNSuLveXIFU8B/hslN+CUJp+1hBtZlO0rbi+t/OOQ8RrvrbL7ohy+aB0zf8ZRm
u90mB+cnR1pC9avyPEVe0zfPTe176AmiTv3b8cfeydmHDtF382jl5c0oJecuuuSr8nvq+Uu/
Xq0KUpz8fVzA+8+/XQFdkCuxoYAPnr/Ey1/7XBVQcL2t8PTfro/HXAr3hzg4n54X3tb1DBls
bOa1n5nY9zEE3yrxyVlLy+P/0tpSzjAyayMSj/kYt6nUmHoac3Km5b69+WWDEjoIKP0yNRTO
9HclvKLjt2u2IBXtPJYjk6SFZVgWFvUImFyjZZZE4bgoCE4dmhBIKvGU3z0CmIKh0lySi+UM
dOpzE3OOfg/vJf71okfq1/MTu0ptqECGjDEF/9mzknrcu18EgrbIHdANYGIdadeB5eIg9ArV
nNCn4kF1AuE59L0Ew4/irBdDM9Hnp+cMT4zcT19JcDmFhgKxBgSuz9Xj6uUbRNkkqefi0cH7
xQjn/SQvDkLdE2CzxFLrB50Sldx6C+mQZp1nJfVdNENOznQ90V1+CPRgTGbJFCPHVuEvHBIP
rmLikFFyNXLIb68pfYOBMj6+xs+efq96s0O6xc+n6xbF3oAD7uoouQjMMPStxiWPgF32CHic
Xmn1o4GZBmb7B1aMC9wB0cB8G/DjqvhWwJ6Hdwk0sGux8fYI7HuyqgrxQwBz5gVVVXg/BLCr
tLs4DSx/CGBBFZ4k1cDqxwB2FW49aWD/xwCGgU+VwMG6EhrHN/F4TQkFhkpob8C43Fop+tBm
VewNWNIAh28N3P8xgIvdCw0cbRuajgwbb3/AvpCVuA2sVsW+gH3h1Woz/jGAlfZDqIGHPwRw
QBUvxY3ZNGP3CFyct9HA7EcA9hmj1VQBg5L8AMC4SV0OpsymGbtHYLBiS6OQ2TRj9wfsYvio
EtimGbs/YEFFNfwzm2bsHoFh0lsB2zRj9wfsucLD1c+P/8YjpQBfhf3LOmZpZOAWaSjZ+LD1
D0I7vHh/tUoRMAwTAykY2fhQE7DifUUmuYvrZZDCJRsfagK3eF8jc6XgOoUgGx9qAlG8r5Ep
H7skpPDIxoeawCve18gC6hUpJNn4UBPI4n1FpqjCqyaQQpGNDzWBKt7XyITC86+QwicbH2oC
v3hfI/MCjIMDKQKy8aEmCIr3FZlPqSqbaK297z0t2oyWH2ukTC8LYaK1Nr/3tKApW32t2X1X
uEGRiJPNTwsaXn6skRbH4jHRmsjce1rQuOXHGmmgg69jojWxufe0oBHlx4oUjBKvqH+2Jjr3
nhY0XvmxRio4Xkx8Ynfj3osM0mncbk4ZYCgGKNjhyVmPHHe7ZBhGyTjJlxj+gMniPNm/FtMW
BzUvN0XktIQBJj7Ord/N4xg3exZTPOpcRjYmk3iSzpcdEkj/F/J6WL587sshpRRvt9WPtI/l
lbLbG64vAgb95Xcd9xsPTOJqcrlLVaKjT/RWOh0vdaS/DtSD8Om1LQTZptT1UY1t540FriyZ
w85KWcSiFXPFo1gv2b/ZP7Bm4GvAnPF1XO5G/Qe4XLwQLp7GhHnnPJwO8AhOMk1ysij+0o1T
nIJyiyhq6VBvDKWz5eoqh30ksMcZ7lyP0izHA27kNWPsDdEMX+mzK1mOcSSja+hpMwxWx33h
liEByTge5vaRuAKtimHaxstJushHA4SSX4GiVWTBfUEJl0q8rlHeSjiZHN/pexOH/+mSi3QR
jc7Dr19HYOvXEdwXgPZhcNMXbUBCOmshuSPNO5mBWm2VxiCK+ji9usJPPCL8V9q3jBIoVdzr
QJSLeDJL5+F8idoqQvfe2Sy8nRaHADsYwTkDzgkeZiKAU+ywQc/bDxqAKVc15dASCg4Zyhpn
FtFUm3kuRY+XTTi0h6IE5fY4s4oGYzxtKAnWUIKAW5QAq2gwdZJ4FzgKc1DNnrddNSsVPB4w
LIH4XDHRuK4toUCfFdbq2C5a4ClP0qYcWkKRkq9QGnNmEc1vwxRNr3U24dAaSlDELP4eUJgn
FK6ofg8onHraT/p3gcKVxxvXriUUJRlrXrvNUBZg7Q7+ZAH/3KluiQBxfBdHC6D+6W3WT6Zv
J+lA3zP56eED0urfkDCaJZ1fP/zR+0/v4rTz07ZeW+UmbOR2+Km3W26qeW5H5592yyt4Uc68
5+dWTINgNs2CG5xAz+q5fyumDnOulXDm4WScDW93KAqnsiHj6HvgiL7bhW9OLcjPji2KntOb
MwbT9t0yayqqmNnBjpmxBtKDYaa12DDuioH+Aq+seHTwTmTlM0r7EXWziNKE0p0KxV5QjlgD
OaprwKe+1NwqxtwnakBmkb9zDTToSRsKBbL3RKEYNAtL/N0K1UAwHxcKhEY9XVO7y4r/grLC
m46QRpk1UDqbZIA+JQNSy8Bu1c2bat1COcndaqCBcjLPzMbgtXNmNroSNmTRjvDvYdviqnjZ
v3ftSm4Dtbuhf1N6/ITAcZNC2RC4Xbuc+5IyIG1orndst3Fe2jAq3B2NCmlj9LIt3Yp+j4Wy
Id0eZTs1i7Ji69muAatKh3sHh08oHd/A/FI27H0YcXdrFhtdU+yYmd/Agqn2wjrVl9YQJodx
fzEcxvOdMm/QBWtOD3fltIn5VHE6j68WY/T6uNwpyyayXGVZ36PfKceX1B+ywbrG/vSHjSF7
16m5ajBk1w08iMfjy3l/sVOG32OV+1ZWnBgWhBUrTgeHghUrTsJhzGHCuVbMUdxRrqOEozxH
SUcpRwWOOnDUoaOOHNV11LGj3jk+dfwjxz92/HdOcOgER07QdYJjJ3jnHLjOgXAOPOdAOgdH
zkHXOVTOoe8cBk43cI45Lm4JZ4wZc2fHRS7VRINabxJcAHYpHnFTDTZ56pZt0JketCzHlpVr
a4ncuYaRGJoX2pdx+O/Cf+HM8Tfp+M4Oy4yaWdZmHuV4VrUhs0ETg9BwgChLzj0pRbPVfmso
rqtUw5Mm9lCkr+/Gfg8oAiRUNNtjsoYCzSyDb41SdBe3ycrPs7oLb7vcDdjzO7pdFCm1g8fv
AUWApdlUAVhDUYE+l/09oHg80N4EvynKL8XhVTwOk3XIYZrm5OyX/3nq8cUcs1mSG1AZs3lM
SDe8icm/0mmckb8P4Ptf/5zHg1GI7rEm/3j1J6b+TE7D+TXmmS2zCJ3IXcX5JXS2RZZfak/j
r6XoQ+G5EsAQfnMZf4PnGoGNflxfSWm/6kJGZBbOC3d086sF+i/J2q+qDBC8zCRD+vLKabsq
SLeuhjrVBEhjfYiyyob0l9rNdTgdFH5y0xk68MjWuYFUUrSgqE/zBNxoHgZxGOXJDTp7az+A
cPl2iKoaNkHcp4U2cj1a8esQtqo08qCkmJS5G5O+6h58eH/8sUM+fvrw4eTDe3LQIx/Pzi7a
rz5Nx3jQZZkuCAZ3mS+mU6zFZEpCcpPM80U4hpqMRlBdDslHSVa4nSdRiL7D9THURaYdP47R
RavWo8BYehPP0fsgYh2dnvVepRh4c5KMQx2TCxIVMLM0h4ZOoPRLyOY6LrIoMySLaR/kU3u0
x9PN6SKHUtWBaOZxFuftV6+ifD5uRWSa3gJBzQ10EgS9xse3ILc1i4MUClXXdi8PtRPUW3Qz
OEivqqM/Djk/6RIoi+uzV39OwmSKjQvVko/0aesEPRImN3gRovixF+dZGl2DSL1mhLuEc4kn
wgnICrpVB7Eif7IO77DPGymGjwkYRQrvKQoe1iQyrmnYdppVuYJVPi7SsCdpaE0TqZpGbOWG
+zUN82oab1eaFTvBruzU3HC6NZeopuB+TcK35sJWFRDUJePudma8DSXztjOzKloQ1TQoNbLj
dugTZatpQl7TqO3s1CTDoCbxt4kAjckGdlyqi8Y7YnM+agPJV6STbiDZLmiMbyCRW+U52kCh
tmUC7IsNNP529te6Z00jtsvmqpJVLZuCbed/sOpotdAItyzaZqG5x0+/lmjhlaLGd25Psb2m
1zq0rEm2VvV6rcUrfvztYhOsuKE1TbBzk660mvcVkV4JmxrUNLysNjDtv9ZEUd1Hva+ojw09
wRNbK3vVPD6rSeT2itvQqz21fTDYQBFsp9hAIrcL9ao9B25NYl5h8itj1GrIZWFNs12i17tb
v6bZqm83K0/5Ne2xwR5Q26tAroaCYU2yXWbYhlpT3lblQfiqCoJVPl/p1f3H+fjbB91Nsulv
r4D+BnXjb1UDa3U2qM2UYLvZtWH4CLaL86pnhrWcBdu59zdk4u3Y/YNayQTbTc61VhnUwhx8
pf9vaMng/4u71h+3cSP+3X+FejjgNteVLZJ6GvCHCxoUh+IaoGlxKIKFoQflFdaWHEne7Oav
71APD72hSNu7d/WHxNZqfkMO58WhRIbn5nUM+69P7BSxUxxzrlUYhcyIQ/X6r/BNxNGnqZGK
xJBxoZn5ORJpcy5JBRKJkcHXeipGhjmBqkNELzcq5UMOEp2roRIffYBCWwuRRC9r1ZSAEL2G
KlwNMcw8JM2RhufsuYfvI40hJ5YiToZEZ0fDVOJ0dmzLUXkMkwmFOyDUMGlDzY6wcd1s4rIs
gjC931WqAjPmxqgNBKnGoGhMDDPUVGbIvlSycw0OSxGwieueq0EpQyLDZFzlFVy9LqB6Z+gU
3HBIjyckh3kOZhPENbg5xXSMeIbwoFIGj+j5SD1CGkPeomybXtjSqAaoc76+Qxgi0xRpqJYR
V7TNN1R/MhWNXrMl54iZNfH1OaIqPAQGp4AiQBJ3nI75E0QohBxLU4E+dqEiSCTaTEldNCBB
eL77QaqQDlRTc0xp2hyiTw31Q6sy8VAfI3CQsBLYpdgaC5ddybHgRAxZNmod+tPobGvF/kR6
g5C0Gy080k6aJoYoGiPERPVEVQ4ipmQbpY2DGhmKIUo+en+qSoOpKd1Gv+0hjaFYhUSej0SG
IVKESep4ep2TchmKRU5Hb3xKX0dNKTd2CeVgqtxLERnlQK6oKBN3dAxT3o6oqAyFaMVMihK9
Y5BGiTlIFBiMQlHloGT0JxPO7sSz5khHmakQh+l3glR6WagaaMijVRkApYY5sooP0xsG6oPH
kMagRKoFEzauMUwqEeYncYBkoWFwUQ4B2iC7vFpIXYPjR33FOgZ1z17UkRgZMmll484uskg0
er+vCMxUnxKDTahGtstvtSOrYuXp9U7yrRlqg6E6reSjNT11AkW90aVMWbkic6De2QsIyMjX
z8Qwi8xypHH1YQmtHGOFb1jhkxQoRu02JNPqHukLTqr4EjgGnyq1jqMyBHqDlYsnuNIZ6NVO
WlEmSMMunvTRQO/xVfYa+Prpv2QSEpF+iBR5Gg3H9acpe1UNa6gvICnbZqikK9Un1E+RlA41
vPihBxrqfaPExouRKDTpKZJhcYKGZ9cZ2HF6QC9fH6DR2U9lYIWc6qchcj7IJE76QVIpXWRI
Z6TiBBprFJgErnLehpUClekZFgqooqTBHEPZQCrHx0hkGCOptO4gkWHugo4u9pHIsC6pMFjm
aMcVYiVyohKnCzI7iZfeKlQSJ4aFc2kxgyGRQeKoDqGHRONy+0S4VMxdmGlmpXqGxLAyIdHk
qEPk4hIXMyxNqNumtwnUVJyaM8Myg8ITM9NjUSo9pdqS08STNNSkpjhzwxUDRs9O6jyKRIZK
iKpPpqUJabEFVcEweVM9hGSauyncI9OvMYC8UXSUIFWkNyI08RB9nasXg5SmZkhz+SI/cw0F
aRWJ4SExFYnpoQ2VorqRYcqLgZweZwXM0wtOpQqG2ZSSRB/5JbFFSDManvGRrwSVx9M7OeUT
eZ5+6qGYszH9Y0WnRSBsnD/OeNWB6KR460tPDI6rghPxSxXzfMMKmpJGmw+fhHFcq2N+oB8m
pRkZZnsqhx9cXJNngWEJFvvjB0hkWOTEkSXofgK9W5Cy4RRpTBUGleCC0CBtVYwIvgvJgrkg
AtLhjY3MSmKxSSmQFGVeWXld7YZbIHKk91y8f3R8nvzvvOTizFLxRod4LynjTVoX+7aqm/GW
X7IM4MD5iRvEBtxNjyk2jT69JxAa/vIu8aT76W2RD5OBl7c1z8AwvS+2mbNk4kiqbXpffS0h
QboR+2rXvD3UJRB/+OfHT//9dNu9d9G9stFAN7vXG0SnZICOHqhDehV5Ue3rolo3XLyL4ZGr
MHZVVuTP623WbR/rXoUxvCmwftytxasO/NG6YW54XXO+rKs9L8W7JcFrZLLpZXK+XPvR/9e4
jXzDxZnBzKee60QhiyQm7h0E9mz9wJ+BwzXddLtutsWOZzVPOfxVALGzgcY3NO6s38d3NY4v
YVg3+yIDHuIouROGxQZsiK/38Qb0GSRzhcL27QbJgsLFbVuLVntXwYjXgHZij9ltkQopsugq
mOZrvK/yXOxrf107Mr7lIBSwgcNWbNofXCeVrh3Cjv0rdBboDw3fFgnQsyvsD+jLvGl4/Zi2
W+FLnOtGtnpE7QjOHo+ff/7Z2kDjU5ClOHYD7heXFm3/Ft0SXCfnN+/EMQ2PoKHiPaeibHm9
tJwnZ/xQv3v1XlDOVv3Heh+nD20dp3xprcbPbAGcFk+hv/Zde1uUhyd7Ux7ExXTeVHP/5q/O
U8B9mPd/hi95HMdJnEfw+242Ngj+4BISh/z0khMHYfLiUuZl6YtLjDrxi0t+HrzEookT3Bnb
ul6L7+tGvHa1Ft4HGs8zqeVRGvjZS+gsY3dHGf3WHcchzpNCIc0cpz96w4YvNBJire2n/fE0
cfiydCBLoBG19J+RMSD6HRAg+mHcIX61O8Qe/wpEyBuCDpG6QSAjYhvhXwMcfD7f83h/Nxth
AC9wk7fA62EAL4z81+O5A6ENitYj2F/t5hTPFYV/JzBIEBKaxTdeV9ZN77uyd7NOXcLc9wSD
4UcQTw186EST4FMau0lBT4XWkpmM3zOLSNBpgW33EiLe2zIb8I/Mhp4NzNw3Z3bSsxNd+gN6
liCzZGBmqxXDv1AhBrwePPaOPVGCexeCD3gDeNSDT6m0eyl4JINnerGwS8EzCTwherFM+LNJ
8EQe0ITpxUIuBWcyuKcXy4RrmgaXBzQJdGIRz1BdCB7I4KFOLOKhrgvBQxk80olFPGV2Ibis
ikmsF8ulFjrgDeAp5VMuO4gmTEjja1KbzokHzmYmww+8OM0kj00S9ra8eviRFyOSwyYJfWNe
HfyRF5P8NUn8t+bFZF6hHBtwvEReMJPvGQm86ZgcTTjgycZlL5qWy03LmWtsWn/PSOBpcpyZ
fM+RINTZ8KXhZMA7go8hXgl+aTgZ8I7gqc6GLw0nA94RPDtDjpJx5IMvVHTVF6sgF7dG9ih5
eOKuulMEXgUeyuBxJLecvho8xiQPJMqmBskX60kXgg94I7inA5+Iyjpw7wRcM5uZyfccCeIz
CGKZYIxw/QxM8qevdiMD+JHTiTZT9lac8pRxMg5J94NqHNbk53N3tNXdCMh9CZCHspDOBXx8
jGvEC2W8Cd9twMua6m6WHz9+R2jLF8gFuJ8fh/1t7ibKlRSiXESZH9Ju5yQ3mrPIC2l0Z308
tOIozPH8zn8U2+3xaCfmEuumTt9ZTVrVXGxOIraoidO6yIuUW12R6I/Ccx3GxInOAoBnCOG5
1s2nKKrT+baCHr+z2qqNt/bjbklCh/kP72+tuKxKu26apUsd8VtU67vf1CPdDc09NK+7An//
8xkueJsuRLljni3qdNnvs0TcaAkNEeyGFnz3+THjyWFj/fBjv8rxg/WjqLVV5bEHXuQzahgC
z7NuqjLjYoen40C4uoH4Y1ADRtjrNld7O5TQ9cnr9kV8MxSPRWLf5++00AfLabac7yX9cxmh
J+oX0RPtI6S/oFT3P4HRsYgc3FkP/LkrQtPwimURoG82vN3FzYN1418HsPuyLqu2yLulmSuK
6YFqaeaairo4crBap3GZciEPciUEaJm0OnHFIgeAHIoMrDIuNzz7i/V73Cwt57bbI4zM3oP+
CmIRTUBXq/3c+vBUtGLLsKYql9Z/fv3bSHqy7vSZhURafeJP3f5m405iMwhL3WPj43Zsc+vT
IRWKx4E5qF5nN4da/IL0ZTb7sI33Yj1YyH1pBc7sC98dbKBuQdH6XMKy+93c7IfHnWWn+4MF
X8Tl4WTqxf5hs+jyjTH5ECdCp1WZFxu78WxxDBB13GixSVPbX4RJ6GZ5FuQ8oeI4cp5ENGcx
pzTI0zzg3E2ImwT+4nEnQL/Z7jyYO3adujZkQkFgbwYEy473e15m1k/3h3KzbkF51/u4LNIV
sXhcb5/3dVG2D6u2ff4kttr1RG2m71kGoWaz3vJHvl3xurZ6vx/vgbb/CrfVX9bx9mv83KyH
zeysOj3sM3A1c/iyBjmIBYTttlPZ6tCuxOYQPX+bWE2VtxDOHg77Y5vKXbEex3HVXbRg2Jvh
67aKs3Ud78CBPayocBe7fXu84Fggz6ba8tPeSBcd63ETr8qq3sVby6qrql11iTMgiPROxMCH
1eIhOYB22t3Gi4v6UNpfDvzAFzCghrHr88mSP7VL8BJiFenccVwmRcPTdshIvcV8HNdzAWzq
EB8aAv8RyphN7b4XVgJtTe9X2LRF3zTr/ceP/17/+tsvf/+w+r8pZ1Yn2XxXwICs0+pQtqvw
J8uyhZXWmbWommIXb/jiyyEuQYnG/20R1wezm6ebb5a9654ktpvd3qKW3R/EbXGRut6WvIXf
K/gPbuh/iOXM+rbIhoti40JIETJer8oU7qnsmnfX7ONOg4UP+LxJLLtu0+7ZkFWXhQmlBn61
cMMiDK0WebNospgshD469tjgQaEIvQW/XcQr8dfbIl+JbRuLahqBvBqBvhqBvRrBfTWC92oE
/2yEfZF1T/F0fgFSCfAGoAwLuPw9BKgcrwtwJYJi+YKi/5OKKIshey2Lb0J3ima/jZ8h3EHy
bYurLWRi5QGy2tn/ACRDNVh1EgIA

--=_5783e7d4.ghMddX2p1ia9FuZPpuYffA+eyPGef8x3apR7phtXvC9zRAcU
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="config-4.7.0-rc4-00278-g63495b0"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 4.7.0-rc4 Kernel Configuration
#
CONFIG_64BIT=y
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf64-x86-64"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_MMU=y
CONFIG_ARCH_MMAP_RND_BITS_MIN=28
CONFIG_ARCH_MMAP_RND_BITS_MAX=32
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MIN=8
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MAX=16
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ARCH_WANT_HUGE_PMD_SHARE=y
CONFIG_ARCH_WANT_GENERAL_HUGETLB=y
CONFIG_ZONE_DMA32=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_KASAN_SHADOW_OFFSET=0xdffffc0000000000
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-rdi -fcall-saved-rsi -fcall-saved-rdx -fcall-saved-rcx -fcall-saved-r8 -fcall-saved-r9 -fcall-saved-r10 -fcall-saved-r11"
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_DEBUG_RODATA=y
CONFIG_PGTABLE_LEVELS=4
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_CONSTRUCTORS=y
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y

#
# General setup
#
CONFIG_BROKEN_ON_SMP=y
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
# CONFIG_COMPILE_TEST is not set
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_HAVE_KERNEL_LZ4=y
# CONFIG_KERNEL_GZIP is not set
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
CONFIG_KERNEL_LZ4=y
CONFIG_DEFAULT_HOSTNAME="(none)"
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
# CONFIG_POSIX_MQUEUE is not set
# CONFIG_CROSS_MEMORY_ATTACH is not set
CONFIG_FHANDLE=y
# CONFIG_USELIB is not set
# CONFIG_AUDIT is not set
CONFIG_HAVE_ARCH_AUDITSYSCALL=y

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_IRQ_DOMAIN=y
CONFIG_IRQ_DOMAIN_HIERARCHY=y
CONFIG_IRQ_DOMAIN_DEBUG=y
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
CONFIG_CLOCKSOURCE_VALIDATE_LAST_CYCLE=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
CONFIG_GENERIC_CMOS_UPDATE=y

#
# Timers subsystem
#
CONFIG_TICK_ONESHOT=y
CONFIG_NO_HZ_COMMON=y
# CONFIG_HZ_PERIODIC is not set
CONFIG_NO_HZ_IDLE=y
CONFIG_NO_HZ=y
# CONFIG_HIGH_RES_TIMERS is not set

#
# CPU/Task time and stats accounting
#
CONFIG_VIRT_CPU_ACCOUNTING=y
# CONFIG_TICK_CPU_ACCOUNTING is not set
CONFIG_VIRT_CPU_ACCOUNTING_GEN=y
# CONFIG_IRQ_TIME_ACCOUNTING is not set
# CONFIG_BSD_PROCESS_ACCT is not set
# CONFIG_TASKSTATS is not set

#
# RCU Subsystem
#
CONFIG_TINY_RCU=y
# CONFIG_RCU_EXPERT is not set
CONFIG_SRCU=y
CONFIG_TASKS_RCU=y
CONFIG_RCU_STALL_COMMON=y
CONFIG_CONTEXT_TRACKING=y
# CONFIG_CONTEXT_TRACKING_FORCE is not set
# CONFIG_TREE_RCU_TRACE is not set
# CONFIG_RCU_EXPEDITE_BOOT is not set
CONFIG_BUILD_BIN2C=y
CONFIG_IKCONFIG=y
# CONFIG_IKCONFIG_PROC is not set
CONFIG_LOG_BUF_SHIFT=17
CONFIG_NMI_LOG_BUF_SHIFT=13
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_SUPPORTS_INT128=y
CONFIG_CGROUPS=y
CONFIG_PAGE_COUNTER=y
CONFIG_MEMCG=y
# CONFIG_CGROUP_SCHED is not set
# CONFIG_CGROUP_PIDS is not set
# CONFIG_CGROUP_FREEZER is not set
# CONFIG_CGROUP_HUGETLB is not set
# CONFIG_CPUSETS is not set
# CONFIG_CGROUP_DEVICE is not set
# CONFIG_CGROUP_CPUACCT is not set
# CONFIG_CGROUP_PERF is not set
# CONFIG_CGROUP_DEBUG is not set
CONFIG_CHECKPOINT_RESTORE=y
# CONFIG_NAMESPACES is not set
# CONFIG_SCHED_AUTOGROUP is not set
# CONFIG_SYSFS_DEPRECATED is not set
# CONFIG_RELAY is not set
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
CONFIG_RD_LZMA=y
CONFIG_RD_XZ=y
CONFIG_RD_LZO=y
CONFIG_RD_LZ4=y
CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE=y
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
CONFIG_HAVE_UID16=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BPF=y
CONFIG_EXPERT=y
# CONFIG_UID16 is not set
CONFIG_MULTIUSER=y
# CONFIG_SGETMASK_SYSCALL is not set
CONFIG_SYSFS_SYSCALL=y
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
# CONFIG_KALLSYMS_ABSOLUTE_PERCPU is not set
CONFIG_KALLSYMS_BASE_RELATIVE=y
CONFIG_PRINTK=y
CONFIG_PRINTK_NMI=y
CONFIG_BUG=y
# CONFIG_PCSPKR_PLATFORM is not set
# CONFIG_BASE_FULL is not set
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
# CONFIG_BPF_SYSCALL is not set
CONFIG_SHMEM=y
# CONFIG_AIO is not set
CONFIG_ADVISE_SYSCALLS=y
# CONFIG_USERFAULTFD is not set
CONFIG_PCI_QUIRKS=y
# CONFIG_MEMBARRIER is not set
CONFIG_EMBEDDED=y
CONFIG_HAVE_PERF_EVENTS=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
# CONFIG_VM_EVENT_COUNTERS is not set
CONFIG_SLUB_DEBUG=y
# CONFIG_COMPAT_BRK is not set
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_SLOB is not set
# CONFIG_SLAB_FREELIST_RANDOM is not set
# CONFIG_SYSTEM_DATA_VERIFICATION is not set
CONFIG_PROFILING=y
CONFIG_OPROFILE=y
# CONFIG_OPROFILE_EVENT_MULTIPLEX is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
CONFIG_JUMP_LABEL=y
CONFIG_STATIC_KEYS_SELFTEST=y
# CONFIG_UPROBES is not set
# CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_NMI=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_CONTIGUOUS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_ARCH_WANTS_DYNAMIC_TASK_STRUCT=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_DMA_API_DEBUG=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_PERF_REGS=y
CONFIG_HAVE_PERF_USER_STACK_DUMP=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_ALIGNED_STRUCT_PAGE=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_ARCH_WANT_COMPAT_IPC_PARSE_VERSION=y
CONFIG_ARCH_WANT_OLD_COMPAT_IPC=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_HAVE_CC_STACKPROTECTOR=y
# CONFIG_CC_STACKPROTECTOR is not set
CONFIG_CC_STACKPROTECTOR_NONE=y
# CONFIG_CC_STACKPROTECTOR_REGULAR is not set
# CONFIG_CC_STACKPROTECTOR_STRONG is not set
CONFIG_HAVE_CONTEXT_TRACKING=y
CONFIG_HAVE_VIRT_CPU_ACCOUNTING_GEN=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_HAVE_ARCH_HUGE_VMAP=y
CONFIG_HAVE_ARCH_SOFT_DIRTY=y
CONFIG_MODULES_USE_ELF_RELA=y
CONFIG_HAVE_IRQ_EXIT_ON_IRQ_STACK=y
CONFIG_ARCH_HAS_ELF_RANDOMIZE=y
CONFIG_HAVE_ARCH_MMAP_RND_BITS=y
CONFIG_HAVE_EXIT_THREAD=y
CONFIG_ARCH_MMAP_RND_BITS=28
CONFIG_HAVE_ARCH_MMAP_RND_COMPAT_BITS=y
CONFIG_ARCH_MMAP_RND_COMPAT_BITS=8
CONFIG_HAVE_COPY_THREAD_TLS=y
CONFIG_HAVE_STACK_VALIDATION=y
# CONFIG_HAVE_ARCH_HASH is not set
CONFIG_ISA_BUS_API=y
CONFIG_OLD_SIGSUSPEND3=y
CONFIG_COMPAT_OLD_SIGACTION=y
# CONFIG_CPU_NO_EFFICIENT_FFS is not set

#
# GCOV-based kernel profiling
#
CONFIG_GCOV_KERNEL=y
CONFIG_ARCH_HAS_GCOV_PROFILE_ALL=y
# CONFIG_GCOV_PROFILE_ALL is not set
# CONFIG_GCOV_FORMAT_AUTODETECT is not set
CONFIG_GCOV_FORMAT_3_4=y
# CONFIG_GCOV_FORMAT_4_7 is not set
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=1
# CONFIG_MODULES is not set
CONFIG_MODULES_TREE_LOOKUP=y
# CONFIG_BLOCK is not set
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=y
CONFIG_ARCH_USE_QUEUED_SPINLOCKS=y
CONFIG_ARCH_USE_QUEUED_RWLOCKS=y
CONFIG_FREEZER=y

#
# Processor type and features
#
# CONFIG_ZONE_DMA is not set
# CONFIG_SMP is not set
CONFIG_X86_FEATURE_NAMES=y
CONFIG_X86_FAST_FEATURE_TESTS=y
# CONFIG_X86_X2APIC is not set
# CONFIG_X86_MPPARSE is not set
# CONFIG_GOLDFISH is not set
# CONFIG_X86_EXTENDED_PLATFORM is not set
# CONFIG_X86_INTEL_LPSS is not set
# CONFIG_X86_AMD_PLATFORM_DEVICE is not set
# CONFIG_IOSF_MBI is not set
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
# CONFIG_XEN is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
CONFIG_NO_BOOTMEM=y
# CONFIG_MK8 is not set
# CONFIG_MPSC is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
CONFIG_GENERIC_CPU=y
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
# CONFIG_PROCESSOR_SELECT is not set
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
# CONFIG_DMI is not set
# CONFIG_GART_IOMMU is not set
# CONFIG_CALGARY_IOMMU is not set
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
CONFIG_NR_CPUS=1
# CONFIG_PREEMPT_NONE is not set
CONFIG_PREEMPT_VOLUNTARY=y
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_UP_LATE_INIT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
# CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
CONFIG_X86_MCE=y
# CONFIG_X86_MCE_INTEL is not set
# CONFIG_X86_MCE_AMD is not set
CONFIG_X86_MCE_INJECT=y

#
# Performance monitoring
#
CONFIG_PERF_EVENTS_INTEL_UNCORE=y
CONFIG_PERF_EVENTS_INTEL_RAPL=y
CONFIG_PERF_EVENTS_INTEL_CSTATE=y
CONFIG_PERF_EVENTS_AMD_POWER=y
# CONFIG_VM86 is not set
CONFIG_X86_VSYSCALL_EMULATION=y
CONFIG_I8K=y
CONFIG_MICROCODE=y
CONFIG_MICROCODE_INTEL=y
# CONFIG_MICROCODE_AMD is not set
CONFIG_MICROCODE_OLD_INTERFACE=y
CONFIG_X86_MSR=y
CONFIG_X86_CPUID=y
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_X86_DIRECT_GBPAGES=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
# CONFIG_ARCH_MEMORY_PROBE is not set
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
CONFIG_SPARSEMEM_VMEMMAP=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
CONFIG_HAVE_BOOTMEM_INFO_NODE=y
CONFIG_MEMORY_HOTPLUG=y
CONFIG_MEMORY_HOTPLUG_SPARSE=y
# CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE is not set
CONFIG_MEMORY_HOTREMOVE=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_VIRT_TO_BUS=y
# CONFIG_KSM is not set
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
CONFIG_MEMORY_FAILURE=y
# CONFIG_HWPOISON_INJECT is not set
# CONFIG_TRANSPARENT_HUGEPAGE is not set
CONFIG_NEED_PER_CPU_KM=y
CONFIG_CLEANCACHE=y
# CONFIG_CMA is not set
# CONFIG_MEM_SOFT_DIRTY is not set
CONFIG_ZPOOL=y
# CONFIG_ZBUD is not set
# CONFIG_Z3FOLD is not set
CONFIG_ZSMALLOC=y
# CONFIG_PGTABLE_MAPPING is not set
# CONFIG_ZSMALLOC_STAT is not set
CONFIG_GENERIC_EARLY_IOREMAP=y
CONFIG_ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT=y
CONFIG_DEFERRED_STRUCT_PAGE_INIT=y
# CONFIG_IDLE_PAGE_TRACKING is not set
CONFIG_ZONE_DEVICE=y
# CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
# CONFIG_MTRR_SANITIZER is not set
# CONFIG_X86_PAT is not set
# CONFIG_ARCH_RANDOM is not set
CONFIG_X86_SMAP=y
CONFIG_X86_INTEL_MPX=y
# CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS is not set
# CONFIG_EFI is not set
# CONFIG_SECCOMP is not set
# CONFIG_HZ_100 is not set
# CONFIG_HZ_250 is not set
CONFIG_HZ_300=y
# CONFIG_HZ_1000 is not set
CONFIG_HZ=300
# CONFIG_SCHED_HRTICK is not set
# CONFIG_KEXEC is not set
# CONFIG_KEXEC_FILE is not set
CONFIG_CRASH_DUMP=y
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
# CONFIG_RANDOMIZE_BASE is not set
CONFIG_PHYSICAL_ALIGN=0x200000
CONFIG_COMPAT_VDSO=y
# CONFIG_LEGACY_VSYSCALL_NATIVE is not set
CONFIG_LEGACY_VSYSCALL_EMULATE=y
# CONFIG_LEGACY_VSYSCALL_NONE is not set
# CONFIG_CMDLINE_BOOL is not set
# CONFIG_MODIFY_LDT_SYSCALL is not set
CONFIG_HAVE_LIVEPATCH=y
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y

#
# Power management and ACPI options
#
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
# CONFIG_SUSPEND_SKIP_SYNC is not set
CONFIG_PM_SLEEP=y
# CONFIG_PM_AUTOSLEEP is not set
# CONFIG_PM_WAKELOCKS is not set
CONFIG_PM=y
# CONFIG_PM_DEBUG is not set
# CONFIG_WQ_POWER_EFFICIENT_DEFAULT is not set
CONFIG_ACPI=y
CONFIG_ACPI_LEGACY_TABLES_LOOKUP=y
CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=y
CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT=y
# CONFIG_ACPI_DEBUGGER is not set
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_PROCFS_POWER is not set
CONFIG_ACPI_REV_OVERRIDE_POSSIBLE=y
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
# CONFIG_ACPI_VIDEO is not set
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_CPU_FREQ_PSS=y
CONFIG_ACPI_PROCESSOR_IDLE=y
CONFIG_ACPI_PROCESSOR=y
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_CUSTOM_DSDT_FILE=""
# CONFIG_ACPI_CUSTOM_DSDT is not set
CONFIG_ACPI_TABLE_UPGRADE=y
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
# CONFIG_ACPI_CONTAINER is not set
# CONFIG_ACPI_HOTPLUG_MEMORY is not set
CONFIG_ACPI_HOTPLUG_IOAPIC=y
# CONFIG_ACPI_SBS is not set
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
CONFIG_HAVE_ACPI_APEI=y
CONFIG_HAVE_ACPI_APEI_NMI=y
# CONFIG_ACPI_APEI is not set
# CONFIG_ACPI_EXTLOG is not set
# CONFIG_PMIC_OPREGION is not set
CONFIG_SFI=y

#
# CPU Frequency scaling
#
# CONFIG_CPU_FREQ is not set

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
# CONFIG_INTEL_IDLE is not set

#
# Memory power savings
#
CONFIG_I7300_IDLE_IOAT_CHANNEL=y
CONFIG_I7300_IDLE=y

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
# CONFIG_PCI_MMCONFIG is not set
CONFIG_PCI_DOMAINS=y
# CONFIG_PCI_CNB20LE_QUIRK is not set
# CONFIG_PCIEPORTBUS is not set
CONFIG_PCI_BUS_ADDR_T_64BIT=y
# CONFIG_PCI_MSI is not set
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
# CONFIG_PCI_STUB is not set
CONFIG_HT_IRQ=y
# CONFIG_PCI_IOV is not set
# CONFIG_PCI_PRI is not set
# CONFIG_PCI_PASID is not set
CONFIG_PCI_LABEL=y
# CONFIG_HOTPLUG_PCI is not set

#
# PCI host controller drivers
#
# CONFIG_PCIE_DW_PLAT is not set
CONFIG_ISA_BUS=y
# CONFIG_ISA_DMA_API is not set
CONFIG_AMD_NB=y
CONFIG_PCCARD=y
# CONFIG_PCMCIA is not set
CONFIG_CARDBUS=y

#
# PC-card bridges
#
# CONFIG_YENTA is not set
# CONFIG_RAPIDIO is not set
CONFIG_X86_SYSFB=y

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_COMPAT_BINFMT_ELF=y
CONFIG_ELFCORE=y
CONFIG_BINFMT_SCRIPT=y
# CONFIG_HAVE_AOUT is not set
# CONFIG_BINFMT_MISC is not set
# CONFIG_COREDUMP is not set
CONFIG_IA32_EMULATION=y
CONFIG_IA32_AOUT=y
# CONFIG_X86_X32 is not set
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_SYSVIPC_COMPAT=y
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_PMC_ATOM=y
CONFIG_NET=y
CONFIG_COMPAT_NETLINK_MESSAGES=y

#
# Networking options
#
# CONFIG_PACKET is not set
CONFIG_UNIX=y
# CONFIG_UNIX_DIAG is not set
# CONFIG_NET_KEY is not set
# CONFIG_INET is not set
# CONFIG_NETWORK_SECMARK is not set
# CONFIG_NET_PTP_CLASSIFY is not set
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
# CONFIG_NETFILTER is not set
# CONFIG_ATM is not set
# CONFIG_BRIDGE is not set
# CONFIG_VLAN_8021Q is not set
# CONFIG_DECNET is not set
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_PHONET is not set
# CONFIG_IEEE802154 is not set
# CONFIG_NET_SCHED is not set
# CONFIG_DCB is not set
# CONFIG_BATMAN_ADV is not set
# CONFIG_VSOCKETS is not set
# CONFIG_NETLINK_DIAG is not set
# CONFIG_MPLS is not set
# CONFIG_HSR is not set
# CONFIG_SOCK_CGROUP_DATA is not set
# CONFIG_CGROUP_NET_PRIO is not set
# CONFIG_CGROUP_NET_CLASSID is not set
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y

#
# Network testing
#
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
# CONFIG_IRDA is not set
# CONFIG_BT is not set
CONFIG_WIRELESS=y
CONFIG_WEXT_CORE=y
CONFIG_WEXT_PROC=y
CONFIG_CFG80211=y
# CONFIG_NL80211_TESTMODE is not set
# CONFIG_CFG80211_DEVELOPER_WARNINGS is not set
# CONFIG_CFG80211_CERTIFICATION_ONUS is not set
CONFIG_CFG80211_DEFAULT_PS=y
# CONFIG_CFG80211_DEBUGFS is not set
# CONFIG_CFG80211_INTERNAL_REGDB is not set
CONFIG_CFG80211_CRDA_SUPPORT=y
CONFIG_CFG80211_WEXT=y
# CONFIG_LIB80211 is not set
CONFIG_MAC80211=y
CONFIG_MAC80211_HAS_RC=y
CONFIG_MAC80211_RC_MINSTREL=y
CONFIG_MAC80211_RC_MINSTREL_HT=y
# CONFIG_MAC80211_RC_MINSTREL_VHT is not set
CONFIG_MAC80211_RC_DEFAULT_MINSTREL=y
CONFIG_MAC80211_RC_DEFAULT="minstrel_ht"
CONFIG_MAC80211_MESH=y
CONFIG_MAC80211_LEDS=y
# CONFIG_MAC80211_DEBUGFS is not set
# CONFIG_MAC80211_MESSAGE_TRACING is not set
# CONFIG_MAC80211_DEBUG_MENU is not set
CONFIG_MAC80211_STA_HASH_MAX_SIZE=0
# CONFIG_WIMAX is not set
# CONFIG_RFKILL is not set
# CONFIG_RFKILL_REGULATOR is not set
# CONFIG_NET_9P is not set
# CONFIG_CAIF is not set
# CONFIG_NFC is not set
# CONFIG_LWTUNNEL is not set
# CONFIG_DST_CACHE is not set
# CONFIG_NET_DEVLINK is not set
CONFIG_MAY_USE_DEVLINK=y
CONFIG_HAVE_EBPF_JIT=y

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER=y
CONFIG_UEVENT_HELPER_PATH=""
CONFIG_DEVTMPFS=y
# CONFIG_DEVTMPFS_MOUNT is not set
# CONFIG_STANDALONE is not set
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=y
CONFIG_FIRMWARE_IN_KERNEL=y
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
CONFIG_FW_LOADER_USER_HELPER_FALLBACK=y
# CONFIG_ALLOW_DEV_COREDUMP is not set
# CONFIG_DEBUG_DRIVER is not set
CONFIG_DEBUG_DEVRES=y
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_SPMI=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
# CONFIG_DMA_SHARED_BUFFER is not set

#
# Bus devices
#
# CONFIG_CONNECTOR is not set
CONFIG_MTD=y
# CONFIG_MTD_REDBOOT_PARTS is not set
CONFIG_MTD_CMDLINE_PARTS=y
CONFIG_MTD_OF_PARTS=y
CONFIG_MTD_AR7_PARTS=y

#
# User Modules And Translation Layers
#
# CONFIG_MTD_OOPS is not set
CONFIG_MTD_PARTITIONED_MASTER=y

#
# RAM/ROM/Flash chip drivers
#
# CONFIG_MTD_CFI is not set
CONFIG_MTD_JEDECPROBE=y
CONFIG_MTD_GEN_PROBE=y
# CONFIG_MTD_CFI_ADV_OPTIONS is not set
CONFIG_MTD_MAP_BANK_WIDTH_1=y
CONFIG_MTD_MAP_BANK_WIDTH_2=y
CONFIG_MTD_MAP_BANK_WIDTH_4=y
# CONFIG_MTD_MAP_BANK_WIDTH_8 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_16 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_32 is not set
CONFIG_MTD_CFI_I1=y
CONFIG_MTD_CFI_I2=y
# CONFIG_MTD_CFI_I4 is not set
# CONFIG_MTD_CFI_I8 is not set
CONFIG_MTD_CFI_INTELEXT=y
CONFIG_MTD_CFI_AMDSTD=y
# CONFIG_MTD_CFI_STAA is not set
CONFIG_MTD_CFI_UTIL=y
CONFIG_MTD_RAM=y
CONFIG_MTD_ROM=y
# CONFIG_MTD_ABSENT is not set

#
# Mapping drivers for chip access
#
# CONFIG_MTD_COMPLEX_MAPPINGS is not set
CONFIG_MTD_PHYSMAP=y
# CONFIG_MTD_PHYSMAP_COMPAT is not set
CONFIG_MTD_PHYSMAP_OF=y
# CONFIG_MTD_PHYSMAP_OF_VERSATILE is not set
# CONFIG_MTD_AMD76XROM is not set
CONFIG_MTD_ICHXROM=y
# CONFIG_MTD_ESB2ROM is not set
# CONFIG_MTD_CK804XROM is not set
# CONFIG_MTD_SCB2_FLASH is not set
# CONFIG_MTD_NETtel is not set
CONFIG_MTD_L440GX=y
# CONFIG_MTD_INTEL_VR_NOR is not set
CONFIG_MTD_PLATRAM=y

#
# Self-contained MTD device drivers
#
# CONFIG_MTD_PMC551 is not set
# CONFIG_MTD_SLRAM is not set
# CONFIG_MTD_PHRAM is not set
# CONFIG_MTD_MTDRAM is not set

#
# Disk-On-Chip Device Drivers
#
CONFIG_MTD_DOCG3=y
CONFIG_BCH_CONST_M=14
CONFIG_BCH_CONST_T=4
CONFIG_MTD_NAND_ECC=y
# CONFIG_MTD_NAND_ECC_SMC is not set
CONFIG_MTD_NAND=y
CONFIG_MTD_NAND_BCH=y
CONFIG_MTD_NAND_ECC_BCH=y
# CONFIG_MTD_SM_COMMON is not set
# CONFIG_MTD_NAND_DENALI_PCI is not set
# CONFIG_MTD_NAND_GPIO is not set
# CONFIG_MTD_NAND_OMAP_BCH_BUILD is not set
CONFIG_MTD_NAND_IDS=y
# CONFIG_MTD_NAND_RICOH is not set
CONFIG_MTD_NAND_DISKONCHIP=y
# CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADVANCED is not set
CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADDRESS=0
CONFIG_MTD_NAND_DISKONCHIP_BBTWRITE=y
# CONFIG_MTD_NAND_DOCG4 is not set
# CONFIG_MTD_NAND_CAFE is not set
CONFIG_MTD_NAND_NANDSIM=y
CONFIG_MTD_NAND_PLATFORM=y
CONFIG_MTD_NAND_HISI504=y
CONFIG_MTD_ONENAND=y
# CONFIG_MTD_ONENAND_VERIFY_WRITE is not set
CONFIG_MTD_ONENAND_GENERIC=y
# CONFIG_MTD_ONENAND_OTP is not set
# CONFIG_MTD_ONENAND_2X_PROGRAM is not set

#
# LPDDR & LPDDR2 PCM memory drivers
#
# CONFIG_MTD_LPDDR is not set
# CONFIG_MTD_SPI_NOR is not set
CONFIG_MTD_UBI=y
CONFIG_MTD_UBI_WL_THRESHOLD=4096
CONFIG_MTD_UBI_BEB_LIMIT=20
CONFIG_MTD_UBI_FASTMAP=y
CONFIG_MTD_UBI_GLUEBI=y
CONFIG_OF=y
# CONFIG_OF_UNITTEST is not set
CONFIG_OF_ADDRESS=y
CONFIG_OF_ADDRESS_PCI=y
CONFIG_OF_IRQ=y
CONFIG_OF_PCI=y
CONFIG_OF_PCI_IRQ=y
CONFIG_OF_MTD=y
# CONFIG_OF_OVERLAY is not set
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
# CONFIG_PARPORT is not set
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_PNPACPI=y

#
# Misc devices
#
# CONFIG_SENSORS_LIS3LV02D is not set
CONFIG_AD525X_DPOT=y
CONFIG_AD525X_DPOT_I2C=y
CONFIG_DUMMY_IRQ=y
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
# CONFIG_SGI_IOC4 is not set
# CONFIG_TIFM_CORE is not set
CONFIG_ICS932S401=y
CONFIG_ENCLOSURE_SERVICES=y
# CONFIG_HP_ILO is not set
CONFIG_APDS9802ALS=y
CONFIG_ISL29003=y
CONFIG_ISL29020=y
CONFIG_SENSORS_TSL2550=y
CONFIG_SENSORS_BH1780=y
CONFIG_SENSORS_BH1770=y
# CONFIG_SENSORS_APDS990X is not set
CONFIG_HMC6352=y
CONFIG_DS1682=y
# CONFIG_BMP085_I2C is not set
# CONFIG_USB_SWITCH_FSA9480 is not set
# CONFIG_SRAM is not set
# CONFIG_C2PORT is not set

#
# EEPROM support
#
CONFIG_EEPROM_AT24=y
CONFIG_EEPROM_LEGACY=y
CONFIG_EEPROM_MAX6875=y
CONFIG_EEPROM_93CX6=y
# CONFIG_CB710_CORE is not set

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
# CONFIG_SENSORS_LIS3_I2C is not set

#
# Altera FPGA firmware download module
#
# CONFIG_ALTERA_STAPL is not set
# CONFIG_INTEL_MEI is not set
# CONFIG_INTEL_MEI_ME is not set
# CONFIG_INTEL_MEI_TXE is not set
# CONFIG_VMWARE_VMCI is not set

#
# Intel MIC Bus Driver
#
# CONFIG_INTEL_MIC_BUS is not set

#
# SCIF Bus Driver
#
# CONFIG_SCIF_BUS is not set

#
# VOP Bus Driver
#
# CONFIG_VOP_BUS is not set

#
# Intel MIC Host Driver
#

#
# Intel MIC Card Driver
#

#
# SCIF Driver
#

#
# Intel MIC Coprocessor State Management (COSM) Drivers
#

#
# VOP Driver
#
# CONFIG_GENWQE is not set
# CONFIG_ECHO is not set
# CONFIG_CXL_BASE is not set
# CONFIG_CXL_KERNEL_API is not set
# CONFIG_CXL_EEH is not set
CONFIG_HAVE_IDE=y

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
# CONFIG_SCSI_DMA is not set
# CONFIG_SCSI_NETLINK is not set
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
CONFIG_FIREWIRE=y
# CONFIG_FIREWIRE_OHCI is not set
# CONFIG_FIREWIRE_NOSY is not set
CONFIG_MACINTOSH_DRIVERS=y
# CONFIG_MAC_EMUMOUSEBTN is not set
# CONFIG_NETDEVICES is not set
# CONFIG_VHOST_NET is not set
CONFIG_VHOST_CROSS_ENDIAN_LEGACY=y

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_LEDS=y
# CONFIG_INPUT_FF_MEMLESS is not set
# CONFIG_INPUT_POLLDEV is not set
# CONFIG_INPUT_SPARSEKMAP is not set
# CONFIG_INPUT_MATRIXKMAP is not set

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
CONFIG_INPUT_MOUSEDEV_PSAUX=y
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
# CONFIG_INPUT_JOYDEV is not set
# CONFIG_INPUT_EVDEV is not set
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADP5588 is not set
# CONFIG_KEYBOARD_ADP5589 is not set
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1070 is not set
# CONFIG_KEYBOARD_QT2160 is not set
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_GPIO is not set
# CONFIG_KEYBOARD_GPIO_POLLED is not set
# CONFIG_KEYBOARD_TCA6416 is not set
# CONFIG_KEYBOARD_TCA8418 is not set
# CONFIG_KEYBOARD_MATRIX is not set
# CONFIG_KEYBOARD_LM8323 is not set
# CONFIG_KEYBOARD_LM8333 is not set
# CONFIG_KEYBOARD_MAX7359 is not set
# CONFIG_KEYBOARD_MCS is not set
# CONFIG_KEYBOARD_MPR121 is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_OPENCORES is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_STMPE is not set
# CONFIG_KEYBOARD_OMAP4 is not set
# CONFIG_KEYBOARD_TC3589X is not set
# CONFIG_KEYBOARD_TWL4030 is not set
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_KEYBOARD_CROS_EC is not set
# CONFIG_KEYBOARD_CAP11XX is not set
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_BYD=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
CONFIG_MOUSE_PS2_CYPRESS=y
CONFIG_MOUSE_PS2_TRACKPOINT=y
# CONFIG_MOUSE_PS2_ELANTECH is not set
# CONFIG_MOUSE_PS2_SENTELIC is not set
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
CONFIG_MOUSE_PS2_FOCALTECH=y
# CONFIG_MOUSE_PS2_VMMOUSE is not set
# CONFIG_MOUSE_SERIAL is not set
# CONFIG_MOUSE_APPLETOUCH is not set
# CONFIG_MOUSE_BCM5974 is not set
# CONFIG_MOUSE_CYAPA is not set
# CONFIG_MOUSE_ELAN_I2C is not set
# CONFIG_MOUSE_VSXXXAA is not set
# CONFIG_MOUSE_GPIO is not set
# CONFIG_MOUSE_SYNAPTICS_I2C is not set
# CONFIG_MOUSE_SYNAPTICS_USB is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
# CONFIG_INPUT_MISC is not set
# CONFIG_RMI4_CORE is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
CONFIG_SERIO_CT82C710=y
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=y
CONFIG_SERIO_ALTERA_PS2=y
CONFIG_SERIO_PS2MULT=y
# CONFIG_SERIO_ARC_PS2 is not set
CONFIG_SERIO_APBPS2=y
CONFIG_USERIO=y
# CONFIG_GAMEPORT is not set

#
# Character devices
#
CONFIG_TTY=y
# CONFIG_VT is not set
CONFIG_UNIX98_PTYS=y
# CONFIG_LEGACY_PTYS is not set
# CONFIG_SERIAL_NONSTANDARD is not set
# CONFIG_NOZOMI is not set
# CONFIG_N_GSM is not set
# CONFIG_TRACE_SINK is not set
CONFIG_DEVMEM=y
CONFIG_DEVKMEM=y

#
# Serial drivers
#
CONFIG_SERIAL_EARLYCON=y
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_DEPRECATED_OPTIONS=y
CONFIG_SERIAL_8250_PNP=y
# CONFIG_SERIAL_8250_FINTEK is not set
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set
# CONFIG_SERIAL_8250_FSL is not set
# CONFIG_SERIAL_8250_DW is not set
# CONFIG_SERIAL_8250_RT288X is not set
CONFIG_SERIAL_8250_MID=y
# CONFIG_SERIAL_8250_MOXA is not set
# CONFIG_SERIAL_OF_PLATFORM is not set

#
# Non-8250 serial port support
#
CONFIG_SERIAL_UARTLITE=y
# CONFIG_SERIAL_UARTLITE_CONSOLE is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
CONFIG_SERIAL_SCCNXP=y
CONFIG_SERIAL_SCCNXP_CONSOLE=y
CONFIG_SERIAL_SC16IS7XX_CORE=y
CONFIG_SERIAL_SC16IS7XX=y
CONFIG_SERIAL_SC16IS7XX_I2C=y
CONFIG_SERIAL_ALTERA_JTAGUART=y
CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE=y
# CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE_BYPASS is not set
CONFIG_SERIAL_ALTERA_UART=y
CONFIG_SERIAL_ALTERA_UART_MAXPORTS=4
CONFIG_SERIAL_ALTERA_UART_BAUDRATE=115200
# CONFIG_SERIAL_ALTERA_UART_CONSOLE is not set
# CONFIG_SERIAL_XILINX_PS_UART is not set
CONFIG_SERIAL_ARC=y
# CONFIG_SERIAL_ARC_CONSOLE is not set
CONFIG_SERIAL_ARC_NR_PORTS=1
# CONFIG_SERIAL_RP2 is not set
# CONFIG_SERIAL_FSL_LPUART is not set
# CONFIG_SERIAL_CONEXANT_DIGICOLOR is not set
# CONFIG_SERIAL_MEN_Z135 is not set
CONFIG_TTY_PRINTK=y
CONFIG_HVC_DRIVER=y
CONFIG_VIRTIO_CONSOLE=y
# CONFIG_IPMI_HANDLER is not set
CONFIG_HW_RANDOM=y
CONFIG_HW_RANDOM_TIMERIOMEM=y
CONFIG_HW_RANDOM_INTEL=y
CONFIG_HW_RANDOM_AMD=y
CONFIG_HW_RANDOM_VIA=y
CONFIG_HW_RANDOM_VIRTIO=y
CONFIG_HW_RANDOM_TPM=y
# CONFIG_NVRAM is not set
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set
# CONFIG_MWAVE is not set
# CONFIG_HPET is not set
CONFIG_HANGCHECK_TIMER=y
CONFIG_TCG_TPM=y
CONFIG_TCG_TIS=y
CONFIG_TCG_TIS_I2C_ATMEL=y
CONFIG_TCG_TIS_I2C_INFINEON=y
CONFIG_TCG_TIS_I2C_NUVOTON=y
CONFIG_TCG_NSC=y
# CONFIG_TCG_ATMEL is not set
# CONFIG_TCG_INFINEON is not set
# CONFIG_TCG_CRB is not set
CONFIG_TCG_TIS_ST33ZP24=y
CONFIG_TCG_TIS_ST33ZP24_I2C=y
# CONFIG_TELCLOCK is not set
CONFIG_DEVPORT=y
# CONFIG_XILLYBUS is not set

#
# I2C support
#
CONFIG_I2C=y
CONFIG_ACPI_I2C_OPREGION=y
CONFIG_I2C_BOARDINFO=y
# CONFIG_I2C_COMPAT is not set
CONFIG_I2C_CHARDEV=y
CONFIG_I2C_MUX=y

#
# Multiplexer I2C Chip support
#
CONFIG_I2C_ARB_GPIO_CHALLENGE=y
CONFIG_I2C_MUX_GPIO=y
CONFIG_I2C_MUX_PCA9541=y
CONFIG_I2C_MUX_PCA954x=y
# CONFIG_I2C_MUX_REG is not set
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_SMBUS=y
CONFIG_I2C_ALGOBIT=y
CONFIG_I2C_ALGOPCA=y

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
# CONFIG_I2C_ALI1535 is not set
# CONFIG_I2C_ALI1563 is not set
# CONFIG_I2C_ALI15X3 is not set
# CONFIG_I2C_AMD756 is not set
# CONFIG_I2C_AMD8111 is not set
# CONFIG_I2C_I801 is not set
# CONFIG_I2C_ISCH is not set
# CONFIG_I2C_ISMT is not set
# CONFIG_I2C_PIIX4 is not set
# CONFIG_I2C_NFORCE2 is not set
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
# CONFIG_I2C_SIS96X is not set
# CONFIG_I2C_VIA is not set
# CONFIG_I2C_VIAPRO is not set

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
# CONFIG_I2C_CBUS_GPIO is not set
# CONFIG_I2C_DESIGNWARE_PCI is not set
# CONFIG_I2C_GPIO is not set
CONFIG_I2C_KEMPLD=y
# CONFIG_I2C_OCORES is not set
CONFIG_I2C_PCA_PLATFORM=y
# CONFIG_I2C_PXA_PCI is not set
CONFIG_I2C_SIMTEC=y
CONFIG_I2C_XILINX=y

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_DIOLAN_U2C=y
CONFIG_I2C_PARPORT_LIGHT=y
CONFIG_I2C_ROBOTFUZZ_OSIF=y
CONFIG_I2C_TAOS_EVM=y
CONFIG_I2C_TINY_USB=y
CONFIG_I2C_VIPERBOARD=y

#
# Other I2C/SMBus bus drivers
#
# CONFIG_I2C_CROS_EC_TUNNEL is not set
CONFIG_I2C_SLAVE=y
# CONFIG_I2C_SLAVE_EEPROM is not set
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_SPI is not set
CONFIG_SPMI=y
CONFIG_HSI=y
CONFIG_HSI_BOARDINFO=y

#
# HSI controllers
#

#
# HSI clients
#
# CONFIG_HSI_CHAR is not set

#
# PPS support
#
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set

#
# PPS clients support
#
# CONFIG_PPS_CLIENT_KTIMER is not set
CONFIG_PPS_CLIENT_LDISC=y
CONFIG_PPS_CLIENT_GPIO=y

#
# PPS generators support
#

#
# PTP clock support
#
# CONFIG_PTP_1588_CLOCK is not set

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
CONFIG_GPIOLIB=y
CONFIG_GPIO_DEVRES=y
CONFIG_OF_GPIO=y
CONFIG_GPIO_ACPI=y
CONFIG_GPIOLIB_IRQCHIP=y
CONFIG_DEBUG_GPIO=y
# CONFIG_GPIO_SYSFS is not set
CONFIG_GPIO_GENERIC=y
CONFIG_GPIO_MAX730X=y

#
# Memory mapped GPIO drivers
#
CONFIG_GPIO_74XX_MMIO=y
CONFIG_GPIO_ALTERA=y
# CONFIG_GPIO_AMDPT is not set
# CONFIG_GPIO_DWAPB is not set
# CONFIG_GPIO_GENERIC_PLATFORM is not set
# CONFIG_GPIO_GRGPIO is not set
# CONFIG_GPIO_ICH is not set
CONFIG_GPIO_LYNXPOINT=y
CONFIG_GPIO_MENZ127=y
# CONFIG_GPIO_SYSCON is not set
# CONFIG_GPIO_VX855 is not set
CONFIG_GPIO_XILINX=y
# CONFIG_GPIO_ZX is not set

#
# Port-mapped I/O GPIO drivers
#
CONFIG_GPIO_104_DIO_48E=y
CONFIG_GPIO_104_IDIO_16=y
CONFIG_GPIO_104_IDI_48=y
CONFIG_GPIO_F7188X=y
CONFIG_GPIO_IT87=y
# CONFIG_GPIO_SCH is not set
CONFIG_GPIO_SCH311X=y
# CONFIG_GPIO_WS16C48 is not set

#
# I2C GPIO expanders
#
CONFIG_GPIO_ADP5588=y
# CONFIG_GPIO_ADP5588_IRQ is not set
CONFIG_GPIO_ADNP=y
CONFIG_GPIO_MAX7300=y
CONFIG_GPIO_MAX732X=y
# CONFIG_GPIO_MAX732X_IRQ is not set
# CONFIG_GPIO_PCA953X is not set
CONFIG_GPIO_PCF857X=y
CONFIG_GPIO_SX150X=y
CONFIG_GPIO_TPIC2810=y

#
# MFD GPIO expanders
#
CONFIG_GPIO_DA9052=y
# CONFIG_GPIO_DA9055 is not set
CONFIG_GPIO_KEMPLD=y
CONFIG_GPIO_LP3943=y
CONFIG_GPIO_PALMAS=y
# CONFIG_GPIO_RC5T583 is not set
CONFIG_GPIO_STMPE=y
CONFIG_GPIO_TC3589X=y
CONFIG_GPIO_TPS65086=y
CONFIG_GPIO_TPS6586X=y
CONFIG_GPIO_TPS65910=y
CONFIG_GPIO_TPS65912=y
CONFIG_GPIO_TWL4030=y
# CONFIG_GPIO_WM831X is not set

#
# PCI GPIO expanders
#
# CONFIG_GPIO_AMD8111 is not set
# CONFIG_GPIO_BT8XX is not set
# CONFIG_GPIO_INTEL_MID is not set
# CONFIG_GPIO_ML_IOH is not set
# CONFIG_GPIO_RDC321X is not set
# CONFIG_GPIO_SODAVILLE is not set

#
# SPI or I2C GPIO expanders
#
CONFIG_GPIO_MCP23S08=y

#
# USB GPIO expanders
#
CONFIG_GPIO_VIPERBOARD=y
CONFIG_W1=y

#
# 1-wire Bus Masters
#
# CONFIG_W1_MASTER_MATROX is not set
CONFIG_W1_MASTER_DS2490=y
CONFIG_W1_MASTER_DS2482=y
CONFIG_W1_MASTER_DS1WM=y
# CONFIG_W1_MASTER_GPIO is not set

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=y
CONFIG_W1_SLAVE_SMEM=y
CONFIG_W1_SLAVE_DS2408=y
CONFIG_W1_SLAVE_DS2408_READBACK=y
# CONFIG_W1_SLAVE_DS2413 is not set
# CONFIG_W1_SLAVE_DS2406 is not set
CONFIG_W1_SLAVE_DS2423=y
CONFIG_W1_SLAVE_DS2431=y
CONFIG_W1_SLAVE_DS2433=y
CONFIG_W1_SLAVE_DS2433_CRC=y
CONFIG_W1_SLAVE_DS2760=y
# CONFIG_W1_SLAVE_DS2780 is not set
# CONFIG_W1_SLAVE_DS2781 is not set
# CONFIG_W1_SLAVE_DS28E04 is not set
CONFIG_W1_SLAVE_BQ27000=y
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
# CONFIG_PDA_POWER is not set
# CONFIG_GENERIC_ADC_BATTERY is not set
# CONFIG_WM831X_BACKUP is not set
# CONFIG_WM831X_POWER is not set
# CONFIG_TEST_POWER is not set
# CONFIG_BATTERY_ACT8945A is not set
# CONFIG_BATTERY_DS2760 is not set
# CONFIG_BATTERY_DS2780 is not set
# CONFIG_BATTERY_DS2781 is not set
# CONFIG_BATTERY_DS2782 is not set
# CONFIG_BATTERY_SBS is not set
# CONFIG_BATTERY_BQ27XXX is not set
# CONFIG_BATTERY_DA9030 is not set
# CONFIG_BATTERY_DA9052 is not set
# CONFIG_CHARGER_DA9150 is not set
# CONFIG_BATTERY_DA9150 is not set
# CONFIG_BATTERY_MAX17040 is not set
# CONFIG_BATTERY_MAX17042 is not set
# CONFIG_BATTERY_TWL4030_MADC is not set
# CONFIG_CHARGER_PCF50633 is not set
# CONFIG_BATTERY_RX51 is not set
# CONFIG_CHARGER_ISP1704 is not set
# CONFIG_CHARGER_MAX8903 is not set
# CONFIG_CHARGER_TWL4030 is not set
# CONFIG_CHARGER_LP8727 is not set
# CONFIG_CHARGER_GPIO is not set
# CONFIG_CHARGER_MANAGER is not set
# CONFIG_CHARGER_MAX14577 is not set
# CONFIG_CHARGER_BQ2415X is not set
# CONFIG_CHARGER_BQ24190 is not set
# CONFIG_CHARGER_BQ24257 is not set
# CONFIG_CHARGER_BQ24735 is not set
# CONFIG_CHARGER_BQ25890 is not set
# CONFIG_CHARGER_SMB347 is not set
# CONFIG_CHARGER_TPS65217 is not set
# CONFIG_BATTERY_GAUGE_LTC2941 is not set
# CONFIG_CHARGER_RT9455 is not set
# CONFIG_POWER_RESET is not set
CONFIG_POWER_AVS=y
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
CONFIG_SENSORS_AD7414=y
CONFIG_SENSORS_AD7418=y
# CONFIG_SENSORS_ADM1021 is not set
# CONFIG_SENSORS_ADM1025 is not set
CONFIG_SENSORS_ADM1026=y
# CONFIG_SENSORS_ADM1029 is not set
# CONFIG_SENSORS_ADM1031 is not set
CONFIG_SENSORS_ADM9240=y
CONFIG_SENSORS_ADT7X10=y
CONFIG_SENSORS_ADT7410=y
CONFIG_SENSORS_ADT7411=y
# CONFIG_SENSORS_ADT7462 is not set
# CONFIG_SENSORS_ADT7470 is not set
# CONFIG_SENSORS_ADT7475 is not set
# CONFIG_SENSORS_ASC7621 is not set
# CONFIG_SENSORS_K8TEMP is not set
# CONFIG_SENSORS_K10TEMP is not set
# CONFIG_SENSORS_FAM15H_POWER is not set
# CONFIG_SENSORS_APPLESMC is not set
# CONFIG_SENSORS_ASB100 is not set
# CONFIG_SENSORS_ATXP1 is not set
CONFIG_SENSORS_DS620=y
CONFIG_SENSORS_DS1621=y
CONFIG_SENSORS_DELL_SMM=y
CONFIG_SENSORS_DA9052_ADC=y
# CONFIG_SENSORS_DA9055 is not set
# CONFIG_SENSORS_I5K_AMB is not set
# CONFIG_SENSORS_F71805F is not set
CONFIG_SENSORS_F71882FG=y
# CONFIG_SENSORS_F75375S is not set
CONFIG_SENSORS_FSCHMD=y
CONFIG_SENSORS_GL518SM=y
CONFIG_SENSORS_GL520SM=y
# CONFIG_SENSORS_G760A is not set
CONFIG_SENSORS_G762=y
# CONFIG_SENSORS_GPIO_FAN is not set
CONFIG_SENSORS_HIH6130=y
CONFIG_SENSORS_IIO_HWMON=y
# CONFIG_SENSORS_I5500 is not set
CONFIG_SENSORS_CORETEMP=y
# CONFIG_SENSORS_IT87 is not set
# CONFIG_SENSORS_JC42 is not set
CONFIG_SENSORS_POWR1220=y
# CONFIG_SENSORS_LINEAGE is not set
CONFIG_SENSORS_LTC2945=y
CONFIG_SENSORS_LTC2990=y
CONFIG_SENSORS_LTC4151=y
# CONFIG_SENSORS_LTC4215 is not set
# CONFIG_SENSORS_LTC4222 is not set
CONFIG_SENSORS_LTC4245=y
# CONFIG_SENSORS_LTC4260 is not set
CONFIG_SENSORS_LTC4261=y
CONFIG_SENSORS_MAX16065=y
CONFIG_SENSORS_MAX1619=y
CONFIG_SENSORS_MAX1668=y
CONFIG_SENSORS_MAX197=y
# CONFIG_SENSORS_MAX6639 is not set
# CONFIG_SENSORS_MAX6642 is not set
# CONFIG_SENSORS_MAX6650 is not set
CONFIG_SENSORS_MAX6697=y
# CONFIG_SENSORS_MAX31790 is not set
# CONFIG_SENSORS_MCP3021 is not set
CONFIG_SENSORS_MENF21BMC_HWMON=y
# CONFIG_SENSORS_LM63 is not set
# CONFIG_SENSORS_LM73 is not set
CONFIG_SENSORS_LM75=y
CONFIG_SENSORS_LM77=y
CONFIG_SENSORS_LM78=y
CONFIG_SENSORS_LM80=y
# CONFIG_SENSORS_LM83 is not set
CONFIG_SENSORS_LM85=y
CONFIG_SENSORS_LM87=y
# CONFIG_SENSORS_LM90 is not set
# CONFIG_SENSORS_LM92 is not set
# CONFIG_SENSORS_LM93 is not set
# CONFIG_SENSORS_LM95234 is not set
# CONFIG_SENSORS_LM95241 is not set
# CONFIG_SENSORS_LM95245 is not set
# CONFIG_SENSORS_PC87360 is not set
# CONFIG_SENSORS_PC87427 is not set
# CONFIG_SENSORS_NTC_THERMISTOR is not set
CONFIG_SENSORS_NCT6683=y
# CONFIG_SENSORS_NCT6775 is not set
CONFIG_SENSORS_NCT7802=y
CONFIG_SENSORS_NCT7904=y
# CONFIG_SENSORS_PCF8591 is not set
# CONFIG_PMBUS is not set
# CONFIG_SENSORS_PWM_FAN is not set
CONFIG_SENSORS_SHT15=y
# CONFIG_SENSORS_SHT21 is not set
# CONFIG_SENSORS_SHTC1 is not set
# CONFIG_SENSORS_SIS5595 is not set
CONFIG_SENSORS_DME1737=y
CONFIG_SENSORS_EMC1403=y
CONFIG_SENSORS_EMC2103=y
CONFIG_SENSORS_EMC6W201=y
CONFIG_SENSORS_SMSC47M1=y
# CONFIG_SENSORS_SMSC47M192 is not set
# CONFIG_SENSORS_SMSC47B397 is not set
# CONFIG_SENSORS_SCH56XX_COMMON is not set
# CONFIG_SENSORS_SMM665 is not set
# CONFIG_SENSORS_ADC128D818 is not set
# CONFIG_SENSORS_ADS1015 is not set
CONFIG_SENSORS_ADS7828=y
# CONFIG_SENSORS_AMC6821 is not set
CONFIG_SENSORS_INA209=y
CONFIG_SENSORS_INA2XX=y
CONFIG_SENSORS_TC74=y
CONFIG_SENSORS_THMC50=y
CONFIG_SENSORS_TMP102=y
CONFIG_SENSORS_TMP103=y
CONFIG_SENSORS_TMP401=y
# CONFIG_SENSORS_TMP421 is not set
CONFIG_SENSORS_TWL4030_MADC=y
# CONFIG_SENSORS_VIA_CPUTEMP is not set
# CONFIG_SENSORS_VIA686A is not set
CONFIG_SENSORS_VT1211=y
# CONFIG_SENSORS_VT8231 is not set
CONFIG_SENSORS_W83781D=y
# CONFIG_SENSORS_W83791D is not set
CONFIG_SENSORS_W83792D=y
CONFIG_SENSORS_W83793=y
CONFIG_SENSORS_W83795=y
# CONFIG_SENSORS_W83795_FANCTRL is not set
CONFIG_SENSORS_W83L785TS=y
CONFIG_SENSORS_W83L786NG=y
CONFIG_SENSORS_W83627HF=y
# CONFIG_SENSORS_W83627EHF is not set
# CONFIG_SENSORS_WM831X is not set

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
CONFIG_THERMAL_HWMON=y
CONFIG_THERMAL_OF=y
# CONFIG_THERMAL_WRITABLE_TRIPS is not set
CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE=y
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_THERMAL_DEFAULT_GOV_POWER_ALLOCATOR is not set
# CONFIG_THERMAL_GOV_FAIR_SHARE is not set
CONFIG_THERMAL_GOV_STEP_WISE=y
# CONFIG_THERMAL_GOV_BANG_BANG is not set
# CONFIG_THERMAL_GOV_USER_SPACE is not set
# CONFIG_THERMAL_GOV_POWER_ALLOCATOR is not set
# CONFIG_THERMAL_EMULATION is not set
# CONFIG_INTEL_POWERCLAMP is not set
# CONFIG_INTEL_SOC_DTS_THERMAL is not set

#
# ACPI INT340X thermal drivers
#
# CONFIG_INT340X_THERMAL is not set
CONFIG_INTEL_PCH_THERMAL=y
# CONFIG_QCOM_SPMI_TEMP_ALARM is not set
# CONFIG_GENERIC_ADC_THERMAL is not set
# CONFIG_WATCHDOG is not set
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
CONFIG_SSB=y
CONFIG_SSB_SPROM=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
CONFIG_SSB_PCIHOST=y
# CONFIG_SSB_B43_PCI_BRIDGE is not set
# CONFIG_SSB_SILENT is not set
CONFIG_SSB_DEBUG=y
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
# CONFIG_SSB_DRIVER_PCICORE is not set
# CONFIG_SSB_DRIVER_GPIO is not set
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
# CONFIG_BCMA is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
CONFIG_MFD_ACT8945A=y
# CONFIG_MFD_AS3711 is not set
# CONFIG_MFD_AS3722 is not set
# CONFIG_PMIC_ADP5520 is not set
# CONFIG_MFD_AAT2870_CORE is not set
# CONFIG_MFD_ATMEL_FLEXCOM is not set
CONFIG_MFD_ATMEL_HLCDC=y
CONFIG_MFD_BCM590XX=y
# CONFIG_MFD_AXP20X_I2C is not set
CONFIG_MFD_CROS_EC=y
CONFIG_MFD_CROS_EC_I2C=y
CONFIG_PMIC_DA903X=y
CONFIG_PMIC_DA9052=y
CONFIG_MFD_DA9052_I2C=y
CONFIG_MFD_DA9055=y
# CONFIG_MFD_DA9062 is not set
CONFIG_MFD_DA9063=y
CONFIG_MFD_DA9150=y
# CONFIG_MFD_DLN2 is not set
# CONFIG_MFD_MC13XXX_I2C is not set
CONFIG_MFD_HI6421_PMIC=y
CONFIG_HTC_PASIC3=y
CONFIG_HTC_I2CPLD=y
# CONFIG_LPC_ICH is not set
# CONFIG_LPC_SCH is not set
# CONFIG_INTEL_SOC_PMIC is not set
# CONFIG_MFD_INTEL_LPSS_ACPI is not set
# CONFIG_MFD_INTEL_LPSS_PCI is not set
# CONFIG_MFD_JANZ_CMODIO is not set
CONFIG_MFD_KEMPLD=y
# CONFIG_MFD_88PM800 is not set
CONFIG_MFD_88PM805=y
# CONFIG_MFD_88PM860X is not set
CONFIG_MFD_MAX14577=y
# CONFIG_MFD_MAX77620 is not set
CONFIG_MFD_MAX77686=y
# CONFIG_MFD_MAX77693 is not set
CONFIG_MFD_MAX77843=y
CONFIG_MFD_MAX8907=y
# CONFIG_MFD_MAX8925 is not set
# CONFIG_MFD_MAX8997 is not set
# CONFIG_MFD_MAX8998 is not set
# CONFIG_MFD_MT6397 is not set
CONFIG_MFD_MENF21BMC=y
CONFIG_MFD_VIPERBOARD=y
CONFIG_MFD_RETU=y
CONFIG_MFD_PCF50633=y
CONFIG_PCF50633_ADC=y
CONFIG_PCF50633_GPIO=y
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_RTSX_PCI is not set
# CONFIG_MFD_RT5033 is not set
# CONFIG_MFD_RTSX_USB is not set
CONFIG_MFD_RC5T583=y
CONFIG_MFD_RK808=y
CONFIG_MFD_RN5T618=y
# CONFIG_MFD_SEC_CORE is not set
# CONFIG_MFD_SI476X_CORE is not set
CONFIG_MFD_SM501=y
CONFIG_MFD_SM501_GPIO=y
CONFIG_MFD_SKY81452=y
# CONFIG_MFD_SMSC is not set
CONFIG_ABX500_CORE=y
CONFIG_AB3100_CORE=y
# CONFIG_AB3100_OTP is not set
CONFIG_MFD_STMPE=y

#
# STMicroelectronics STMPE Interface Drivers
#
# CONFIG_STMPE_I2C is not set
CONFIG_MFD_SYSCON=y
CONFIG_MFD_TI_AM335X_TSCADC=y
CONFIG_MFD_LP3943=y
CONFIG_MFD_LP8788=y
CONFIG_MFD_PALMAS=y
CONFIG_TPS6105X=y
# CONFIG_TPS65010 is not set
CONFIG_TPS6507X=y
CONFIG_MFD_TPS65086=y
# CONFIG_MFD_TPS65090 is not set
CONFIG_MFD_TPS65217=y
# CONFIG_MFD_TPS65218 is not set
CONFIG_MFD_TPS6586X=y
CONFIG_MFD_TPS65910=y
CONFIG_MFD_TPS65912=y
CONFIG_MFD_TPS65912_I2C=y
# CONFIG_MFD_TPS80031 is not set
CONFIG_TWL4030_CORE=y
# CONFIG_MFD_TWL4030_AUDIO is not set
# CONFIG_TWL6040_CORE is not set
CONFIG_MFD_WL1273_CORE=y
# CONFIG_MFD_LM3533 is not set
CONFIG_MFD_TC3589X=y
# CONFIG_MFD_TMIO is not set
# CONFIG_MFD_VX855 is not set
# CONFIG_MFD_ARIZONA_I2C is not set
# CONFIG_MFD_WM8400 is not set
CONFIG_MFD_WM831X=y
CONFIG_MFD_WM831X_I2C=y
# CONFIG_MFD_WM8350_I2C is not set
# CONFIG_MFD_WM8994 is not set
CONFIG_REGULATOR=y
# CONFIG_REGULATOR_DEBUG is not set
CONFIG_REGULATOR_FIXED_VOLTAGE=y
CONFIG_REGULATOR_VIRTUAL_CONSUMER=y
CONFIG_REGULATOR_USERSPACE_CONSUMER=y
CONFIG_REGULATOR_ACT8865=y
CONFIG_REGULATOR_ACT8945A=y
# CONFIG_REGULATOR_AD5398 is not set
CONFIG_REGULATOR_ANATOP=y
CONFIG_REGULATOR_AB3100=y
CONFIG_REGULATOR_BCM590XX=y
CONFIG_REGULATOR_DA903X=y
# CONFIG_REGULATOR_DA9052 is not set
# CONFIG_REGULATOR_DA9055 is not set
CONFIG_REGULATOR_DA9063=y
CONFIG_REGULATOR_DA9210=y
# CONFIG_REGULATOR_DA9211 is not set
CONFIG_REGULATOR_FAN53555=y
CONFIG_REGULATOR_GPIO=y
CONFIG_REGULATOR_HI6421=y
CONFIG_REGULATOR_ISL9305=y
# CONFIG_REGULATOR_ISL6271A is not set
CONFIG_REGULATOR_LP3971=y
CONFIG_REGULATOR_LP3972=y
CONFIG_REGULATOR_LP872X=y
CONFIG_REGULATOR_LP8755=y
CONFIG_REGULATOR_LP8788=y
CONFIG_REGULATOR_LTC3589=y
# CONFIG_REGULATOR_MAX14577 is not set
CONFIG_REGULATOR_MAX1586=y
CONFIG_REGULATOR_MAX8649=y
# CONFIG_REGULATOR_MAX8660 is not set
# CONFIG_REGULATOR_MAX8907 is not set
CONFIG_REGULATOR_MAX8952=y
# CONFIG_REGULATOR_MAX8973 is not set
CONFIG_REGULATOR_MAX77686=y
# CONFIG_REGULATOR_MAX77693 is not set
CONFIG_REGULATOR_MAX77802=y
CONFIG_REGULATOR_MT6311=y
CONFIG_REGULATOR_PALMAS=y
CONFIG_REGULATOR_PCF50633=y
CONFIG_REGULATOR_PFUZE100=y
CONFIG_REGULATOR_PV88060=y
CONFIG_REGULATOR_PV88080=y
# CONFIG_REGULATOR_PV88090 is not set
# CONFIG_REGULATOR_PWM is not set
# CONFIG_REGULATOR_QCOM_SPMI is not set
# CONFIG_REGULATOR_RC5T583 is not set
CONFIG_REGULATOR_RK808=y
# CONFIG_REGULATOR_RN5T618 is not set
CONFIG_REGULATOR_SKY81452=y
CONFIG_REGULATOR_TPS51632=y
CONFIG_REGULATOR_TPS6105X=y
# CONFIG_REGULATOR_TPS62360 is not set
CONFIG_REGULATOR_TPS65023=y
CONFIG_REGULATOR_TPS6507X=y
CONFIG_REGULATOR_TPS65086=y
# CONFIG_REGULATOR_TPS65217 is not set
# CONFIG_REGULATOR_TPS6586X is not set
CONFIG_REGULATOR_TPS65910=y
CONFIG_REGULATOR_TPS65912=y
# CONFIG_REGULATOR_TWL4030 is not set
CONFIG_REGULATOR_WM831X=y
CONFIG_MEDIA_SUPPORT=y

#
# Multimedia core support
#
# CONFIG_MEDIA_CAMERA_SUPPORT is not set
# CONFIG_MEDIA_ANALOG_TV_SUPPORT is not set
CONFIG_MEDIA_DIGITAL_TV_SUPPORT=y
CONFIG_MEDIA_RADIO_SUPPORT=y
# CONFIG_MEDIA_SDR_SUPPORT is not set
# CONFIG_MEDIA_RC_SUPPORT is not set
# CONFIG_MEDIA_CONTROLLER is not set
CONFIG_VIDEO_DEV=y
CONFIG_VIDEO_V4L2=y
CONFIG_VIDEO_ADV_DEBUG=y
CONFIG_VIDEO_FIXED_MINOR_RANGES=y
CONFIG_DVB_CORE=y
# CONFIG_TTPCI_EEPROM is not set
CONFIG_DVB_MAX_ADAPTERS=8
# CONFIG_DVB_DYNAMIC_MINORS is not set

#
# Media drivers
#
# CONFIG_MEDIA_USB_SUPPORT is not set
# CONFIG_MEDIA_PCI_SUPPORT is not set
# CONFIG_DVB_PLATFORM_DRIVERS is not set

#
# Supported MMC/SDIO adapters
#
# CONFIG_RADIO_ADAPTERS is not set

#
# Supported FireWire (IEEE 1394) Adapters
#
CONFIG_DVB_FIREDTV=y
CONFIG_DVB_FIREDTV_INPUT=y
# CONFIG_CYPRESS_FIRMWARE is not set

#
# Media ancillary drivers (tuners, sensors, i2c, frontends)
#
CONFIG_MEDIA_SUBDRV_AUTOSELECT=y

#
# Audio decoders, processors and mixers
#

#
# RDS decoders
#

#
# Video decoders
#

#
# Video and audio decoders
#

#
# Video encoders
#

#
# Camera sensor devices
#

#
# Flash devices
#

#
# Video improvement chips
#

#
# Audio/Video compression chips
#

#
# Miscellaneous helper chips
#

#
# Sensors used on soc_camera driver
#
CONFIG_MEDIA_TUNER=y
CONFIG_MEDIA_TUNER_SIMPLE=y
CONFIG_MEDIA_TUNER_TDA8290=y
CONFIG_MEDIA_TUNER_TDA827X=y
CONFIG_MEDIA_TUNER_TDA18271=y
CONFIG_MEDIA_TUNER_TDA9887=y
CONFIG_MEDIA_TUNER_TEA5761=y
CONFIG_MEDIA_TUNER_TEA5767=y
CONFIG_MEDIA_TUNER_MT20XX=y
CONFIG_MEDIA_TUNER_XC2028=y
CONFIG_MEDIA_TUNER_XC5000=y
CONFIG_MEDIA_TUNER_XC4000=y
CONFIG_MEDIA_TUNER_MC44S803=y

#
# Multistandard (satellite) frontends
#

#
# Multistandard (cable + terrestrial) frontends
#

#
# DVB-S (satellite) frontends
#

#
# DVB-T (terrestrial) frontends
#
# CONFIG_DVB_AS102_FE is not set

#
# DVB-C (cable) frontends
#

#
# ATSC (North American/Korean Terrestrial/Cable DTV) frontends
#

#
# ISDB-T (terrestrial) frontends
#

#
# ISDB-S (satellite) & ISDB-T (terrestrial) frontends
#

#
# Digital terrestrial only tuners/PLL
#

#
# SEC control devices for DVB-S
#

#
# Tools to develop new frontends
#
# CONFIG_DVB_DUMMY_FE is not set

#
# Graphics support
#
# CONFIG_AGP is not set
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
# CONFIG_DRM is not set

#
# ACP (Audio CoProcessor) Configuration
#

#
# Frame buffer Devices
#
# CONFIG_FB is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=y
CONFIG_LCD_PLATFORM=y
CONFIG_BACKLIGHT_CLASS_DEVICE=y
CONFIG_BACKLIGHT_GENERIC=y
CONFIG_BACKLIGHT_PWM=y
# CONFIG_BACKLIGHT_DA903X is not set
CONFIG_BACKLIGHT_DA9052=y
# CONFIG_BACKLIGHT_APPLE is not set
# CONFIG_BACKLIGHT_PM8941_WLED is not set
CONFIG_BACKLIGHT_SAHARA=y
CONFIG_BACKLIGHT_WM831X=y
CONFIG_BACKLIGHT_ADP8860=y
CONFIG_BACKLIGHT_ADP8870=y
# CONFIG_BACKLIGHT_PCF50633 is not set
# CONFIG_BACKLIGHT_LM3630A is not set
# CONFIG_BACKLIGHT_LM3639 is not set
CONFIG_BACKLIGHT_LP855X=y
CONFIG_BACKLIGHT_LP8788=y
CONFIG_BACKLIGHT_PANDORA=y
CONFIG_BACKLIGHT_SKY81452=y
CONFIG_BACKLIGHT_TPS65217=y
CONFIG_BACKLIGHT_GPIO=y
CONFIG_BACKLIGHT_LV5207LP=y
CONFIG_BACKLIGHT_BD6107=y
# CONFIG_VGASTATE is not set
# CONFIG_SOUND is not set

#
# HID support
#
CONFIG_HID=y
# CONFIG_HID_BATTERY_STRENGTH is not set
# CONFIG_HIDRAW is not set
# CONFIG_UHID is not set
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
# CONFIG_HID_A4TECH is not set
# CONFIG_HID_ACRUX is not set
# CONFIG_HID_APPLE is not set
# CONFIG_HID_APPLEIR is not set
# CONFIG_HID_AUREAL is not set
# CONFIG_HID_BELKIN is not set
# CONFIG_HID_BETOP_FF is not set
# CONFIG_HID_CHERRY is not set
# CONFIG_HID_CHICONY is not set
# CONFIG_HID_CORSAIR is not set
# CONFIG_HID_CMEDIA is not set
# CONFIG_HID_CP2112 is not set
# CONFIG_HID_CYPRESS is not set
# CONFIG_HID_DRAGONRISE is not set
# CONFIG_HID_EMS_FF is not set
# CONFIG_HID_ELECOM is not set
# CONFIG_HID_ELO is not set
# CONFIG_HID_EZKEY is not set
# CONFIG_HID_GEMBIRD is not set
# CONFIG_HID_GFRM is not set
# CONFIG_HID_HOLTEK is not set
# CONFIG_HID_GT683R is not set
# CONFIG_HID_KEYTOUCH is not set
# CONFIG_HID_KYE is not set
# CONFIG_HID_UCLOGIC is not set
# CONFIG_HID_WALTOP is not set
# CONFIG_HID_GYRATION is not set
# CONFIG_HID_ICADE is not set
# CONFIG_HID_TWINHAN is not set
# CONFIG_HID_KENSINGTON is not set
# CONFIG_HID_LCPOWER is not set
# CONFIG_HID_LENOVO is not set
# CONFIG_HID_LOGITECH is not set
# CONFIG_HID_MAGICMOUSE is not set
# CONFIG_HID_MICROSOFT is not set
# CONFIG_HID_MONTEREY is not set
# CONFIG_HID_MULTITOUCH is not set
# CONFIG_HID_NTRIG is not set
# CONFIG_HID_ORTEK is not set
# CONFIG_HID_PANTHERLORD is not set
# CONFIG_HID_PENMOUNT is not set
# CONFIG_HID_PETALYNX is not set
# CONFIG_HID_PICOLCD is not set
# CONFIG_HID_PLANTRONICS is not set
# CONFIG_HID_PRIMAX is not set
# CONFIG_HID_ROCCAT is not set
# CONFIG_HID_SAITEK is not set
# CONFIG_HID_SAMSUNG is not set
# CONFIG_HID_SONY is not set
# CONFIG_HID_SPEEDLINK is not set
# CONFIG_HID_STEELSERIES is not set
# CONFIG_HID_SUNPLUS is not set
# CONFIG_HID_RMI is not set
# CONFIG_HID_GREENASIA is not set
# CONFIG_HID_SMARTJOYPLUS is not set
# CONFIG_HID_TIVO is not set
# CONFIG_HID_TOPSEED is not set
# CONFIG_HID_THINGM is not set
# CONFIG_HID_THRUSTMASTER is not set
# CONFIG_HID_WACOM is not set
# CONFIG_HID_WIIMOTE is not set
# CONFIG_HID_XINMO is not set
# CONFIG_HID_ZEROPLUS is not set
# CONFIG_HID_ZYDACRON is not set
# CONFIG_HID_SENSOR_HUB is not set

#
# USB HID support
#
CONFIG_USB_HID=y
# CONFIG_HID_PID is not set
# CONFIG_USB_HIDDEV is not set

#
# I2C HID support
#
# CONFIG_I2C_HID is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=y
# CONFIG_USB_ANNOUNCE_NEW_DEVICES is not set

#
# Miscellaneous USB options
#
# CONFIG_USB_DEFAULT_PERSIST is not set
CONFIG_USB_DYNAMIC_MINORS=y
# CONFIG_USB_OTG is not set
# CONFIG_USB_OTG_WHITELIST is not set
# CONFIG_USB_OTG_BLACKLIST_HUB is not set
# CONFIG_USB_ULPI_BUS is not set
# CONFIG_USB_MON is not set
CONFIG_USB_WUSB=y
CONFIG_USB_WUSB_CBAF=y
# CONFIG_USB_WUSB_CBAF_DEBUG is not set

#
# USB Host Controller Drivers
#
CONFIG_USB_C67X00_HCD=y
CONFIG_USB_XHCI_HCD=y
CONFIG_USB_XHCI_PCI=y
CONFIG_USB_XHCI_PLATFORM=y
CONFIG_USB_EHCI_HCD=y
CONFIG_USB_EHCI_ROOT_HUB_TT=y
# CONFIG_USB_EHCI_TT_NEWSCHED is not set
CONFIG_USB_EHCI_PCI=y
# CONFIG_USB_EHCI_HCD_PLATFORM is not set
CONFIG_USB_OXU210HP_HCD=y
# CONFIG_USB_ISP116X_HCD is not set
CONFIG_USB_ISP1362_HCD=y
CONFIG_USB_FOTG210_HCD=y
# CONFIG_USB_OHCI_HCD is not set
# CONFIG_USB_UHCI_HCD is not set
CONFIG_USB_U132_HCD=y
CONFIG_USB_SL811_HCD=y
# CONFIG_USB_SL811_HCD_ISO is not set
CONFIG_USB_R8A66597_HCD=y
# CONFIG_USB_WHCI_HCD is not set
CONFIG_USB_HWA_HCD=y
# CONFIG_USB_HCD_SSB is not set
CONFIG_USB_HCD_TEST_MODE=y

#
# USB Device Class drivers
#
CONFIG_USB_ACM=y
CONFIG_USB_PRINTER=y
# CONFIG_USB_WDM is not set
CONFIG_USB_TMC=y

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#

#
# USB Imaging devices
#
CONFIG_USB_MDC800=y
# CONFIG_USBIP_CORE is not set
CONFIG_USB_MUSB_HDRC=y
CONFIG_USB_MUSB_HOST=y
# CONFIG_USB_MUSB_GADGET is not set
# CONFIG_USB_MUSB_DUAL_ROLE is not set

#
# Platform Glue Layer
#

#
# MUSB DMA mode
#
CONFIG_MUSB_PIO_ONLY=y
CONFIG_USB_DWC3=y
CONFIG_USB_DWC3_HOST=y
# CONFIG_USB_DWC3_GADGET is not set
# CONFIG_USB_DWC3_DUAL_ROLE is not set

#
# Platform Glue Driver Support
#
CONFIG_USB_DWC3_PCI=y
# CONFIG_USB_DWC2 is not set
CONFIG_USB_CHIPIDEA=y
CONFIG_USB_CHIPIDEA_OF=y
CONFIG_USB_CHIPIDEA_PCI=y
# CONFIG_USB_CHIPIDEA_UDC is not set
CONFIG_USB_CHIPIDEA_HOST=y
# CONFIG_USB_ISP1760 is not set

#
# USB port drivers
#
CONFIG_USB_SERIAL=y
CONFIG_USB_SERIAL_CONSOLE=y
CONFIG_USB_SERIAL_GENERIC=y
# CONFIG_USB_SERIAL_SIMPLE is not set
# CONFIG_USB_SERIAL_AIRCABLE is not set
# CONFIG_USB_SERIAL_ARK3116 is not set
# CONFIG_USB_SERIAL_BELKIN is not set
CONFIG_USB_SERIAL_CH341=y
CONFIG_USB_SERIAL_WHITEHEAT=y
# CONFIG_USB_SERIAL_DIGI_ACCELEPORT is not set
CONFIG_USB_SERIAL_CP210X=y
# CONFIG_USB_SERIAL_CYPRESS_M8 is not set
CONFIG_USB_SERIAL_EMPEG=y
# CONFIG_USB_SERIAL_FTDI_SIO is not set
CONFIG_USB_SERIAL_VISOR=y
# CONFIG_USB_SERIAL_IPAQ is not set
# CONFIG_USB_SERIAL_IR is not set
# CONFIG_USB_SERIAL_EDGEPORT is not set
CONFIG_USB_SERIAL_EDGEPORT_TI=y
CONFIG_USB_SERIAL_F81232=y
CONFIG_USB_SERIAL_GARMIN=y
CONFIG_USB_SERIAL_IPW=y
CONFIG_USB_SERIAL_IUU=y
CONFIG_USB_SERIAL_KEYSPAN_PDA=y
CONFIG_USB_SERIAL_KEYSPAN=y
CONFIG_USB_SERIAL_KEYSPAN_MPR=y
CONFIG_USB_SERIAL_KEYSPAN_USA28=y
CONFIG_USB_SERIAL_KEYSPAN_USA28X=y
CONFIG_USB_SERIAL_KEYSPAN_USA28XA=y
# CONFIG_USB_SERIAL_KEYSPAN_USA28XB is not set
# CONFIG_USB_SERIAL_KEYSPAN_USA19 is not set
# CONFIG_USB_SERIAL_KEYSPAN_USA18X is not set
# CONFIG_USB_SERIAL_KEYSPAN_USA19W is not set
# CONFIG_USB_SERIAL_KEYSPAN_USA19QW is not set
# CONFIG_USB_SERIAL_KEYSPAN_USA19QI is not set
# CONFIG_USB_SERIAL_KEYSPAN_USA49W is not set
CONFIG_USB_SERIAL_KEYSPAN_USA49WLC=y
# CONFIG_USB_SERIAL_KLSI is not set
CONFIG_USB_SERIAL_KOBIL_SCT=y
CONFIG_USB_SERIAL_MCT_U232=y
# CONFIG_USB_SERIAL_METRO is not set
CONFIG_USB_SERIAL_MOS7720=y
CONFIG_USB_SERIAL_MOS7840=y
CONFIG_USB_SERIAL_MXUPORT=y
# CONFIG_USB_SERIAL_NAVMAN is not set
CONFIG_USB_SERIAL_PL2303=y
CONFIG_USB_SERIAL_OTI6858=y
CONFIG_USB_SERIAL_QCAUX=y
CONFIG_USB_SERIAL_QUALCOMM=y
CONFIG_USB_SERIAL_SPCP8X5=y
CONFIG_USB_SERIAL_SAFE=y
# CONFIG_USB_SERIAL_SAFE_PADDED is not set
CONFIG_USB_SERIAL_SIERRAWIRELESS=y
CONFIG_USB_SERIAL_SYMBOL=y
# CONFIG_USB_SERIAL_TI is not set
CONFIG_USB_SERIAL_CYBERJACK=y
CONFIG_USB_SERIAL_XIRCOM=y
CONFIG_USB_SERIAL_WWAN=y
# CONFIG_USB_SERIAL_OPTION is not set
# CONFIG_USB_SERIAL_OMNINET is not set
# CONFIG_USB_SERIAL_OPTICON is not set
CONFIG_USB_SERIAL_XSENS_MT=y
CONFIG_USB_SERIAL_WISHBONE=y
CONFIG_USB_SERIAL_SSU100=y
# CONFIG_USB_SERIAL_QT2 is not set
# CONFIG_USB_SERIAL_DEBUG is not set

#
# USB Miscellaneous drivers
#
CONFIG_USB_EMI62=y
CONFIG_USB_EMI26=y
CONFIG_USB_ADUTUX=y
CONFIG_USB_SEVSEG=y
CONFIG_USB_RIO500=y
# CONFIG_USB_LEGOTOWER is not set
CONFIG_USB_LCD=y
# CONFIG_USB_LED is not set
# CONFIG_USB_CYPRESS_CY7C63 is not set
CONFIG_USB_CYTHERM=y
CONFIG_USB_IDMOUSE=y
CONFIG_USB_FTDI_ELAN=y
CONFIG_USB_APPLEDISPLAY=y
# CONFIG_USB_SISUSBVGA is not set
CONFIG_USB_LD=y
CONFIG_USB_TRANCEVIBRATOR=y
CONFIG_USB_IOWARRIOR=y
CONFIG_USB_TEST=y
CONFIG_USB_EHSET_TEST_FIXTURE=y
CONFIG_USB_ISIGHTFW=y
CONFIG_USB_YUREX=y
CONFIG_USB_EZUSB_FX2=y
CONFIG_USB_HSIC_USB3503=y
# CONFIG_USB_LINK_LAYER_TEST is not set
CONFIG_USB_CHAOSKEY=y
# CONFIG_UCSI is not set

#
# USB Physical Layer drivers
#
CONFIG_USB_PHY=y
CONFIG_NOP_USB_XCEIV=y
# CONFIG_USB_GPIO_VBUS is not set
CONFIG_TAHVO_USB=y
# CONFIG_TAHVO_USB_HOST_BY_DEFAULT is not set
CONFIG_USB_ISP1301=y
CONFIG_USB_GADGET=y
# CONFIG_USB_GADGET_DEBUG is not set
# CONFIG_USB_GADGET_DEBUG_FILES is not set
CONFIG_USB_GADGET_DEBUG_FS=y
CONFIG_USB_GADGET_VBUS_DRAW=2
CONFIG_USB_GADGET_STORAGE_NUM_BUFFERS=2

#
# USB Peripheral Controller
#
# CONFIG_USB_FOTG210_UDC is not set
CONFIG_USB_GR_UDC=y
# CONFIG_USB_R8A66597 is not set
CONFIG_USB_PXA27X=y
# CONFIG_USB_MV_UDC is not set
CONFIG_USB_MV_U3D=y
CONFIG_USB_M66592=y
# CONFIG_USB_BDC_UDC is not set
# CONFIG_USB_AMD5536UDC is not set
# CONFIG_USB_NET2272 is not set
# CONFIG_USB_NET2280 is not set
# CONFIG_USB_GOKU is not set
# CONFIG_USB_EG20T is not set
# CONFIG_USB_GADGET_XILINX is not set
# CONFIG_USB_DUMMY_HCD is not set
CONFIG_USB_LIBCOMPOSITE=y
CONFIG_USB_F_PRINTER=y
# CONFIG_USB_CONFIGFS is not set
# CONFIG_USB_ZERO is not set
# CONFIG_USB_ETH is not set
# CONFIG_USB_G_NCM is not set
# CONFIG_USB_GADGETFS is not set
# CONFIG_USB_FUNCTIONFS is not set
# CONFIG_USB_G_SERIAL is not set
CONFIG_USB_G_PRINTER=y
# CONFIG_USB_CDC_COMPOSITE is not set
# CONFIG_USB_G_HID is not set
# CONFIG_USB_G_DBGP is not set
# CONFIG_USB_G_WEBCAM is not set
# CONFIG_USB_LED_TRIG is not set
CONFIG_UWB=y
CONFIG_UWB_HWA=y
# CONFIG_UWB_WHCI is not set
# CONFIG_UWB_I1480U is not set
# CONFIG_MMC is not set
CONFIG_MEMSTICK=y
# CONFIG_MEMSTICK_DEBUG is not set

#
# MemoryStick drivers
#
CONFIG_MEMSTICK_UNSAFE_RESUME=y

#
# MemoryStick Host Controller Drivers
#
# CONFIG_MEMSTICK_TIFM_MS is not set
# CONFIG_MEMSTICK_JMICRON_38X is not set
# CONFIG_MEMSTICK_R592 is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y
# CONFIG_LEDS_CLASS_FLASH is not set

#
# LED drivers
#
CONFIG_LEDS_BCM6328=y
CONFIG_LEDS_BCM6358=y
# CONFIG_LEDS_LM3530 is not set
CONFIG_LEDS_LM3642=y
# CONFIG_LEDS_PCA9532 is not set
CONFIG_LEDS_GPIO=y
CONFIG_LEDS_LP3944=y
CONFIG_LEDS_LP55XX_COMMON=y
# CONFIG_LEDS_LP5521 is not set
# CONFIG_LEDS_LP5523 is not set
# CONFIG_LEDS_LP5562 is not set
CONFIG_LEDS_LP8501=y
CONFIG_LEDS_LP8788=y
CONFIG_LEDS_LP8860=y
CONFIG_LEDS_PCA955X=y
CONFIG_LEDS_PCA963X=y
CONFIG_LEDS_WM831X_STATUS=y
CONFIG_LEDS_DA903X=y
CONFIG_LEDS_DA9052=y
CONFIG_LEDS_PWM=y
CONFIG_LEDS_REGULATOR=y
# CONFIG_LEDS_BD2802 is not set
# CONFIG_LEDS_LT3593 is not set
# CONFIG_LEDS_TCA6507 is not set
CONFIG_LEDS_TLC591XX=y
CONFIG_LEDS_LM355x=y
CONFIG_LEDS_MENF21BMC=y
CONFIG_LEDS_IS31FL32XX=y

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
CONFIG_LEDS_BLINKM=y
# CONFIG_LEDS_SYSCON is not set

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
# CONFIG_LEDS_TRIGGER_TIMER is not set
# CONFIG_LEDS_TRIGGER_ONESHOT is not set
# CONFIG_LEDS_TRIGGER_MTD is not set
# CONFIG_LEDS_TRIGGER_HEARTBEAT is not set
# CONFIG_LEDS_TRIGGER_BACKLIGHT is not set
# CONFIG_LEDS_TRIGGER_CPU is not set
# CONFIG_LEDS_TRIGGER_GPIO is not set
# CONFIG_LEDS_TRIGGER_DEFAULT_ON is not set

#
# iptables trigger is under Netfilter config (LED target)
#
# CONFIG_LEDS_TRIGGER_TRANSIENT is not set
# CONFIG_LEDS_TRIGGER_CAMERA is not set
# CONFIG_LEDS_TRIGGER_PANIC is not set
# CONFIG_ACCESSIBILITY is not set
CONFIG_EDAC_ATOMIC_SCRUB=y
CONFIG_EDAC_SUPPORT=y
CONFIG_EDAC=y
CONFIG_EDAC_LEGACY_SYSFS=y
CONFIG_EDAC_DEBUG=y
# CONFIG_EDAC_MM_EDAC is not set
CONFIG_RTC_LIB=y
# CONFIG_RTC_CLASS is not set
# CONFIG_DMADEVICES is not set

#
# DMABUF options
#
# CONFIG_SYNC_FILE is not set
CONFIG_AUXDISPLAY=y
# CONFIG_UIO is not set
CONFIG_VIRT_DRIVERS=y
CONFIG_VIRTIO=y

#
# Virtio drivers
#
# CONFIG_VIRTIO_PCI is not set
# CONFIG_VIRTIO_BALLOON is not set
# CONFIG_VIRTIO_INPUT is not set
CONFIG_VIRTIO_MMIO=y
CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES=y

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
# CONFIG_STAGING is not set
# CONFIG_X86_PLATFORM_DEVICES is not set
CONFIG_CHROME_PLATFORMS=y
CONFIG_CHROMEOS_PSTORE=y
# CONFIG_CROS_EC_CHARDEV is not set
CONFIG_CROS_EC_LPC=y
CONFIG_CROS_EC_PROTO=y
# CONFIG_CROS_KBD_LED_BACKLIGHT is not set

#
# Hardware Spinlock drivers
#

#
# Clock Source drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_CLKBLD_I8253=y
# CONFIG_ATMEL_PIT is not set
# CONFIG_SH_TIMER_CMT is not set
# CONFIG_SH_TIMER_MTU2 is not set
# CONFIG_SH_TIMER_TMU is not set
# CONFIG_EM_TIMER_STI is not set
CONFIG_MAILBOX=y
# CONFIG_PCC is not set
CONFIG_ALTERA_MBOX=y
# CONFIG_MAILBOX_TEST is not set
CONFIG_IOMMU_SUPPORT=y

#
# Generic IOMMU Pagetable Support
#
# CONFIG_AMD_IOMMU is not set

#
# Remoteproc drivers
#
CONFIG_REMOTEPROC=y
CONFIG_STE_MODEM_RPROC=y

#
# Rpmsg drivers
#

#
# SOC (System On Chip) specific Drivers
#
# CONFIG_SUNXI_SRAM is not set
# CONFIG_SOC_TI is not set
# CONFIG_PM_DEVFREQ is not set
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
# CONFIG_EXTCON_ADC_JACK is not set
CONFIG_EXTCON_GPIO=y
CONFIG_EXTCON_MAX14577=y
# CONFIG_EXTCON_MAX3355 is not set
# CONFIG_EXTCON_MAX77843 is not set
CONFIG_EXTCON_PALMAS=y
CONFIG_EXTCON_RT8973A=y
CONFIG_EXTCON_SM5502=y
CONFIG_EXTCON_USB_GPIO=y
CONFIG_MEMORY=y
CONFIG_IIO=y
CONFIG_IIO_BUFFER=y
# CONFIG_IIO_BUFFER_CB is not set
CONFIG_IIO_KFIFO_BUF=y
CONFIG_IIO_TRIGGERED_BUFFER=y
CONFIG_IIO_CONFIGFS=y
CONFIG_IIO_TRIGGER=y
CONFIG_IIO_CONSUMERS_PER_TRIGGER=2
CONFIG_IIO_SW_TRIGGER=y

#
# Accelerometers
#
# CONFIG_BMA180 is not set
CONFIG_BMC150_ACCEL=y
CONFIG_BMC150_ACCEL_I2C=y
CONFIG_IIO_ST_ACCEL_3AXIS=y
CONFIG_IIO_ST_ACCEL_I2C_3AXIS=y
CONFIG_KXCJK1013=y
CONFIG_MMA7455=y
CONFIG_MMA7455_I2C=y
CONFIG_MMA8452=y
CONFIG_MMA9551_CORE=y
# CONFIG_MMA9551 is not set
CONFIG_MMA9553=y
CONFIG_MXC4005=y
CONFIG_MXC6255=y
CONFIG_STK8312=y
CONFIG_STK8BA50=y

#
# Analog to digital converters
#
CONFIG_AD7291=y
# CONFIG_AD799X is not set
CONFIG_DA9150_GPADC=y
# CONFIG_LP8788_ADC is not set
# CONFIG_MAX1363 is not set
CONFIG_MCP3422=y
CONFIG_MEN_Z188_ADC=y
CONFIG_NAU7802=y
CONFIG_PALMAS_GPADC=y
CONFIG_QCOM_SPMI_IADC=y
# CONFIG_QCOM_SPMI_VADC is not set
# CONFIG_TI_ADC081C is not set
CONFIG_TI_ADS1015=y
CONFIG_TI_AM335X_ADC=y
CONFIG_TWL4030_MADC=y
CONFIG_TWL6030_GPADC=y
# CONFIG_VF610_ADC is not set
CONFIG_VIPERBOARD_ADC=y

#
# Amplifiers
#

#
# Chemical Sensors
#
# CONFIG_ATLAS_PH_SENSOR is not set
CONFIG_IAQCORE=y
# CONFIG_VZ89X is not set

#
# Hid Sensor IIO Common
#
CONFIG_IIO_MS_SENSORS_I2C=y

#
# SSP Sensor Common
#
CONFIG_IIO_ST_SENSORS_I2C=y
CONFIG_IIO_ST_SENSORS_CORE=y

#
# Digital to analog converters
#
CONFIG_AD5064=y
CONFIG_AD5380=y
# CONFIG_AD5446 is not set
CONFIG_AD5592R_BASE=y
CONFIG_AD5593R=y
# CONFIG_M62332 is not set
# CONFIG_MAX517 is not set
CONFIG_MAX5821=y
CONFIG_MCP4725=y
CONFIG_STX104=y
CONFIG_VF610_DAC=y

#
# IIO dummy driver
#
CONFIG_IIO_SIMPLE_DUMMY=y
# CONFIG_IIO_SIMPLE_DUMMY_EVENTS is not set
# CONFIG_IIO_SIMPLE_DUMMY_BUFFER is not set

#
# Frequency Synthesizers DDS/PLL
#

#
# Clock Generator/Distribution
#

#
# Phase-Locked Loop (PLL) frequency synthesizers
#

#
# Digital gyroscope sensors
#
# CONFIG_BMG160 is not set
# CONFIG_IIO_ST_GYRO_3AXIS is not set
CONFIG_ITG3200=y

#
# Health Sensors
#

#
# Heart Rate Monitors
#
# CONFIG_AFE4404 is not set
CONFIG_MAX30100=y

#
# Humidity sensors
#
CONFIG_AM2315=y
CONFIG_DHT11=y
# CONFIG_HDC100X is not set
CONFIG_HTU21=y
CONFIG_SI7005=y
CONFIG_SI7020=y

#
# Inertial measurement units
#
CONFIG_BMI160=y
CONFIG_BMI160_I2C=y
# CONFIG_KMX61 is not set
CONFIG_INV_MPU6050_IIO=y
CONFIG_INV_MPU6050_I2C=y

#
# Light sensors
#
# CONFIG_ACPI_ALS is not set
CONFIG_ADJD_S311=y
# CONFIG_AL3320A is not set
CONFIG_APDS9300=y
# CONFIG_APDS9960 is not set
CONFIG_BH1750=y
CONFIG_CM32181=y
CONFIG_CM3232=y
# CONFIG_CM3323 is not set
CONFIG_CM36651=y
CONFIG_GP2AP020A00F=y
CONFIG_ISL29125=y
CONFIG_JSA1212=y
CONFIG_RPR0521=y
CONFIG_LTR501=y
CONFIG_MAX44000=y
CONFIG_OPT3001=y
# CONFIG_PA12203001 is not set
CONFIG_STK3310=y
CONFIG_TCS3414=y
CONFIG_TCS3472=y
CONFIG_SENSORS_TSL2563=y
# CONFIG_TSL4531 is not set
# CONFIG_US5182D is not set
# CONFIG_VCNL4000 is not set
# CONFIG_VEML6070 is not set

#
# Magnetometer sensors
#
# CONFIG_AK8975 is not set
# CONFIG_AK09911 is not set
# CONFIG_BMC150_MAGN_I2C is not set
CONFIG_MAG3110=y
CONFIG_MMC35240=y
CONFIG_IIO_ST_MAGN_3AXIS=y
CONFIG_IIO_ST_MAGN_I2C_3AXIS=y
CONFIG_SENSORS_HMC5843=y
CONFIG_SENSORS_HMC5843_I2C=y

#
# Inclinometer sensors
#

#
# Triggers - standalone
#
CONFIG_IIO_HRTIMER_TRIGGER=y
# CONFIG_IIO_INTERRUPT_TRIGGER is not set
# CONFIG_IIO_SYSFS_TRIGGER is not set

#
# Digital potentiometers
#
CONFIG_DS1803=y
CONFIG_MCP4531=y
CONFIG_TPL0102=y

#
# Pressure sensors
#
# CONFIG_BMP280 is not set
CONFIG_HP03=y
# CONFIG_MPL115_I2C is not set
CONFIG_MPL3115=y
CONFIG_MS5611=y
# CONFIG_MS5611_I2C is not set
CONFIG_MS5637=y
CONFIG_IIO_ST_PRESS=y
CONFIG_IIO_ST_PRESS_I2C=y
CONFIG_T5403=y
# CONFIG_HP206C is not set

#
# Lightning sensors
#

#
# Proximity sensors
#
CONFIG_LIDAR_LITE_V2=y
CONFIG_SX9500=y

#
# Temperature sensors
#
CONFIG_MLX90614=y
CONFIG_TMP006=y
# CONFIG_TSYS01 is not set
CONFIG_TSYS02D=y
# CONFIG_NTB is not set
# CONFIG_VME_BUS is not set
CONFIG_PWM=y
CONFIG_PWM_SYSFS=y
CONFIG_PWM_FSL_FTM=y
CONFIG_PWM_LP3943=y
# CONFIG_PWM_LPSS_PCI is not set
# CONFIG_PWM_LPSS_PLATFORM is not set
# CONFIG_PWM_PCA9685 is not set
# CONFIG_PWM_TWL is not set
CONFIG_PWM_TWL_LED=y
CONFIG_IRQCHIP=y
CONFIG_ARM_GIC_MAX_NR=1
CONFIG_IPACK_BUS=y
# CONFIG_BOARD_TPCI200 is not set
CONFIG_SERIAL_IPOCTAL=y
# CONFIG_RESET_CONTROLLER is not set
CONFIG_FMC=y
CONFIG_FMC_FAKEDEV=y
CONFIG_FMC_TRIVIAL=y
CONFIG_FMC_WRITE_EEPROM=y
CONFIG_FMC_CHARDEV=y

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
CONFIG_PHY_PXA_28NM_HSIC=y
CONFIG_PHY_PXA_28NM_USB2=y
CONFIG_BCM_KONA_USB2_PHY=y
CONFIG_POWERCAP=y
CONFIG_MCB=y
# CONFIG_MCB_PCI is not set

#
# Performance monitor support
#
CONFIG_RAS=y
# CONFIG_THUNDERBOLT is not set

#
# Android
#
CONFIG_ANDROID=y
# CONFIG_ANDROID_BINDER_IPC is not set
CONFIG_NVMEM=y
CONFIG_STM=y
CONFIG_STM_DUMMY=y
# CONFIG_STM_SOURCE_CONSOLE is not set
# CONFIG_STM_SOURCE_HEARTBEAT is not set
CONFIG_INTEL_TH=y
# CONFIG_INTEL_TH_PCI is not set
CONFIG_INTEL_TH_GTH=y
CONFIG_INTEL_TH_STH=y
CONFIG_INTEL_TH_MSU=y
CONFIG_INTEL_TH_PTI=y
# CONFIG_INTEL_TH_DEBUG is not set

#
# FPGA Configuration Support
#
CONFIG_FPGA=y
CONFIG_FPGA_MGR_ZYNQ_FPGA=y

#
# Firmware Drivers
#
CONFIG_EDD=y
# CONFIG_EDD_OFF is not set
CONFIG_FIRMWARE_MEMMAP=y
CONFIG_DELL_RBU=y
CONFIG_DCDBAS=y
# CONFIG_ISCSI_IBFT_FIND is not set
CONFIG_FW_CFG_SYSFS=y
CONFIG_FW_CFG_SYSFS_CMDLINE=y
# CONFIG_GOOGLE_FIRMWARE is not set

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_FILE_LOCKING=y
CONFIG_MANDATORY_FILE_LOCKING=y
CONFIG_FSNOTIFY=y
# CONFIG_DNOTIFY is not set
CONFIG_INOTIFY_USER=y
CONFIG_FANOTIFY=y
CONFIG_FANOTIFY_ACCESS_PERMISSIONS=y
CONFIG_QUOTA=y
# CONFIG_QUOTA_NETLINK_INTERFACE is not set
# CONFIG_PRINT_QUOTA_WARNING is not set
CONFIG_QUOTA_DEBUG=y
CONFIG_QUOTA_TREE=y
CONFIG_QFMT_V1=y
CONFIG_QFMT_V2=y
CONFIG_QUOTACTL=y
CONFIG_QUOTACTL_COMPAT=y
# CONFIG_AUTOFS4_FS is not set
CONFIG_FUSE_FS=y
# CONFIG_CUSE is not set
CONFIG_OVERLAY_FS=y

#
# Caches
#
CONFIG_FSCACHE=y
# CONFIG_FSCACHE_STATS is not set
# CONFIG_FSCACHE_HISTOGRAM is not set
CONFIG_FSCACHE_DEBUG=y
# CONFIG_FSCACHE_OBJECT_LIST is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
# CONFIG_PROC_KCORE is not set
CONFIG_PROC_VMCORE=y
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_PROC_CHILDREN=y
CONFIG_KERNFS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_TMPFS_XATTR=y
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_CONFIGFS_FS=y
CONFIG_MISC_FILESYSTEMS=y
CONFIG_ORANGEFS_FS=y
# CONFIG_JFFS2_FS is not set
CONFIG_UBIFS_FS=y
CONFIG_UBIFS_FS_ADVANCED_COMPR=y
CONFIG_UBIFS_FS_LZO=y
# CONFIG_UBIFS_FS_ZLIB is not set
# CONFIG_UBIFS_ATIME_SUPPORT is not set
# CONFIG_LOGFS is not set
CONFIG_ROMFS_FS=y
CONFIG_ROMFS_BACKED_BY_MTD=y
CONFIG_ROMFS_ON_MTD=y
CONFIG_PSTORE=y
# CONFIG_PSTORE_CONSOLE is not set
CONFIG_PSTORE_PMSG=y
# CONFIG_PSTORE_RAM is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
# CONFIG_NLS_CODEPAGE_437 is not set
CONFIG_NLS_CODEPAGE_737=y
CONFIG_NLS_CODEPAGE_775=y
# CONFIG_NLS_CODEPAGE_850 is not set
CONFIG_NLS_CODEPAGE_852=y
CONFIG_NLS_CODEPAGE_855=y
CONFIG_NLS_CODEPAGE_857=y
CONFIG_NLS_CODEPAGE_860=y
# CONFIG_NLS_CODEPAGE_861 is not set
CONFIG_NLS_CODEPAGE_862=y
CONFIG_NLS_CODEPAGE_863=y
# CONFIG_NLS_CODEPAGE_864 is not set
CONFIG_NLS_CODEPAGE_865=y
# CONFIG_NLS_CODEPAGE_866 is not set
# CONFIG_NLS_CODEPAGE_869 is not set
# CONFIG_NLS_CODEPAGE_936 is not set
CONFIG_NLS_CODEPAGE_950=y
CONFIG_NLS_CODEPAGE_932=y
CONFIG_NLS_CODEPAGE_949=y
# CONFIG_NLS_CODEPAGE_874 is not set
CONFIG_NLS_ISO8859_8=y
# CONFIG_NLS_CODEPAGE_1250 is not set
CONFIG_NLS_CODEPAGE_1251=y
CONFIG_NLS_ASCII=y
CONFIG_NLS_ISO8859_1=y
CONFIG_NLS_ISO8859_2=y
CONFIG_NLS_ISO8859_3=y
# CONFIG_NLS_ISO8859_4 is not set
# CONFIG_NLS_ISO8859_5 is not set
CONFIG_NLS_ISO8859_6=y
# CONFIG_NLS_ISO8859_7 is not set
CONFIG_NLS_ISO8859_9=y
CONFIG_NLS_ISO8859_13=y
# CONFIG_NLS_ISO8859_14 is not set
# CONFIG_NLS_ISO8859_15 is not set
CONFIG_NLS_KOI8_R=y
# CONFIG_NLS_KOI8_U is not set
# CONFIG_NLS_MAC_ROMAN is not set
CONFIG_NLS_MAC_CELTIC=y
CONFIG_NLS_MAC_CENTEURO=y
# CONFIG_NLS_MAC_CROATIAN is not set
CONFIG_NLS_MAC_CYRILLIC=y
# CONFIG_NLS_MAC_GAELIC is not set
# CONFIG_NLS_MAC_GREEK is not set
CONFIG_NLS_MAC_ICELAND=y
CONFIG_NLS_MAC_INUIT=y
CONFIG_NLS_MAC_ROMANIAN=y
# CONFIG_NLS_MAC_TURKISH is not set
CONFIG_NLS_UTF8=y

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=y
CONFIG_MESSAGE_LOGLEVEL_DEFAULT=4
# CONFIG_BOOT_PRINTK_DELAY is not set
# CONFIG_DYNAMIC_DEBUG is not set

#
# Compile-time checks and compiler options
#
# CONFIG_DEBUG_INFO is not set
# CONFIG_ENABLE_WARN_DEPRECATED is not set
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=8192
CONFIG_STRIP_ASM_SYMS=y
CONFIG_READABLE_ASM=y
CONFIG_UNUSED_SYMBOLS=y
# CONFIG_PAGE_OWNER is not set
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
# CONFIG_DEBUG_SECTION_MISMATCH is not set
CONFIG_SECTION_MISMATCH_WARN_ONLY=y
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
CONFIG_STACK_VALIDATION=y
CONFIG_DEBUG_FORCE_WEAK_PER_CPU=y
# CONFIG_MAGIC_SYSRQ is not set
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
CONFIG_PAGE_EXTENSION=y
# CONFIG_DEBUG_PAGEALLOC is not set
CONFIG_PAGE_POISONING=y
# CONFIG_PAGE_POISONING_NO_SANITY is not set
# CONFIG_PAGE_POISONING_ZERO is not set
CONFIG_DEBUG_OBJECTS=y
CONFIG_DEBUG_OBJECTS_SELFTEST=y
# CONFIG_DEBUG_OBJECTS_FREE is not set
CONFIG_DEBUG_OBJECTS_TIMERS=y
# CONFIG_DEBUG_OBJECTS_WORK is not set
CONFIG_DEBUG_OBJECTS_RCU_HEAD=y
# CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER is not set
CONFIG_DEBUG_OBJECTS_ENABLE_DEFAULT=1
CONFIG_SLUB_DEBUG_ON=y
CONFIG_SLUB_STATS=y
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
CONFIG_DEBUG_STACK_USAGE=y
# CONFIG_DEBUG_VM is not set
# CONFIG_DEBUG_VIRTUAL is not set
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_MEMORY_NOTIFIER_ERROR_INJECT=y
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
CONFIG_DEBUG_STACKOVERFLOW=y
CONFIG_HAVE_ARCH_KMEMCHECK=y
# CONFIG_KMEMCHECK is not set
CONFIG_HAVE_ARCH_KASAN=y
CONFIG_KASAN=y
CONFIG_KASAN_OUTLINE=y
# CONFIG_KASAN_INLINE is not set
CONFIG_ARCH_HAS_KCOV=y
CONFIG_KCOV=y
CONFIG_DEBUG_SHIRQ=y

#
# Debug Lockups and Hangs
#
CONFIG_LOCKUP_DETECTOR=y
CONFIG_HARDLOCKUP_DETECTOR=y
# CONFIG_BOOTPARAM_HARDLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC_VALUE=0
# CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=0
CONFIG_DETECT_HUNG_TASK=y
CONFIG_DEFAULT_HUNG_TASK_TIMEOUT=120
# CONFIG_BOOTPARAM_HUNG_TASK_PANIC is not set
CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=0
# CONFIG_WQ_WATCHDOG is not set
# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=0
CONFIG_PANIC_TIMEOUT=0
CONFIG_SCHED_DEBUG=y
# CONFIG_SCHED_INFO is not set
# CONFIG_SCHEDSTATS is not set
CONFIG_SCHED_STACK_END_CHECK=y
# CONFIG_DEBUG_TIMEKEEPING is not set
# CONFIG_TIMER_STATS is not set

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
# CONFIG_DEBUG_RT_MUTEXES is not set
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
# CONFIG_DEBUG_WW_MUTEX_SLOWPATH is not set
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_PROVE_LOCKING=y
CONFIG_LOCKDEP=y
# CONFIG_LOCK_STAT is not set
# CONFIG_DEBUG_LOCKDEP is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
CONFIG_DEBUG_LOCKING_API_SELFTESTS=y
# CONFIG_LOCK_TORTURE_TEST is not set
CONFIG_TRACE_IRQFLAGS=y
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
# CONFIG_DEBUG_KOBJECT_RELEASE is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_LIST=y
# CONFIG_DEBUG_PI_LIST is not set
CONFIG_DEBUG_SG=y
CONFIG_DEBUG_NOTIFIERS=y
CONFIG_DEBUG_CREDENTIALS=y

#
# RCU Debugging
#
CONFIG_PROVE_RCU=y
# CONFIG_PROVE_RCU_REPEATEDLY is not set
CONFIG_SPARSE_RCU_POINTER=y
CONFIG_TORTURE_TEST=y
# CONFIG_RCU_PERF_TEST is not set
CONFIG_RCU_TORTURE_TEST=y
# CONFIG_RCU_TORTURE_TEST_RUNNABLE is not set
CONFIG_RCU_TORTURE_TEST_SLOW_PREINIT=y
CONFIG_RCU_TORTURE_TEST_SLOW_PREINIT_DELAY=3
# CONFIG_RCU_TORTURE_TEST_SLOW_INIT is not set
# CONFIG_RCU_TORTURE_TEST_SLOW_CLEANUP is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=21
CONFIG_RCU_TRACE=y
CONFIG_RCU_EQS_DEBUG=y
CONFIG_DEBUG_WQ_FORCE_RR_CPU=y
CONFIG_NOTIFIER_ERROR_INJECTION=y
# CONFIG_PM_NOTIFIER_ERROR_INJECT is not set
# CONFIG_NETDEV_NOTIFIER_ERROR_INJECT is not set
# CONFIG_FAULT_INJECTION is not set
# CONFIG_LATENCYTOP is not set
CONFIG_ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS=y
# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_FENTRY=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACE_CLOCK=y
CONFIG_RING_BUFFER=y
CONFIG_RING_BUFFER_ALLOW_SWAP=y
CONFIG_TRACING_SUPPORT=y
# CONFIG_FTRACE is not set

#
# Runtime Testing
#
CONFIG_TEST_LIST_SORT=y
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_RBTREE_TEST is not set
CONFIG_ATOMIC64_SELFTEST=y
# CONFIG_TEST_HEXDUMP is not set
CONFIG_TEST_STRING_HELPERS=y
CONFIG_TEST_KSTRTOX=y
CONFIG_TEST_PRINTF=y
CONFIG_TEST_BITMAP=y
CONFIG_TEST_UUID=y
CONFIG_TEST_RHASHTABLE=y
CONFIG_TEST_HASH=y
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
CONFIG_BUILD_DOCSRC=y
# CONFIG_DMA_API_DEBUG is not set
# CONFIG_TEST_FIRMWARE is not set
CONFIG_TEST_UDELAY=y
CONFIG_MEMTEST=y
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_ARCH_HAS_UBSAN_SANITIZE_ALL=y
# CONFIG_UBSAN is not set
CONFIG_ARCH_HAS_DEVMEM_IS_ALLOWED=y
# CONFIG_STRICT_DEVMEM is not set
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
CONFIG_X86_PTDUMP_CORE=y
CONFIG_X86_PTDUMP=y
# CONFIG_DEBUG_RODATA_TEST is not set
# CONFIG_DEBUG_WX is not set
# CONFIG_DOUBLEFAULT is not set
# CONFIG_DEBUG_TLBFLUSH is not set
CONFIG_IOMMU_STRESS=y
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
# CONFIG_IO_DELAY_0X80 is not set
CONFIG_IO_DELAY_0XED=y
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=1
# CONFIG_DEBUG_BOOT_PARAMS is not set
# CONFIG_CPA_DEBUG is not set
# CONFIG_OPTIMIZE_INLINING is not set
# CONFIG_DEBUG_ENTRY is not set
# CONFIG_DEBUG_NMI_SELFTEST is not set
CONFIG_X86_DEBUG_FPU=y
# CONFIG_PUNIT_ATOM_DEBUG is not set

#
# Security options
#
# CONFIG_KEYS is not set
CONFIG_SECURITY_DMESG_RESTRICT=y
CONFIG_SECURITY=y
CONFIG_SECURITYFS=y
CONFIG_SECURITY_NETWORK=y
# CONFIG_SECURITY_PATH is not set
# CONFIG_SECURITY_TOMOYO is not set
# CONFIG_SECURITY_APPARMOR is not set
# CONFIG_SECURITY_YAMA is not set
# CONFIG_INTEGRITY is not set
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD=y
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_BLKCIPHER=y
CONFIG_CRYPTO_BLKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG=y
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_RNG_DEFAULT=y
CONFIG_CRYPTO_AKCIPHER2=y
# CONFIG_CRYPTO_RSA is not set
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_USER is not set
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_NULL2=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_MCRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_ABLK_HELPER=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=y
CONFIG_CRYPTO_GCM=y
CONFIG_CRYPTO_CHACHA20POLY1305=y
CONFIG_CRYPTO_SEQIV=y
CONFIG_CRYPTO_ECHAINIV=y

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_CTS=y
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_LRW=y
CONFIG_CRYPTO_PCBC=y
CONFIG_CRYPTO_XTS=y
CONFIG_CRYPTO_KEYWRAP=y

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=y
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=y
CONFIG_CRYPTO_VMAC=y

#
# Digest
#
# CONFIG_CRYPTO_CRC32C is not set
CONFIG_CRYPTO_CRC32C_INTEL=y
# CONFIG_CRYPTO_CRC32 is not set
CONFIG_CRYPTO_CRC32_PCLMUL=y
CONFIG_CRYPTO_CRCT10DIF=y
CONFIG_CRYPTO_CRCT10DIF_PCLMUL=y
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_POLY1305=y
# CONFIG_CRYPTO_POLY1305_X86_64 is not set
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=y
CONFIG_CRYPTO_RMD128=y
CONFIG_CRYPTO_RMD160=y
CONFIG_CRYPTO_RMD256=y
# CONFIG_CRYPTO_RMD320 is not set
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_SSSE3=y
CONFIG_CRYPTO_SHA256_SSSE3=y
CONFIG_CRYPTO_SHA512_SSSE3=y
CONFIG_CRYPTO_SHA1_MB=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_TGR192=y
CONFIG_CRYPTO_WP512=y
# CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL is not set

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_X86_64=y
CONFIG_CRYPTO_AES_NI_INTEL=y
CONFIG_CRYPTO_ANUBIS=y
CONFIG_CRYPTO_ARC4=y
CONFIG_CRYPTO_BLOWFISH=y
CONFIG_CRYPTO_BLOWFISH_COMMON=y
CONFIG_CRYPTO_BLOWFISH_X86_64=y
CONFIG_CRYPTO_CAMELLIA=y
CONFIG_CRYPTO_CAMELLIA_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64=y
# CONFIG_CRYPTO_CAST5 is not set
# CONFIG_CRYPTO_CAST5_AVX_X86_64 is not set
# CONFIG_CRYPTO_CAST6 is not set
# CONFIG_CRYPTO_CAST6_AVX_X86_64 is not set
CONFIG_CRYPTO_DES=y
# CONFIG_CRYPTO_DES3_EDE_X86_64 is not set
CONFIG_CRYPTO_FCRYPT=y
CONFIG_CRYPTO_KHAZAD=y
CONFIG_CRYPTO_SALSA20=y
CONFIG_CRYPTO_SALSA20_X86_64=y
CONFIG_CRYPTO_CHACHA20=y
CONFIG_CRYPTO_CHACHA20_X86_64=y
CONFIG_CRYPTO_SEED=y
CONFIG_CRYPTO_SERPENT=y
# CONFIG_CRYPTO_SERPENT_SSE2_X86_64 is not set
CONFIG_CRYPTO_SERPENT_AVX_X86_64=y
CONFIG_CRYPTO_SERPENT_AVX2_X86_64=y
# CONFIG_CRYPTO_TEA is not set
CONFIG_CRYPTO_TWOFISH=y
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_X86_64=y
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=y
CONFIG_CRYPTO_TWOFISH_AVX_X86_64=y

#
# Compression
#
# CONFIG_CRYPTO_DEFLATE is not set
CONFIG_CRYPTO_LZO=y
CONFIG_CRYPTO_842=y
CONFIG_CRYPTO_LZ4=y
CONFIG_CRYPTO_LZ4HC=y

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=y
CONFIG_CRYPTO_DRBG_MENU=y
CONFIG_CRYPTO_DRBG_HMAC=y
# CONFIG_CRYPTO_DRBG_HASH is not set
# CONFIG_CRYPTO_DRBG_CTR is not set
CONFIG_CRYPTO_DRBG=y
CONFIG_CRYPTO_JITTERENTROPY=y
# CONFIG_CRYPTO_USER_API_HASH is not set
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
# CONFIG_CRYPTO_USER_API_RNG is not set
# CONFIG_CRYPTO_USER_API_AEAD is not set
# CONFIG_CRYPTO_HW is not set

#
# Certificates for signature checking
#
CONFIG_HAVE_KVM=y
CONFIG_VIRTUALIZATION=y
# CONFIG_BINARY_PRINTF is not set

#
# Library routines
#
CONFIG_BITREVERSE=y
# CONFIG_HAVE_ARCH_BITREVERSE is not set
CONFIG_RATIONAL=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_IO=y
CONFIG_ARCH_USE_CMPXCHG_LOCKREF=y
CONFIG_ARCH_HAS_FAST_MULTIPLIER=y
# CONFIG_CRC_CCITT is not set
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
CONFIG_CRC32_SELFTEST=y
CONFIG_CRC32_SLICEBY8=y
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
# CONFIG_CRC7 is not set
# CONFIG_LIBCRC32C is not set
# CONFIG_CRC8 is not set
# CONFIG_AUDIT_ARCH_COMPAT_GENERIC is not set
# CONFIG_RANDOM32_SELFTEST is not set
CONFIG_842_COMPRESS=y
CONFIG_842_DECOMPRESS=y
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4_COMPRESS=y
CONFIG_LZ4HC_COMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
CONFIG_XZ_DEC=y
CONFIG_XZ_DEC_X86=y
# CONFIG_XZ_DEC_POWERPC is not set
CONFIG_XZ_DEC_IA64=y
# CONFIG_XZ_DEC_ARM is not set
# CONFIG_XZ_DEC_ARMTHUMB is not set
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
CONFIG_XZ_DEC_TEST=y
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_DECOMPRESS_XZ=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_REED_SOLOMON=y
CONFIG_REED_SOLOMON_DEC16=y
CONFIG_BCH=y
CONFIG_BCH_CONST_PARAMS=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
CONFIG_CORDIC=y
# CONFIG_DDR is not set
# CONFIG_IRQ_POLL is not set
# CONFIG_SG_SPLIT is not set
# CONFIG_SG_POOL is not set
CONFIG_ARCH_HAS_SG_CHAIN=y
CONFIG_ARCH_HAS_PMEM_API=y
CONFIG_ARCH_HAS_MMIO_FLUSH=y
CONFIG_STACKDEPOT=y

--=_5783e7d4.ghMddX2p1ia9FuZPpuYffA+eyPGef8x3apR7phtXvC9zRAcU--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
