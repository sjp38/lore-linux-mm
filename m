Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 6A3556B015C
	for <linux-mm@kvack.org>; Wed, 19 Mar 2014 07:55:54 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id r10so8524038pdi.16
        for <linux-mm@kvack.org>; Wed, 19 Mar 2014 04:55:54 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id hh1si14769616pac.341.2014.03.19.04.55.52
        for <linux-mm@kvack.org>;
        Wed, 19 Mar 2014 04:55:53 -0700 (PDT)
Date: Wed, 19 Mar 2014 19:55:40 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [mm/vmalloc] BUG: sleeping function called from invalid context at
 mm/vmalloc.c:74
Message-ID: <20140319115540.GA7277@localhost>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="Kj7319i9nmIyA2yE"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>
Cc: LKML <linux-kernel@vger.kernel.org>, lkp@01.org, Linux Memory Management List <linux-mm@kvack.org>


--Kj7319i9nmIyA2yE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi David,

FYI, we noticed the below BUG on

git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
commit 032dda8b6c4021d4be63bcc483b47fd26c6f48a2 ("mm/vmalloc: avoid soft lockup warnings when vunmap()'ing large ranges")

[  229.097122] BUG: sleeping function called from invalid context at mm/vmalloc.c:74                            
[  229.109704] in_atomic(): 1, irqs_disabled(): 0, pid: 13598, name: poll2_threads  
[  229.119755] CPU: 17 PID: 13598 Comm: poll2_threads Not tainted 3.14.0-rc6-next-20140317 #1
[  229.130914] Hardware name: Intel Corporation BRICKLAND/BRICKLAND, BIOS BKLDSDP1.86B.0031.R01.1304221600 04/22/2013
[  229.144432]  0000000000000000 ffff881840111d80 ffffffff81a3ae8a ffffc9001cf38000                                  
[  229.155417]  ffff881840111d90 ffffffff81101256 ffff881840111e08 ffffffff811b1540
[  229.166340]  ffffc9001cf48fff ffffc9001cf48fff 0000000000000000 ffff881840111dd0
[  229.177355] Call Trace:
[  229.181129]  [<ffffffff81a3ae8a>] dump_stack+0x4d/0x66
[  229.188012]  [<ffffffff81101256>] __might_sleep+0x10a/0x10c
[  229.195320]  [<ffffffff811b1540>] vunmap_page_range+0x143/0x2b2
[  229.203046]  [<ffffffff811b2174>] ? map_vm_area+0x2e/0x40
[  229.210184]  [<ffffffff811b2c95>] remove_vm_area+0x58/0x75
[  229.217361]  [<ffffffff811b2ced>] __vunmap+0x3b/0xaf
[  229.223979]  [<ffffffff811b2df5>] vfree+0x67/0x6a
[  229.230316]  [<ffffffff811f4868>] free_fdmem+0x2a/0x33
[  229.237140]  [<ffffffff811f4949>] __free_fdtable+0x16/0x2a
[  229.244313]  [<ffffffff811f4c1e>] expand_files+0x121/0x143
[  229.251516]  [<ffffffff811f5075>] __alloc_fd+0x5e/0xef
[  229.258363]  [<ffffffff811f5136>] get_unused_fd_flags+0x30/0x32
[  229.266038]  [<ffffffff811dcf02>] do_sys_open+0x12e/0x1d6
[  229.273127]  [<ffffffff811dcfc8>] SyS_open+0x1e/0x20
[  229.279718]  [<ffffffff81a49de9>] system_call_fastpath+0x16/0x1b

Thanks,
Fengguang

--Kj7319i9nmIyA2yE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=".dmesg"
Content-Transfer-Encoding: quoted-printable

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.14.0-rc6-next-20140317 (kbuild@xian) (gcc ve=
rsion 4.8.2 (Debian 4.8.2-16) ) #1 SMP Mon Mar 17 20:01:18 CST 2014
[    0.000000] Command line: user=3Dlkp job=3D/lkp/scheduled/brickland1/cyc=
lic_will-it-scale-poll2-HEAD-8808b950581f71e3ee4cf8e6cae479f4c7106405.yaml =
ARCH=3Dx86_64 BOOT_IMAGE=3D/kernel/x86_64-lkp/8808b950581f71e3ee4cf8e6cae47=
9f4c7106405/vmlinuz-3.14.0-rc6-next-20140317 kconfig=3Dx86_64-lkp commit=3D=
8808b950581f71e3ee4cf8e6cae479f4c7106405 bm_initrd=3D/lkp/benchmarks/will-i=
t-scale.cgz modules_initrd=3D/kernel/x86_64-lkp/8808b950581f71e3ee4cf8e6cae=
479f4c7106405/modules.cgz max_uptime=3D900 RESULT_ROOT=3D/lkp/result/brickl=
and1/micro/will-it-scale/poll2/x86_64-lkp/8808b950581f71e3ee4cf8e6cae479f4c=
7106405/0 initrd=3D/kernel-tests/initrd/lkp-rootfs.cgz root=3D/dev/ram0 ip=
=3D::::brickland1::dhcp oops=3Dpanic ipmi_si.tryacpi=3D0 ipmi_watchdog.star=
t_now=3D1 earlyprintk=3DttyS0,115200 debug apic=3Ddebug sysrq_always_enable=
d rcupdate.rcu_cpu_stall_timeout=3D100 panic=3D10 softlockup_panic=3D1 nmi_=
watchdog=3Dpanic load_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200=
 console=3Dtty0 vga=3Dnormal
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000100-0x000000000009dfff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009e000-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000006509efff] usable
[    0.000000] BIOS-e820: [mem 0x000000006509f000-0x0000000065375fff] ACPI =
NVS
[    0.000000] BIOS-e820: [mem 0x0000000065376000-0x0000000065a6afff] usable
[    0.000000] BIOS-e820: [mem 0x0000000065a6b000-0x0000000065b29fff] ACPI =
data
[    0.000000] BIOS-e820: [mem 0x0000000065b2a000-0x0000000065df8fff] usable
[    0.000000] BIOS-e820: [mem 0x0000000065df9000-0x0000000066df8fff] ACPI =
NVS
[    0.000000] BIOS-e820: [mem 0x0000000066df9000-0x000000007abcefff] usable
[    0.000000] BIOS-e820: [mem 0x000000007abcf000-0x000000007accefff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x000000007accf000-0x000000007b6fefff] ACPI =
NVS
[    0.000000] BIOS-e820: [mem 0x000000007b6ff000-0x000000007b7ebfff] ACPI =
data
[    0.000000] BIOS-e820: [mem 0x000000007b7ec000-0x000000007b7fffff] usable
[    0.000000] BIOS-e820: [mem 0x000000007b800000-0x000000008fffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fed1c000-0x00000000fed1ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000ff800000-0x00000000ffffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000207fffffff] usable
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.7 present.
[    0.000000] DMI: Intel Corporation BRICKLAND/BRICKLAND, BIOS BKLDSDP1.86=
B.0031.R01.1304221600 04/22/2013
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] No AGP bridge found
[    0.000000] e820: last_pfn =3D 0x2080000 max_arch_pfn =3D 0x400000000
[    0.000000] MTRR default type: write-back
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-DFFFF write-protect
[    0.000000]   E0000-FFFFF uncachable
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 000080000000 mask 3FFF80000000 uncachable
[    0.000000]   1 base 380000000000 mask 3F8000000000 uncachable
[    0.000000]   2 base 00007C000000 mask 3FFFFC000000 uncachable
[    0.000000]   3 base 00007FC00000 mask 3FFFFFC00000 uncachable
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000]   8 disabled
[    0.000000]   9 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x7010600070106, new 0x701060007=
0106
[    0.000000] e820: last_pfn =3D 0x7b800 max_arch_pfn =3D 0x400000000
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] Scan for SMP in [mem 0x0009d000-0x0009d3ff]
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] Base memory trampoline at [ffff880000096000] 96000 size 24576
[    0.000000] Using GB pages for direct mapping
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x0266c000, 0x0266cfff] PGTABLE
[    0.000000] BRK [0x0266d000, 0x0266dfff] PGTABLE
[    0.000000] BRK [0x0266e000, 0x0266efff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x207fe00000-0x207fffffff]
[    0.000000]  [mem 0x207fe00000-0x207fffffff] page 1G
[    0.000000] init_memory_mapping: [mem 0x207c000000-0x207fdfffff]
[    0.000000]  [mem 0x207c000000-0x207fdfffff] page 1G
[    0.000000] init_memory_mapping: [mem 0x2000000000-0x207bffffff]
[    0.000000]  [mem 0x2000000000-0x207bffffff] page 1G
[    0.000000] init_memory_mapping: [mem 0x1000000000-0x1fffffffff]
[    0.000000]  [mem 0x1000000000-0x1fffffffff] page 1G
[    0.000000] init_memory_mapping: [mem 0x00100000-0x6509efff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x64ffffff] page 2M
[    0.000000]  [mem 0x65000000-0x6509efff] page 4k
[    0.000000] init_memory_mapping: [mem 0x65376000-0x65a6afff]
[    0.000000]  [mem 0x65376000-0x653fffff] page 4k
[    0.000000]  [mem 0x65400000-0x659fffff] page 2M
[    0.000000]  [mem 0x65a00000-0x65a6afff] page 4k
[    0.000000] BRK [0x0266f000, 0x0266ffff] PGTABLE
[    0.000000] BRK [0x02670000, 0x02670fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x65b2a000-0x65df8fff]
[    0.000000]  [mem 0x65b2a000-0x65df8fff] page 4k
[    0.000000] BRK [0x02671000, 0x02671fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x66df9000-0x7abcefff]
[    0.000000]  [mem 0x66df9000-0x66dfffff] page 4k
[    0.000000]  [mem 0x66e00000-0x7a9fffff] page 2M
[    0.000000]  [mem 0x7aa00000-0x7abcefff] page 4k
[    0.000000] init_memory_mapping: [mem 0x7b7ec000-0x7b7fffff]
[    0.000000]  [mem 0x7b7ec000-0x7b7fffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x100000000-0xfffffffff]
[    0.000000]  [mem 0x100000000-0xfffffffff] page 1G
[    0.000000] RAMDISK: [mem 0x6dbc4000-0x7abcefff]
[    0.000000] ACPI: RSDP 0x00000000000F0410 000024 (v02 INTEL )
[    0.000000] ACPI: XSDT 0x000000007B7EA0E8 0000AC (v01 INTEL  TIANO    00=
000000 MSFT 01000013)
[    0.000000] ACPI: FACP 0x000000007B7E7000 0000F4 (v04 INTEL  TIANO    00=
000000 MSFT 01000013)
[    0.000000] ACPI: DSDT 0x000000007B7B9000 022FFB (v02 INTEL  TIANO    00=
000003 MSFT 01000013)
[    0.000000] ACPI: FACS 0x000000007AE78000 000040
[    0.000000] ACPI: TCPA 0x000000007B7E9000 000064 (v02 INTEL  BRICKLAN 06=
222004 INTL 20121004)
[    0.000000] ACPI: BDAT 0x000000007B7E8000 000030 (v01 INTEL  TIANO    00=
000000 MSFT 01000013)
[    0.000000] ACPI: HPET 0x000000007B7E6000 000038 (v01 INTEL  TIANO    00=
000001 MSFT 01000013)
[    0.000000] ACPI: APIC 0x000000007B7E5000 00085C (v03 INTEL  TIANO    00=
000000 MSFT 01000013)
[    0.000000] ACPI: MCFG 0x000000007B7E4000 00003C (v01 INTEL  TIANO    00=
000001 MSFT 01000013)
[    0.000000] ACPI: MSCT 0x000000007B7E3000 000090 (v01 INTEL  TIANO    00=
000001 MSFT 01000013)
[    0.000000] ACPI: PCCT 0x000000007B7E2000 0000AC (v01 INTEL  TIANO    00=
000002 MSFT 01000013)
[    0.000000] ACPI: PMCT 0x000000007B7E1000 000060 (v01 INTEL  TIANO    00=
000000 MSFT 01000013)
[    0.000000] ACPI: RASF 0x000000007B7E0000 000030 (v01 INTEL  TIANO    00=
000001 MSFT 01000013)
[    0.000000] ACPI: SLIT 0x000000007B7DF000 00003C (v01 INTEL  TIANO    00=
000001 MSFT 01000013)
[    0.000000] ACPI: SRAT 0x000000007B7DE000 000E30 (v03 INTEL  TIANO    00=
000001 MSFT 01000013)
[    0.000000] ACPI: SVOS 0x000000007B7DD000 000032 (v01 INTEL  TIANO    00=
000000 MSFT 01000013)
[    0.000000] ACPI: WDDT 0x000000007B7DC000 000040 (v01 INTEL  TIANO    00=
000000 MSFT 01000013)
[    0.000000] ACPI: SSDT 0x0000000065A6B000 0BEF1B (v02 INTEL  SSDT  PM 00=
004000 INTL 20090521)
[    0.000000] ACPI: SSDT 0x000000007B7B8000 00008B (v02 INTEL  SpsNvs   00=
000002 INTL 20090521)
[    0.000000] ACPI: SPCR 0x000000007B7B7000 000050 (v01                 00=
000000      00000000)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5f3000 (        fee00000)
[    0.000000] SRAT: PXM 0 -> APIC 0x00 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x02 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x04 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x06 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x08 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0a -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0c -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0e -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x10 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x12 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x14 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x16 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x18 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x1a -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x1c -> Node 0
[    0.000000] SRAT: PXM 1 -> APIC 0x20 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x22 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x24 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x26 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x28 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x2a -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x2c -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x2e -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x30 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x32 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x34 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x36 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x38 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x3a -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x3c -> Node 1
[    0.000000] SRAT: PXM 2 -> APIC 0x40 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x42 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x44 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x46 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x48 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x4a -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x4c -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x4e -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x50 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x52 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x54 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x56 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x58 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x5a -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x5c -> Node 2
[    0.000000] SRAT: PXM 3 -> APIC 0x60 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x62 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x64 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x66 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x68 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x6a -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x6c -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x6e -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x70 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x72 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x74 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x76 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x78 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x7a -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x7c -> Node 3
[    0.000000] SRAT: PXM 0 -> APIC 0x01 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x03 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x05 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x07 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x09 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0b -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0d -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0f -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x11 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x13 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x15 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x17 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x19 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x1b -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x1d -> Node 0
[    0.000000] SRAT: PXM 1 -> APIC 0x21 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x23 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x25 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x27 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x29 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x2b -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x2d -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x2f -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x31 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x33 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x35 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x37 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x39 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x3b -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x3d -> Node 1
[    0.000000] SRAT: PXM 2 -> APIC 0x41 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x43 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x45 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x47 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x49 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x4b -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x4d -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x4f -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x51 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x53 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x55 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x57 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x59 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x5b -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x5d -> Node 2
[    0.000000] SRAT: PXM 3 -> APIC 0x61 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x63 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x65 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x67 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x69 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x6b -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x6d -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x6f -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x71 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x73 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x75 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x77 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x79 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x7b -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x7d -> Node 3
[    0.000000] SRAT: Node 0 PXM 0 [mem 0x00000000-0x7fffffff]
[    0.000000] SRAT: Node 0 PXM 0 [mem 0x100000000-0x87fffffff]
[    0.000000] SRAT: Node 1 PXM 1 [mem 0x880000000-0x107fffffff]
[    0.000000] SRAT: Node 2 PXM 2 [mem 0x1080000000-0x187fffffff]
[    0.000000] SRAT: Node 3 PXM 3 [mem 0x1880000000-0x207fffffff]
[    0.000000] NUMA: Initialized distance table, cnt=3D4
[    0.000000] NUMA: Node 0 [mem 0x00000000-0x7fffffff] + [mem 0x100000000-=
0x87fffffff] -> [mem 0x00000000-0x87fffffff]
[    0.000000] Initmem setup node 0 [mem 0x00000000-0x87fffffff]
[    0.000000]   NODE_DATA [mem 0x87fffb000-0x87fffffff]
[    0.000000] Initmem setup node 1 [mem 0x880000000-0x107fffffff]
[    0.000000]   NODE_DATA [mem 0x107fffb000-0x107fffffff]
[    0.000000] Initmem setup node 2 [mem 0x1080000000-0x187fffffff]
[    0.000000]   NODE_DATA [mem 0x187fffb000-0x187fffffff]
[    0.000000] Initmem setup node 3 [mem 0x1880000000-0x207fffffff]
[    0.000000]   NODE_DATA [mem 0x207fff5000-0x207fff9fff]
[    0.000000]  [ffffea0000000000-ffffea0021ffffff] PMD -> [ffff88085fe0000=
0-ffff88087fdfffff] on node 0
[    0.000000]  [ffffea0022000000-ffffea0041ffffff] PMD -> [ffff88105fe0000=
0-ffff88107fdfffff] on node 1
[    0.000000]  [ffffea0042000000-ffffea0061ffffff] PMD -> [ffff88185fe0000=
0-ffff88187fdfffff] on node 2
[    0.000000]  [ffffea0062000000-ffffea0081ffffff] PMD -> [ffff88205f60000=
0-ffff88207f5fffff] on node 3
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   [mem 0x100000000-0x207fffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009dfff]
[    0.000000]   node   0: [mem 0x00100000-0x6509efff]
[    0.000000]   node   0: [mem 0x65376000-0x65a6afff]
[    0.000000]   node   0: [mem 0x65b2a000-0x65df8fff]
[    0.000000]   node   0: [mem 0x66df9000-0x7abcefff]
[    0.000000]   node   0: [mem 0x7b7ec000-0x7b7fffff]
[    0.000000]   node   0: [mem 0x100000000-0x87fffffff]
[    0.000000]   node   1: [mem 0x880000000-0x107fffffff]
[    0.000000]   node   2: [mem 0x1080000000-0x187fffffff]
[    0.000000]   node   3: [mem 0x1880000000-0x207fffffff]
[    0.000000] On node 0 totalpages: 8361962
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 23 pages reserved
[    0.000000]   DMA zone: 3997 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 7714 pages used for memmap
[    0.000000]   DMA32 zone: 493645 pages, LIFO batch:31
[    0.000000]   Normal zone: 122880 pages used for memmap
[    0.000000]   Normal zone: 7864320 pages, LIFO batch:31
[    0.000000] On node 1 totalpages: 8388608
[    0.000000]   Normal zone: 131072 pages used for memmap
[    0.000000]   Normal zone: 8388608 pages, LIFO batch:31
[    0.000000] On node 2 totalpages: 8388608
[    0.000000]   Normal zone: 131072 pages used for memmap
[    0.000000]   Normal zone: 8388608 pages, LIFO batch:31
[    0.000000] On node 3 totalpages: 8388608
[    0.000000]   Normal zone: 131072 pages used for memmap
[    0.000000]   Normal zone: 8388608 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0x408
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5f3000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x04] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x06] lapic_id[0x06] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x08] lapic_id[0x08] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0a] lapic_id[0x0a] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0c] lapic_id[0x0c] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0e] lapic_id[0x0e] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x10] lapic_id[0x10] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x12] lapic_id[0x12] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x14] lapic_id[0x14] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x16] lapic_id[0x16] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x18] lapic_id[0x18] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1a] lapic_id[0x1a] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1c] lapic_id[0x1c] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x40] lapic_id[0x20] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x42] lapic_id[0x22] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x44] lapic_id[0x24] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x46] lapic_id[0x26] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x48] lapic_id[0x28] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x4a] lapic_id[0x2a] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x4c] lapic_id[0x2c] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x4e] lapic_id[0x2e] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x50] lapic_id[0x30] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x52] lapic_id[0x32] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x54] lapic_id[0x34] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x56] lapic_id[0x36] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x58] lapic_id[0x38] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x5a] lapic_id[0x3a] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x5c] lapic_id[0x3c] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x80] lapic_id[0x40] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x82] lapic_id[0x42] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x84] lapic_id[0x44] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x86] lapic_id[0x46] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x88] lapic_id[0x48] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x8a] lapic_id[0x4a] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x8c] lapic_id[0x4c] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x8e] lapic_id[0x4e] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x90] lapic_id[0x50] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x92] lapic_id[0x52] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x94] lapic_id[0x54] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x96] lapic_id[0x56] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x98] lapic_id[0x58] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x9a] lapic_id[0x5a] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x9c] lapic_id[0x5c] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xc0] lapic_id[0x60] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xc2] lapic_id[0x62] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xc4] lapic_id[0x64] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xc6] lapic_id[0x66] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xc8] lapic_id[0x68] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xca] lapic_id[0x6a] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xcc] lapic_id[0x6c] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xce] lapic_id[0x6e] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xd0] lapic_id[0x70] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xd2] lapic_id[0x72] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xd4] lapic_id[0x74] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xd6] lapic_id[0x76] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xd8] lapic_id[0x78] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xda] lapic_id[0x7a] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xdc] lapic_id[0x7c] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x03] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x05] lapic_id[0x05] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x07] lapic_id[0x07] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x09] lapic_id[0x09] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0b] lapic_id[0x0b] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0d] lapic_id[0x0d] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0f] lapic_id[0x0f] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x11] lapic_id[0x11] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x13] lapic_id[0x13] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x15] lapic_id[0x15] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x17] lapic_id[0x17] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x19] lapic_id[0x19] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1b] lapic_id[0x1b] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1d] lapic_id[0x1d] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x41] lapic_id[0x21] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x43] lapic_id[0x23] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x45] lapic_id[0x25] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x47] lapic_id[0x27] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x49] lapic_id[0x29] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x4b] lapic_id[0x2b] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x4d] lapic_id[0x2d] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x4f] lapic_id[0x2f] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x51] lapic_id[0x31] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x53] lapic_id[0x33] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x55] lapic_id[0x35] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x57] lapic_id[0x37] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x59] lapic_id[0x39] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x5b] lapic_id[0x3b] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x5d] lapic_id[0x3d] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x81] lapic_id[0x41] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x83] lapic_id[0x43] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x85] lapic_id[0x45] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x87] lapic_id[0x47] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x89] lapic_id[0x49] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x8b] lapic_id[0x4b] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x8d] lapic_id[0x4d] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x8f] lapic_id[0x4f] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x91] lapic_id[0x51] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x93] lapic_id[0x53] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x95] lapic_id[0x55] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x97] lapic_id[0x57] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x99] lapic_id[0x59] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x9b] lapic_id[0x5b] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x9d] lapic_id[0x5d] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xc1] lapic_id[0x61] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xc3] lapic_id[0x63] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xc5] lapic_id[0x65] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xc7] lapic_id[0x67] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xc9] lapic_id[0x69] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xcb] lapic_id[0x6b] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xcd] lapic_id[0x6d] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xcf] lapic_id[0x6f] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xd1] lapic_id[0x71] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xd3] lapic_id[0x73] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xd5] lapic_id[0x75] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xd7] lapic_id[0x77] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xd9] lapic_id[0x79] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xdb] lapic_id[0x7b] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xdd] lapic_id[0x7d] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x02] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x03] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x04] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x05] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x06] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x07] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x08] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x09] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0a] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0b] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0c] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0d] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0e] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0f] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x10] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x11] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x12] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x13] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x14] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x15] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x16] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x17] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x18] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x19] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1a] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1b] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1c] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1d] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1e] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1f] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x20] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x21] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x22] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x23] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x24] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x25] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x26] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x27] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x28] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x29] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x2a] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x2b] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x2c] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x2d] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x2e] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x2f] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x30] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x31] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x32] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x33] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x34] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x35] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x36] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x37] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x38] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x39] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x3a] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x3b] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x3c] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x3d] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x3e] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x3f] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x40] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x41] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x42] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x43] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x44] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x45] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x46] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x47] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x48] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x49] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x4a] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x4b] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x4c] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x4d] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x4e] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x4f] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x50] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x51] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x52] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x53] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x54] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x55] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x56] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x57] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x58] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x59] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x5a] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x5b] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x5c] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x5d] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x5e] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x5f] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x60] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x61] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x62] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x63] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x64] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x65] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x66] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x67] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x68] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x69] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x6a] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x6b] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x6c] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x6d] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x6e] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x6f] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x70] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x71] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x72] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x73] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x74] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x75] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x76] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x77] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x78] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x79] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x7a] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x7b] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x7c] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x7c] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x7d] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x7e] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x7f] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x80] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x81] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x82] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x83] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x84] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x85] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x86] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x87] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x88] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x89] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x8a] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x8b] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x8c] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x8d] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x8f] high level lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x08] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 8, version 32, address 0xfec00000, GSI 0-=
23
[    0.000000] ACPI: IOAPIC (id[0x09] address[0xfec01000] gsi_base[24])
[    0.000000] IOAPIC[1]: apic_id 9, version 32, address 0xfec01000, GSI 24=
-47
[    0.000000] ACPI: IOAPIC (id[0x0a] address[0xfec40000] gsi_base[48])
[    0.000000] IOAPIC[2]: apic_id 10, version 32, address 0xfec40000, GSI 4=
8-71
[    0.000000] ACPI: IOAPIC (id[0x0b] address[0xfec80000] gsi_base[72])
[    0.000000] IOAPIC[3]: apic_id 11, version 32, address 0xfec80000, GSI 7=
2-95
[    0.000000] ACPI: IOAPIC (id[0x0c] address[0xfecc0000] gsi_base[96])
[    0.000000] IOAPIC[4]: apic_id 12, version 32, address 0xfecc0000, GSI 9=
6-119
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 8, APIC =
INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 8, APIC =
INT 09
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 8, APIC =
INT 01
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 8, APIC =
INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 8, APIC =
INT 04
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 05, APIC ID 8, APIC =
INT 05
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 8, APIC =
INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 8, APIC =
INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 8, APIC =
INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0a, APIC ID 8, APIC =
INT 0a
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0b, APIC ID 8, APIC =
INT 0b
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 8, APIC =
INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 8, APIC =
INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 8, APIC =
INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 8, APIC =
INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a301 base: 0xfed00000
[    0.000000] smpboot: Allowing 144 CPUs, 24 hotplug CPUs
[    0.000000] mapped IOAPIC to ffffffffff5f2000 (fec00000)
[    0.000000] mapped IOAPIC to ffffffffff5f1000 (fec01000)
[    0.000000] mapped IOAPIC to ffffffffff5f0000 (fec40000)
[    0.000000] mapped IOAPIC to ffffffffff5ef000 (fec80000)
[    0.000000] mapped IOAPIC to ffffffffff5ee000 (fecc0000)
[    0.000000] nr_irqs_gsi: 136
[    0.000000] PM: Registered nosave memory: [mem 0x0009e000-0x0009ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000dffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000e0000-0x000fffff]
[    0.000000] PM: Registered nosave memory: [mem 0x6509f000-0x65375fff]
[    0.000000] PM: Registered nosave memory: [mem 0x65a6b000-0x65b29fff]
[    0.000000] PM: Registered nosave memory: [mem 0x65df9000-0x66df8fff]
[    0.000000] PM: Registered nosave memory: [mem 0x7abcf000-0x7accefff]
[    0.000000] PM: Registered nosave memory: [mem 0x7accf000-0x7b6fefff]
[    0.000000] PM: Registered nosave memory: [mem 0x7b6ff000-0x7b7ebfff]
[    0.000000] PM: Registered nosave memory: [mem 0x7b800000-0x8fffffff]
[    0.000000] PM: Registered nosave memory: [mem 0x90000000-0xfed1bfff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed1c000-0xfed1ffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed20000-0xff7fffff]
[    0.000000] PM: Registered nosave memory: [mem 0xff800000-0xffffffff]
[    0.000000] e820: [mem 0x90000000-0xfed1bfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] setup_percpu: NR_CPUS:512 nr_cpumask_bits:512 nr_cpu_ids:144=
 nr_node_ids:4
[    0.000000] PERCPU: Embedded 27 pages/cpu @ffff88085f800000 s81088 r8192=
 d21312 u131072
[    0.000000] pcpu-alloc: s81088 r8192 d21312 u131072 alloc=3D1*2097152
[    0.000000] pcpu-alloc: [0] 000 001 002 003 004 005 006 007 008 009 010 =
011 012 013 014 060=20
[    0.000000] pcpu-alloc: [0] 061 062 063 064 065 066 067 068 069 070 071 =
072 073 074 120 124=20
[    0.000000] pcpu-alloc: [0] 128 132 136 140 --- --- --- --- --- --- --- =
--- --- --- --- ---=20
[    0.000000] pcpu-alloc: [1] 015 016 017 018 019 020 021 022 023 024 025 =
026 027 028 029 075=20
[    0.000000] pcpu-alloc: [1] 076 077 078 079 080 081 082 083 084 085 086 =
087 088 089 121 125=20
[    0.000000] pcpu-alloc: [1] 129 133 137 141 --- --- --- --- --- --- --- =
--- --- --- --- ---=20
[    0.000000] pcpu-alloc: [2] 030 031 032 033 034 035 036 037 038 039 040 =
041 042 043 044 090=20
[    0.000000] pcpu-alloc: [2] 091 092 093 094 095 096 097 098 099 100 101 =
102 103 104 122 126=20
[    0.000000] pcpu-alloc: [2] 130 134 138 142 --- --- --- --- --- --- --- =
--- --- --- --- ---=20
[    0.000000] pcpu-alloc: [3] 045 046 047 048 049 050 051 052 053 054 055 =
056 057 058 059 105=20
[    0.000000] pcpu-alloc: [3] 106 107 108 109 110 111 112 113 114 115 116 =
117 118 119 123 127=20
[    0.000000] pcpu-alloc: [3] 131 135 139 143 --- --- --- --- --- --- --- =
--- --- --- --- ---=20
[    0.000000] Built 4 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 33003889
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: user=3Dlkp job=3D/lkp/scheduled/brickla=
nd1/cyclic_will-it-scale-poll2-HEAD-8808b950581f71e3ee4cf8e6cae479f4c710640=
5.yaml ARCH=3Dx86_64 BOOT_IMAGE=3D/kernel/x86_64-lkp/8808b950581f71e3ee4cf8=
e6cae479f4c7106405/vmlinuz-3.14.0-rc6-next-20140317 kconfig=3Dx86_64-lkp co=
mmit=3D8808b950581f71e3ee4cf8e6cae479f4c7106405 bm_initrd=3D/lkp/benchmarks=
/will-it-scale.cgz modules_initrd=3D/kernel/x86_64-lkp/8808b950581f71e3ee4c=
f8e6cae479f4c7106405/modules.cgz max_uptime=3D900 RESULT_ROOT=3D/lkp/result=
/brickland1/micro/will-it-scale/poll2/x86_64-lkp/8808b950581f71e3ee4cf8e6ca=
e479f4c7106405/0 initrd=3D/kernel-tests/initrd/lkp-rootfs.cgz root=3D/dev/r=
am0 ip=3D::::brickland1::dhcp oops=3Dpanic ipmi_si.tryacpi=3D0 ipmi_watchdo=
g.start_now=3D1 earlyprintk=3DttyS0,115200 debug apic=3Ddebug sysrq_always_=
enabled rcupdate.rcu_cpu_stall_timeout=3D100 panic=3D10 softlockup_panic=3D=
1 nmi_watchdog=3Dpanic load_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,=
115200 console=3Dtty0 vga=3Dnormal
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] xsave: enabled xstate_bv 0x7, cntxt size 0x340
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Memory: 131695560K/134111144K available (10556K kernel code,=
 1268K rwdata, 4292K rodata, 1436K init, 1760K bss, 2415584K reserved)
[    0.000000] SLUB: HWalign=3D64, Order=3D0-3, MinObjects=3D0, CPUs=3D144,=
 Nodes=3D4
[    0.000000] Hierarchical RCU implementation.
[    0.000000] RCU dyntick-idle grace-period acceleration is enabled.
[    0.000000] RCU restricting CPUs from NR_CPUS=3D512 to nr_cpu_ids=3D144.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=3D16, nr_cpu_ids=
=3D144
[    0.000000] NR_IRQS:33024 nr_irqs:3464 16
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] bootconsole [earlyser0] disabled
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.14.0-rc6-next-20140317 (kbuild@xian) (gcc ve=
rsion 4.8.2 (Debian 4.8.2-16) ) #1 SMP Mon Mar 17 20:01:18 CST 2014
[    0.000000] Command line: user=3Dlkp job=3D/lkp/scheduled/brickland1/cyc=
lic_will-it-scale-poll2-HEAD-8808b950581f71e3ee4cf8e6cae479f4c7106405.yaml =
ARCH=3Dx86_64 BOOT_IMAGE=3D/kernel/x86_64-lkp/8808b950581f71e3ee4cf8e6cae47=
9f4c7106405/vmlinuz-3.14.0-rc6-next-20140317 kconfig=3Dx86_64-lkp commit=3D=
8808b950581f71e3ee4cf8e6cae479f4c7106405 bm_initrd=3D/lkp/benchmarks/will-i=
t-scale.cgz modules_initrd=3D/kernel/x86_64-lkp/8808b950581f71e3ee4cf8e6cae=
479f4c7106405/modules.cgz max_uptime=3D900 RESULT_ROOT=3D/lkp/result/brickl=
and1/micro/will-it-scale/poll2/x86_64-lkp/8808b950581f71e3ee4cf8e6cae479f4c=
7106405/0 initrd=3D/kernel-tests/initrd/lkp-rootfs.cgz root=3D/dev/ram0 ip=
=3D::::brickland1::dhcp oops=3Dpanic ipmi_si.tryacpi=3D0 ipmi_watchdog.star=
t_now=3D1 earlyprintk=3DttyS0,115200 debug apic=3Ddebug sysrq_always_enable=
d rcupdate.rcu_cpu_stall_timeout=3D100 panic=3D10 softlockup_panic=3D1 nmi_=
watchdog=3Dpanic load_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200=
 console=3Dtty0 vga=3Dnormal
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000100-0x000000000009dfff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009e000-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000006509efff] usable
[    0.000000] BIOS-e820: [mem 0x000000006509f000-0x0000000065375fff] ACPI =
NVS
[    0.000000] BIOS-e820: [mem 0x0000000065376000-0x0000000065a6afff] usable
[    0.000000] BIOS-e820: [mem 0x0000000065a6b000-0x0000000065b29fff] ACPI =
data
[    0.000000] BIOS-e820: [mem 0x0000000065b2a000-0x0000000065df8fff] usable
[    0.000000] BIOS-e820: [mem 0x0000000065df9000-0x0000000066df8fff] ACPI =
NVS
[    0.000000] BIOS-e820: [mem 0x0000000066df9000-0x000000007abcefff] usable
[    0.000000] BIOS-e820: [mem 0x000000007abcf000-0x000000007accefff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x000000007accf000-0x000000007b6fefff] ACPI =
NVS
[    0.000000] BIOS-e820: [mem 0x000000007b6ff000-0x000000007b7ebfff] ACPI =
data
[    0.000000] BIOS-e820: [mem 0x000000007b7ec000-0x000000007b7fffff] usable
[    0.000000] BIOS-e820: [mem 0x000000007b800000-0x000000008fffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fed1c000-0x00000000fed1ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000ff800000-0x00000000ffffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000207fffffff] usable
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.7 present.
[    0.000000] DMI: Intel Corporation BRICKLAND/BRICKLAND, BIOS BKLDSDP1.86=
B.0031.R01.1304221600 04/22/2013
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] No AGP bridge found
[    0.000000] e820: last_pfn =3D 0x2080000 max_arch_pfn =3D 0x400000000
[    0.000000] MTRR default type: write-back
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-DFFFF write-protect
[    0.000000]   E0000-FFFFF uncachable
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 000080000000 mask 3FFF80000000 uncachable
[    0.000000]   1 base 380000000000 mask 3F8000000000 uncachable
[    0.000000]   2 base 00007C000000 mask 3FFFFC000000 uncachable
[    0.000000]   3 base 00007FC00000 mask 3FFFFFC00000 uncachable
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000]   8 disabled
[    0.000000]   9 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x7010600070106, new 0x701060007=
0106
[    0.000000] e820: last_pfn =3D 0x7b800 max_arch_pfn =3D 0x400000000
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] Scan for SMP in [mem 0x0009d000-0x0009d3ff]
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] Base memory trampoline at [ffff880000096000] 96000 size 24576
[    0.000000] Using GB pages for direct mapping
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x0266c000, 0x0266cfff] PGTABLE
[    0.000000] BRK [0x0266d000, 0x0266dfff] PGTABLE
[    0.000000] BRK [0x0266e000, 0x0266efff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x207fe00000-0x207fffffff]
[    0.000000]  [mem 0x207fe00000-0x207fffffff] page 1G
[    0.000000] init_memory_mapping: [mem 0x207c000000-0x207fdfffff]
[    0.000000]  [mem 0x207c000000-0x207fdfffff] page 1G
[    0.000000] init_memory_mapping: [mem 0x2000000000-0x207bffffff]
[    0.000000]  [mem 0x2000000000-0x207bffffff] page 1G
[    0.000000] init_memory_mapping: [mem 0x1000000000-0x1fffffffff]
[    0.000000]  [mem 0x1000000000-0x1fffffffff] page 1G
[    0.000000] init_memory_mapping: [mem 0x00100000-0x6509efff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x64ffffff] page 2M
[    0.000000]  [mem 0x65000000-0x6509efff] page 4k
[    0.000000] init_memory_mapping: [mem 0x65376000-0x65a6afff]
[    0.000000]  [mem 0x65376000-0x653fffff] page 4k
[    0.000000]  [mem 0x65400000-0x659fffff] page 2M
[    0.000000]  [mem 0x65a00000-0x65a6afff] page 4k
[    0.000000] BRK [0x0266f000, 0x0266ffff] PGTABLE
[    0.000000] BRK [0x02670000, 0x02670fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x65b2a000-0x65df8fff]
[    0.000000]  [mem 0x65b2a000-0x65df8fff] page 4k
[    0.000000] BRK [0x02671000, 0x02671fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x66df9000-0x7abcefff]
[    0.000000]  [mem 0x66df9000-0x66dfffff] page 4k
[    0.000000]  [mem 0x66e00000-0x7a9fffff] page 2M
[    0.000000]  [mem 0x7aa00000-0x7abcefff] page 4k
[    0.000000] init_memory_mapping: [mem 0x7b7ec000-0x7b7fffff]
[    0.000000]  [mem 0x7b7ec000-0x7b7fffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x100000000-0xfffffffff]
[    0.000000]  [mem 0x100000000-0xfffffffff] page 1G
[    0.000000] RAMDISK: [mem 0x6dbc4000-0x7abcefff]
[    0.000000] ACPI: RSDP 0x00000000000F0410 000024 (v02 INTEL )
[    0.000000] ACPI: XSDT 0x000000007B7EA0E8 0000AC (v01 INTEL  TIANO    00=
000000 MSFT 01000013)
[    0.000000] ACPI: FACP 0x000000007B7E7000 0000F4 (v04 INTEL  TIANO    00=
000000 MSFT 01000013)
[    0.000000] ACPI: DSDT 0x000000007B7B9000 022FFB (v02 INTEL  TIANO    00=
000003 MSFT 01000013)
[    0.000000] ACPI: FACS 0x000000007AE78000 000040
[    0.000000] ACPI: TCPA 0x000000007B7E9000 000064 (v02 INTEL  BRICKLAN 06=
222004 INTL 20121004)
[    0.000000] ACPI: BDAT 0x000000007B7E8000 000030 (v01 INTEL  TIANO    00=
000000 MSFT 01000013)
[    0.000000] ACPI: HPET 0x000000007B7E6000 000038 (v01 INTEL  TIANO    00=
000001 MSFT 01000013)
[    0.000000] ACPI: APIC 0x000000007B7E5000 00085C (v03 INTEL  TIANO    00=
000000 MSFT 01000013)
[    0.000000] ACPI: MCFG 0x000000007B7E4000 00003C (v01 INTEL  TIANO    00=
000001 MSFT 01000013)
[    0.000000] ACPI: MSCT 0x000000007B7E3000 000090 (v01 INTEL  TIANO    00=
000001 MSFT 01000013)
[    0.000000] ACPI: PCCT 0x000000007B7E2000 0000AC (v01 INTEL  TIANO    00=
000002 MSFT 01000013)
[    0.000000] ACPI: PMCT 0x000000007B7E1000 000060 (v01 INTEL  TIANO    00=
000000 MSFT 01000013)
[    0.000000] ACPI: RASF 0x000000007B7E0000 000030 (v01 INTEL  TIANO    00=
000001 MSFT 01000013)
[    0.000000] ACPI: SLIT 0x000000007B7DF000 00003C (v01 INTEL  TIANO    00=
000001 MSFT 01000013)
[    0.000000] ACPI: SRAT 0x000000007B7DE000 000E30 (v03 INTEL  TIANO    00=
000001 MSFT 01000013)
[    0.000000] ACPI: SVOS 0x000000007B7DD000 000032 (v01 INTEL  TIANO    00=
000000 MSFT 01000013)
[    0.000000] ACPI: WDDT 0x000000007B7DC000 000040 (v01 INTEL  TIANO    00=
000000 MSFT 01000013)
[    0.000000] ACPI: SSDT 0x0000000065A6B000 0BEF1B (v02 INTEL  SSDT  PM 00=
004000 INTL 20090521)
[    0.000000] ACPI: SSDT 0x000000007B7B8000 00008B (v02 INTEL  SpsNvs   00=
000002 INTL 20090521)
[    0.000000] ACPI: SPCR 0x000000007B7B7000 000050 (v01                 00=
000000      00000000)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5f3000 (        fee00000)
[    0.000000] SRAT: PXM 0 -> APIC 0x00 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x02 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x04 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x06 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x08 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0a -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0c -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0e -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x10 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x12 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x14 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x16 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x18 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x1a -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x1c -> Node 0
[    0.000000] SRAT: PXM 1 -> APIC 0x20 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x22 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x24 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x26 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x28 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x2a -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x2c -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x2e -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x30 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x32 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x34 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x36 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x38 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x3a -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x3c -> Node 1
[    0.000000] SRAT: PXM 2 -> APIC 0x40 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x42 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x44 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x46 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x48 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x4a -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x4c -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x4e -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x50 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x52 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x54 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x56 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x58 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x5a -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x5c -> Node 2
[    0.000000] SRAT: PXM 3 -> APIC 0x60 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x62 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x64 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x66 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x68 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x6a -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x6c -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x6e -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x70 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x72 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x74 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x76 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x78 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x7a -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x7c -> Node 3
[    0.000000] SRAT: PXM 0 -> APIC 0x01 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x03 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x05 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x07 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x09 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0b -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0d -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0f -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x11 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x13 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x15 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x17 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x19 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x1b -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x1d -> Node 0
[    0.000000] SRAT: PXM 1 -> APIC 0x21 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x23 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x25 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x27 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x29 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x2b -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x2d -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x2f -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x31 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x33 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x35 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x37 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x39 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x3b -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x3d -> Node 1
[    0.000000] SRAT: PXM 2 -> APIC 0x41 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x43 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x45 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x47 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x49 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x4b -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x4d -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x4f -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x51 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x53 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x55 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x57 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x59 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x5b -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x5d -> Node 2
[    0.000000] SRAT: PXM 3 -> APIC 0x61 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x63 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x65 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x67 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x69 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x6b -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x6d -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x6f -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x71 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x73 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x75 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x77 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x79 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x7b -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x7d -> Node 3
[    0.000000] SRAT: Node 0 PXM 0 [mem 0x00000000-0x7fffffff]
[    0.000000] SRAT: Node 0 PXM 0 [mem 0x100000000-0x87fffffff]
[    0.000000] SRAT: Node 1 PXM 1 [mem 0x880000000-0x107fffffff]
[    0.000000] SRAT: Node 2 PXM 2 [mem 0x1080000000-0x187fffffff]
[    0.000000] SRAT: Node 3 PXM 3 [mem 0x1880000000-0x207fffffff]
[    0.000000] NUMA: Initialized distance table, cnt=3D4
[    0.000000] NUMA: Node 0 [mem 0x00000000-0x7fffffff] + [mem 0x100000000-=
0x87fffffff] -> [mem 0x00000000-0x87fffffff]
[    0.000000] Initmem setup node 0 [mem 0x00000000-0x87fffffff]
[    0.000000]   NODE_DATA [mem 0x87fffb000-0x87fffffff]
[    0.000000] Initmem setup node 1 [mem 0x880000000-0x107fffffff]
[    0.000000]   NODE_DATA [mem 0x107fffb000-0x107fffffff]
[    0.000000] Initmem setup node 2 [mem 0x1080000000-0x187fffffff]
[    0.000000]   NODE_DATA [mem 0x187fffb000-0x187fffffff]
[    0.000000] Initmem setup node 3 [mem 0x1880000000-0x207fffffff]
[    0.000000]   NODE_DATA [mem 0x207fff5000-0x207fff9fff]
[    0.000000]  [ffffea0000000000-ffffea0021ffffff] PMD -> [ffff88085fe0000=
0-ffff88087fdfffff] on node 0
[    0.000000]  [ffffea0022000000-ffffea0041ffffff] PMD -> [ffff88105fe0000=
0-ffff88107fdfffff] on node 1
[    0.000000]  [ffffea0042000000-ffffea0061ffffff] PMD -> [ffff88185fe0000=
0-ffff88187fdfffff] on node 2
[    0.000000]  [ffffea0062000000-ffffea0081ffffff] PMD -> [ffff88205f60000=
0-ffff88207f5fffff] on node 3
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   [mem 0x100000000-0x207fffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009dfff]
[    0.000000]   node   0: [mem 0x00100000-0x6509efff]
[    0.000000]   node   0: [mem 0x65376000-0x65a6afff]
[    0.000000]   node   0: [mem 0x65b2a000-0x65df8fff]
[    0.000000]   node   0: [mem 0x66df9000-0x7abcefff]
[    0.000000]   node   0: [mem 0x7b7ec000-0x7b7fffff]
[    0.000000]   node   0: [mem 0x100000000-0x87fffffff]
[    0.000000]   node   1: [mem 0x880000000-0x107fffffff]
[    0.000000]   node   2: [mem 0x1080000000-0x187fffffff]
[    0.000000]   node   3: [mem 0x1880000000-0x207fffffff]
[    0.000000] On node 0 totalpages: 8361962
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 23 pages reserved
[    0.000000]   DMA zone: 3997 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 7714 pages used for memmap
[    0.000000]   DMA32 zone: 493645 pages, LIFO batch:31
[    0.000000]   Normal zone: 122880 pages used for memmap
[    0.000000]   Normal zone: 7864320 pages, LIFO batch:31
[    0.000000] On node 1 totalpages: 8388608
[    0.000000]   Normal zone: 131072 pages used for memmap
[    0.000000]   Normal zone: 8388608 pages, LIFO batch:31
[    0.000000] On node 2 totalpages: 8388608
[    0.000000]   Normal zone: 131072 pages used for memmap
[    0.000000]   Normal zone: 8388608 pages, LIFO batch:31
[    0.000000] On node 3 totalpages: 8388608
[    0.000000]   Normal zone: 131072 pages used for memmap
[    0.000000]   Normal zone: 8388608 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0x408
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5f3000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x04] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x06] lapic_id[0x06] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x08] lapic_id[0x08] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0a] lapic_id[0x0a] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0c] lapic_id[0x0c] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0e] lapic_id[0x0e] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x10] lapic_id[0x10] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x12] lapic_id[0x12] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x14] lapic_id[0x14] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x16] lapic_id[0x16] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x18] lapic_id[0x18] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1a] lapic_id[0x1a] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1c] lapic_id[0x1c] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x40] lapic_id[0x20] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x42] lapic_id[0x22] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x44] lapic_id[0x24] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x46] lapic_id[0x26] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x48] lapic_id[0x28] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x4a] lapic_id[0x2a] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x4c] lapic_id[0x2c] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x4e] lapic_id[0x2e] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x50] lapic_id[0x30] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x52] lapic_id[0x32] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x54] lapic_id[0x34] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x56] lapic_id[0x36] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x58] lapic_id[0x38] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x5a] lapic_id[0x3a] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x5c] lapic_id[0x3c] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x80] lapic_id[0x40] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x82] lapic_id[0x42] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x84] lapic_id[0x44] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x86] lapic_id[0x46] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x88] lapic_id[0x48] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x8a] lapic_id[0x4a] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x8c] lapic_id[0x4c] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x8e] lapic_id[0x4e] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x90] lapic_id[0x50] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x92] lapic_id[0x52] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x94] lapic_id[0x54] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x96] lapic_id[0x56] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x98] lapic_id[0x58] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x9a] lapic_id[0x5a] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x9c] lapic_id[0x5c] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xc0] lapic_id[0x60] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xc2] lapic_id[0x62] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xc4] lapic_id[0x64] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xc6] lapic_id[0x66] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xc8] lapic_id[0x68] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xca] lapic_id[0x6a] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xcc] lapic_id[0x6c] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xce] lapic_id[0x6e] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xd0] lapic_id[0x70] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xd2] lapic_id[0x72] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xd4] lapic_id[0x74] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xd6] lapic_id[0x76] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xd8] lapic_id[0x78] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xda] lapic_id[0x7a] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xdc] lapic_id[0x7c] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x03] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x05] lapic_id[0x05] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x07] lapic_id[0x07] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x09] lapic_id[0x09] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0b] lapic_id[0x0b] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0d] lapic_id[0x0d] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0f] lapic_id[0x0f] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x11] lapic_id[0x11] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x13] lapic_id[0x13] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x15] lapic_id[0x15] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x17] lapic_id[0x17] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x19] lapic_id[0x19] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1b] lapic_id[0x1b] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1d] lapic_id[0x1d] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x41] lapic_id[0x21] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x43] lapic_id[0x23] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x45] lapic_id[0x25] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x47] lapic_id[0x27] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x49] lapic_id[0x29] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x4b] lapic_id[0x2b] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x4d] lapic_id[0x2d] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x4f] lapic_id[0x2f] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x51] lapic_id[0x31] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x53] lapic_id[0x33] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x55] lapic_id[0x35] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x57] lapic_id[0x37] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x59] lapic_id[0x39] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x5b] lapic_id[0x3b] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x5d] lapic_id[0x3d] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x81] lapic_id[0x41] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x83] lapic_id[0x43] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x85] lapic_id[0x45] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x87] lapic_id[0x47] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x89] lapic_id[0x49] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x8b] lapic_id[0x4b] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x8d] lapic_id[0x4d] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x8f] lapic_id[0x4f] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x91] lapic_id[0x51] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x93] lapic_id[0x53] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x95] lapic_id[0x55] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x97] lapic_id[0x57] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x99] lapic_id[0x59] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x9b] lapic_id[0x5b] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x9d] lapic_id[0x5d] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xc1] lapic_id[0x61] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xc3] lapic_id[0x63] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xc5] lapic_id[0x65] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xc7] lapic_id[0x67] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xc9] lapic_id[0x69] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xcb] lapic_id[0x6b] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xcd] lapic_id[0x6d] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xcf] lapic_id[0x6f] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xd1] lapic_id[0x71] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xd3] lapic_id[0x73] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xd5] lapic_id[0x75] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xd7] lapic_id[0x77] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xd9] lapic_id[0x79] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xdb] lapic_id[0x7b] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xdd] lapic_id[0x7d] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0xff] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x02] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x03] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x04] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x05] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x06] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x07] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x08] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x09] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0a] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0b] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0c] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0d] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0e] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0f] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x10] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x11] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x12] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x13] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x14] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x15] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x16] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x17] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x18] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x19] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1a] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1b] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1c] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1d] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1e] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1f] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x20] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x21] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x22] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x23] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x24] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x25] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x26] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x27] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x28] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x29] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x2a] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x2b] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x2c] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x2d] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x2e] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x2f] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x30] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x31] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x32] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x33] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x34] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x35] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x36] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x37] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x38] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x39] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x3a] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x3b] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x3c] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x3d] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x3e] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x3f] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x40] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x41] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x42] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x43] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x44] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x45] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x46] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x47] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x48] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x49] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x4a] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x4b] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x4c] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x4d] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x4e] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x4f] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x50] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x51] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x52] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x53] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x54] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x55] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x56] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x57] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x58] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x59] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x5a] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x5b] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x5c] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x5d] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x5e] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x5f] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x60] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x61] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x62] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x63] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x64] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x65] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x66] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x67] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x68] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x69] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x6a] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x6b] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x6c] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x6d] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x6e] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x6f] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x70] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x71] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x72] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x73] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x74] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x75] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x76] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x77] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x78] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x79] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x7a] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x7b] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x7c] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x7c] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x7d] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x7e] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x7f] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x80] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x81] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x82] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x83] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x84] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x85] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x86] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x87] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x88] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x89] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x8a] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x8b] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x8c] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x8d] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x8f] high level lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x08] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 8, version 32, address 0xfec00000, GSI 0-=
23
[    0.000000] ACPI: IOAPIC (id[0x09] address[0xfec01000] gsi_base[24])
[    0.000000] IOAPIC[1]: apic_id 9, version 32, address 0xfec01000, GSI 24=
-47
[    0.000000] ACPI: IOAPIC (id[0x0a] address[0xfec40000] gsi_base[48])
[    0.000000] IOAPIC[2]: apic_id 10, version 32, address 0xfec40000, GSI 4=
8-71
[    0.000000] ACPI: IOAPIC (id[0x0b] address[0xfec80000] gsi_base[72])
[    0.000000] IOAPIC[3]: apic_id 11, version 32, address 0xfec80000, GSI 7=
2-95
[    0.000000] ACPI: IOAPIC (id[0x0c] address[0xfecc0000] gsi_base[96])
[    0.000000] IOAPIC[4]: apic_id 12, version 32, address 0xfecc0000, GSI 9=
6-119
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 8, APIC =
INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 8, APIC =
INT 09
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 8, APIC =
INT 01
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 8, APIC =
INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 8, APIC =
INT 04
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 05, APIC ID 8, APIC =
INT 05
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 8, APIC =
INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 8, APIC =
INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 8, APIC =
INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0a, APIC ID 8, APIC =
INT 0a
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0b, APIC ID 8, APIC =
INT 0b
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 8, APIC =
INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 8, APIC =
INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 8, APIC =
INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 8, APIC =
INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a301 base: 0xfed00000
[    0.000000] smpboot: Allowing 144 CPUs, 24 hotplug CPUs
[    0.000000] mapped IOAPIC to ffffffffff5f2000 (fec00000)
[    0.000000] mapped IOAPIC to ffffffffff5f1000 (fec01000)
[    0.000000] mapped IOAPIC to ffffffffff5f0000 (fec40000)
[    0.000000] mapped IOAPIC to ffffffffff5ef000 (fec80000)
[    0.000000] mapped IOAPIC to ffffffffff5ee000 (fecc0000)
[    0.000000] nr_irqs_gsi: 136
[    0.000000] PM: Registered nosave memory: [mem 0x0009e000-0x0009ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000dffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000e0000-0x000fffff]
[    0.000000] PM: Registered nosave memory: [mem 0x6509f000-0x65375fff]
[    0.000000] PM: Registered nosave memory: [mem 0x65a6b000-0x65b29fff]
[    0.000000] PM: Registered nosave memory: [mem 0x65df9000-0x66df8fff]
[    0.000000] PM: Registered nosave memory: [mem 0x7abcf000-0x7accefff]
[    0.000000] PM: Registered nosave memory: [mem 0x7accf000-0x7b6fefff]
[    0.000000] PM: Registered nosave memory: [mem 0x7b6ff000-0x7b7ebfff]
[    0.000000] PM: Registered nosave memory: [mem 0x7b800000-0x8fffffff]
[    0.000000] PM: Registered nosave memory: [mem 0x90000000-0xfed1bfff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed1c000-0xfed1ffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed20000-0xff7fffff]
[    0.000000] PM: Registered nosave memory: [mem 0xff800000-0xffffffff]
[    0.000000] e820: [mem 0x90000000-0xfed1bfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] setup_percpu: NR_CPUS:512 nr_cpumask_bits:512 nr_cpu_ids:144=
 nr_node_ids:4
[    0.000000] PERCPU: Embedded 27 pages/cpu @ffff88085f800000 s81088 r8192=
 d21312 u131072
[    0.000000] pcpu-alloc: s81088 r8192 d21312 u131072 alloc=3D1*2097152
[    0.000000] pcpu-alloc: [0] 000 001 002 003 004 005 006 007 008 009 010 =
011 012 013 014 060=20
[    0.000000] pcpu-alloc: [0] 061 062 063 064 065 066 067 068 069 070 071 =
072 073 074 120 124=20
[    0.000000] pcpu-alloc: [0] 128 132 136 140 --- --- --- --- --- --- --- =
--- --- --- --- ---=20
[    0.000000] pcpu-alloc: [1] 015 016 017 018 019 020 021 022 023 024 025 =
026 027 028 029 075=20
[    0.000000] pcpu-alloc: [1] 076 077 078 079 080 081 082 083 084 085 086 =
087 088 089 121 125=20
[    0.000000] pcpu-alloc: [1] 129 133 137 141 --- --- --- --- --- --- --- =
--- --- --- --- ---=20
[    0.000000] pcpu-alloc: [2] 030 031 032 033 034 035 036 037 038 039 040 =
041 042 043 044 090=20
[    0.000000] pcpu-alloc: [2] 091 092 093 094 095 096 097 098 099 100 101 =
102 103 104 122 126=20
[    0.000000] pcpu-alloc: [2] 130 134 138 142 --- --- --- --- --- --- --- =
--- --- --- --- ---=20
[    0.000000] pcpu-alloc: [3] 045 046 047 048 049 050 051 052 053 054 055 =
056 057 058 059 105=20
[    0.000000] pcpu-alloc: [3] 106 107 108 109 110 111 112 113 114 115 116 =
117 118 119 123 127=20
[    0.000000] pcpu-alloc: [3] 131 135 139 143 --- --- --- --- --- --- --- =
--- --- --- --- ---=20
[    0.000000] Built 4 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 33003889
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: user=3Dlkp job=3D/lkp/scheduled/brickla=
nd1/cyclic_will-it-scale-poll2-HEAD-8808b950581f71e3ee4cf8e6cae479f4c710640=
5.yaml ARCH=3Dx86_64 BOOT_IMAGE=3D/kernel/x86_64-lkp/8808b950581f71e3ee4cf8=
e6cae479f4c7106405/vmlinuz-3.14.0-rc6-next-20140317 kconfig=3Dx86_64-lkp co=
mmit=3D8808b950581f71e3ee4cf8e6cae479f4c7106405 bm_initrd=3D/lkp/benchmarks=
/will-it-scale.cgz modules_initrd=3D/kernel/x86_64-lkp/8808b950581f71e3ee4c=
f8e6cae479f4c7106405/modules.cgz max_uptime=3D900 RESULT_ROOT=3D/lkp/result=
/brickland1/micro/will-it-scale/poll2/x86_64-lkp/8808b950581f71e3ee4cf8e6ca=
e479f4c7106405/0 initrd=3D/kernel-tests/initrd/lkp-rootfs.cgz root=3D/dev/r=
am0 ip=3D::::brickland1::dhcp oops=3Dpanic ipmi_si.tryacpi=3D0 ipmi_watchdo=
g.start_now=3D1 earlyprintk=3DttyS0,115200 debug apic=3Ddebug sysrq_always_=
enabled rcupdate.rcu_cpu_stall_timeout=3D100 panic=3D10 softlockup_panic=3D=
1 nmi_watchdog=3Dpanic load_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,=
115200 console=3Dtty0 vga=3Dnormal
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] xsave: enabled xstate_bv 0x7, cntxt size 0x340
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Memory: 131695560K/134111144K available (10556K kernel code,=
 1268K rwdata, 4292K rodata, 1436K init, 1760K bss, 2415584K reserved)
[    0.000000] SLUB: HWalign=3D64, Order=3D0-3, MinObjects=3D0, CPUs=3D144,=
 Nodes=3D4
[    0.000000] Hierarchical RCU implementation.
[    0.000000] RCU dyntick-idle grace-period acceleration is enabled.
[    0.000000] RCU restricting CPUs from NR_CPUS=3D512 to nr_cpu_ids=3D144.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=3D16, nr_cpu_ids=
=3D144
[    0.000000] NR_IRQS:33024 nr_irqs:3464 16
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] bootconsole [earlyser0] disabled
[    0.000000] console [ttyS0] enabled
[    0.000000] allocated 536870912 bytes of page_cgroup
[    0.000000] please try 'cgroup_disable=3Dmemory' option if you don't wan=
t memory cgroups
[    0.000000] Disabling automatic NUMA balancing. Configure with numa_bala=
ncing=3D or the kernel.numa_balancing sysctl
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Fast TSC calibration failed
[    0.000000] tsc: Unable to calibrate against PIT
[    0.000000] tsc: using HPET reference calibration
[    0.000000] tsc: Detected 2799.804 MHz processor
[    0.000208] Calibrating delay loop (skipped), value calculated using tim=
er frequency.. 5599.60 BogoMIPS (lpj=3D11199216)
[    0.012589] pid_max: default: 147456 minimum: 1152
[    0.018219] ACPI: Core revision 20140214
[    0.439176] ACPI: All ACPI Tables successfully acquired
[    0.484298] Dentry cache hash table entries: 16777216 (order: 15, 134217=
728 bytes)
[    0.640363] Inode-cache hash table entries: 8388608 (order: 14, 67108864=
 bytes)
[    0.714667] Mount-cache hash table entries: 256
[    0.722652] Initializing cgroup subsys memory
[    0.728665] Initializing cgroup subsys devices
[    0.734632] Initializing cgroup subsys freezer
[    0.740603] Initializing cgroup subsys blkio
[    0.746363] Initializing cgroup subsys perf_event
[    0.752634] Initializing cgroup subsys hugetlb
[    0.758948] CPU: Physical Processor ID: 0
[    0.764404] CPU: Processor Core ID: 0
[    0.772772] mce: CPU supports 32 MCE banks
[    0.778517] CPU0: Thermal LVT vector (0xfa) already installed
[    0.786022] Last level iTLB entries: 4KB 512, 2MB 8, 4MB 8
[    0.786022] Last level dTLB entries: 4KB 512, 2MB 32, 4MB 32, 1GB 0
[    0.786022] tlb_flushall_shift: 6
[    0.806156] Freeing SMP alternatives memory: 44K (ffffffff824a6000 - fff=
fffff824b1000)
[    0.823130] ftrace: allocating 40687 entries in 159 pages
[    0.908590] Getting VERSION: 1060015
[    0.913562] Getting VERSION: 1060015
[    0.918542] Getting ID: 0
[    0.922461] Getting ID: 0
[    0.926381] Switched APIC routing to physical flat.
[    0.932815] masked ExtINT on CPU#0
[    0.939425] ENABLING IO-APIC IRQs
[    0.944110] init IO_APIC IRQs
[    0.948408]  apic 8 pin 0 not connected
[    0.953692] IOAPIC[0]: Set routing entry (8-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:0)
[    0.964363] IOAPIC[0]: Set routing entry (8-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:0)
[    0.975036] IOAPIC[0]: Set routing entry (8-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:0)
[    0.985760] IOAPIC[0]: Set routing entry (8-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:0)
[    0.996433] IOAPIC[0]: Set routing entry (8-5 -> 0x35 -> IRQ 5 Mode:0 Ac=
tive:0 Dest:0)
[    1.007123] IOAPIC[0]: Set routing entry (8-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:0)
[    1.017808] IOAPIC[0]: Set routing entry (8-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:0)
[    1.028483] IOAPIC[0]: Set routing entry (8-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:0)
[    1.039158] IOAPIC[0]: Set routing entry (8-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:0)
[    1.049831] IOAPIC[0]: Set routing entry (8-10 -> 0x3a -> IRQ 10 Mode:0 =
Active:0 Dest:0)
[    1.060719] IOAPIC[0]: Set routing entry (8-11 -> 0x3b -> IRQ 11 Mode:0 =
Active:0 Dest:0)
[    1.071598] IOAPIC[0]: Set routing entry (8-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:0)
[    1.082482] IOAPIC[0]: Set routing entry (8-13 -> 0x3d -> IRQ 13 Mode:0 =
Active:0 Dest:0)
[    1.093368] IOAPIC[0]: Set routing entry (8-14 -> 0x3e -> IRQ 14 Mode:0 =
Active:0 Dest:0)
[    1.104262] IOAPIC[0]: Set routing entry (8-15 -> 0x3f -> IRQ 15 Mode:0 =
Active:0 Dest:0)
[    1.115145]  apic 8 pin 16 not connected
[    1.120505]  apic 8 pin 17 not connected
[    1.125866]  apic 8 pin 18 not connected
[    1.131228]  apic 8 pin 19 not connected
[    1.136593]  apic 8 pin 20 not connected
[    1.141952]  apic 8 pin 21 not connected
[    1.147311]  apic 8 pin 22 not connected
[    1.152676]  apic 8 pin 23 not connected
[    1.158043]  apic 9 pin 0 not connected
[    1.163323]  apic 9 pin 1 not connected
[    1.168599]  apic 9 pin 2 not connected
[    1.173877]  apic 9 pin 3 not connected
[    1.179151]  apic 9 pin 4 not connected
[    1.184432]  apic 9 pin 5 not connected
[    1.189707]  apic 9 pin 6 not connected
[    1.194983]  apic 9 pin 7 not connected
[    1.200260]  apic 9 pin 8 not connected
[    1.205532]  apic 9 pin 9 not connected
[    1.210811]  apic 9 pin 10 not connected
[    1.216169]  apic 9 pin 11 not connected
[    1.221528]  apic 9 pin 12 not connected
[    1.226893]  apic 9 pin 13 not connected
[    1.232257]  apic 9 pin 14 not connected
[    1.237614]  apic 9 pin 15 not connected
[    1.242975]  apic 9 pin 16 not connected
[    1.248335]  apic 9 pin 17 not connected
[    1.253694]  apic 9 pin 18 not connected
[    1.259076]  apic 9 pin 19 not connected
[    1.264446]  apic 9 pin 20 not connected
[    1.269810]  apic 9 pin 21 not connected
[    1.275170]  apic 9 pin 22 not connected
[    1.280537]  apic 9 pin 23 not connected
[    1.285900]  apic 10 pin 0 not connected
[    1.291258]  apic 10 pin 1 not connected
[    1.296616]  apic 10 pin 2 not connected
[    1.301975]  apic 10 pin 3 not connected
[    1.307333]  apic 10 pin 4 not connected
[    1.312701]  apic 10 pin 5 not connected
[    1.318061]  apic 10 pin 6 not connected
[    1.323422]  apic 10 pin 7 not connected
[    1.328803]  apic 10 pin 8 not connected
[    1.334163]  apic 10 pin 9 not connected
[    1.339530]  apic 10 pin 10 not connected
[    1.345010]  apic 10 pin 11 not connected
[    1.350486]  apic 10 pin 12 not connected
[    1.355964]  apic 10 pin 13 not connected
[    1.361443]  apic 10 pin 14 not connected
[    1.366921]  apic 10 pin 15 not connected
[    1.372376]  apic 10 pin 16 not connected
[    1.377833]  apic 10 pin 17 not connected
[    1.383315]  apic 10 pin 18 not connected
[    1.388798]  apic 10 pin 19 not connected
[    1.394277]  apic 10 pin 20 not connected
[    1.399759]  apic 10 pin 21 not connected
[    1.405215]  apic 10 pin 22 not connected
[    1.410693]  apic 10 pin 23 not connected
[    1.416148]  apic 11 pin 0 not connected
[    1.421509]  apic 11 pin 1 not connected
[    1.426870]  apic 11 pin 2 not connected
[    1.432230]  apic 11 pin 3 not connected
[    1.437592]  apic 11 pin 4 not connected
[    1.442950]  apic 11 pin 5 not connected
[    1.448316]  apic 11 pin 6 not connected
[    1.453679]  apic 11 pin 7 not connected
[    1.459044]  apic 11 pin 8 not connected
[    1.464406]  apic 11 pin 9 not connected
[    1.469767]  apic 11 pin 10 not connected
[    1.475244]  apic 11 pin 11 not connected
[    1.480723]  apic 11 pin 12 not connected
[    1.486181]  apic 11 pin 13 not connected
[    1.491660]  apic 11 pin 14 not connected
[    1.497117]  apic 11 pin 15 not connected
[    1.502596]  apic 11 pin 16 not connected
[    1.508074]  apic 11 pin 17 not connected
[    1.513554]  apic 11 pin 18 not connected
[    1.519032]  apic 11 pin 19 not connected
[    1.524513]  apic 11 pin 20 not connected
[    1.529992]  apic 11 pin 21 not connected
[    1.535475]  apic 11 pin 22 not connected
[    1.540955]  apic 11 pin 23 not connected
[    1.546431]  apic 12 pin 0 not connected
[    1.551789]  apic 12 pin 1 not connected
[    1.557153]  apic 12 pin 2 not connected
[    1.562520]  apic 12 pin 3 not connected
[    1.567882]  apic 12 pin 4 not connected
[    1.573243]  apic 12 pin 5 not connected
[    1.578601]  apic 12 pin 6 not connected
[    1.583959]  apic 12 pin 7 not connected
[    1.589318]  apic 12 pin 8 not connected
[    1.594679]  apic 12 pin 9 not connected
[    1.600041]  apic 12 pin 10 not connected
[    1.605523]  apic 12 pin 11 not connected
[    1.610979]  apic 12 pin 12 not connected
[    1.616458]  apic 12 pin 13 not connected
[    1.621916]  apic 12 pin 14 not connected
[    1.627393]  apic 12 pin 15 not connected
[    1.632852]  apic 12 pin 16 not connected
[    1.638335]  apic 12 pin 17 not connected
[    1.643794]  apic 12 pin 18 not connected
[    1.649276]  apic 12 pin 19 not connected
[    1.654760]  apic 12 pin 20 not connected
[    1.660237]  apic 12 pin 21 not connected
[    1.665693]  apic 12 pin 22 not connected
[    1.671169]  apic 12 pin 23 not connected
[    1.676826] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    1.724478] smpboot: CPU0: Intel(R) Xeon(R) CPU E7-4890 V2 @ 2.80GHz (fa=
m: 06, model: 3e, stepping: 07)
[    1.737381] TSC deadline timer enabled
[    1.742691] Performance Events: PEBS fmt1+, 16-deep LBR, IvyBridge event=
s, full-width counters, Intel PMU driver.
[    1.756928] ... version:                3
[    1.762412] ... bit width:              48
[    1.767989] ... generic registers:      4
[    1.773449] ... value mask:             0000ffffffffffff
[    1.780411] ... max period:             0000ffffffffffff
[    1.787345] ... fixed-purpose events:   3
[    1.792793] ... event mask:             000000070000000f
[    1.814230] x86: Booting SMP configuration:
[    1.819891] .... node  #0, CPUs:          #1
[    1.847145] masked ExtINT on CPU#1
[    1.854815] CPU1: Thermal LVT vector (0xfa) already installed
[    1.864205]    #2
[    1.879455] masked ExtINT on CPU#2
[    1.887197] CPU2: Thermal LVT vector (0xfa) already installed
[    1.896603]    #3
[    1.912524] masked ExtINT on CPU#3
[    1.920260] CPU3: Thermal LVT vector (0xfa) already installed
[    1.929844]    #4
[    1.945011] masked ExtINT on CPU#4
[    1.952757] CPU4: Thermal LVT vector (0xfa) already installed
[    1.962240]    #5
[    1.977479] masked ExtINT on CPU#5
[    1.985484] CPU5: Thermal LVT vector (0xfa) already installed
[    1.994996]    #6
[    2.010212] masked ExtINT on CPU#6
[    2.018035] CPU6: Thermal LVT vector (0xfa) already installed
[    2.027549]    #7
[    2.043482] masked ExtINT on CPU#7
[    2.051311] CPU7: Thermal LVT vector (0xfa) already installed
[    2.060831]    #8
[    2.076054] masked ExtINT on CPU#8
[    2.083797] CPU8: Thermal LVT vector (0xfa) already installed
[    2.093307]    #9
[    2.108468] masked ExtINT on CPU#9
[    2.116197] CPU9: Thermal LVT vector (0xfa) already installed
[    2.125949]   #10
[    2.141097] masked ExtINT on CPU#10
[    2.148989] CPU10: Thermal LVT vector (0xfa) already installed
[    2.158520]   #11
[    2.174356] masked ExtINT on CPU#11
[    2.182078] CPU11: Thermal LVT vector (0xfa) already installed
[    2.191602]   #12
[    2.206733] masked ExtINT on CPU#12
[    2.214446] CPU12: Thermal LVT vector (0xfa) already installed
[    2.223989]   #13
[    2.238979] masked ExtINT on CPU#13
[    2.246620] CPU13: Thermal LVT vector (0xfa) already installed
[    2.256422]   #14
[    2.271539] masked ExtINT on CPU#14
[    2.279179] CPU14: Thermal LVT vector (0xfa) already installed
[    2.288971]=20
[    2.312444] .... node  #1, CPUs:    #15
[    2.335755] masked ExtINT on CPU#15
[    2.343425] CPU15: Thermal LVT vector (0xfa) already installed
[    2.449245] TSC synchronization [CPU#0 -> CPU#15]:
[    2.456389] Measured 23679 cycles TSC warp between CPUs, turning off TSC=
 clock.
[    2.466354] tsc: Marking TSC unstable due to check_tsc_sync_source failed
[    1.156009]   #16
[    0.004000] masked ExtINT on CPU#16
[    0.004000] CPU16: Thermal LVT vector (0xfa) already installed
[    1.186983]   #17
[    0.004000] masked ExtINT on CPU#17
[    0.004000] CPU17: Thermal LVT vector (0xfa) already installed
[    1.216120]   #18
[    0.004000] masked ExtINT on CPU#18
[    0.004000] CPU18: Thermal LVT vector (0xfa) already installed
[    1.246290]   #19
[    0.004000] masked ExtINT on CPU#19
[    0.004000] CPU19: Thermal LVT vector (0xfa) already installed
[    1.276179]   #20
[    0.004000] masked ExtINT on CPU#20
[    0.004000] CPU20: Thermal LVT vector (0xfa) already installed
[    1.307510]   #21
[    0.004000] masked ExtINT on CPU#21
[    0.004000] CPU21: Thermal LVT vector (0xfa) already installed
[    1.336217]   #22
[    0.004000] masked ExtINT on CPU#22
[    0.004000] CPU22: Thermal LVT vector (0xfa) already installed
[    1.366536]   #23
[    0.004000] masked ExtINT on CPU#23
[    0.004000] CPU23: Thermal LVT vector (0xfa) already installed
[    1.396331]   #24
[    0.004000] masked ExtINT on CPU#24
[    0.004000] CPU24: Thermal LVT vector (0xfa) already installed
[    1.427257]   #25
[    0.004000] masked ExtINT on CPU#25
[    0.004000] CPU25: Thermal LVT vector (0xfa) already installed
[    1.456085]   #26
[    0.004000] masked ExtINT on CPU#26
[    0.004000] CPU26: Thermal LVT vector (0xfa) already installed
[    1.486043]   #27
[    0.004000] masked ExtINT on CPU#27
[    0.004000] CPU27: Thermal LVT vector (0xfa) already installed
[    1.515758]   #28
[    0.004000] masked ExtINT on CPU#28
[    0.004000] CPU28: Thermal LVT vector (0xfa) already installed
[    1.543711]   #29
[    0.004000] masked ExtINT on CPU#29
[    0.004000] CPU29: Thermal LVT vector (0xfa) already installed
[    1.571934]=20
[    1.572004] .... node  #2, CPUs:    #30
[    0.004000] masked ExtINT on CPU#30
[    0.004000] CPU30: Thermal LVT vector (0xfa) already installed
[    1.684583]   #31
[    0.004000] masked ExtINT on CPU#31
[    0.004000] CPU31: Thermal LVT vector (0xfa) already installed
[    1.714709]   #32
[    0.004000] masked ExtINT on CPU#32
[    0.004000] CPU32: Thermal LVT vector (0xfa) already installed
[    1.744000]   #33
[    0.004000] masked ExtINT on CPU#33
[    0.004000] CPU33: Thermal LVT vector (0xfa) already installed
[    1.772087]   #34
[    0.004000] masked ExtINT on CPU#34
[    0.004000] CPU34: Thermal LVT vector (0xfa) already installed
[    1.802384]   #35
[    0.004000] masked ExtINT on CPU#35
[    0.004000] CPU35: Thermal LVT vector (0xfa) already installed
[    1.832429]   #36
[    0.004000] masked ExtINT on CPU#36
[    0.004000] CPU36: Thermal LVT vector (0xfa) already installed
[    1.863621]   #37
[    0.004000] masked ExtINT on CPU#37
[    0.004000] CPU37: Thermal LVT vector (0xfa) already installed
[    1.892162]   #38
[    0.004000] masked ExtINT on CPU#38
[    0.004000] CPU38: Thermal LVT vector (0xfa) already installed
[    1.922429]   #39
[    0.004000] masked ExtINT on CPU#39
[    0.004000] CPU39: Thermal LVT vector (0xfa) already installed
[    1.952164]   #40
[    0.004000] masked ExtINT on CPU#40
[    0.004000] CPU40: Thermal LVT vector (0xfa) already installed
[    1.983091]   #41
[    0.004000] masked ExtINT on CPU#41
[    0.004000] CPU41: Thermal LVT vector (0xfa) already installed
[    2.011955]   #42
[    0.004000] masked ExtINT on CPU#42
[    0.004000] CPU42: Thermal LVT vector (0xfa) already installed
[    2.039875]   #43
[    0.004000] masked ExtINT on CPU#43
[    0.004000] CPU43: Thermal LVT vector (0xfa) already installed
[    2.067816]   #44
[    0.004000] masked ExtINT on CPU#44
[    0.004000] CPU44: Thermal LVT vector (0xfa) already installed
[    2.095913]=20
[    2.096004] .... node  #3, CPUs:    #45
[    0.004000] masked ExtINT on CPU#45
[    0.004000] CPU45: Thermal LVT vector (0xfa) already installed
[    2.212830]   #46
[    0.004000] masked ExtINT on CPU#46
[    0.004000] CPU46: Thermal LVT vector (0xfa) already installed
[    2.242877]   #47
[    0.004000] masked ExtINT on CPU#47
[    0.004000] CPU47: Thermal LVT vector (0xfa) already installed
[    2.272130]   #48
[    0.004000] masked ExtINT on CPU#48
[    0.004000] CPU48: Thermal LVT vector (0xfa) already installed
[    2.302221]   #49
[    0.004000] masked ExtINT on CPU#49
[    0.004000] CPU49: Thermal LVT vector (0xfa) already installed
[    2.332134]   #50
[    0.004000] masked ExtINT on CPU#50
[    0.004000] CPU50: Thermal LVT vector (0xfa) already installed
[    2.362663]   #51
[    0.004000] masked ExtINT on CPU#51
[    0.004000] CPU51: Thermal LVT vector (0xfa) already installed
[    2.392210]   #52
[    0.004000] masked ExtINT on CPU#52
[    0.004000] CPU52: Thermal LVT vector (0xfa) already installed
[    2.422472]   #53
[    0.004000] masked ExtINT on CPU#53
[    0.004000] CPU53: Thermal LVT vector (0xfa) already installed
[    2.452252]   #54
[    0.004000] masked ExtINT on CPU#54
[    0.004000] CPU54: Thermal LVT vector (0xfa) already installed
[    2.482447]   #55
[    0.004000] masked ExtINT on CPU#55
[    0.004000] CPU55: Thermal LVT vector (0xfa) already installed
[    2.511976]   #56
[    0.004000] masked ExtINT on CPU#56
[    0.004000] CPU56: Thermal LVT vector (0xfa) already installed
[    2.539864]   #57
[    0.004000] masked ExtINT on CPU#57
[    0.004000] CPU57: Thermal LVT vector (0xfa) already installed
[    2.567873]   #58
[    0.004000] masked ExtINT on CPU#58
[    0.004000] CPU58: Thermal LVT vector (0xfa) already installed
[    2.595787]   #59
[    0.004000] masked ExtINT on CPU#59
[    0.004000] CPU59: Thermal LVT vector (0xfa) already installed
[    2.623793]=20
[    2.624004] .... node  #0, CPUs:    #60
[    0.004000] masked ExtINT on CPU#60
[    0.004000] CPU60: Thermal LVT vector (0xfa) already installed
[    2.656006]   #61
[    0.004000] masked ExtINT on CPU#61
[    0.004000] CPU61: Thermal LVT vector (0xfa) already installed
[    2.686504]   #62
[    0.004000] masked ExtINT on CPU#62
[    0.004000] CPU62: Thermal LVT vector (0xfa) already installed
[    2.716296]   #63
[    0.004000] masked ExtINT on CPU#63
[    0.004000] CPU63: Thermal LVT vector (0xfa) already installed
[    2.746919]   #64
[    0.004000] masked ExtINT on CPU#64
[    0.004000] CPU64: Thermal LVT vector (0xfa) already installed
[    2.776484]   #65
[    0.004000] masked ExtINT on CPU#65
[    0.004000] CPU65: Thermal LVT vector (0xfa) already installed
[    2.807300]   #66
[    0.004000] masked ExtINT on CPU#66
[    0.004000] CPU66: Thermal LVT vector (0xfa) already installed
[    2.836512]   #67
[    0.004000] masked ExtINT on CPU#67
[    0.004000] CPU67: Thermal LVT vector (0xfa) already installed
[    2.867225]   #68
[    0.004000] masked ExtINT on CPU#68
[    0.004000] CPU68: Thermal LVT vector (0xfa) already installed
[    2.896504]   #69
[    0.004000] masked ExtINT on CPU#69
[    0.004000] CPU69: Thermal LVT vector (0xfa) already installed
[    2.927101]   #70
[    0.004000] masked ExtINT on CPU#70
[    0.004000] CPU70: Thermal LVT vector (0xfa) already installed
[    2.956339]   #71
[    0.004000] masked ExtINT on CPU#71
[    0.004000] CPU71: Thermal LVT vector (0xfa) already installed
[    2.986541]   #72
[    0.004000] masked ExtINT on CPU#72
[    0.004000] CPU72: Thermal LVT vector (0xfa) already installed
[    3.016264]   #73
[    0.004000] masked ExtINT on CPU#73
[    0.004000] CPU73: Thermal LVT vector (0xfa) already installed
[    3.046585]   #74
[    0.004000] masked ExtINT on CPU#74
[    0.004000] CPU74: Thermal LVT vector (0xfa) already installed
[    3.076126]=20
[    3.078796] .... node  #1, CPUs:    #75
[    0.004000] masked ExtINT on CPU#75
[    0.004000] CPU75: Thermal LVT vector (0xfa) already installed
[    3.108740]   #76
[    0.004000] masked ExtINT on CPU#76
[    0.004000] CPU76: Thermal LVT vector (0xfa) already installed
[    3.138894]   #77
[    0.004000] masked ExtINT on CPU#77
[    0.004000] CPU77: Thermal LVT vector (0xfa) already installed
[    3.168177]   #78
[    0.004000] masked ExtINT on CPU#78
[    0.004000] CPU78: Thermal LVT vector (0xfa) already installed
[    3.198370]   #79
[    0.004000] masked ExtINT on CPU#79
[    0.004000] CPU79: Thermal LVT vector (0xfa) already installed
[    3.228164]   #80
[    0.004000] masked ExtINT on CPU#80
[    0.004000] CPU80: Thermal LVT vector (0xfa) already installed
[    3.258718]   #81
[    0.004000] masked ExtINT on CPU#81
[    0.004000] CPU81: Thermal LVT vector (0xfa) already installed
[    3.288256]   #82
[    0.004000] masked ExtINT on CPU#82
[    0.004000] CPU82: Thermal LVT vector (0xfa) already installed
[    3.318595]   #83
[    0.004000] masked ExtINT on CPU#83
[    0.004000] CPU83: Thermal LVT vector (0xfa) already installed
[    3.348129]   #84
[    0.004000] masked ExtINT on CPU#84
[    0.004000] CPU84: Thermal LVT vector (0xfa) already installed
[    3.378359]   #85
[    0.004000] masked ExtINT on CPU#85
[    0.004000] CPU85: Thermal LVT vector (0xfa) already installed
[    3.408051]   #86
[    0.004000] masked ExtINT on CPU#86
[    0.004000] CPU86: Thermal LVT vector (0xfa) already installed
[    3.438042]   #87
[    0.004000] masked ExtINT on CPU#87
[    0.004000] CPU87: Thermal LVT vector (0xfa) already installed
[    3.467847]   #88
[    0.004000] masked ExtINT on CPU#88
[    0.004000] CPU88: Thermal LVT vector (0xfa) already installed
[    3.495807]   #89
[    0.004000] masked ExtINT on CPU#89
[    0.004000] CPU89: Thermal LVT vector (0xfa) already installed
[    3.523912]=20
[    3.524004] .... node  #2, CPUs:    #90
[    0.004000] masked ExtINT on CPU#90
[    0.004000] CPU90: Thermal LVT vector (0xfa) already installed
[    3.555994]   #91
[    0.004000] masked ExtINT on CPU#91
[    0.004000] CPU91: Thermal LVT vector (0xfa) already installed
[    3.584175]   #92
[    0.004000] masked ExtINT on CPU#92
[    0.004000] CPU92: Thermal LVT vector (0xfa) already installed
[    3.615207]   #93
[    0.004000] masked ExtINT on CPU#93
[    0.004000] CPU93: Thermal LVT vector (0xfa) already installed
[    3.644127]   #94
[    0.004000] masked ExtINT on CPU#94
[    0.004000] CPU94: Thermal LVT vector (0xfa) already installed
[    3.674300]   #95
[    0.004000] masked ExtINT on CPU#95
[    0.004000] CPU95: Thermal LVT vector (0xfa) already installed
[    3.704498]   #96
[    0.004000] masked ExtINT on CPU#96
[    0.004000] CPU96: Thermal LVT vector (0xfa) already installed
[    3.735668]   #97
[    0.004000] masked ExtINT on CPU#97
[    0.004000] CPU97: Thermal LVT vector (0xfa) already installed
[    3.764299]   #98
[    0.004000] masked ExtINT on CPU#98
[    0.004000] CPU98: Thermal LVT vector (0xfa) already installed
[    3.794550]   #99
[    0.004000] masked ExtINT on CPU#99
[    0.004000] CPU99: Thermal LVT vector (0xfa) already installed
[    3.824222]  #100
[    0.004000] masked ExtINT on CPU#100
[    0.004000] CPU100: Thermal LVT vector (0xfa) already installed
[    3.855294]  #101
[    0.004000] masked ExtINT on CPU#101
[    0.004000] CPU101: Thermal LVT vector (0xfa) already installed
[    3.884213]  #102
[    0.004000] masked ExtINT on CPU#102
[    0.004000] CPU102: Thermal LVT vector (0xfa) already installed
[    3.914412]  #103
[    0.004000] masked ExtINT on CPU#103
[    0.004000] CPU103: Thermal LVT vector (0xfa) already installed
[    3.944047]  #104
[    0.004000] masked ExtINT on CPU#104
[    0.004000] CPU104: Thermal LVT vector (0xfa) already installed
[    3.975038]=20
[    3.976004] .... node  #3, CPUs:   #105
[    0.004000] masked ExtINT on CPU#105
[    0.004000] CPU105: Thermal LVT vector (0xfa) already installed
[    4.008174]  #106
[    0.004000] masked ExtINT on CPU#106
[    0.004000] CPU106: Thermal LVT vector (0xfa) already installed
[    4.038431]  #107
[    0.004000] masked ExtINT on CPU#107
[    0.004000] CPU107: Thermal LVT vector (0xfa) already installed
[    4.068377]  #108
[    0.004000] masked ExtINT on CPU#108
[    0.004000] CPU108: Thermal LVT vector (0xfa) already installed
[    4.098751]  #109
[    0.004000] masked ExtINT on CPU#109
[    0.004000] CPU109: Thermal LVT vector (0xfa) already installed
[    4.128375]  #110
[    0.004000] masked ExtINT on CPU#110
[    0.004000] CPU110: Thermal LVT vector (0xfa) already installed
[    4.159178]  #111
[    0.004000] masked ExtINT on CPU#111
[    0.004000] CPU111: Thermal LVT vector (0xfa) already installed
[    4.188424]  #112
[    0.004000] masked ExtINT on CPU#112
[    0.004000] CPU112: Thermal LVT vector (0xfa) already installed
[    4.218923]  #113
[    0.004000] masked ExtINT on CPU#113
[    0.004000] CPU113: Thermal LVT vector (0xfa) already installed
[    4.248448]  #114
[    0.004000] masked ExtINT on CPU#114
[    0.004000] CPU114: Thermal LVT vector (0xfa) already installed
[    4.278833]  #115
[    0.004000] masked ExtINT on CPU#115
[    0.004000] CPU115: Thermal LVT vector (0xfa) already installed
[    4.308336]  #116
[    0.004000] masked ExtINT on CPU#116
[    0.004000] CPU116: Thermal LVT vector (0xfa) already installed
[    4.338582]  #117
[    0.004000] masked ExtINT on CPU#117
[    0.004000] CPU117: Thermal LVT vector (0xfa) already installed
[    4.368083]  #118
[    0.004000] masked ExtINT on CPU#118
[    0.004000] CPU118: Thermal LVT vector (0xfa) already installed
[    4.398167]  #119
[    0.004000] masked ExtINT on CPU#119
[    0.004000] CPU119: Thermal LVT vector (0xfa) already installed
[    4.427667] x86: Booted up 4 nodes, 120 CPUs
[    4.428031] smpboot: Total of 120 processors activated (673812.06 BogoMI=
PS)
[    4.450106] devtmpfs: initialized
[    4.539022] PM: Registering ACPI NVS region [mem 0x6509f000-0x65375fff] =
(2977792 bytes)
[    4.540286] PM: Registering ACPI NVS region [mem 0x65df9000-0x66df8fff] =
(16777216 bytes)
[    4.545095] PM: Registering ACPI NVS region [mem 0x7accf000-0x7b6fefff] =
(10682368 bytes)
[    4.557402] xor: automatically using best checksumming function:
[    4.600004]    avx       :  4033.000 MB/sec
[    4.604128] atomic64 test passed for x86-64 platform with CX8 and with S=
SE
[    4.608625] NET: Registered protocol family 16
[    4.615389] cpuidle: using governor ladder
[    4.616004] cpuidle: using governor menu
[    4.622765] ACPI FADT declares the system doesn't support PCIe ASPM, so =
disable it
[    4.624004] ACPI: bus type PCI registered
[    4.628005] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    4.632328] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0x80000000=
-0x8fffffff] (base 0x80000000)
[    4.636006] PCI: MMCONFIG at [mem 0x80000000-0x8fffffff] reserved in E820
[    4.709854] PCI: Using configuration type 1 for base access
[    4.828036] raid6: sse2x1    1202 MB/s
[    4.900043] raid6: sse2x2    1552 MB/s
[    4.972035] raid6: sse2x4    2038 MB/s
[    4.976003] raid6: using algorithm sse2x4 (2038 MB/s)
[    4.980003] raid6: using ssse3x2 recovery algorithm
[    4.986012] ACPI: Added _OSI(Module Device)
[    4.988090] ACPI: Added _OSI(Processor Device)
[    4.992003] ACPI: Added _OSI(3.0 _SCP Extensions)
[    4.996003] ACPI: Added _OSI(Processor Aggregator Device)
[    5.544387] ACPI Error: Field [CPB3] at 96 exceeds Buffer [NULL] size 64=
 (bits) (20140214/dsopcode-236)
[    5.551534] ACPI Error: Method parse/execution failed [\_SB_._OSC] (Node=
 ffff88105f409c80), AE_AML_BUFFER_LIMIT (20140214/psparse-536)
[    5.695062] ACPI: Interpreter enabled
[    5.700069] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [=
\_S2_] (20140214/hwxface-580)
[    5.711438] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [=
\_S3_] (20140214/hwxface-580)
[    5.727454] ACPI: (supports S0 S1 S4 S5)
[    5.732003] ACPI: Using IOAPIC for interrupt routing
[    5.736176] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    5.949056] ACPI: PCI Root Bridge [UNC3] (domain 0000 [bus ff])
[    5.956036] acpi PNP0A03:00: _OSC: OS supports [ExtendedConfig ASPM Cloc=
kPM Segments MSI]
[    5.968010] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    5.976212] PCI host bridge to bus 0000:ff
[    5.980008] pci_bus 0000:ff: root bus resource [bus ff]
[    5.988069] pci 0000:ff:08.0: [8086:0e80] type 00 class 0x088000
[    5.996295] pci 0000:ff:08.2: [8086:0e32] type 00 class 0x110100
[    6.004292] pci 0000:ff:08.3: [8086:0e83] type 00 class 0x088000
[    6.012300] pci 0000:ff:08.4: [8086:0e84] type 00 class 0x088000
[    6.020308] pci 0000:ff:09.0: [8086:0e90] type 00 class 0x088000
[    6.028258] pci 0000:ff:09.2: [8086:0e33] type 00 class 0x110100
[    6.036254] pci 0000:ff:09.3: [8086:0e93] type 00 class 0x088000
[    6.044294] pci 0000:ff:09.4: [8086:0e94] type 00 class 0x088000
[    6.052300] pci 0000:ff:0a.0: [8086:0ec0] type 00 class 0x088000
[    6.060247] pci 0000:ff:0a.1: [8086:0ec1] type 00 class 0x088000
[    6.068257] pci 0000:ff:0a.2: [8086:0ec2] type 00 class 0x088000
[    6.076217] pci 0000:ff:0a.3: [8086:0ec3] type 00 class 0x088000
[    6.084252] pci 0000:ff:0b.0: [8086:0e1e] type 00 class 0x088000
[    6.092223] pci 0000:ff:0b.3: [8086:0e1f] type 00 class 0x088000
[    6.100256] pci 0000:ff:0c.0: [8086:0ee0] type 00 class 0x088000
[    6.108221] pci 0000:ff:0c.1: [8086:0ee2] type 00 class 0x088000
[    6.116219] pci 0000:ff:0c.2: [8086:0ee4] type 00 class 0x088000
[    6.124246] pci 0000:ff:0c.3: [8086:0ee6] type 00 class 0x088000
[    6.132246] pci 0000:ff:0c.4: [8086:0ee8] type 00 class 0x088000
[    6.140221] pci 0000:ff:0c.5: [8086:0eea] type 00 class 0x088000
[    6.148219] pci 0000:ff:0c.6: [8086:0eec] type 00 class 0x088000
[    6.156246] pci 0000:ff:0c.7: [8086:0eee] type 00 class 0x088000
[    6.164221] pci 0000:ff:0d.0: [8086:0ee1] type 00 class 0x088000
[    6.172215] pci 0000:ff:0d.1: [8086:0ee3] type 00 class 0x088000
[    6.180246] pci 0000:ff:0d.2: [8086:0ee5] type 00 class 0x088000
[    6.188221] pci 0000:ff:0d.3: [8086:0ee7] type 00 class 0x088000
[    6.196247] pci 0000:ff:0d.4: [8086:0ee9] type 00 class 0x088000
[    6.204262] pci 0000:ff:0d.5: [8086:0eeb] type 00 class 0x088000
[    6.212220] pci 0000:ff:0d.6: [8086:0eed] type 00 class 0x088000
[    6.216249] pci 0000:ff:0e.0: [8086:0ea0] type 00 class 0x088000
[    6.224250] pci 0000:ff:0e.1: [8086:0e30] type 00 class 0x110100
[    6.232292] pci 0000:ff:0f.0: [8086:0ea8] type 00 class 0x088000
[    6.240292] pci 0000:ff:0f.1: [8086:0e71] type 00 class 0x088000
[    6.248298] pci 0000:ff:0f.2: [8086:0eaa] type 00 class 0x088000
[    6.256294] pci 0000:ff:0f.3: [8086:0eab] type 00 class 0x088000
[    6.264292] pci 0000:ff:0f.4: [8086:0eac] type 00 class 0x088000
[    6.272295] pci 0000:ff:0f.5: [8086:0ead] type 00 class 0x088000
[    6.280293] pci 0000:ff:10.0: [8086:0eb0] type 00 class 0x088000
[    6.288295] pci 0000:ff:10.1: [8086:0eb1] type 00 class 0x088000
[    6.296292] pci 0000:ff:10.2: [8086:0eb2] type 00 class 0x088000
[    6.304298] pci 0000:ff:10.3: [8086:0eb3] type 00 class 0x088000
[    6.312290] pci 0000:ff:10.4: [8086:0eb4] type 00 class 0x088000
[    6.320294] pci 0000:ff:10.5: [8086:0eb5] type 00 class 0x088000
[    6.328292] pci 0000:ff:10.6: [8086:0eb6] type 00 class 0x088000
[    6.336292] pci 0000:ff:10.7: [8086:0eb7] type 00 class 0x088000
[    6.344292] pci 0000:ff:11.0: [8086:0ef8] type 00 class 0x088000
[    6.352328] pci 0000:ff:13.0: [8086:0e1d] type 00 class 0x088000
[    6.360217] pci 0000:ff:13.1: [8086:0e34] type 00 class 0x110100
[    6.368247] pci 0000:ff:13.4: [8086:0e81] type 00 class 0x088000
[    6.376251] pci 0000:ff:13.5: [8086:0e36] type 00 class 0x110100
[    6.384247] pci 0000:ff:13.6: [8086:0e37] type 00 class 0x110100
[    6.392260] pci 0000:ff:16.0: [8086:0ec8] type 00 class 0x088000
[    6.400255] pci 0000:ff:16.1: [8086:0ec9] type 00 class 0x088000
[    6.408249] pci 0000:ff:16.2: [8086:0eca] type 00 class 0x088000
[    6.416264] pci 0000:ff:18.0: [8086:0e40] type 00 class 0x088000
[    6.424260] pci 0000:ff:18.2: [8086:0e3a] type 00 class 0x110100
[    6.432262] pci 0000:ff:18.3: [8086:0e43] type 00 class 0x088000
[    6.440304] pci 0000:ff:18.4: [8086:0e44] type 00 class 0x088000
[    6.448335] pci 0000:ff:1c.0: [8086:0e60] type 00 class 0x088000
[    6.456252] pci 0000:ff:1c.1: [8086:0e38] type 00 class 0x110100
[    6.464300] pci 0000:ff:1d.0: [8086:0e68] type 00 class 0x088000
[    6.472302] pci 0000:ff:1d.1: [8086:0e79] type 00 class 0x088000
[    6.480336] pci 0000:ff:1d.2: [8086:0e6a] type 00 class 0x088000
[    6.488305] pci 0000:ff:1d.3: [8086:0e6b] type 00 class 0x088000
[    6.496305] pci 0000:ff:1d.4: [8086:0e6c] type 00 class 0x088000
[    6.504305] pci 0000:ff:1d.5: [8086:0e6d] type 00 class 0x088000
[    6.512331] pci 0000:ff:1e.0: [8086:0ef0] type 00 class 0x088000
[    6.520329] pci 0000:ff:1e.1: [8086:0ef1] type 00 class 0x088000
[    6.528301] pci 0000:ff:1e.2: [8086:0ef2] type 00 class 0x088000
[    6.536340] pci 0000:ff:1e.3: [8086:0ef3] type 00 class 0x088000
[    6.544304] pci 0000:ff:1e.4: [8086:0ef4] type 00 class 0x088000
[    6.552296] pci 0000:ff:1e.5: [8086:0ef5] type 00 class 0x088000
[    6.560301] pci 0000:ff:1e.6: [8086:0ef6] type 00 class 0x088000
[    6.568294] pci 0000:ff:1e.7: [8086:0ef7] type 00 class 0x088000
[    6.576330] pci 0000:ff:1f.0: [8086:0ed8] type 00 class 0x088000
[    6.584300] pci 0000:ff:1f.1: [8086:0ed9] type 00 class 0x088000
[    6.592330] pci 0000:ff:1f.4: [8086:0edc] type 00 class 0x088000
[    6.600294] pci 0000:ff:1f.5: [8086:0edd] type 00 class 0x088000
[    6.608299] pci 0000:ff:1f.6: [8086:0ede] type 00 class 0x088000
[    6.616299] pci 0000:ff:1f.7: [8086:0edf] type 00 class 0x088000
[    6.624509] ACPI: PCI Root Bridge [UNC2] (domain 0000 [bus bf])
[    6.632031] acpi PNP0A03:01: _OSC: OS supports [ExtendedConfig ASPM Cloc=
kPM Segments MSI]
[    6.644010] acpi PNP0A03:01: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    6.652209] PCI host bridge to bus 0000:bf
[    6.656006] pci_bus 0000:bf: root bus resource [bus bf]
[    6.664066] pci 0000:bf:08.0: [8086:0e80] type 00 class 0x088000
[    6.672260] pci 0000:bf:08.2: [8086:0e32] type 00 class 0x110100
[    6.680221] pci 0000:bf:08.3: [8086:0e83] type 00 class 0x088000
[    6.688292] pci 0000:bf:08.4: [8086:0e84] type 00 class 0x088000
[    6.716328] pci 0000:bf:09.0: [8086:0e90] type 00 class 0x088000
[    6.724256] pci 0000:bf:09.2: [8086:0e33] type 00 class 0x110100
[    6.732258] pci 0000:bf:09.3: [8086:0e93] type 00 class 0x088000
[    6.740292] pci 0000:bf:09.4: [8086:0e94] type 00 class 0x088000
[    6.748299] pci 0000:bf:0a.0: [8086:0ec0] type 00 class 0x088000
[    6.756249] pci 0000:bf:0a.1: [8086:0ec1] type 00 class 0x088000
[    6.764247] pci 0000:bf:0a.2: [8086:0ec2] type 00 class 0x088000
[    6.768249] pci 0000:bf:0a.3: [8086:0ec3] type 00 class 0x088000
[    6.776257] pci 0000:bf:0b.0: [8086:0e1e] type 00 class 0x088000
[    6.784254] pci 0000:bf:0b.3: [8086:0e1f] type 00 class 0x088000
[    6.792246] pci 0000:bf:0c.0: [8086:0ee0] type 00 class 0x088000
[    6.800254] pci 0000:bf:0c.1: [8086:0ee2] type 00 class 0x088000
[    6.808251] pci 0000:bf:0c.2: [8086:0ee4] type 00 class 0x088000
[    6.816253] pci 0000:bf:0c.3: [8086:0ee6] type 00 class 0x088000
[    6.824247] pci 0000:bf:0c.4: [8086:0ee8] type 00 class 0x088000
[    6.832258] pci 0000:bf:0c.5: [8086:0eea] type 00 class 0x088000
[    6.840249] pci 0000:bf:0c.6: [8086:0eec] type 00 class 0x088000
[    6.848245] pci 0000:bf:0c.7: [8086:0eee] type 00 class 0x088000
[    6.856224] pci 0000:bf:0d.0: [8086:0ee1] type 00 class 0x088000
[    6.864250] pci 0000:bf:0d.1: [8086:0ee3] type 00 class 0x088000
[    6.872247] pci 0000:bf:0d.2: [8086:0ee5] type 00 class 0x088000
[    6.880253] pci 0000:bf:0d.3: [8086:0ee7] type 00 class 0x088000
[    6.888218] pci 0000:bf:0d.4: [8086:0ee9] type 00 class 0x088000
[    6.896253] pci 0000:bf:0d.5: [8086:0eeb] type 00 class 0x088000
[    6.904249] pci 0000:bf:0d.6: [8086:0eed] type 00 class 0x088000
[    6.912290] pci 0000:bf:0e.0: [8086:0ea0] type 00 class 0x088000
[    6.920255] pci 0000:bf:0e.1: [8086:0e30] type 00 class 0x110100
[    6.928292] pci 0000:bf:0f.0: [8086:0ea8] type 00 class 0x088000
[    6.936296] pci 0000:bf:0f.1: [8086:0e71] type 00 class 0x088000
[    6.944300] pci 0000:bf:0f.2: [8086:0eaa] type 00 class 0x088000
[    6.952328] pci 0000:bf:0f.3: [8086:0eab] type 00 class 0x088000
[    6.960301] pci 0000:bf:0f.4: [8086:0eac] type 00 class 0x088000
[    6.968303] pci 0000:bf:0f.5: [8086:0ead] type 00 class 0x088000
[    6.976303] pci 0000:bf:10.0: [8086:0eb0] type 00 class 0x088000
[    6.984293] pci 0000:bf:10.1: [8086:0eb1] type 00 class 0x088000
[    6.992298] pci 0000:bf:10.2: [8086:0eb2] type 00 class 0x088000
[    7.000296] pci 0000:bf:10.3: [8086:0eb3] type 00 class 0x088000
[    7.008297] pci 0000:bf:10.4: [8086:0eb4] type 00 class 0x088000
[    7.016332] pci 0000:bf:10.5: [8086:0eb5] type 00 class 0x088000
[    7.024302] pci 0000:bf:10.6: [8086:0eb6] type 00 class 0x088000
[    7.032301] pci 0000:bf:10.7: [8086:0eb7] type 00 class 0x088000
[    7.040302] pci 0000:bf:11.0: [8086:0ef8] type 00 class 0x088000
[    7.048327] pci 0000:bf:13.0: [8086:0e1d] type 00 class 0x088000
[    7.056249] pci 0000:bf:13.1: [8086:0e34] type 00 class 0x110100
[    7.064254] pci 0000:bf:13.4: [8086:0e81] type 00 class 0x088000
[    7.072251] pci 0000:bf:13.5: [8086:0e36] type 00 class 0x110100
[    7.080219] pci 0000:bf:13.6: [8086:0e37] type 00 class 0x110100
[    7.088255] pci 0000:bf:16.0: [8086:0ec8] type 00 class 0x088000
[    7.096249] pci 0000:bf:16.1: [8086:0ec9] type 00 class 0x088000
[    7.104252] pci 0000:bf:16.2: [8086:0eca] type 00 class 0x088000
[    7.112288] pci 0000:bf:18.0: [8086:0e40] type 00 class 0x088000
[    7.120260] pci 0000:bf:18.2: [8086:0e3a] type 00 class 0x110100
[    7.128264] pci 0000:bf:18.3: [8086:0e43] type 00 class 0x088000
[    7.136331] pci 0000:bf:18.4: [8086:0e44] type 00 class 0x088000
[    7.144339] pci 0000:bf:1c.0: [8086:0e60] type 00 class 0x088000
[    7.152263] pci 0000:bf:1c.1: [8086:0e38] type 00 class 0x110100
[    7.160305] pci 0000:bf:1d.0: [8086:0e68] type 00 class 0x088000
[    7.168303] pci 0000:bf:1d.1: [8086:0e79] type 00 class 0x088000
[    7.176291] pci 0000:bf:1d.2: [8086:0e6a] type 00 class 0x088000
[    7.184303] pci 0000:bf:1d.3: [8086:0e6b] type 00 class 0x088000
[    7.192300] pci 0000:bf:1d.4: [8086:0e6c] type 00 class 0x088000
[    7.200333] pci 0000:bf:1d.5: [8086:0e6d] type 00 class 0x088000
[    7.208332] pci 0000:bf:1e.0: [8086:0ef0] type 00 class 0x088000
[    7.216298] pci 0000:bf:1e.1: [8086:0ef1] type 00 class 0x088000
[    7.224298] pci 0000:bf:1e.2: [8086:0ef2] type 00 class 0x088000
[    7.232008] pci 0000:bf:1e.3: [8086:0ef3] type 00 class 0x088000
[    7.240030] pci 0000:bf:1e.4: [8086:0ef4] type 00 class 0x088000
[    7.248031] pci 0000:bf:1e.5: [8086:0ef5] type 00 class 0x088000
[    7.252299] pci 0000:bf:1e.6: [8086:0ef6] type 00 class 0x088000
[    7.260296] pci 0000:bf:1e.7: [8086:0ef7] type 00 class 0x088000
[    7.268291] pci 0000:bf:1f.0: [8086:0ed8] type 00 class 0x088000
[    7.276299] pci 0000:bf:1f.1: [8086:0ed9] type 00 class 0x088000
[    7.284332] pci 0000:bf:1f.4: [8086:0edc] type 00 class 0x088000
[    7.292331] pci 0000:bf:1f.5: [8086:0edd] type 00 class 0x088000
[    7.300329] pci 0000:bf:1f.6: [8086:0ede] type 00 class 0x088000
[    7.308303] pci 0000:bf:1f.7: [8086:0edf] type 00 class 0x088000
[    7.316509] ACPI: PCI Root Bridge [UNC1] (domain 0000 [bus 7f])
[    7.324009] acpi PNP0A03:02: _OSC: OS supports [ExtendedConfig ASPM Cloc=
kPM Segments MSI]
[    7.336009] acpi PNP0A03:02: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    7.344210] PCI host bridge to bus 0000:7f
[    7.352006] pci_bus 0000:7f: root bus resource [bus 7f]
[    7.356045] pci 0000:7f:08.0: [8086:0e80] type 00 class 0x088000
[    7.364253] pci 0000:7f:08.2: [8086:0e32] type 00 class 0x110100
[    7.372255] pci 0000:7f:08.3: [8086:0e83] type 00 class 0x088000
[    7.380299] pci 0000:7f:08.4: [8086:0e84] type 00 class 0x088000
[    7.388300] pci 0000:7f:09.0: [8086:0e90] type 00 class 0x088000
[    7.396221] pci 0000:7f:09.2: [8086:0e33] type 00 class 0x110100
[    7.404258] pci 0000:7f:09.3: [8086:0e93] type 00 class 0x088000
[    7.412295] pci 0000:7f:09.4: [8086:0e94] type 00 class 0x088000
[    7.420299] pci 0000:7f:0a.0: [8086:0ec0] type 00 class 0x088000
[    7.428250] pci 0000:7f:0a.1: [8086:0ec1] type 00 class 0x088000
[    7.436250] pci 0000:7f:0a.2: [8086:0ec2] type 00 class 0x088000
[    7.444249] pci 0000:7f:0a.3: [8086:0ec3] type 00 class 0x088000
[    7.452252] pci 0000:7f:0b.0: [8086:0e1e] type 00 class 0x088000
[    7.460226] pci 0000:7f:0b.3: [8086:0e1f] type 00 class 0x088000
[    7.468249] pci 0000:7f:0c.0: [8086:0ee0] type 00 class 0x088000
[    7.476249] pci 0000:7f:0c.1: [8086:0ee2] type 00 class 0x088000
[    7.484245] pci 0000:7f:0c.2: [8086:0ee4] type 00 class 0x088000
[    7.492217] pci 0000:7f:0c.3: [8086:0ee6] type 00 class 0x088000
[    7.500250] pci 0000:7f:0c.4: [8086:0ee8] type 00 class 0x088000
[    7.508249] pci 0000:7f:0c.5: [8086:0eea] type 00 class 0x088000
[    7.516250] pci 0000:7f:0c.6: [8086:0eec] type 00 class 0x088000
[    7.524246] pci 0000:7f:0c.7: [8086:0eee] type 00 class 0x088000
[    7.532249] pci 0000:7f:0d.0: [8086:0ee1] type 00 class 0x088000
[    7.540246] pci 0000:7f:0d.1: [8086:0ee3] type 00 class 0x088000
[    7.548252] pci 0000:7f:0d.2: [8086:0ee5] type 00 class 0x088000
[    7.556254] pci 0000:7f:0d.3: [8086:0ee7] type 00 class 0x088000
[    7.564257] pci 0000:7f:0d.4: [8086:0ee9] type 00 class 0x088000
[    7.572256] pci 0000:7f:0d.5: [8086:0eeb] type 00 class 0x088000
[    7.580249] pci 0000:7f:0d.6: [8086:0eed] type 00 class 0x088000
[    7.588218] pci 0000:7f:0e.0: [8086:0ea0] type 00 class 0x088000
[    7.596254] pci 0000:7f:0e.1: [8086:0e30] type 00 class 0x110100
[    7.604304] pci 0000:7f:0f.0: [8086:0ea8] type 00 class 0x088000
[    7.612299] pci 0000:7f:0f.1: [8086:0e71] type 00 class 0x088000
[    7.620302] pci 0000:7f:0f.2: [8086:0eaa] type 00 class 0x088000
[    7.628297] pci 0000:7f:0f.3: [8086:0eab] type 00 class 0x088000
[    7.636300] pci 0000:7f:0f.4: [8086:0eac] type 00 class 0x088000
[    7.644299] pci 0000:7f:0f.5: [8086:0ead] type 00 class 0x088000
[    7.652301] pci 0000:7f:10.0: [8086:0eb0] type 00 class 0x088000
[    7.660298] pci 0000:7f:10.1: [8086:0eb1] type 00 class 0x088000
[    7.668293] pci 0000:7f:10.2: [8086:0eb2] type 00 class 0x088000
[    7.676305] pci 0000:7f:10.3: [8086:0eb3] type 00 class 0x088000
[    7.684292] pci 0000:7f:10.4: [8086:0eb4] type 00 class 0x088000
[    7.688297] pci 0000:7f:10.5: [8086:0eb5] type 00 class 0x088000
[    7.696293] pci 0000:7f:10.6: [8086:0eb6] type 00 class 0x088000
[    7.704298] pci 0000:7f:10.7: [8086:0eb7] type 00 class 0x088000
[    7.712293] pci 0000:7f:11.0: [8086:0ef8] type 00 class 0x088000
[    7.720304] pci 0000:7f:13.0: [8086:0e1d] type 00 class 0x088000
[    7.728247] pci 0000:7f:13.1: [8086:0e34] type 00 class 0x110100
[    7.736255] pci 0000:7f:13.4: [8086:0e81] type 00 class 0x088000
[    7.744255] pci 0000:7f:13.5: [8086:0e36] type 00 class 0x110100
[    7.752247] pci 0000:7f:13.6: [8086:0e37] type 00 class 0x110100
[    7.760260] pci 0000:7f:16.0: [8086:0ec8] type 00 class 0x088000
[    7.768254] pci 0000:7f:16.1: [8086:0ec9] type 00 class 0x088000
[    7.776245] pci 0000:7f:16.2: [8086:0eca] type 00 class 0x088000
[    7.784265] pci 0000:7f:18.0: [8086:0e40] type 00 class 0x088000
[    7.792256] pci 0000:7f:18.2: [8086:0e3a] type 00 class 0x110100
[    7.800257] pci 0000:7f:18.3: [8086:0e43] type 00 class 0x088000
[    7.808298] pci 0000:7f:18.4: [8086:0e44] type 00 class 0x088000
[    7.816343] pci 0000:7f:1c.0: [8086:0e60] type 00 class 0x088000
[    7.824264] pci 0000:7f:1c.1: [8086:0e38] type 00 class 0x110100
[    7.832327] pci 0000:7f:1d.0: [8086:0e68] type 00 class 0x088000
[    7.840305] pci 0000:7f:1d.1: [8086:0e79] type 00 class 0x088000
[    7.848303] pci 0000:7f:1d.2: [8086:0e6a] type 00 class 0x088000
[    7.856299] pci 0000:7f:1d.3: [8086:0e6b] type 00 class 0x088000
[    7.864299] pci 0000:7f:1d.4: [8086:0e6c] type 00 class 0x088000
[    7.872297] pci 0000:7f:1d.5: [8086:0e6d] type 00 class 0x088000
[    7.880334] pci 0000:7f:1e.0: [8086:0ef0] type 00 class 0x088000
[    7.888303] pci 0000:7f:1e.1: [8086:0ef1] type 00 class 0x088000
[    7.896304] pci 0000:7f:1e.2: [8086:0ef2] type 00 class 0x088000
[    7.904302] pci 0000:7f:1e.3: [8086:0ef3] type 00 class 0x088000
[    7.912300] pci 0000:7f:1e.4: [8086:0ef4] type 00 class 0x088000
[    7.920298] pci 0000:7f:1e.5: [8086:0ef5] type 00 class 0x088000
[    7.928300] pci 0000:7f:1e.6: [8086:0ef6] type 00 class 0x088000
[    7.936340] pci 0000:7f:1e.7: [8086:0ef7] type 00 class 0x088000
[    7.944333] pci 0000:7f:1f.0: [8086:0ed8] type 00 class 0x088000
[    7.952303] pci 0000:7f:1f.1: [8086:0ed9] type 00 class 0x088000
[    7.960336] pci 0000:7f:1f.4: [8086:0edc] type 00 class 0x088000
[    7.968293] pci 0000:7f:1f.5: [8086:0edd] type 00 class 0x088000
[    7.976296] pci 0000:7f:1f.6: [8086:0ede] type 00 class 0x088000
[    7.984300] pci 0000:7f:1f.7: [8086:0edf] type 00 class 0x088000
[    7.992504] ACPI: PCI Root Bridge [UNC0] (domain 0000 [bus 3f])
[    8.000009] acpi PNP0A03:03: _OSC: OS supports [ExtendedConfig ASPM Cloc=
kPM Segments MSI]
[    8.012009] acpi PNP0A03:03: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    8.020207] PCI host bridge to bus 0000:3f
[    8.024006] pci_bus 0000:3f: root bus resource [bus 3f]
[    8.032040] pci 0000:3f:08.0: [8086:0e80] type 00 class 0x088000
[    8.040261] pci 0000:3f:08.2: [8086:0e32] type 00 class 0x110100
[    8.048250] pci 0000:3f:08.3: [8086:0e83] type 00 class 0x088000
[    8.056291] pci 0000:3f:08.4: [8086:0e84] type 00 class 0x088000
[    8.064288] pci 0000:3f:09.0: [8086:0e90] type 00 class 0x088000
[    8.072256] pci 0000:3f:09.2: [8086:0e33] type 00 class 0x110100
[    8.080249] pci 0000:3f:09.3: [8086:0e93] type 00 class 0x088000
[    8.088288] pci 0000:3f:09.4: [8086:0e94] type 00 class 0x088000
[    8.096290] pci 0000:3f:0a.0: [8086:0ec0] type 00 class 0x088000
[    8.104247] pci 0000:3f:0a.1: [8086:0ec1] type 00 class 0x088000
[    8.112220] pci 0000:3f:0a.2: [8086:0ec2] type 00 class 0x088000
[    8.120222] pci 0000:3f:0a.3: [8086:0ec3] type 00 class 0x088000
[    8.148246] pci 0000:3f:0b.0: [8086:0e1e] type 00 class 0x088000
[    8.156221] pci 0000:3f:0b.3: [8086:0e1f] type 00 class 0x088000
[    8.164244] pci 0000:3f:0c.0: [8086:0ee0] type 00 class 0x088000
[    8.172247] pci 0000:3f:0c.1: [8086:0ee2] type 00 class 0x088000
[    8.180220] pci 0000:3f:0c.2: [8086:0ee4] type 00 class 0x088000
[    8.188219] pci 0000:3f:0c.3: [8086:0ee6] type 00 class 0x088000
[    8.192247] pci 0000:3f:0c.4: [8086:0ee8] type 00 class 0x088000
[    8.200248] pci 0000:3f:0c.5: [8086:0eea] type 00 class 0x088000
[    8.208212] pci 0000:3f:0c.6: [8086:0eec] type 00 class 0x088000
[    8.216222] pci 0000:3f:0c.7: [8086:0eee] type 00 class 0x088000
[    8.224254] pci 0000:3f:0d.0: [8086:0ee1] type 00 class 0x088000
[    8.232225] pci 0000:3f:0d.1: [8086:0ee3] type 00 class 0x088000
[    8.240222] pci 0000:3f:0d.2: [8086:0ee5] type 00 class 0x088000
[    8.248251] pci 0000:3f:0d.3: [8086:0ee7] type 00 class 0x088000
[    8.256244] pci 0000:3f:0d.4: [8086:0ee9] type 00 class 0x088000
[    8.264245] pci 0000:3f:0d.5: [8086:0eeb] type 00 class 0x088000
[    8.272217] pci 0000:3f:0d.6: [8086:0eed] type 00 class 0x088000
[    8.280246] pci 0000:3f:0e.0: [8086:0ea0] type 00 class 0x088000
[    8.288253] pci 0000:3f:0e.1: [8086:0e30] type 00 class 0x110100
[    8.296294] pci 0000:3f:0f.0: [8086:0ea8] type 00 class 0x088000
[    8.304288] pci 0000:3f:0f.1: [8086:0e71] type 00 class 0x088000
[    8.312335] pci 0000:3f:0f.2: [8086:0eaa] type 00 class 0x088000
[    8.320300] pci 0000:3f:0f.3: [8086:0eab] type 00 class 0x088000
[    8.328303] pci 0000:3f:0f.4: [8086:0eac] type 00 class 0x088000
[    8.336294] pci 0000:3f:0f.5: [8086:0ead] type 00 class 0x088000
[    8.344299] pci 0000:3f:10.0: [8086:0eb0] type 00 class 0x088000
[    8.352296] pci 0000:3f:10.1: [8086:0eb1] type 00 class 0x088000
[    8.360295] pci 0000:3f:10.2: [8086:0eb2] type 00 class 0x088000
[    8.368301] pci 0000:3f:10.3: [8086:0eb3] type 00 class 0x088000
[    8.376301] pci 0000:3f:10.4: [8086:0eb4] type 00 class 0x088000
[    8.384300] pci 0000:3f:10.5: [8086:0eb5] type 00 class 0x088000
[    8.392298] pci 0000:3f:10.6: [8086:0eb6] type 00 class 0x088000
[    8.400262] pci 0000:3f:10.7: [8086:0eb7] type 00 class 0x088000
[    8.408295] pci 0000:3f:11.0: [8086:0ef8] type 00 class 0x088000
[    8.416334] pci 0000:3f:13.0: [8086:0e1d] type 00 class 0x088000
[    8.424256] pci 0000:3f:13.1: [8086:0e34] type 00 class 0x110100
[    8.432258] pci 0000:3f:13.4: [8086:0e81] type 00 class 0x088000
[    8.440254] pci 0000:3f:13.5: [8086:0e36] type 00 class 0x110100
[    8.448248] pci 0000:3f:13.6: [8086:0e37] type 00 class 0x110100
[    8.456254] pci 0000:3f:16.0: [8086:0ec8] type 00 class 0x088000
[    8.464225] pci 0000:3f:16.1: [8086:0ec9] type 00 class 0x088000
[    8.472249] pci 0000:3f:16.2: [8086:0eca] type 00 class 0x088000
[    8.480257] pci 0000:3f:18.0: [8086:0e40] type 00 class 0x088000
[    8.488260] pci 0000:3f:18.2: [8086:0e3a] type 00 class 0x110100
[    8.496249] pci 0000:3f:18.3: [8086:0e43] type 00 class 0x088000
[    8.504291] pci 0000:3f:18.4: [8086:0e44] type 00 class 0x088000
[    8.512329] pci 0000:3f:1c.0: [8086:0e60] type 00 class 0x088000
[    8.520257] pci 0000:3f:1c.1: [8086:0e38] type 00 class 0x110100
[    8.528292] pci 0000:3f:1d.0: [8086:0e68] type 00 class 0x088000
[    8.536297] pci 0000:3f:1d.1: [8086:0e79] type 00 class 0x088000
[    8.544299] pci 0000:3f:1d.2: [8086:0e6a] type 00 class 0x088000
[    8.552297] pci 0000:3f:1d.3: [8086:0e6b] type 00 class 0x088000
[    8.560298] pci 0000:3f:1d.4: [8086:0e6c] type 00 class 0x088000
[    8.568292] pci 0000:3f:1d.5: [8086:0e6d] type 00 class 0x088000
[    8.576300] pci 0000:3f:1e.0: [8086:0ef0] type 00 class 0x088000
[    8.584296] pci 0000:3f:1e.1: [8086:0ef1] type 00 class 0x088000
[    8.592261] pci 0000:3f:1e.2: [8086:0ef2] type 00 class 0x088000
[    8.600301] pci 0000:3f:1e.3: [8086:0ef3] type 00 class 0x088000
[    8.608292] pci 0000:3f:1e.4: [8086:0ef4] type 00 class 0x088000
[    8.616303] pci 0000:3f:1e.5: [8086:0ef5] type 00 class 0x088000
[    8.624292] pci 0000:3f:1e.6: [8086:0ef6] type 00 class 0x088000
[    8.632295] pci 0000:3f:1e.7: [8086:0ef7] type 00 class 0x088000
[    8.640288] pci 0000:3f:1f.0: [8086:0ed8] type 00 class 0x088000
[    8.648337] pci 0000:3f:1f.1: [8086:0ed9] type 00 class 0x088000
[    8.652334] pci 0000:3f:1f.4: [8086:0edc] type 00 class 0x088000
[    8.660297] pci 0000:3f:1f.5: [8086:0edd] type 00 class 0x088000
[    8.668297] pci 0000:3f:1f.6: [8086:0ede] type 00 class 0x088000
[    8.676297] pci 0000:3f:1f.7: [8086:0edf] type 00 class 0x088000
[    8.806810] ACPI: PCI Root Bridge [IIO0] (domain 0000 [bus 00-3e])
[    8.816035] acpi PNP0A08:00: _OSC: OS supports [ExtendedConfig ASPM Cloc=
kPM Segments MSI]
[    8.828429] acpi PNP0A08:00: _OSC: platform does not support [PCIeHotplu=
g]
[    8.836384] acpi PNP0A08:00: _OSC: OS now controls [PME AER PCIeCapabili=
ty]
[    8.845421] acpi PNP0A08:00: ignoring host bridge window [mem 0x000c4000=
-0x000cbfff] (conflicts with Video ROM [mem 0x000c0000-0x000c7fff])
[    8.865177] PCI host bridge to bus 0000:00
[    8.868006] pci_bus 0000:00: root bus resource [bus 00-3e]
[    8.876006] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    8.884027] pci_bus 0000:00: root bus resource [io  0x1000-0x3fff]
[    8.892004] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f]
[    8.900004] pci_bus 0000:00: root bus resource [mem 0xfed40000-0xfedffff=
f]
[    8.908004] pci_bus 0000:00: root bus resource [mem 0x90000000-0xabffbff=
f]
[    8.916004] pci_bus 0000:00: root bus resource [mem 0x380000000000-0x381=
fffffffff]
[    8.928042] pci 0000:00:00.0: [8086:0e00] type 00 class 0x060000
[    8.936212] pci 0000:00:00.0: PME# supported from D0 D3hot D3cold
[    8.944477] pci 0000:00:02.0: [8086:0e04] type 01 class 0x060400
[    8.952246] pci 0000:00:02.0: PME# supported from D0 D3hot D3cold
[    8.960260] pci 0000:00:02.0: System wakeup disabled by ACPI
[    8.968220] pci 0000:00:03.0: [8086:0e08] type 01 class 0x060400
[    8.976220] pci 0000:00:03.0: PME# supported from D0 D3hot D3cold
[    8.984289] pci 0000:00:03.0: System wakeup disabled by ACPI
[    8.992218] pci 0000:00:03.2: [8086:0e0a] type 01 class 0x060400
[    9.000220] pci 0000:00:03.2: PME# supported from D0 D3hot D3cold
[    9.008257] pci 0000:00:03.2: System wakeup disabled by ACPI
[    9.016212] pci 0000:00:03.3: [8086:0e0b] type 01 class 0x060400
[    9.020245] pci 0000:00:03.3: PME# supported from D0 D3hot D3cold
[    9.028287] pci 0000:00:03.3: System wakeup disabled by ACPI
[    9.036212] pci 0000:00:05.0: [8086:0e28] type 00 class 0x088000
[    9.044547] pci 0000:00:05.1: [8086:0e29] type 00 class 0x088000
[    9.052598] pci 0000:00:05.2: [8086:0e2a] type 00 class 0x088000
[    9.060543] pci 0000:00:05.4: [8086:0e2c] type 00 class 0x080020
[    9.068040] pci 0000:00:05.4: reg 0x10: [mem 0x93406000-0x93406fff]
[    9.076591] pci 0000:00:11.0: [8086:1d3e] type 01 class 0x060400
[    9.088288] pci 0000:00:11.0: PME# supported from D0 D3hot D3cold
[    9.096471] pci 0000:00:1a.0: [8086:1d2d] type 00 class 0x0c0320
[    9.104079] pci 0000:00:1a.0: reg 0x10: [mem 0x93402000-0x934023ff]
[    9.112255] pci 0000:00:1a.0: PME# supported from D0 D3hot D3cold
[    9.120428] pci 0000:00:1c.0: [8086:1d10] type 01 class 0x060400
[    9.128299] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    9.136295] pci 0000:00:1c.0: System wakeup disabled by ACPI
[    9.144247] pci 0000:00:1c.7: [8086:1d1e] type 01 class 0x060400
[    9.148245] pci 0000:00:1c.7: PME# supported from D0 D3hot D3cold
[    9.156255] pci 0000:00:1c.7: System wakeup disabled by ACPI
[    9.164217] pci 0000:00:1d.0: [8086:1d26] type 00 class 0x0c0320
[    9.172054] pci 0000:00:1d.0: reg 0x10: [mem 0x93401000-0x934013ff]
[    9.180256] pci 0000:00:1d.0: PME# supported from D0 D3hot D3cold
[    9.188431] pci 0000:00:1e.0: [8086:244e] type 01 class 0x060401
[    9.196376] pci 0000:00:1e.0: System wakeup disabled by ACPI
[    9.204216] pci 0000:00:1f.0: [8086:1d41] type 00 class 0x060100
[    9.212682] pci 0000:00:1f.2: [8086:1d02] type 00 class 0x010601
[    9.220053] pci 0000:00:1f.2: reg 0x10: [io  0x2058-0x205f]
[    9.228037] pci 0000:00:1f.2: reg 0x14: [io  0x207c-0x207f]
[    9.236015] pci 0000:00:1f.2: reg 0x18: [io  0x2040-0x2047]
[    9.244035] pci 0000:00:1f.2: reg 0x1c: [io  0x2048-0x204b]
[    9.252036] pci 0000:00:1f.2: reg 0x20: [io  0x2020-0x203f]
[    9.256036] pci 0000:00:1f.2: reg 0x24: [mem 0x93400000-0x934007ff]
[    9.264137] pci 0000:00:1f.2: PME# supported from D3hot
[    9.272429] pci 0000:00:1f.3: [8086:1d22] type 00 class 0x0c0500
[    9.280047] pci 0000:00:1f.3: reg 0x10: [mem 0x381ffff00000-0x381ffff000=
ff 64bit]
[    9.292054] pci 0000:00:1f.3: reg 0x20: [io  0x2000-0x201f]
[    9.300208] acpiphp: Slot [8] registered
[    9.304123] pci 0000:01:00.0: [1000:0087] type 00 class 0x010700
[    9.312038] pci 0000:01:00.0: reg 0x10: [io  0x1000-0x10ff]
[    9.320015] pci 0000:01:00.0: reg 0x14: [mem 0x93340000-0x9334ffff 64bit]
[    9.328014] pci 0000:01:00.0: reg 0x1c: [mem 0x93300000-0x9333ffff 64bit]
[    9.336040] pci 0000:01:00.0: reg 0x30: [mem 0xfff00000-0xffffffff pref]
[    9.344123] pci 0000:01:00.0: supports D1 D2
[    9.352288] pci 0000:00:02.0: PCI bridge to [bus 01]
[    9.356008] pci 0000:00:02.0:   bridge window [io  0x1000-0x1fff]
[    9.364009] pci 0000:00:02.0:   bridge window [mem 0x93300000-0x933fffff]
[    9.372032] pci 0000:00:02.0:   bridge window [mem 0x90000000-0x900fffff=
 64bit pref]
[    9.384759] acpiphp: Slot [2] registered
[    9.392088] pci 0000:00:03.0: PCI bridge to [bus 02]
[    9.396724] acpiphp: Slot [1] registered
[    9.404130] pci 0000:03:00.0: [8086:1528] type 00 class 0x020000
[    9.412044] pci 0000:03:00.0: reg 0x10: [mem 0x92c00000-0x92dfffff 64bit=
 pref]
[    9.420080] pci 0000:03:00.0: reg 0x20: [mem 0x92e04000-0x92e07fff 64bit=
 pref]
[    9.432035] pci 0000:03:00.0: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[    9.440130] pci 0000:03:00.0: PME# supported from D0 D3hot
[    9.448082] pci 0000:03:00.0: reg 0x184: [mem 0x93100000-0x93103fff 64bi=
t]
[    9.456041] pci 0000:03:00.0: reg 0x190: [mem 0x93200000-0x93203fff 64bi=
t]
[    9.464298] pci 0000:03:00.1: [8086:1528] type 00 class 0x020000
[    9.472043] pci 0000:03:00.1: reg 0x10: [mem 0x92a00000-0x92bfffff 64bit=
 pref]
[    9.480054] pci 0000:03:00.1: reg 0x20: [mem 0x92e00000-0x92e03fff 64bit=
 pref]
[    9.492038] pci 0000:03:00.1: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[    9.500130] pci 0000:03:00.1: PME# supported from D0 D3hot
[    9.508080] pci 0000:03:00.1: reg 0x184: [mem 0x92f00000-0x92f03fff 64bi=
t]
[    9.516042] pci 0000:03:00.1: reg 0x190: [mem 0x93000000-0x93003fff 64bi=
t]
[    9.532045] pci 0000:00:03.2: PCI bridge to [bus 03-04]
[    9.540033] pci 0000:00:03.2:   bridge window [mem 0x92f00000-0x932fffff]
[    9.548032] pci 0000:00:03.2:   bridge window [mem 0x92a00000-0x92efffff=
 64bit pref]
[    9.560117] acpiphp: Slot [0] registered
[    9.564092] pci 0000:00:03.3: PCI bridge to [bus 05]
[    9.572331] pci 0000:00:11.0: PCI bridge to [bus 06]
[    9.576320] pci 0000:00:1c.0: PCI bridge to [bus 07]
[    9.584335] pci 0000:08:00.0: [102b:0522] type 00 class 0x030000
[    9.592054] pci 0000:08:00.0: reg 0x10: [mem 0x91000000-0x91ffffff pref]
[    9.600045] pci 0000:08:00.0: reg 0x14: [mem 0x92800000-0x92803fff]
[    9.608044] pci 0000:08:00.0: reg 0x18: [mem 0x92000000-0x927fffff]
[    9.616165] pci 0000:08:00.0: reg 0x30: [mem 0xffff0000-0xffffffff pref]
[    9.632047] pci 0000:00:1c.7: PCI bridge to [bus 08]
[    9.640034] pci 0000:00:1c.7:   bridge window [mem 0x92000000-0x928fffff]
[    9.668033] pci 0000:00:1c.7:   bridge window [mem 0x91000000-0x91ffffff=
 64bit pref]
[    9.680256] pci 0000:00:1e.0: PCI bridge to [bus 09] (subtractive decode)
[    9.688038] pci 0000:00:1e.0:   bridge window [io  0x0000-0x0cf7] (subtr=
active decode)
[    9.700005] pci 0000:00:1e.0:   bridge window [io  0x1000-0x3fff] (subtr=
active decode)
[    9.708005] pci 0000:00:1e.0:   bridge window [mem 0x000a0000-0x000bffff=
] (subtractive decode)
[    9.720004] pci 0000:00:1e.0:   bridge window [mem 0xfed40000-0xfedfffff=
] (subtractive decode)
[    9.732004] pci 0000:00:1e.0:   bridge window [mem 0x90000000-0xabffbfff=
] (subtractive decode)
[    9.744004] pci 0000:00:1e.0:   bridge window [mem 0x380000000000-0x381f=
ffffffff] (subtractive decode)
[    9.756133] acpi PNP0A08:00: Disabling ASPM (FADT indicates it is unsupp=
orted)
[    9.764670] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 9 10 11 12 1=
4 15) *0, disabled.
[    9.780179] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 9 10 11 12 1=
4 15) *0, disabled.
[    9.792175] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 9 10 11 12 1=
4 15) *0, disabled.
[    9.808173] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 9 10 11 12 1=
4 15) *0, disabled.
[    9.820172] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 9 10 11 12 1=
4 15) *0, disabled.
[    9.836172] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 9 10 11 12 1=
4 15) *0, disabled.
[    9.848172] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 9 10 11 12 1=
4 15) *0, disabled.
[    9.864174] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 7 9 10 11 12 1=
4 15) *0, disabled.
[    9.876667] ACPI: PCI Root Bridge [IIO1] (domain 0000 [bus 40-7e])
[    9.884036] acpi PNP0A08:01: _OSC: OS supports [ExtendedConfig ASPM Cloc=
kPM Segments MSI]
[    9.896010] acpi PNP0A08:01: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    9.904717] PCI host bridge to bus 0000:40
[    9.912007] pci_bus 0000:40: root bus resource [bus 40-7e]
[    9.916005] pci_bus 0000:40: root bus resource [io  0x4000-0x7fff]
[    9.924004] pci_bus 0000:40: root bus resource [mem 0xac000000-0xc7ffbff=
f]
[    9.936004] pci_bus 0000:40: root bus resource [mem 0x382000000000-0x383=
fffffffff]
[    9.944049] pci 0000:40:02.0: [8086:0e04] type 01 class 0x060400
[    9.952252] pci 0000:40:02.0: PME# supported from D0 D3hot D3cold
[    9.960173] pci 0000:40:02.0: System wakeup disabled by ACPI
[    9.968250] pci 0000:40:02.2: [8086:0e06] type 01 class 0x060400
[    9.976250] pci 0000:40:02.2: PME# supported from D0 D3hot D3cold
[    9.984171] pci 0000:40:02.2: System wakeup disabled by ACPI
[    9.992219] pci 0000:40:03.0: [8086:0e08] type 01 class 0x060400
[   10.000221] pci 0000:40:03.0: PME# supported from D0 D3hot D3cold
[   10.008180] pci 0000:40:03.0: System wakeup disabled by ACPI
[   10.016209] pci 0000:40:05.0: [8086:0e28] type 00 class 0x088000
[   10.024460] pci 0000:40:05.1: [8086:0e29] type 00 class 0x088000
[   10.032505] pci 0000:40:05.2: [8086:0e2a] type 00 class 0x088000
[   10.040463] pci 0000:40:05.4: [8086:0e2c] type 00 class 0x080020
[   10.048041] pci 0000:40:05.4: reg 0x10: [mem 0xac000000-0xac000fff]
[   10.057259] acpiphp: Slot [5] registered
[   10.060089] pci 0000:40:02.0: PCI bridge to [bus 41]
[   10.068008] pci 0000:40:02.0:   bridge window [io  0x4000-0x4fff]
[   10.076007] pci 0000:40:02.0:   bridge window [mem 0xac100000-0xac2fffff]
[   10.084009] pci 0000:40:02.0:   bridge window [mem 0xac300000-0xac4fffff=
 64bit pref]
[   10.096738] acpiphp: Slot [7] registered
[   10.100122] pci 0000:40:02.2: PCI bridge to [bus 42]
[   10.108030] pci 0000:40:02.2:   bridge window [io  0x5000-0x5fff]
[   10.116007] pci 0000:40:02.2:   bridge window [mem 0xac500000-0xac6fffff]
[   10.124032] pci 0000:40:02.2:   bridge window [mem 0xac700000-0xac8fffff=
 64bit pref]
[   10.136055] acpiphp: Slot [6] registered
[   10.140087] pci 0000:40:03.0: PCI bridge to [bus 43]
[   10.148615] ACPI: PCI Root Bridge [IIO2] (domain 0000 [bus 80-be])
[   10.156009] acpi PNP0A08:02: _OSC: OS supports [ExtendedConfig ASPM Cloc=
kPM Segments MSI]
[   10.164009] acpi PNP0A08:02: _OSC failed (AE_NOT_FOUND); disabling ASPM
[   10.172085] acpi PNP0A08:02: ignoring host bridge window [io  0x4558-0xf=
fff] (conflicts with PCI Bus 0000:40 [io  0x4000-0x7fff])
[   10.188660] PCI host bridge to bus 0000:80
[   10.196006] pci_bus 0000:80: root bus resource [bus 80-be]
[   10.204005] pci_bus 0000:80: root bus resource [mem 0xc8000000-0xe3ffbff=
f]
[   10.212005] pci_bus 0000:80: root bus resource [mem 0x384000000000-0x385=
fffffffff]
[   10.220048] pci 0000:80:02.0: [8086:0e04] type 01 class 0x060400
[   10.228252] pci 0000:80:02.0: PME# supported from D0 D3hot D3cold
[   10.236174] pci 0000:80:02.0: System wakeup disabled by ACPI
[   10.244220] pci 0000:80:02.2: [8086:0e06] type 01 class 0x060400
[   10.252251] pci 0000:80:02.2: PME# supported from D0 D3hot D3cold
[   10.260170] pci 0000:80:02.2: System wakeup disabled by ACPI
[   10.268219] pci 0000:80:03.0: [8086:0e08] type 01 class 0x060400
[   10.276247] pci 0000:80:03.0: PME# supported from D0 D3hot D3cold
[   10.284169] pci 0000:80:03.0: System wakeup disabled by ACPI
[   10.292207] pci 0000:80:05.0: [8086:0e28] type 00 class 0x088000
[   10.300460] pci 0000:80:05.1: [8086:0e29] type 00 class 0x088000
[   10.308506] pci 0000:80:05.2: [8086:0e2a] type 00 class 0x088000
[   10.316463] pci 0000:80:05.4: [8086:0e2c] type 00 class 0x080020
[   10.324040] pci 0000:80:05.4: reg 0x10: [mem 0xc8000000-0xc8000fff]
[   10.333254] acpiphp: Slot [4] registered
[   10.336089] pci 0000:80:02.0: PCI bridge to [bus 81]
[   10.344759] acpiphp: Slot [3] registered
[   10.352088] pci 0000:80:02.2: PCI bridge to [bus 82]
[   10.356751] acpiphp: Slot [9] registered
[   10.364087] pci 0000:80:03.0: PCI bridge to [bus 83]
[   10.368612] ACPI: PCI Root Bridge [IIO3] (domain 0000 [bus c0-fe])
[   10.376009] acpi PNP0A08:03: _OSC: OS supports [ExtendedConfig ASPM Cloc=
kPM Segments MSI]
[   10.388009] acpi PNP0A08:03: _OSC failed (AE_NOT_FOUND); disabling ASPM
[   10.396716] PCI host bridge to bus 0000:c0
[   10.404010] pci_bus 0000:c0: root bus resource [bus c0-fe]
[   10.412005] pci_bus 0000:c0: root bus resource [io  0xc000-0xffff]
[   10.420004] pci_bus 0000:c0: root bus resource [mem 0xe4000000-0xfbffbff=
f]
[   10.428004] pci_bus 0000:c0: root bus resource [mem 0x386000000000-0x387=
fffffffff]
[   10.436047] pci 0000:c0:02.0: [8086:0e04] type 01 class 0x060400
[   10.444254] pci 0000:c0:02.0: PME# supported from D0 D3hot D3cold
[   10.452173] pci 0000:c0:02.0: System wakeup disabled by ACPI
[   10.460216] pci 0000:c0:02.2: [8086:0e06] type 01 class 0x060400
[   10.468250] pci 0000:c0:02.2: PME# supported from D0 D3hot D3cold
[   10.476171] pci 0000:c0:02.2: System wakeup disabled by ACPI
[   10.484214] pci 0000:c0:03.0: [8086:0e08] type 01 class 0x060400
[   10.492246] pci 0000:c0:03.0: PME# supported from D0 D3hot D3cold
[   10.500167] pci 0000:c0:03.0: System wakeup disabled by ACPI
[   10.508213] pci 0000:c0:05.0: [8086:0e28] type 00 class 0x088000
[   10.516461] pci 0000:c0:05.1: [8086:0e29] type 00 class 0x088000
[   10.524510] pci 0000:c0:05.2: [8086:0e2a] type 00 class 0x088000
[   10.532426] pci 0000:c0:05.4: [8086:0e2c] type 00 class 0x080020
[   10.540040] pci 0000:c0:05.4: reg 0x10: [mem 0xe4000000-0xe4000fff]
[   10.549270] acpiphp: Slot [12] registered
[   10.552088] pci 0000:c0:02.0: PCI bridge to [bus c1]
[   10.560008] pci 0000:c0:02.0:   bridge window [io  0xc000-0xcfff]
[   10.568007] pci 0000:c0:02.0:   bridge window [mem 0xe4100000-0xe42fffff]
[   10.576032] pci 0000:c0:02.0:   bridge window [mem 0xe4300000-0xe44fffff=
 64bit pref]
[   10.588750] acpiphp: Slot [10] registered
[   10.592110] pci 0000:c0:02.2: PCI bridge to [bus c2]
[   10.600007] pci 0000:c0:02.2:   bridge window [io  0xd000-0xdfff]
[   10.608007] pci 0000:c0:02.2:   bridge window [mem 0xe4500000-0xe46fffff]
[   10.616032] pci 0000:c0:02.2:   bridge window [mem 0xe4700000-0xe48fffff=
 64bit pref]
[   10.628725] acpiphp: Slot [11] registered
[   10.632121] pci 0000:c0:03.0: PCI bridge to [bus c3]
[   10.640664] ACPI: Enabled 3 GPEs in block 00 to 3F
[   10.648837] vgaarb: device added: PCI:0000:08:00.0,decodes=3Dio+mem,owns=
=3Dio+mem,locks=3Dnone
[   10.660047] vgaarb: loaded
[   10.664004] vgaarb: bridge control possible 0000:08:00.0
[   10.672132] SCSI subsystem initialized
[   10.677214] libata version 3.00 loaded.
[   10.684462] ACPI: bus type USB registered
[   10.688178] usbcore: registered new interface driver usbfs
[   10.696079] usbcore: registered new interface driver hub
[   10.704133] usbcore: registered new device driver usb
[   10.708246] pps_core: LinuxPPS API ver. 1 registered
[   10.716004] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[   10.728040] PTP clock support registered
[   10.737061] EDAC MC: Ver: 3.0.0
[   10.744224] PCI: Using ACPI for IRQ routing
[   10.760663] PCI: pci_cache_line_size set to 64 bytes
[   10.769915] e820: reserve RAM buffer [mem 0x0009e000-0x0009ffff]
[   10.776031] e820: reserve RAM buffer [mem 0x6509f000-0x67ffffff]
[   10.784004] e820: reserve RAM buffer [mem 0x65a6b000-0x67ffffff]
[   10.792004] e820: reserve RAM buffer [mem 0x65df9000-0x67ffffff]
[   10.800003] e820: reserve RAM buffer [mem 0x7abcf000-0x7bffffff]
[   10.808004] e820: reserve RAM buffer [mem 0x7b800000-0x7bffffff]
[   10.819564] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0, 0, 0, 0, 0
[   10.828004] hpet0: 8 comparators, 64-bit 14.318180 MHz counter
[   10.840723] Switched to clocksource hpet
[   10.847250] Could not create debugfs 'set_ftrace_filter' entry
[   10.854834] Could not create debugfs 'set_ftrace_notrace' entry
[   10.920179] pnp: PnP ACPI init
[   10.924685] ACPI: bus type PNP registered
[   10.975373] pnp 00:00: Plug and Play ACPI device, IDs PNP0c80 (active)
[   11.028535] pnp 00:01: Plug and Play ACPI device, IDs PNP0c80 (active)
[   11.081585] pnp 00:02: Plug and Play ACPI device, IDs PNP0c80 (active)
[   11.134659] pnp 00:03: Plug and Play ACPI device, IDs PNP0c80 (active)
[   11.143638] pnp 00:04: Plug and Play ACPI device, IDs PNP0003 (active)
[   11.153059] pnp 00:05: [dma 4]
[   11.157732] pnp 00:05: Plug and Play ACPI device, IDs PNP0200 (active)
[   11.166133] IOAPIC[0]: Set routing entry (8-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:0)
[   11.197505] pnp 00:06: Plug and Play ACPI device, IDs PNP0b00 (active)
[   11.205886] IOAPIC[0]: Set routing entry (8-13 -> 0x3d -> IRQ 13 Mode:0 =
Active:0 Dest:0)
[   11.216999] pnp 00:07: Plug and Play ACPI device, IDs PNP0c04 (active)
[   11.225568] pnp 00:08: Plug and Play ACPI device, IDs PNP0800 (active)
[   11.234226] pnp 00:09: Plug and Play ACPI device, IDs PNP0103 (active)
[   11.243682] system 00:0a: [io  0x0500-0x053f] has been reserved
[   11.251368] system 00:0a: [io  0x0400-0x047f] could not be reserved
[   11.259453] system 00:0a: [io  0x0540-0x057f] has been reserved
[   11.267106] system 00:0a: [io  0x0600-0x061f] has been reserved
[   11.274755] system 00:0a: [io  0x0ca0-0x0ca5] has been reserved
[   11.282397] system 00:0a: [io  0x0880-0x0883] has been reserved
[   11.290066] system 00:0a: [io  0x0800-0x081f] has been reserved
[   11.297715] system 00:0a: [mem 0xfed1c000-0xfed3ffff] could not be reser=
ved
[   11.306541] system 00:0a: [mem 0xfed45000-0xfed8bfff] has been reserved
[   11.314982] system 00:0a: [mem 0xff000000-0xffffffff] could not be reser=
ved
[   11.323804] system 00:0a: [mem 0xfee00000-0xfeefffff] has been reserved
[   11.332238] system 00:0a: [mem 0xfed12000-0xfed1200f] has been reserved
[   11.340675] system 00:0a: [mem 0xfed12010-0xfed1201f] has been reserved
[   11.349144] system 00:0a: [mem 0xfed1b000-0xfed1bfff] has been reserved
[   11.357596] system 00:0a: Plug and Play ACPI device, IDs PNP0c02 (active)
[   11.366665] IOAPIC[0]: Set routing entry (8-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:0)
[   11.377722] pnp 00:0b: Plug and Play ACPI device, IDs PNP0501 (active)
[   11.386399] IOAPIC[0]: Set routing entry (8-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:0)
[   11.397438] pnp 00:0c: Plug and Play ACPI device, IDs PNP0501 (active)
[   11.406063] pnp 00:0d: Plug and Play ACPI device, IDs IPI0001 (active)
[   11.416344] pnp: PnP ACPI: found 14 devices
[   11.422048] ACPI: bus type PNP unregistered
[   11.446603] pci 0000:01:00.0: can't claim BAR 6 [mem 0xfff00000-0xffffff=
ff pref]: no compatible bridge window
[   11.459607] pci 0000:03:00.0: can't claim BAR 6 [mem 0xfff80000-0xffffff=
ff pref]: no compatible bridge window
[   11.472522] pci 0000:03:00.1: can't claim BAR 6 [mem 0xfff80000-0xffffff=
ff pref]: no compatible bridge window
[   11.485496] pci 0000:08:00.0: can't claim BAR 6 [mem 0xffff0000-0xffffff=
ff pref]: no compatible bridge window
[   11.499134] pci 0000:01:00.0: BAR 6: assigned [mem 0x90000000-0x900fffff=
 pref]
[   11.509079] pci 0000:00:02.0: PCI bridge to [bus 01]
[   11.515671] pci 0000:00:02.0:   bridge window [io  0x1000-0x1fff]
[   11.523530] pci 0000:00:02.0:   bridge window [mem 0x93300000-0x933fffff]
[   11.532172] pci 0000:00:02.0:   bridge window [mem 0x90000000-0x900fffff=
 64bit pref]
[   11.542712] pci 0000:00:03.0: PCI bridge to [bus 02]
[   11.549345] pci 0000:03:00.0: BAR 6: assigned [mem 0x92e80000-0x92efffff=
 pref]
[   11.559290] pci 0000:03:00.1: BAR 6: can't assign mem pref (size 0x80000)
[   11.567936] pci 0000:00:03.2: PCI bridge to [bus 03-04]
[   11.574801] pci 0000:00:03.2:   bridge window [mem 0x92f00000-0x932fffff]
[   11.583417] pci 0000:00:03.2:   bridge window [mem 0x92a00000-0x92efffff=
 64bit pref]
[   11.593947] pci 0000:00:03.3: PCI bridge to [bus 05]
[   11.600569] pci 0000:00:11.0: PCI bridge to [bus 06]
[   11.607170] pci 0000:00:1c.0: PCI bridge to [bus 07]
[   11.613805] pci 0000:08:00.0: BAR 6: assigned [mem 0x92810000-0x9281ffff=
 pref]
[   11.623739] pci 0000:00:1c.7: PCI bridge to [bus 08]
[   11.630338] pci 0000:00:1c.7:   bridge window [mem 0x92000000-0x928fffff]
[   11.638976] pci 0000:00:1c.7:   bridge window [mem 0x91000000-0x91ffffff=
 64bit pref]
[   11.649517] pci 0000:00:1e.0: PCI bridge to [bus 09]
[   11.656115] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[   11.663345] pci_bus 0000:00: resource 5 [io  0x1000-0x3fff]
[   11.670611] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[   11.678638] pci_bus 0000:00: resource 7 [mem 0xfed40000-0xfedfffff]
[   11.686671] pci_bus 0000:00: resource 8 [mem 0x90000000-0xabffbfff]
[   11.694726] pci_bus 0000:00: resource 9 [mem 0x380000000000-0x381fffffff=
ff]
[   11.703553] pci_bus 0000:01: resource 0 [io  0x1000-0x1fff]
[   11.710818] pci_bus 0000:01: resource 1 [mem 0x93300000-0x933fffff]
[   11.718873] pci_bus 0000:01: resource 2 [mem 0x90000000-0x900fffff 64bit=
 pref]
[   11.728792] pci_bus 0000:03: resource 1 [mem 0x92f00000-0x932fffff]
[   11.736846] pci_bus 0000:03: resource 2 [mem 0x92a00000-0x92efffff 64bit=
 pref]
[   11.746787] pci_bus 0000:08: resource 1 [mem 0x92000000-0x928fffff]
[   11.754838] pci_bus 0000:08: resource 2 [mem 0x91000000-0x91ffffff 64bit=
 pref]
[   11.764749] pci_bus 0000:09: resource 4 [io  0x0000-0x0cf7]
[   11.772046] pci_bus 0000:09: resource 5 [io  0x1000-0x3fff]
[   11.779283] pci_bus 0000:09: resource 6 [mem 0x000a0000-0x000bffff]
[   11.787308] pci_bus 0000:09: resource 7 [mem 0xfed40000-0xfedfffff]
[   11.795366] pci_bus 0000:09: resource 8 [mem 0x90000000-0xabffbfff]
[   11.803395] pci_bus 0000:09: resource 9 [mem 0x380000000000-0x381fffffff=
ff]
[   11.812297] pci 0000:40:02.0: PCI bridge to [bus 41]
[   11.818861] pci 0000:40:02.0:   bridge window [io  0x4000-0x4fff]
[   11.826748] pci 0000:40:02.0:   bridge window [mem 0xac100000-0xac2fffff]
[   11.835339] pci 0000:40:02.0:   bridge window [mem 0xac300000-0xac4fffff=
 64bit pref]
[   11.845873] pci 0000:40:02.2: PCI bridge to [bus 42]
[   11.852465] pci 0000:40:02.2:   bridge window [io  0x5000-0x5fff]
[   11.860326] pci 0000:40:02.2:   bridge window [mem 0xac500000-0xac6fffff]
[   11.868943] pci 0000:40:02.2:   bridge window [mem 0xac700000-0xac8fffff=
 64bit pref]
[   11.879471] pci 0000:40:03.0: PCI bridge to [bus 43]
[   11.886095] pci_bus 0000:40: resource 4 [io  0x4000-0x7fff]
[   11.893324] pci_bus 0000:40: resource 5 [mem 0xac000000-0xc7ffbfff]
[   11.901377] pci_bus 0000:40: resource 6 [mem 0x382000000000-0x383fffffff=
ff]
[   11.910177] pci_bus 0000:41: resource 0 [io  0x4000-0x4fff]
[   11.917445] pci_bus 0000:41: resource 1 [mem 0xac100000-0xac2fffff]
[   11.925471] pci_bus 0000:41: resource 2 [mem 0xac300000-0xac4fffff 64bit=
 pref]
[   11.935412] pci_bus 0000:42: resource 0 [io  0x5000-0x5fff]
[   11.942681] pci_bus 0000:42: resource 1 [mem 0xac500000-0xac6fffff]
[   11.950734] pci_bus 0000:42: resource 2 [mem 0xac700000-0xac8fffff 64bit=
 pref]
[   11.960723] pci 0000:80:02.0: PCI bridge to [bus 81]
[   11.967354] pci 0000:80:02.2: PCI bridge to [bus 82]
[   11.973950] pci 0000:80:03.0: PCI bridge to [bus 83]
[   11.980547] pci_bus 0000:80: resource 4 [mem 0xc8000000-0xe3ffbfff]
[   11.988601] pci_bus 0000:80: resource 5 [mem 0x384000000000-0x385fffffff=
ff]
[   11.997481] pci 0000:c0:02.0: PCI bridge to [bus c1]
[   12.004035] pci 0000:c0:02.0:   bridge window [io  0xc000-0xcfff]
[   12.011893] pci 0000:c0:02.0:   bridge window [mem 0xe4100000-0xe42fffff]
[   12.020533] pci 0000:c0:02.0:   bridge window [mem 0xe4300000-0xe44fffff=
 64bit pref]
[   12.031046] pci 0000:c0:02.2: PCI bridge to [bus c2]
[   12.037637] pci 0000:c0:02.2:   bridge window [io  0xd000-0xdfff]
[   12.045494] pci 0000:c0:02.2:   bridge window [mem 0xe4500000-0xe46fffff]
[   12.054107] pci 0000:c0:02.2:   bridge window [mem 0xe4700000-0xe48fffff=
 64bit pref]
[   12.064640] pci 0000:c0:03.0: PCI bridge to [bus c3]
[   12.071268] pci_bus 0000:c0: resource 4 [io  0xc000-0xffff]
[   12.078545] pci_bus 0000:c0: resource 5 [mem 0xe4000000-0xfbffbfff]
[   12.086596] pci_bus 0000:c0: resource 6 [mem 0x386000000000-0x387fffffff=
ff]
[   12.095394] pci_bus 0000:c1: resource 0 [io  0xc000-0xcfff]
[   12.102660] pci_bus 0000:c1: resource 1 [mem 0xe4100000-0xe42fffff]
[   12.110717] pci_bus 0000:c1: resource 2 [mem 0xe4300000-0xe44fffff 64bit=
 pref]
[   12.120631] pci_bus 0000:c2: resource 0 [io  0xd000-0xdfff]
[   12.127892] pci_bus 0000:c2: resource 1 [mem 0xe4500000-0xe46fffff]
[   12.135922] pci_bus 0000:c2: resource 2 [mem 0xe4700000-0xe48fffff 64bit=
 pref]
[   12.146313] NET: Registered protocol family 2
[   12.156092] TCP established hash table entries: 524288 (order: 10, 41943=
04 bytes)
[   12.169935] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[   12.179206] TCP: Hash tables configured (established 524288 bind 65536)
[   12.187868] TCP: reno registered
[   12.193289] UDP hash table entries: 65536 (order: 9, 2097152 bytes)
[   12.203433] UDP-Lite hash table entries: 65536 (order: 9, 2097152 bytes)
[   12.215421] NET: Registered protocol family 1
[   12.222899] RPC: Registered named UNIX socket transport module.
[   12.230573] RPC: Registered udp transport module.
[   12.236850] RPC: Registered tcp transport module.
[   12.243179] RPC: Registered tcp NFSv4.1 backchannel transport module.
[   12.300838] IOAPIC[0]: Set routing entry (8-16 -> 0x41 -> IRQ 16 Mode:1 =
Active:1 Dest:0)
[   12.312733] IOAPIC[0]: Set routing entry (8-23 -> 0x51 -> IRQ 23 Mode:1 =
Active:1 Dest:0)
[   12.324135] pci 0000:08:00.0: Boot video device
[   12.330377] PCI: CLS 64 bytes, default 64
[   12.336217] Trying to unpack rootfs image as initramfs...
[   30.841137] Freeing initrd memory: 213036K (ffff88006dbc4000 - ffff88007=
abcf000)
[   30.851281] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[   30.859514] software IO TLB [mem 0x69bc4000-0x6dbc4000] (64MB) mapped at=
 [ffff880069bc4000-ffff88006dbc3fff]
[   30.921928] RAPL PMU detected, hw unit 2^-16 Joules, API unit is 2^-32 J=
oules, 3 fixed counters 163840 ms ovfl timer
[   30.935710] Scanning for low memory corruption every 60 seconds
[   30.950008] AVX version of gcm_enc/dec engaged.
[   30.959305] sha1_ssse3: Using AVX optimized SHA-1 implementation
[   30.989484] futex hash table entries: 65536 (order: 10, 4194304 bytes)
[   31.116703] bounce pool size: 64 pages
[   31.121967] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[   31.139687] VFS: Disk quotas dquot_6.5.2
[   31.145572] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[   31.160908] NFS: Registering the id_resolver key type
[   31.167668] Key type id_resolver registered
[   31.173377] Key type id_legacy registered
[   31.178902] nfs4filelayout_init: NFSv4 File Layout Driver Registering...
[   31.187448] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[   31.199616] ROMFS MTD (C) 2007 Red Hat, Inc.
[   31.205823] fuse init (API version 7.22)
[   31.212284] SGI XFS with ACLs, security attributes, realtime, large bloc=
k/inode numbers, no debug enabled
[   31.230535] msgmni has been set to 32768
[   31.250630] NET: Registered protocol family 38
[   31.277053] Key type asymmetric registered
[   31.282892] Block layer SCSI generic (bsg) driver version 0.4 loaded (ma=
jor 250)
[   31.294288] io scheduler noop registered
[   31.299721] io scheduler deadline registered
[   31.305519] io scheduler cfq registered (default)
[   31.314729] IOAPIC[1]: Set routing entry (9-23 -> 0x61 -> IRQ 47 Mode:1 =
Active:1 Dest:0)
[   31.325911] pcieport 0000:00:02.0: irq 136 for MSI/MSI-X
[   31.333712] pcieport 0000:00:03.0: irq 137 for MSI/MSI-X
[   31.341452] pcieport 0000:00:03.2: irq 138 for MSI/MSI-X
[   31.349209] pcieport 0000:00:03.3: irq 139 for MSI/MSI-X
[   31.356883] IOAPIC[0]: Set routing entry (8-19 -> 0xb1 -> IRQ 19 Mode:1 =
Active:1 Dest:0)
[   31.367989] pcieport 0000:00:11.0: irq 140 for MSI/MSI-X
[   31.375834] pcieport 0000:00:1c.0: irq 141 for MSI/MSI-X
[   31.383547] pcieport 0000:00:1c.7: irq 142 for MSI/MSI-X
[   31.391127] IOAPIC[2]: Set routing entry (10-23 -> 0x22 -> IRQ 71 Mode:1=
 Active:1 Dest:0)
[   31.403331] IOAPIC[3]: Set routing entry (11-23 -> 0x42 -> IRQ 95 Mode:1=
 Active:1 Dest:0)
[   31.415603] IOAPIC[4]: Set routing entry (12-23 -> 0x52 -> IRQ 119 Mode:=
1 Active:1 Dest:0)
[   31.427807] aer 0000:00:02.0:pcie02: service driver aer loaded
[   31.435469] aer 0000:00:03.0:pcie02: service driver aer loaded
[   31.443147] aer 0000:00:03.2:pcie02: service driver aer loaded
[   31.450784] aer 0000:00:03.3:pcie02: service driver aer loaded
[   31.458429] aer 0000:00:11.0:pcie02: service driver aer loaded
[   31.466061] pcieport 0000:00:02.0: Signaling PME through PCIe PME interr=
upt
[   31.474902] pci 0000:01:00.0: Signaling PME through PCIe PME interrupt
[   31.483226] pcie_pme 0000:00:02.0:pcie01: service driver pcie_pme loaded
[   31.491787] pcieport 0000:00:03.0: Signaling PME through PCIe PME interr=
upt
[   31.500631] pcie_pme 0000:00:03.0:pcie01: service driver pcie_pme loaded
[   31.509165] pcieport 0000:00:03.2: Signaling PME through PCIe PME interr=
upt
[   31.517981] pci 0000:03:00.0: Signaling PME through PCIe PME interrupt
[   31.526318] pci 0000:03:00.1: Signaling PME through PCIe PME interrupt
[   31.534667] pcie_pme 0000:00:03.2:pcie01: service driver pcie_pme loaded
[   31.543227] pcieport 0000:00:03.3: Signaling PME through PCIe PME interr=
upt
[   31.552072] pcie_pme 0000:00:03.3:pcie01: service driver pcie_pme loaded
[   31.560601] pcieport 0000:00:11.0: Signaling PME through PCIe PME interr=
upt
[   31.569449] pcie_pme 0000:00:11.0:pcie01: service driver pcie_pme loaded
[   31.578014] pcieport 0000:00:1c.0: Signaling PME through PCIe PME interr=
upt
[   31.586857] pcie_pme 0000:00:1c.0:pcie01: service driver pcie_pme loaded
[   31.595470] pcieport 0000:00:1c.7: Signaling PME through PCIe PME interr=
upt
[   31.604312] pci 0000:08:00.0: Signaling PME through PCIe PME interrupt
[   31.612635] pcie_pme 0000:00:1c.7:pcie01: service driver pcie_pme loaded
[   31.621349] ioapic: probe of 0000:00:05.4 failed with error -22
[   31.629026] ioapic: probe of 0000:40:05.4 failed with error -22
[   31.636674] ioapic: probe of 0000:80:05.4 failed with error -22
[   31.644346] ioapic: probe of 0000:c0:05.4 failed with error -22
[   31.652065] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[   31.659477] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[   31.667931] intel_idle: MWAIT substates: 0x1120
[   31.674019] intel_idle: v0.4 model 0x3E
[   31.679342] intel_idle: lapic_timer_reliable_states 0xffffffff
[   31.705036] input: Sleep Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0=
C0E:00/input/input0
[   31.716268] ACPI: Sleep Button [SLPB]
[   31.721590] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input1
[   31.731736] ACPI: Power Button [PWRF]
[   31.737307] GHES: HEST is not enabled!
[   31.743085] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[   31.773030] 00:0b: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115200) =
is a 16550A
[   31.804774] 00:0c: ttyS1 at I/O 0x2f8 (irq =3D 3, base_baud =3D 115200) =
is a 16550A
[   31.818064] Non-volatile memory driver v1.3
[   31.841077] brd: module loaded
[   31.851741] loop: module loaded
[   31.857438] lkdtm: No crash points registered, enable through debugfs
[   31.866798] ACPI Warning: SystemIO range 0x0000000000000428-0x0000000000=
00042f conflicts with OpRegion 0x0000000000000428-0x000000000000042f (\GPE0=
) (20140214/utaddress-258)
[   31.887344] ACPI: If an ACPI driver is available for this device, you sh=
ould use it instead of the native driver
[   31.900600] ACPI Warning: SystemIO range 0x0000000000000500-0x0000000000=
00052f conflicts with OpRegion 0x000000000000052c-0x000000000000052d (\GPIV=
) (20140214/utaddress-258)
[   31.920986] ACPI: If an ACPI driver is available for this device, you sh=
ould use it instead of the native driver
[   31.934326] lpc_ich: Resource conflict(s) found affecting gpio_ich
[   31.942551] Loading iSCSI transport class v2.0-870.
[   31.951562] Adaptec aacraid driver 1.2-0[30300]-ms
[   31.958348] aic94xx: Adaptec aic94xx SAS/SATA driver version 1.0.3 loaded
[   31.967427] qla2xxx [0000:00:00.0]-0005: : QLogic Fibre Channel HBA Driv=
er: 8.07.00.02-k.
[   31.978830] megaraid cmm: 2.20.2.7 (Release Date: Sun Jul 16 00:01:03 ES=
T 2006)
[   31.989108] megaraid: 2.20.5.1 (Release Date: Thu Nov 16 15:32:35 EST 20=
06)
[   31.998131] megasas: 06.803.01.00-rc1 Mon. Mar. 10 17:00:00 PDT 2014
[   32.006661] GDT-HA: Storage RAID Controller Driver. Version: 3.05
[   32.014717] RocketRAID 3xxx/4xxx Controller driver v1.8
[   32.023069] ahci 0000:00:1f.2: version 3.0
[   32.029312] ahci 0000:00:1f.2: irq 143 for MSI/MSI-X
[   32.052150] ahci 0000:00:1f.2: AHCI 0001.0300 32 slots 6 ports 6 Gbps 0x=
10 impl SATA mode
[   32.063174] ahci 0000:00:1f.2: flags: 64bit ncq sntf pm led clo pio slum=
 part ems apst=20
[   32.077397] scsi0 : ahci
[   32.082040] scsi1 : ahci
[   32.086598] scsi2 : ahci
[   32.091050] scsi3 : ahci
[   32.095516] scsi4 : ahci
[   32.099959] scsi5 : ahci
[   32.104047] ata1: DUMMY
[   32.107810] ata2: DUMMY
[   32.111552] ata3: DUMMY
[   32.115319] ata4: DUMMY
[   32.119053] ata5: SATA max UDMA/133 abar m2048@0x93400000 port 0x9340030=
0 irq 143
[   32.129288] ata6: DUMMY
[   32.134650] tun: Universal TUN/TAP device driver, 1.6
[   32.141331] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[   32.150180] pcnet32: pcnet32.c:v1.35 21.Apr.2008 tsbogend@alpha.franken.=
de
[   32.159246] Atheros(R) L2 Ethernet Driver - version 2.2.3
[   32.166340] Copyright (c) 2007 Atheros Corporation.
[   32.173967] dmfe: Davicom DM9xxx net driver, version 1.36.4 (2002-01-17)
[   32.182706] v1.01-e (2.4 port) Sep-11-2006  Donald Becker <becker@scyld.=
com>
[   32.182706]   http://www.scyld.com/network/drivers.html
[   32.198951] uli526x: ULi M5261/M5263 net driver, version 0.9.3 (2005-7-2=
9)
[   32.208095] e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
[   32.215954] e100: Copyright(c) 1999-2006 Intel Corporation
[   32.223471] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-=
NAPI
[   32.232408] e1000: Copyright (c) 1999-2006 Intel Corporation.
[   32.240216] e1000e: Intel(R) PRO/1000 Network Driver - 2.3.2-k
[   32.247769] e1000e: Copyright(c) 1999 - 2014 Intel Corporation.
[   32.255823] igb: Intel(R) Gigabit Ethernet Network Driver - version 5.0.=
5-k
[   32.264675] igb: Copyright (c) 2007-2014 Intel Corporation.
[   32.272283] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - vers=
ion 3.19.1-k
[   32.282808] ixgbe: Copyright (c) 1999-2014 Intel Corporation.
[   32.290781] IOAPIC[1]: Set routing entry (9-21 -> 0x72 -> IRQ 45 Mode:1 =
Active:1 Dest:0)
[   32.452078] ata5: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
[   32.461918] ata5.00: ATAPI: TEAC    DV-W28S-W, 1.0A, max UDMA/100
[   32.471764] ata5.00: configured for UDMA/100
[   32.479120] scsi 4:0:0:0: CD-ROM            TEAC     DV-W28S-W        1.=
0A PQ: 0 ANSI: 5
[   32.490888] scsi 4:0:0:0: Attached scsi generic sg0 type 5
[   32.720065] ixgbe 0000:03:00.0: irq 144 for MSI/MSI-X
[   32.726786] ixgbe 0000:03:00.0: irq 145 for MSI/MSI-X
[   32.733501] ixgbe 0000:03:00.0: irq 146 for MSI/MSI-X
[   32.740212] ixgbe 0000:03:00.0: irq 147 for MSI/MSI-X
[   32.746901] ixgbe 0000:03:00.0: irq 148 for MSI/MSI-X
[   32.753620] ixgbe 0000:03:00.0: irq 149 for MSI/MSI-X
[   32.760338] ixgbe 0000:03:00.0: irq 150 for MSI/MSI-X
[   32.767051] ixgbe 0000:03:00.0: irq 151 for MSI/MSI-X
[   32.773764] ixgbe 0000:03:00.0: irq 152 for MSI/MSI-X
[   32.780483] ixgbe 0000:03:00.0: irq 153 for MSI/MSI-X
[   32.787196] ixgbe 0000:03:00.0: irq 154 for MSI/MSI-X
[   32.793912] ixgbe 0000:03:00.0: irq 155 for MSI/MSI-X
[   32.800631] ixgbe 0000:03:00.0: irq 156 for MSI/MSI-X
[   32.807350] ixgbe 0000:03:00.0: irq 157 for MSI/MSI-X
[   32.814067] ixgbe 0000:03:00.0: irq 158 for MSI/MSI-X
[   32.820779] ixgbe 0000:03:00.0: irq 159 for MSI/MSI-X
[   32.827492] ixgbe 0000:03:00.0: irq 160 for MSI/MSI-X
[   32.834291] ixgbe 0000:03:00.0: irq 161 for MSI/MSI-X
[   32.841008] ixgbe 0000:03:00.0: irq 162 for MSI/MSI-X
[   32.847722] ixgbe 0000:03:00.0: irq 163 for MSI/MSI-X
[   32.854435] ixgbe 0000:03:00.0: irq 164 for MSI/MSI-X
[   32.861152] ixgbe 0000:03:00.0: irq 165 for MSI/MSI-X
[   32.867864] ixgbe 0000:03:00.0: irq 166 for MSI/MSI-X
[   32.874578] ixgbe 0000:03:00.0: irq 167 for MSI/MSI-X
[   32.881294] ixgbe 0000:03:00.0: irq 168 for MSI/MSI-X
[   32.888044] ixgbe 0000:03:00.0: irq 169 for MSI/MSI-X
[   32.894754] ixgbe 0000:03:00.0: irq 170 for MSI/MSI-X
[   32.901442] ixgbe 0000:03:00.0: irq 171 for MSI/MSI-X
[   32.908156] ixgbe 0000:03:00.0: irq 172 for MSI/MSI-X
[   32.914912] ixgbe 0000:03:00.0: irq 173 for MSI/MSI-X
[   32.921632] ixgbe 0000:03:00.0: irq 174 for MSI/MSI-X
[   32.928352] ixgbe 0000:03:00.0: irq 175 for MSI/MSI-X
[   32.935066] ixgbe 0000:03:00.0: irq 176 for MSI/MSI-X
[   32.941854] ixgbe 0000:03:00.0: irq 177 for MSI/MSI-X
[   32.948569] ixgbe 0000:03:00.0: irq 178 for MSI/MSI-X
[   32.955262] ixgbe 0000:03:00.0: irq 179 for MSI/MSI-X
[   32.962006] ixgbe 0000:03:00.0: irq 180 for MSI/MSI-X
[   32.968699] ixgbe 0000:03:00.0: irq 181 for MSI/MSI-X
[   32.975416] ixgbe 0000:03:00.0: irq 182 for MSI/MSI-X
[   32.982133] ixgbe 0000:03:00.0: irq 183 for MSI/MSI-X
[   33.009317] ixgbe 0000:03:00.0: irq 184 for MSI/MSI-X
[   33.016065] ixgbe 0000:03:00.0: irq 185 for MSI/MSI-X
[   33.022780] ixgbe 0000:03:00.0: irq 186 for MSI/MSI-X
[   33.029470] ixgbe 0000:03:00.0: irq 187 for MSI/MSI-X
[   33.036180] ixgbe 0000:03:00.0: irq 188 for MSI/MSI-X
[   33.042894] ixgbe 0000:03:00.0: irq 189 for MSI/MSI-X
[   33.049605] ixgbe 0000:03:00.0: irq 190 for MSI/MSI-X
[   33.056324] ixgbe 0000:03:00.0: irq 191 for MSI/MSI-X
[   33.063043] ixgbe 0000:03:00.0: irq 192 for MSI/MSI-X
[   33.069836] ixgbe 0000:03:00.0: irq 193 for MSI/MSI-X
[   33.076554] ixgbe 0000:03:00.0: irq 194 for MSI/MSI-X
[   33.083267] ixgbe 0000:03:00.0: irq 195 for MSI/MSI-X
[   33.090013] ixgbe 0000:03:00.0: irq 196 for MSI/MSI-X
[   33.096731] ixgbe 0000:03:00.0: irq 197 for MSI/MSI-X
[   33.103453] ixgbe 0000:03:00.0: irq 198 for MSI/MSI-X
[   33.110170] ixgbe 0000:03:00.0: irq 199 for MSI/MSI-X
[   33.116885] ixgbe 0000:03:00.0: irq 200 for MSI/MSI-X
[   33.123595] ixgbe 0000:03:00.0: irq 201 for MSI/MSI-X
[   33.130308] ixgbe 0000:03:00.0: irq 202 for MSI/MSI-X
[   33.137030] ixgbe 0000:03:00.0: irq 203 for MSI/MSI-X
[   33.143750] ixgbe 0000:03:00.0: irq 204 for MSI/MSI-X
[   33.150490] ixgbe 0000:03:00.0: irq 205 for MSI/MSI-X
[   33.157206] ixgbe 0000:03:00.0: irq 206 for MSI/MSI-X
[   33.163919] ixgbe 0000:03:00.0: irq 207 for MSI/MSI-X
[   33.171192] ixgbe 0000:03:00.0: Multiqueue Enabled: Rx Queue count =3D 6=
3, Tx Queue count =3D 63
[   33.243076] ixgbe 0000:03:00.0: PCI Express bandwidth of 16GT/s available
[   33.251741] ixgbe 0000:03:00.0: (Speed:5.0GT/s, Width: x4, Encoding Loss=
:20%)
[   33.422186] ixgbe 0000:03:00.0: MAC: 3, PHY: 3, PBA No: G36748-004
[   33.430204] ixgbe 0000:03:00.0: a0:36:9f:18:d5:24
[   33.587503] ixgbe 0000:03:00.0: Intel(R) 10 Gigabit Network Connection
[   33.596353] IOAPIC[1]: Set routing entry (9-18 -> 0xc7 -> IRQ 42 Mode:1 =
Active:1 Dest:0)
[   34.023815] ixgbe 0000:03:00.1: irq 208 for MSI/MSI-X
[   34.030572] ixgbe 0000:03:00.1: irq 209 for MSI/MSI-X
[   34.037286] ixgbe 0000:03:00.1: irq 210 for MSI/MSI-X
[   34.043977] ixgbe 0000:03:00.1: irq 211 for MSI/MSI-X
[   34.050692] ixgbe 0000:03:00.1: irq 212 for MSI/MSI-X
[   34.057414] ixgbe 0000:03:00.1: irq 213 for MSI/MSI-X
[   34.064130] ixgbe 0000:03:00.1: irq 214 for MSI/MSI-X
[   34.070849] ixgbe 0000:03:00.1: irq 215 for MSI/MSI-X
[   34.077564] ixgbe 0000:03:00.1: irq 216 for MSI/MSI-X
[   34.084278] ixgbe 0000:03:00.1: irq 217 for MSI/MSI-X
[   34.090996] ixgbe 0000:03:00.1: irq 218 for MSI/MSI-X
[   34.097717] ixgbe 0000:03:00.1: irq 219 for MSI/MSI-X
[   34.104432] ixgbe 0000:03:00.1: irq 220 for MSI/MSI-X
[   34.111153] ixgbe 0000:03:00.1: irq 221 for MSI/MSI-X
[   34.117899] ixgbe 0000:03:00.1: irq 222 for MSI/MSI-X
[   34.124665] ixgbe 0000:03:00.1: irq 223 for MSI/MSI-X
[   34.131384] ixgbe 0000:03:00.1: irq 224 for MSI/MSI-X
[   34.138103] ixgbe 0000:03:00.1: irq 225 for MSI/MSI-X
[   34.144816] ixgbe 0000:03:00.1: irq 226 for MSI/MSI-X
[   34.151534] ixgbe 0000:03:00.1: irq 227 for MSI/MSI-X
[   34.158270] ixgbe 0000:03:00.1: irq 228 for MSI/MSI-X
[   34.164964] ixgbe 0000:03:00.1: irq 229 for MSI/MSI-X
[   34.171682] ixgbe 0000:03:00.1: irq 230 for MSI/MSI-X
[   34.178402] ixgbe 0000:03:00.1: irq 231 for MSI/MSI-X
[   34.185160] ixgbe 0000:03:00.1: irq 232 for MSI/MSI-X
[   34.191879] ixgbe 0000:03:00.1: irq 233 for MSI/MSI-X
[   34.198597] ixgbe 0000:03:00.1: irq 234 for MSI/MSI-X
[   34.205314] ixgbe 0000:03:00.1: irq 235 for MSI/MSI-X
[   34.212063] ixgbe 0000:03:00.1: irq 236 for MSI/MSI-X
[   34.218781] ixgbe 0000:03:00.1: irq 237 for MSI/MSI-X
[   34.225536] ixgbe 0000:03:00.1: irq 238 for MSI/MSI-X
[   34.232308] ixgbe 0000:03:00.1: irq 239 for MSI/MSI-X
[   34.239026] ixgbe 0000:03:00.1: irq 240 for MSI/MSI-X
[   34.245771] ixgbe 0000:03:00.1: irq 241 for MSI/MSI-X
[   34.252491] ixgbe 0000:03:00.1: irq 242 for MSI/MSI-X
[   34.259204] ixgbe 0000:03:00.1: irq 243 for MSI/MSI-X
[   34.265895] ixgbe 0000:03:00.1: irq 244 for MSI/MSI-X
[   34.272645] ixgbe 0000:03:00.1: irq 245 for MSI/MSI-X
[   34.279373] ixgbe 0000:03:00.1: irq 246 for MSI/MSI-X
[   34.286086] ixgbe 0000:03:00.1: irq 247 for MSI/MSI-X
[   34.292800] ixgbe 0000:03:00.1: irq 248 for MSI/MSI-X
[   34.299518] ixgbe 0000:03:00.1: irq 249 for MSI/MSI-X
[   34.306235] ixgbe 0000:03:00.1: irq 250 for MSI/MSI-X
[   34.312948] ixgbe 0000:03:00.1: irq 251 for MSI/MSI-X
[   34.319661] ixgbe 0000:03:00.1: irq 252 for MSI/MSI-X
[   34.326372] ixgbe 0000:03:00.1: irq 253 for MSI/MSI-X
[   34.333090] ixgbe 0000:03:00.1: irq 254 for MSI/MSI-X
[   34.339887] ixgbe 0000:03:00.1: irq 255 for MSI/MSI-X
[   34.346608] ixgbe 0000:03:00.1: irq 256 for MSI/MSI-X
[   34.353323] ixgbe 0000:03:00.1: irq 257 for MSI/MSI-X
[   34.360069] ixgbe 0000:03:00.1: irq 258 for MSI/MSI-X
[   34.366798] ixgbe 0000:03:00.1: irq 259 for MSI/MSI-X
[   34.373513] ixgbe 0000:03:00.1: irq 260 for MSI/MSI-X
[   34.380230] ixgbe 0000:03:00.1: irq 261 for MSI/MSI-X
[   34.386945] ixgbe 0000:03:00.1: irq 262 for MSI/MSI-X
[   34.393662] ixgbe 0000:03:00.1: irq 263 for MSI/MSI-X
[   34.400375] ixgbe 0000:03:00.1: irq 264 for MSI/MSI-X
[   34.407095] ixgbe 0000:03:00.1: irq 265 for MSI/MSI-X
[   34.413808] ixgbe 0000:03:00.1: irq 266 for MSI/MSI-X
[   34.420527] ixgbe 0000:03:00.1: irq 267 for MSI/MSI-X
[   34.427242] ixgbe 0000:03:00.1: irq 268 for MSI/MSI-X
[   34.433959] ixgbe 0000:03:00.1: irq 269 for MSI/MSI-X
[   34.440674] ixgbe 0000:03:00.1: irq 270 for MSI/MSI-X
[   34.447465] ixgbe 0000:03:00.1: irq 271 for MSI/MSI-X
[   34.454722] ixgbe 0000:03:00.1: Multiqueue Enabled: Rx Queue count =3D 6=
3, Tx Queue count =3D 63
[   34.526633] ixgbe 0000:03:00.1: PCI Express bandwidth of 16GT/s available
[   34.535295] ixgbe 0000:03:00.1: (Speed:5.0GT/s, Width: x4, Encoding Loss=
:20%)
[   34.705784] ixgbe 0000:03:00.1: MAC: 3, PHY: 3, PBA No: G36748-004
[   34.713814] ixgbe 0000:03:00.1: a0:36:9f:18:d5:26
[   34.869728] ixgbe 0000:03:00.1: Intel(R) 10 Gigabit Network Connection
[   34.878294] ixgb: Intel(R) PRO/10GbE Network Driver - version 1.0.135-k2=
-NAPI
[   34.887333] ixgb: Copyright (c) 1999-2008 Intel Corporation.
[   34.895096] sky2: driver version 1.30
[   34.901999] usbcore: registered new interface driver catc
[   34.909103] usbcore: registered new interface driver kaweth
[   34.916369] pegasus: v0.9.3 (2013/04/25), Pegasus/Pegasus II USB Etherne=
t driver
[   34.926562] usbcore: registered new interface driver pegasus
[   34.933981] usbcore: registered new interface driver rtl8150
[   34.941374] usbcore: registered new interface driver asix
[   34.948475] usbcore: registered new interface driver ax88179_178a
[   34.956364] usbcore: registered new interface driver cdc_ether
[   34.964001] usbcore: registered new interface driver cdc_eem
[   34.971422] usbcore: registered new interface driver dm9601
[   34.978771] usbcore: registered new interface driver smsc75xx
[   34.986316] usbcore: registered new interface driver smsc95xx
[   34.993808] usbcore: registered new interface driver gl620a
[   35.001141] usbcore: registered new interface driver net1080
[   35.008563] usbcore: registered new interface driver plusb
[   35.015762] usbcore: registered new interface driver rndis_host
[   35.023478] usbcore: registered new interface driver cdc_subset
[   35.031165] usbcore: registered new interface driver zaurus
[   35.038474] usbcore: registered new interface driver MOSCHIP usb-etherne=
t driver
[   35.048698] usbcore: registered new interface driver int51x1
[   35.056123] usbcore: registered new interface driver ipheth
[   35.063429] usbcore: registered new interface driver sierra_net
[   35.071118] usbcore: registered new interface driver cdc_ncm
[   35.078499] Fusion MPT base driver 3.04.20
[   35.084090] Copyright (c) 1999-2008 LSI Corporation
[   35.090601] Fusion MPT SPI Host driver 3.04.20
[   35.096769] Fusion MPT FC Host driver 3.04.20
[   35.102891] Fusion MPT SAS Host driver 3.04.20
[   35.109084] Fusion MPT misc device (ioctl) driver 3.04.20
[   35.116362] mptctl: Registered with Fusion MPT base driver
[   35.123536] mptctl: /dev/mptctl @ (major,minor=3D10,220)
[   35.130991] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[   35.139357] ehci-pci: EHCI PCI platform driver
[   35.146347] ehci-pci 0000:00:1a.0: EHCI Host Controller
[   35.153529] ehci-pci 0000:00:1a.0: new USB bus registered, assigned bus =
number 1
[   35.163744] ehci-pci 0000:00:1a.0: debug port 2
[   35.173855] ehci-pci 0000:00:1a.0: cache line size of 64 is not supported
[   35.182585] ehci-pci 0000:00:1a.0: irq 16, io mem 0x93402000
[   35.200116] ehci-pci 0000:00:1a.0: USB 2.0 started, EHCI 1.00
[   35.208546] hub 1-0:1.0: USB hub found
[   35.213826] hub 1-0:1.0: 2 ports detected
[   35.220713] ehci-pci 0000:00:1d.0: EHCI Host Controller
[   35.227937] ehci-pci 0000:00:1d.0: new USB bus registered, assigned bus =
number 2
[   35.238152] ehci-pci 0000:00:1d.0: debug port 2
[   35.248205] ehci-pci 0000:00:1d.0: cache line size of 64 is not supported
[   35.256888] ehci-pci 0000:00:1d.0: irq 23, io mem 0x93401000
[   35.276114] ehci-pci 0000:00:1d.0: USB 2.0 started, EHCI 1.00
[   35.284416] hub 2-0:1.0: USB hub found
[   35.289673] hub 2-0:1.0: 2 ports detected
[   35.295833] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[   35.303843] ohci-pci: OHCI PCI platform driver
[   35.310018] uhci_hcd: USB Universal Host Controller Interface driver
[   35.318615] usbcore: registered new interface driver usb-storage
[   35.326426] usbcore: registered new interface driver ums-alauda
[   35.334116] usbcore: registered new interface driver ums-datafab
[   35.341917] usbcore: registered new interface driver ums-freecom
[   35.349717] usbcore: registered new interface driver ums-isd200
[   35.357402] usbcore: registered new interface driver ums-jumpshot
[   35.365294] usbcore: registered new interface driver ums-sddr09
[   35.373016] usbcore: registered new interface driver ums-sddr55
[   35.380703] usbcore: registered new interface driver ums-usbat
[   35.388334] usbcore: registered new interface driver usbtest
[   35.395966] i8042: PNP: No PS/2 controller found. Probing ports directly.
[   36.009047] i8042: Can't read CTR while initializing i8042
[   36.016267] i8042: probe of i8042 failed with error -5
[   36.023464] mousedev: PS/2 mouse device common for all mice
[   36.032172] rtc_cmos 00:06: RTC can wake from S4
[   36.039001] rtc_cmos 00:06: rtc core: registered rtc_cmos as rtc0
[   36.046914] rtc_cmos 00:06: alarms up to one month, y3k, 114 bytes nvram=
, hpet irqs
[   36.077980] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.10
[   36.085323] iTCO_wdt: unable to reset NO_REBOOT flag, device disabled by=
 hardware/BIOS
[   36.096096] iTCO_vendor_support: vendor-support=3D0
[   36.102804] softdog: Software Watchdog Timer: 0.08 initialized. soft_nob=
oot=3D0 soft_margin=3D60 sec soft_panic=3D0 (nowayout=3D0)
[   36.117069] md: linear personality registered for level -1
[   36.124248] md: raid0 personality registered for level 0
[   36.128388] usb 1-1: new high-speed USB device number 2 using ehci-pci
[   36.139597] md: raid1 personality registered for level 1
[   36.146542] md: raid10 personality registered for level 10
[   36.154095] md: raid6 personality registered for level 6
[   36.161101] md: raid5 personality registered for level 5
[   36.168083] md: raid4 personality registered for level 4
[   36.175050] md: multipath personality registered for level -4
[   36.182527] md: faulty personality registered for level -5
[   36.192648] device-mapper: ioctl: 4.27.0-ioctl (2013-10-30) initialised:=
 dm-devel@redhat.com
[   36.206031] device-mapper: multipath: version 1.7.0 loaded
[   36.213246] device-mapper: multipath round-robin: version 1.0.0 loaded
[   36.221651] device-mapper: cache-policy-mq: version 1.2.0 loaded
[   36.229417] device-mapper: cache cleaner: version 1.0.0 loaded
[   36.237261] Intel P-state driver initializing.
[   36.243342] Intel pstate controlling: cpu 0
[   36.248548] Intel pstate controlling: cpu 1
[   36.253725] Intel pstate controlling: cpu 2
[   36.258911] Intel pstate controlling: cpu 3
[   36.261191] hub 1-1:1.0: USB hub found
[   36.261392] hub 1-1:1.0: 6 ports detected
[   36.273691] Intel pstate controlling: cpu 4
[   36.278863] Intel pstate controlling: cpu 5
[   36.284089] Intel pstate controlling: cpu 6
[   36.289276] Intel pstate controlling: cpu 7
[   36.294462] Intel pstate controlling: cpu 8
[   36.299634] Intel pstate controlling: cpu 9
[   36.304817] Intel pstate controlling: cpu 10
[   36.310101] Intel pstate controlling: cpu 11
[   36.315378] Intel pstate controlling: cpu 12
[   36.320659] Intel pstate controlling: cpu 13
[   36.325939] Intel pstate controlling: cpu 14
[   36.331209] Intel pstate controlling: cpu 15
[   36.336482] Intel pstate controlling: cpu 16
[   36.341768] Intel pstate controlling: cpu 17
[   36.347041] Intel pstate controlling: cpu 18
[   36.352308] Intel pstate controlling: cpu 19
[   36.357586] Intel pstate controlling: cpu 20
[   36.362889] Intel pstate controlling: cpu 21
[   36.368184] Intel pstate controlling: cpu 22
[   36.372292] usb 2-1: new high-speed USB device number 2 using ehci-pci
[   36.381267] Intel pstate controlling: cpu 23
[   36.386559] Intel pstate controlling: cpu 24
[   36.391859] Intel pstate controlling: cpu 25
[   36.397180] Intel pstate controlling: cpu 26
[   36.402479] Intel pstate controlling: cpu 27
[   36.407760] Intel pstate controlling: cpu 28
[   36.413081] Intel pstate controlling: cpu 29
[   36.418374] Intel pstate controlling: cpu 30
[   36.423658] Intel pstate controlling: cpu 31
[   36.428979] Intel pstate controlling: cpu 32
[   36.434289] Intel pstate controlling: cpu 33
[   36.439566] Intel pstate controlling: cpu 34
[   36.444869] Intel pstate controlling: cpu 35
[   36.450171] Intel pstate controlling: cpu 36
[   36.455442] Intel pstate controlling: cpu 37
[   36.460740] Intel pstate controlling: cpu 38
[   36.466038] Intel pstate controlling: cpu 39
[   36.471315] Intel pstate controlling: cpu 40
[   36.476634] Intel pstate controlling: cpu 41
[   36.481939] Intel pstate controlling: cpu 42
[   36.487209] Intel pstate controlling: cpu 43
[   36.492535] Intel pstate controlling: cpu 44
[   36.497831] Intel pstate controlling: cpu 45
[   36.503103] Intel pstate controlling: cpu 46
[   36.505205] hub 2-1:1.0: USB hub found
[   36.505411] hub 2-1:1.0: 8 ports detected
[   36.518031] Intel pstate controlling: cpu 47
[   36.523341] Intel pstate controlling: cpu 48
[   36.528658] Intel pstate controlling: cpu 49
[   36.533956] Intel pstate controlling: cpu 50
[   36.539235] Intel pstate controlling: cpu 51
[   36.544556] Intel pstate controlling: cpu 52
[   36.549859] Intel pstate controlling: cpu 53
[   36.555134] Intel pstate controlling: cpu 54
[   36.560441] Intel pstate controlling: cpu 55
[   36.565741] Intel pstate controlling: cpu 56
[   36.571017] Intel pstate controlling: cpu 57
[   36.576344] Intel pstate controlling: cpu 58
[   36.581648] Intel pstate controlling: cpu 59
[   36.586922] Intel pstate controlling: cpu 60
[   36.592247] Intel pstate controlling: cpu 61
[   36.597552] Intel pstate controlling: cpu 62
[   36.602826] Intel pstate controlling: cpu 63
[   36.608158] Intel pstate controlling: cpu 64
[   36.613462] Intel pstate controlling: cpu 65
[   36.618741] Intel pstate controlling: cpu 66
[   36.624133] Intel pstate controlling: cpu 67
[   36.629430] Intel pstate controlling: cpu 68
[   36.634756] Intel pstate controlling: cpu 69
[   36.640083] Intel pstate controlling: cpu 70
[   36.645400] Intel pstate controlling: cpu 71
[   36.650711] Intel pstate controlling: cpu 72
[   36.655984] Intel pstate controlling: cpu 73
[   36.661301] Intel pstate controlling: cpu 74
[   36.666610] Intel pstate controlling: cpu 75
[   36.671882] Intel pstate controlling: cpu 76
[   36.677199] Intel pstate controlling: cpu 77
[   36.682500] Intel pstate controlling: cpu 78
[   36.687771] Intel pstate controlling: cpu 79
[   36.693098] Intel pstate controlling: cpu 80
[   36.698405] Intel pstate controlling: cpu 81
[   36.703671] Intel pstate controlling: cpu 82
[   36.708967] Intel pstate controlling: cpu 83
[   36.714231] Intel pstate controlling: cpu 84
[   36.719502] Intel pstate controlling: cpu 85
[   36.724793] Intel pstate controlling: cpu 86
[   36.730069] Intel pstate controlling: cpu 87
[   36.735348] Intel pstate controlling: cpu 88
[   36.740658] Intel pstate controlling: cpu 89
[   36.745931] Intel pstate controlling: cpu 90
[   36.751213] Intel pstate controlling: cpu 91
[   36.756491] Intel pstate controlling: cpu 92
[   36.761769] Intel pstate controlling: cpu 93
[   36.767052] Intel pstate controlling: cpu 94
[   36.772347] Intel pstate controlling: cpu 95
[   36.776320] usb 2-1.2: new full-speed USB device number 3 using ehci-pci
[   36.785567] Intel pstate controlling: cpu 96
[   36.790848] Intel pstate controlling: cpu 97
[   36.796133] Intel pstate controlling: cpu 98
[   36.801401] Intel pstate controlling: cpu 99
[   36.806684] Intel pstate controlling: cpu 100
[   36.812084] Intel pstate controlling: cpu 101
[   36.817467] Intel pstate controlling: cpu 102
[   36.822848] Intel pstate controlling: cpu 103
[   36.828225] Intel pstate controlling: cpu 104
[   36.833611] Intel pstate controlling: cpu 105
[   36.838989] Intel pstate controlling: cpu 106
[   36.844358] Intel pstate controlling: cpu 107
[   36.849738] Intel pstate controlling: cpu 108
[   36.855117] Intel pstate controlling: cpu 109
[   36.860488] Intel pstate controlling: cpu 110
[   36.865879] Intel pstate controlling: cpu 111
[   36.869678] hub 2-1.2:1.0: USB hub found
[   36.869892] hub 2-1.2:1.0: 4 ports detected
[   36.881257] Intel pstate controlling: cpu 112
[   36.886628] Intel pstate controlling: cpu 113
[   36.892031] Intel pstate controlling: cpu 114
[   36.897416] Intel pstate controlling: cpu 115
[   36.902800] Intel pstate controlling: cpu 116
[   36.908180] Intel pstate controlling: cpu 117
[   36.913553] Intel pstate controlling: cpu 118
[   36.918926] Intel pstate controlling: cpu 119
[   36.924432] dcdbas dcdbas: Dell Systems Management Base Driver (version =
5.6.0-3.2)
[   36.934333] usbcore: registered new interface driver usbhid
[   36.940292] usb 2-1.4: new full-speed USB device number 4 using ehci-pci
[   36.949029] usbhid: USB HID core driver
[   36.953985] TCP: bic registered
[   36.957984] Initializing XFRM netlink socket
[   36.963585] NET: Registered protocol family 10
[   36.970129] sit: IPv6 over IPv4 tunneling driver
[   36.976278] NET: Registered protocol family 17
[   36.981772] 8021q: 802.1Q VLAN Support v1.8
[   36.988987] DCCP: Activated CCID 2 (TCP-like)
[   36.994386] DCCP: Activated CCID 3 (TCP-Friendly Rate Control)
[   37.002341] sctp: Hash tables configured (established 65536 bind 65536)
[   37.010468] tipc: Activated (version 2.0.0)
[   37.015740] NET: Registered protocol family 30
[   37.021614] tipc: Started in single node mode
[   37.026999] Key type dns_resolver registered
[   37.041113]=20
[   37.041113] printing PIC contents
[   37.047344] ... PIC  IMR: ffff
[   37.051227] ... PIC  IRR: 0c00
[   37.055119] ... PIC  ISR: 0000
[   37.057808] input: American Megatrends Inc. Virtual Keyboard and Mouse a=
s /devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.4/2-1.4:1.0/0003:046B:FF10.=
0001/input/input2
[   37.059367] hid-generic 0003:046B:FF10.0001: input: USB HID v1.10 Keyboa=
rd [American Megatrends Inc. Virtual Keyboard and Mouse] on usb-0000:00:1d.=
0-1.4/input0
[   37.061534] input: American Megatrends Inc. Virtual Keyboard and Mouse a=
s /devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.4/2-1.4:1.1/0003:046B:FF10.=
0002/input/input3
[   37.061916] hid-generic 0003:046B:FF10.0002: input: USB HID v1.10 Mouse =
[American Megatrends Inc. Virtual Keyboard and Mouse] on usb-0000:00:1d.0-1=
=2E4/input1
[   37.137781] ... PIC ELCR: 0e00
[   37.140278] usb 2-1.2.1: new low-speed USB device number 5 using ehci-pci
[   37.149809] printing local APIC contents on CPU#0/0:
[   37.153803] ... APIC ID:      00000000 (0)
[   37.153803] ... APIC VERSION: 01060015
[   37.153803] ... APIC TASKPRI: 00000000 (00)
[   37.153803] ... APIC PROCPRI: 00000000
[   37.153803] ... APIC LDR: 01000000
[   37.153803] ... APIC DFR: ffffffff
[   37.153803] ... APIC SPIV: 000001ff
[   37.153803] ... APIC ISR field:
[   37.153803] 000000000000000000000000000000000000000000000000000000000000=
0000
[   37.153803] ... APIC TMR field:
[   37.153803] 000000000000000000020002000000000000000000000000000000000000=
0000
[   37.153803] ... APIC IRR field:
[   37.153803] 000000000000000000020000000000000000000000000000000000000000=
8000
[   37.153803] ... APIC ESR: 00000000
[   37.153803] ... APIC ICR: 000000fd
[   37.153803] ... APIC ICR2: 23000000
[   37.153803] ... APIC LVTT: 000400ef
[   37.153803] ... APIC LVTPC: 00000400
[   37.153803] ... APIC LVT0: 00010700
[   37.153803] ... APIC LVT1: 00000400
[   37.153803] ... APIC LVTERR: 000000fe
[   37.153803] ... APIC TMICT: 00000000
[   37.153803] ... APIC TMCCT: 00000000
[   37.153803] ... APIC TDCR: 00000000
[   37.153803]=20
[   37.293591] number of MP IRQ sources: 15.
[   37.299024] number of IO-APIC #8 registers: 24.
[   37.305029] number of IO-APIC #9 registers: 24.
[   37.311013] number of IO-APIC #10 registers: 24.
[   37.317088] number of IO-APIC #11 registers: 24.
[   37.323159] number of IO-APIC #12 registers: 24.
[   37.329232] testing the IO APIC.......................
[   37.335912] IO APIC #8......
[   37.340044] .... register #00: 08000000
[   37.345261] .......    : physical APIC id: 08
[   37.351031] .......    : Delivery Type: 0
[   37.356423] .......    : LTS          : 0
[   37.361852] .... register #01: 00170020
[   37.367029] .......     : max redirection entries: 17
[   37.373595] .......     : PRQ implemented: 0
[   37.379287] .......     : IO APIC version: 20
[   37.385070] .... IRQ redirection table:
[   37.390288] 1    0    0   0   0    0    0    00
[   37.396277] 0    0    0   0   0    0    0    31
[   37.402263] 0    0    0   0   0    0    0    30
[   37.408253] 0    0    0   0   0    0    0    33
[   37.414235] 0    0    0   0   0    0    0    34
[   37.420244] 0    0    0   0   0    0    0    35
[   37.426222] 0    0    0   0   0    0    0    36
[   37.432206] 0    0    0   0   0    0    0    37
[   37.438188] 0    0    0   0   0    0    0    38
[   37.444241] 0    1    0   0   0    0    0    39
[   37.450331] 0    0    0   0   0    0    0    3A
[   37.456423] 0    0    0   0   0    0    0    3B
[   37.461999] input: ATEN International Co. Ltd CS1716A V1.0.098 as /devic=
es/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.2/2-1.2.1/2-1.2.1:1.0/0003:0557:226=
1.0003/input/input4
[   37.463031] hid-generic 0003:0557:2261.0003: input: USB HID v1.00 Keyboa=
rd [ATEN International Co. Ltd CS1716A V1.0.098] on usb-0000:00:1d.0-1.2.1/=
input0
[   37.485189] input: ATEN International Co. Ltd CS1716A V1.0.098 as /devic=
es/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.2/2-1.2.1/2-1.2.1:1.1/0003:0557:226=
1.0004/input/input5
[   37.485566] hid-generic 0003:0557:2261.0004: input: USB HID v1.00 Device=
 [ATEN International Co. Ltd CS1716A V1.0.098] on usb-0000:00:1d.0-1.2.1/in=
put1
[   37.504205] input: ATEN International Co. Ltd CS1716A V1.0.098 as /devic=
es/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.2/2-1.2.1/2-1.2.1:1.2/0003:0557:226=
1.0005/input/input6
[   37.504664] hid-generic 0003:0557:2261.0005: input: USB HID v1.10 Mouse =
[ATEN International Co. Ltd CS1716A V1.0.098] on usb-0000:00:1d.0-1.2.1/inp=
ut2
[   37.571685] 0    0    0   0   0    0    0    3C
[   37.577779] 0    0    0   0   0    0    0    3D
[   37.583892] 0    0    0   0   0    0    0    3E
[   37.590017] 0    0    0   0   0    0    0    3F
[   37.596110] 0    1    0   1   0    0    0    41
[   37.602232] 1    0    0   0   0    0    0    00
[   37.608358] 1    0    0   0   0    0    2    09
[   37.614474] 1    1    0   1   0    0    0    B1
[   37.620568] 1    0    0   0   0    0    0    00
[   37.626690] 1    0    0   0   0    0    2    09
[   37.632811] 1    0    0   0   0    0    2    09
[   37.638907] 0    1    0   1   0    0    0    51
[   37.645019] IO APIC #9......
[   37.649261] .... register #00: 09000000
[   37.654583] .......    : physical APIC id: 09
[   37.660472] .......    : Delivery Type: 0
[   37.665978] .......    : LTS          : 0
[   37.671507] .... register #01: 00170020
[   37.676833] .......     : max redirection entries: 17
[   37.683502] .......     : PRQ implemented: 0
[   37.689294] .......     : IO APIC version: 20
[   37.695211] .... register #02: 00000000
[   37.700564] .......     : arbitration: 00
[   37.706072] .... register #03: 00000001
[   37.711399] .......     : Boot DT    : 1
[   37.716815] .... IRQ redirection table:
[   37.722148] 1    0    0   0   0    0    0    00
[   37.728246] 1    0    0   0   0    0    0    00
[   37.734337] 1    0    0   0   0    0    0    00
[   37.740445] 1    0    0   0   0    0    0    00
[   37.746516] 1    0    0   0   0    0    0    00
[   37.752632] 1    0    0   0   0    0    0    00
[   37.758746] 1    0    0   0   0    0    0    00
[   37.764843] 1    0    0   0   0    0    0    00
[   37.770957] 1    0    0   0   0    0    0    00
[   37.777046] 1    0    0   0   0    0    0    00
[   37.783158] 1    0    0   0   0    0    0    00
[   37.789247] 1    0    0   0   0    0    0    00
[   37.795372] 1    0    0   0   0    0    0    00
[   37.801469] 1    0    0   0   0    0    0    00
[   37.807564] 1    0    0   0   0    0    0    00
[   37.813656] 1    0    0   0   0    0    0    00
[   37.819770] 1    0    0   0   0    0    0    00
[   37.825896] 1    0    0   0   0    0    0    00
[   37.832024] 1    1    0   1   0    0    0    C7
[   37.838142] 1    0    0   0   0    0    0    00
[   37.844235] 1    0    0   0   0    0    0    00
[   37.850355] 1    1    0   1   0    0    0    72
[   37.856443] 1    0    0   0   0    0    0    00
[   37.862534] 1    1    0   1   0    0    0    61
[   37.868650] IO APIC #10......
[   37.872986] .... register #00: 0A000000
[   37.878313] .......    : physical APIC id: 0A
[   37.884222] .......    : Delivery Type: 0
[   37.889754] .......    : LTS          : 0
[   37.895262] .... register #01: 00170020
[   37.900585] .......     : max redirection entries: 17
[   37.907261] .......     : PRQ implemented: 0
[   37.913084] .......     : IO APIC version: 20
[   37.918965] .... register #02: 00000000
[   37.924298] .......     : arbitration: 00
[   37.929826] .... register #03: 00000001
[   37.935120] .......     : Boot DT    : 1
[   37.940542] .... IRQ redirection table:
[   37.945891] 1    0    0   0   0    0    0    00
[   37.951978] 1    0    0   0   0    0    0    00
[   37.958069] 1    0    0   0   0    0    0    00
[   37.964162] 1    0    0   0   0    0    0    00
[   37.970276] 1    0    0   0   0    0    0    00
[   37.976362] 1    0    0   0   0    0    0    00
[   37.982447] 1    0    0   0   0    0    0    00
[   37.988541] 1    0    0   0   0    0    0    00
[   37.994625] 1    0    0   0   0    0    0    00
[   38.000719] 1    0    0   0   0    0    0    00
[   38.006838] 1    0    0   0   0    0    0    00
[   38.012928] 1    0    0   0   0    0    0    00
[   38.019045] 1    0    0   0   0    0    0    00
[   38.025137] 1    0    0   0   0    0    0    00
[   38.031229] 1    0    0   0   0    0    0    00
[   38.037320] 1    0    0   0   0    0    0    00
[   38.043438] 1    0    0   0   0    0    0    00
[   38.049589] 1    0    0   0   0    0    0    00
[   38.055681] 1    0    0   0   0    0    0    00
[   38.061773] 1    0    0   0   0    0    0    00
[   38.067856] 1    0    0   0   0    0    0    00
[   38.073951] 1    0    0   0   0    0    0    00
[   38.080045] 1    0    0   0   0    0    0    00
[   38.086189] 1    1    0   1   0    0    0    22
[   38.092303] IO APIC #11......
[   38.096636] .... register #00: 0B000000
[   38.101964] .......    : physical APIC id: 0B
[   38.107879] .......    : Delivery Type: 0
[   38.113412] .......    : LTS          : 0
[   38.118919] .... register #01: 00170020
[   38.124236] .......     : max redirection entries: 17
[   38.130907] .......     : PRQ implemented: 0
[   38.136727] .......     : IO APIC version: 20
[   38.142610] .... register #02: 00000000
[   38.147940] .......     : arbitration: 00
[   38.153475] .... register #03: 00000001
[   38.158771] .......     : Boot DT    : 1
[   38.164184] .... IRQ redirection table:
[   38.189989] 1    0    0   0   0    0    0    00
[   38.196107] 1    0    0   0   0    0    0    00
[   38.202205] 1    0    0   0   0    0    0    00
[   38.208318] 1    0    0   0   0    0    0    00
[   38.214411] 1    0    0   0   0    0    0    00
[   38.220504] 1    0    0   0   0    0    0    00
[   38.226620] 1    0    0   0   0    0    0    00
[   38.232740] 1    0    0   0   0    0    0    00
[   38.238812] 1    0    0   0   0    0    0    00
[   38.244906] 1    0    0   0   0    0    0    00
[   38.251044] 1    0    0   0   0    0    0    00
[   38.257137] 1    0    0   0   0    0    0    00
[   38.263234] 1    0    0   0   0    0    0    00
[   38.269327] 1    0    0   0   0    0    0    00
[   38.275443] 1    0    0   0   0    0    0    00
[   38.281563] 1    0    0   0   0    0    0    00
[   38.287650] 1    0    0   0   0    0    0    00
[   38.293738] 1    0    0   0   0    0    0    00
[   38.299827] 1    0    0   0   0    0    0    00
[   38.305952] 1    0    0   0   0    0    0    00
[   38.312071] 1    0    0   0   0    0    0    00
[   38.318163] 1    0    0   0   0    0    0    00
[   38.324283] 1    0    0   0   0    0    0    00
[   38.330373] 1    1    0   1   0    0    0    42
[   38.336465] IO APIC #12......
[   38.340828] .... register #00: 0C000000
[   38.346161] .......    : physical APIC id: 0C
[   38.352081] .......    : Delivery Type: 0
[   38.357605] .......    : LTS          : 0
[   38.363109] .... register #01: 00170020
[   38.368462] .......     : max redirection entries: 17
[   38.375136] .......     : PRQ implemented: 0
[   38.380932] .......     : IO APIC version: 20
[   38.386819] .... register #02: 00000000
[   38.392147] .......     : arbitration: 00
[   38.397669] .... register #03: 00000001
[   38.402971] .......     : Boot DT    : 1
[   38.408384] .... IRQ redirection table:
[   38.413707] 1    0    0   0   0    0    0    00
[   38.419819] 1    0    0   0   0    0    0    00
[   38.425914] 1    0    0   0   0    0    0    00
[   38.432031] 1    0    0   0   0    0    0    00
[   38.438146] 1    0    0   0   0    0    0    00
[   38.444235] 1    0    0   0   0    0    0    00
[   38.450355] 1    0    0   0   0    0    0    00
[   38.456445] 1    0    0   0   0    0    0    00
[   38.462537] 1    0    0   0   0    0    0    00
[   38.468631] 1    0    0   0   0    0    0    00
[   38.474770] 1    0    0   0   0    0    0    00
[   38.480861] 1    0    0   0   0    0    0    00
[   38.486981] 1    0    0   0   0    0    0    00
[   38.493066] 1    0    0   0   0    0    0    00
[   38.499157] 1    0    0   0   0    0    0    00
[   38.505271] 1    0    0   0   0    0    0    00
[   38.511362] 1    0    0   0   0    0    0    00
[   38.517454] 1    0    0   0   0    0    0    00
[   38.523543] 1    0    0   0   0    0    0    00
[   38.529642] 1    0    0   0   0    0    0    00
[   38.535757] 1    0    0   0   0    0    0    00
[   38.541839] 1    0    0   0   0    0    0    00
[   38.547961] 1    0    0   0   0    0    0    00
[   38.554056] 1    1    0   1   0    0    0    52
[   38.560148] IRQ to pin mappings:
[   38.564802] IRQ0 -> 0:2
[   38.568958] IRQ1 -> 0:1
[   38.573115] IRQ3 -> 0:3
[   38.577231] IRQ4 -> 0:4
[   38.581264] IRQ5 -> 0:5
[   38.585337] IRQ6 -> 0:6
[   38.589453] IRQ7 -> 0:7
[   38.593576] IRQ8 -> 0:8
[   38.597701] IRQ9 -> 0:9
[   38.601820] IRQ10 -> 0:10
[   38.606151] IRQ11 -> 0:11
[   38.610483] IRQ12 -> 0:12
[   38.614817] IRQ13 -> 0:13
[   38.619145] IRQ14 -> 0:14
[   38.623439] IRQ15 -> 0:15
[   38.627768] IRQ16 -> 0:16
[   38.632107] IRQ19 -> 0:19
[   38.636437] IRQ23 -> 0:23
[   38.640771] IRQ42 -> 1:18
[   38.645103] IRQ45 -> 1:21
[   38.649466] IRQ47 -> 1:23
[   38.653801] IRQ71 -> 2:23
[   38.658126] IRQ95 -> 3:23
[   38.662457] IRQ119 -> 4:23
[   38.666878] .................................... done.
[   38.674761] registered taskstats version 1
[   38.682294] Btrfs loaded
[   38.689577] rtc_cmos 00:06: setting system clock to 2014-03-18 16:52:30 =
UTC (1395161550)
[   38.699529] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
[   38.706852] EDD information not available.
[   39.018510] pps pps0: new PPS source ptp0
[   39.023996] ixgbe 0000:03:00.0: registered PHC device on eth0
[   39.440833] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[   39.448386] 8021q: adding VLAN 0 to HW filter on device eth0
[   39.759039] pps pps1: new PPS source ptp1
[   39.764522] ixgbe 0000:03:00.1: registered PHC device on eth1
[   40.180676] IPv6: ADDRCONF(NETDEV_UP): eth1: link is not ready
[   40.188248] 8021q: adding VLAN 0 to HW filter on device eth1
[   44.010326] ixgbe 0000:03:00.0 eth0: NIC Link is Up 1 Gbps, Flow Control=
: None
[   44.028295] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[   44.044140] Sending DHCP requests .., OK
[   47.052143] IP-Config: Got DHCP answer from 192.168.1.1, my address is 1=
92.168.1.188
[   47.065143] ixgbe 0000:03:00.1: removed PHC on eth1
[   47.502028] IP-Config: Complete:
[   47.506721]      device=3Deth0, hwaddr=3Da0:36:9f:18:d5:24, ipaddr=3D192=
=2E168.1.188, mask=3D255.255.255.0, gw=3D192.168.1.1
[   47.519971]      host=3Dbrickland1, domain=3Dlkp.intel.com, nis-domain=
=3D(none)
[   47.528592]      bootserver=3D192.168.1.1, rootserver=3D192.168.1.1, roo=
tpath=3D
[   47.536307]      nameserver0=3D192.168.1.1
[   47.543141] PM: Hibernation image not present or could not be loaded.
[   47.558220] Freeing unused kernel memory: 1436K (ffffffff8233f000 - ffff=
ffff824a6000)
[   47.568843] Write protecting the kernel read-only data: 18432k
[   47.597210] Freeing unused kernel memory: 1720K (ffff880001a52000 - ffff=
880001c00000)
[   47.627448] Freeing unused kernel memory: 1852K (ffff880002031000 - ffff=
880002200000)
[   48.711355] ipmi message handler version 39.2
[   48.723837] IPMI System Interface driver.
[   48.729576] ipmi_si: probing via SMBIOS
[   48.734869] ipmi_si: SMBIOS: io 0xca2 regsize 1 spacing 1 irq 0
[   48.742567] ipmi_si: Adding SMBIOS-specified kcs state machine
[   48.749900] ipmi_si: Trying SMBIOS-specified kcs state machine at i/o ad=
dress 0xca2, slave address 0x20, irq 0
[   48.778524] mpt2sas version 16.100.00.00 loaded
[   48.785965] scsi6 : Fusion MPT SAS Host
[   48.795055] IOAPIC[1]: Set routing entry (9-8 -> 0x5d -> IRQ 32 Mode:1 A=
ctive:1 Dest:0)
[   48.806248] mpt2sas0: 64 BIT PCI BUS DMA ADDRESSING SUPPORTED, total mem=
 (131913648 kB)
[   48.817504] mpt2sas 0000:01:00.0: irq 272 for MSI/MSI-X
[   48.824528] mpt2sas 0000:01:00.0: irq 273 for MSI/MSI-X
[   48.831464] mpt2sas 0000:01:00.0: irq 274 for MSI/MSI-X
[   48.838434] mpt2sas 0000:01:00.0: irq 275 for MSI/MSI-X
[   48.845422] mpt2sas 0000:01:00.0: irq 276 for MSI/MSI-X
[   48.852361] mpt2sas 0000:01:00.0: irq 277 for MSI/MSI-X
[   48.859288] mpt2sas 0000:01:00.0: irq 278 for MSI/MSI-X
[   48.866425] mpt2sas 0000:01:00.0: irq 279 for MSI/MSI-X
[   48.873362] mpt2sas 0000:01:00.0: irq 280 for MSI/MSI-X
[   48.880378] mpt2sas 0000:01:00.0: irq 281 for MSI/MSI-X
[   48.887732] mpt2sas 0000:01:00.0: irq 282 for MSI/MSI-X
[   48.894969] mpt2sas 0000:01:00.0: irq 283 for MSI/MSI-X
[   48.902056] mpt2sas 0000:01:00.0: irq 284 for MSI/MSI-X
[   48.908613] ipmi_si ipmi_si.0: Found new BMC (man_id: 0x000157, prod_id:=
 0x0063, dev_id: 0x21)
[   48.908640] ipmi_si ipmi_si.0: IPMI kcs interface initialized
[   48.928310] mpt2sas 0000:01:00.0: irq 285 for MSI/MSI-X
[   48.935423] mpt2sas 0000:01:00.0: irq 286 for MSI/MSI-X
[   48.942415] mpt2sas 0000:01:00.0: irq 287 for MSI/MSI-X
[   48.949996] mpt2sas0-msix0: PCI-MSI-X enabled: IRQ 272
[   48.956792] mpt2sas0-msix1: PCI-MSI-X enabled: IRQ 273
[   48.963599] mpt2sas0-msix2: PCI-MSI-X enabled: IRQ 274
[   48.970408] mpt2sas0-msix3: PCI-MSI-X enabled: IRQ 275
[   48.977307] mpt2sas0-msix4: PCI-MSI-X enabled: IRQ 276
[   48.983840] mpt2sas0-msix5: PCI-MSI-X enabled: IRQ 277
[   48.990593] mpt2sas0-msix6: PCI-MSI-X enabled: IRQ 278
[   48.997323] mpt2sas0-msix7: PCI-MSI-X enabled: IRQ 279
[   49.004227] mpt2sas0-msix8: PCI-MSI-X enabled: IRQ 280
[   49.010982] mpt2sas0-msix9: PCI-MSI-X enabled: IRQ 281
[   49.017622] mpt2sas0-msix10: PCI-MSI-X enabled: IRQ 282
[   49.024306] mpt2sas0-msix11: PCI-MSI-X enabled: IRQ 283
[   49.031120] mpt2sas0-msix12: PCI-MSI-X enabled: IRQ 284
[   49.038014] mpt2sas0-msix13: PCI-MSI-X enabled: IRQ 285
[   49.038955] microcode: CPU0 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.039101] microcode: CPU1 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.039204] microcode: CPU2 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.039295] microcode: CPU3 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.039404] microcode: CPU4 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.039557] microcode: CPU5 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.039681] microcode: CPU6 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.039817] microcode: CPU7 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.039936] microcode: CPU8 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.040066] microcode: CPU9 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.040227] microcode: CPU10 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.040345] microcode: CPU11 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.040470] microcode: CPU12 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.040600] microcode: CPU13 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.040721] microcode: CPU14 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.040850] microcode: CPU15 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.040987] microcode: CPU16 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.041103] microcode: CPU17 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.041222] microcode: CPU18 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.041981] microcode: CPU19 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.218374] mpt2sas0-msix14: PCI-MSI-X enabled: IRQ 286
[   49.218448] microcode: CPU20 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.218673] microcode: CPU21 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.219045] microcode: CPU22 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.219165] microcode: CPU23 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.219251] microcode: CPU24 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.219390] microcode: CPU25 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.219516] microcode: CPU26 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.219630] microcode: CPU27 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.219756] microcode: CPU28 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.219881] microcode: CPU29 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.220005] microcode: CPU30 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.220148] microcode: CPU31 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.220209] microcode: CPU32 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.220349] microcode: CPU33 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.220440] microcode: CPU34 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.220527] microcode: CPU35 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.220682] microcode: CPU36 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.220811] microcode: CPU37 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.220928] microcode: CPU38 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.221052] microcode: CPU39 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.221150] microcode: CPU40 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.221277] microcode: CPU41 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.221385] microcode: CPU42 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.221512] microcode: CPU43 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.221610] microcode: CPU44 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.221660] microcode: CPU45 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.221733] microcode: CPU46 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.221833] microcode: CPU47 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.221919] microcode: CPU48 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.222001] microcode: CPU49 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.222082] microcode: CPU50 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.222168] microcode: CPU51 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.222250] microcode: CPU52 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.222370] microcode: CPU53 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.222454] microcode: CPU54 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.222510] microcode: CPU55 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.222643] microcode: CPU56 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.222766] microcode: CPU57 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.222877] microcode: CPU58 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.222931] microcode: CPU59 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.223028] microcode: CPU60 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.223142] microcode: CPU61 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.223207] microcode: CPU62 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.223362] microcode: CPU63 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.223454] microcode: CPU64 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.223567] microcode: CPU65 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.223679] microcode: CPU66 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.223812] microcode: CPU67 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.223942] microcode: CPU68 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.224071] microcode: CPU69 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.224183] microcode: CPU70 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.224302] microcode: CPU71 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.224404] microcode: CPU72 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.224511] microcode: CPU73 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.224592] microcode: CPU74 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.224726] microcode: CPU75 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.224807] microcode: CPU76 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.224914] microcode: CPU77 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.224997] microcode: CPU78 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.225133] microcode: CPU79 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.225243] microcode: CPU80 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.225386] microcode: CPU81 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.225495] microcode: CPU82 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.225653] microcode: CPU83 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.225781] microcode: CPU84 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.225903] microcode: CPU85 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.226007] microcode: CPU86 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.226083] microcode: CPU87 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.226179] microcode: CPU88 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.226340] microcode: CPU89 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.226457] microcode: CPU90 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.226583] microcode: CPU91 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.226656] microcode: CPU92 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.226793] microcode: CPU93 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.226884] microcode: CPU94 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.226968] microcode: CPU95 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.227079] microcode: CPU96 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.227177] microcode: CPU97 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.227263] microcode: CPU98 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.227341] microcode: CPU99 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.227463] microcode: CPU100 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.227584] microcode: CPU101 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.227681] microcode: CPU102 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.227795] microcode: CPU103 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.227888] microcode: CPU104 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.227960] microcode: CPU105 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.228065] microcode: CPU106 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.228144] microcode: CPU107 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.228277] microcode: CPU108 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.228362] microcode: CPU109 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.228474] microcode: CPU110 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.228528] microcode: CPU111 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.228610] microcode: CPU112 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.228688] microcode: CPU113 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.228767] microcode: CPU114 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.228838] microcode: CPU115 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.228927] microcode: CPU116 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.228993] microcode: CPU117 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.229051] microcode: CPU118 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.229115] microcode: CPU119 sig=3D0x306e7, pf=3D0x80, revision=3D0x0
[   49.229713] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.f=
snet.co.uk>, Peter Oruba
[   50.005555] mpt2sas0-msix15: PCI-MSI-X enabled: IRQ 287
[   50.012422] mpt2sas0: iomem(0x0000000093340000), mapped(0xffffc9001dfc00=
00), size(65536)
[   50.022842] mpt2sas0: ioport(0x0000000000001000), size(256)
[   50.503028] mpt2sas0: Allocated physical memory: size(7101 kB)
[   50.510597] mpt2sas0: Current Controller Queue Depth(2811), Max Controll=
er Queue Depth(3072)
[   50.521877] mpt2sas0: Scatter Gather Elements per IO(128)
[   50.761095] mpt2sas0: LSISAS2308: FWVersion(15.00.00.00), ChipRevision(0=
x05), BiosVersion(07.29.01.00)
[   50.773355] mpt2sas0: Protocol=3D(Initiator), Capabilities=3D(Raid,TLR,E=
EDP,Snapshot Buffer,Diag Trace Buffer,Task Set Full,NCQ)
[   50.790492] mpt2sas0: sending port enable !!
[   52.330847] mpt2sas0: host_add: handle(0x0001), sas_addr(0x500605b005c36=
e40), phys(8)
[   58.460143] mpt2sas0: port enable: SUCCESS
[   58.466750] scsi 6:1:0:0: Direct-Access     LSI      Logical Volume   30=
00 PQ: 0 ANSI: 6
[   58.478184] scsi 6:1:0:0: RAID0: handle(0x011e), wwid(0x0f7d60fc0e769932=
), pd_count(2), type(SSP)
[   58.489938] scsi 6:1:0:0: qdepth(254), tagged(1), simple(0), ordered(0),=
 scsi_level(7), cmd_que(1)
[   58.504539] scsi 6:0:0:0: Direct-Access     SEAGATE  ST9300653SS      00=
04 PQ: 0 ANSI: 6
[   58.515676] scsi 6:0:0:0: SSP: handle(0x0009), sas_addr(0x5000c50067bdf9=
c1), phy(2), device_name(0x5000c50067bdf9c0)
[   58.519664] scsi 6:0:0:0: SSP: enclosure_logical_id(0x500605b005c36e40),=
 slot(1)
[   58.539334] scsi 6:0:0:0: qdepth(254), tagged(1), simple(0), ordered(0),=
 scsi_level(7), cmd_que(1)
[   58.553932] scsi 6:0:1:0: Direct-Access     SEAGATE  ST9300653SS      00=
04 PQ: 0 ANSI: 6
[   58.565057] scsi 6:0:1:0: SSP: handle(0x000a), sas_addr(0x5000c50067b45a=
75), phy(3), device_name(0x5000c50067b45a74)
[   58.569047] scsi 6:0:1:0: SSP: enclosure_logical_id(0x500605b005c36e40),=
 slot(0)
[   58.588706] scsi 6:0:1:0: qdepth(254), tagged(1), simple(0), ordered(0),=
 scsi_level(7), cmd_que(1)
[   58.602983] sd 6:1:0:0: [sda] 1167966208 512-byte logical blocks: (597 G=
B/556 GiB)
[   58.603188] sd 6:1:0:0: Attached scsi generic sg1 type 0
[   58.604261] scsi 6:0:0:0: Attached scsi generic sg2 type 0
[   58.605108] scsi 6:0:1:0: Attached scsi generic sg3 type 0
[   58.634426] sd 6:1:0:0: [sda] 4096-byte physical blocks
[   58.641817] sd 6:1:0:0: [sda] Write Protect is off
[   58.648192] sd 6:1:0:0: [sda] Mode Sense: 03 00 00 08
[   58.654947] sd 6:1:0:0: [sda] No Caching mode page found
[   58.661885] sd 6:1:0:0: [sda] Assuming drive cache: write through
[   58.670745] sd 6:1:0:0: [sda] No Caching mode page found
[   58.677737] sd 6:1:0:0: [sda] Assuming drive cache: write through
[   58.690491]  sda: sda1 sda2 sda3
[   58.697182] sd 6:1:0:0: [sda] No Caching mode page found
[   58.704157] sd 6:1:0:0: [sda] Assuming drive cache: write through
[   58.712086] sd 6:1:0:0: [sda] Attached SCSI disk
[   58.785129] random: nonblocking pool is initialized

=3D=3D> /lkp/lkp/src/tmp/run_log <=3D=3D
Kernel tests: Boot OK!
PATH=3D/sbin:/usr/sbin:/bin:/usr/bin

=3D=3D> /lkp/lkp/src/tmp/err_log <=3D=3D

=3D=3D> /lkp/lkp/src/tmp/run_log <=3D=3D
downloading latest lkp src code
Kernel tests: Boot OK 2!
/lkp/lkp/src/bin/run-lkp
LKP_SRC_DIR=3D/lkp/lkp/src
RESULT_ROOT=3D/lkp/result/brickland1/micro/will-it-scale/poll2/x86_64-lkp/8=
808b950581f71e3ee4cf8e6cae479f4c7106405/0
job=3D/lkp/scheduled/brickland1/cyclic_will-it-scale-poll2-HEAD-8808b950581=
f71e3ee4cf8e6cae479f4c7106405.yaml
run-job /lkp/scheduled/brickland1/cyclic_will-it-scale-poll2-HEAD-8808b9505=
81f71e3ee4cf8e6cae479f4c7106405.yaml
run: /lkp/lkp/src/monitors/wrapper perf-profile{"freq"=3D>"800"}
run: pre-test
run: /lkp/lkp/src/monitors/event/wait pre-test{}
run: /lkp/lkp/src/monitors/wrapper uptime{}
run: /lkp/lkp/src/monitors/wrapper iostat{}
run: /lkp/lkp/src/monitors/wrapper vmstat{}
run: /lkp/lkp/src/monitors/wrapper numa-numastat{}
run: /lkp/lkp/src/monitors/wrapper numa-vmstat{}
run: /lkp/lkp/src/monitors/wrapper numa-meminfo{}
run: /lkp/lkp/src/monitors/wrapper proc-vmstat{}
run: /lkp/lkp/src/monitors/wrapper meminfo{}
run: /lkp/lkp/src/monitors/wrapper slabinfo{}
run: /lkp/lkp/src/monitors/wrapper interrupts{}
run: /lkp/lkp/src/monitors/wrapper lock_stat{}
run: /lkp/lkp/src/monitors/wrapper latency_stats{}
run: /lkp/lkp/src/monitors/wrapper softirqs{}
run: /lkp/lkp/src/monitors/wrapper bdi_dev_mapping{}
run: /lkp/lkp/src/monitors/wrapper pmeter{}
run: /lkp/lkp/src/monitors/wrapper diskstats{}
run: /lkp/lkp/src/monitors/wrapper zoneinfo{}
run: /lkp/lkp/src/monitors/wrapper energy{}
run: /lkp/lkp/src/monitors/wrapper cpuidle{}
run: /lkp/lkp/src/monitors/wrapper turbostat{}
run: /usr/bin/time -v -o /lkp/lkp/src/tmp/time /lkp/lkp/src/tests/micro/wra=
pper will-it-scale{"test"=3D>"poll2"}
[  171.409202] perf interrupt took too long (2612 > 2500), lowering kernel.=
perf_event_max_sample_rate to 50000
[  171.458606] perf interrupt took too long (5160 > 5000), lowering kernel.=
perf_event_max_sample_rate to 25000
[  171.594163] perf interrupt took too long (10104 > 10000), lowering kerne=
l.perf_event_max_sample_rate to 12500
[  229.097122] BUG: sleeping function called from invalid context at mm/vma=
lloc.c:74
[  229.109704] in_atomic(): 1, irqs_disabled(): 0, pid: 13598, name: poll2_=
threads
[  229.119755] CPU: 17 PID: 13598 Comm: poll2_threads Not tainted 3.14.0-rc=
6-next-20140317 #1
[  229.130914] Hardware name: Intel Corporation BRICKLAND/BRICKLAND, BIOS B=
KLDSDP1.86B.0031.R01.1304221600 04/22/2013
[  229.144432]  0000000000000000 ffff881840111d80 ffffffff81a3ae8a ffffc900=
1cf38000
[  229.155417]  ffff881840111d90 ffffffff81101256 ffff881840111e08 ffffffff=
811b1540
[  229.166340]  ffffc9001cf48fff ffffc9001cf48fff 0000000000000000 ffff8818=
40111dd0
[  229.177355] Call Trace:
[  229.181129]  [<ffffffff81a3ae8a>] dump_stack+0x4d/0x66
[  229.188012]  [<ffffffff81101256>] __might_sleep+0x10a/0x10c
[  229.195320]  [<ffffffff811b1540>] vunmap_page_range+0x143/0x2b2
[  229.203046]  [<ffffffff811b2174>] ? map_vm_area+0x2e/0x40
[  229.210184]  [<ffffffff811b2c95>] remove_vm_area+0x58/0x75
[  229.217361]  [<ffffffff811b2ced>] __vunmap+0x3b/0xaf
[  229.223979]  [<ffffffff811b2df5>] vfree+0x67/0x6a
[  229.230316]  [<ffffffff811f4868>] free_fdmem+0x2a/0x33
[  229.237140]  [<ffffffff811f4949>] __free_fdtable+0x16/0x2a
[  229.244313]  [<ffffffff811f4c1e>] expand_files+0x121/0x143
[  229.251516]  [<ffffffff811f5075>] __alloc_fd+0x5e/0xef
[  229.258363]  [<ffffffff811f5136>] get_unused_fd_flags+0x30/0x32
[  229.266038]  [<ffffffff811dcf02>] do_sys_open+0x12e/0x1d6
[  229.273127]  [<ffffffff811dcfc8>] SyS_open+0x1e/0x20
[  229.279718]  [<ffffffff81a49de9>] system_call_fastpath+0x16/0x1b
[  273.917004] BUG: sleeping function called from invalid context at mm/vma=
lloc.c:74
[  273.929625] in_atomic(): 1, irqs_disabled(): 0, pid: 15170, name: poll2_=
threads
[  273.939680] CPU: 27 PID: 15170 Comm: poll2_threads Not tainted 3.14.0-rc=
6-next-20140317 #1
[  273.950860] Hardware name: Intel Corporation BRICKLAND/BRICKLAND, BIOS B=
KLDSDP1.86B.0031.R01.1304221600 04/22/2013
[  273.964405]  0000000000000000 ffff881844b29d80 ffffffff81a3ae8a ffffc900=
1d181000
[  273.975404]  ffff881844b29d90 ffffffff81101256 ffff881844b29e08 ffffffff=
811b1540
[  273.986314]  ffffc9001d191fff ffffc9001d191fff 0000000000000000 ffff8818=
44b29dd0
[  273.997308] Call Trace:
[  274.001101]  [<ffffffff81a3ae8a>] dump_stack+0x4d/0x66
[  274.007980]  [<ffffffff81101256>] __might_sleep+0x10a/0x10c
[  274.015315]  [<ffffffff811b1540>] vunmap_page_range+0x143/0x2b2
[  274.023044]  [<ffffffff811b2174>] ? map_vm_area+0x2e/0x40
[  274.030178]  [<ffffffff811b2c95>] remove_vm_area+0x58/0x75
[  274.037358]  [<ffffffff811b2ced>] __vunmap+0x3b/0xaf
[  274.043965]  [<ffffffff811b2df5>] vfree+0x67/0x6a
[  274.050337]  [<ffffffff811f4868>] free_fdmem+0x2a/0x33
[  274.057108]  [<ffffffff811f4949>] __free_fdtable+0x16/0x2a
[  274.064284]  [<ffffffff811f4c1e>] expand_files+0x121/0x143
[  274.071480]  [<ffffffff811f5075>] __alloc_fd+0x5e/0xef
[  274.078356]  [<ffffffff811f5136>] get_unused_fd_flags+0x30/0x32
[  274.086027]  [<ffffffff811dcf02>] do_sys_open+0x12e/0x1d6
[  274.093094]  [<ffffffff811dcfc8>] SyS_open+0x1e/0x20
[  274.099699]  [<ffffffff81a49de9>] system_call_fastpath+0x16/0x1b
[  318.773358] BUG: sleeping function called from invalid context at mm/vma=
lloc.c:74
[  318.785909] in_atomic(): 1, irqs_disabled(): 0, pid: 16820, name: poll2_=
threads
[  318.795915] CPU: 13 PID: 16820 Comm: poll2_threads Not tainted 3.14.0-rc=
6-next-20140317 #1
[  318.807103] Hardware name: Intel Corporation BRICKLAND/BRICKLAND, BIOS B=
KLDSDP1.86B.0031.R01.1304221600 04/22/2013
[  318.820593]  0000000000000000 ffff8820439d3d80 ffffffff81a3ae8a ffffc900=
1d401000
[  318.831677]  ffff8820439d3d90 ffffffff81101256 ffff8820439d3e08 ffffffff=
811b1540
[  318.842522]  ffffc9001d411fff ffffc9001d411fff 0000000000000000 ffff8820=
439d3dd0
[  318.853413] Call Trace:
[  318.857165]  [<ffffffff81a3ae8a>] dump_stack+0x4d/0x66
[  318.863908]  [<ffffffff81101256>] __might_sleep+0x10a/0x10c
[  318.871282]  [<ffffffff811b1540>] vunmap_page_range+0x143/0x2b2
[  318.878999]  [<ffffffff811b2174>] ? map_vm_area+0x2e/0x40
[  318.886071]  [<ffffffff811b2c95>] remove_vm_area+0x58/0x75
[  318.893221]  [<ffffffff811b2ced>] __vunmap+0x3b/0xaf
[  318.899770]  [<ffffffff811b2df5>] vfree+0x67/0x6a
[  318.906171]  [<ffffffff811f4868>] free_fdmem+0x2a/0x33
[  318.912938]  [<ffffffff811f4949>] __free_fdtable+0x16/0x2a
[  318.920209]  [<ffffffff811f4c1e>] expand_files+0x121/0x143
[  318.927322]  [<ffffffff811f5075>] __alloc_fd+0x5e/0xef
[  318.934213]  [<ffffffff811f5136>] get_unused_fd_flags+0x30/0x32
[  318.941832]  [<ffffffff811dcf02>] do_sys_open+0x12e/0x1d6
[  318.948868]  [<ffffffff811dcfc8>] SyS_open+0x1e/0x20
[  318.955432]  [<ffffffff81a49de9>] system_call_fastpath+0x16/0x1b
[  363.710911] BUG: sleeping function called from invalid context at mm/vma=
lloc.c:74
[  363.723635] in_atomic(): 1, irqs_disabled(): 0, pid: 18411, name: poll2_=
threads
[  363.733856] CPU: 48 PID: 18411 Comm: poll2_threads Not tainted 3.14.0-rc=
6-next-20140317 #1
[  363.744982] Hardware name: Intel Corporation BRICKLAND/BRICKLAND, BIOS B=
KLDSDP1.86B.0031.R01.1304221600 04/22/2013
[  363.758461]  0000000000000000 ffff88203bd59d80 ffffffff81a3ae8a ffffc900=
1d814000
[  363.769467]  ffff88203bd59d90 ffffffff81101256 ffff88203bd59e08 ffffffff=
811b1540
[  363.780586]  ffffc9001d824fff ffffc9001d824fff 0000000000000000 ffff8820=
3bd59dd0
[  363.791793] Call Trace:
[  363.795761]  [<ffffffff81a3ae8a>] dump_stack+0x4d/0x66
[  363.802774]  [<ffffffff81101256>] __might_sleep+0x10a/0x10c
[  363.810038]  [<ffffffff811b1540>] vunmap_page_range+0x143/0x2b2
[  363.817702]  [<ffffffff811b2174>] ? map_vm_area+0x2e/0x40
[  363.824798]  [<ffffffff811b2c95>] remove_vm_area+0x58/0x75
[  363.831956]  [<ffffffff811b2ced>] __vunmap+0x3b/0xaf
[  363.838704]  [<ffffffff811b2df5>] vfree+0x67/0x6a
[  363.845017]  [<ffffffff811f4868>] free_fdmem+0x2a/0x33
[  363.851783]  [<ffffffff811f4949>] __free_fdtable+0x16/0x2a
[  363.859139]  [<ffffffff811f4c1e>] expand_files+0x121/0x143
[  363.866454]  [<ffffffff811f5075>] __alloc_fd+0x5e/0xef
[  363.873231]  [<ffffffff811f5136>] get_unused_fd_flags+0x30/0x32
[  363.880912]  [<ffffffff811dcf02>] do_sys_open+0x12e/0x1d6
[  363.887954]  [<ffffffff811dcfc8>] SyS_open+0x1e/0x20
[  363.894699]  [<ffffffff81a49de9>] system_call_fastpath+0x16/0x1b
geting new job...
downloading kernel image ...
downloading initrds ...
kexecing...
kexec -l /tmp//kernel/x86_64-lkp/8808b950581f71e3ee4cf8e6cae479f4c7106405/v=
mlinuz-3.14.0-rc6-next-20140317 --initrd=3D/tmp/initrd-19670 --append=3D"us=
er=3Dlkp job=3D/lkp/scheduled/brickland1/reconfirm_will-it-scale-page_fault=
1-x86_64-lkp-8808b950581f71e3ee4cf8e6cae479f4c7106405-2.yaml ARCH=3Dx86_64 =
BOOT_IMAGE=3D/kernel/x86_64-lkp/8808b950581f71e3ee4cf8e6cae479f4c7106405/vm=
linuz-3.14.0-rc6-next-20140317 kconfig=3Dx86_64-lkp commit=3D8808b950581f71=
e3ee4cf8e6cae479f4c7106405 bm_initrd=3D/lkp/benchmarks/will-it-scale.cgz mo=
dules_initrd=3D/kernel/x86_64-lkp/8808b950581f71e3ee4cf8e6cae479f4c7106405/=
modules.cgz max_uptime=3D900 RESULT_ROOT=3D/lkp/result/brickland1/micro/wil=
l-it-scale/page_fault1/x86_64-lkp/8808b950581f71e3ee4cf8e6cae479f4c7106405/=
1 initrd=3D/kernel-tests/initrd/lkp-rootfs.cgz root=3D/dev/ram0 ip=3D::::br=
ickland1::dhcp oops=3Dpanic ipmi_si.tryacpi=3D0 ipmi_watchdog.start_now=3D1=
 earlyprintk=3DttyS0,115200 debug apic=3Ddebug sysrq_always_enabled rcupdat=
e.rcu_cpu_stall_timeout=3D100 panic=3D10 softlockup_panic=3D1 nmi_watchdog=
=3Dpanic load_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 console=
=3Dtty0 vga=3Dnormal"
[  406.140488] ixgbe 0000:03:00.0: removed PHC on eth0
[  406.582052] kvm: exiting hardware virtualization
[  406.718648] mpt2sas0: IR shutdown (sending)
[  406.723708] mpt2sas0: IR shutdown (complete): ioc_status(0x0000), loginf=
o(0x00000000)
[  406.732950] mpt2sas0: sending diag reset !!
[  407.736121] mpt2sas0: diag reset: SUCCESS
[  408.413166] Starting new kernel

--Kj7319i9nmIyA2yE--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
