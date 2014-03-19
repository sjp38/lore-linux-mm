Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 3C1776B0164
	for <linux-mm@kvack.org>; Wed, 19 Mar 2014 08:08:56 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id rr13so8883687pbb.1
        for <linux-mm@kvack.org>; Wed, 19 Mar 2014 05:08:55 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id zh8si9495929pac.31.2014.03.19.05.08.49
        for <linux-mm@kvack.org>;
        Wed, 19 Mar 2014 05:08:50 -0700 (PDT)
Date: Wed, 19 Mar 2014 20:07:47 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [cpuidle] BUG: sleeping function called from invalid context at
 /c/kernel-tests/src/lkp/mm/vmalloc.c:74
Message-ID: <20140319120747.GA7600@localhost>
References: <20140319120251.GC7277@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140319120251.GC7277@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-pm@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, lkp@01.org

On Wed, Mar 19, 2014 at 08:02:51PM +0800, Fengguang Wu wrote:
> Greetings,
> 
> FYI, the below debug patch triggers a warning on cpuidle code path

One more dmesg:

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.14.0-rc6-next-20140317 (kbuild@xian) (gcc version 4.8.2 (Debian 4.8.2-16) ) #1 SMP Mon Mar 17 20:01:18 CST 2014
[    0.000000] Command line: BOOT_IMAGE=/kernel/x86_64-lkp/8808b950581f71e3ee4cf8e6cae479f4c7106405/vmlinuz-3.14.0-rc6-next-20140317 user=lkp job=/lkp/scheduled/lkp-wsx02/cyclic_netperf-power-120s-25%-SCTP_STREAM_MANY-HEAD-8808b950581f71e3ee4cf8e6cae479f4c7106405.yaml ARCH=x86_64 BOOT_IMAGE=/kernel/x86_64-lkp/8808b950581f71e3ee4cf8e6cae479f4c7106405/vmlinuz-3.14.0-rc6-next-20140317 kconfig=x86_64-lkp commit=8808b950581f71e3ee4cf8e6cae479f4c7106405 max_uptime=996 RESULT_ROOT=/lkp/result/lkp-wsx02/micro/netperf/120s-25%-SCTP_STREAM_MANY/x86_64-lkp/8808b950581f71e3ee4cf8e6cae479f4c7106405/0 root=/dev/ram0 ip=::::lkp-wsx02::dhcp oops=panic earlyprintk=ttyS0,115200 debug apic=debug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=100 panic=10 softlockup_panic=1 nmi_watchdog=panic load_ramdisk=2 prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000100-0x000000000009b3ff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009b400-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000007b43dfff] usable
[    0.000000] BIOS-e820: [mem 0x000000007b43e000-0x000000007b440fff] reserved
[    0.000000] BIOS-e820: [mem 0x000000007b441000-0x000000007b67cfff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x000000007b67d000-0x000000007b68bfff] ACPI data
[    0.000000] BIOS-e820: [mem 0x000000007b68c000-0x000000007b68efff] reserved
[    0.000000] BIOS-e820: [mem 0x000000007b68f000-0x000000007b693fff] ACPI data
[    0.000000] BIOS-e820: [mem 0x000000007b694000-0x000000007b7bcfff] reserved
[    0.000000] BIOS-e820: [mem 0x000000007b7bd000-0x000000007ba3cfff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x000000007ba3d000-0x000000007baa7fff] reserved
[    0.000000] BIOS-e820: [mem 0x000000007baa8000-0x000000007bcfffff] ACPI data
[    0.000000] BIOS-e820: [mem 0x000000007bd00000-0x000000007bd16fff] reserved
[    0.000000] BIOS-e820: [mem 0x000000007bd17000-0x000000007bd19fff] ACPI data
[    0.000000] BIOS-e820: [mem 0x000000007bd1a000-0x000000007bd49fff] reserved
[    0.000000] BIOS-e820: [mem 0x000000007bd4a000-0x000000007bd5efff] ACPI data
[    0.000000] BIOS-e820: [mem 0x000000007bd5f000-0x000000007bdfefff] reserved
[    0.000000] BIOS-e820: [mem 0x000000007bdff000-0x000000007bdfffff] ACPI data
[    0.000000] BIOS-e820: [mem 0x000000007be00000-0x000000007be4efff] reserved
[    0.000000] BIOS-e820: [mem 0x000000007be4f000-0x000000007bf70fff] ACPI data
[    0.000000] BIOS-e820: [mem 0x000000007bf71000-0x000000007bfcefff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x000000007bfcf000-0x000000007bffefff] ACPI data
[    0.000000] BIOS-e820: [mem 0x000000007bfff000-0x000000008fffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fc000000-0x00000000fcffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fed1c000-0x00000000fed1ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000ff000000-0x00000000ffffffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000207fffffff] usable
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.5 present.
[    0.000000] DMI: QCI QSSC-S4R/QSSC-S4R, BIOS QSSC-S4R.QCI.01.00.0030.031120111710 03/11/2011
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] No AGP bridge found
[    0.000000] e820: last_pfn = 0x2080000 max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: write-back
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-DFFFF write-through
[    0.000000]   E0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 00080000000 mask FFF80000000 uncachable
[    0.000000]   1 base FC000000000 mask FFF00000000 uncachable
[    0.000000]   2 disabled
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000]   8 disabled
[    0.000000]   9 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
[    0.000000] e820: last_pfn = 0x7b43e max_arch_pfn = 0x400000000
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000fd9e0-0x000fd9ef] mapped at [ffff8800000fd9e0]
[    0.000000]   mpc: efc20-eff2c
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] Base memory trampoline at [ffff880000095000] 95000 size 24576
[    0.000000] Using GB pages for direct mapping
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x0266b000, 0x0266bfff] PGTABLE
[    0.000000] BRK [0x0266c000, 0x0266cfff] PGTABLE
[    0.000000] BRK [0x0266d000, 0x0266dfff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x207fe00000-0x207fffffff]
[    0.000000]  [mem 0x207fe00000-0x207fffffff] page 1G
[    0.000000] init_memory_mapping: [mem 0x207c000000-0x207fdfffff]
[    0.000000]  [mem 0x207c000000-0x207fdfffff] page 1G
[    0.000000] init_memory_mapping: [mem 0x2000000000-0x207bffffff]
[    0.000000]  [mem 0x2000000000-0x207bffffff] page 1G
[    0.000000] init_memory_mapping: [mem 0x1000000000-0x1fffffffff]
[    0.000000]  [mem 0x1000000000-0x1fffffffff] page 1G
[    0.000000] init_memory_mapping: [mem 0x00100000-0x7b43dfff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x7b3fffff] page 2M
[    0.000000]  [mem 0x7b400000-0x7b43dfff] page 4k
[    0.000000] init_memory_mapping: [mem 0x100000000-0xfffffffff]
[    0.000000]  [mem 0x100000000-0xfffffffff] page 1G
[    0.000000] RAMDISK: [mem 0x6e448000-0x7b433fff]
[    0.000000] ACPI: RSDP 0x00000000000F0410 000024 (v02 QUANTA)
[    0.000000] ACPI: XSDT 0x000000007BFFE120 0000BC (v01 QUANTA QSSC-S4R 00000000      01000013)
[    0.000000] ACPI: FACP 0x000000007BFFD000 0000F4 (v04 QUANTA QSSC-S4R 00000000 MSFT 0100000D)
[    0.000000] ACPI: DSDT 0x000000007BFE1000 01B7B5 (v02 QUANTA QSSC-S4R 00000003 MSFT 0100000D)
[    0.000000] ACPI: FACS 0x000000007BF71000 000040
[    0.000000] ACPI: APIC 0x000000007BFE0000 0004C4 (v02 QUANTA QSSC-S4R 00000000 MSFT 0100000D)
[    0.000000] ACPI: MSCT 0x000000007BFDF000 000090 (v01 QUANTA QSSC-S4R 00000001 MSFT 0100000D)
[    0.000000] ACPI: MCFG 0x000000007BFDE000 00003C (v01 QUANTA QSSC-S4R 00000001 MSFT 0100000D)
[    0.000000] ACPI: HPET 0x000000007BFDD000 000038 (v01 QUANTA QSSC-S4R 00000001 MSFT 0100000D)
[    0.000000] ACPI: SLIT 0x000000007BFDC000 00003C (v01 QUANTA QSSC-S4R 00000001 MSFT 0100000D)
[    0.000000] ACPI: SRAT 0x000000007BFDB000 000A30 (v02 QUANTA QSSC-S4R 00000001 MSFT 0100000D)
[    0.000000] ACPI: SPCR 0x000000007BFDA000 000050 (v01 QUANTA QSSC-S4R 00000000 MSFT 0100000D)
[    0.000000] ACPI: WDDT 0x000000007BFD9000 000040 (v01 QUANTA QSSC-S4R 00000000 MSFT 0100000D)
[    0.000000] ACPI: SSDT 0x000000007BF24000 04C744 (v02 QUANTA QSSC-S4R 00004000 INTL 20061109)
[    0.000000] ACPI: SSDT 0x000000007BFD8000 000174 (v02 QUANTA QSSC-S4R 00004000 INTL 20061109)
[    0.000000] ACPI: PMCT 0x000000007BFD7000 000060 (v01 QUANTA QSSC-S4R 00000000 MSFT 0100000D)
[    0.000000] ACPI: MIGT 0x000000007BFD6000 000040 (v01 QUANTA QSSC-S4R 00000000 MSFT 0100000D)
[    0.000000] ACPI: TCPA 0x000000007BFD3000 000032 (v00 QUANTA QSSC-S4R 00000000      00000000)
[    0.000000] ACPI: HEST 0x000000007BFD2000 0000A8 (v01 QUANTA QSSC-S4R 00000001 INTL 00000001)
[    0.000000] ACPI: BERT 0x000000007BFD1000 000030 (v01 QUANTA QSSC-S4R 00000001 INTL 00000001)
[    0.000000] ACPI: ERST 0x000000007BFD0000 000230 (v01 QUANTA QSSC-S4R 00000001 INTL 00000001)
[    0.000000] ACPI: EINJ 0x000000007BFCF000 000130 (v01 QUANTA QSSC-S4R 00000001 INTL 00000001)
[    0.000000] ACPI: DMAR 0x000000007BF23000 0002F8 (v01 QUANTA QSSC-S4R 00000001 MSFT 0100000D)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5f3000 (        fee00000)
[    0.000000] SRAT: PXM 0 -> APIC 0x00 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x01 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x02 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x03 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x04 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x05 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x10 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x11 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x12 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x13 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x20 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x21 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x22 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x23 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x24 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x25 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x30 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x31 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x32 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x33 -> Node 0
[    0.000000] SRAT: PXM 1 -> APIC 0x40 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x41 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x42 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x43 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x44 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x45 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x50 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x51 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x52 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x53 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x60 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x61 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x62 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x63 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x64 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x65 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x70 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x71 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x72 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x73 -> Node 1
[    0.000000] SRAT: PXM 2 -> APIC 0x80 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x81 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x82 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x83 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x84 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x85 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x90 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x91 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x92 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x93 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0xa0 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0xa1 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0xa2 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0xa3 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0xa4 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0xa5 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0xb0 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0xb1 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0xb2 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0xb3 -> Node 2
[    0.000000] SRAT: PXM 3 -> APIC 0xc0 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0xc1 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0xc2 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0xc3 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0xc4 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0xc5 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0xd0 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0xd1 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0xd2 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0xd3 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0xe0 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0xe1 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0xe2 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0xe3 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0xe4 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0xe5 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0xf0 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0xf1 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0xf2 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0xf3 -> Node 3
[    0.000000] SRAT: Node 0 PXM 0 [mem 0x00000000-0x7fffffff]
[    0.000000] SRAT: Node 0 PXM 0 [mem 0x100000000-0x87fffffff]
[    0.000000] SRAT: Node 1 PXM 1 [mem 0x880000000-0x107fffffff]
[    0.000000] SRAT: Node 2 PXM 2 [mem 0x1080000000-0x187fffffff]
[    0.000000] SRAT: Node 3 PXM 3 [mem 0x1880000000-0x207fffffff]
[    0.000000] SRAT: Node 0 PXM 0 [mem 0x2100000000-0x40ffffffff] hotplug
[    0.000000] SRAT: Node 0 PXM 0 [mem 0x4100000000-0x60ffffffff] hotplug
[    0.000000] SRAT: Node 1 PXM 1 [mem 0x6100000000-0x80ffffffff] hotplug
[    0.000000] SRAT: Node 1 PXM 1 [mem 0x8100000000-0xa0ffffffff] hotplug
[    0.000000] SRAT: Node 2 PXM 2 [mem 0xa100000000-0xc0ffffffff] hotplug
[    0.000000] SRAT: Node 2 PXM 2 [mem 0xc100000000-0xe0ffffffff] hotplug
[    0.000000] SRAT: Node 3 PXM 3 [mem 0xe100000000-0x100ffffffff] hotplug
[    0.000000] SRAT: Node 3 PXM 3 [mem 0x10100000000-0x120ffffffff] hotplug
[    0.000000] NUMA: Initialized distance table, cnt=4
[    0.000000] NUMA: Node 0 [mem 0x00000000-0x7fffffff] + [mem 0x100000000-0x87fffffff] -> [mem 0x00000000-0x87fffffff]
[    0.000000] Initmem setup node 0 [mem 0x00000000-0x87fffffff]
[    0.000000]   NODE_DATA [mem 0x87fffb000-0x87fffffff]
[    0.000000] Initmem setup node 1 [mem 0x880000000-0x107fffffff]
[    0.000000]   NODE_DATA [mem 0x107fffb000-0x107fffffff]
[    0.000000] Initmem setup node 2 [mem 0x1080000000-0x187fffffff]
[    0.000000]   NODE_DATA [mem 0x187fffb000-0x187fffffff]
[    0.000000] Initmem setup node 3 [mem 0x1880000000-0x207fffffff]
[    0.000000]   NODE_DATA [mem 0x207fff8000-0x207fffcfff]
[    0.000000]  [ffffea0000000000-ffffea0021ffffff] PMD -> [ffff88085fe00000-ffff88087fdfffff] on node 0
[    0.000000]  [ffffea0022000000-ffffea0041ffffff] PMD -> [ffff88105fe00000-ffff88107fdfffff] on node 1
[    0.000000]  [ffffea0042000000-ffffea0061ffffff] PMD -> [ffff88185fe00000-ffff88187fdfffff] on node 2
[    0.000000]  [ffffea0062000000-ffffea0081ffffff] PMD -> [ffff88205f600000-ffff88207f5fffff] on node 3
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   [mem 0x100000000-0x207fffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009afff]
[    0.000000]   node   0: [mem 0x00100000-0x7b43dfff]
[    0.000000]   node   0: [mem 0x100000000-0x87fffffff]
[    0.000000]   node   1: [mem 0x880000000-0x107fffffff]
[    0.000000]   node   2: [mem 0x1080000000-0x187fffffff]
[    0.000000]   node   3: [mem 0x1880000000-0x207fffffff]
[    0.000000] On node 0 totalpages: 8369112
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3994 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 7825 pages used for memmap
[    0.000000]   DMA32 zone: 500798 pages, LIFO batch:31
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
[    0.000000] ACPI: LAPIC (acpi_id[0x28] lapic_id[0x80] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x14] lapic_id[0x40] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x3c] lapic_id[0xc0] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0a] lapic_id[0x20] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x32] lapic_id[0xa0] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1e] lapic_id[0x60] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x46] lapic_id[0xe0] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x06] lapic_id[0x10] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x2e] lapic_id[0x90] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1a] lapic_id[0x50] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x42] lapic_id[0xd0] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x10] lapic_id[0x30] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x38] lapic_id[0xb0] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x24] lapic_id[0x70] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x4c] lapic_id[0xf0] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x2a] lapic_id[0x82] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x16] lapic_id[0x42] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x3e] lapic_id[0xc2] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0c] lapic_id[0x22] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x34] lapic_id[0xa2] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x20] lapic_id[0x62] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x48] lapic_id[0xe2] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x08] lapic_id[0x12] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x30] lapic_id[0x92] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1c] lapic_id[0x52] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x44] lapic_id[0xd2] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x12] lapic_id[0x32] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x3a] lapic_id[0xb2] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x26] lapic_id[0x72] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x4e] lapic_id[0xf2] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x29] lapic_id[0x81] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x15] lapic_id[0x41] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x3d] lapic_id[0xc1] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0b] lapic_id[0x21] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x33] lapic_id[0xa1] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1f] lapic_id[0x61] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x47] lapic_id[0xe1] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x07] lapic_id[0x11] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x2f] lapic_id[0x91] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1b] lapic_id[0x51] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x43] lapic_id[0xd1] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x11] lapic_id[0x31] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x39] lapic_id[0xb1] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x25] lapic_id[0x71] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x4d] lapic_id[0xf1] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x03] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x2b] lapic_id[0x83] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x17] lapic_id[0x43] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x3f] lapic_id[0xc3] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0d] lapic_id[0x23] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x35] lapic_id[0xa3] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x21] lapic_id[0x63] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x49] lapic_id[0xe3] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x09] lapic_id[0x13] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x31] lapic_id[0x93] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1d] lapic_id[0x53] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x45] lapic_id[0xd3] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x13] lapic_id[0x33] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x3b] lapic_id[0xb3] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x27] lapic_id[0x73] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x4f] lapic_id[0xf3] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x04] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x2c] lapic_id[0x84] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x18] lapic_id[0x44] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x40] lapic_id[0xc4] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0e] lapic_id[0x24] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x36] lapic_id[0xa4] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x22] lapic_id[0x64] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x4a] lapic_id[0xe4] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x05] lapic_id[0x05] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x2d] lapic_id[0x85] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x19] lapic_id[0x45] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x41] lapic_id[0xc5] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0f] lapic_id[0x25] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x37] lapic_id[0xa5] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x23] lapic_id[0x65] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x4b] lapic_id[0xe5] enabled)
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
[    0.000000] ACPI: IOAPIC (id[0x08] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 8, version 32, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: IOAPIC (id[0x09] address[0xfec01000] gsi_base[24])
[    0.000000] IOAPIC[1]: apic_id 9, version 32, address 0xfec01000, GSI 24-47
[    0.000000] ACPI: IOAPIC (id[0x0a] address[0xfec04000] gsi_base[48])
[    0.000000] IOAPIC[2]: apic_id 10, version 32, address 0xfec04000, GSI 48-71
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 8, APIC INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 8, APIC INT 09
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 8, APIC INT 01
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 8, APIC INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 8, APIC INT 04
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 05, APIC ID 8, APIC INT 05
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 8, APIC INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 8, APIC INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 8, APIC INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0a, APIC ID 8, APIC INT 0a
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0b, APIC ID 8, APIC INT 0b
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 8, APIC INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 8, APIC INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 8, APIC INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 8, APIC INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a401 base: 0xfed00000
[    0.000000] smpboot: Allowing 80 CPUs, 0 hotplug CPUs
[    0.000000] mapped IOAPIC to ffffffffff5f2000 (fec00000)
[    0.000000] mapped IOAPIC to ffffffffff5f1000 (fec01000)
[    0.000000] mapped IOAPIC to ffffffffff5f0000 (fec04000)
[    0.000000] nr_irqs_gsi: 88
[    0.000000] PM: Registered nosave memory: [mem 0x0009b000-0x0009bfff]
[    0.000000] PM: Registered nosave memory: [mem 0x0009c000-0x0009ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000dffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000e0000-0x000fffff]
[    0.000000] PM: Registered nosave memory: [mem 0x7b43e000-0x7b440fff]
[    0.000000] PM: Registered nosave memory: [mem 0x7b441000-0x7b67cfff]
[    0.000000] PM: Registered nosave memory: [mem 0x7b67d000-0x7b68bfff]
[    0.000000] PM: Registered nosave memory: [mem 0x7b68c000-0x7b68efff]
[    0.000000] PM: Registered nosave memory: [mem 0x7b68f000-0x7b693fff]
[    0.000000] PM: Registered nosave memory: [mem 0x7b694000-0x7b7bcfff]
[    0.000000] PM: Registered nosave memory: [mem 0x7b7bd000-0x7ba3cfff]
[    0.000000] PM: Registered nosave memory: [mem 0x7ba3d000-0x7baa7fff]
[    0.000000] PM: Registered nosave memory: [mem 0x7baa8000-0x7bcfffff]
[    0.000000] PM: Registered nosave memory: [mem 0x7bd00000-0x7bd16fff]
[    0.000000] PM: Registered nosave memory: [mem 0x7bd17000-0x7bd19fff]
[    0.000000] PM: Registered nosave memory: [mem 0x7bd1a000-0x7bd49fff]
[    0.000000] PM: Registered nosave memory: [mem 0x7bd4a000-0x7bd5efff]
[    0.000000] PM: Registered nosave memory: [mem 0x7bd5f000-0x7bdfefff]
[    0.000000] PM: Registered nosave memory: [mem 0x7bdff000-0x7bdfffff]
[    0.000000] PM: Registered nosave memory: [mem 0x7be00000-0x7be4efff]
[    0.000000] PM: Registered nosave memory: [mem 0x7be4f000-0x7bf70fff]
[    0.000000] PM: Registered nosave memory: [mem 0x7bf71000-0x7bfcefff]
[    0.000000] PM: Registered nosave memory: [mem 0x7bfcf000-0x7bffefff]
[    0.000000] PM: Registered nosave memory: [mem 0x7bfff000-0x8fffffff]
[    0.000000] PM: Registered nosave memory: [mem 0x90000000-0xfbffffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfc000000-0xfcffffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfd000000-0xfed1bfff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed1c000-0xfed1ffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed20000-0xfeffffff]
[    0.000000] PM: Registered nosave memory: [mem 0xff000000-0xffffffff]
[    0.000000] e820: [mem 0x90000000-0xfbffffff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] setup_percpu: NR_CPUS:512 nr_cpumask_bits:512 nr_cpu_ids:80 nr_node_ids:4
[    0.000000] PERCPU: Embedded 27 pages/cpu @ffff88085f800000 s81088 r8192 d21312 u262144
[    0.000000] pcpu-alloc: s81088 r8192 d21312 u262144 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 00 04 08 12 16 20 24 28 [0] 32 36 40 44 48 52 56 60 
[    0.000000] pcpu-alloc: [0] 64 68 72 76 -- -- -- -- [1] 01 05 09 13 17 21 25 29 
[    0.000000] pcpu-alloc: [1] 33 37 41 45 49 53 57 61 [1] 65 69 73 77 -- -- -- -- 
[    0.000000] pcpu-alloc: [2] 02 06 10 14 18 22 26 30 [2] 34 38 42 46 50 54 58 62 
[    0.000000] pcpu-alloc: [2] 66 70 74 78 -- -- -- -- [3] 03 07 11 15 19 23 27 31 
[    0.000000] pcpu-alloc: [3] 35 39 43 47 51 55 59 63 [3] 67 71 75 79 -- -- -- -- 
[    0.000000] Built 4 zonelists in Zone order, mobility grouping on.  Total pages: 33010930
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: BOOT_IMAGE=/kernel/x86_64-lkp/8808b950581f71e3ee4cf8e6cae479f4c7106405/vmlinuz-3.14.0-rc6-next-20140317 user=lkp job=/lkp/scheduled/lkp-wsx02/cyclic_netperf-power-120s-25%-SCTP_STREAM_MANY-HEAD-8808b950581f71e3ee4cf8e6cae479f4c7106405.yaml ARCH=x86_64 BOOT_IMAGE=/kernel/x86_64-lkp/8808b950581f71e3ee4cf8e6cae479f4c7106405/vmlinuz-3.14.0-rc6-next-20140317 kconfig=x86_64-lkp commit=8808b950581f71e3ee4cf8e6cae479f4c7106405 max_uptime=996 RESULT_ROOT=/lkp/result/lkp-wsx02/micro/netperf/120s-25%-SCTP_STREAM_MANY/x86_64-lkp/8808b950581f71e3ee4cf8e6cae479f4c7106405/0 root=/dev/ram0 ip=::::lkp-wsx02::dhcp oops=panic earlyprintk=ttyS0,115200 debug apic=debug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=100 panic=10 softlockup_panic=1 nmi_watchdog=panic load_ramdisk=2 prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Memory: 131731224K/134139744K available (10556K kernel code, 1268K rwdata, 4292K rodata, 1436K init, 1760K bss, 2408520K reserved)
[    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=80, Nodes=4
[    0.000000] Hierarchical RCU implementation.
[    0.000000] 	RCU dyntick-idle grace-period acceleration is enabled.
[    0.000000] 	RCU restricting CPUs from NR_CPUS=512 to nr_cpu_ids=80.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=80
[    0.000000] NR_IRQS:33024 nr_irqs:2136 16
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] bootconsole [earlyser0] disabled
[    0.000000] console [ttyS0] enabled
[    0.000000] allocated 536870912 bytes of page_cgroup
[    0.000000] please try 'cgroup_disable=memory' option if you don't want memory cgroups
[    0.000000] Disabling automatic NUMA balancing. Configure with numa_balancing= or the kernel.numa_balancing sysctl
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Fast TSC calibration using PIT
[    0.000000] tsc: Detected 2394.281 MHz processor
[    0.000042] Calibrating delay loop (skipped), value calculated using timer frequency.. 4788.56 BogoMIPS (lpj=9577124)
[    0.012311] pid_max: default: 81920 minimum: 640
[    0.017689] ACPI: Core revision 20140214
[    0.108793] ACPI: All ACPI Tables successfully acquired
[    0.126760] Dentry cache hash table entries: 16777216 (order: 15, 134217728 bytes)
[    0.175568] Inode-cache hash table entries: 8388608 (order: 14, 67108864 bytes)
[    0.201651] Mount-cache hash table entries: 256
[    0.207817] Initializing cgroup subsys memory
[    0.213232] Initializing cgroup subsys devices
[    0.218799] Initializing cgroup subsys freezer
[    0.224280] Initializing cgroup subsys blkio
[    0.229559] Initializing cgroup subsys perf_event
[    0.235437] Initializing cgroup subsys hugetlb
[    0.241103] CPU: Physical Processor ID: 0
[    0.246098] CPU: Processor Core ID: 0
[    0.250784] mce: CPU supports 24 MCE banks
[    0.255911] CPU0: Thermal monitoring enabled (TM1)
[    0.261819] Last level iTLB entries: 4KB 512, 2MB 7, 4MB 7
[    0.261819] Last level dTLB entries: 4KB 512, 2MB 32, 4MB 32, 1GB 0
[    0.261819] tlb_flushall_shift: 6
[    0.280249] Freeing SMP alternatives memory: 44K (ffffffff824a6000 - ffffffff824b1000)
[    0.292202] ftrace: allocating 40687 entries in 159 pages
[    0.326147] Getting VERSION: 1060015
[    0.330732] Getting VERSION: 1060015
[    0.335225] Getting ID: 0
[    0.338541] Getting ID: 0
[    0.342094] Switched APIC routing to physical flat.
[    0.348101] enabled ExtINT on CPU#0
[    0.353071] ENABLING IO-APIC IRQs
[    0.357282] init IO_APIC IRQs
[    0.361107]  apic 8 pin 0 not connected
[    0.365908] IOAPIC[0]: Set routing entry (8-1 -> 0x31 -> IRQ 1 Mode:0 Active:0 Dest:0)
[    0.375734] IOAPIC[0]: Set routing entry (8-2 -> 0x30 -> IRQ 0 Mode:0 Active:0 Dest:0)
[    0.385475] IOAPIC[0]: Set routing entry (8-3 -> 0x33 -> IRQ 3 Mode:0 Active:0 Dest:0)
[    0.395030] IOAPIC[0]: Set routing entry (8-4 -> 0x34 -> IRQ 4 Mode:0 Active:0 Dest:0)
[    0.404616] IOAPIC[0]: Set routing entry (8-5 -> 0x35 -> IRQ 5 Mode:0 Active:0 Dest:0)
[    0.414199] IOAPIC[0]: Set routing entry (8-6 -> 0x36 -> IRQ 6 Mode:0 Active:0 Dest:0)
[    0.423778] IOAPIC[0]: Set routing entry (8-7 -> 0x37 -> IRQ 7 Mode:0 Active:0 Dest:0)
[    0.433346] IOAPIC[0]: Set routing entry (8-8 -> 0x38 -> IRQ 8 Mode:0 Active:0 Dest:0)
[    0.442905] IOAPIC[0]: Set routing entry (8-9 -> 0x39 -> IRQ 9 Mode:1 Active:0 Dest:0)
[    0.452460] IOAPIC[0]: Set routing entry (8-10 -> 0x3a -> IRQ 10 Mode:0 Active:0 Dest:0)
[    0.462225] IOAPIC[0]: Set routing entry (8-11 -> 0x3b -> IRQ 11 Mode:0 Active:0 Dest:0)
[    0.472001] IOAPIC[0]: Set routing entry (8-12 -> 0x3c -> IRQ 12 Mode:0 Active:0 Dest:0)
[    0.481760] IOAPIC[0]: Set routing entry (8-13 -> 0x3d -> IRQ 13 Mode:0 Active:0 Dest:0)
[    0.491525] IOAPIC[0]: Set routing entry (8-14 -> 0x3e -> IRQ 14 Mode:0 Active:0 Dest:0)
[    0.501285] IOAPIC[0]: Set routing entry (8-15 -> 0x3f -> IRQ 15 Mode:0 Active:0 Dest:0)
[    0.511054]  apic 8 pin 16 not connected
[    0.515817]  apic 8 pin 17 not connected
[    0.520586]  apic 8 pin 18 not connected
[    0.525363]  apic 8 pin 19 not connected
[    0.530140]  apic 8 pin 20 not connected
[    0.534916]  apic 8 pin 21 not connected
[    0.539693]  apic 8 pin 22 not connected
[    0.544466]  apic 8 pin 23 not connected
[    0.549243]  apic 9 pin 0 not connected
[    0.553911]  apic 9 pin 1 not connected
[    0.558577]  apic 9 pin 2 not connected
[    0.563243]  apic 9 pin 3 not connected
[    0.567916]  apic 9 pin 4 not connected
[    0.572585]  apic 9 pin 5 not connected
[    0.577243]  apic 9 pin 6 not connected
[    0.581923]  apic 9 pin 7 not connected
[    0.586602]  apic 9 pin 8 not connected
[    0.591280]  apic 9 pin 9 not connected
[    0.595956]  apic 9 pin 10 not connected
[    0.600730]  apic 9 pin 11 not connected
[    0.605500]  apic 9 pin 12 not connected
[    0.610273]  apic 9 pin 13 not connected
[    0.615037]  apic 9 pin 14 not connected
[    0.619803]  apic 9 pin 15 not connected
[    0.624576]  apic 9 pin 16 not connected
[    0.629342]  apic 9 pin 17 not connected
[    0.634109]  apic 9 pin 18 not connected
[    0.638880]  apic 9 pin 19 not connected
[    0.643658]  apic 9 pin 20 not connected
[    0.648434]  apic 9 pin 21 not connected
[    0.653210]  apic 9 pin 22 not connected
[    0.657983]  apic 9 pin 23 not connected
[    0.662756]  apic 10 pin 0 not connected
[    0.667532]  apic 10 pin 1 not connected
[    0.672300]  apic 10 pin 2 not connected
[    0.677067]  apic 10 pin 3 not connected
[    0.681846]  apic 10 pin 4 not connected
[    0.686609]  apic 10 pin 5 not connected
[    0.691374]  apic 10 pin 6 not connected
[    0.696145]  apic 10 pin 7 not connected
[    0.700913]  apic 10 pin 8 not connected
[    0.705689]  apic 10 pin 9 not connected
[    0.710466]  apic 10 pin 10 not connected
[    0.715339]  apic 10 pin 11 not connected
[    0.720211]  apic 10 pin 12 not connected
[    0.725084]  apic 10 pin 13 not connected
[    0.729954]  apic 10 pin 14 not connected
[    0.734819]  apic 10 pin 15 not connected
[    0.739694]  apic 10 pin 16 not connected
[    0.744554]  apic 10 pin 17 not connected
[    0.749418]  apic 10 pin 18 not connected
[    0.754293]  apic 10 pin 19 not connected
[    0.759156]  apic 10 pin 20 not connected
[    0.764020]  apic 10 pin 21 not connected
[    0.768896]  apic 10 pin 22 not connected
[    0.773760]  apic 10 pin 23 not connected
[    0.778765] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.825589] smpboot: CPU0: Intel(R) Xeon(R) CPU E7- 8870  @ 2.40GHz (fam: 06, model: 2f, stepping: 02)
[    0.836935] Using local APIC timer interrupts.
[    0.836935] calibrating APIC timer ...
[    0.950976] ... lapic delta = 831240
[    0.955352] ... PM-Timer delta = 357950
[    0.960026] ... PM-Timer result ok
[    0.964216] ..... delta 831240
[    0.968009] ..... mult: 35701486
[    0.971994] ..... calibration result: 531993
[    0.977160] ..... CPU clock speed is 2393.3878 MHz.
[    0.983006] ..... host bus clock speed is 132.3993 MHz.
[    0.989256] Performance Events: PEBS fmt1+, 16-deep LBR, Westmere events, Intel PMU driver.
[    0.999593] perf_event_intel: CPUID marked event: 'bus cycles' unavailable
[    1.007674] ... version:                3
[    1.012537] ... bit width:              48
[    1.017505] ... generic registers:      4
[    1.022379] ... value mask:             0000ffffffffffff
[    1.028707] ... max period:             000000007fffffff
[    1.035035] ... fixed-purpose events:   3
[    1.039907] ... event mask:             000000070000000f
[    1.049647] x86: Booting SMP configuration:
[    1.054722] .... node  #2, CPUs:        #1
[    1.071838] masked ExtINT on CPU#1
[    1.173617] 
[    1.175669] .... node  #1, CPUs:    #2
[    1.192293] masked ExtINT on CPU#2
[    1.293655] 
[    1.295705] .... node  #3, CPUs:    #3
[    1.312335] masked ExtINT on CPU#3
[    1.413750] 
[    1.415797] .... node  #0, CPUs:    #4
[    1.432410] masked ExtINT on CPU#4
[    1.438758] 
[    1.440811] .... node  #2, CPUs:    #5
[    1.457427] masked ExtINT on CPU#5
[    1.463691] 
[    1.465740] .... node  #1, CPUs:    #6
[    1.482377] masked ExtINT on CPU#6
[    1.488618] 
[    1.490672] .... node  #3, CPUs:    #7
[    1.507298] masked ExtINT on CPU#7
[    1.513542] 
[    1.515591] .... node  #0, CPUs:    #8
[    1.532203] masked ExtINT on CPU#8
[    1.538554] 
[    1.540598] .... node  #2, CPUs:    #9
[    1.557215] masked ExtINT on CPU#9
[    1.563470] 
[    1.565515] .... node  #1, CPUs:   #10
[    1.582133] masked ExtINT on CPU#10
[    1.588499] 
[    1.590550] .... node  #3, CPUs:   #11
[    1.607165] masked ExtINT on CPU#11
[    1.613514] 
[    1.615563] .... node  #0, CPUs:   #12
[    1.632176] masked ExtINT on CPU#12
[    1.638639] 
[    1.640697] .... node  #2, CPUs:   #13
[    1.657333] masked ExtINT on CPU#13
[    1.663665] 
[    1.665720] .... node  #1, CPUs:   #14
[    1.682353] masked ExtINT on CPU#14
[    1.688704] 
[    1.690757] .... node  #3, CPUs:   #15
[    1.707374] masked ExtINT on CPU#15
[    1.713718] 
[    1.715768] .... node  #0, CPUs:   #16
[    1.732382] masked ExtINT on CPU#16
[    1.738822] 
[    1.740875] .... node  #2, CPUs:   #17
[    1.757490] masked ExtINT on CPU#17
[    1.763844] 
[    1.765897] .... node  #1, CPUs:   #18
[    1.782513] masked ExtINT on CPU#18
[    1.788882] 
[    1.790933] .... node  #3, CPUs:   #19
[    1.807547] masked ExtINT on CPU#19
[    1.813879] 
[    1.815919] .... node  #0, CPUs:   #20
[    1.832533] masked ExtINT on CPU#20
[    1.838982] 
[    1.841027] .... node  #2, CPUs:   #21
[    1.857644] masked ExtINT on CPU#21
[    1.864012] 
[    1.866053] .... node  #1, CPUs:   #22
[    1.882669] masked ExtINT on CPU#22
[    1.889046] 
[    1.891099] .... node  #3, CPUs:   #23
[    1.907716] masked ExtINT on CPU#23
[    1.914060] 
[    1.916113] .... node  #0, CPUs:   #24
[    1.932727] masked ExtINT on CPU#24
[    1.939171] 
[    1.941219] .... node  #2, CPUs:   #25
[    1.957836] masked ExtINT on CPU#25
[    1.964183] 
[    1.966230] .... node  #1, CPUs:   #26
[    1.982845] masked ExtINT on CPU#26
[    1.989212] 
[    1.991267] .... node  #3, CPUs:   #27
[    2.007884] masked ExtINT on CPU#27
[    2.014230] 
[    2.016273] .... node  #0, CPUs:   #28
[    2.032886] masked ExtINT on CPU#28
[    2.039339] 
[    2.041392] .... node  #2, CPUs:   #29
[    2.058007] masked ExtINT on CPU#29
[    2.064369] 
[    2.066422] .... node  #1, CPUs:   #30
[    2.083035] masked ExtINT on CPU#30
[    2.089400] 
[    2.091452] .... node  #3, CPUs:   #31
[    2.108066] masked ExtINT on CPU#31
[    2.114400] 
[    2.116451] .... node  #0, CPUs:   #32
[    2.133284] masked ExtINT on CPU#32
[    2.139782] 
[    2.141826] .... node  #2, CPUs:   #33
[    2.158446] masked ExtINT on CPU#33
[    2.164797] 
[    2.166843] .... node  #1, CPUs:   #34
[    2.183457] masked ExtINT on CPU#34
[    2.189828] 
[    2.191881] .... node  #3, CPUs:   #35
[    2.208497] masked ExtINT on CPU#35
[    2.214843] 
[    2.216888] .... node  #0, CPUs:   #36
[    2.233499] masked ExtINT on CPU#36
[    2.239946] 
[    2.241988] .... node  #2, CPUs:   #37
[    2.258602] masked ExtINT on CPU#37
[    2.264963] 
[    2.267011] .... node  #1, CPUs:   #38
[    2.283626] masked ExtINT on CPU#38
[    2.289998] 
[    2.292050] .... node  #3, CPUs:   #39
[    2.308666] masked ExtINT on CPU#39
[    2.315016] 
[    2.317068] .... node  #0, CPUs:   #40
[    2.333682] masked ExtINT on CPU#40
[    2.340130] 
[    2.342188] .... node  #2, CPUs:   #41
[    2.358804] masked ExtINT on CPU#41
[    2.365168] 
[    2.367221] .... node  #1, CPUs:   #42
[    2.383836] masked ExtINT on CPU#42
[    2.390213] 
[    2.392262] .... node  #3, CPUs:   #43
[    2.408877] masked ExtINT on CPU#43
[    2.415223] 
[    2.417272] .... node  #0, CPUs:   #44
[    2.433884] masked ExtINT on CPU#44
[    2.440352] 
[    2.450492] .... node  #2, CPUs:   #45
[    2.467103] masked ExtINT on CPU#45
[    2.473455] 
[    2.475499] .... node  #1, CPUs:   #46
[    2.492114] masked ExtINT on CPU#46
[    2.498473] 
[    2.500526] .... node  #3, CPUs:   #47
[    2.517144] masked ExtINT on CPU#47
[    2.523489] 
[    2.525530] .... node  #0, CPUs:   #48
[    2.542142] masked ExtINT on CPU#48
[    2.548609] 
[    2.550669] .... node  #2, CPUs:   #49
[    2.567273] masked ExtINT on CPU#49
[    2.573629] 
[    2.575676] .... node  #1, CPUs:   #50
[    2.592291] masked ExtINT on CPU#50
[    2.598678] 
[    2.600731] .... node  #3, CPUs:   #51
[    2.617347] masked ExtINT on CPU#51
[    2.623683] 
[    2.625730] .... node  #0, CPUs:   #52
[    2.642341] masked ExtINT on CPU#52
[    2.648801] 
[    2.650863] .... node  #2, CPUs:   #53
[    2.667476] masked ExtINT on CPU#53
[    2.673833] 
[    2.675890] .... node  #1, CPUs:   #54
[    2.692507] masked ExtINT on CPU#54
[    2.698866] 
[    2.700919] .... node  #3, CPUs:   #55
[    2.717533] masked ExtINT on CPU#55
[    2.723890] 
[    2.725938] .... node  #0, CPUs:   #56
[    2.742550] masked ExtINT on CPU#56
[    2.749010] 
[    2.751069] .... node  #2, CPUs:   #57
[    2.767685] masked ExtINT on CPU#57
[    2.774043] 
[    2.776094] .... node  #1, CPUs:   #58
[    2.792711] masked ExtINT on CPU#58
[    2.799080] 
[    2.801131] .... node  #3, CPUs:   #59
[    2.817745] masked ExtINT on CPU#59
[    2.824098] 
[    2.826151] .... node  #0, CPUs:   #60
[    2.842762] masked ExtINT on CPU#60
[    2.849222] 
[    2.851277] .... node  #2, CPUs:   #61
[    2.867890] masked ExtINT on CPU#61
[    2.874252] 
[    2.876294] .... node  #1, CPUs:   #62
[    2.892908] masked ExtINT on CPU#62
[    2.899276] 
[    2.901327] .... node  #3, CPUs:   #63
[    2.917940] masked ExtINT on CPU#63
[    2.924290] 
[    2.926338] .... node  #0, CPUs:   #64
[    2.942954] masked ExtINT on CPU#64
[    2.949408] 
[    2.951467] .... node  #2, CPUs:   #65
[    2.968081] masked ExtINT on CPU#65
[    2.974450] 
[    2.976502] .... node  #1, CPUs:   #66
[    2.993117] masked ExtINT on CPU#66
[    2.999500] 
[    3.001555] .... node  #3, CPUs:   #67
[    3.018168] masked ExtINT on CPU#67
[    3.024536] 
[    3.026593] .... node  #0, CPUs:   #68
[    3.043207] masked ExtINT on CPU#68
[    3.049672] 
[    3.051730] .... node  #2, CPUs:   #69
[    3.068345] masked ExtINT on CPU#69
[    3.074707] 
[    3.076755] .... node  #1, CPUs:   #70
[    3.093368] masked ExtINT on CPU#70
[    3.099740] 
[    3.101794] .... node  #3, CPUs:   #71
[    3.118407] masked ExtINT on CPU#71
[    3.124764] 
[    3.126810] .... node  #0, CPUs:   #72
[    3.143423] masked ExtINT on CPU#72
[    3.149885] 
[    3.151942] .... node  #2, CPUs:   #73
[    3.168557] masked ExtINT on CPU#73
[    3.174916] 
[    3.176959] .... node  #1, CPUs:   #74
[    3.193573] masked ExtINT on CPU#74
[    3.199960] 
[    3.202012] .... node  #3, CPUs:   #75
[    3.218625] masked ExtINT on CPU#75
[    3.224975] 
[    3.227026] .... node  #0, CPUs:   #76
[    3.243636] masked ExtINT on CPU#76
[    3.250115] 
[    3.252178] .... node  #2, CPUs:   #77
[    3.268792] masked ExtINT on CPU#77
[    3.275149] 
[    3.277201] .... node  #1, CPUs:   #78
[    3.293813] masked ExtINT on CPU#78
[    3.300189] 
[    3.302240] .... node  #3, CPUs:   #79
[    3.318854] masked ExtINT on CPU#79
[    3.325108] x86: Booted up 4 nodes, 80 CPUs
[    3.330507] smpboot: Total of 80 processors activated (383052.54 BogoMIPS)
[    3.828712] devtmpfs: initialized
[    3.860017] PM: Registering ACPI NVS region [mem 0x7b441000-0x7b67cfff] (2342912 bytes)
[    3.869794] PM: Registering ACPI NVS region [mem 0x7b7bd000-0x7ba3cfff] (2621440 bytes)
[    3.879595] PM: Registering ACPI NVS region [mem 0x7bf71000-0x7bfcefff] (385024 bytes)
[    3.891488] xor: measuring software checksum speed
[    3.934969]    prefetch64-sse:  9923.000 MB/sec
[    3.978995]    generic_sse:  8725.000 MB/sec
[    3.984164] xor: using function: prefetch64-sse (9923.000 MB/sec)
[    3.991399] atomic64 test passed for x86-64 platform with CX8 and with SSE
[    3.999637] NET: Registered protocol family 16
[    4.005783] cpuidle: using governor ladder
[    4.010747] cpuidle: using governor menu
[    4.016119] ACPI FADT declares the system doesn't support PCIe ASPM, so disable it
[    4.025289] ACPI: bus type PCI registered
[    4.030151] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    4.037829] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0x80000000-0x8fffffff] (base 0x80000000)
[    4.048950] PCI: MMCONFIG at [mem 0x80000000-0x8fffffff] reserved in E820
[    4.072919] PCI: Using configuration type 1 for base access
[    4.159107] raid6: sse2x1    5118 MB/s
[    4.231152] raid6: sse2x2    6194 MB/s
[    4.303187] raid6: sse2x4    7365 MB/s
[    4.307763] raid6: using algorithm sse2x4 (7365 MB/s)
[    4.313805] raid6: using ssse3x2 recovery algorithm
[    4.320053] ACPI: Added _OSI(Module Device)
[    4.325120] ACPI: Added _OSI(Processor Device)
[    4.330479] ACPI: Added _OSI(3.0 _SCP Extensions)
[    4.336122] ACPI: Added _OSI(Processor Aggregator Device)
[    4.456495] ACPI: Interpreter enabled
[    4.460987] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S2_] (20140214/hwxface-580)
[    4.472172] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S3_] (20140214/hwxface-580)
[    4.483355] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S4_] (20140214/hwxface-580)
[    4.494532] ACPI: (supports S0 S1 S5)
[    4.499007] ACPI: Using IOAPIC for interrupt routing
[    4.505024] HEST: Table parsing has been initialized.
[    4.511061] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    4.551440] ACPI: PCI Root Bridge [IOH0] (domain 0000 [bus 00-7f])
[    4.558741] acpi PNP0A08:00: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[    4.568784] acpi PNP0A08:00: _OSC: platform does not support [PCIeHotplug AER]
[    4.577745] acpi PNP0A08:00: _OSC: OS now controls [PME PCIeCapability]
[    4.586052] acpi PNP0A08:00: ignoring host bridge window [mem 0x000c4000-0x000cbfff] (conflicts with Video ROM [mem 0x000c0000-0x000c7fff])
[    4.601101] PCI host bridge to bus 0000:00
[    4.606076] pci_bus 0000:00: root bus resource [bus 00-7f]
[    4.612600] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    4.619896] pci_bus 0000:00: root bus resource [io  0x1000-0x9fff]
[    4.627206] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff]
[    4.635287] pci_bus 0000:00: root bus resource [mem 0xfed40000-0xfedfffff]
[    4.643370] pci_bus 0000:00: root bus resource [mem 0x90000000-0xafffffff]
[    4.651458] pci_bus 0000:00: root bus resource [mem 0xfc000000000-0xfc07fffffff]
[    4.660452] pci 0000:00:00.0: [8086:3407] type 00 class 0x060000
[    4.667629] pci 0000:00:00.0: PME# supported from D0 D3hot D3cold
[    4.674973] pci 0000:00:01.0: [8086:3408] type 01 class 0x060400
[    4.682135] pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
[    4.689413] pci 0000:00:01.0: System wakeup disabled by ACPI
[    4.696184] pci 0000:00:02.0: [8086:3409] type 01 class 0x060400
[    4.703351] pci 0000:00:02.0: PME# supported from D0 D3hot D3cold
[    4.710619] pci 0000:00:02.0: System wakeup disabled by ACPI
[    4.717404] pci 0000:00:03.0: [8086:340a] type 01 class 0x060400
[    4.724570] pci 0000:00:03.0: PME# supported from D0 D3hot D3cold
[    4.731902] pci 0000:00:05.0: [8086:340c] type 01 class 0x060400
[    4.739066] pci 0000:00:05.0: PME# supported from D0 D3hot D3cold
[    4.746345] pci 0000:00:05.0: System wakeup disabled by ACPI
[    4.753139] pci 0000:00:07.0: [8086:340e] type 01 class 0x060400
[    4.760313] pci 0000:00:07.0: PME# supported from D0 D3hot D3cold
[    4.767597] pci 0000:00:07.0: System wakeup disabled by ACPI
[    4.774383] pci 0000:00:09.0: [8086:3410] type 01 class 0x060400
[    4.781553] pci 0000:00:09.0: PME# supported from D0 D3hot D3cold
[    4.788825] pci 0000:00:09.0: System wakeup disabled by ACPI
[    4.795604] pci 0000:00:0a.0: [8086:3411] type 01 class 0x060400
[    4.802760] pci 0000:00:0a.0: PME# supported from D0 D3hot D3cold
[    4.810031] pci 0000:00:0a.0: System wakeup disabled by ACPI
[    4.816810] pci 0000:00:10.0: [8086:3425] type 00 class 0x080000
[    4.824062] pci 0000:00:10.1: [8086:3426] type 00 class 0x080000
[    4.831308] pci 0000:00:11.0: [8086:3427] type 00 class 0x080000
[    4.838566] pci 0000:00:11.1: [8086:3428] type 00 class 0x080000
[    4.845828] pci 0000:00:13.0: [8086:342d] type 00 class 0x080020
[    4.852955] pci 0000:00:13.0: reg 0x10: [mem 0x95c02000-0x95c02fff]
[    4.860405] pci 0000:00:13.0: PME# supported from D0 D3hot D3cold
[    4.867726] pci 0000:00:14.0: [8086:342e] type 00 class 0x080000
[    4.874988] pci 0000:00:14.1: [8086:3422] type 00 class 0x080000
[    4.882236] pci 0000:00:14.2: [8086:3423] type 00 class 0x080000
[    4.889484] pci 0000:00:14.3: [8086:3438] type 00 class 0x080000
[    4.896727] pci 0000:00:15.0: [8086:342f] type 00 class 0x080020
[    4.903978] pci 0000:00:16.0: [8086:3430] type 00 class 0x088000
[    4.911102] pci 0000:00:16.0: reg 0x10: [mem 0xaff1c000-0xaff1ffff 64bit]
[    4.919254] pci 0000:00:16.1: [8086:3431] type 00 class 0x088000
[    4.926383] pci 0000:00:16.1: reg 0x10: [mem 0xaff18000-0xaff1bfff 64bit]
[    4.934534] pci 0000:00:16.2: [8086:3432] type 00 class 0x088000
[    4.941663] pci 0000:00:16.2: reg 0x10: [mem 0xaff14000-0xaff17fff 64bit]
[    4.949813] pci 0000:00:16.3: [8086:3433] type 00 class 0x088000
[    4.956938] pci 0000:00:16.3: reg 0x10: [mem 0xaff10000-0xaff13fff 64bit]
[    4.965088] pci 0000:00:16.4: [8086:3429] type 00 class 0x088000
[    4.972214] pci 0000:00:16.4: reg 0x10: [mem 0xaff0c000-0xaff0ffff 64bit]
[    4.980357] pci 0000:00:16.5: [8086:342a] type 00 class 0x088000
[    4.987485] pci 0000:00:16.5: reg 0x10: [mem 0xaff08000-0xaff0bfff 64bit]
[    4.995627] pci 0000:00:16.6: [8086:342b] type 00 class 0x088000
[    5.002754] pci 0000:00:16.6: reg 0x10: [mem 0xaff04000-0xaff07fff 64bit]
[    5.010907] pci 0000:00:16.7: [8086:342c] type 00 class 0x088000
[    5.018032] pci 0000:00:16.7: reg 0x10: [mem 0xaff00000-0xaff03fff 64bit]
[    5.026171] pci 0000:00:1a.0: [8086:3a37] type 00 class 0x0c0300
[    5.033324] pci 0000:00:1a.0: reg 0x20: [io  0x60c0-0x60df]
[    5.040060] pci 0000:00:1a.0: System wakeup disabled by ACPI
[    5.046849] pci 0000:00:1a.1: [8086:3a38] type 00 class 0x0c0300
[    5.054002] pci 0000:00:1a.1: reg 0x20: [io  0x60a0-0x60bf]
[    5.060751] pci 0000:00:1a.1: System wakeup disabled by ACPI
[    5.067540] pci 0000:00:1a.2: [8086:3a39] type 00 class 0x0c0300
[    5.074682] pci 0000:00:1a.2: reg 0x20: [io  0x6080-0x609f]
[    5.081420] pci 0000:00:1a.2: System wakeup disabled by ACPI
[    5.088201] pci 0000:00:1a.7: [8086:3a3c] type 00 class 0x0c0320
[    5.095327] pci 0000:00:1a.7: reg 0x10: [mem 0x95c01000-0x95c013ff]
[    5.102805] pci 0000:00:1a.7: PME# supported from D0 D3hot D3cold
[    5.110105] pci 0000:00:1a.7: System wakeup disabled by ACPI
[    5.116895] pci 0000:00:1c.0: [8086:3a40] type 01 class 0x060400
[    5.124083] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    5.131364] pci 0000:00:1c.0: System wakeup disabled by ACPI
[    5.138157] pci 0000:00:1c.4: [8086:3a48] type 01 class 0x060400
[    5.145335] pci 0000:00:1c.4: PME# supported from D0 D3hot D3cold
[    5.152618] pci 0000:00:1c.4: System wakeup disabled by ACPI
[    5.159401] pci 0000:00:1d.0: [8086:3a34] type 00 class 0x0c0300
[    5.166546] pci 0000:00:1d.0: reg 0x20: [io  0x6060-0x607f]
[    5.173279] pci 0000:00:1d.0: System wakeup disabled by ACPI
[    5.180060] pci 0000:00:1d.1: [8086:3a35] type 00 class 0x0c0300
[    5.187219] pci 0000:00:1d.1: reg 0x20: [io  0x6040-0x605f]
[    5.193963] pci 0000:00:1d.1: System wakeup disabled by ACPI
[    5.200745] pci 0000:00:1d.2: [8086:3a36] type 00 class 0x0c0300
[    5.207902] pci 0000:00:1d.2: reg 0x20: [io  0x6020-0x603f]
[    5.214649] pci 0000:00:1d.2: System wakeup disabled by ACPI
[    5.221444] pci 0000:00:1d.7: [8086:3a3a] type 00 class 0x0c0320
[    5.228580] pci 0000:00:1d.7: reg 0x10: [mem 0x95c00000-0x95c003ff]
[    5.236063] pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
[    5.243363] pci 0000:00:1d.7: System wakeup disabled by ACPI
[    5.258255] pci 0000:00:1e.0: [8086:244e] type 01 class 0x060401
[    5.265469] pci 0000:00:1e.0: System wakeup disabled by ACPI
[    5.272245] pci 0000:00:1f.0: [8086:3a16] type 00 class 0x060100
[    5.279424] pci 0000:00:1f.0: quirk: [io  0x0400-0x047f] claimed by ICH6 ACPI/GPIO/TCO
[    5.288991] pci 0000:00:1f.0: quirk: [io  0x0500-0x053f] claimed by ICH6 GPIO
[    5.297364] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 1 PIO at 0680 (mask 000f)
[    5.306553] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 2 PIO at 0ca0 (mask 000f)
[    5.315744] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 3 PIO at 0600 (mask 001f)
[    5.325064] pci 0000:00:1f.2: [8086:3a20] type 00 class 0x01018f
[    5.332188] pci 0000:00:1f.2: reg 0x10: [io  0x6138-0x613f]
[    5.338810] pci 0000:00:1f.2: reg 0x14: [io  0x614c-0x614f]
[    5.345431] pci 0000:00:1f.2: reg 0x18: [io  0x6130-0x6137]
[    5.352052] pci 0000:00:1f.2: reg 0x1c: [io  0x6148-0x614b]
[    5.358668] pci 0000:00:1f.2: reg 0x20: [io  0x6110-0x611f]
[    5.365290] pci 0000:00:1f.2: reg 0x24: [io  0x6100-0x610f]
[    5.372051] pci 0000:00:1f.3: [8086:3a30] type 00 class 0x0c0500
[    5.379178] pci 0000:00:1f.3: reg 0x10: [mem 0xaff20000-0xaff200ff 64bit]
[    5.387185] pci 0000:00:1f.3: reg 0x20: [io  0x6000-0x601f]
[    5.393939] pci 0000:00:1f.5: [8086:3a26] type 00 class 0x010185
[    5.401068] pci 0000:00:1f.5: reg 0x10: [io  0x6128-0x612f]
[    5.407702] pci 0000:00:1f.5: reg 0x14: [io  0x6144-0x6147]
[    5.414329] pci 0000:00:1f.5: reg 0x18: [io  0x6120-0x6127]
[    5.420960] pci 0000:00:1f.5: reg 0x1c: [io  0x6140-0x6143]
[    5.427592] pci 0000:00:1f.5: reg 0x20: [io  0x60f0-0x60ff]
[    5.434221] pci 0000:00:1f.5: reg 0x24: [io  0x60e0-0x60ef]
[    5.441108] pci 0000:01:00.0: [8086:150a] type 00 class 0x020000
[    5.448238] pci 0000:01:00.0: reg 0x10: [mem 0x95b20000-0x95b3ffff]
[    5.455650] pci 0000:01:00.0: reg 0x18: [io  0x5020-0x503f]
[    5.462286] pci 0000:01:00.0: reg 0x1c: [mem 0x95bc4000-0x95bc7fff]
[    5.469788] pci 0000:01:00.0: PME# supported from D0 D3hot D3cold
[    5.477048] pci 0000:01:00.0: reg 0x184: [mem 0x95b40000-0x95b43fff 64bit]
[    5.485157] pci 0000:01:00.0: reg 0x190: [mem 0x95b60000-0x95b63fff 64bit]
[    5.493354] pci 0000:01:00.1: [8086:150a] type 00 class 0x020000
[    5.500486] pci 0000:01:00.1: reg 0x10: [mem 0x95b00000-0x95b1ffff]
[    5.507915] pci 0000:01:00.1: reg 0x18: [io  0x5000-0x501f]
[    5.514547] pci 0000:01:00.1: reg 0x1c: [mem 0x95bc0000-0x95bc3fff]
[    5.522048] pci 0000:01:00.1: PME# supported from D0 D3hot D3cold
[    5.529300] pci 0000:01:00.1: reg 0x184: [mem 0x95b80000-0x95b83fff 64bit]
[    5.537402] pci 0000:01:00.1: reg 0x190: [mem 0x95ba0000-0x95ba3fff 64bit]
[    5.551948] pci 0000:00:01.0: PCI bridge to [bus 01-03]
[    5.558190] pci 0000:00:01.0:   bridge window [io  0x5000-0x5fff]
[    5.565395] pci 0000:00:01.0:   bridge window [mem 0x95b00000-0x95bfffff]
[    5.573518] pci 0000:04:00.0: [8086:150a] type 00 class 0x020000
[    5.580649] pci 0000:04:00.0: reg 0x10: [mem 0x95a20000-0x95a3ffff]
[    5.588076] pci 0000:04:00.0: reg 0x18: [io  0x4020-0x403f]
[    5.594712] pci 0000:04:00.0: reg 0x1c: [mem 0x95ac4000-0x95ac7fff]
[    5.602211] pci 0000:04:00.0: PME# supported from D0 D3hot D3cold
[    5.609468] pci 0000:04:00.0: reg 0x184: [mem 0x95a40000-0x95a43fff 64bit]
[    5.617567] pci 0000:04:00.0: reg 0x190: [mem 0x95a60000-0x95a63fff 64bit]
[    5.625746] pci 0000:04:00.1: [8086:150a] type 00 class 0x020000
[    5.632872] pci 0000:04:00.1: reg 0x10: [mem 0x95a00000-0x95a1ffff]
[    5.640281] pci 0000:04:00.1: reg 0x18: [io  0x4000-0x401f]
[    5.646922] pci 0000:04:00.1: reg 0x1c: [mem 0x95ac0000-0x95ac3fff]
[    5.654407] pci 0000:04:00.1: PME# supported from D0 D3hot D3cold
[    5.661657] pci 0000:04:00.1: reg 0x184: [mem 0x95a80000-0x95a83fff 64bit]
[    5.669767] pci 0000:04:00.1: reg 0x190: [mem 0x95aa0000-0x95aa3fff 64bit]
[    5.684025] pci 0000:00:02.0: PCI bridge to [bus 04-06]
[    5.690275] pci 0000:00:02.0:   bridge window [io  0x4000-0x4fff]
[    5.697491] pci 0000:00:02.0:   bridge window [mem 0x95a00000-0x95afffff]
[    5.705602] pci 0000:07:00.0: [1000:0079] type 00 class 0x010400
[    5.712726] pci 0000:07:00.0: reg 0x10: [io  0x3000-0x30ff]
[    5.719354] pci 0000:07:00.0: reg 0x14: [mem 0x95940000-0x95943fff 64bit]
[    5.727346] pci 0000:07:00.0: reg 0x1c: [mem 0x95900000-0x9593ffff 64bit]
[    5.735337] pci 0000:07:00.0: reg 0x30: [mem 0xfffc0000-0xffffffff pref]
[    5.743260] pci 0000:07:00.0: supports D1 D2
[    5.756061] pci 0000:00:03.0: PCI bridge to [bus 07]
[    5.762014] pci 0000:00:03.0:   bridge window [io  0x3000-0x3fff]
[    5.769230] pci 0000:00:03.0:   bridge window [mem 0x95900000-0x959fffff]
[    5.777224] pci 0000:00:03.0:   bridge window [mem 0x95d00000-0x95dfffff 64bit pref]
[    5.786851] acpiphp: Slot [1] registered
[    5.791658] pci 0000:00:05.0: PCI bridge to [bus 08-0a]
[    5.797899] pci 0000:00:05.0:   bridge window [io  0x2000-0x2fff]
[    5.805111] pci 0000:00:05.0:   bridge window [mem 0x94900000-0x958fffff]
[    5.813098] pci 0000:00:05.0:   bridge window [mem 0x91900000-0x928fffff 64bit pref]
[    5.822697] acpiphp: Slot [2] registered
[    5.827497] pci 0000:00:07.0: PCI bridge to [bus 0b-0d]
[    5.833731] pci 0000:00:07.0:   bridge window [io  0x1000-0x1fff]
[    5.840936] pci 0000:00:07.0:   bridge window [mem 0x93900000-0x948fffff]
[    5.848932] pci 0000:00:07.0:   bridge window [mem 0x92900000-0x938fffff 64bit pref]
[    5.858534] pci 0000:00:09.0: PCI bridge to [bus 0e]
[    5.864716] pci 0000:00:0a.0: PCI bridge to [bus 0f]
[    5.870802] pci 0000:00:1c.0: PCI bridge to [bus 10]
[    5.876751] pci 0000:00:1c.0:   bridge window [io  0x7000-0x7fff]
[    5.883958] pci 0000:00:1c.0:   bridge window [mem 0x95e00000-0x95ffffff]
[    5.891934] pci 0000:00:1c.0:   bridge window [mem 0x96000000-0x961fffff 64bit pref]
[    5.901397] pci 0000:11:00.0: [102b:0522] type 00 class 0x030000
[    5.908526] pci 0000:11:00.0: reg 0x10: [mem 0x90000000-0x90ffffff pref]
[    5.916424] pci 0000:11:00.0: reg 0x14: [mem 0x91800000-0x91803fff]
[    5.923828] pci 0000:11:00.0: reg 0x18: [mem 0x91000000-0x917fffff]
[    5.931284] pci 0000:11:00.0: reg 0x30: [mem 0xffff0000-0xffffffff pref]
[    5.944175] pci 0000:00:1c.4: PCI bridge to [bus 11]
[    5.950134] pci 0000:00:1c.4:   bridge window [io  0x8000-0x8fff]
[    5.957350] pci 0000:00:1c.4:   bridge window [mem 0x91000000-0x918fffff]
[    5.965342] pci 0000:00:1c.4:   bridge window [mem 0x90000000-0x90ffffff 64bit pref]
[    5.974813] pci 0000:00:1e.0: PCI bridge to [bus 12] (subtractive decode)
[    5.982814] pci 0000:00:1e.0:   bridge window [io  0x0000-0x0cf7] (subtractive decode)
[    5.992394] pci 0000:00:1e.0:   bridge window [io  0x1000-0x9fff] (subtractive decode)
[    6.001978] pci 0000:00:1e.0:   bridge window [mem 0x000a0000-0x000bffff] (subtractive decode)
[    6.012326] pci 0000:00:1e.0:   bridge window [mem 0xfed40000-0xfedfffff] (subtractive decode)
[    6.022689] pci 0000:00:1e.0:   bridge window [mem 0x90000000-0xafffffff] (subtractive decode)
[    6.033051] pci 0000:00:1e.0:   bridge window [mem 0xfc000000000-0xfc07fffffff] (subtractive decode)
[    6.044031] acpi PNP0A08:00: Disabling ASPM (FADT indicates it is unsupported)
[    6.053034] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 9 10 *11 12 14 15)
[    6.062809] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 9 *10 11 12 14 15)
[    6.072572] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 *9 10 11 12 14 15)
[    6.082357] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 *5 6 7 9 10 11 12 14 15)
[    6.092130] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
[    6.103304] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 9 10 *11 12 14 15)
[    6.113062] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
[    6.124242] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 7 9 *10 11 12 14 15)
[    6.134146] ACPI: PCI Root Bridge [IOH1] (domain 0000 [bus 80-f7])
[    6.141456] acpi PNP0A08:01: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[    6.151496] acpi PNP0A08:01: _OSC: platform does not support [PCIeHotplug AER]
[    6.160457] acpi PNP0A08:01: _OSC: OS now controls [PME PCIeCapability]
[    6.168425] PCI host bridge to bus 0000:80
[    6.173391] pci_bus 0000:80: root bus resource [bus 80-f7]
[    6.179914] pci_bus 0000:80: root bus resource [io  0xa000-0xffff]
[    6.187222] pci_bus 0000:80: root bus resource [mem 0xb0000000-0xfbffffff]
[    6.195295] pci_bus 0000:80: root bus resource [mem 0xfc080000000-0xfc0ffffffff]
[    6.204294] pci 0000:80:00.0: [8086:3420] type 01 class 0x060400
[    6.211460] pci 0000:80:00.0: PME# supported from D0 D3hot D3cold
[    6.218711] pci 0000:80:00.0: System wakeup disabled by ACPI
[    6.225499] pci 0000:80:01.0: [8086:3408] type 01 class 0x060400
[    6.232678] pci 0000:80:01.0: PME# supported from D0 D3hot D3cold
[    6.239926] pci 0000:80:01.0: System wakeup disabled by ACPI
[    6.246713] pci 0000:80:03.0: [8086:340a] type 01 class 0x060400
[    6.253889] pci 0000:80:03.0: PME# supported from D0 D3hot D3cold
[    6.261135] pci 0000:80:03.0: System wakeup disabled by ACPI
[    6.267925] pci 0000:80:07.0: [8086:340e] type 01 class 0x060400
[    6.275093] pci 0000:80:07.0: PME# supported from D0 D3hot D3cold
[    6.282329] pci 0000:80:07.0: System wakeup disabled by ACPI
[    6.289116] pci 0000:80:09.0: [8086:3410] type 01 class 0x060400
[    6.296280] pci 0000:80:09.0: PME# supported from D0 D3hot D3cold
[    6.303514] pci 0000:80:09.0: System wakeup disabled by ACPI
[    6.310301] pci 0000:80:10.0: [8086:3425] type 00 class 0x080000
[    6.317532] pci 0000:80:10.1: [8086:3426] type 00 class 0x080000
[    6.324756] pci 0000:80:11.0: [8086:3427] type 00 class 0x080000
[    6.331983] pci 0000:80:11.1: [8086:3428] type 00 class 0x080000
[    6.339203] pci 0000:80:13.0: [8086:342d] type 00 class 0x080020
[    6.346327] pci 0000:80:13.0: reg 0x10: [mem 0xb4000000-0xb4000fff]
[    6.353774] pci 0000:80:13.0: PME# supported from D0 D3hot D3cold
[    6.361059] pci 0000:80:14.0: [8086:342e] type 00 class 0x080000
[    6.368297] pci 0000:80:14.1: [8086:3422] type 00 class 0x080000
[    6.375520] pci 0000:80:14.2: [8086:3423] type 00 class 0x080000
[    6.382743] pci 0000:80:14.3: [8086:3438] type 00 class 0x080000
[    6.389963] pci 0000:80:15.0: [8086:342f] type 00 class 0x080020
[    6.397173] pci 0000:80:16.0: [8086:3430] type 00 class 0x088000
[    6.404299] pci 0000:80:16.0: reg 0x10: [mem 0xfbf1c000-0xfbf1ffff 64bit]
[    6.412429] pci 0000:80:16.1: [8086:3431] type 00 class 0x088000
[    6.419547] pci 0000:80:16.1: reg 0x10: [mem 0xfbf18000-0xfbf1bfff 64bit]
[    6.427668] pci 0000:80:16.2: [8086:3432] type 00 class 0x088000
[    6.434789] pci 0000:80:16.2: reg 0x10: [mem 0xfbf14000-0xfbf17fff 64bit]
[    6.442912] pci 0000:80:16.3: [8086:3433] type 00 class 0x088000
[    6.458132] pci 0000:80:16.3: reg 0x10: [mem 0xfbf10000-0xfbf13fff 64bit]
[    6.466243] pci 0000:80:16.4: [8086:3429] type 00 class 0x088000
[    6.473359] pci 0000:80:16.4: reg 0x10: [mem 0xfbf0c000-0xfbf0ffff 64bit]
[    6.481471] pci 0000:80:16.5: [8086:342a] type 00 class 0x088000
[    6.488596] pci 0000:80:16.5: reg 0x10: [mem 0xfbf08000-0xfbf0bfff 64bit]
[    6.496711] pci 0000:80:16.6: [8086:342b] type 00 class 0x088000
[    6.503831] pci 0000:80:16.6: reg 0x10: [mem 0xfbf04000-0xfbf07fff 64bit]
[    6.511950] pci 0000:80:16.7: [8086:342c] type 00 class 0x088000
[    6.519075] pci 0000:80:16.7: reg 0x10: [mem 0xfbf00000-0xfbf03fff 64bit]
[    6.527420] pci 0000:80:00.0: PCI bridge to [bus 81]
[    6.533596] pci 0000:80:01.0: PCI bridge to [bus 82]
[    6.539780] pci 0000:80:03.0: PCI bridge to [bus 83]
[    6.545975] acpiphp: Slot [6] registered
[    6.550784] pci 0000:80:07.0: PCI bridge to [bus 84-86]
[    6.557026] pci 0000:80:07.0:   bridge window [io  0xb000-0xbfff]
[    6.564225] pci 0000:80:07.0:   bridge window [mem 0xb3000000-0xb3ffffff]
[    6.572226] pci 0000:80:07.0:   bridge window [mem 0xb0000000-0xb0ffffff 64bit pref]
[    6.581842] acpiphp: Slot [7] registered
[    6.586647] pci 0000:80:09.0: PCI bridge to [bus 87-89]
[    6.592889] pci 0000:80:09.0:   bridge window [io  0xa000-0xafff]
[    6.600103] pci 0000:80:09.0:   bridge window [mem 0xb2000000-0xb2ffffff]
[    6.608096] pci 0000:80:09.0:   bridge window [mem 0xb1000000-0xb1ffffff 64bit pref]
[    6.617499] acpi PNP0A08:01: Disabling ASPM (FADT indicates it is unsupported)
[    6.626477] ACPI: PCI Root Bridge [PRB3] (domain 0000 [bus fc])
[    6.633491] acpi PNP0A03:00: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[    6.643350] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    6.651203] PCI host bridge to bus 0000:fc
[    6.656175] pci_bus 0000:fc: root bus resource [bus fc]
[    6.662395] pci 0000:fc:00.0: [8086:2b00] type 00 class 0x060000
[    6.669574] pci 0000:fc:00.2: [8086:2b02] type 00 class 0x060000
[    6.676748] pci 0000:fc:00.4: [8086:2b22] type 00 class 0x060000
[    6.683934] pci 0000:fc:00.6: [8086:2b2a] type 00 class 0x060000
[    6.691113] pci 0000:fc:01.0: [8086:2b04] type 00 class 0x060000
[    6.698299] pci 0000:fc:02.0: [8086:2b08] type 00 class 0x060000
[    6.705479] pci 0000:fc:03.0: [8086:2b0c] type 00 class 0x060000
[    6.712665] pci 0000:fc:04.0: [8086:2b10] type 00 class 0x060000
[    6.719840] pci 0000:fc:05.0: [8086:2b14] type 00 class 0x060000
[    6.727014] pci 0000:fc:05.2: [8086:2b16] type 00 class 0x060000
[    6.734184] pci 0000:fc:05.4: [8086:2b13] type 00 class 0x060000
[    6.741369] pci 0000:fc:05.6: [8086:2b53] type 00 class 0x060000
[    6.748553] pci 0000:fc:06.0: [8086:2b18] type 00 class 0x060000
[    6.755737] pci 0000:fc:07.0: [8086:2b1c] type 00 class 0x060000
[    6.762911] pci 0000:fc:07.2: [8086:2b1e] type 00 class 0x060000
[    6.770096] pci 0000:fc:07.4: [8086:2b1b] type 00 class 0x060000
[    6.777272] pci 0000:fc:07.6: [8086:2b5b] type 00 class 0x060000
[    6.784459] pci 0000:fc:08.0: [8086:2b20] type 00 class 0x060000
[    6.791636] pci 0000:fc:09.0: [8086:2b24] type 00 class 0x060000
[    6.798819] pci 0000:fc:0a.0: [8086:2b28] type 00 class 0x060000
[    6.805996] pci 0000:fc:0b.0: [8086:2b2c] type 00 class 0x060000
[    6.813185] pci 0000:fc:0c.0: [8086:2b30] type 00 class 0x060000
[    6.820368] pci 0000:fc:0d.0: [8086:2b34] type 00 class 0x060000
[    6.827553] pci 0000:fc:0e.0: [8086:2b38] type 00 class 0x060000
[    6.834736] pci 0000:fc:0f.0: [8086:2b3c] type 00 class 0x060000
[    6.841917] pci 0000:fc:10.0: [8086:2b40] type 00 class 0x060000
[    6.849103] pci 0000:fc:10.2: [8086:2b42] type 00 class 0x060000
[    6.856280] pci 0000:fc:10.4: [8086:2b32] type 00 class 0x060000
[    6.863465] pci 0000:fc:10.6: [8086:2b3a] type 00 class 0x060000
[    6.870650] pci 0000:fc:11.0: [8086:2b44] type 00 class 0x060000
[    6.877837] pci 0000:fc:11.2: [8086:2b46] type 00 class 0x060000
[    6.885023] pci 0000:fc:11.4: [8086:2b36] type 00 class 0x060000
[    6.892207] pci 0000:fc:11.6: [8086:2b3e] type 00 class 0x060000
[    6.899395] pci 0000:fc:12.0: [8086:2b48] type 00 class 0x060000
[    6.906585] pci 0000:fc:13.0: [8086:2b4c] type 00 class 0x060000
[    6.913767] pci 0000:fc:14.0: [8086:2b50] type 00 class 0x060000
[    6.920954] pci 0000:fc:14.2: [8086:2b52] type 00 class 0x060000
[    6.928137] pci 0000:fc:15.0: [8086:2b54] type 00 class 0x060000
[    6.935315] pci 0000:fc:15.2: [8086:2b56] type 00 class 0x060000
[    6.942502] pci 0000:fc:16.0: [8086:2b58] type 00 class 0x060000
[    6.949687] pci 0000:fc:16.2: [8086:2b5a] type 00 class 0x060000
[    6.956875] pci 0000:fc:17.0: [8086:2b5c] type 00 class 0x060000
[    6.964061] pci 0000:fc:17.2: [8086:2b5e] type 00 class 0x060000
[    6.971252] pci 0000:fc:18.0: [8086:2b60] type 00 class 0x060000
[    6.978442] pci 0000:fc:18.2: [8086:2b62] type 00 class 0x060000
[    6.985627] pci 0000:fc:19.0: [8086:2b64] type 00 class 0x060000
[    6.992812] pci 0000:fc:19.2: [8086:2b66] type 00 class 0x060000
[    7.000000] pci 0000:fc:1a.0: [8086:2b68] type 00 class 0x060000
[    7.007191] pci 0000:fc:1b.0: [8086:2b6c] type 00 class 0x060000
[    7.014441] ACPI: PCI Root Bridge [PRB2] (domain 0000 [bus fd])
[    7.021452] acpi PNP0A03:01: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[    7.031333] acpi PNP0A03:01: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    7.039188] PCI host bridge to bus 0000:fd
[    7.044161] pci_bus 0000:fd: root bus resource [bus fd]
[    7.050407] pci 0000:fd:00.0: [8086:2b00] type 00 class 0x060000
[    7.057595] pci 0000:fd:00.2: [8086:2b02] type 00 class 0x060000
[    7.064777] pci 0000:fd:00.4: [8086:2b22] type 00 class 0x060000
[    7.071952] pci 0000:fd:00.6: [8086:2b2a] type 00 class 0x060000
[    7.079136] pci 0000:fd:01.0: [8086:2b04] type 00 class 0x060000
[    7.086312] pci 0000:fd:02.0: [8086:2b08] type 00 class 0x060000
[    7.093489] pci 0000:fd:03.0: [8086:2b0c] type 00 class 0x060000
[    7.100667] pci 0000:fd:04.0: [8086:2b10] type 00 class 0x060000
[    7.107847] pci 0000:fd:05.0: [8086:2b14] type 00 class 0x060000
[    7.115025] pci 0000:fd:05.2: [8086:2b16] type 00 class 0x060000
[    7.122208] pci 0000:fd:05.4: [8086:2b13] type 00 class 0x060000
[    7.129387] pci 0000:fd:05.6: [8086:2b53] type 00 class 0x060000
[    7.136564] pci 0000:fd:06.0: [8086:2b18] type 00 class 0x060000
[    7.143750] pci 0000:fd:07.0: [8086:2b1c] type 00 class 0x060000
[    7.150926] pci 0000:fd:07.2: [8086:2b1e] type 00 class 0x060000
[    7.158109] pci 0000:fd:07.4: [8086:2b1b] type 00 class 0x060000
[    7.165286] pci 0000:fd:07.6: [8086:2b5b] type 00 class 0x060000
[    7.172456] pci 0000:fd:08.0: [8086:2b20] type 00 class 0x060000
[    7.179624] pci 0000:fd:09.0: [8086:2b24] type 00 class 0x060000
[    7.186802] pci 0000:fd:0a.0: [8086:2b28] type 00 class 0x060000
[    7.193984] pci 0000:fd:0b.0: [8086:2b2c] type 00 class 0x060000
[    7.201167] pci 0000:fd:0c.0: [8086:2b30] type 00 class 0x060000
[    7.208355] pci 0000:fd:0d.0: [8086:2b34] type 00 class 0x060000
[    7.215540] pci 0000:fd:0e.0: [8086:2b38] type 00 class 0x060000
[    7.222726] pci 0000:fd:0f.0: [8086:2b3c] type 00 class 0x060000
[    7.229923] pci 0000:fd:10.0: [8086:2b40] type 00 class 0x060000
[    7.237111] pci 0000:fd:10.2: [8086:2b42] type 00 class 0x060000
[    7.244292] pci 0000:fd:10.4: [8086:2b32] type 00 class 0x060000
[    7.251480] pci 0000:fd:10.6: [8086:2b3a] type 00 class 0x060000
[    7.258665] pci 0000:fd:11.0: [8086:2b44] type 00 class 0x060000
[    7.265839] pci 0000:fd:11.2: [8086:2b46] type 00 class 0x060000
[    7.273012] pci 0000:fd:11.4: [8086:2b36] type 00 class 0x060000
[    7.280188] pci 0000:fd:11.6: [8086:2b3e] type 00 class 0x060000
[    7.287367] pci 0000:fd:12.0: [8086:2b48] type 00 class 0x060000
[    7.294540] pci 0000:fd:13.0: [8086:2b4c] type 00 class 0x060000
[    7.301729] pci 0000:fd:14.0: [8086:2b50] type 00 class 0x060000
[    7.308916] pci 0000:fd:14.2: [8086:2b52] type 00 class 0x060000
[    7.316103] pci 0000:fd:15.0: [8086:2b54] type 00 class 0x060000
[    7.323290] pci 0000:fd:15.2: [8086:2b56] type 00 class 0x060000
[    7.330474] pci 0000:fd:16.0: [8086:2b58] type 00 class 0x060000
[    7.337660] pci 0000:fd:16.2: [8086:2b5a] type 00 class 0x060000
[    7.344847] pci 0000:fd:17.0: [8086:2b5c] type 00 class 0x060000
[    7.352025] pci 0000:fd:17.2: [8086:2b5e] type 00 class 0x060000
[    7.359213] pci 0000:fd:18.0: [8086:2b60] type 00 class 0x060000
[    7.366402] pci 0000:fd:18.2: [8086:2b62] type 00 class 0x060000
[    7.373577] pci 0000:fd:19.0: [8086:2b64] type 00 class 0x060000
[    7.380759] pci 0000:fd:19.2: [8086:2b66] type 00 class 0x060000
[    7.387928] pci 0000:fd:1a.0: [8086:2b68] type 00 class 0x060000
[    7.395116] pci 0000:fd:1b.0: [8086:2b6c] type 00 class 0x060000
[    7.402360] ACPI: PCI Root Bridge [PRB1] (domain 0000 [bus fe])
[    7.409385] acpi PNP0A03:02: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[    7.419244] acpi PNP0A03:02: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    7.427100] PCI host bridge to bus 0000:fe
[    7.432071] pci_bus 0000:fe: root bus resource [bus fe]
[    7.438315] pci 0000:fe:00.0: [8086:2b00] type 00 class 0x060000
[    7.445486] pci 0000:fe:00.2: [8086:2b02] type 00 class 0x060000
[    7.452669] pci 0000:fe:00.4: [8086:2b22] type 00 class 0x060000
[    7.459846] pci 0000:fe:00.6: [8086:2b2a] type 00 class 0x060000
[    7.467026] pci 0000:fe:01.0: [8086:2b04] type 00 class 0x060000
[    7.474198] pci 0000:fe:02.0: [8086:2b08] type 00 class 0x060000
[    7.481386] pci 0000:fe:03.0: [8086:2b0c] type 00 class 0x060000
[    7.488573] pci 0000:fe:04.0: [8086:2b10] type 00 class 0x060000
[    7.495760] pci 0000:fe:05.0: [8086:2b14] type 00 class 0x060000
[    7.502937] pci 0000:fe:05.2: [8086:2b16] type 00 class 0x060000
[    7.510122] pci 0000:fe:05.4: [8086:2b13] type 00 class 0x060000
[    7.517306] pci 0000:fe:05.6: [8086:2b53] type 00 class 0x060000
[    7.524488] pci 0000:fe:06.0: [8086:2b18] type 00 class 0x060000
[    7.531670] pci 0000:fe:07.0: [8086:2b1c] type 00 class 0x060000
[    7.538853] pci 0000:fe:07.2: [8086:2b1e] type 00 class 0x060000
[    7.546028] pci 0000:fe:07.4: [8086:2b1b] type 00 class 0x060000
[    7.553212] pci 0000:fe:07.6: [8086:2b5b] type 00 class 0x060000
[    7.560389] pci 0000:fe:08.0: [8086:2b20] type 00 class 0x060000
[    7.567570] pci 0000:fe:09.0: [8086:2b24] type 00 class 0x060000
[    7.574760] pci 0000:fe:0a.0: [8086:2b28] type 00 class 0x060000
[    7.581947] pci 0000:fe:0b.0: [8086:2b2c] type 00 class 0x060000
[    7.589136] pci 0000:fe:0c.0: [8086:2b30] type 00 class 0x060000
[    7.596326] pci 0000:fe:0d.0: [8086:2b34] type 00 class 0x060000
[    7.603503] pci 0000:fe:0e.0: [8086:2b38] type 00 class 0x060000
[    7.610695] pci 0000:fe:0f.0: [8086:2b3c] type 00 class 0x060000
[    7.617881] pci 0000:fe:10.0: [8086:2b40] type 00 class 0x060000
[    7.625068] pci 0000:fe:10.2: [8086:2b42] type 00 class 0x060000
[    7.632242] pci 0000:fe:10.4: [8086:2b32] type 00 class 0x060000
[    7.639420] pci 0000:fe:10.6: [8086:2b3a] type 00 class 0x060000
[    7.646597] pci 0000:fe:11.0: [8086:2b44] type 00 class 0x060000
[    7.653769] pci 0000:fe:11.2: [8086:2b46] type 00 class 0x060000
[    7.660947] pci 0000:fe:11.4: [8086:2b36] type 00 class 0x060000
[    7.668132] pci 0000:fe:11.6: [8086:2b3e] type 00 class 0x060000
[    7.675309] pci 0000:fe:12.0: [8086:2b48] type 00 class 0x060000
[    7.682496] pci 0000:fe:13.0: [8086:2b4c] type 00 class 0x060000
[    7.689686] pci 0000:fe:14.0: [8086:2b50] type 00 class 0x060000
[    7.696869] pci 0000:fe:14.2: [8086:2b52] type 00 class 0x060000
[    7.704061] pci 0000:fe:15.0: [8086:2b54] type 00 class 0x060000
[    7.719341] pci 0000:fe:15.2: [8086:2b56] type 00 class 0x060000
[    7.726523] pci 0000:fe:16.0: [8086:2b58] type 00 class 0x060000
[    7.733702] pci 0000:fe:16.2: [8086:2b5a] type 00 class 0x060000
[    7.740879] pci 0000:fe:17.0: [8086:2b5c] type 00 class 0x060000
[    7.748057] pci 0000:fe:17.2: [8086:2b5e] type 00 class 0x060000
[    7.755237] pci 0000:fe:18.0: [8086:2b60] type 00 class 0x060000
[    7.762416] pci 0000:fe:18.2: [8086:2b62] type 00 class 0x060000
[    7.769603] pci 0000:fe:19.0: [8086:2b64] type 00 class 0x060000
[    7.776787] pci 0000:fe:19.2: [8086:2b66] type 00 class 0x060000
[    7.783975] pci 0000:fe:1a.0: [8086:2b68] type 00 class 0x060000
[    7.791165] pci 0000:fe:1b.0: [8086:2b6c] type 00 class 0x060000
[    7.798415] ACPI: PCI Root Bridge [PRB0] (domain 0000 [bus ff])
[    7.805432] acpi PNP0A03:03: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[    7.815294] acpi PNP0A03:03: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    7.823147] PCI host bridge to bus 0000:ff
[    7.828112] pci_bus 0000:ff: root bus resource [bus ff]
[    7.834347] pci 0000:ff:00.0: [8086:2b00] type 00 class 0x060000
[    7.841524] pci 0000:ff:00.2: [8086:2b02] type 00 class 0x060000
[    7.848707] pci 0000:ff:00.4: [8086:2b22] type 00 class 0x060000
[    7.855891] pci 0000:ff:00.6: [8086:2b2a] type 00 class 0x060000
[    7.863081] pci 0000:ff:01.0: [8086:2b04] type 00 class 0x060000
[    7.870264] pci 0000:ff:02.0: [8086:2b08] type 00 class 0x060000
[    7.877446] pci 0000:ff:03.0: [8086:2b0c] type 00 class 0x060000
[    7.884626] pci 0000:ff:04.0: [8086:2b10] type 00 class 0x060000
[    7.891809] pci 0000:ff:05.0: [8086:2b14] type 00 class 0x060000
[    7.898987] pci 0000:ff:05.2: [8086:2b16] type 00 class 0x060000
[    7.906166] pci 0000:ff:05.4: [8086:2b13] type 00 class 0x060000
[    7.913347] pci 0000:ff:05.6: [8086:2b53] type 00 class 0x060000
[    7.920523] pci 0000:ff:06.0: [8086:2b18] type 00 class 0x060000
[    7.927699] pci 0000:ff:07.0: [8086:2b1c] type 00 class 0x060000
[    7.934877] pci 0000:ff:07.2: [8086:2b1e] type 00 class 0x060000
[    7.942046] pci 0000:ff:07.4: [8086:2b1b] type 00 class 0x060000
[    7.949226] pci 0000:ff:07.6: [8086:2b5b] type 00 class 0x060000
[    7.956401] pci 0000:ff:08.0: [8086:2b20] type 00 class 0x060000
[    7.963590] pci 0000:ff:09.0: [8086:2b24] type 00 class 0x060000
[    7.970760] pci 0000:ff:0a.0: [8086:2b28] type 00 class 0x060000
[    7.977947] pci 0000:ff:0b.0: [8086:2b2c] type 00 class 0x060000
[    7.985122] pci 0000:ff:0c.0: [8086:2b30] type 00 class 0x060000
[    7.992301] pci 0000:ff:0d.0: [8086:2b34] type 00 class 0x060000
[    7.999465] pci 0000:ff:0e.0: [8086:2b38] type 00 class 0x060000
[    8.006646] pci 0000:ff:0f.0: [8086:2b3c] type 00 class 0x060000
[    8.013818] pci 0000:ff:10.0: [8086:2b40] type 00 class 0x060000
[    8.020998] pci 0000:ff:10.2: [8086:2b42] type 00 class 0x060000
[    8.028169] pci 0000:ff:10.4: [8086:2b32] type 00 class 0x060000
[    8.035350] pci 0000:ff:10.6: [8086:2b3a] type 00 class 0x060000
[    8.042523] pci 0000:ff:11.0: [8086:2b44] type 00 class 0x060000
[    8.049705] pci 0000:ff:11.2: [8086:2b46] type 00 class 0x060000
[    8.056873] pci 0000:ff:11.4: [8086:2b36] type 00 class 0x060000
[    8.064056] pci 0000:ff:11.6: [8086:2b3e] type 00 class 0x060000
[    8.071229] pci 0000:ff:12.0: [8086:2b48] type 00 class 0x060000
[    8.078418] pci 0000:ff:13.0: [8086:2b4c] type 00 class 0x060000
[    8.085594] pci 0000:ff:14.0: [8086:2b50] type 00 class 0x060000
[    8.092778] pci 0000:ff:14.2: [8086:2b52] type 00 class 0x060000
[    8.099956] pci 0000:ff:15.0: [8086:2b54] type 00 class 0x060000
[    8.107136] pci 0000:ff:15.2: [8086:2b56] type 00 class 0x060000
[    8.114315] pci 0000:ff:16.0: [8086:2b58] type 00 class 0x060000
[    8.121500] pci 0000:ff:16.2: [8086:2b5a] type 00 class 0x060000
[    8.128685] pci 0000:ff:17.0: [8086:2b5c] type 00 class 0x060000
[    8.135870] pci 0000:ff:17.2: [8086:2b5e] type 00 class 0x060000
[    8.143051] pci 0000:ff:18.0: [8086:2b60] type 00 class 0x060000
[    8.150241] pci 0000:ff:18.2: [8086:2b62] type 00 class 0x060000
[    8.157429] pci 0000:ff:19.0: [8086:2b64] type 00 class 0x060000
[    8.164614] pci 0000:ff:19.2: [8086:2b66] type 00 class 0x060000
[    8.171800] pci 0000:ff:1a.0: [8086:2b68] type 00 class 0x060000
[    8.178991] pci 0000:ff:1b.0: [8086:2b6c] type 00 class 0x060000
[    8.204364] ACPI: Enabled 34 GPEs in block 00 to 3F
[    8.210600] vgaarb: device added: PCI:0000:11:00.0,decodes=io+mem,owns=io+mem,locks=none
[    8.220459] vgaarb: loaded
[    8.223869] vgaarb: bridge control possible 0000:11:00.0
[    8.230392] SCSI subsystem initialized
[    8.235272] libata version 3.00 loaded.
[    8.240097] ACPI: bus type USB registered
[    8.245035] usbcore: registered new interface driver usbfs
[    8.251590] usbcore: registered new interface driver hub
[    8.258006] usbcore: registered new device driver usb
[    8.264104] pps_core: LinuxPPS API ver. 1 registered
[    8.270057] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
[    8.281023] PTP clock support registered
[    8.286287] EDAC MC: Ver: 3.0.0
[    8.290678] PCI: Using ACPI for IRQ routing
[    8.300238] PCI: pci_cache_line_size set to 64 bytes
[    8.306576] e820: reserve RAM buffer [mem 0x0009b400-0x0009ffff]
[    8.313700] e820: reserve RAM buffer [mem 0x7b43e000-0x7bffffff]
[    8.321636] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0
[    8.328151] hpet0: 4 comparators, 64-bit 14.318180 MHz counter
[    8.337404] Switched to clocksource hpet
[    8.342424] Could not create debugfs 'set_ftrace_filter' entry
[    8.349357] Could not create debugfs 'set_ftrace_notrace' entry
[    8.372587] pnp: PnP ACPI init
[    8.376421] ACPI: bus type PNP registered
[    8.381382] pnp 00:00: Plug and Play ACPI device, IDs PNP0003 (active)
[    8.389446] pnp 00:01: [dma 4]
[    8.393305] pnp 00:01: Plug and Play ACPI device, IDs PNP0200 (active)
[    8.401027] IOAPIC[0]: Set routing entry (8-8 -> 0x38 -> IRQ 8 Mode:0 Active:0 Dest:0)
[    8.410679] pnp 00:02: Plug and Play ACPI device, IDs PNP0b00 (active)
[    8.418405] IOAPIC[0]: Set routing entry (8-13 -> 0x3d -> IRQ 13 Mode:0 Active:0 Dest:0)
[    8.428223] pnp 00:03: Plug and Play ACPI device, IDs PNP0c04 (active)
[    8.435985] pnp 00:04: Plug and Play ACPI device, IDs PNP0800 (active)
[    8.443784] pnp 00:05: Plug and Play ACPI device, IDs PNP0103 (active)
[    8.451691] system 00:06: [io  0x0500-0x057f] could not be reserved
[    8.459108] system 00:06: [io  0x0400-0x047f] could not be reserved
[    8.466520] system 00:06: [io  0x0540-0x057f] has been reserved
[    8.473543] system 00:06: [io  0x0600-0x061f] has been reserved
[    8.480565] system 00:06: [io  0x0880-0x0883] has been reserved
[    8.487590] system 00:06: [io  0x0ca4-0x0ca5] has been reserved
[    8.494618] system 00:06: [io  0x0800-0x081f] has been reserved
[    8.501648] system 00:06: [mem 0xfed1c000-0xfed3ffff] could not be reserved
[    8.509846] system 00:06: [mem 0xfed45000-0xfed8bfff] has been reserved
[    8.517649] system 00:06: [mem 0xff000000-0xffffffff] has been reserved
[    8.525453] system 00:06: [mem 0xfee00000-0xfeefffff] has been reserved
[    8.533263] system 00:06: [mem 0xfed12000-0xfed1200f] has been reserved
[    8.541058] system 00:06: [mem 0xfed12010-0xfed1201f] has been reserved
[    8.548866] system 00:06: [mem 0xfed1b000-0xfed1bfff] has been reserved
[    8.556665] system 00:06: Plug and Play ACPI device, IDs PNP0c02 (active)
[    8.564806] IOAPIC[0]: Set routing entry (8-4 -> 0x34 -> IRQ 4 Mode:0 Active:0 Dest:0)
[    8.574472] pnp 00:07: Plug and Play ACPI device, IDs PNP0501 (active)
[    8.582310] IOAPIC[0]: Set routing entry (8-3 -> 0x33 -> IRQ 3 Mode:0 Active:0 Dest:0)
[    8.592008] pnp 00:08: Plug and Play ACPI device, IDs PNP0501 (active)
[    8.599794] pnp 00:09: Plug and Play ACPI device, IDs PNP0c31 (active)
[    8.607591] pnp 00:0a: Plug and Play ACPI device, IDs IPI0001 (active)
[    8.633939] pnp 00:0b: Plug and Play ACPI device, IDs PNP0c80 (active)
[    8.659998] pnp 00:0c: Plug and Play ACPI device, IDs PNP0c80 (active)
[    8.685994] pnp 00:0d: Plug and Play ACPI device, IDs PNP0c80 (active)
[    8.712012] pnp 00:0e: Plug and Play ACPI device, IDs PNP0c80 (active)
[    8.719813] pnp: PnP ACPI: found 15 devices
[    8.724895] ACPI: bus type PNP unregistered
[    8.737662] pci 0000:07:00.0: can't claim BAR 6 [mem 0xfffc0000-0xffffffff pref]: no compatible bridge window
[    8.749495] pci 0000:11:00.0: can't claim BAR 6 [mem 0xffff0000-0xffffffff pref]: no compatible bridge window
[    8.761418] pci 0000:00:01.0: PCI bridge to [bus 01-03]
[    8.767669] pci 0000:00:01.0:   bridge window [io  0x5000-0x5fff]
[    8.774893] pci 0000:00:01.0:   bridge window [mem 0x95b00000-0x95bfffff]
[    8.782890] pci 0000:00:02.0: PCI bridge to [bus 04-06]
[    8.789141] pci 0000:00:02.0:   bridge window [io  0x4000-0x4fff]
[    8.796353] pci 0000:00:02.0:   bridge window [mem 0x95a00000-0x95afffff]
[    8.804362] pci 0000:07:00.0: BAR 6: assigned [mem 0x95d00000-0x95d3ffff pref]
[    8.813167] pci 0000:00:03.0: PCI bridge to [bus 07]
[    8.819118] pci 0000:00:03.0:   bridge window [io  0x3000-0x3fff]
[    8.826339] pci 0000:00:03.0:   bridge window [mem 0x95900000-0x959fffff]
[    8.834341] pci 0000:00:03.0:   bridge window [mem 0x95d00000-0x95dfffff 64bit pref]
[    8.843749] pci 0000:00:05.0: PCI bridge to [bus 08-0a]
[    8.850000] pci 0000:00:05.0:   bridge window [io  0x2000-0x2fff]
[    8.857219] pci 0000:00:05.0:   bridge window [mem 0x94900000-0x958fffff]
[    8.865225] pci 0000:00:05.0:   bridge window [mem 0x91900000-0x928fffff 64bit pref]
[    8.874617] pci 0000:00:07.0: PCI bridge to [bus 0b-0d]
[    8.880852] pci 0000:00:07.0:   bridge window [io  0x1000-0x1fff]
[    8.888074] pci 0000:00:07.0:   bridge window [mem 0x93900000-0x948fffff]
[    8.896062] pci 0000:00:07.0:   bridge window [mem 0x92900000-0x938fffff 64bit pref]
[    8.905466] pci 0000:00:09.0: PCI bridge to [bus 0e]
[    8.911432] pci 0000:00:0a.0: PCI bridge to [bus 0f]
[    8.917397] pci 0000:00:1c.0: PCI bridge to [bus 10]
[    8.923351] pci 0000:00:1c.0:   bridge window [io  0x7000-0x7fff]
[    8.930575] pci 0000:00:1c.0:   bridge window [mem 0x95e00000-0x95ffffff]
[    8.938571] pci 0000:00:1c.0:   bridge window [mem 0x96000000-0x961fffff 64bit pref]
[    8.947980] pci 0000:11:00.0: BAR 6: assigned [mem 0x91810000-0x9181ffff pref]
[    8.956782] pci 0000:00:1c.4: PCI bridge to [bus 11]
[    8.962732] pci 0000:00:1c.4:   bridge window [io  0x8000-0x8fff]
[    8.969953] pci 0000:00:1c.4:   bridge window [mem 0x91000000-0x918fffff]
[    8.977949] pci 0000:00:1c.4:   bridge window [mem 0x90000000-0x90ffffff 64bit pref]
[    8.987351] pci 0000:00:1e.0: PCI bridge to [bus 12]
[    8.993301] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    8.999941] pci_bus 0000:00: resource 5 [io  0x1000-0x9fff]
[    9.006564] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    9.013978] pci_bus 0000:00: resource 7 [mem 0xfed40000-0xfedfffff]
[    9.021397] pci_bus 0000:00: resource 8 [mem 0x90000000-0xafffffff]
[    9.037139] pci_bus 0000:00: resource 9 [mem 0xfc000000000-0xfc07fffffff]
[    9.045130] pci_bus 0000:01: resource 0 [io  0x5000-0x5fff]
[    9.051755] pci_bus 0000:01: resource 1 [mem 0x95b00000-0x95bfffff]
[    9.059174] pci_bus 0000:04: resource 0 [io  0x4000-0x4fff]
[    9.065798] pci_bus 0000:04: resource 1 [mem 0x95a00000-0x95afffff]
[    9.073206] pci_bus 0000:07: resource 0 [io  0x3000-0x3fff]
[    9.079842] pci_bus 0000:07: resource 1 [mem 0x95900000-0x959fffff]
[    9.087254] pci_bus 0000:07: resource 2 [mem 0x95d00000-0x95dfffff 64bit pref]
[    9.096059] pci_bus 0000:08: resource 0 [io  0x2000-0x2fff]
[    9.102697] pci_bus 0000:08: resource 1 [mem 0x94900000-0x958fffff]
[    9.110116] pci_bus 0000:08: resource 2 [mem 0x91900000-0x928fffff 64bit pref]
[    9.118936] pci_bus 0000:0b: resource 0 [io  0x1000-0x1fff]
[    9.125563] pci_bus 0000:0b: resource 1 [mem 0x93900000-0x948fffff]
[    9.132970] pci_bus 0000:0b: resource 2 [mem 0x92900000-0x938fffff 64bit pref]
[    9.141775] pci_bus 0000:10: resource 0 [io  0x7000-0x7fff]
[    9.148403] pci_bus 0000:10: resource 1 [mem 0x95e00000-0x95ffffff]
[    9.155813] pci_bus 0000:10: resource 2 [mem 0x96000000-0x961fffff 64bit pref]
[    9.164631] pci_bus 0000:11: resource 0 [io  0x8000-0x8fff]
[    9.171271] pci_bus 0000:11: resource 1 [mem 0x91000000-0x918fffff]
[    9.178685] pci_bus 0000:11: resource 2 [mem 0x90000000-0x90ffffff 64bit pref]
[    9.187505] pci_bus 0000:12: resource 4 [io  0x0000-0x0cf7]
[    9.194134] pci_bus 0000:12: resource 5 [io  0x1000-0x9fff]
[    9.200765] pci_bus 0000:12: resource 6 [mem 0x000a0000-0x000bffff]
[    9.208166] pci_bus 0000:12: resource 7 [mem 0xfed40000-0xfedfffff]
[    9.215581] pci_bus 0000:12: resource 8 [mem 0x90000000-0xafffffff]
[    9.222984] pci_bus 0000:12: resource 9 [mem 0xfc000000000-0xfc07fffffff]
[    9.231020] pci 0000:80:00.0: PCI bridge to [bus 81]
[    9.236976] pci 0000:80:01.0: PCI bridge to [bus 82]
[    9.242942] pci 0000:80:03.0: PCI bridge to [bus 83]
[    9.248903] pci 0000:80:07.0: PCI bridge to [bus 84-86]
[    9.255155] pci 0000:80:07.0:   bridge window [io  0xb000-0xbfff]
[    9.262378] pci 0000:80:07.0:   bridge window [mem 0xb3000000-0xb3ffffff]
[    9.270385] pci 0000:80:07.0:   bridge window [mem 0xb0000000-0xb0ffffff 64bit pref]
[    9.279783] pci 0000:80:09.0: PCI bridge to [bus 87-89]
[    9.286032] pci 0000:80:09.0:   bridge window [io  0xa000-0xafff]
[    9.293244] pci 0000:80:09.0:   bridge window [mem 0xb2000000-0xb2ffffff]
[    9.301245] pci 0000:80:09.0:   bridge window [mem 0xb1000000-0xb1ffffff 64bit pref]
[    9.310638] pci_bus 0000:80: resource 4 [io  0xa000-0xffff]
[    9.317280] pci_bus 0000:80: resource 5 [mem 0xb0000000-0xfbffffff]
[    9.324698] pci_bus 0000:80: resource 6 [mem 0xfc080000000-0xfc0ffffffff]
[    9.332698] pci_bus 0000:84: resource 0 [io  0xb000-0xbfff]
[    9.339339] pci_bus 0000:84: resource 1 [mem 0xb3000000-0xb3ffffff]
[    9.346747] pci_bus 0000:84: resource 2 [mem 0xb0000000-0xb0ffffff 64bit pref]
[    9.355565] pci_bus 0000:87: resource 0 [io  0xa000-0xafff]
[    9.362197] pci_bus 0000:87: resource 1 [mem 0xb2000000-0xb2ffffff]
[    9.369613] pci_bus 0000:87: resource 2 [mem 0xb1000000-0xb1ffffff 64bit pref]
[    9.378529] NET: Registered protocol family 2
[    9.384684] TCP established hash table entries: 524288 (order: 10, 4194304 bytes)
[    9.394932] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[    9.403094] TCP: Hash tables configured (established 524288 bind 65536)
[    9.411004] TCP: reno registered
[    9.415227] UDP hash table entries: 65536 (order: 9, 2097152 bytes)
[    9.423300] UDP-Lite hash table entries: 65536 (order: 9, 2097152 bytes)
[    9.432118] NET: Registered protocol family 1
[    9.437787] RPC: Registered named UNIX socket transport module.
[    9.444820] RPC: Registered udp transport module.
[    9.450477] RPC: Registered tcp transport module.
[    9.456143] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    9.518290] IOAPIC[0]: Set routing entry (8-16 -> 0x41 -> IRQ 16 Mode:1 Active:1 Dest:0)
[    9.528408] IOAPIC[0]: Set routing entry (8-21 -> 0x51 -> IRQ 21 Mode:1 Active:1 Dest:0)
[    9.538514] IOAPIC[0]: Set routing entry (8-19 -> 0x61 -> IRQ 19 Mode:1 Active:1 Dest:0)
[    9.548638] IOAPIC[0]: Set routing entry (8-18 -> 0x71 -> IRQ 18 Mode:1 Active:1 Dest:0)
[    9.558766] IOAPIC[0]: Set routing entry (8-23 -> 0x81 -> IRQ 23 Mode:1 Active:1 Dest:0)
[    9.569702] pci 0000:11:00.0: Boot video device
[    9.575494] PCI: CLS 64 bytes, default 64
[    9.580424] Trying to unpack rootfs image as initramfs...
[   14.246348] Freeing initrd memory: 212912K (ffff88006e448000 - ffff88007b434000)
[   14.255384] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[   14.263002] software IO TLB [mem 0x6a448000-0x6e448000] (64MB) mapped at [ffff88006a448000-ffff88006e447fff]
[   14.283170] Scanning for low memory corruption every 60 seconds
[   14.292421] sha1_ssse3: Using SSSE3 optimized SHA-1 implementation
[   14.299807] PCLMULQDQ-NI instructions are not detected.
[   14.306057] AVX or AES-NI instructions are not detected.
[   14.312397] AVX instructions are not detected.
[   14.317763] AVX instructions are not detected.
[   14.323126] AVX instructions are not detected.
[   14.328480] AVX instructions are not detected.
[   14.336197] futex hash table entries: 32768 (order: 9, 2097152 bytes)
[   14.372452] bounce pool size: 64 pages
[   14.377048] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[   14.387627] VFS: Disk quotas dquot_6.5.2
[   14.392523] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[   14.401907] NFS: Registering the id_resolver key type
[   14.407983] Key type id_resolver registered
[   14.413065] Key type id_legacy registered
[   14.417957] nfs4filelayout_init: NFSv4 File Layout Driver Registering...
[   14.425858] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[   14.434223] ROMFS MTD (C) 2007 Red Hat, Inc.
[   14.439500] fuse init (API version 7.22)
[   14.444532] SGI XFS with ACLs, security attributes, realtime, large block/inode numbers, no debug enabled
[   14.457230] msgmni has been set to 32768
[   14.466203] NET: Registered protocol family 38
[   14.471592] Key type asymmetric registered
[   14.476684] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 250)
[   14.485945] io scheduler noop registered
[   14.490738] io scheduler deadline registered
[   14.495915] io scheduler cfq registered (default)
[   14.502414] IOAPIC[1]: Set routing entry (9-4 -> 0x91 -> IRQ 28 Mode:1 Active:1 Dest:0)
[   14.512166] pcieport 0000:00:01.0: irq 88 for MSI/MSI-X
[   14.518647] IOAPIC[1]: Set routing entry (9-5 -> 0xb1 -> IRQ 29 Mode:1 Active:1 Dest:0)
[   14.528348] pcieport 0000:00:02.0: irq 89 for MSI/MSI-X
[   14.534829] IOAPIC[1]: Set routing entry (9-0 -> 0xd1 -> IRQ 24 Mode:1 Active:1 Dest:0)
[   14.544561] pcieport 0000:00:03.0: irq 90 for MSI/MSI-X
[   14.551044] IOAPIC[1]: Set routing entry (9-2 -> 0x22 -> IRQ 26 Mode:1 Active:1 Dest:0)
[   14.560760] pcieport 0000:00:05.0: irq 91 for MSI/MSI-X
[   14.567244] IOAPIC[1]: Set routing entry (9-6 -> 0x52 -> IRQ 30 Mode:1 Active:1 Dest:0)
[   14.576942] pcieport 0000:00:07.0: irq 92 for MSI/MSI-X
[   14.583454] IOAPIC[1]: Set routing entry (9-8 -> 0x72 -> IRQ 32 Mode:1 Active:1 Dest:0)
[   14.593193] pcieport 0000:00:09.0: irq 93 for MSI/MSI-X
[   14.599670] IOAPIC[1]: Set routing entry (9-9 -> 0x92 -> IRQ 33 Mode:1 Active:1 Dest:0)
[   14.609382] pcieport 0000:00:0a.0: irq 94 for MSI/MSI-X
[   14.615883] pcieport 0000:00:1c.0: irq 95 for MSI/MSI-X
[   14.622421] pcieport 0000:00:1c.4: irq 96 for MSI/MSI-X
[   14.628919] IOAPIC[2]: Set routing entry (10-23 -> 0xd2 -> IRQ 71 Mode:1 Active:1 Dest:0)
[   14.638835] pcieport 0000:80:00.0: irq 97 for MSI/MSI-X
[   14.645282] IOAPIC[2]: Set routing entry (10-4 -> 0x23 -> IRQ 52 Mode:1 Active:1 Dest:0)
[   14.655099] pcieport 0000:80:01.0: irq 98 for MSI/MSI-X
[   14.661542] IOAPIC[2]: Set routing entry (10-0 -> 0x53 -> IRQ 48 Mode:1 Active:1 Dest:0)
[   14.671349] pcieport 0000:80:03.0: irq 99 for MSI/MSI-X
[   14.677796] IOAPIC[2]: Set routing entry (10-6 -> 0x73 -> IRQ 54 Mode:1 Active:1 Dest:0)
[   14.687607] pcieport 0000:80:07.0: irq 100 for MSI/MSI-X
[   14.694146] IOAPIC[2]: Set routing entry (10-8 -> 0x93 -> IRQ 56 Mode:1 Active:1 Dest:0)
[   14.703960] pcieport 0000:80:09.0: irq 101 for MSI/MSI-X
[   14.710436] pcieport 0000:00:01.0: Signaling PME through PCIe PME interrupt
[   14.718626] pci 0000:01:00.0: Signaling PME through PCIe PME interrupt
[   14.726328] pci 0000:01:00.1: Signaling PME through PCIe PME interrupt
[   14.734031] pcie_pme 0000:00:01.0:pcie01: service driver pcie_pme loaded
[   14.741959] pcieport 0000:00:02.0: Signaling PME through PCIe PME interrupt
[   14.750149] pci 0000:04:00.0: Signaling PME through PCIe PME interrupt
[   14.757851] pci 0000:04:00.1: Signaling PME through PCIe PME interrupt
[   14.765561] pcie_pme 0000:00:02.0:pcie01: service driver pcie_pme loaded
[   14.773487] pcieport 0000:00:03.0: Signaling PME through PCIe PME interrupt
[   14.781684] pci 0000:07:00.0: Signaling PME through PCIe PME interrupt
[   14.789394] pcie_pme 0000:00:03.0:pcie01: service driver pcie_pme loaded
[   14.797306] pcieport 0000:00:05.0: Signaling PME through PCIe PME interrupt
[   14.805507] pcie_pme 0000:00:05.0:pcie01: service driver pcie_pme loaded
[   14.813431] pcieport 0000:00:07.0: Signaling PME through PCIe PME interrupt
[   14.821618] pcie_pme 0000:00:07.0:pcie01: service driver pcie_pme loaded
[   14.829530] pcieport 0000:00:09.0: Signaling PME through PCIe PME interrupt
[   14.837722] pcie_pme 0000:00:09.0:pcie01: service driver pcie_pme loaded
[   14.845637] pcieport 0000:00:0a.0: Signaling PME through PCIe PME interrupt
[   14.853834] pcie_pme 0000:00:0a.0:pcie01: service driver pcie_pme loaded
[   14.861755] pcieport 0000:00:1c.0: Signaling PME through PCIe PME interrupt
[   14.869954] pcie_pme 0000:00:1c.0:pcie01: service driver pcie_pme loaded
[   14.877877] pcieport 0000:00:1c.4: Signaling PME through PCIe PME interrupt
[   14.886073] pci 0000:11:00.0: Signaling PME through PCIe PME interrupt
[   14.893786] pcie_pme 0000:00:1c.4:pcie01: service driver pcie_pme loaded
[   14.901717] pcieport 0000:80:00.0: Signaling PME through PCIe PME interrupt
[   14.909917] pcie_pme 0000:80:00.0:pcie01: service driver pcie_pme loaded
[   14.926162] pcieport 0000:80:01.0: Signaling PME through PCIe PME interrupt
[   14.934361] pcie_pme 0000:80:01.0:pcie01: service driver pcie_pme loaded
[   14.942278] pcieport 0000:80:03.0: Signaling PME through PCIe PME interrupt
[   14.950465] pcie_pme 0000:80:03.0:pcie01: service driver pcie_pme loaded
[   14.958381] pcieport 0000:80:07.0: Signaling PME through PCIe PME interrupt
[   14.966572] pcie_pme 0000:80:07.0:pcie01: service driver pcie_pme loaded
[   14.974495] pcieport 0000:80:09.0: Signaling PME through PCIe PME interrupt
[   14.982682] pcie_pme 0000:80:09.0:pcie01: service driver pcie_pme loaded
[   14.990609] ioapic: probe of 0000:00:13.0 failed with error -22
[   14.997644] ioapic: probe of 0000:00:15.0 failed with error -22
[   15.004679] ioapic: probe of 0000:80:13.0 failed with error -22
[   15.011712] ioapic: probe of 0000:80:15.0 failed with error -22
[   15.018764] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[   15.025447] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[   15.033256] intel_idle: MWAIT substates: 0x1120
[   15.038717] intel_idle: v0.4 model 0x2F
[   15.043408] intel_idle: lapic_timer_reliable_states 0xffffffff
[   15.054759] input: Sleep Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0E:00/input/input0
[   15.064826] ACPI: Sleep Button [SLPB]
[   15.069407] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
[   15.078424] ACPI: Power Button [PWRF]
[   15.083062] ERST: Error Record Serialization Table (ERST) support is initialized.
[   15.092176] pstore: Registered erst as persistent store backend
[   15.100564] ghes_edac: This EDAC driver relies on BIOS to enumerate memory and get error reports.
[   15.111212] ghes_edac: Unfortunately, not all BIOSes reflect the memory layout correctly.
[   15.121081] ghes_edac: So, the end result of using this driver varies from vendor to vendor.
[   15.131255] ghes_edac: If you find incorrect reports, please contact your hardware vendor
[   15.141143] ghes_edac: to correct its BIOS.
[   15.146225] ghes_edac: This system has 64 DIMM sockets.
[   15.155496] EDAC MC0: Giving out device to module ghes_edac.c controller ghes_edac: DEV ghes (INTERRUPT)
[   15.168254] EDAC MC1: Giving out device to module ghes_edac.c controller ghes_edac: DEV ghes (INTERRUPT)
[   15.181572] GHES: APEI firmware first mode is enabled by APEI bit and WHEA _OSC.
[   15.190600] EINJ: Error INJection is initialized.
[   15.196394] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[   15.224345] 00:07: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
[   15.253794] 00:08: ttyS1 at I/O 0x2f8 (irq = 3, base_baud = 115200) is a 16550A
[   15.263443] Non-volatile memory driver v1.3
[   15.272451] brd: module loaded
[   15.277604] tsc: Refined TSC clocksource calibration: 2393.999 MHz
[   15.277916] loop: module loaded
[   15.278214] lkdtm: No crash points registered, enable through debugfs
[   15.278300] ACPI Warning: SystemIO range 0x0000000000000428-0x000000000000042f conflicts with OpRegion 0x0000000000000428-0x000000000000042f (\GPE0) (20140214/utaddress-258)
[   15.278310] ACPI: If an ACPI driver is available for this device, you should use it instead of the native driver
[   15.278316] ACPI Warning: SystemIO range 0x0000000000000500-0x000000000000052f conflicts with OpRegion 0x000000000000052c-0x000000000000052c (\GPIV) (20140214/utaddress-258)
[   15.278319] ACPI Warning: SystemIO range 0x0000000000000500-0x000000000000052f conflicts with OpRegion 0x0000000000000500-0x000000000000052f (\_SI_.SIOR) (20140214/utaddress-258)
[   15.278321] ACPI: If an ACPI driver is available for this device, you should use it instead of the native driver
[   15.278353] lpc_ich: Resource conflict(s) found affecting gpio_ich
[   15.278606] Loading iSCSI transport class v2.0-870.
[   15.279201] Adaptec aacraid driver 1.2-0[30300]-ms
[   15.279265] aic94xx: Adaptec aic94xx SAS/SATA driver version 1.0.3 loaded
[   15.279368] qla2xxx [0000:00:00.0]-0005: : QLogic Fibre Channel HBA Driver: 8.07.00.02-k.
[   15.279451] megaraid cmm: 2.20.2.7 (Release Date: Sun Jul 16 00:01:03 EST 2006)
[   15.279588] megaraid: 2.20.5.1 (Release Date: Thu Nov 16 15:32:35 EST 2006)
[   15.279627] megasas: 06.803.01.00-rc1 Mon. Mar. 10 17:00:00 PDT 2014
[   15.279645] megasas: 0x1000:0x0079:0x8086:0x9256: bus 7:slot 0:func 0
[   15.280103] megasas: FW now in Ready state
[   15.280129] megaraid_sas 0000:07:00.0: irq 102 for MSI/MSI-X
[   15.280142] megaraid_sas 0000:07:00.0: [scsi0]: FW supports<0> MSIX vector,Online CPUs: <80>,Current MSIX <1>
[   15.349727] megasas_init_mfi: fw_support_ieee=0
[   15.349727] megasas: INIT adapter done
[   15.421783] megaraid_sas 0000:07:00.0: Controller type: MR,Memory size is: 512MB
[   15.421800] scsi0 : LSI SAS based MegaRAID driver
[   15.422099] GDT-HA: Storage RAID Controller Driver. Version: 3.05
[   15.422165] RocketRAID 3xxx/4xxx Controller driver v1.8
[   15.422540] ata_piix 0000:00:1f.2: version 2.13
[   15.422774] ata_piix 0000:00:1f.2: MAP [ P0 P2 P1 P3 ]
[   15.424205] scsi1 : ata_piix
[   15.424688] scsi2 : ata_piix
[   15.424775] ata1: SATA max UDMA/133 cmd 0x6138 ctl 0x614c bmdma 0x6110 irq 19
[   15.424780] ata2: SATA max UDMA/133 cmd 0x6130 ctl 0x6148 bmdma 0x6118 irq 19
[   15.424963] ata_piix 0000:00:1f.5: MAP [ P0 -- P1 -- ]
[   15.425071] scsi 0:0:25:0: Direct-Access     SEAGATE  ST9300603SS      0006 PQ: 0 ANSI: 5
[   15.425560] scsi 0:0:26:0: Direct-Access     ATA      SSDSA2SH032G1GN  8621 PQ: 0 ANSI: 5
[   15.446984] scsi 0:2:0:0: Direct-Access     INTEL    RS2BL080DE       2.70 PQ: 0 ANSI: 5
[   15.447255] scsi 0:2:2:0: Direct-Access     INTEL    RS2BL080DE       2.70 PQ: 0 ANSI: 5
[   15.458156] sd 0:2:0:0: [sda] 583983104 512-byte logical blocks: (298 GB/278 GiB)
[   15.458236] sd 0:2:0:0: Attached scsi generic sg0 type 0
[   15.458398] sd 0:2:0:0: [sda] Write Protect is off
[   15.458401] sd 0:2:0:0: [sda] Mode Sense: 1f 00 10 08
[   15.458525] sd 0:2:0:0: [sda] Write cache: disabled, read cache: enabled, supports DPO and FUA
[   15.458599] sd 0:2:2:0: Attached scsi generic sg1 type 0
[   15.458839] sd 0:2:2:0: [sdb] 57376768 512-byte logical blocks: (29.3 GB/27.3 GiB)
[   15.458958] sd 0:2:2:0: [sdb] Write Protect is off
[   15.458960] sd 0:2:2:0: [sdb] Mode Sense: 1f 00 10 08
[   15.459081] sd 0:2:2:0: [sdb] Write cache: disabled, read cache: enabled, supports DPO and FUA
[   15.460590]  sdb: sdb1 sdb9
[   15.461561] sd 0:2:2:0: [sdb] Attached SCSI disk
[   15.470698]  sda: sda1
[   15.470698]  sda1: <solaris: [s0] sda5 [s2] sda6 [s8] sda7 >
[   15.472054] sd 0:2:0:0: [sda] Attached SCSI disk
[   15.578959] scsi3 : ata_piix
[   15.579520] scsi4 : ata_piix
[   15.579601] ata3: SATA max UDMA/133 cmd 0x6128 ctl 0x6144 bmdma 0x60f0 irq 21
[   15.579604] ata4: SATA max UDMA/133 cmd 0x6120 ctl 0x6140 bmdma 0x60f8 irq 21
[   15.579808] tun: Universal TUN/TAP device driver, 1.6
[   15.579808] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[   15.580181] pcnet32: pcnet32.c:v1.35 21.Apr.2008 tsbogend@alpha.franken.de
[   15.580248] Atheros(R) L2 Ethernet Driver - version 2.2.3
[   15.580248] Copyright (c) 2007 Atheros Corporation.
[   15.580476] dmfe: Davicom DM9xxx net driver, version 1.36.4 (2002-01-17)
[   15.580512] v1.01-e (2.4 port) Sep-11-2006  Donald Becker <becker@scyld.com>
[   15.580512]   http://www.scyld.com/network/drivers.html
[   15.580624] uli526x: ULi M5261/M5263 net driver, version 0.9.3 (2005-7-29)
[   15.580704] e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
[   15.580705] e100: Copyright(c) 1999-2006 Intel Corporation
[   15.580764] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-NAPI
[   15.580764] e1000: Copyright (c) 1999-2006 Intel Corporation.
[   15.580823] e1000e: Intel(R) PRO/1000 Network Driver - 2.3.2-k
[   15.580823] e1000e: Copyright(c) 1999 - 2014 Intel Corporation.
[   15.580900] igb: Intel(R) Gigabit Ethernet Network Driver - version 5.0.5-k
[   15.580901] igb: Copyright (c) 2007-2014 Intel Corporation.
[   15.581266] igb 0000:01:00.0: irq 103 for MSI/MSI-X
[   15.581287] igb 0000:01:00.0: irq 104 for MSI/MSI-X
[   15.581296] igb 0000:01:00.0: irq 105 for MSI/MSI-X
[   15.581306] igb 0000:01:00.0: irq 106 for MSI/MSI-X
[   15.581315] igb 0000:01:00.0: irq 107 for MSI/MSI-X
[   15.581324] igb 0000:01:00.0: irq 108 for MSI/MSI-X
[   15.581342] igb 0000:01:00.0: irq 109 for MSI/MSI-X
[   15.581352] igb 0000:01:00.0: irq 110 for MSI/MSI-X
[   15.581361] igb 0000:01:00.0: irq 111 for MSI/MSI-X
[   15.581445] igb 0000:01:00.0: irq 103 for MSI/MSI-X
[   15.581454] igb 0000:01:00.0: irq 104 for MSI/MSI-X
[   15.581463] igb 0000:01:00.0: irq 105 for MSI/MSI-X
[   15.581472] igb 0000:01:00.0: irq 106 for MSI/MSI-X
[   15.581481] igb 0000:01:00.0: irq 107 for MSI/MSI-X
[   15.581489] igb 0000:01:00.0: irq 108 for MSI/MSI-X
[   15.581499] igb 0000:01:00.0: irq 109 for MSI/MSI-X
[   15.581508] igb 0000:01:00.0: irq 110 for MSI/MSI-X
[   15.581517] igb 0000:01:00.0: irq 111 for MSI/MSI-X
[   15.773191] igb 0000:01:00.0: added PHC on eth0
[   15.773192] igb 0000:01:00.0: Intel(R) Gigabit Ethernet Network Connection
[   15.773195] igb 0000:01:00.0: eth0: (PCIe:2.5Gb/s:Width x2) 60:eb:69:82:38:2a
[   15.773199] igb 0000:01:00.0: eth0: PBA No: Unknown
[   15.773200] igb 0000:01:00.0: Using MSI-X interrupts. 8 rx queue(s), 8 tx queue(s)
[   15.773284] IOAPIC[1]: Set routing entry (9-16 -> 0x65 -> IRQ 40 Mode:1 Active:1 Dest:0)
[   15.773571] igb 0000:01:00.1: irq 112 for MSI/MSI-X
[   15.773581] igb 0000:01:00.1: irq 113 for MSI/MSI-X
[   15.773590] igb 0000:01:00.1: irq 114 for MSI/MSI-X
[   15.773614] igb 0000:01:00.1: irq 115 for MSI/MSI-X
[   15.773623] igb 0000:01:00.1: irq 116 for MSI/MSI-X
[   15.773643] igb 0000:01:00.1: irq 117 for MSI/MSI-X
[   15.773652] igb 0000:01:00.1: irq 118 for MSI/MSI-X
[   15.773662] igb 0000:01:00.1: irq 119 for MSI/MSI-X
[   15.773671] igb 0000:01:00.1: irq 120 for MSI/MSI-X
[   15.773756] igb 0000:01:00.1: irq 112 for MSI/MSI-X
[   15.773765] igb 0000:01:00.1: irq 113 for MSI/MSI-X
[   15.773774] igb 0000:01:00.1: irq 114 for MSI/MSI-X
[   15.773783] igb 0000:01:00.1: irq 115 for MSI/MSI-X
[   15.773792] igb 0000:01:00.1: irq 116 for MSI/MSI-X
[   15.773801] igb 0000:01:00.1: irq 117 for MSI/MSI-X
[   15.773810] igb 0000:01:00.1: irq 118 for MSI/MSI-X
[   15.773819] igb 0000:01:00.1: irq 119 for MSI/MSI-X
[   15.773828] igb 0000:01:00.1: irq 120 for MSI/MSI-X
[   15.908840] ata3: SATA link down (SStatus 4 SControl 300)
[   15.962629] igb 0000:01:00.1: added PHC on eth1
[   15.962631] igb 0000:01:00.1: Intel(R) Gigabit Ethernet Network Connection
[   15.962633] igb 0000:01:00.1: eth1: (PCIe:2.5Gb/s:Width x2) 60:eb:69:82:38:2b
[   15.962636] igb 0000:01:00.1: eth1: PBA No: Unknown
[   15.962638] igb 0000:01:00.1: Using MSI-X interrupts. 8 rx queue(s), 8 tx queue(s)
[   15.962968] igb 0000:04:00.0: irq 121 for MSI/MSI-X
[   15.962978] igb 0000:04:00.0: irq 122 for MSI/MSI-X
[   15.962996] igb 0000:04:00.0: irq 123 for MSI/MSI-X
[   15.963006] igb 0000:04:00.0: irq 124 for MSI/MSI-X
[   15.963015] igb 0000:04:00.0: irq 125 for MSI/MSI-X
[   15.963024] igb 0000:04:00.0: irq 126 for MSI/MSI-X
[   15.963033] igb 0000:04:00.0: irq 127 for MSI/MSI-X
[   15.963044] igb 0000:04:00.0: irq 128 for MSI/MSI-X
[   15.963053] igb 0000:04:00.0: irq 129 for MSI/MSI-X
[   15.963134] igb 0000:04:00.0: irq 121 for MSI/MSI-X
[   15.963143] igb 0000:04:00.0: irq 122 for MSI/MSI-X
[   15.963152] igb 0000:04:00.0: irq 123 for MSI/MSI-X
[   15.963161] igb 0000:04:00.0: irq 124 for MSI/MSI-X
[   15.963170] igb 0000:04:00.0: irq 125 for MSI/MSI-X
[   15.963179] igb 0000:04:00.0: irq 126 for MSI/MSI-X
[   15.963188] igb 0000:04:00.0: irq 127 for MSI/MSI-X
[   15.963197] igb 0000:04:00.0: irq 128 for MSI/MSI-X
[   15.963206] igb 0000:04:00.0: irq 129 for MSI/MSI-X
[   16.062149] ata4: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
[   16.070357] ata4.00: ATAPI: HL-DT-STDVDRAM GT32N, AS00, max UDMA/100
[   16.072973] ata2.00: SATA link down (SStatus 0 SControl 300)
[   16.072991] ata2.01: SATA link down (SStatus 0 SControl 300)
[   16.083890] ata1.00: SATA link down (SStatus 0 SControl 300)
[   16.083909] ata1.01: SATA link down (SStatus 0 SControl 300)
[   16.086296] ata4.00: configured for UDMA/100
[   16.089850] scsi 4:0:0:0: CD-ROM            HL-DT-ST DVDRAM GT32N     AS00 PQ: 0 ANSI: 5
[   16.090135] scsi 4:0:0:0: Attached scsi generic sg2 type 5
[   16.154643] igb 0000:04:00.0: added PHC on eth2
[   16.154644] igb 0000:04:00.0: Intel(R) Gigabit Ethernet Network Connection
[   16.154646] igb 0000:04:00.0: eth2: (PCIe:2.5Gb/s:Width x2) 60:eb:69:82:38:2c
[   16.154649] igb 0000:04:00.0: eth2: PBA No: Unknown
[   16.154651] igb 0000:04:00.0: Using MSI-X interrupts. 8 rx queue(s), 8 tx queue(s)
[   16.154716] IOAPIC[1]: Set routing entry (9-17 -> 0x78 -> IRQ 41 Mode:1 Active:1 Dest:0)
[   16.154991] igb 0000:04:00.1: irq 130 for MSI/MSI-X
[   16.155000] igb 0000:04:00.1: irq 131 for MSI/MSI-X
[   16.155010] igb 0000:04:00.1: irq 132 for MSI/MSI-X
[   16.155019] igb 0000:04:00.1: irq 133 for MSI/MSI-X
[   16.155042] igb 0000:04:00.1: irq 134 for MSI/MSI-X
[   16.155051] igb 0000:04:00.1: irq 135 for MSI/MSI-X
[   16.155061] igb 0000:04:00.1: irq 136 for MSI/MSI-X
[   16.155070] igb 0000:04:00.1: irq 137 for MSI/MSI-X
[   16.155079] igb 0000:04:00.1: irq 138 for MSI/MSI-X
[   16.155158] igb 0000:04:00.1: irq 130 for MSI/MSI-X
[   16.155167] igb 0000:04:00.1: irq 131 for MSI/MSI-X
[   16.155176] igb 0000:04:00.1: irq 132 for MSI/MSI-X
[   16.155185] igb 0000:04:00.1: irq 133 for MSI/MSI-X
[   16.155194] igb 0000:04:00.1: irq 134 for MSI/MSI-X
[   16.155203] igb 0000:04:00.1: irq 135 for MSI/MSI-X
[   16.155212] igb 0000:04:00.1: irq 136 for MSI/MSI-X
[   16.155221] igb 0000:04:00.1: irq 137 for MSI/MSI-X
[   16.155230] igb 0000:04:00.1: irq 138 for MSI/MSI-X
[   16.346724] igb 0000:04:00.1: added PHC on eth3
[   16.346725] igb 0000:04:00.1: Intel(R) Gigabit Ethernet Network Connection
[   16.346727] igb 0000:04:00.1: eth3: (PCIe:2.5Gb/s:Width x2) 60:eb:69:82:38:2d
[   16.346730] igb 0000:04:00.1: eth3: PBA No: Unknown
[   16.346732] igb 0000:04:00.1: Using MSI-X interrupts. 8 rx queue(s), 8 tx queue(s)
[   16.346808] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - version 3.19.1-k
[   16.346809] ixgbe: Copyright (c) 1999-2014 Intel Corporation.
[   16.346874] ixgb: Intel(R) PRO/10GbE Network Driver - version 1.0.135-k2-NAPI
[   16.346874] ixgb: Copyright (c) 1999-2008 Intel Corporation.
[   16.346957] sky2: driver version 1.30
[   16.347314] usbcore: registered new interface driver catc
[   16.347329] usbcore: registered new interface driver kaweth
[   16.347331] pegasus: v0.9.3 (2013/04/25), Pegasus/Pegasus II USB Ethernet driver
[   16.347341] usbcore: registered new interface driver pegasus
[   16.347351] usbcore: registered new interface driver rtl8150
[   16.347365] usbcore: registered new interface driver asix
[   16.347376] usbcore: registered new interface driver ax88179_178a
[   16.347393] usbcore: registered new interface driver cdc_ether
[   16.347408] usbcore: registered new interface driver cdc_eem
[   16.347419] usbcore: registered new interface driver dm9601
[   16.347434] usbcore: registered new interface driver smsc75xx
[   16.347450] usbcore: registered new interface driver smsc95xx
[   16.347465] usbcore: registered new interface driver gl620a
[   16.347476] usbcore: registered new interface driver net1080
[   16.347487] usbcore: registered new interface driver plusb
[   16.347499] usbcore: registered new interface driver rndis_host
[   16.347512] usbcore: registered new interface driver cdc_subset
[   16.347524] usbcore: registered new interface driver zaurus
[   16.347542] usbcore: registered new interface driver MOSCHIP usb-ethernet driver
[   16.347557] usbcore: registered new interface driver int51x1
[   16.347568] usbcore: registered new interface driver ipheth
[   16.347582] usbcore: registered new interface driver sierra_net
[   16.347597] usbcore: registered new interface driver cdc_ncm
[   16.347598] Fusion MPT base driver 3.04.20
[   16.347599] Copyright (c) 1999-2008 LSI Corporation
[   16.347608] Fusion MPT SPI Host driver 3.04.20
[   16.347652] Fusion MPT FC Host driver 3.04.20
[   16.347697] Fusion MPT SAS Host driver 3.04.20
[   16.347737] Fusion MPT misc device (ioctl) driver 3.04.20
[   16.347786] mptctl: Registered with Fusion MPT base driver
[   16.347787] mptctl: /dev/mptctl @ (major,minor=10,220)
[   16.347952] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[   16.347956] ehci-pci: EHCI PCI platform driver
[   16.348244] ehci-pci 0000:00:1a.7: EHCI Host Controller
[   16.348315] ehci-pci 0000:00:1a.7: new USB bus registered, assigned bus number 1
[   16.348339] ehci-pci 0000:00:1a.7: debug port 1
[   16.352267] ehci-pci 0000:00:1a.7: cache line size of 64 is not supported
[   16.352285] ehci-pci 0000:00:1a.7: irq 18, io mem 0x95c01000
[   16.358276] ehci-pci 0000:00:1a.7: USB 2.0 started, EHCI 1.00
[   16.358491] hub 1-0:1.0: USB hub found
[   16.358511] hub 1-0:1.0: 6 ports detected
[   16.358977] ehci-pci 0000:00:1d.7: EHCI Host Controller
[   16.359126] ehci-pci 0000:00:1d.7: new USB bus registered, assigned bus number 2
[   16.359141] ehci-pci 0000:00:1d.7: debug port 1
[   16.363045] ehci-pci 0000:00:1d.7: cache line size of 64 is not supported
[   16.363062] ehci-pci 0000:00:1d.7: irq 23, io mem 0x95c00000
[   16.370286] ehci-pci 0000:00:1d.7: USB 2.0 started, EHCI 1.00
[   16.370584] hub 2-0:1.0: USB hub found
[   16.370589] hub 2-0:1.0: 6 ports detected
[   16.370844] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[   16.370848] ohci-pci: OHCI PCI platform driver
[   16.370882] uhci_hcd: USB Universal Host Controller Interface driver
[   16.371080] uhci_hcd 0000:00:1a.0: UHCI Host Controller
[   16.371232] uhci_hcd 0000:00:1a.0: new USB bus registered, assigned bus number 3
[   16.371240] uhci_hcd 0000:00:1a.0: detected 2 ports
[   16.371276] uhci_hcd 0000:00:1a.0: irq 16, io base 0x000060c0
[   16.371563] hub 3-0:1.0: USB hub found
[   16.371570] hub 3-0:1.0: 2 ports detected
[   16.371901] uhci_hcd 0000:00:1a.1: UHCI Host Controller
[   16.372046] uhci_hcd 0000:00:1a.1: new USB bus registered, assigned bus number 4
[   16.372053] uhci_hcd 0000:00:1a.1: detected 2 ports
[   16.372078] uhci_hcd 0000:00:1a.1: irq 21, io base 0x000060a0
[   16.372361] hub 4-0:1.0: USB hub found
[   16.372367] hub 4-0:1.0: 2 ports detected
[   16.372691] uhci_hcd 0000:00:1a.2: UHCI Host Controller
[   16.372837] uhci_hcd 0000:00:1a.2: new USB bus registered, assigned bus number 5
[   16.372844] uhci_hcd 0000:00:1a.2: detected 2 ports
[   16.372868] uhci_hcd 0000:00:1a.2: irq 19, io base 0x00006080
[   16.373150] hub 5-0:1.0: USB hub found
[   16.373155] hub 5-0:1.0: 2 ports detected
[   16.373480] uhci_hcd 0000:00:1d.0: UHCI Host Controller
[   16.373638] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 6
[   16.373646] uhci_hcd 0000:00:1d.0: detected 2 ports
[   16.373668] uhci_hcd 0000:00:1d.0: irq 23, io base 0x00006060
[   16.373971] hub 6-0:1.0: USB hub found
[   16.373977] hub 6-0:1.0: 2 ports detected
[   16.374315] uhci_hcd 0000:00:1d.1: UHCI Host Controller
[   16.374473] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 7
[   16.374480] uhci_hcd 0000:00:1d.1: detected 2 ports
[   16.374502] uhci_hcd 0000:00:1d.1: irq 19, io base 0x00006040
[   16.374778] hub 7-0:1.0: USB hub found
[   16.374784] hub 7-0:1.0: 2 ports detected
[   16.375114] uhci_hcd 0000:00:1d.2: UHCI Host Controller
[   16.375256] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 8
[   16.375263] uhci_hcd 0000:00:1d.2: detected 2 ports
[   16.375286] uhci_hcd 0000:00:1d.2: irq 18, io base 0x00006020
[   16.375609] hub 8-0:1.0: USB hub found
[   16.375615] hub 8-0:1.0: 2 ports detected
[   16.375844] usbcore: registered new interface driver usb-storage
[   16.375854] usbcore: registered new interface driver ums-alauda
[   16.375865] usbcore: registered new interface driver ums-datafab
[   16.375883] usbcore: registered new interface driver ums-freecom
[   16.375904] usbcore: registered new interface driver ums-isd200
[   16.375922] usbcore: registered new interface driver ums-jumpshot
[   16.375934] usbcore: registered new interface driver ums-sddr09
[   16.375945] usbcore: registered new interface driver ums-sddr55
[   16.375957] usbcore: registered new interface driver ums-usbat
[   16.375976] usbcore: registered new interface driver usbtest
[   16.376034] i8042: PNP: No PS/2 controller found. Probing ports directly.
[   17.405635] i8042: No controller found
[   17.410609] mousedev: PS/2 mouse device common for all mice
[   17.418387] rtc_cmos 00:02: RTC can wake from S4
[   17.424332] rtc_cmos 00:02: rtc core: registered rtc_cmos as rtc0
[   17.431581] rtc_cmos 00:02: alarms up to one month, y3k, 114 bytes nvram, hpet irqs
[   17.440919] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.10
[   17.447578] iTCO_wdt: unable to reset NO_REBOOT flag, device disabled by hardware/BIOS
[   17.457172] iTCO_vendor_support: vendor-support=0
[   17.463307] softdog: Software Watchdog Timer: 0.08 initialized. soft_noboot=0 soft_margin=60 sec soft_panic=0 (nowayout=0)
[   17.476416] md: linear personality registered for level -1
[   17.482949] md: raid0 personality registered for level 0
[   17.489292] md: raid1 personality registered for level 1
[   17.495640] md: raid10 personality registered for level 10
[   17.502437] md: raid6 personality registered for level 6
[   17.508784] md: raid5 personality registered for level 5
[   17.515122] md: raid4 personality registered for level 4
[   17.521456] md: multipath personality registered for level -4
[   17.528279] md: faulty personality registered for level -5
[   17.537057] device-mapper: ioctl: 4.27.0-ioctl (2013-10-30) initialised: dm-devel@redhat.com
[   17.554338] device-mapper: multipath: version 1.7.0 loaded
[   17.560897] device-mapper: multipath round-robin: version 1.0.0 loaded
[   17.568622] device-mapper: cache-policy-mq: version 1.2.0 loaded
[   17.575753] device-mapper: cache cleaner: version 1.0.0 loaded
[   17.582809] dcdbas dcdbas: Dell Systems Management Base Driver (version 5.6.0-3.2)
[   17.592392] usbcore: registered new interface driver usbhid
[   17.599029] usbhid: USB HID core driver
[   17.603973] TCP: bic registered
[   17.607877] Initializing XFRM netlink socket
[   17.613261] NET: Registered protocol family 10
[   17.619155] sit: IPv6 over IPv4 tunneling driver
[   17.624932] NET: Registered protocol family 17
[   17.630335] 8021q: 802.1Q VLAN Support v1.8
[   17.637012] DCCP: Activated CCID 2 (TCP-like)
[   17.642304] DCCP: Activated CCID 3 (TCP-Friendly Rate Control)
[   17.650030] sctp: Hash tables configured (established 65536 bind 65536)
[   17.657956] tipc: Activated (version 2.0.0)
[   17.663121] NET: Registered protocol family 30
[   17.669939] tipc: Started in single node mode
[   17.675231] Key type dns_resolver registered
[   17.685148] 
[   17.685148] printing PIC contents
[   17.691241] ... PIC  IMR: ffff
[   17.695054] ... PIC  IRR: 0c20
[   17.698867] ... PIC  ISR: 0000
[   17.702691] ... PIC ELCR: 0e20
[   17.706612] printing local APIC contents on CPU#0/0:
[   17.712559] ... APIC ID:      00000000 (0)
[   17.717530] ... APIC VERSION: 01060015
[   17.722108] ... APIC TASKPRI: 00000000 (00)
[   17.727170] ... APIC PROCPRI: 00000000
[   17.731740] ... APIC LDR: 01000000
[   17.735914] ... APIC DFR: ffffffff
[   17.740095] ... APIC SPIV: 000001ff
[   17.744381] ... APIC ISR field:
[   17.748262] 0000000000000000000000000000000000000000000000000000000000000000
[   17.757082] ... APIC TMR field:
[   17.760975] 0000000000000000000200000002000000000002000000000000000000000000
[   17.769805] ... APIC IRR field:
[   17.773704] 0000000000000000000000000000000000000000000000000000000000000000
[   17.782536] ... APIC ESR: 00000000
[   17.786724] ... APIC ICR: 000000fd
[   17.790909] ... APIC ICR2: a1000000
[   17.795199] ... APIC LVTT: 000000ef
[   17.799487] ... APIC LVTPC: 00000400
[   17.803869] ... APIC LVT0: 00010700
[   17.808145] ... APIC LVT1: 00000400
[   17.812432] ... APIC LVTERR: 000000fe
[   17.816914] ... APIC TMICT: 7fffffff
[   17.821289] ... APIC TMCCT: 7ff08fb4
[   17.825665] ... APIC TDCR: 00000003
[   17.829952] 
[   17.832002] number of MP IRQ sources: 15.
[   17.836887] number of IO-APIC #8 registers: 24.
[   17.842346] number of IO-APIC #9 registers: 24.
[   17.847813] number of IO-APIC #10 registers: 24.
[   17.853379] testing the IO APIC.......................
[   17.859524] IO APIC #8......
[   17.863125] .... register #00: 08000000
[   17.867808] .......    : physical APIC id: 08
[   17.873081] .......    : Delivery Type: 0
[   17.877957] .......    : LTS          : 0
[   17.882845] .... register #01: 00170020
[   17.887528] .......     : max redirection entries: 17
[   17.893583] .......     : PRQ implemented: 0
[   17.898763] .......     : IO APIC version: 20
[   17.904041] .... IRQ redirection table:
[   17.908733] 1    0    0   0   0    0    0    00
[   17.914202] 0    0    0   0   0    0    0    31
[   17.919676] 0    0    0   0   0    0    0    30
[   17.925142] 0    0    0   0   0    0    0    33
[   17.930617] 0    0    0   0   0    0    0    34
[   17.936075] 0    0    0   0   0    0    0    35
[   17.941537] 0    0    0   0   0    0    0    36
[   17.947002] 0    0    0   0   0    0    0    37
[   17.952472] 0    0    0   0   0    0    0    38
[   17.957944] 0    1    0   0   0    0    0    39
[   17.963420] 0    0    0   0   0    0    0    3A
[   17.968895] 0    0    0   0   0    0    0    3B
[   17.974367] 0    0    0   0   0    0    0    3C
[   17.979832] 0    0    0   0   0    0    0    3D
[   17.985300] 0    0    0   0   0    0    0    3E
[   17.990771] 0    0    0   0   0    0    0    3F
[   17.996237] 0    1    0   1   0    0    0    41
[   18.001710] 1    0    0   0   0    0    0    00
[   18.007167] 0    1    0   1   0    0    0    71
[   18.012631] 0    1    0   1   0    0    0    61
[   18.018096] 1    0    0   0   0    0    0    00
[   18.023568] 0    1    0   1   0    0    0    51
[   18.029041] 1    0    0   0   0    0    0    00
[   18.034515] 0    1    0   1   0    0    0    81
[   18.039990] IO APIC #9......
[   18.043610] .... register #00: 09000000
[   18.048300] .......    : physical APIC id: 09
[   18.053574] .......    : Delivery Type: 0
[   18.058457] .......    : LTS          : 0
[   18.063331] .... register #01: 00170020
[   18.068011] .......     : max redirection entries: 17
[   18.074063] .......     : PRQ implemented: 0
[   18.079225] .......     : IO APIC version: 20
[   18.084489] .... register #02: 00000000
[   18.089171] .......     : arbitration: 00
[   18.094053] .... register #03: 00000001
[   18.098747] .......     : Boot DT    : 1
[   18.103538] .... IRQ redirection table:
[   18.108233] 1    1    0   1   0    0    0    D1
[   18.113703] 1    0    0   0   0    0    0    00
[   18.119170] 1    1    0   1   0    0    0    22
[   18.124636] 1    0    0   0   0    0    0    00
[   18.130110] 1    1    0   1   0    0    0    91
[   18.135569] 1    1    0   1   0    0    0    B1
[   18.141031] 1    1    0   1   0    0    0    52
[   18.146494] 1    0    0   0   0    0    0    00
[   18.151957] 1    1    0   1   0    0    0    72
[   18.157429] 1    1    0   1   0    0    0    92
[   18.162901] 1    0    0   0   0    0    0    00
[   18.168373] 1    0    0   0   0    0    0    00
[   18.173845] 1    0    0   0   0    0    0    00
[   18.179305] 1    0    0   0   0    0    0    00
[   18.184774] 1    0    0   0   0    0    0    00
[   18.190247] 1    0    0   0   0    0    0    00
[   18.195717] 1    1    0   1   0    0    0    65
[   18.201192] 1    1    0   1   0    0    0    78
[   18.206653] 1    0    0   0   0    0    0    00
[   18.212116] 1    0    0   0   0    0    0    00
[   18.217581] 1    0    0   0   0    0    0    00
[   18.223059] 1    0    0   0   0    0    0    00
[   18.228577] 1    0    0   0   0    0    0    00
[   18.234055] 1    0    0   0   0    0    0    00
[   18.239539] IO APIC #10......
[   18.243257] .... register #00: 0A000000
[   18.248026] .......    : physical APIC id: 0A
[   18.253308] .......    : Delivery Type: 0
[   18.258198] .......    : LTS          : 0
[   18.263086] .... register #01: 00170020
[   18.267834] .......     : max redirection entries: 17
[   18.273887] .......     : PRQ implemented: 0
[   18.279068] .......     : IO APIC version: 20
[   18.284408] .... register #02: 00000000
[   18.289103] .......     : arbitration: 00
[   18.293988] .... register #03: 00000001
[   18.298686] .......     : Boot DT    : 1
[   18.303544] .... IRQ redirection table:
[   18.308244] 1    1    0   1   0    0    0    53
[   18.313722] 1    0    0   0   0    0    0    00
[   18.319188] 1    0    0   0   0    0    0    00
[   18.324745] 1    0    0   0   0    0    0    00
[   18.338695] 1    1    0   1   0    0    0    23
[   18.344169] 1    0    0   0   0    0    0    00
[   18.349633] 1    1    0   1   0    0    0    73
[   18.355092] 1    0    0   0   0    0    0    00
[   18.360572] 1    1    0   1   0    0    0    93
[   18.366039] 1    0    0   0   0    0    0    00
[   18.371590] 1    0    0   0   0    0    0    00
[   18.377059] 1    0    0   0   0    0    0    00
[   18.382534] 1    0    0   0   0    0    0    00
[   18.388009] 1    0    0   0   0    0    0    00
[   18.393486] 1    0    0   0   0    0    0    00
[   18.398956] 1    0    0   0   0    0    0    00
[   18.404430] 1    0    0   0   0    0    0    00
[   18.409900] 1    0    0   0   0    0    0    00
[   18.415365] 1    0    0   0   0    0    0    00
[   18.420909] 1    0    0   0   0    0    0    00
[   18.426373] 1    0    0   0   0    0    0    00
[   18.431846] 1    0    0   0   0    0    0    00
[   18.437310] 1    0    0   0   0    0    0    00
[   18.442779] 1    1    0   1   0    0    0    D2
[   18.448241] IRQ to pin mappings:
[   18.452253] IRQ0 -> 0:2
[   18.455532] IRQ1 -> 0:1
[   18.458876] IRQ3 -> 0:3
[   18.462158] IRQ4 -> 0:4
[   18.465441] IRQ5 -> 0:5
[   18.468716] IRQ6 -> 0:6
[   18.472065] IRQ7 -> 0:7
[   18.475329] IRQ8 -> 0:8
[   18.478614] IRQ9 -> 0:9
[   18.481893] IRQ10 -> 0:10
[   18.485362] IRQ11 -> 0:11
[   18.488832] IRQ12 -> 0:12
[   18.492312] IRQ13 -> 0:13
[   18.495814] IRQ14 -> 0:14
[   18.499273] IRQ15 -> 0:15
[   18.502754] IRQ16 -> 0:16
[   18.506225] IRQ18 -> 0:18
[   18.509695] IRQ19 -> 0:19
[   18.513164] IRQ21 -> 0:21
[   18.516636] IRQ23 -> 0:23
[   18.520174] IRQ24 -> 1:0
[   18.523541] IRQ26 -> 1:2
[   18.526954] IRQ28 -> 1:4
[   18.530338] IRQ29 -> 1:5
[   18.533713] IRQ30 -> 1:6
[   18.537094] IRQ32 -> 1:8
[   18.540474] IRQ33 -> 1:9
[   18.543874] IRQ40 -> 1:16
[   18.547338] IRQ41 -> 1:17
[   18.550819] IRQ48 -> 2:0
[   18.554192] IRQ52 -> 2:4
[   18.557559] IRQ54 -> 2:6
[   18.560974] IRQ56 -> 2:8
[   18.564350] IRQ71 -> 2:23
[   18.567830] .................................... done.
[   18.574077] Switched to clocksource tsc
[   18.574702] registered taskstats version 1
[   18.582053] Btrfs loaded
[   18.590970] rtc_cmos 00:02: setting system clock to 2014-03-18 03:42:57 UTC (1395114177)
[   18.600764] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
[   18.607885] EDD information not available.
[   18.627906] usb 4-1: new full-speed USB device number 2 using uhci_hcd
[   18.724643] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[   18.731569] 8021q: adding VLAN 0 to HW filter on device eth0
[   18.803975] input: American Megatrends Inc. Virtual Keyboard and Mouse as /devices/pci0000:00/0000:00:1a.1/usb4/4-1/4-1:1.0/0003:046B:FF10.0001/input/input2
[   18.820906] hid-generic 0003:046B:FF10.0001: input: USB HID v1.10 Keyboard [American Megatrends Inc. Virtual Keyboard and Mouse] on usb-0000:00:1a.1-1/input0
[   18.843933] input: American Megatrends Inc. Virtual Keyboard and Mouse as /devices/pci0000:00/0000:00:1a.1/usb4/4-1/4-1:1.1/0003:046B:FF10.0002/input/input3
[   18.848584] IPv6: ADDRCONF(NETDEV_UP): eth1: link is not ready
[   18.848585] 8021q: adding VLAN 0 to HW filter on device eth1
[   18.874616] hid-generic 0003:046B:FF10.0002: input: USB HID v1.10 Mouse [American Megatrends Inc. Virtual Keyboard and Mouse] on usb-0000:00:1a.1-1/input1
[   18.960691] IPv6: ADDRCONF(NETDEV_UP): eth2: link is not ready
[   18.967707] 8021q: adding VLAN 0 to HW filter on device eth2
[   19.084807] IPv6: ADDRCONF(NETDEV_UP): eth3: link is not ready
[   19.091734] 8021q: adding VLAN 0 to HW filter on device eth3
[   19.128117] usb 7-2: new full-speed USB device number 2 using uhci_hcd
[   19.287508] hub 7-2:1.0: USB hub found
[   19.293412] hub 7-2:1.0: 4 ports detected
[   19.633617] usb 7-2.1: new low-speed USB device number 3 using uhci_hcd
[   19.859043] input: ATEN International Co. Ltd CS1716A V1.0.098 as /devices/pci0000:00/0000:00:1d.1/usb7/7-2/7-2.1/7-2.1:1.0/0003:0557:2261.0003/input/input4
[   19.875916] hid-generic 0003:0557:2261.0003: input: USB HID v1.00 Keyboard [ATEN International Co. Ltd CS1716A V1.0.098] on usb-0000:00:1d.1-2.1/input0
[   19.926945] input: ATEN International Co. Ltd CS1716A V1.0.098 as /devices/pci0000:00/0000:00:1d.1/usb7/7-2/7-2.1/7-2.1:1.1/0003:0557:2261.0004/input/input5
[   19.943669] hid-generic 0003:0557:2261.0004: input: USB HID v1.00 Device [ATEN International Co. Ltd CS1716A V1.0.098] on usb-0000:00:1d.1-2.1/input1
[   19.982085] input: ATEN International Co. Ltd CS1716A V1.0.098 as /devices/pci0000:00/0000:00:1d.1/usb7/7-2/7-2.1/7-2.1:1.2/0003:0557:2261.0005/input/input6
[   19.999092] hid-generic 0003:0557:2261.0005: input: USB HID v1.10 Mouse [ATEN International Co. Ltd CS1716A V1.0.098] on usb-0000:00:1d.1-2.1/input2
[   21.353918] igb: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX
[   21.369553] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[   21.385487] Sending DHCP requests .., OK
[   25.560152] IP-Config: Got DHCP answer from 192.168.1.1, my address is 192.168.1.191
[   26.133319] IP-Config: Complete:
[   26.137420]      device=eth0, hwaddr=60:eb:69:82:38:2a, ipaddr=192.168.1.191, mask=255.255.255.0, gw=192.168.1.1
[   26.149520]      host=lkp-wsx02, domain=lkp.intel.com, nis-domain=(none)
[   26.157399]      bootserver=192.168.1.1, rootserver=192.168.1.1, rootpath=
[   26.164967]      nameserver0=192.168.1.1
[   26.170390] PM: Hibernation image not present or could not be loaded.
[   26.198284] Freeing unused kernel memory: 1436K (ffffffff8233f000 - ffffffff824a6000)
[   26.207768] Write protecting the kernel read-only data: 18432k
[   26.251995] Freeing unused kernel memory: 1720K (ffff880001a52000 - ffff880001c00000)
[   26.279269] Freeing unused kernel memory: 1852K (ffff880002031000 - ffff880002200000)
[   26.670238] ipmi message handler version 39.2
[   26.715704] IPMI System Interface driver.
[   26.720715] ipmi_si: probing via ACPI
[   26.725244] ipmi_si 00:0a: [io  0x0ca2] regsize 1 spacing 1 irq 0
[   26.732472] ipmi_si: Adding ACPI-specified kcs state machine
[   26.741396] ipmi_si: probing via SMBIOS
[   26.746096] ipmi_si: SMBIOS: io 0xca2 regsize 1 spacing 1 irq 0
[   26.753114] ipmi_si: Adding SMBIOS-specified kcs state machine duplicate interface
[   26.762396] ipmi_si: Trying ACPI-specified kcs state machine at i/o address 0xca2, slave address 0x0, irq 0
[   26.795556] microcode: CPU0 sig=0x206f2, pf=0x4, revision=0x26
[   26.802588] microcode: CPU1 sig=0x206f2, pf=0x4, revision=0x26
[   26.809675] microcode: CPU2 sig=0x206f2, pf=0x4, revision=0x26
[   26.816878] microcode: CPU3 sig=0x206f2, pf=0x4, revision=0x26
[   26.823838] microcode: CPU4 sig=0x206f2, pf=0x4, revision=0x26
[   26.830954] microcode: CPU5 sig=0x206f2, pf=0x4, revision=0x26
[   26.837958] microcode: CPU6 sig=0x206f2, pf=0x4, revision=0x26
[   26.844944] microcode: CPU7 sig=0x206f2, pf=0x4, revision=0x26
[   26.851966] microcode: CPU8 sig=0x206f2, pf=0x4, revision=0x26
[   26.858950] microcode: CPU9 sig=0x206f2, pf=0x4, revision=0x26
[   26.865991] microcode: CPU10 sig=0x206f2, pf=0x4, revision=0x26
[   26.873103] microcode: CPU11 sig=0x206f2, pf=0x4, revision=0x26
[   26.880194] microcode: CPU12 sig=0x206f2, pf=0x4, revision=0x26
[   26.887316] microcode: CPU13 sig=0x206f2, pf=0x4, revision=0x26
[   26.894437] microcode: CPU14 sig=0x206f2, pf=0x4, revision=0x26
[   26.901755] microcode: CPU15 sig=0x206f2, pf=0x4, revision=0x26
[   26.909082] microcode: CPU16 sig=0x206f2, pf=0x4, revision=0x26
[   26.916399] microcode: CPU17 sig=0x206f2, pf=0x4, revision=0x26
[   26.923745] microcode: CPU18 sig=0x206f2, pf=0x4, revision=0x26
[   26.931045] microcode: CPU19 sig=0x206f2, pf=0x4, revision=0x26
[   26.931340] ipmi_si 00:0a: Found new BMC (man_id: 0x000157, prod_id: 0x0040, dev_id: 0x21)
[   26.931350] ipmi_si 00:0a: IPMI kcs interface initialized
[   26.954604] microcode: CPU20 sig=0x206f2, pf=0x4, revision=0x26
[   26.961730] microcode: CPU21 sig=0x206f2, pf=0x4, revision=0x26
[   26.968854] microcode: CPU22 sig=0x206f2, pf=0x4, revision=0x26
[   26.975966] microcode: CPU23 sig=0x206f2, pf=0x4, revision=0x26
[   26.983071] microcode: CPU24 sig=0x206f2, pf=0x4, revision=0x26
[   26.990214] microcode: CPU25 sig=0x206f2, pf=0x4, revision=0x26
[   26.997376] microcode: CPU26 sig=0x206f2, pf=0x4, revision=0x26
[   27.004487] microcode: CPU27 sig=0x206f2, pf=0x4, revision=0x26
[   27.011607] microcode: CPU28 sig=0x206f2, pf=0x4, revision=0x26
[   27.018754] microcode: CPU29 sig=0x206f2, pf=0x4, revision=0x26
[   27.025919] microcode: CPU30 sig=0x206f2, pf=0x4, revision=0x26
[   27.032990] microcode: CPU31 sig=0x206f2, pf=0x4, revision=0x26
[   27.040108] microcode: CPU32 sig=0x206f2, pf=0x4, revision=0x26
[   27.047231] microcode: CPU33 sig=0x206f2, pf=0x4, revision=0x26
[   27.054394] microcode: CPU34 sig=0x206f2, pf=0x4, revision=0x26
[   27.061509] microcode: CPU35 sig=0x206f2, pf=0x4, revision=0x26
[   27.068550] microcode: CPU36 sig=0x206f2, pf=0x4, revision=0x26
[   27.075680] microcode: CPU37 sig=0x206f2, pf=0x4, revision=0x26
[   27.082851] microcode: CPU38 sig=0x206f2, pf=0x4, revision=0x26
[   27.089963] microcode: CPU39 sig=0x206f2, pf=0x4, revision=0x26
[   27.097075] microcode: CPU40 sig=0x206f2, pf=0x4, revision=0x26
[   27.104214] microcode: CPU41 sig=0x206f2, pf=0x4, revision=0x26
[   27.111377] microcode: CPU42 sig=0x206f2, pf=0x4, revision=0x26
[   27.118481] microcode: CPU43 sig=0x206f2, pf=0x4, revision=0x26
[   27.133934] microcode: CPU44 sig=0x206f2, pf=0x4, revision=0x26
[   27.141068] microcode: CPU45 sig=0x206f2, pf=0x4, revision=0x26
[   27.148225] microcode: CPU46 sig=0x206f2, pf=0x4, revision=0x26
[   27.155337] microcode: CPU47 sig=0x206f2, pf=0x4, revision=0x26
[   27.162447] microcode: CPU48 sig=0x206f2, pf=0x4, revision=0x26
[   27.169574] microcode: CPU49 sig=0x206f2, pf=0x4, revision=0x26
[   27.176728] microcode: CPU50 sig=0x206f2, pf=0x4, revision=0x26
[   27.183832] microcode: CPU51 sig=0x206f2, pf=0x4, revision=0x26
[   27.190951] microcode: CPU52 sig=0x206f2, pf=0x4, revision=0x26
[   27.198101] microcode: CPU53 sig=0x206f2, pf=0x4, revision=0x26
[   27.205259] microcode: CPU54 sig=0x206f2, pf=0x4, revision=0x26
[   27.212384] microcode: CPU55 sig=0x206f2, pf=0x4, revision=0x26
[   27.219501] microcode: CPU56 sig=0x206f2, pf=0x4, revision=0x26
[   27.226639] microcode: CPU57 sig=0x206f2, pf=0x4, revision=0x26
[   27.233804] microcode: CPU58 sig=0x206f2, pf=0x4, revision=0x26
[   27.240905] microcode: CPU59 sig=0x206f2, pf=0x4, revision=0x26
[   27.248037] microcode: CPU60 sig=0x206f2, pf=0x4, revision=0x26
[   27.255175] microcode: CPU61 sig=0x206f2, pf=0x4, revision=0x26
[   27.262338] microcode: CPU62 sig=0x206f2, pf=0x4, revision=0x26
[   27.269443] microcode: CPU63 sig=0x206f2, pf=0x4, revision=0x26
[   27.276551] microcode: CPU64 sig=0x206f2, pf=0x4, revision=0x26
[   27.283699] microcode: CPU65 sig=0x206f2, pf=0x4, revision=0x26
[   27.290859] microcode: CPU66 sig=0x206f2, pf=0x4, revision=0x26
[   27.297976] microcode: CPU67 sig=0x206f2, pf=0x4, revision=0x26
[   27.305204] microcode: CPU68 sig=0x206f2, pf=0x4, revision=0x26
[   27.312354] microcode: CPU69 sig=0x206f2, pf=0x4, revision=0x26
[   27.319515] microcode: CPU70 sig=0x206f2, pf=0x4, revision=0x26
[   27.326558] microcode: CPU71 sig=0x206f2, pf=0x4, revision=0x26
[   27.333664] microcode: CPU72 sig=0x206f2, pf=0x4, revision=0x26
[   27.340799] microcode: CPU73 sig=0x206f2, pf=0x4, revision=0x26
[   27.347961] microcode: CPU74 sig=0x206f2, pf=0x4, revision=0x26
[   27.355066] microcode: CPU75 sig=0x206f2, pf=0x4, revision=0x26
[   27.362190] microcode: CPU76 sig=0x206f2, pf=0x4, revision=0x26
[   27.369249] microcode: CPU77 sig=0x206f2, pf=0x4, revision=0x26
[   27.376428] microcode: CPU78 sig=0x206f2, pf=0x4, revision=0x26
[   27.383471] microcode: CPU79 sig=0x206f2, pf=0x4, revision=0x26
[   27.390837] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
[   30.170456] random: vgscan urandom read with 91 bits of entropy available
<6>[    0.000000] Initializing cgroup subsys cpuset
<6>[    0.000000] Initializing cgroup subsys cpu
<5>[    0.000000] Linux version 3.14.0-rc6-next-20140317 (kbuild@xian) (gcc version 4.8.2 (Debian 4.8.2-16) ) #1 SMP Mon Mar 17 20:01:18 CST 2014
<6>[    0.000000] Command line: BOOT_IMAGE=/kernel/x86_64-lkp/8808b950581f71e3ee4cf8e6cae479f4c7106405/vmlinuz-3.14.0-rc6-next-20140317 user=lkp job=/lkp/scheduled/lkp-wsx02/cyclic_netperf-power-120s-25%-SCTP_STREAM_MANY-HEAD-8808b950581f71e3ee4cf8e6cae479f4c7106405.yaml ARCH=x86_64 BOOT_IMAGE=/kernel/x86_64-lkp/8808b950581f71e3ee4cf8e6cae479f4c7106405/vmlinuz-3.14.0-rc6-next-20140317 kconfig=x86_64-lkp commit=8808b950581f71e3ee4cf8e6cae479f4c7106405 max_uptime=996 RESULT_ROOT=/lkp/result/lkp-wsx02/micro/netperf/120s-25%-SCTP_STREAM_MANY/x86_64-lkp/8808b950581f71e3ee4cf8e6cae479f4c7106405/0 root=/dev/ram0 ip=::::lkp-wsx02::dhcp oops=panic earlyprintk=ttyS0,115200 debug apic=debug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=100 panic=10 softlockup_panic=1 nmi_watchdog=panic load_ramdisk=2 prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal
<6>[    0.000000] e820: BIOS-provided physical RAM map:
<6>[    0.000000] BIOS-e820: [mem 0x0000000000000100-0x000000000009b3ff] usable
<6>[    0.000000] BIOS-e820: [mem 0x000000000009b400-0x000000000009ffff] reserved
<6>[    0.000000] BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] reserved
<6>[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000007b43dfff] usable
<6>[    0.000000] BIOS-e820: [mem 0x000000007b43e000-0x000000007b440fff] reserved
<6>[    0.000000] BIOS-e820: [mem 0x000000007b441000-0x000000007b67cfff] ACPI NVS
<6>[    0.000000] BIOS-e820: [mem 0x000000007b67d000-0x000000007b68bfff] ACPI data
<6>[    0.000000] BIOS-e820: [mem 0x000000007b68c000-0x000000007b68efff] reserved
<6>[    0.000000] BIOS-e820: [mem 0x000000007b68f000-0x000000007b693fff] ACPI data
<6>[    0.000000] BIOS-e820: [mem 0x000000007b694000-0x000000007b7bcfff] reserved
<6>[    0.000000] BIOS-e820: [mem 0x000000007b7bd000-0x000000007ba3cfff] ACPI NVS
<6>[    0.000000] BIOS-e820: [mem 0x000000007ba3d000-0x000000007baa7fff] reserved
<6>[    0.000000] BIOS-e820: [mem 0x000000007baa8000-0x000000007bcfffff] ACPI data
<6>[    0.000000] BIOS-e820: [mem 0x000000007bd00000-0x000000007bd16fff] reserved
<6>[    0.000000] BIOS-e820: [mem 0x000000007bd17000-0x000000007bd19fff] ACPI data
<6>[    0.000000] BIOS-e820: [mem 0x000000007bd1a000-0x000000007bd49fff] reserved
<6>[    0.000000] BIOS-e820: [mem 0x000000007bd4a000-0x000000007bd5efff] ACPI data
<6>[    0.000000] BIOS-e820: [mem 0x000000007bd5f000-0x000000007bdfefff] reserved
<6>[    0.000000] BIOS-e820: [mem 0x000000007bdff000-0x000000007bdfffff] ACPI data
<6>[    0.000000] BIOS-e820: [mem 0x000000007be00000-0x000000007be4efff] reserved
<6>[    0.000000] BIOS-e820: [mem 0x000000007be4f000-0x000000007bf70fff] ACPI data
<6>[    0.000000] BIOS-e820: [mem 0x000000007bf71000-0x000000007bfcefff] ACPI NVS
<6>[    0.000000] BIOS-e820: [mem 0x000000007bfcf000-0x000000007bffefff] ACPI data
<6>[    0.000000] BIOS-e820: [mem 0x000000007bfff000-0x000000008fffffff] reserved
<6>[    0.000000] BIOS-e820: [mem 0x00000000fc000000-0x00000000fcffffff] reserved
<6>[    0.000000] BIOS-e820: [mem 0x00000000fed1c000-0x00000000fed1ffff] reserved
<6>[    0.000000] BIOS-e820: [mem 0x00000000ff000000-0x00000000ffffffff] reserved
<6>[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000207fffffff] usable
<6>[    0.000000] bootconsole [earlyser0] enabled
<6>[    0.000000] NX (Execute Disable) protection: active
<6>[    0.000000] SMBIOS 2.5 present.
<7>[    0.000000] DMI: QCI QSSC-S4R/QSSC-S4R, BIOS QSSC-S4R.QCI.01.00.0030.031120111710 03/11/2011
<7>[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
<7>[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
<6>[    0.000000] No AGP bridge found
<6>[    0.000000] e820: last_pfn = 0x2080000 max_arch_pfn = 0x400000000
<7>[    0.000000] MTRR default type: write-back
<7>[    0.000000] MTRR fixed ranges enabled:
<7>[    0.000000]   00000-9FFFF write-back
<7>[    0.000000]   A0000-BFFFF uncachable
<7>[    0.000000]   C0000-DFFFF write-through
<7>[    0.000000]   E0000-FFFFF write-protect
<7>[    0.000000] MTRR variable ranges enabled:
<7>[    0.000000]   0 base 00080000000 mask FFF80000000 uncachable
<7>[    0.000000]   1 base FC000000000 mask FFF00000000 uncachable
<7>[    0.000000]   2 disabled
<7>[    0.000000]   3 disabled
<7>[    0.000000]   4 disabled
<7>[    0.000000]   5 disabled
<7>[    0.000000]   6 disabled
<7>[    0.000000]   7 disabled
<7>[    0.000000]   8 disabled
<7>[    0.000000]   9 disabled
<6>[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
<6>[    0.000000] e820: last_pfn = 0x7b43e max_arch_pfn = 0x400000000
<4>[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
<4>[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
<4>[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
<6>[    0.000000] found SMP MP-table at [mem 0x000fd9e0-0x000fd9ef] mapped at [ffff8800000fd9e0]
<4>[    0.000000]   mpc: efc20-eff2c
<6>[    0.000000] Scanning 1 areas for low memory corruption
<7>[    0.000000] Base memory trampoline at [ffff880000095000] 95000 size 24576
<6>[    0.000000] Using GB pages for direct mapping
<6>[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
<7>[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
<7>[    0.000000] BRK [0x0266b000, 0x0266bfff] PGTABLE
<7>[    0.000000] BRK [0x0266c000, 0x0266cfff] PGTABLE
<7>[    0.000000] BRK [0x0266d000, 0x0266dfff] PGTABLE
<6>[    0.000000] init_memory_mapping: [mem 0x207fe00000-0x207fffffff]
<7>[    0.000000]  [mem 0x207fe00000-0x207fffffff] page 1G
<6>[    0.000000] init_memory_mapping: [mem 0x207c000000-0x207fdfffff]
<7>[    0.000000]  [mem 0x207c000000-0x207fdfffff] page 1G
<6>[    0.000000] init_memory_mapping: [mem 0x2000000000-0x207bffffff]
<7>[    0.000000]  [mem 0x2000000000-0x207bffffff] page 1G
<6>[    0.000000] init_memory_mapping: [mem 0x1000000000-0x1fffffffff]
<7>[    0.000000]  [mem 0x1000000000-0x1fffffffff] page 1G
<6>[    0.000000] init_memory_mapping: [mem 0x00100000-0x7b43dfff]
<7>[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
<7>[    0.000000]  [mem 0x00200000-0x7b3fffff] page 2M
<7>[    0.000000]  [mem 0x7b400000-0x7b43dfff] page 4k
<6>[    0.000000] init_memory_mapping: [mem 0x100000000-0xfffffffff]
<7>[    0.000000]  [mem 0x100000000-0xfffffffff] page 1G
<6>[    0.000000] RAMDISK: [mem 0x6e448000-0x7b433fff]
<4>[    0.000000] ACPI: RSDP 0x00000000000F0410 000024 (v02 QUANTA)
<4>[    0.000000] ACPI: XSDT 0x000000007BFFE120 0000BC (v01 QUANTA QSSC-S4R 00000000      01000013)
<4>[    0.000000] ACPI: FACP 0x000000007BFFD000 0000F4 (v04 QUANTA QSSC-S4R 00000000 MSFT 0100000D)
<4>[    0.000000] ACPI: DSDT 0x000000007BFE1000 01B7B5 (v02 QUANTA QSSC-S4R 00000003 MSFT 0100000D)
<4>[    0.000000] ACPI: FACS 0x000000007BF71000 000040
<4>[    0.000000] ACPI: APIC 0x000000007BFE0000 0004C4 (v02 QUANTA QSSC-S4R 00000000 MSFT 0100000D)
<4>[    0.000000] ACPI: MSCT 0x000000007BFDF000 000090 (v01 QUANTA QSSC-S4R 00000001 MSFT 0100000D)
<4>[    0.000000] ACPI: MCFG 0x000000007BFDE000 00003C (v01 QUANTA QSSC-S4R 00000001 MSFT 0100000D)
<4>[    0.000000] ACPI: HPET 0x000000007BFDD000 000038 (v01 QUANTA QSSC-S4R 00000001 MSFT 0100000D)
<4>[    0.000000] ACPI: SLIT 0x000000007BFDC000 00003C (v01 QUANTA QSSC-S4R 00000001 MSFT 0100000D)
<4>[    0.000000] ACPI: SRAT 0x000000007BFDB000 000A30 (v02 QUANTA QSSC-S4R 00000001 MSFT 0100000D)
<4>[    0.000000] ACPI: SPCR 0x000000007BFDA000 000050 (v01 QUANTA QSSC-S4R 00000000 MSFT 0100000D)
<4>[    0.000000] ACPI: WDDT 0x000000007BFD9000 000040 (v01 QUANTA QSSC-S4R 00000000 MSFT 0100000D)
<4>[    0.000000] ACPI: SSDT 0x000000007BF24000 04C744 (v02 QUANTA QSSC-S4R 00004000 INTL 20061109)
<4>[    0.000000] ACPI: SSDT 0x000000007BFD8000 000174 (v02 QUANTA QSSC-S4R 00004000 INTL 20061109)
<4>[    0.000000] ACPI: PMCT 0x000000007BFD7000 000060 (v01 QUANTA QSSC-S4R 00000000 MSFT 0100000D)
<4>[    0.000000] ACPI: MIGT 0x000000007BFD6000 000040 (v01 QUANTA QSSC-S4R 00000000 MSFT 0100000D)
<4>[    0.000000] ACPI: TCPA 0x000000007BFD3000 000032 (v00 QUANTA QSSC-S4R 00000000      00000000)
<4>[    0.000000] ACPI: HEST 0x000000007BFD2000 0000A8 (v01 QUANTA QSSC-S4R 00000001 INTL 00000001)
<4>[    0.000000] ACPI: BERT 0x000000007BFD1000 000030 (v01 QUANTA QSSC-S4R 00000001 INTL 00000001)
<4>[    0.000000] ACPI: ERST 0x000000007BFD0000 000230 (v01 QUANTA QSSC-S4R 00000001 INTL 00000001)
<4>[    0.000000] ACPI: EINJ 0x000000007BFCF000 000130 (v01 QUANTA QSSC-S4R 00000001 INTL 00000001)
<4>[    0.000000] ACPI: DMAR 0x000000007BF23000 0002F8 (v01 QUANTA QSSC-S4R 00000001 MSFT 0100000D)
<7>[    0.000000] ACPI: Local APIC address 0xfee00000
<4>[    0.000000] mapped APIC to ffffffffff5f3000 (        fee00000)
<6>[    0.000000] SRAT: PXM 0 -> APIC 0x00 -> Node 0
<6>[    0.000000] SRAT: PXM 0 -> APIC 0x01 -> Node 0
<6>[    0.000000] SRAT: PXM 0 -> APIC 0x02 -> Node 0
<6>[    0.000000] SRAT: PXM 0 -> APIC 0x03 -> Node 0
<6>[    0.000000] SRAT: PXM 0 -> APIC 0x04 -> Node 0
<6>[    0.000000] SRAT: PXM 0 -> APIC 0x05 -> Node 0
<6>[    0.000000] SRAT: PXM 0 -> APIC 0x10 -> Node 0
<6>[    0.000000] SRAT: PXM 0 -> APIC 0x11 -> Node 0
<6>[    0.000000] SRAT: PXM 0 -> APIC 0x12 -> Node 0
<6>[    0.000000] SRAT: PXM 0 -> APIC 0x13 -> Node 0
<6>[    0.000000] SRAT: PXM 0 -> APIC 0x20 -> Node 0
<6>[    0.000000] SRAT: PXM 0 -> APIC 0x21 -> Node 0
<6>[    0.000000] SRAT: PXM 0 -> APIC 0x22 -> Node 0
<6>[    0.000000] SRAT: PXM 0 -> APIC 0x23 -> Node 0
<6>[    0.000000] SRAT: PXM 0 -> APIC 0x24 -> Node 0
<6>[    0.000000] SRAT: PXM 0 -> APIC 0x25 -> Node 0
<6>[    0.000000] SRAT: PXM 0 -> APIC 0x30 -> Node 0
<6>[    0.000000] SRAT: PXM 0 -> APIC 0x31 -> Node 0
<6>[    0.000000] SRAT: PXM 0 -> APIC 0x32 -> Node 0
<6>[    0.000000] SRAT: PXM 0 -> APIC 0x33 -> Node 0
<6>[    0.000000] SRAT: PXM 1 -> APIC 0x40 -> Node 1
<6>[    0.000000] SRAT: PXM 1 -> APIC 0x41 -> Node 1
<6>[    0.000000] SRAT: PXM 1 -> APIC 0x42 -> Node 1
<6>[    0.000000] SRAT: PXM 1 -> APIC 0x43 -> Node 1
<6>[    0.000000] SRAT: PXM 1 -> APIC 0x44 -> Node 1
<6>[    0.000000] SRAT: PXM 1 -> APIC 0x45 -> Node 1
<6>[    0.000000] SRAT: PXM 1 -> APIC 0x50 -> Node 1
<6>[    0.000000] SRAT: PXM 1 -> APIC 0x51 -> Node 1
<6>[    0.000000] SRAT: PXM 1 -> APIC 0x52 -> Node 1
<6>[    0.000000] SRAT: PXM 1 -> APIC 0x53 -> Node 1
<6>[    0.000000] SRAT: PXM 1 -> APIC 0x60 -> Node 1
<6>[    0.000000] SRAT: PXM 1 -> APIC 0x61 -> Node 1
<6>[    0.000000] SRAT: PXM 1 -> APIC 0x62 -> Node 1
<6>[    0.000000] SRAT: PXM 1 -> APIC 0x63 -> Node 1
<6>[    0.000000] SRAT: PXM 1 -> APIC 0x64 -> Node 1
<6>[    0.000000] SRAT: PXM 1 -> APIC 0x65 -> Node 1
<6>[    0.000000] SRAT: PXM 1 -> APIC 0x70 -> Node 1
<6>[    0.000000] SRAT: PXM 1 -> APIC 0x71 -> Node 1
<6>[    0.000000] SRAT: PXM 1 -> APIC 0x72 -> Node 1
<6>[    0.000000] SRAT: PXM 1 -> APIC 0x73 -> Node 1
<6>[    0.000000] SRAT: PXM 2 -> APIC 0x80 -> Node 2
<6>[    0.000000] SRAT: PXM 2 -> APIC 0x81 -> Node 2
<6>[    0.000000] SRAT: PXM 2 -> APIC 0x82 -> Node 2
<6>[    0.000000] SRAT: PXM 2 -> APIC 0x83 -> Node 2
<6>[    0.000000] SRAT: PXM 2 -> APIC 0x84 -> Node 2
<6>[    0.000000] SRAT: PXM 2 -> APIC 0x85 -> Node 2
<6>[    0.000000] SRAT: PXM 2 -> APIC 0x90 -> Node 2
<6>[    0.000000] SRAT: PXM 2 -> APIC 0x91 -> Node 2
<6>[    0.000000] SRAT: PXM 2 -> APIC 0x92 -> Node 2
<6>[    0.000000] SRAT: PXM 2 -> APIC 0x93 -> Node 2
<6>[    0.000000] SRAT: PXM 2 -> APIC 0xa0 -> Node 2
<6>[    0.000000] SRAT: PXM 2 -> APIC 0xa1 -> Node 2
<6>[    0.000000] SRAT: PXM 2 -> APIC 0xa2 -> Node 2
<6>[    0.000000] SRAT: PXM 2 -> APIC 0xa3 -> Node 2
<6>[    0.000000] SRAT: PXM 2 -> APIC 0xa4 -> Node 2
<6>[    0.000000] SRAT: PXM 2 -> APIC 0xa5 -> Node 2
<6>[    0.000000] SRAT: PXM 2 -> APIC 0xb0 -> Node 2
<6>[    0.000000] SRAT: PXM 2 -> APIC 0xb1 -> Node 2
<6>[    0.000000] SRAT: PXM 2 -> APIC 0xb2 -> Node 2
<6>[    0.000000] SRAT: PXM 2 -> APIC 0xb3 -> Node 2
<6>[    0.000000] SRAT: PXM 3 -> APIC 0xc0 -> Node 3
<6>[    0.000000] SRAT: PXM 3 -> APIC 0xc1 -> Node 3
<6>[    0.000000] SRAT: PXM 3 -> APIC 0xc2 -> Node 3
<6>[    0.000000] SRAT: PXM 3 -> APIC 0xc3 -> Node 3
<6>[    0.000000] SRAT: PXM 3 -> APIC 0xc4 -> Node 3
<6>[    0.000000] SRAT: PXM 3 -> APIC 0xc5 -> Node 3
<6>[    0.000000] SRAT: PXM 3 -> APIC 0xd0 -> Node 3
<6>[    0.000000] SRAT: PXM 3 -> APIC 0xd1 -> Node 3
<6>[    0.000000] SRAT: PXM 3 -> APIC 0xd2 -> Node 3
<6>[    0.000000] SRAT: PXM 3 -> APIC 0xd3 -> Node 3
<6>[    0.000000] SRAT: PXM 3 -> APIC 0xe0 -> Node 3
<6>[    0.000000] SRAT: PXM 3 -> APIC 0xe1 -> Node 3
<6>[    0.000000] SRAT: PXM 3 -> APIC 0xe2 -> Node 3
<6>[    0.000000] SRAT: PXM 3 -> APIC 0xe3 -> Node 3
<6>[    0.000000] SRAT: PXM 3 -> APIC 0xe4 -> Node 3
<6>[    0.000000] SRAT: PXM 3 -> APIC 0xe5 -> Node 3
<6>[    0.000000] SRAT: PXM 3 -> APIC 0xf0 -> Node 3
<6>[    0.000000] SRAT: PXM 3 -> APIC 0xf1 -> Node 3
<6>[    0.000000] SRAT: PXM 3 -> APIC 0xf2 -> Node 3
<6>[    0.000000] SRAT: PXM 3 -> APIC 0xf3 -> Node 3
<6>[    0.000000] SRAT: Node 0 PXM 0 [mem 0x00000000-0x7fffffff]
<6>[    0.000000] SRAT: Node 0 PXM 0 [mem 0x100000000-0x87fffffff]
<6>[    0.000000] SRAT: Node 1 PXM 1 [mem 0x880000000-0x107fffffff]
<6>[    0.000000] SRAT: Node 2 PXM 2 [mem 0x1080000000-0x187fffffff]
<6>[    0.000000] SRAT: Node 3 PXM 3 [mem 0x1880000000-0x207fffffff]
<6>[    0.000000] SRAT: Node 0 PXM 0 [mem 0x2100000000-0x40ffffffff] hotplug
<6>[    0.000000] SRAT: Node 0 PXM 0 [mem 0x4100000000-0x60ffffffff] hotplug
<6>[    0.000000] SRAT: Node 1 PXM 1 [mem 0x6100000000-0x80ffffffff] hotplug
<6>[    0.000000] SRAT: Node 1 PXM 1 [mem 0x8100000000-0xa0ffffffff] hotplug
<6>[    0.000000] SRAT: Node 2 PXM 2 [mem 0xa100000000-0xc0ffffffff] hotplug
<6>[    0.000000] SRAT: Node 2 PXM 2 [mem 0xc100000000-0xe0ffffffff] hotplug
<6>[    0.000000] SRAT: Node 3 PXM 3 [mem 0xe100000000-0x100ffffffff] hotplug
<6>[    0.000000] SRAT: Node 3 PXM 3 [mem 0x10100000000-0x120ffffffff] hotplug
<7>[    0.000000] NUMA: Initialized distance table, cnt=4
<6>[    0.000000] NUMA: Node 0 [mem 0x00000000-0x7fffffff] + [mem 0x100000000-0x87fffffff] -> [mem 0x00000000-0x87fffffff]
<6>[    0.000000] Initmem setup node 0 [mem 0x00000000-0x87fffffff]
<6>[    0.000000]   NODE_DATA [mem 0x87fffb000-0x87fffffff]
<6>[    0.000000] Initmem setup node 1 [mem 0x880000000-0x107fffffff]
<6>[    0.000000]   NODE_DATA [mem 0x107fffb000-0x107fffffff]
<6>[    0.000000] Initmem setup node 2 [mem 0x1080000000-0x187fffffff]
<6>[    0.000000]   NODE_DATA [mem 0x187fffb000-0x187fffffff]
<6>[    0.000000] Initmem setup node 3 [mem 0x1880000000-0x207fffffff]
<6>[    0.000000]   NODE_DATA [mem 0x207fff8000-0x207fffcfff]
<7>[    0.000000]  [ffffea0000000000-ffffea0021ffffff] PMD -> [ffff88085fe00000-ffff88087fdfffff] on node 0
<7>[    0.000000]  [ffffea0022000000-ffffea0041ffffff] PMD -> [ffff88105fe00000-ffff88107fdfffff] on node 1
<7>[    0.000000]  [ffffea0042000000-ffffea0061ffffff] PMD -> [ffff88185fe00000-ffff88187fdfffff] on node 2
<7>[    0.000000]  [ffffea0062000000-ffffea0081ffffff] PMD -> [ffff88205f600000-ffff88207f5fffff] on node 3
<4>[    0.000000] Zone ranges:
<4>[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
<4>[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
<4>[    0.000000]   Normal   [mem 0x100000000-0x207fffffff]
<4>[    0.000000] Movable zone start for each node
<4>[    0.000000] Early memory node ranges
<4>[    0.000000]   node   0: [mem 0x00001000-0x0009afff]
<4>[    0.000000]   node   0: [mem 0x00100000-0x7b43dfff]
<4>[    0.000000]   node   0: [mem 0x100000000-0x87fffffff]
<4>[    0.000000]   node   1: [mem 0x880000000-0x107fffffff]
<4>[    0.000000]   node   2: [mem 0x1080000000-0x187fffffff]
<4>[    0.000000]   node   3: [mem 0x1880000000-0x207fffffff]
<7>[    0.000000] On node 0 totalpages: 8369112
<7>[    0.000000]   DMA zone: 64 pages used for memmap
<7>[    0.000000]   DMA zone: 21 pages reserved
<7>[    0.000000]   DMA zone: 3994 pages, LIFO batch:0
<7>[    0.000000]   DMA32 zone: 7825 pages used for memmap
<7>[    0.000000]   DMA32 zone: 500798 pages, LIFO batch:31
<7>[    0.000000]   Normal zone: 122880 pages used for memmap
<7>[    0.000000]   Normal zone: 7864320 pages, LIFO batch:31
<7>[    0.000000] On node 1 totalpages: 8388608
<7>[    0.000000]   Normal zone: 131072 pages used for memmap
<7>[    0.000000]   Normal zone: 8388608 pages, LIFO batch:31
<7>[    0.000000] On node 2 totalpages: 8388608
<7>[    0.000000]   Normal zone: 131072 pages used for memmap
<7>[    0.000000]   Normal zone: 8388608 pages, LIFO batch:31
<7>[    0.000000] On node 3 totalpages: 8388608
<7>[    0.000000]   Normal zone: 131072 pages used for memmap
<7>[    0.000000]   Normal zone: 8388608 pages, LIFO batch:31
<6>[    0.000000] ACPI: PM-Timer IO Port: 0x408
<7>[    0.000000] ACPI: Local APIC address 0xfee00000
<4>[    0.000000] mapped APIC to ffffffffff5f3000 (        fee00000)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x28] lapic_id[0x80] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x14] lapic_id[0x40] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x3c] lapic_id[0xc0] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x0a] lapic_id[0x20] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x32] lapic_id[0xa0] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x1e] lapic_id[0x60] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x46] lapic_id[0xe0] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x06] lapic_id[0x10] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x2e] lapic_id[0x90] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x1a] lapic_id[0x50] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x42] lapic_id[0xd0] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x10] lapic_id[0x30] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x38] lapic_id[0xb0] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x24] lapic_id[0x70] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x4c] lapic_id[0xf0] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x2a] lapic_id[0x82] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x16] lapic_id[0x42] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x3e] lapic_id[0xc2] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x0c] lapic_id[0x22] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x34] lapic_id[0xa2] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x20] lapic_id[0x62] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x48] lapic_id[0xe2] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x08] lapic_id[0x12] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x30] lapic_id[0x92] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x1c] lapic_id[0x52] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x44] lapic_id[0xd2] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x12] lapic_id[0x32] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x3a] lapic_id[0xb2] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x26] lapic_id[0x72] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x4e] lapic_id[0xf2] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x29] lapic_id[0x81] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x15] lapic_id[0x41] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x3d] lapic_id[0xc1] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x0b] lapic_id[0x21] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x33] lapic_id[0xa1] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x1f] lapic_id[0x61] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x47] lapic_id[0xe1] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x07] lapic_id[0x11] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x2f] lapic_id[0x91] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x1b] lapic_id[0x51] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x43] lapic_id[0xd1] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x11] lapic_id[0x31] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x39] lapic_id[0xb1] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x25] lapic_id[0x71] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x4d] lapic_id[0xf1] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x03] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x2b] lapic_id[0x83] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x17] lapic_id[0x43] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x3f] lapic_id[0xc3] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x0d] lapic_id[0x23] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x35] lapic_id[0xa3] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x21] lapic_id[0x63] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x49] lapic_id[0xe3] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x09] lapic_id[0x13] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x31] lapic_id[0x93] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x1d] lapic_id[0x53] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x45] lapic_id[0xd3] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x13] lapic_id[0x33] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x3b] lapic_id[0xb3] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x27] lapic_id[0x73] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x4f] lapic_id[0xf3] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x04] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x2c] lapic_id[0x84] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x18] lapic_id[0x44] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x40] lapic_id[0xc4] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x0e] lapic_id[0x24] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x36] lapic_id[0xa4] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x22] lapic_id[0x64] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x4a] lapic_id[0xe4] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x05] lapic_id[0x05] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x2d] lapic_id[0x85] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x19] lapic_id[0x45] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x41] lapic_id[0xc5] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x0f] lapic_id[0x25] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x37] lapic_id[0xa5] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x23] lapic_id[0x65] enabled)
<6>[    0.000000] ACPI: LAPIC (acpi_id[0x4b] lapic_id[0xe5] enabled)
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x02] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x03] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x04] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x05] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x06] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x07] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x08] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x09] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0a] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0b] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0c] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0d] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0e] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0f] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x10] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x11] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x12] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x13] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x14] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x15] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x16] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x17] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x18] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x19] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1a] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1b] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1c] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1d] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1e] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x1f] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x20] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x21] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x22] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x23] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x24] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x25] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x26] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x27] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x28] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x29] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x2a] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x2b] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x2c] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x2d] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x2e] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x2f] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x30] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x31] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x32] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x33] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x34] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x35] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x36] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x37] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x38] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x39] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x3a] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x3b] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x3c] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x3d] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x3e] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x3f] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x40] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x41] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x42] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x43] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x44] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x45] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x46] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x47] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x48] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x49] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x4a] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x4b] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x4c] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x4d] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x4e] high level lint[0x1])
<6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x4f] high level lint[0x1])
<6>[    0.000000] ACPI: IOAPIC (id[0x08] address[0xfec00000] gsi_base[0])
<6>[    0.000000] IOAPIC[0]: apic_id 8, version 32, address 0xfec00000, GSI 0-23
<6>[    0.000000] ACPI: IOAPIC (id[0x09] address[0xfec01000] gsi_base[24])
<6>[    0.000000] IOAPIC[1]: apic_id 9, version 32, address 0xfec01000, GSI 24-47
<6>[    0.000000] ACPI: IOAPIC (id[0x0a] address[0xfec04000] gsi_base[48])
<6>[    0.000000] IOAPIC[2]: apic_id 10, version 32, address 0xfec04000, GSI 48-71
<6>[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
<4>[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 8, APIC INT 02
<6>[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
<4>[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 8, APIC INT 09
<7>[    0.000000] ACPI: IRQ0 used by override.
<4>[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 8, APIC INT 01
<7>[    0.000000] ACPI: IRQ2 used by override.
<4>[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 8, APIC INT 03
<4>[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 8, APIC INT 04
<4>[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 05, APIC ID 8, APIC INT 05
<4>[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 8, APIC INT 06
<4>[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 8, APIC INT 07
<4>[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 8, APIC INT 08
<7>[    0.000000] ACPI: IRQ9 used by override.
<4>[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0a, APIC ID 8, APIC INT 0a
<4>[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0b, APIC ID 8, APIC INT 0b
<4>[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 8, APIC INT 0c
<4>[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 8, APIC INT 0d
<4>[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 8, APIC INT 0e
<4>[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 8, APIC INT 0f
<6>[    0.000000] Using ACPI (MADT) for SMP configuration information
<6>[    0.000000] ACPI: HPET id: 0x8086a401 base: 0xfed00000
<6>[    0.000000] smpboot: Allowing 80 CPUs, 0 hotplug CPUs
<4>[    0.000000] mapped IOAPIC to ffffffffff5f2000 (fec00000)
<4>[    0.000000] mapped IOAPIC to ffffffffff5f1000 (fec01000)
<4>[    0.000000] mapped IOAPIC to ffffffffff5f0000 (fec04000)
<7>[    0.000000] nr_irqs_gsi: 88
<6>[    0.000000] PM: Registered nosave memory: [mem 0x0009b000-0x0009bfff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x0009c000-0x0009ffff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000dffff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x000e0000-0x000fffff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x7b43e000-0x7b440fff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x7b441000-0x7b67cfff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x7b67d000-0x7b68bfff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x7b68c000-0x7b68efff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x7b68f000-0x7b693fff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x7b694000-0x7b7bcfff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x7b7bd000-0x7ba3cfff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x7ba3d000-0x7baa7fff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x7baa8000-0x7bcfffff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x7bd00000-0x7bd16fff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x7bd17000-0x7bd19fff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x7bd1a000-0x7bd49fff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x7bd4a000-0x7bd5efff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x7bd5f000-0x7bdfefff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x7bdff000-0x7bdfffff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x7be00000-0x7be4efff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x7be4f000-0x7bf70fff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x7bf71000-0x7bfcefff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x7bfcf000-0x7bffefff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x7bfff000-0x8fffffff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x90000000-0xfbffffff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0xfc000000-0xfcffffff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0xfd000000-0xfed1bfff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0xfed1c000-0xfed1ffff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0xfed20000-0xfeffffff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0xff000000-0xffffffff]
<6>[    0.000000] e820: [mem 0x90000000-0xfbffffff] available for PCI devices
<6>[    0.000000] Booting paravirtualized kernel on bare hardware
<6>[    0.000000] setup_percpu: NR_CPUS:512 nr_cpumask_bits:512 nr_cpu_ids:80 nr_node_ids:4
<6>[    0.000000] PERCPU: Embedded 27 pages/cpu @ffff88085f800000 s81088 r8192 d21312 u262144
<7>[    0.000000] pcpu-alloc: s81088 r8192 d21312 u262144 alloc=1*2097152
<7>[    0.000000] pcpu-alloc: [0] 00 04 08 12 16 20 24 28 [0] 32 36 40 44 48 52 56 60 
<7>[    0.000000] pcpu-alloc: [0] 64 68 72 76 -- -- -- -- [1] 01 05 09 13 17 21 25 29 
<7>[    0.000000] pcpu-alloc: [1] 33 37 41 45 49 53 57 61 [1] 65 69 73 77 -- -- -- -- 
<7>[    0.000000] pcpu-alloc: [2] 02 06 10 14 18 22 26 30 [2] 34 38 42 46 50 54 58 62 
<7>[    0.000000] pcpu-alloc: [2] 66 70 74 78 -- -- -- -- [3] 03 07 11 15 19 23 27 31 
<7>[    0.000000] pcpu-alloc: [3] 35 39 43 47 51 55 59 63 [3] 67 71 75 79 -- -- -- -- 
<4>[    0.000000] Built 4 zonelists in Zone order, mobility grouping on.  Total pages: 33010930
<4>[    0.000000] Policy zone: Normal
<5>[    0.000000] Kernel command line: BOOT_IMAGE=/kernel/x86_64-lkp/8808b950581f71e3ee4cf8e6cae479f4c7106405/vmlinuz-3.14.0-rc6-next-20140317 user=lkp job=/lkp/scheduled/lkp-wsx02/cyclic_netperf-power-120s-25%-SCTP_STREAM_MANY-HEAD-8808b950581f71e3ee4cf8e6cae479f4c7106405.yaml ARCH=x86_64 BOOT_IMAGE=/kernel/x86_64-lkp/8808b950581f71e3ee4cf8e6cae479f4c7106405/vmlinuz-3.14.0-rc6-next-20140317 kconfig=x86_64-lkp commit=8808b950581f71e3ee4cf8e6cae479f4c7106405 max_uptime=996 RESULT_ROOT=/lkp/result/lkp-wsx02/micro/netperf/120s-25%-SCTP_STREAM_MANY/x86_64-lkp/8808b950581f71e3ee4cf8e6cae479f4c7106405/0 root=/dev/ram0 ip=::::lkp-wsx02::dhcp oops=panic earlyprintk=ttyS0,115200 debug apic=debug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=100 panic=10 softlockup_panic=1 nmi_watchdog=panic load_ramdisk=2 prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal
<6>[    0.000000] sysrq: sysrq always enabled.
<6>[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
<6>[    0.000000] Checking aperture...
<6>[    0.000000] No AGP bridge found
<4>[    0.000000] Memory: 131731224K/134139744K available (10556K kernel code, 1268K rwdata, 4292K rodata, 1436K init, 1760K bss, 2408520K reserved)
<6>[    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=80, Nodes=4
<6>[    0.000000] Hierarchical RCU implementation.
<6>[    0.000000] 	RCU dyntick-idle grace-period acceleration is enabled.
<6>[    0.000000] 	RCU restricting CPUs from NR_CPUS=512 to nr_cpu_ids=80.
<6>[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=80
<6>[    0.000000] NR_IRQS:33024 nr_irqs:2136 16
<6>[    0.000000] Console: colour VGA+ 80x25
<6>[    0.000000] console [tty0] enabled
<6>[    0.000000] bootconsole [earlyser0] disabled
<6>[    0.000000] console [ttyS0] enabled
<6>[    0.000000] allocated 536870912 bytes of page_cgroup
<6>[    0.000000] please try 'cgroup_disable=memory' option if you don't want memory cgroups
<6>[    0.000000] Disabling automatic NUMA balancing. Configure with numa_balancing= or the kernel.numa_balancing sysctl
<7>[    0.000000] hpet clockevent registered
<6>[    0.000000] tsc: Fast TSC calibration using PIT
<6>[    0.000000] tsc: Detected 2394.281 MHz processor
<6>[    0.000042] Calibrating delay loop (skipped), value calculated using timer frequency.. 4788.56 BogoMIPS (lpj=9577124)
<6>[    0.012311] pid_max: default: 81920 minimum: 640
<6>[    0.017689] ACPI: Core revision 20140214
<4>[    0.108793] ACPI: All ACPI Tables successfully acquired
<6>[    0.126760] Dentry cache hash table entries: 16777216 (order: 15, 134217728 bytes)
<6>[    0.175568] Inode-cache hash table entries: 8388608 (order: 14, 67108864 bytes)
<6>[    0.201651] Mount-cache hash table entries: 256
<6>[    0.207817] Initializing cgroup subsys memory
<6>[    0.213232] Initializing cgroup subsys devices
<6>[    0.218799] Initializing cgroup subsys freezer
<6>[    0.224280] Initializing cgroup subsys blkio
<6>[    0.229559] Initializing cgroup subsys perf_event
<6>[    0.235437] Initializing cgroup subsys hugetlb
<6>[    0.241103] CPU: Physical Processor ID: 0
<6>[    0.246098] CPU: Processor Core ID: 0
<6>[    0.250784] mce: CPU supports 24 MCE banks
<6>[    0.255911] CPU0: Thermal monitoring enabled (TM1)
<6>[    0.261819] Last level iTLB entries: 4KB 512, 2MB 7, 4MB 7
<6>[    0.261819] Last level dTLB entries: 4KB 512, 2MB 32, 4MB 32, 1GB 0
<6>[    0.261819] tlb_flushall_shift: 6
<6>[    0.280249] Freeing SMP alternatives memory: 44K (ffffffff824a6000 - ffffffff824b1000)
<6>[    0.292202] ftrace: allocating 40687 entries in 159 pages
<4>[    0.326147] Getting VERSION: 1060015
<4>[    0.330732] Getting VERSION: 1060015
<4>[    0.335225] Getting ID: 0
<4>[    0.338541] Getting ID: 0
<6>[    0.342094] Switched APIC routing to physical flat.
<4>[    0.348101] enabled ExtINT on CPU#0
<4>[    0.353071] ENABLING IO-APIC IRQs
<7>[    0.357282] init IO_APIC IRQs
<7>[    0.361107]  apic 8 pin 0 not connected
<7>[    0.365908] IOAPIC[0]: Set routing entry (8-1 -> 0x31 -> IRQ 1 Mode:0 Active:0 Dest:0)
<7>[    0.375734] IOAPIC[0]: Set routing entry (8-2 -> 0x30 -> IRQ 0 Mode:0 Active:0 Dest:0)
<7>[    0.385475] IOAPIC[0]: Set routing entry (8-3 -> 0x33 -> IRQ 3 Mode:0 Active:0 Dest:0)
<7>[    0.395030] IOAPIC[0]: Set routing entry (8-4 -> 0x34 -> IRQ 4 Mode:0 Active:0 Dest:0)
<7>[    0.404616] IOAPIC[0]: Set routing entry (8-5 -> 0x35 -> IRQ 5 Mode:0 Active:0 Dest:0)
<7>[    0.414199] IOAPIC[0]: Set routing entry (8-6 -> 0x36 -> IRQ 6 Mode:0 Active:0 Dest:0)
<7>[    0.423778] IOAPIC[0]: Set routing entry (8-7 -> 0x37 -> IRQ 7 Mode:0 Active:0 Dest:0)
<7>[    0.433346] IOAPIC[0]: Set routing entry (8-8 -> 0x38 -> IRQ 8 Mode:0 Active:0 Dest:0)
<7>[    0.442905] IOAPIC[0]: Set routing entry (8-9 -> 0x39 -> IRQ 9 Mode:1 Active:0 Dest:0)
<7>[    0.452460] IOAPIC[0]: Set routing entry (8-10 -> 0x3a -> IRQ 10 Mode:0 Active:0 Dest:0)
<7>[    0.462225] IOAPIC[0]: Set routing entry (8-11 -> 0x3b -> IRQ 11 Mode:0 Active:0 Dest:0)
<7>[    0.472001] IOAPIC[0]: Set routing entry (8-12 -> 0x3c -> IRQ 12 Mode:0 Active:0 Dest:0)
<7>[    0.481760] IOAPIC[0]: Set routing entry (8-13 -> 0x3d -> IRQ 13 Mode:0 Active:0 Dest:0)
<7>[    0.491525] IOAPIC[0]: Set routing entry (8-14 -> 0x3e -> IRQ 14 Mode:0 Active:0 Dest:0)
<7>[    0.501285] IOAPIC[0]: Set routing entry (8-15 -> 0x3f -> IRQ 15 Mode:0 Active:0 Dest:0)
<7>[    0.511054]  apic 8 pin 16 not connected
<7>[    0.515817]  apic 8 pin 17 not connected
<7>[    0.520586]  apic 8 pin 18 not connected
<7>[    0.525363]  apic 8 pin 19 not connected
<7>[    0.530140]  apic 8 pin 20 not connected
<7>[    0.534916]  apic 8 pin 21 not connected
<7>[    0.539693]  apic 8 pin 22 not connected
<7>[    0.544466]  apic 8 pin 23 not connected
<7>[    0.549243]  apic 9 pin 0 not connected
<7>[    0.553911]  apic 9 pin 1 not connected
<7>[    0.558577]  apic 9 pin 2 not connected
<7>[    0.563243]  apic 9 pin 3 not connected
<7>[    0.567916]  apic 9 pin 4 not connected
<7>[    0.572585]  apic 9 pin 5 not connected
<7>[    0.577243]  apic 9 pin 6 not connected
<7>[    0.581923]  apic 9 pin 7 not connected
<7>[    0.586602]  apic 9 pin 8 not connected
<7>[    0.591280]  apic 9 pin 9 not connected
<7>[    0.595956]  apic 9 pin 10 not connected
<7>[    0.600730]  apic 9 pin 11 not connected
<7>[    0.605500]  apic 9 pin 12 not connected
<7>[    0.610273]  apic 9 pin 13 not connected
<7>[    0.615037]  apic 9 pin 14 not connected
<7>[    0.619803]  apic 9 pin 15 not connected
<7>[    0.624576]  apic 9 pin 16 not connected
<7>[    0.629342]  apic 9 pin 17 not connected
<7>[    0.634109]  apic 9 pin 18 not connected
<7>[    0.638880]  apic 9 pin 19 not connected
<7>[    0.643658]  apic 9 pin 20 not connected
<7>[    0.648434]  apic 9 pin 21 not connected
<7>[    0.653210]  apic 9 pin 22 not connected
<7>[    0.657983]  apic 9 pin 23 not connected
<7>[    0.662756]  apic 10 pin 0 not connected
<7>[    0.667532]  apic 10 pin 1 not connected
<7>[    0.672300]  apic 10 pin 2 not connected
<7>[    0.677067]  apic 10 pin 3 not connected
<7>[    0.681846]  apic 10 pin 4 not connected
<7>[    0.686609]  apic 10 pin 5 not connected
<7>[    0.691374]  apic 10 pin 6 not connected
<7>[    0.696145]  apic 10 pin 7 not connected
<7>[    0.700913]  apic 10 pin 8 not connected
<7>[    0.705689]  apic 10 pin 9 not connected
<7>[    0.710466]  apic 10 pin 10 not connected
<7>[    0.715339]  apic 10 pin 11 not connected
<7>[    0.720211]  apic 10 pin 12 not connected
<7>[    0.725084]  apic 10 pin 13 not connected
<7>[    0.729954]  apic 10 pin 14 not connected
<7>[    0.734819]  apic 10 pin 15 not connected
<7>[    0.739694]  apic 10 pin 16 not connected
<7>[    0.744554]  apic 10 pin 17 not connected
<7>[    0.749418]  apic 10 pin 18 not connected
<7>[    0.754293]  apic 10 pin 19 not connected
<7>[    0.759156]  apic 10 pin 20 not connected
<7>[    0.764020]  apic 10 pin 21 not connected
<7>[    0.768896]  apic 10 pin 22 not connected
<7>[    0.773760]  apic 10 pin 23 not connected
<6>[    0.778765] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
<6>[    0.825589] smpboot: CPU0: Intel(R) Xeon(R) CPU E7- 8870  @ 2.40GHz (fam: 06, model: 2f, stepping: 02)
<4>[    0.836935] Using local APIC timer interrupts.
<4>[    0.836935] calibrating APIC timer ...
<4>[    0.950976] ... lapic delta = 831240
<4>[    0.955352] ... PM-Timer delta = 357950
<4>[    0.960026] ... PM-Timer result ok
<4>[    0.964216] ..... delta 831240
<4>[    0.968009] ..... mult: 35701486
<4>[    0.971994] ..... calibration result: 531993
<4>[    0.977160] ..... CPU clock speed is 2393.3878 MHz.
<4>[    0.983006] ..... host bus clock speed is 132.3993 MHz.
<6>[    0.989256] Performance Events: PEBS fmt1+, 16-deep LBR, Westmere events, Intel PMU driver.
<4>[    0.999593] perf_event_intel: CPUID marked event: 'bus cycles' unavailable
<6>[    1.007674] ... version:                3
<6>[    1.012537] ... bit width:              48
<6>[    1.017505] ... generic registers:      4
<6>[    1.022379] ... value mask:             0000ffffffffffff
<6>[    1.028707] ... max period:             000000007fffffff
<6>[    1.035035] ... fixed-purpose events:   3
<6>[    1.039907] ... event mask:             000000070000000f
<6>[    1.049647] x86: Booting SMP configuration:
<6>[    1.054722] .... node  #2, CPUs:        #1
<4>[    1.071838] masked ExtINT on CPU#1
<4>[    1.173617] 
<6>[    1.175669] .... node  #1, CPUs:    #2
<4>[    1.192293] masked ExtINT on CPU#2
<4>[    1.293655] 
<6>[    1.295705] .... node  #3, CPUs:    #3
<4>[    1.312335] masked ExtINT on CPU#3
<4>[    1.413750] 
<6>[    1.415797] .... node  #0, CPUs:    #4
<4>[    1.432410] masked ExtINT on CPU#4
<4>[    1.438758] 
<6>[    1.440811] .... node  #2, CPUs:    #5
<4>[    1.457427] masked ExtINT on CPU#5
<4>[    1.463691] 
<6>[    1.465740] .... node  #1, CPUs:    #6
<4>[    1.482377] masked ExtINT on CPU#6
<4>[    1.488618] 
<6>[    1.490672] .... node  #3, CPUs:    #7
<4>[    1.507298] masked ExtINT on CPU#7
<4>[    1.513542] 
<6>[    1.515591] .... node  #0, CPUs:    #8
<4>[    1.532203] masked ExtINT on CPU#8
<4>[    1.538554] 
<6>[    1.540598] .... node  #2, CPUs:    #9
<4>[    1.557215] masked ExtINT on CPU#9
<4>[    1.563470] 
<6>[    1.565515] .... node  #1, CPUs:   #10
<4>[    1.582133] masked ExtINT on CPU#10
<4>[    1.588499] 
<6>[    1.590550] .... node  #3, CPUs:   #11
<4>[    1.607165] masked ExtINT on CPU#11
<4>[    1.613514] 
<6>[    1.615563] .... node  #0, CPUs:   #12
<4>[    1.632176] masked ExtINT on CPU#12
<4>[    1.638639] 
<6>[    1.640697] .... node  #2, CPUs:   #13
<4>[    1.657333] masked ExtINT on CPU#13
<4>[    1.663665] 
<6>[    1.665720] .... node  #1, CPUs:   #14
<4>[    1.682353] masked ExtINT on CPU#14
<4>[    1.688704] 
<6>[    1.690757] .... node  #3, CPUs:   #15
<4>[    1.707374] masked ExtINT on CPU#15
<4>[    1.713718] 
<6>[    1.715768] .... node  #0, CPUs:   #16
<4>[    1.732382] masked ExtINT on CPU#16
<4>[    1.738822] 
<6>[    1.740875] .... node  #2, CPUs:   #17
<4>[    1.757490] masked ExtINT on CPU#17
<4>[    1.763844] 
<6>[    1.765897] .... node  #1, CPUs:   #18
<4>[    1.782513] masked ExtINT on CPU#18
<4>[    1.788882] 
<6>[    1.790933] .... node  #3, CPUs:   #19
<4>[    1.807547] masked ExtINT on CPU#19
<4>[    1.813879] 
<6>[    1.815919] .... node  #0, CPUs:   #20
<4>[    1.832533] masked ExtINT on CPU#20
<4>[    1.838982] 
<6>[    1.841027] .... node  #2, CPUs:   #21
<4>[    1.857644] masked ExtINT on CPU#21
<4>[    1.864012] 
<6>[    1.866053] .... node  #1, CPUs:   #22
<4>[    1.882669] masked ExtINT on CPU#22
<4>[    1.889046] 
<6>[    1.891099] .... node  #3, CPUs:   #23
<4>[    1.907716] masked ExtINT on CPU#23
<4>[    1.914060] 
<6>[    1.916113] .... node  #0, CPUs:   #24
<4>[    1.932727] masked ExtINT on CPU#24
<4>[    1.939171] 
<6>[    1.941219] .... node  #2, CPUs:   #25
<4>[    1.957836] masked ExtINT on CPU#25
<4>[    1.964183] 
<6>[    1.966230] .... node  #1, CPUs:   #26
<4>[    1.982845] masked ExtINT on CPU#26
<4>[    1.989212] 
<6>[    1.991267] .... node  #3, CPUs:   #27
<4>[    2.007884] masked ExtINT on CPU#27
<4>[    2.014230] 
<6>[    2.016273] .... node  #0, CPUs:   #28
<4>[    2.032886] masked ExtINT on CPU#28
<4>[    2.039339] 
<6>[    2.041392] .... node  #2, CPUs:   #29
<4>[    2.058007] masked ExtINT on CPU#29
<4>[    2.064369] 
<6>[    2.066422] .... node  #1, CPUs:   #30
<4>[    2.083035] masked ExtINT on CPU#30
<4>[    2.089400] 
<6>[    2.091452] .... node  #3, CPUs:   #31
<4>[    2.108066] masked ExtINT on CPU#31
<4>[    2.114400] 
<6>[    2.116451] .... node  #0, CPUs:   #32
<4>[    2.133284] masked ExtINT on CPU#32
<4>[    2.139782] 
<6>[    2.141826] .... node  #2, CPUs:   #33
<4>[    2.158446] masked ExtINT on CPU#33
<4>[    2.164797] 
<6>[    2.166843] .... node  #1, CPUs:   #34
<4>[    2.183457] masked ExtINT on CPU#34
<4>[    2.189828] 
<6>[    2.191881] .... node  #3, CPUs:   #35
<4>[    2.208497] masked ExtINT on CPU#35
<4>[    2.214843] 
<6>[    2.216888] .... node  #0, CPUs:   #36
<4>[    2.233499] masked ExtINT on CPU#36
<4>[    2.239946] 
<6>[    2.241988] .... node  #2, CPUs:   #37
<4>[    2.258602] masked ExtINT on CPU#37
<4>[    2.264963] 
<6>[    2.267011] .... node  #1, CPUs:   #38
<4>[    2.283626] masked ExtINT on CPU#38
<4>[    2.289998] 
<6>[    2.292050] .... node  #3, CPUs:   #39
<4>[    2.308666] masked ExtINT on CPU#39
<4>[    2.315016] 
<6>[    2.317068] .... node  #0, CPUs:   #40
<4>[    2.333682] masked ExtINT on CPU#40
<4>[    2.340130] 
<6>[    2.342188] .... node  #2, CPUs:   #41
<4>[    2.358804] masked ExtINT on CPU#41
<4>[    2.365168] 
<6>[    2.367221] .... node  #1, CPUs:   #42
<4>[    2.383836] masked ExtINT on CPU#42
<4>[    2.390213] 
<6>[    2.392262] .... node  #3, CPUs:   #43
<4>[    2.408877] masked ExtINT on CPU#43
<4>[    2.415223] 
<6>[    2.417272] .... node  #0, CPUs:   #44
<4>[    2.433884] masked ExtINT on CPU#44
<4>[    2.440352] 
<6>[    2.450492] .... node  #2, CPUs:   #45
<4>[    2.467103] masked ExtINT on CPU#45
<4>[    2.473455] 
<6>[    2.475499] .... node  #1, CPUs:   #46
<4>[    2.492114] masked ExtINT on CPU#46
<4>[    2.498473] 
<6>[    2.500526] .... node  #3, CPUs:   #47
<4>[    2.517144] masked ExtINT on CPU#47
<4>[    2.523489] 
<6>[    2.525530] .... node  #0, CPUs:   #48
<4>[    2.542142] masked ExtINT on CPU#48
<4>[    2.548609] 
<6>[    2.550669] .... node  #2, CPUs:   #49
<4>[    2.567273] masked ExtINT on CPU#49
<4>[    2.573629] 
<6>[    2.575676] .... node  #1, CPUs:   #50
<4>[    2.592291] masked ExtINT on CPU#50
<4>[    2.598678] 
<6>[    2.600731] .... node  #3, CPUs:   #51
<4>[    2.617347] masked ExtINT on CPU#51
<4>[    2.623683] 
<6>[    2.625730] .... node  #0, CPUs:   #52
<4>[    2.642341] masked ExtINT on CPU#52
<4>[    2.648801] 
<6>[    2.650863] .... node  #2, CPUs:   #53
<4>[    2.667476] masked ExtINT on CPU#53
<4>[    2.673833] 
<6>[    2.675890] .... node  #1, CPUs:   #54
<4>[    2.692507] masked ExtINT on CPU#54
<4>[    2.698866] 
<6>[    2.700919] .... node  #3, CPUs:   #55
<4>[    2.717533] masked ExtINT on CPU#55
<4>[    2.723890] 
<6>[    2.725938] .... node  #0, CPUs:   #56
<4>[    2.742550] masked ExtINT on CPU#56
<4>[    2.749010] 
<6>[    2.751069] .... node  #2, CPUs:   #57
<4>[    2.767685] masked ExtINT on CPU#57
<4>[    2.774043] 
<6>[    2.776094] .... node  #1, CPUs:   #58
<4>[    2.792711] masked ExtINT on CPU#58
<4>[    2.799080] 
<6>[    2.801131] .... node  #3, CPUs:   #59
<4>[    2.817745] masked ExtINT on CPU#59
<4>[    2.824098] 
<6>[    2.826151] .... node  #0, CPUs:   #60
<4>[    2.842762] masked ExtINT on CPU#60
<4>[    2.849222] 
<6>[    2.851277] .... node  #2, CPUs:   #61
<4>[    2.867890] masked ExtINT on CPU#61
<4>[    2.874252] 
<6>[    2.876294] .... node  #1, CPUs:   #62
<4>[    2.892908] masked ExtINT on CPU#62
<4>[    2.899276] 
<6>[    2.901327] .... node  #3, CPUs:   #63
<4>[    2.917940] masked ExtINT on CPU#63
<4>[    2.924290] 
<6>[    2.926338] .... node  #0, CPUs:   #64
<4>[    2.942954] masked ExtINT on CPU#64
<4>[    2.949408] 
<6>[    2.951467] .... node  #2, CPUs:   #65
<4>[    2.968081] masked ExtINT on CPU#65
<4>[    2.974450] 
<6>[    2.976502] .... node  #1, CPUs:   #66
<4>[    2.993117] masked ExtINT on CPU#66
<4>[    2.999500] 
<6>[    3.001555] .... node  #3, CPUs:   #67
<4>[    3.018168] masked ExtINT on CPU#67
<4>[    3.024536] 
<6>[    3.026593] .... node  #0, CPUs:   #68
<4>[    3.043207] masked ExtINT on CPU#68
<4>[    3.049672] 
<6>[    3.051730] .... node  #2, CPUs:   #69
<4>[    3.068345] masked ExtINT on CPU#69
<4>[    3.074707] 
<6>[    3.076755] .... node  #1, CPUs:   #70
<4>[    3.093368] masked ExtINT on CPU#70
<4>[    3.099740] 
<6>[    3.101794] .... node  #3, CPUs:   #71
<4>[    3.118407] masked ExtINT on CPU#71
<4>[    3.124764] 
<6>[    3.126810] .... node  #0, CPUs:   #72
<4>[    3.143423] masked ExtINT on CPU#72
<4>[    3.149885] 
<6>[    3.151942] .... node  #2, CPUs:   #73
<4>[    3.168557] masked ExtINT on CPU#73
<4>[    3.174916] 
<6>[    3.176959] .... node  #1, CPUs:   #74
<4>[    3.193573] masked ExtINT on CPU#74
<4>[    3.199960] 
<6>[    3.202012] .... node  #3, CPUs:   #75
<4>[    3.218625] masked ExtINT on CPU#75
<4>[    3.224975] 
<6>[    3.227026] .... node  #0, CPUs:   #76
<4>[    3.243636] masked ExtINT on CPU#76
<4>[    3.250115] 
<6>[    3.252178] .... node  #2, CPUs:   #77
<4>[    3.268792] masked ExtINT on CPU#77
<4>[    3.275149] 
<6>[    3.277201] .... node  #1, CPUs:   #78
<4>[    3.293813] masked ExtINT on CPU#78
<4>[    3.300189] 
<6>[    3.302240] .... node  #3, CPUs:   #79
<4>[    3.318854] masked ExtINT on CPU#79
<6>[    3.325108] x86: Booted up 4 nodes, 80 CPUs
<6>[    3.330507] smpboot: Total of 80 processors activated (383052.54 BogoMIPS)
<6>[    3.828712] devtmpfs: initialized
<6>[    3.860017] PM: Registering ACPI NVS region [mem 0x7b441000-0x7b67cfff] (2342912 bytes)
<6>[    3.869794] PM: Registering ACPI NVS region [mem 0x7b7bd000-0x7ba3cfff] (2621440 bytes)
<6>[    3.879595] PM: Registering ACPI NVS region [mem 0x7bf71000-0x7bfcefff] (385024 bytes)
<6>[    3.891488] xor: measuring software checksum speed
<6>[    3.934969]    prefetch64-sse:  9923.000 MB/sec
<6>[    3.978995]    generic_sse:  8725.000 MB/sec
<6>[    3.984164] xor: using function: prefetch64-sse (9923.000 MB/sec)
<6>[    3.991399] atomic64 test passed for x86-64 platform with CX8 and with SSE
<6>[    3.999637] NET: Registered protocol family 16
<6>[    4.005783] cpuidle: using governor ladder
<6>[    4.010747] cpuidle: using governor menu
<6>[    4.016119] ACPI FADT declares the system doesn't support PCIe ASPM, so disable it
<6>[    4.025289] ACPI: bus type PCI registered
<6>[    4.030151] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
<6>[    4.037829] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0x80000000-0x8fffffff] (base 0x80000000)
<6>[    4.048950] PCI: MMCONFIG at [mem 0x80000000-0x8fffffff] reserved in E820
<6>[    4.072919] PCI: Using configuration type 1 for base access
<4>[    4.159107] raid6: sse2x1    5118 MB/s
<4>[    4.231152] raid6: sse2x2    6194 MB/s
<4>[    4.303187] raid6: sse2x4    7365 MB/s
<4>[    4.307763] raid6: using algorithm sse2x4 (7365 MB/s)
<4>[    4.313805] raid6: using ssse3x2 recovery algorithm
<6>[    4.320053] ACPI: Added _OSI(Module Device)
<6>[    4.325120] ACPI: Added _OSI(Processor Device)
<6>[    4.330479] ACPI: Added _OSI(3.0 _SCP Extensions)
<6>[    4.336122] ACPI: Added _OSI(Processor Aggregator Device)
<6>[    4.456495] ACPI: Interpreter enabled
<4>[    4.460987] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S2_] (20140214/hwxface-580)
<4>[    4.472172] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S3_] (20140214/hwxface-580)
<4>[    4.483355] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S4_] (20140214/hwxface-580)
<6>[    4.494532] ACPI: (supports S0 S1 S5)
<6>[    4.499007] ACPI: Using IOAPIC for interrupt routing
<6>[    4.505024] HEST: Table parsing has been initialized.
<6>[    4.511061] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
<6>[    4.551440] ACPI: PCI Root Bridge [IOH0] (domain 0000 [bus 00-7f])
<6>[    4.558741] acpi PNP0A08:00: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
<6>[    4.568784] acpi PNP0A08:00: _OSC: platform does not support [PCIeHotplug AER]
<6>[    4.577745] acpi PNP0A08:00: _OSC: OS now controls [PME PCIeCapability]
<6>[    4.586052] acpi PNP0A08:00: ignoring host bridge window [mem 0x000c4000-0x000cbfff] (conflicts with Video ROM [mem 0x000c0000-0x000c7fff])
<6>[    4.601101] PCI host bridge to bus 0000:00
<6>[    4.606076] pci_bus 0000:00: root bus resource [bus 00-7f]
<6>[    4.612600] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
<6>[    4.619896] pci_bus 0000:00: root bus resource [io  0x1000-0x9fff]
<6>[    4.627206] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff]
<6>[    4.635287] pci_bus 0000:00: root bus resource [mem 0xfed40000-0xfedfffff]
<6>[    4.643370] pci_bus 0000:00: root bus resource [mem 0x90000000-0xafffffff]
<6>[    4.651458] pci_bus 0000:00: root bus resource [mem 0xfc000000000-0xfc07fffffff]
<7>[    4.660452] pci 0000:00:00.0: [8086:3407] type 00 class 0x060000
<7>[    4.667629] pci 0000:00:00.0: PME# supported from D0 D3hot D3cold
<7>[    4.674973] pci 0000:00:01.0: [8086:3408] type 01 class 0x060400
<7>[    4.682135] pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
<6>[    4.689413] pci 0000:00:01.0: System wakeup disabled by ACPI
<7>[    4.696184] pci 0000:00:02.0: [8086:3409] type 01 class 0x060400
<7>[    4.703351] pci 0000:00:02.0: PME# supported from D0 D3hot D3cold
<6>[    4.710619] pci 0000:00:02.0: System wakeup disabled by ACPI
<7>[    4.717404] pci 0000:00:03.0: [8086:340a] type 01 class 0x060400
<7>[    4.724570] pci 0000:00:03.0: PME# supported from D0 D3hot D3cold
<7>[    4.731902] pci 0000:00:05.0: [8086:340c] type 01 class 0x060400
<7>[    4.739066] pci 0000:00:05.0: PME# supported from D0 D3hot D3cold
<6>[    4.746345] pci 0000:00:05.0: System wakeup disabled by ACPI
<7>[    4.753139] pci 0000:00:07.0: [8086:340e] type 01 class 0x060400
<7>[    4.760313] pci 0000:00:07.0: PME# supported from D0 D3hot D3cold
<6>[    4.767597] pci 0000:00:07.0: System wakeup disabled by ACPI
<7>[    4.774383] pci 0000:00:09.0: [8086:3410] type 01 class 0x060400
<7>[    4.781553] pci 0000:00:09.0: PME# supported from D0 D3hot D3cold
<6>[    4.788825] pci 0000:00:09.0: System wakeup disabled by ACPI
<7>[    4.795604] pci 0000:00:0a.0: [8086:3411] type 01 class 0x060400
<7>[    4.802760] pci 0000:00:0a.0: PME# supported from D0 D3hot D3cold
<6>[    4.810031] pci 0000:00:0a.0: System wakeup disabled by ACPI
<7>[    4.816810] pci 0000:00:10.0: [8086:3425] type 00 class 0x080000
<7>[    4.824062] pci 0000:00:10.1: [8086:3426] type 00 class 0x080000
<7>[    4.831308] pci 0000:00:11.0: [8086:3427] type 00 class 0x080000
<7>[    4.838566] pci 0000:00:11.1: [8086:3428] type 00 class 0x080000
<7>[    4.845828] pci 0000:00:13.0: [8086:342d] type 00 class 0x080020
<7>[    4.852955] pci 0000:00:13.0: reg 0x10: [mem 0x95c02000-0x95c02fff]
<7>[    4.860405] pci 0000:00:13.0: PME# supported from D0 D3hot D3cold
<7>[    4.867726] pci 0000:00:14.0: [8086:342e] type 00 class 0x080000
<7>[    4.874988] pci 0000:00:14.1: [8086:3422] type 00 class 0x080000
<7>[    4.882236] pci 0000:00:14.2: [8086:3423] type 00 class 0x080000
<7>[    4.889484] pci 0000:00:14.3: [8086:3438] type 00 class 0x080000
<7>[    4.896727] pci 0000:00:15.0: [8086:342f] type 00 class 0x080020
<7>[    4.903978] pci 0000:00:16.0: [8086:3430] type 00 class 0x088000
<7>[    4.911102] pci 0000:00:16.0: reg 0x10: [mem 0xaff1c000-0xaff1ffff 64bit]
<7>[    4.919254] pci 0000:00:16.1: [8086:3431] type 00 class 0x088000
<7>[    4.926383] pci 0000:00:16.1: reg 0x10: [mem 0xaff18000-0xaff1bfff 64bit]
<7>[    4.934534] pci 0000:00:16.2: [8086:3432] type 00 class 0x088000
<7>[    4.941663] pci 0000:00:16.2: reg 0x10: [mem 0xaff14000-0xaff17fff 64bit]
<7>[    4.949813] pci 0000:00:16.3: [8086:3433] type 00 class 0x088000
<7>[    4.956938] pci 0000:00:16.3: reg 0x10: [mem 0xaff10000-0xaff13fff 64bit]
<7>[    4.965088] pci 0000:00:16.4: [8086:3429] type 00 class 0x088000
<7>[    4.972214] pci 0000:00:16.4: reg 0x10: [mem 0xaff0c000-0xaff0ffff 64bit]
<7>[    4.980357] pci 0000:00:16.5: [8086:342a] type 00 class 0x088000
<7>[    4.987485] pci 0000:00:16.5: reg 0x10: [mem 0xaff08000-0xaff0bfff 64bit]
<7>[    4.995627] pci 0000:00:16.6: [8086:342b] type 00 class 0x088000
<7>[    5.002754] pci 0000:00:16.6: reg 0x10: [mem 0xaff04000-0xaff07fff 64bit]
<7>[    5.010907] pci 0000:00:16.7: [8086:342c] type 00 class 0x088000
<7>[    5.018032] pci 0000:00:16.7: reg 0x10: [mem 0xaff00000-0xaff03fff 64bit]
<7>[    5.026171] pci 0000:00:1a.0: [8086:3a37] type 00 class 0x0c0300
<7>[    5.033324] pci 0000:00:1a.0: reg 0x20: [io  0x60c0-0x60df]
<6>[    5.040060] pci 0000:00:1a.0: System wakeup disabled by ACPI
<7>[    5.046849] pci 0000:00:1a.1: [8086:3a38] type 00 class 0x0c0300
<7>[    5.054002] pci 0000:00:1a.1: reg 0x20: [io  0x60a0-0x60bf]
<6>[    5.060751] pci 0000:00:1a.1: System wakeup disabled by ACPI
<7>[    5.067540] pci 0000:00:1a.2: [8086:3a39] type 00 class 0x0c0300
<7>[    5.074682] pci 0000:00:1a.2: reg 0x20: [io  0x6080-0x609f]
<6>[    5.081420] pci 0000:00:1a.2: System wakeup disabled by ACPI
<7>[    5.088201] pci 0000:00:1a.7: [8086:3a3c] type 00 class 0x0c0320
<7>[    5.095327] pci 0000:00:1a.7: reg 0x10: [mem 0x95c01000-0x95c013ff]
<7>[    5.102805] pci 0000:00:1a.7: PME# supported from D0 D3hot D3cold
<6>[    5.110105] pci 0000:00:1a.7: System wakeup disabled by ACPI
<7>[    5.116895] pci 0000:00:1c.0: [8086:3a40] type 01 class 0x060400
<7>[    5.124083] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
<6>[    5.131364] pci 0000:00:1c.0: System wakeup disabled by ACPI
<7>[    5.138157] pci 0000:00:1c.4: [8086:3a48] type 01 class 0x060400
<7>[    5.145335] pci 0000:00:1c.4: PME# supported from D0 D3hot D3cold
<6>[    5.152618] pci 0000:00:1c.4: System wakeup disabled by ACPI
<7>[    5.159401] pci 0000:00:1d.0: [8086:3a34] type 00 class 0x0c0300
<7>[    5.166546] pci 0000:00:1d.0: reg 0x20: [io  0x6060-0x607f]
<6>[    5.173279] pci 0000:00:1d.0: System wakeup disabled by ACPI
<7>[    5.180060] pci 0000:00:1d.1: [8086:3a35] type 00 class 0x0c0300
<7>[    5.187219] pci 0000:00:1d.1: reg 0x20: [io  0x6040-0x605f]
<6>[    5.193963] pci 0000:00:1d.1: System wakeup disabled by ACPI
<7>[    5.200745] pci 0000:00:1d.2: [8086:3a36] type 00 class 0x0c0300
<7>[    5.207902] pci 0000:00:1d.2: reg 0x20: [io  0x6020-0x603f]
<6>[    5.214649] pci 0000:00:1d.2: System wakeup disabled by ACPI
<7>[    5.221444] pci 0000:00:1d.7: [8086:3a3a] type 00 class 0x0c0320
<7>[    5.228580] pci 0000:00:1d.7: reg 0x10: [mem 0x95c00000-0x95c003ff]
<7>[    5.236063] pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
<6>[    5.243363] pci 0000:00:1d.7: System wakeup disabled by ACPI
<7>[    5.258255] pci 0000:00:1e.0: [8086:244e] type 01 class 0x060401
<6>[    5.265469] pci 0000:00:1e.0: System wakeup disabled by ACPI
<7>[    5.272245] pci 0000:00:1f.0: [8086:3a16] type 00 class 0x060100
<6>[    5.279424] pci 0000:00:1f.0: quirk: [io  0x0400-0x047f] claimed by ICH6 ACPI/GPIO/TCO
<6>[    5.288991] pci 0000:00:1f.0: quirk: [io  0x0500-0x053f] claimed by ICH6 GPIO
<6>[    5.297364] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 1 PIO at 0680 (mask 000f)
<6>[    5.306553] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 2 PIO at 0ca0 (mask 000f)
<6>[    5.315744] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 3 PIO at 0600 (mask 001f)
<7>[    5.325064] pci 0000:00:1f.2: [8086:3a20] type 00 class 0x01018f
<7>[    5.332188] pci 0000:00:1f.2: reg 0x10: [io  0x6138-0x613f]
<7>[    5.338810] pci 0000:00:1f.2: reg 0x14: [io  0x614c-0x614f]
<7>[    5.345431] pci 0000:00:1f.2: reg 0x18: [io  0x6130-0x6137]
<7>[    5.352052] pci 0000:00:1f.2: reg 0x1c: [io  0x6148-0x614b]
<7>[    5.358668] pci 0000:00:1f.2: reg 0x20: [io  0x6110-0x611f]
<7>[    5.365290] pci 0000:00:1f.2: reg 0x24: [io  0x6100-0x610f]
<7>[    5.372051] pci 0000:00:1f.3: [8086:3a30] type 00 class 0x0c0500
<7>[    5.379178] pci 0000:00:1f.3: reg 0x10: [mem 0xaff20000-0xaff200ff 64bit]
<7>[    5.387185] pci 0000:00:1f.3: reg 0x20: [io  0x6000-0x601f]
<7>[    5.393939] pci 0000:00:1f.5: [8086:3a26] type 00 class 0x010185
<7>[    5.401068] pci 0000:00:1f.5: reg 0x10: [io  0x6128-0x612f]
<7>[    5.407702] pci 0000:00:1f.5: reg 0x14: [io  0x6144-0x6147]
<7>[    5.414329] pci 0000:00:1f.5: reg 0x18: [io  0x6120-0x6127]
<7>[    5.420960] pci 0000:00:1f.5: reg 0x1c: [io  0x6140-0x6143]
<7>[    5.427592] pci 0000:00:1f.5: reg 0x20: [io  0x60f0-0x60ff]
<7>[    5.434221] pci 0000:00:1f.5: reg 0x24: [io  0x60e0-0x60ef]
<7>[    5.441108] pci 0000:01:00.0: [8086:150a] type 00 class 0x020000
<7>[    5.448238] pci 0000:01:00.0: reg 0x10: [mem 0x95b20000-0x95b3ffff]
<7>[    5.455650] pci 0000:01:00.0: reg 0x18: [io  0x5020-0x503f]
<7>[    5.462286] pci 0000:01:00.0: reg 0x1c: [mem 0x95bc4000-0x95bc7fff]
<7>[    5.469788] pci 0000:01:00.0: PME# supported from D0 D3hot D3cold
<7>[    5.477048] pci 0000:01:00.0: reg 0x184: [mem 0x95b40000-0x95b43fff 64bit]
<7>[    5.485157] pci 0000:01:00.0: reg 0x190: [mem 0x95b60000-0x95b63fff 64bit]
<7>[    5.493354] pci 0000:01:00.1: [8086:150a] type 00 class 0x020000
<7>[    5.500486] pci 0000:01:00.1: reg 0x10: [mem 0x95b00000-0x95b1ffff]
<7>[    5.507915] pci 0000:01:00.1: reg 0x18: [io  0x5000-0x501f]
<7>[    5.514547] pci 0000:01:00.1: reg 0x1c: [mem 0x95bc0000-0x95bc3fff]
<7>[    5.522048] pci 0000:01:00.1: PME# supported from D0 D3hot D3cold
<7>[    5.529300] pci 0000:01:00.1: reg 0x184: [mem 0x95b80000-0x95b83fff 64bit]
<7>[    5.537402] pci 0000:01:00.1: reg 0x190: [mem 0x95ba0000-0x95ba3fff 64bit]
<6>[    5.551948] pci 0000:00:01.0: PCI bridge to [bus 01-03]
<7>[    5.558190] pci 0000:00:01.0:   bridge window [io  0x5000-0x5fff]
<7>[    5.565395] pci 0000:00:01.0:   bridge window [mem 0x95b00000-0x95bfffff]
<7>[    5.573518] pci 0000:04:00.0: [8086:150a] type 00 class 0x020000
<7>[    5.580649] pci 0000:04:00.0: reg 0x10: [mem 0x95a20000-0x95a3ffff]
<7>[    5.588076] pci 0000:04:00.0: reg 0x18: [io  0x4020-0x403f]
<7>[    5.594712] pci 0000:04:00.0: reg 0x1c: [mem 0x95ac4000-0x95ac7fff]
<7>[    5.602211] pci 0000:04:00.0: PME# supported from D0 D3hot D3cold
<7>[    5.609468] pci 0000:04:00.0: reg 0x184: [mem 0x95a40000-0x95a43fff 64bit]
<7>[    5.617567] pci 0000:04:00.0: reg 0x190: [mem 0x95a60000-0x95a63fff 64bit]
<7>[    5.625746] pci 0000:04:00.1: [8086:150a] type 00 class 0x020000
<7>[    5.632872] pci 0000:04:00.1: reg 0x10: [mem 0x95a00000-0x95a1ffff]
<7>[    5.640281] pci 0000:04:00.1: reg 0x18: [io  0x4000-0x401f]
<7>[    5.646922] pci 0000:04:00.1: reg 0x1c: [mem 0x95ac0000-0x95ac3fff]
<7>[    5.654407] pci 0000:04:00.1: PME# supported from D0 D3hot D3cold
<7>[    5.661657] pci 0000:04:00.1: reg 0x184: [mem 0x95a80000-0x95a83fff 64bit]
<7>[    5.669767] pci 0000:04:00.1: reg 0x190: [mem 0x95aa0000-0x95aa3fff 64bit]
<6>[    5.684025] pci 0000:00:02.0: PCI bridge to [bus 04-06]
<7>[    5.690275] pci 0000:00:02.0:   bridge window [io  0x4000-0x4fff]
<7>[    5.697491] pci 0000:00:02.0:   bridge window [mem 0x95a00000-0x95afffff]
<7>[    5.705602] pci 0000:07:00.0: [1000:0079] type 00 class 0x010400
<7>[    5.712726] pci 0000:07:00.0: reg 0x10: [io  0x3000-0x30ff]
<7>[    5.719354] pci 0000:07:00.0: reg 0x14: [mem 0x95940000-0x95943fff 64bit]
<7>[    5.727346] pci 0000:07:00.0: reg 0x1c: [mem 0x95900000-0x9593ffff 64bit]
<7>[    5.735337] pci 0000:07:00.0: reg 0x30: [mem 0xfffc0000-0xffffffff pref]
<7>[    5.743260] pci 0000:07:00.0: supports D1 D2
<6>[    5.756061] pci 0000:00:03.0: PCI bridge to [bus 07]
<7>[    5.762014] pci 0000:00:03.0:   bridge window [io  0x3000-0x3fff]
<7>[    5.769230] pci 0000:00:03.0:   bridge window [mem 0x95900000-0x959fffff]
<7>[    5.777224] pci 0000:00:03.0:   bridge window [mem 0x95d00000-0x95dfffff 64bit pref]
<6>[    5.786851] acpiphp: Slot [1] registered
<6>[    5.791658] pci 0000:00:05.0: PCI bridge to [bus 08-0a]
<7>[    5.797899] pci 0000:00:05.0:   bridge window [io  0x2000-0x2fff]
<7>[    5.805111] pci 0000:00:05.0:   bridge window [mem 0x94900000-0x958fffff]
<7>[    5.813098] pci 0000:00:05.0:   bridge window [mem 0x91900000-0x928fffff 64bit pref]
<6>[    5.822697] acpiphp: Slot [2] registered
<6>[    5.827497] pci 0000:00:07.0: PCI bridge to [bus 0b-0d]
<7>[    5.833731] pci 0000:00:07.0:   bridge window [io  0x1000-0x1fff]
<7>[    5.840936] pci 0000:00:07.0:   bridge window [mem 0x93900000-0x948fffff]
<7>[    5.848932] pci 0000:00:07.0:   bridge window [mem 0x92900000-0x938fffff 64bit pref]
<6>[    5.858534] pci 0000:00:09.0: PCI bridge to [bus 0e]
<6>[    5.864716] pci 0000:00:0a.0: PCI bridge to [bus 0f]
<6>[    5.870802] pci 0000:00:1c.0: PCI bridge to [bus 10]
<7>[    5.876751] pci 0000:00:1c.0:   bridge window [io  0x7000-0x7fff]
<7>[    5.883958] pci 0000:00:1c.0:   bridge window [mem 0x95e00000-0x95ffffff]
<7>[    5.891934] pci 0000:00:1c.0:   bridge window [mem 0x96000000-0x961fffff 64bit pref]
<7>[    5.901397] pci 0000:11:00.0: [102b:0522] type 00 class 0x030000
<7>[    5.908526] pci 0000:11:00.0: reg 0x10: [mem 0x90000000-0x90ffffff pref]
<7>[    5.916424] pci 0000:11:00.0: reg 0x14: [mem 0x91800000-0x91803fff]
<7>[    5.923828] pci 0000:11:00.0: reg 0x18: [mem 0x91000000-0x917fffff]
<7>[    5.931284] pci 0000:11:00.0: reg 0x30: [mem 0xffff0000-0xffffffff pref]
<6>[    5.944175] pci 0000:00:1c.4: PCI bridge to [bus 11]
<7>[    5.950134] pci 0000:00:1c.4:   bridge window [io  0x8000-0x8fff]
<7>[    5.957350] pci 0000:00:1c.4:   bridge window [mem 0x91000000-0x918fffff]
<7>[    5.965342] pci 0000:00:1c.4:   bridge window [mem 0x90000000-0x90ffffff 64bit pref]
<6>[    5.974813] pci 0000:00:1e.0: PCI bridge to [bus 12] (subtractive decode)
<7>[    5.982814] pci 0000:00:1e.0:   bridge window [io  0x0000-0x0cf7] (subtractive decode)
<7>[    5.992394] pci 0000:00:1e.0:   bridge window [io  0x1000-0x9fff] (subtractive decode)
<7>[    6.001978] pci 0000:00:1e.0:   bridge window [mem 0x000a0000-0x000bffff] (subtractive decode)
<7>[    6.012326] pci 0000:00:1e.0:   bridge window [mem 0xfed40000-0xfedfffff] (subtractive decode)
<7>[    6.022689] pci 0000:00:1e.0:   bridge window [mem 0x90000000-0xafffffff] (subtractive decode)
<7>[    6.033051] pci 0000:00:1e.0:   bridge window [mem 0xfc000000000-0xfc07fffffff] (subtractive decode)
<6>[    6.044031] acpi PNP0A08:00: Disabling ASPM (FADT indicates it is unsupported)
<6>[    6.053034] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 9 10 *11 12 14 15)
<6>[    6.062809] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 9 *10 11 12 14 15)
<6>[    6.072572] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 *9 10 11 12 14 15)
<6>[    6.082357] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 *5 6 7 9 10 11 12 14 15)
<6>[    6.092130] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
<6>[    6.103304] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 9 10 *11 12 14 15)
<6>[    6.113062] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
<6>[    6.124242] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 7 9 *10 11 12 14 15)
<6>[    6.134146] ACPI: PCI Root Bridge [IOH1] (domain 0000 [bus 80-f7])
<6>[    6.141456] acpi PNP0A08:01: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
<6>[    6.151496] acpi PNP0A08:01: _OSC: platform does not support [PCIeHotplug AER]
<6>[    6.160457] acpi PNP0A08:01: _OSC: OS now controls [PME PCIeCapability]
<6>[    6.168425] PCI host bridge to bus 0000:80
<6>[    6.173391] pci_bus 0000:80: root bus resource [bus 80-f7]
<6>[    6.179914] pci_bus 0000:80: root bus resource [io  0xa000-0xffff]
<6>[    6.187222] pci_bus 0000:80: root bus resource [mem 0xb0000000-0xfbffffff]
<6>[    6.195295] pci_bus 0000:80: root bus resource [mem 0xfc080000000-0xfc0ffffffff]
<7>[    6.204294] pci 0000:80:00.0: [8086:3420] type 01 class 0x060400
<7>[    6.211460] pci 0000:80:00.0: PME# supported from D0 D3hot D3cold
<6>[    6.218711] pci 0000:80:00.0: System wakeup disabled by ACPI
<7>[    6.225499] pci 0000:80:01.0: [8086:3408] type 01 class 0x060400
<7>[    6.232678] pci 0000:80:01.0: PME# supported from D0 D3hot D3cold
<6>[    6.239926] pci 0000:80:01.0: System wakeup disabled by ACPI
<7>[    6.246713] pci 0000:80:03.0: [8086:340a] type 01 class 0x060400
<7>[    6.253889] pci 0000:80:03.0: PME# supported from D0 D3hot D3cold
<6>[    6.261135] pci 0000:80:03.0: System wakeup disabled by ACPI
<7>[    6.267925] pci 0000:80:07.0: [8086:340e] type 01 class 0x060400
<7>[    6.275093] pci 0000:80:07.0: PME# supported from D0 D3hot D3cold
<6>[    6.282329] pci 0000:80:07.0: System wakeup disabled by ACPI
<7>[    6.289116] pci 0000:80:09.0: [8086:3410] type 01 class 0x060400
<7>[    6.296280] pci 0000:80:09.0: PME# supported from D0 D3hot D3cold
<6>[    6.303514] pci 0000:80:09.0: System wakeup disabled by ACPI
<7>[    6.310301] pci 0000:80:10.0: [8086:3425] type 00 class 0x080000
<7>[    6.317532] pci 0000:80:10.1: [8086:3426] type 00 class 0x080000
<7>[    6.324756] pci 0000:80:11.0: [8086:3427] type 00 class 0x080000
<7>[    6.331983] pci 0000:80:11.1: [8086:3428] type 00 class 0x080000
<7>[    6.339203] pci 0000:80:13.0: [8086:342d] type 00 class 0x080020
<7>[    6.346327] pci 0000:80:13.0: reg 0x10: [mem 0xb4000000-0xb4000fff]
<7>[    6.353774] pci 0000:80:13.0: PME# supported from D0 D3hot D3cold
<7>[    6.361059] pci 0000:80:14.0: [8086:342e] type 00 class 0x080000
<7>[    6.368297] pci 0000:80:14.1: [8086:3422] type 00 class 0x080000
<7>[    6.375520] pci 0000:80:14.2: [8086:3423] type 00 class 0x080000
<7>[    6.382743] pci 0000:80:14.3: [8086:3438] type 00 class 0x080000
<7>[    6.389963] pci 0000:80:15.0: [8086:342f] type 00 class 0x080020
<7>[    6.397173] pci 0000:80:16.0: [8086:3430] type 00 class 0x088000
<7>[    6.404299] pci 0000:80:16.0: reg 0x10: [mem 0xfbf1c000-0xfbf1ffff 64bit]
<7>[    6.412429] pci 0000:80:16.1: [8086:3431] type 00 class 0x088000
<7>[    6.419547] pci 0000:80:16.1: reg 0x10: [mem 0xfbf18000-0xfbf1bfff 64bit]
<7>[    6.427668] pci 0000:80:16.2: [8086:3432] type 00 class 0x088000
<7>[    6.434789] pci 0000:80:16.2: reg 0x10: [mem 0xfbf14000-0xfbf17fff 64bit]
<7>[    6.442912] pci 0000:80:16.3: [8086:3433] type 00 class 0x088000
<7>[    6.458132] pci 0000:80:16.3: reg 0x10: [mem 0xfbf10000-0xfbf13fff 64bit]
<7>[    6.466243] pci 0000:80:16.4: [8086:3429] type 00 class 0x088000
<7>[    6.473359] pci 0000:80:16.4: reg 0x10: [mem 0xfbf0c000-0xfbf0ffff 64bit]
<7>[    6.481471] pci 0000:80:16.5: [8086:342a] type 00 class 0x088000
<7>[    6.488596] pci 0000:80:16.5: reg 0x10: [mem 0xfbf08000-0xfbf0bfff 64bit]
<7>[    6.496711] pci 0000:80:16.6: [8086:342b] type 00 class 0x088000
<7>[    6.503831] pci 0000:80:16.6: reg 0x10: [mem 0xfbf04000-0xfbf07fff 64bit]
<7>[    6.511950] pci 0000:80:16.7: [8086:342c] type 00 class 0x088000
<7>[    6.519075] pci 0000:80:16.7: reg 0x10: [mem 0xfbf00000-0xfbf03fff 64bit]
<6>[    6.527420] pci 0000:80:00.0: PCI bridge to [bus 81]
<6>[    6.533596] pci 0000:80:01.0: PCI bridge to [bus 82]
<6>[    6.539780] pci 0000:80:03.0: PCI bridge to [bus 83]
<6>[    6.545975] acpiphp: Slot [6] registered
<6>[    6.550784] pci 0000:80:07.0: PCI bridge to [bus 84-86]
<7>[    6.557026] pci 0000:80:07.0:   bridge window [io  0xb000-0xbfff]
<7>[    6.564225] pci 0000:80:07.0:   bridge window [mem 0xb3000000-0xb3ffffff]
<7>[    6.572226] pci 0000:80:07.0:   bridge window [mem 0xb0000000-0xb0ffffff 64bit pref]
<6>[    6.581842] acpiphp: Slot [7] registered
<6>[    6.586647] pci 0000:80:09.0: PCI bridge to [bus 87-89]
<7>[    6.592889] pci 0000:80:09.0:   bridge window [io  0xa000-0xafff]
<7>[    6.600103] pci 0000:80:09.0:   bridge window [mem 0xb2000000-0xb2ffffff]
<7>[    6.608096] pci 0000:80:09.0:   bridge window [mem 0xb1000000-0xb1ffffff 64bit pref]
<6>[    6.617499] acpi PNP0A08:01: Disabling ASPM (FADT indicates it is unsupported)
<6>[    6.626477] ACPI: PCI Root Bridge [PRB3] (domain 0000 [bus fc])
<6>[    6.633491] acpi PNP0A03:00: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
<6>[    6.643350] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
<6>[    6.651203] PCI host bridge to bus 0000:fc
<6>[    6.656175] pci_bus 0000:fc: root bus resource [bus fc]
<7>[    6.662395] pci 0000:fc:00.0: [8086:2b00] type 00 class 0x060000
<7>[    6.669574] pci 0000:fc:00.2: [8086:2b02] type 00 class 0x060000
<7>[    6.676748] pci 0000:fc:00.4: [8086:2b22] type 00 class 0x060000
<7>[    6.683934] pci 0000:fc:00.6: [8086:2b2a] type 00 class 0x060000
<7>[    6.691113] pci 0000:fc:01.0: [8086:2b04] type 00 class 0x060000
<7>[    6.698299] pci 0000:fc:02.0: [8086:2b08] type 00 class 0x060000
<7>[    6.705479] pci 0000:fc:03.0: [8086:2b0c] type 00 class 0x060000
<7>[    6.712665] pci 0000:fc:04.0: [8086:2b10] type 00 class 0x060000
<7>[    6.719840] pci 0000:fc:05.0: [8086:2b14] type 00 class 0x060000
<7>[    6.727014] pci 0000:fc:05.2: [8086:2b16] type 00 class 0x060000
<7>[    6.734184] pci 0000:fc:05.4: [8086:2b13] type 00 class 0x060000
<7>[    6.741369] pci 0000:fc:05.6: [8086:2b53] type 00 class 0x060000
<7>[    6.748553] pci 0000:fc:06.0: [8086:2b18] type 00 class 0x060000
<7>[    6.755737] pci 0000:fc:07.0: [8086:2b1c] type 00 class 0x060000
<7>[    6.762911] pci 0000:fc:07.2: [8086:2b1e] type 00 class 0x060000
<7>[    6.770096] pci 0000:fc:07.4: [8086:2b1b] type 00 class 0x060000
<7>[    6.777272] pci 0000:fc:07.6: [8086:2b5b] type 00 class 0x060000
<7>[    6.784459] pci 0000:fc:08.0: [8086:2b20] type 00 class 0x060000
<7>[    6.791636] pci 0000:fc:09.0: [8086:2b24] type 00 class 0x060000
<7>[    6.798819] pci 0000:fc:0a.0: [8086:2b28] type 00 class 0x060000
<7>[    6.805996] pci 0000:fc:0b.0: [8086:2b2c] type 00 class 0x060000
<7>[    6.813185] pci 0000:fc:0c.0: [8086:2b30] type 00 class 0x060000
<7>[    6.820368] pci 0000:fc:0d.0: [8086:2b34] type 00 class 0x060000
<7>[    6.827553] pci 0000:fc:0e.0: [8086:2b38] type 00 class 0x060000
<7>[    6.834736] pci 0000:fc:0f.0: [8086:2b3c] type 00 class 0x060000
<7>[    6.841917] pci 0000:fc:10.0: [8086:2b40] type 00 class 0x060000
<7>[    6.849103] pci 0000:fc:10.2: [8086:2b42] type 00 class 0x060000
<7>[    6.856280] pci 0000:fc:10.4: [8086:2b32] type 00 class 0x060000
<7>[    6.863465] pci 0000:fc:10.6: [8086:2b3a] type 00 class 0x060000
<7>[    6.870650] pci 0000:fc:11.0: [8086:2b44] type 00 class 0x060000
<7>[    6.877837] pci 0000:fc:11.2: [8086:2b46] type 00 class 0x060000
<7>[    6.885023] pci 0000:fc:11.4: [8086:2b36] type 00 class 0x060000
<7>[    6.892207] pci 0000:fc:11.6: [8086:2b3e] type 00 class 0x060000
<7>[    6.899395] pci 0000:fc:12.0: [8086:2b48] type 00 class 0x060000
<7>[    6.906585] pci 0000:fc:13.0: [8086:2b4c] type 00 class 0x060000
<7>[    6.913767] pci 0000:fc:14.0: [8086:2b50] type 00 class 0x060000
<7>[    6.920954] pci 0000:fc:14.2: [8086:2b52] type 00 class 0x060000
<7>[    6.928137] pci 0000:fc:15.0: [8086:2b54] type 00 class 0x060000
<7>[    6.935315] pci 0000:fc:15.2: [8086:2b56] type 00 class 0x060000
<7>[    6.942502] pci 0000:fc:16.0: [8086:2b58] type 00 class 0x060000
<7>[    6.949687] pci 0000:fc:16.2: [8086:2b5a] type 00 class 0x060000
<7>[    6.956875] pci 0000:fc:17.0: [8086:2b5c] type 00 class 0x060000
<7>[    6.964061] pci 0000:fc:17.2: [8086:2b5e] type 00 class 0x060000
<7>[    6.971252] pci 0000:fc:18.0: [8086:2b60] type 00 class 0x060000
<7>[    6.978442] pci 0000:fc:18.2: [8086:2b62] type 00 class 0x060000
<7>[    6.985627] pci 0000:fc:19.0: [8086:2b64] type 00 class 0x060000
<7>[    6.992812] pci 0000:fc:19.2: [8086:2b66] type 00 class 0x060000
<7>[    7.000000] pci 0000:fc:1a.0: [8086:2b68] type 00 class 0x060000
<7>[    7.007191] pci 0000:fc:1b.0: [8086:2b6c] type 00 class 0x060000
<6>[    7.014441] ACPI: PCI Root Bridge [PRB2] (domain 0000 [bus fd])
<6>[    7.021452] acpi PNP0A03:01: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
<6>[    7.031333] acpi PNP0A03:01: _OSC failed (AE_NOT_FOUND); disabling ASPM
<6>[    7.039188] PCI host bridge to bus 0000:fd
<6>[    7.044161] pci_bus 0000:fd: root bus resource [bus fd]
<7>[    7.050407] pci 0000:fd:00.0: [8086:2b00] type 00 class 0x060000
<7>[    7.057595] pci 0000:fd:00.2: [8086:2b02] type 00 class 0x060000
<7>[    7.064777] pci 0000:fd:00.4: [8086:2b22] type 00 class 0x060000
<7>[    7.071952] pci 0000:fd:00.6: [8086:2b2a] type 00 class 0x060000
<7>[    7.079136] pci 0000:fd:01.0: [8086:2b04] type 00 class 0x060000
<7>[    7.086312] pci 0000:fd:02.0: [8086:2b08] type 00 class 0x060000
<7>[    7.093489] pci 0000:fd:03.0: [8086:2b0c] type 00 class 0x060000
<7>[    7.100667] pci 0000:fd:04.0: [8086:2b10] type 00 class 0x060000
<7>[    7.107847] pci 0000:fd:05.0: [8086:2b14] type 00 class 0x060000
<7>[    7.115025] pci 0000:fd:05.2: [8086:2b16] type 00 class 0x060000
<7>[    7.122208] pci 0000:fd:05.4: [8086:2b13] type 00 class 0x060000
<7>[    7.129387] pci 0000:fd:05.6: [8086:2b53] type 00 class 0x060000
<7>[    7.136564] pci 0000:fd:06.0: [8086:2b18] type 00 class 0x060000
<7>[    7.143750] pci 0000:fd:07.0: [8086:2b1c] type 00 class 0x060000
<7>[    7.150926] pci 0000:fd:07.2: [8086:2b1e] type 00 class 0x060000
<7>[    7.158109] pci 0000:fd:07.4: [8086:2b1b] type 00 class 0x060000
<7>[    7.165286] pci 0000:fd:07.6: [8086:2b5b] type 00 class 0x060000
<7>[    7.172456] pci 0000:fd:08.0: [8086:2b20] type 00 class 0x060000
<7>[    7.179624] pci 0000:fd:09.0: [8086:2b24] type 00 class 0x060000
<7>[    7.186802] pci 0000:fd:0a.0: [8086:2b28] type 00 class 0x060000
<7>[    7.193984] pci 0000:fd:0b.0: [8086:2b2c] type 00 class 0x060000
<7>[    7.201167] pci 0000:fd:0c.0: [8086:2b30] type 00 class 0x060000
<7>[    7.208355] pci 0000:fd:0d.0: [8086:2b34] type 00 class 0x060000
<7>[    7.215540] pci 0000:fd:0e.0: [8086:2b38] type 00 class 0x060000
<7>[    7.222726] pci 0000:fd:0f.0: [8086:2b3c] type 00 class 0x060000
<7>[    7.229923] pci 0000:fd:10.0: [8086:2b40] type 00 class 0x060000
<7>[    7.237111] pci 0000:fd:10.2: [8086:2b42] type 00 class 0x060000
<7>[    7.244292] pci 0000:fd:10.4: [8086:2b32] type 00 class 0x060000
<7>[    7.251480] pci 0000:fd:10.6: [8086:2b3a] type 00 class 0x060000
<7>[    7.258665] pci 0000:fd:11.0: [8086:2b44] type 00 class 0x060000
<7>[    7.265839] pci 0000:fd:11.2: [8086:2b46] type 00 class 0x060000
<7>[    7.273012] pci 0000:fd:11.4: [8086:2b36] type 00 class 0x060000
<7>[    7.280188] pci 0000:fd:11.6: [8086:2b3e] type 00 class 0x060000
<7>[    7.287367] pci 0000:fd:12.0: [8086:2b48] type 00 class 0x060000
<7>[    7.294540] pci 0000:fd:13.0: [8086:2b4c] type 00 class 0x060000
<7>[    7.301729] pci 0000:fd:14.0: [8086:2b50] type 00 class 0x060000
<7>[    7.308916] pci 0000:fd:14.2: [8086:2b52] type 00 class 0x060000
<7>[    7.316103] pci 0000:fd:15.0: [8086:2b54] type 00 class 0x060000
<7>[    7.323290] pci 0000:fd:15.2: [8086:2b56] type 00 class 0x060000
<7>[    7.330474] pci 0000:fd:16.0: [8086:2b58] type 00 class 0x060000
<7>[    7.337660] pci 0000:fd:16.2: [8086:2b5a] type 00 class 0x060000
<7>[    7.344847] pci 0000:fd:17.0: [8086:2b5c] type 00 class 0x060000
<7>[    7.352025] pci 0000:fd:17.2: [8086:2b5e] type 00 class 0x060000
<7>[    7.359213] pci 0000:fd:18.0: [8086:2b60] type 00 class 0x060000
<7>[    7.366402] pci 0000:fd:18.2: [8086:2b62] type 00 class 0x060000
<7>[    7.373577] pci 0000:fd:19.0: [8086:2b64] type 00 class 0x060000
<7>[    7.380759] pci 0000:fd:19.2: [8086:2b66] type 00 class 0x060000
<7>[    7.387928] pci 0000:fd:1a.0: [8086:2b68] type 00 class 0x060000
<7>[    7.395116] pci 0000:fd:1b.0: [8086:2b6c] type 00 class 0x060000
<6>[    7.402360] ACPI: PCI Root Bridge [PRB1] (domain 0000 [bus fe])
<6>[    7.409385] acpi PNP0A03:02: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
<6>[    7.419244] acpi PNP0A03:02: _OSC failed (AE_NOT_FOUND); disabling ASPM
<6>[    7.427100] PCI host bridge to bus 0000:fe
<6>[    7.432071] pci_bus 0000:fe: root bus resource [bus fe]
<7>[    7.438315] pci 0000:fe:00.0: [8086:2b00] type 00 class 0x060000
<7>[    7.445486] pci 0000:fe:00.2: [8086:2b02] type 00 class 0x060000
<7>[    7.452669] pci 0000:fe:00.4: [8086:2b22] type 00 class 0x060000
<7>[    7.459846] pci 0000:fe:00.6: [8086:2b2a] type 00 class 0x060000
<7>[    7.467026] pci 0000:fe:01.0: [8086:2b04] type 00 class 0x060000
<7>[    7.474198] pci 0000:fe:02.0: [8086:2b08] type 00 class 0x060000
<7>[    7.481386] pci 0000:fe:03.0: [8086:2b0c] type 00 class 0x060000
<7>[    7.488573] pci 0000:fe:04.0: [8086:2b10] type 00 class 0x060000
<7>[    7.495760] pci 0000:fe:05.0: [8086:2b14] type 00 class 0x060000
<7>[    7.502937] pci 0000:fe:05.2: [8086:2b16] type 00 class 0x060000
<7>[    7.510122] pci 0000:fe:05.4: [8086:2b13] type 00 class 0x060000
<7>[    7.517306] pci 0000:fe:05.6: [8086:2b53] type 00 class 0x060000
<7>[    7.524488] pci 0000:fe:06.0: [8086:2b18] type 00 class 0x060000
<7>[    7.531670] pci 0000:fe:07.0: [8086:2b1c] type 00 class 0x060000
<7>[    7.538853] pci 0000:fe:07.2: [8086:2b1e] type 00 class 0x060000
<7>[    7.546028] pci 0000:fe:07.4: [8086:2b1b] type 00 class 0x060000
<7>[    7.553212] pci 0000:fe:07.6: [8086:2b5b] type 00 class 0x060000
<7>[    7.560389] pci 0000:fe:08.0: [8086:2b20] type 00 class 0x060000
<7>[    7.567570] pci 0000:fe:09.0: [8086:2b24] type 00 class 0x060000
<7>[    7.574760] pci 0000:fe:0a.0: [8086:2b28] type 00 class 0x060000
<7>[    7.581947] pci 0000:fe:0b.0: [8086:2b2c] type 00 class 0x060000
<7>[    7.589136] pci 0000:fe:0c.0: [8086:2b30] type 00 class 0x060000
<7>[    7.596326] pci 0000:fe:0d.0: [8086:2b34] type 00 class 0x060000
<7>[    7.603503] pci 0000:fe:0e.0: [8086:2b38] type 00 class 0x060000
<7>[    7.610695] pci 0000:fe:0f.0: [8086:2b3c] type 00 class 0x060000
<7>[    7.617881] pci 0000:fe:10.0: [8086:2b40] type 00 class 0x060000
<7>[    7.625068] pci 0000:fe:10.2: [8086:2b42] type 00 class 0x060000
<7>[    7.632242] pci 0000:fe:10.4: [8086:2b32] type 00 class 0x060000
<7>[    7.639420] pci 0000:fe:10.6: [8086:2b3a] type 00 class 0x060000
<7>[    7.646597] pci 0000:fe:11.0: [8086:2b44] type 00 class 0x060000
<7>[    7.653769] pci 0000:fe:11.2: [8086:2b46] type 00 class 0x060000
<7>[    7.660947] pci 0000:fe:11.4: [8086:2b36] type 00 class 0x060000
<7>[    7.668132] pci 0000:fe:11.6: [8086:2b3e] type 00 class 0x060000
<7>[    7.675309] pci 0000:fe:12.0: [8086:2b48] type 00 class 0x060000
<7>[    7.682496] pci 0000:fe:13.0: [8086:2b4c] type 00 class 0x060000
<7>[    7.689686] pci 0000:fe:14.0: [8086:2b50] type 00 class 0x060000
<7>[    7.696869] pci 0000:fe:14.2: [8086:2b52] type 00 class 0x060000
<7>[    7.704061] pci 0000:fe:15.0: [8086:2b54] type 00 class 0x060000
<7>[    7.719341] pci 0000:fe:15.2: [8086:2b56] type 00 class 0x060000
<7>[    7.726523] pci 0000:fe:16.0: [8086:2b58] type 00 class 0x060000
<7>[    7.733702] pci 0000:fe:16.2: [8086:2b5a] type 00 class 0x060000
<7>[    7.740879] pci 0000:fe:17.0: [8086:2b5c] type 00 class 0x060000
<7>[    7.748057] pci 0000:fe:17.2: [8086:2b5e] type 00 class 0x060000
<7>[    7.755237] pci 0000:fe:18.0: [8086:2b60] type 00 class 0x060000
<7>[    7.762416] pci 0000:fe:18.2: [8086:2b62] type 00 class 0x060000
<7>[    7.769603] pci 0000:fe:19.0: [8086:2b64] type 00 class 0x060000
<7>[    7.776787] pci 0000:fe:19.2: [8086:2b66] type 00 class 0x060000
<7>[    7.783975] pci 0000:fe:1a.0: [8086:2b68] type 00 class 0x060000
<7>[    7.791165] pci 0000:fe:1b.0: [8086:2b6c] type 00 class 0x060000
<6>[    7.798415] ACPI: PCI Root Bridge [PRB0] (domain 0000 [bus ff])
<6>[    7.805432] acpi PNP0A03:03: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
<6>[    7.815294] acpi PNP0A03:03: _OSC failed (AE_NOT_FOUND); disabling ASPM
<6>[    7.823147] PCI host bridge to bus 0000:ff
<6>[    7.828112] pci_bus 0000:ff: root bus resource [bus ff]
<7>[    7.834347] pci 0000:ff:00.0: [8086:2b00] type 00 class 0x060000
<7>[    7.841524] pci 0000:ff:00.2: [8086:2b02] type 00 class 0x060000
<7>[    7.848707] pci 0000:ff:00.4: [8086:2b22] type 00 class 0x060000
<7>[    7.855891] pci 0000:ff:00.6: [8086:2b2a] type 00 class 0x060000
<7>[    7.863081] pci 0000:ff:01.0: [8086:2b04] type 00 class 0x060000
<7>[    7.870264] pci 0000:ff:02.0: [8086:2b08] type 00 class 0x060000
<7>[    7.877446] pci 0000:ff:03.0: [8086:2b0c] type 00 class 0x060000
<7>[    7.884626] pci 0000:ff:04.0: [8086:2b10] type 00 class 0x060000
<7>[    7.891809] pci 0000:ff:05.0: [8086:2b14] type 00 class 0x060000
<7>[    7.898987] pci 0000:ff:05.2: [8086:2b16] type 00 class 0x060000
<7>[    7.906166] pci 0000:ff:05.4: [8086:2b13] type 00 class 0x060000
<7>[    7.913347] pci 0000:ff:05.6: [8086:2b53] type 00 class 0x060000
<7>[    7.920523] pci 0000:ff:06.0: [8086:2b18] type 00 class 0x060000
<7>[    7.927699] pci 0000:ff:07.0: [8086:2b1c] type 00 class 0x060000
<7>[    7.934877] pci 0000:ff:07.2: [8086:2b1e] type 00 class 0x060000
<7>[    7.942046] pci 0000:ff:07.4: [8086:2b1b] type 00 class 0x060000
<7>[    7.949226] pci 0000:ff:07.6: [8086:2b5b] type 00 class 0x060000
<7>[    7.956401] pci 0000:ff:08.0: [8086:2b20] type 00 class 0x060000
<7>[    7.963590] pci 0000:ff:09.0: [8086:2b24] type 00 class 0x060000
<7>[    7.970760] pci 0000:ff:0a.0: [8086:2b28] type 00 class 0x060000
<7>[    7.977947] pci 0000:ff:0b.0: [8086:2b2c] type 00 class 0x060000
<7>[    7.985122] pci 0000:ff:0c.0: [8086:2b30] type 00 class 0x060000
<7>[    7.992301] pci 0000:ff:0d.0: [8086:2b34] type 00 class 0x060000
<7>[    7.999465] pci 0000:ff:0e.0: [8086:2b38] type 00 class 0x060000
<7>[    8.006646] pci 0000:ff:0f.0: [8086:2b3c] type 00 class 0x060000
<7>[    8.013818] pci 0000:ff:10.0: [8086:2b40] type 00 class 0x060000
<7>[    8.020998] pci 0000:ff:10.2: [8086:2b42] type 00 class 0x060000
<7>[    8.028169] pci 0000:ff:10.4: [8086:2b32] type 00 class 0x060000
<7>[    8.035350] pci 0000:ff:10.6: [8086:2b3a] type 00 class 0x060000
<7>[    8.042523] pci 0000:ff:11.0: [8086:2b44] type 00 class 0x060000
<7>[    8.049705] pci 0000:ff:11.2: [8086:2b46] type 00 class 0x060000
<7>[    8.056873] pci 0000:ff:11.4: [8086:2b36] type 00 class 0x060000
<7>[    8.064056] pci 0000:ff:11.6: [8086:2b3e] type 00 class 0x060000
<7>[    8.071229] pci 0000:ff:12.0: [8086:2b48] type 00 class 0x060000
<7>[    8.078418] pci 0000:ff:13.0: [8086:2b4c] type 00 class 0x060000
<7>[    8.085594] pci 0000:ff:14.0: [8086:2b50] type 00 class 0x060000
<7>[    8.092778] pci 0000:ff:14.2: [8086:2b52] type 00 class 0x060000
<7>[    8.099956] pci 0000:ff:15.0: [8086:2b54] type 00 class 0x060000
<7>[    8.107136] pci 0000:ff:15.2: [8086:2b56] type 00 class 0x060000
<7>[    8.114315] pci 0000:ff:16.0: [8086:2b58] type 00 class 0x060000
<7>[    8.121500] pci 0000:ff:16.2: [8086:2b5a] type 00 class 0x060000
<7>[    8.128685] pci 0000:ff:17.0: [8086:2b5c] type 00 class 0x060000
<7>[    8.135870] pci 0000:ff:17.2: [8086:2b5e] type 00 class 0x060000
<7>[    8.143051] pci 0000:ff:18.0: [8086:2b60] type 00 class 0x060000
<7>[    8.150241] pci 0000:ff:18.2: [8086:2b62] type 00 class 0x060000
<7>[    8.157429] pci 0000:ff:19.0: [8086:2b64] type 00 class 0x060000
<7>[    8.164614] pci 0000:ff:19.2: [8086:2b66] type 00 class 0x060000
<7>[    8.171800] pci 0000:ff:1a.0: [8086:2b68] type 00 class 0x060000
<7>[    8.178991] pci 0000:ff:1b.0: [8086:2b6c] type 00 class 0x060000
<4>[    8.204364] ACPI: Enabled 34 GPEs in block 00 to 3F
<6>[    8.210600] vgaarb: device added: PCI:0000:11:00.0,decodes=io+mem,owns=io+mem,locks=none
<6>[    8.220459] vgaarb: loaded
<6>[    8.223869] vgaarb: bridge control possible 0000:11:00.0
<5>[    8.230392] SCSI subsystem initialized
<7>[    8.235272] libata version 3.00 loaded.
<6>[    8.240097] ACPI: bus type USB registered
<6>[    8.245035] usbcore: registered new interface driver usbfs
<6>[    8.251590] usbcore: registered new interface driver hub
<6>[    8.258006] usbcore: registered new device driver usb
<6>[    8.264104] pps_core: LinuxPPS API ver. 1 registered
<6>[    8.270057] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
<6>[    8.281023] PTP clock support registered
<6>[    8.286287] EDAC MC: Ver: 3.0.0
<6>[    8.290678] PCI: Using ACPI for IRQ routing
<7>[    8.300238] PCI: pci_cache_line_size set to 64 bytes
<7>[    8.306576] e820: reserve RAM buffer [mem 0x0009b400-0x0009ffff]
<7>[    8.313700] e820: reserve RAM buffer [mem 0x7b43e000-0x7bffffff]
<6>[    8.321636] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0
<6>[    8.328151] hpet0: 4 comparators, 64-bit 14.318180 MHz counter
<6>[    8.337404] Switched to clocksource hpet
<4>[    8.342424] Could not create debugfs 'set_ftrace_filter' entry
<4>[    8.349357] Could not create debugfs 'set_ftrace_notrace' entry
<6>[    8.372587] pnp: PnP ACPI init
<6>[    8.376421] ACPI: bus type PNP registered
<7>[    8.381382] pnp 00:00: Plug and Play ACPI device, IDs PNP0003 (active)
<7>[    8.389446] pnp 00:01: [dma 4]
<7>[    8.393305] pnp 00:01: Plug and Play ACPI device, IDs PNP0200 (active)
<7>[    8.401027] IOAPIC[0]: Set routing entry (8-8 -> 0x38 -> IRQ 8 Mode:0 Active:0 Dest:0)
<7>[    8.410679] pnp 00:02: Plug and Play ACPI device, IDs PNP0b00 (active)
<7>[    8.418405] IOAPIC[0]: Set routing entry (8-13 -> 0x3d -> IRQ 13 Mode:0 Active:0 Dest:0)
<7>[    8.428223] pnp 00:03: Plug and Play ACPI device, IDs PNP0c04 (active)
<7>[    8.435985] pnp 00:04: Plug and Play ACPI device, IDs PNP0800 (active)
<7>[    8.443784] pnp 00:05: Plug and Play ACPI device, IDs PNP0103 (active)
<6>[    8.451691] system 00:06: [io  0x0500-0x057f] could not be reserved
<6>[    8.459108] system 00:06: [io  0x0400-0x047f] could not be reserved
<6>[    8.466520] system 00:06: [io  0x0540-0x057f] has been reserved
<6>[    8.473543] system 00:06: [io  0x0600-0x061f] has been reserved
<6>[    8.480565] system 00:06: [io  0x0880-0x0883] has been reserved
<6>[    8.487590] system 00:06: [io  0x0ca4-0x0ca5] has been reserved
<6>[    8.494618] system 00:06: [io  0x0800-0x081f] has been reserved
<6>[    8.501648] system 00:06: [mem 0xfed1c000-0xfed3ffff] could not be reserved
<6>[    8.509846] system 00:06: [mem 0xfed45000-0xfed8bfff] has been reserved
<6>[    8.517649] system 00:06: [mem 0xff000000-0xffffffff] has been reserved
<6>[    8.525453] system 00:06: [mem 0xfee00000-0xfeefffff] has been reserved
<6>[    8.533263] system 00:06: [mem 0xfed12000-0xfed1200f] has been reserved
<6>[    8.541058] system 00:06: [mem 0xfed12010-0xfed1201f] has been reserved
<6>[    8.548866] system 00:06: [mem 0xfed1b000-0xfed1bfff] has been reserved
<7>[    8.556665] system 00:06: Plug and Play ACPI device, IDs PNP0c02 (active)
<7>[    8.564806] IOAPIC[0]: Set routing entry (8-4 -> 0x34 -> IRQ 4 Mode:0 Active:0 Dest:0)
<7>[    8.574472] pnp 00:07: Plug and Play ACPI device, IDs PNP0501 (active)
<7>[    8.582310] IOAPIC[0]: Set routing entry (8-3 -> 0x33 -> IRQ 3 Mode:0 Active:0 Dest:0)
<7>[    8.592008] pnp 00:08: Plug and Play ACPI device, IDs PNP0501 (active)
<7>[    8.599794] pnp 00:09: Plug and Play ACPI device, IDs PNP0c31 (active)
<7>[    8.607591] pnp 00:0a: Plug and Play ACPI device, IDs IPI0001 (active)
<7>[    8.633939] pnp 00:0b: Plug and Play ACPI device, IDs PNP0c80 (active)
<7>[    8.659998] pnp 00:0c: Plug and Play ACPI device, IDs PNP0c80 (active)
<7>[    8.685994] pnp 00:0d: Plug and Play ACPI device, IDs PNP0c80 (active)
<7>[    8.712012] pnp 00:0e: Plug and Play ACPI device, IDs PNP0c80 (active)
<6>[    8.719813] pnp: PnP ACPI: found 15 devices
<6>[    8.724895] ACPI: bus type PNP unregistered
<6>[    8.737662] pci 0000:07:00.0: can't claim BAR 6 [mem 0xfffc0000-0xffffffff pref]: no compatible bridge window
<6>[    8.749495] pci 0000:11:00.0: can't claim BAR 6 [mem 0xffff0000-0xffffffff pref]: no compatible bridge window
<6>[    8.761418] pci 0000:00:01.0: PCI bridge to [bus 01-03]
<6>[    8.767669] pci 0000:00:01.0:   bridge window [io  0x5000-0x5fff]
<6>[    8.774893] pci 0000:00:01.0:   bridge window [mem 0x95b00000-0x95bfffff]
<6>[    8.782890] pci 0000:00:02.0: PCI bridge to [bus 04-06]
<6>[    8.789141] pci 0000:00:02.0:   bridge window [io  0x4000-0x4fff]
<6>[    8.796353] pci 0000:00:02.0:   bridge window [mem 0x95a00000-0x95afffff]
<6>[    8.804362] pci 0000:07:00.0: BAR 6: assigned [mem 0x95d00000-0x95d3ffff pref]
<6>[    8.813167] pci 0000:00:03.0: PCI bridge to [bus 07]
<6>[    8.819118] pci 0000:00:03.0:   bridge window [io  0x3000-0x3fff]
<6>[    8.826339] pci 0000:00:03.0:   bridge window [mem 0x95900000-0x959fffff]
<6>[    8.834341] pci 0000:00:03.0:   bridge window [mem 0x95d00000-0x95dfffff 64bit pref]
<6>[    8.843749] pci 0000:00:05.0: PCI bridge to [bus 08-0a]
<6>[    8.850000] pci 0000:00:05.0:   bridge window [io  0x2000-0x2fff]
<6>[    8.857219] pci 0000:00:05.0:   bridge window [mem 0x94900000-0x958fffff]
<6>[    8.865225] pci 0000:00:05.0:   bridge window [mem 0x91900000-0x928fffff 64bit pref]
<6>[    8.874617] pci 0000:00:07.0: PCI bridge to [bus 0b-0d]
<6>[    8.880852] pci 0000:00:07.0:   bridge window [io  0x1000-0x1fff]
<6>[    8.888074] pci 0000:00:07.0:   bridge window [mem 0x93900000-0x948fffff]
<6>[    8.896062] pci 0000:00:07.0:   bridge window [mem 0x92900000-0x938fffff 64bit pref]
<6>[    8.905466] pci 0000:00:09.0: PCI bridge to [bus 0e]
<6>[    8.911432] pci 0000:00:0a.0: PCI bridge to [bus 0f]
<6>[    8.917397] pci 0000:00:1c.0: PCI bridge to [bus 10]
<6>[    8.923351] pci 0000:00:1c.0:   bridge window [io  0x7000-0x7fff]
<6>[    8.930575] pci 0000:00:1c.0:   bridge window [mem 0x95e00000-0x95ffffff]
<6>[    8.938571] pci 0000:00:1c.0:   bridge window [mem 0x96000000-0x961fffff 64bit pref]
<6>[    8.947980] pci 0000:11:00.0: BAR 6: assigned [mem 0x91810000-0x9181ffff pref]
<6>[    8.956782] pci 0000:00:1c.4: PCI bridge to [bus 11]
<6>[    8.962732] pci 0000:00:1c.4:   bridge window [io  0x8000-0x8fff]
<6>[    8.969953] pci 0000:00:1c.4:   bridge window [mem 0x91000000-0x918fffff]
<6>[    8.977949] pci 0000:00:1c.4:   bridge window [mem 0x90000000-0x90ffffff 64bit pref]
<6>[    8.987351] pci 0000:00:1e.0: PCI bridge to [bus 12]
<7>[    8.993301] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
<7>[    8.999941] pci_bus 0000:00: resource 5 [io  0x1000-0x9fff]
<7>[    9.006564] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
<7>[    9.013978] pci_bus 0000:00: resource 7 [mem 0xfed40000-0xfedfffff]
<7>[    9.021397] pci_bus 0000:00: resource 8 [mem 0x90000000-0xafffffff]
<7>[    9.037139] pci_bus 0000:00: resource 9 [mem 0xfc000000000-0xfc07fffffff]
<7>[    9.045130] pci_bus 0000:01: resource 0 [io  0x5000-0x5fff]
<7>[    9.051755] pci_bus 0000:01: resource 1 [mem 0x95b00000-0x95bfffff]
<7>[    9.059174] pci_bus 0000:04: resource 0 [io  0x4000-0x4fff]
<7>[    9.065798] pci_bus 0000:04: resource 1 [mem 0x95a00000-0x95afffff]
<7>[    9.073206] pci_bus 0000:07: resource 0 [io  0x3000-0x3fff]
<7>[    9.079842] pci_bus 0000:07: resource 1 [mem 0x95900000-0x959fffff]
<7>[    9.087254] pci_bus 0000:07: resource 2 [mem 0x95d00000-0x95dfffff 64bit pref]
<7>[    9.096059] pci_bus 0000:08: resource 0 [io  0x2000-0x2fff]
<7>[    9.102697] pci_bus 0000:08: resource 1 [mem 0x94900000-0x958fffff]
<7>[    9.110116] pci_bus 0000:08: resource 2 [mem 0x91900000-0x928fffff 64bit pref]
<7>[    9.118936] pci_bus 0000:0b: resource 0 [io  0x1000-0x1fff]
<7>[    9.125563] pci_bus 0000:0b: resource 1 [mem 0x93900000-0x948fffff]
<7>[    9.132970] pci_bus 0000:0b: resource 2 [mem 0x92900000-0x938fffff 64bit pref]
<7>[    9.141775] pci_bus 0000:10: resource 0 [io  0x7000-0x7fff]
<7>[    9.148403] pci_bus 0000:10: resource 1 [mem 0x95e00000-0x95ffffff]
<7>[    9.155813] pci_bus 0000:10: resource 2 [mem 0x96000000-0x961fffff 64bit pref]
<7>[    9.164631] pci_bus 0000:11: resource 0 [io  0x8000-0x8fff]
<7>[    9.171271] pci_bus 0000:11: resource 1 [mem 0x91000000-0x918fffff]
<7>[    9.178685] pci_bus 0000:11: resource 2 [mem 0x90000000-0x90ffffff 64bit pref]
<7>[    9.187505] pci_bus 0000:12: resource 4 [io  0x0000-0x0cf7]
<7>[    9.194134] pci_bus 0000:12: resource 5 [io  0x1000-0x9fff]
<7>[    9.200765] pci_bus 0000:12: resource 6 [mem 0x000a0000-0x000bffff]
<7>[    9.208166] pci_bus 0000:12: resource 7 [mem 0xfed40000-0xfedfffff]
<7>[    9.215581] pci_bus 0000:12: resource 8 [mem 0x90000000-0xafffffff]
<7>[    9.222984] pci_bus 0000:12: resource 9 [mem 0xfc000000000-0xfc07fffffff]
<6>[    9.231020] pci 0000:80:00.0: PCI bridge to [bus 81]
<6>[    9.236976] pci 0000:80:01.0: PCI bridge to [bus 82]
<6>[    9.242942] pci 0000:80:03.0: PCI bridge to [bus 83]
<6>[    9.248903] pci 0000:80:07.0: PCI bridge to [bus 84-86]
<6>[    9.255155] pci 0000:80:07.0:   bridge window [io  0xb000-0xbfff]
<6>[    9.262378] pci 0000:80:07.0:   bridge window [mem 0xb3000000-0xb3ffffff]
<6>[    9.270385] pci 0000:80:07.0:   bridge window [mem 0xb0000000-0xb0ffffff 64bit pref]
<6>[    9.279783] pci 0000:80:09.0: PCI bridge to [bus 87-89]
<6>[    9.286032] pci 0000:80:09.0:   bridge window [io  0xa000-0xafff]
<6>[    9.293244] pci 0000:80:09.0:   bridge window [mem 0xb2000000-0xb2ffffff]
<6>[    9.301245] pci 0000:80:09.0:   bridge window [mem 0xb1000000-0xb1ffffff 64bit pref]
<7>[    9.310638] pci_bus 0000:80: resource 4 [io  0xa000-0xffff]
<7>[    9.317280] pci_bus 0000:80: resource 5 [mem 0xb0000000-0xfbffffff]
<7>[    9.324698] pci_bus 0000:80: resource 6 [mem 0xfc080000000-0xfc0ffffffff]
<7>[    9.332698] pci_bus 0000:84: resource 0 [io  0xb000-0xbfff]
<7>[    9.339339] pci_bus 0000:84: resource 1 [mem 0xb3000000-0xb3ffffff]
<7>[    9.346747] pci_bus 0000:84: resource 2 [mem 0xb0000000-0xb0ffffff 64bit pref]
<7>[    9.355565] pci_bus 0000:87: resource 0 [io  0xa000-0xafff]
<7>[    9.362197] pci_bus 0000:87: resource 1 [mem 0xb2000000-0xb2ffffff]
<7>[    9.369613] pci_bus 0000:87: resource 2 [mem 0xb1000000-0xb1ffffff 64bit pref]
<6>[    9.378529] NET: Registered protocol family 2
<6>[    9.384684] TCP established hash table entries: 524288 (order: 10, 4194304 bytes)
<6>[    9.394932] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
<6>[    9.403094] TCP: Hash tables configured (established 524288 bind 65536)
<6>[    9.411004] TCP: reno registered
<6>[    9.415227] UDP hash table entries: 65536 (order: 9, 2097152 bytes)
<6>[    9.423300] UDP-Lite hash table entries: 65536 (order: 9, 2097152 bytes)
<6>[    9.432118] NET: Registered protocol family 1
<6>[    9.437787] RPC: Registered named UNIX socket transport module.
<6>[    9.444820] RPC: Registered udp transport module.
<6>[    9.450477] RPC: Registered tcp transport module.
<6>[    9.456143] RPC: Registered tcp NFSv4.1 backchannel transport module.
<7>[    9.518290] IOAPIC[0]: Set routing entry (8-16 -> 0x41 -> IRQ 16 Mode:1 Active:1 Dest:0)
<7>[    9.528408] IOAPIC[0]: Set routing entry (8-21 -> 0x51 -> IRQ 21 Mode:1 Active:1 Dest:0)
<7>[    9.538514] IOAPIC[0]: Set routing entry (8-19 -> 0x61 -> IRQ 19 Mode:1 Active:1 Dest:0)
<7>[    9.548638] IOAPIC[0]: Set routing entry (8-18 -> 0x71 -> IRQ 18 Mode:1 Active:1 Dest:0)
<7>[    9.558766] IOAPIC[0]: Set routing entry (8-23 -> 0x81 -> IRQ 23 Mode:1 Active:1 Dest:0)
<7>[    9.569702] pci 0000:11:00.0: Boot video device
<7>[    9.575494] PCI: CLS 64 bytes, default 64
<6>[    9.580424] Trying to unpack rootfs image as initramfs...
<6>[   14.246348] Freeing initrd memory: 212912K (ffff88006e448000 - ffff88007b434000)
<6>[   14.255384] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
<6>[   14.263002] software IO TLB [mem 0x6a448000-0x6e448000] (64MB) mapped at [ffff88006a448000-ffff88006e447fff]
<6>[   14.283170] Scanning for low memory corruption every 60 seconds
<6>[   14.292421] sha1_ssse3: Using SSSE3 optimized SHA-1 implementation
<6>[   14.299807] PCLMULQDQ-NI instructions are not detected.
<6>[   14.306057] AVX or AES-NI instructions are not detected.
<6>[   14.312397] AVX instructions are not detected.
<6>[   14.317763] AVX instructions are not detected.
<6>[   14.323126] AVX instructions are not detected.
<6>[   14.328480] AVX instructions are not detected.
<6>[   14.336197] futex hash table entries: 32768 (order: 9, 2097152 bytes)
<4>[   14.372452] bounce pool size: 64 pages
<6>[   14.377048] HugeTLB registered 2 MB page size, pre-allocated 0 pages
<5>[   14.387627] VFS: Disk quotas dquot_6.5.2
<4>[   14.392523] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
<5>[   14.401907] NFS: Registering the id_resolver key type
<5>[   14.407983] Key type id_resolver registered
<5>[   14.413065] Key type id_legacy registered
<6>[   14.417957] nfs4filelayout_init: NFSv4 File Layout Driver Registering...
<6>[   14.425858] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
<6>[   14.434223] ROMFS MTD (C) 2007 Red Hat, Inc.
<6>[   14.439500] fuse init (API version 7.22)
<6>[   14.444532] SGI XFS with ACLs, security attributes, realtime, large block/inode numbers, no debug enabled
<6>[   14.457230] msgmni has been set to 32768
<6>[   14.466203] NET: Registered protocol family 38
<5>[   14.471592] Key type asymmetric registered
<6>[   14.476684] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 250)
<6>[   14.485945] io scheduler noop registered
<6>[   14.490738] io scheduler deadline registered
<6>[   14.495915] io scheduler cfq registered (default)
<7>[   14.502414] IOAPIC[1]: Set routing entry (9-4 -> 0x91 -> IRQ 28 Mode:1 Active:1 Dest:0)
<7>[   14.512166] pcieport 0000:00:01.0: irq 88 for MSI/MSI-X
<7>[   14.518647] IOAPIC[1]: Set routing entry (9-5 -> 0xb1 -> IRQ 29 Mode:1 Active:1 Dest:0)
<7>[   14.528348] pcieport 0000:00:02.0: irq 89 for MSI/MSI-X
<7>[   14.534829] IOAPIC[1]: Set routing entry (9-0 -> 0xd1 -> IRQ 24 Mode:1 Active:1 Dest:0)
<7>[   14.544561] pcieport 0000:00:03.0: irq 90 for MSI/MSI-X
<7>[   14.551044] IOAPIC[1]: Set routing entry (9-2 -> 0x22 -> IRQ 26 Mode:1 Active:1 Dest:0)
<7>[   14.560760] pcieport 0000:00:05.0: irq 91 for MSI/MSI-X
<7>[   14.567244] IOAPIC[1]: Set routing entry (9-6 -> 0x52 -> IRQ 30 Mode:1 Active:1 Dest:0)
<7>[   14.576942] pcieport 0000:00:07.0: irq 92 for MSI/MSI-X
<7>[   14.583454] IOAPIC[1]: Set routing entry (9-8 -> 0x72 -> IRQ 32 Mode:1 Active:1 Dest:0)
<7>[   14.593193] pcieport 0000:00:09.0: irq 93 for MSI/MSI-X
<7>[   14.599670] IOAPIC[1]: Set routing entry (9-9 -> 0x92 -> IRQ 33 Mode:1 Active:1 Dest:0)
<7>[   14.609382] pcieport 0000:00:0a.0: irq 94 for MSI/MSI-X
<7>[   14.615883] pcieport 0000:00:1c.0: irq 95 for MSI/MSI-X
<7>[   14.622421] pcieport 0000:00:1c.4: irq 96 for MSI/MSI-X
<7>[   14.628919] IOAPIC[2]: Set routing entry (10-23 -> 0xd2 -> IRQ 71 Mode:1 Active:1 Dest:0)
<7>[   14.638835] pcieport 0000:80:00.0: irq 97 for MSI/MSI-X
<7>[   14.645282] IOAPIC[2]: Set routing entry (10-4 -> 0x23 -> IRQ 52 Mode:1 Active:1 Dest:0)
<7>[   14.655099] pcieport 0000:80:01.0: irq 98 for MSI/MSI-X
<7>[   14.661542] IOAPIC[2]: Set routing entry (10-0 -> 0x53 -> IRQ 48 Mode:1 Active:1 Dest:0)
<7>[   14.671349] pcieport 0000:80:03.0: irq 99 for MSI/MSI-X
<7>[   14.677796] IOAPIC[2]: Set routing entry (10-6 -> 0x73 -> IRQ 54 Mode:1 Active:1 Dest:0)
<7>[   14.687607] pcieport 0000:80:07.0: irq 100 for MSI/MSI-X
<7>[   14.694146] IOAPIC[2]: Set routing entry (10-8 -> 0x93 -> IRQ 56 Mode:1 Active:1 Dest:0)
<7>[   14.703960] pcieport 0000:80:09.0: irq 101 for MSI/MSI-X
<6>[   14.710436] pcieport 0000:00:01.0: Signaling PME through PCIe PME interrupt
<6>[   14.718626] pci 0000:01:00.0: Signaling PME through PCIe PME interrupt
<6>[   14.726328] pci 0000:01:00.1: Signaling PME through PCIe PME interrupt
<7>[   14.734031] pcie_pme 0000:00:01.0:pcie01: service driver pcie_pme loaded
<6>[   14.741959] pcieport 0000:00:02.0: Signaling PME through PCIe PME interrupt
<6>[   14.750149] pci 0000:04:00.0: Signaling PME through PCIe PME interrupt
<6>[   14.757851] pci 0000:04:00.1: Signaling PME through PCIe PME interrupt
<7>[   14.765561] pcie_pme 0000:00:02.0:pcie01: service driver pcie_pme loaded
<6>[   14.773487] pcieport 0000:00:03.0: Signaling PME through PCIe PME interrupt
<6>[   14.781684] pci 0000:07:00.0: Signaling PME through PCIe PME interrupt
<7>[   14.789394] pcie_pme 0000:00:03.0:pcie01: service driver pcie_pme loaded
<6>[   14.797306] pcieport 0000:00:05.0: Signaling PME through PCIe PME interrupt
<7>[   14.805507] pcie_pme 0000:00:05.0:pcie01: service driver pcie_pme loaded
<6>[   14.813431] pcieport 0000:00:07.0: Signaling PME through PCIe PME interrupt
<7>[   14.821618] pcie_pme 0000:00:07.0:pcie01: service driver pcie_pme loaded
<6>[   14.829530] pcieport 0000:00:09.0: Signaling PME through PCIe PME interrupt
<7>[   14.837722] pcie_pme 0000:00:09.0:pcie01: service driver pcie_pme loaded
<6>[   14.845637] pcieport 0000:00:0a.0: Signaling PME through PCIe PME interrupt
<7>[   14.853834] pcie_pme 0000:00:0a.0:pcie01: service driver pcie_pme loaded
<6>[   14.861755] pcieport 0000:00:1c.0: Signaling PME through PCIe PME interrupt
<7>[   14.869954] pcie_pme 0000:00:1c.0:pcie01: service driver pcie_pme loaded
<6>[   14.877877] pcieport 0000:00:1c.4: Signaling PME through PCIe PME interrupt
<6>[   14.886073] pci 0000:11:00.0: Signaling PME through PCIe PME interrupt
<7>[   14.893786] pcie_pme 0000:00:1c.4:pcie01: service driver pcie_pme loaded
<6>[   14.901717] pcieport 0000:80:00.0: Signaling PME through PCIe PME interrupt
<7>[   14.909917] pcie_pme 0000:80:00.0:pcie01: service driver pcie_pme loaded
<6>[   14.926162] pcieport 0000:80:01.0: Signaling PME through PCIe PME interrupt
<7>[   14.934361] pcie_pme 0000:80:01.0:pcie01: service driver pcie_pme loaded
<6>[   14.942278] pcieport 0000:80:03.0: Signaling PME through PCIe PME interrupt
<7>[   14.950465] pcie_pme 0000:80:03.0:pcie01: service driver pcie_pme loaded
<6>[   14.958381] pcieport 0000:80:07.0: Signaling PME through PCIe PME interrupt
<7>[   14.966572] pcie_pme 0000:80:07.0:pcie01: service driver pcie_pme loaded
<6>[   14.974495] pcieport 0000:80:09.0: Signaling PME through PCIe PME interrupt
<7>[   14.982682] pcie_pme 0000:80:09.0:pcie01: service driver pcie_pme loaded
<4>[   14.990609] ioapic: probe of 0000:00:13.0 failed with error -22
<4>[   14.997644] ioapic: probe of 0000:00:15.0 failed with error -22
<4>[   15.004679] ioapic: probe of 0000:80:13.0 failed with error -22
<4>[   15.011712] ioapic: probe of 0000:80:15.0 failed with error -22
<6>[   15.018764] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
<6>[   15.025447] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
<7>[   15.033256] intel_idle: MWAIT substates: 0x1120
<7>[   15.038717] intel_idle: v0.4 model 0x2F
<7>[   15.043408] intel_idle: lapic_timer_reliable_states 0xffffffff
<6>[   15.054759] input: Sleep Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0E:00/input/input0
<6>[   15.064826] ACPI: Sleep Button [SLPB]
<6>[   15.069407] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
<6>[   15.078424] ACPI: Power Button [PWRF]
<6>[   15.083062] ERST: Error Record Serialization Table (ERST) support is initialized.
<6>[   15.092176] pstore: Registered erst as persistent store backend
<6>[   15.100564] ghes_edac: This EDAC driver relies on BIOS to enumerate memory and get error reports.
<6>[   15.111212] ghes_edac: Unfortunately, not all BIOSes reflect the memory layout correctly.
<6>[   15.121081] ghes_edac: So, the end result of using this driver varies from vendor to vendor.
<6>[   15.131255] ghes_edac: If you find incorrect reports, please contact your hardware vendor
<6>[   15.141143] ghes_edac: to correct its BIOS.
<6>[   15.146225] ghes_edac: This system has 64 DIMM sockets.
<6>[   15.155496] EDAC MC0: Giving out device to module ghes_edac.c controller ghes_edac: DEV ghes (INTERRUPT)
<6>[   15.168254] EDAC MC1: Giving out device to module ghes_edac.c controller ghes_edac: DEV ghes (INTERRUPT)
<6>[   15.181572] GHES: APEI firmware first mode is enabled by APEI bit and WHEA _OSC.
<6>[   15.190600] EINJ: Error INJection is initialized.
<6>[   15.196394] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
<6>[   15.224345] 00:07: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
<6>[   15.253794] 00:08: ttyS1 at I/O 0x2f8 (irq = 3, base_baud = 115200) is a 16550A
<6>[   15.263443] Non-volatile memory driver v1.3
<6>[   15.272451] brd: module loaded
<6>[   15.277604] tsc: Refined TSC clocksource calibration: 2393.999 MHz
<6>[   15.277916] loop: module loaded
<6>[   15.278214] lkdtm: No crash points registered, enable through debugfs
<4>[   15.278300] ACPI Warning: SystemIO range 0x0000000000000428-0x000000000000042f conflicts with OpRegion 0x0000000000000428-0x000000000000042f (\GPE0) (20140214/utaddress-258)
<6>[   15.278310] ACPI: If an ACPI driver is available for this device, you should use it instead of the native driver
<4>[   15.278316] ACPI Warning: SystemIO range 0x0000000000000500-0x000000000000052f conflicts with OpRegion 0x000000000000052c-0x000000000000052c (\GPIV) (20140214/utaddress-258)
<4>[   15.278319] ACPI Warning: SystemIO range 0x0000000000000500-0x000000000000052f conflicts with OpRegion 0x0000000000000500-0x000000000000052f (\_SI_.SIOR) (20140214/utaddress-258)
<6>[   15.278321] ACPI: If an ACPI driver is available for this device, you should use it instead of the native driver
<4>[   15.278353] lpc_ich: Resource conflict(s) found affecting gpio_ich
<6>[   15.278606] Loading iSCSI transport class v2.0-870.
<6>[   15.279201] Adaptec aacraid driver 1.2-0[30300]-ms
<5>[   15.279265] aic94xx: Adaptec aic94xx SAS/SATA driver version 1.0.3 loaded
<4>[   15.279368] qla2xxx [0000:00:00.0]-0005: : QLogic Fibre Channel HBA Driver: 8.07.00.02-k.
<6>[   15.279451] megaraid cmm: 2.20.2.7 (Release Date: Sun Jul 16 00:01:03 EST 2006)
<6>[   15.279588] megaraid: 2.20.5.1 (Release Date: Thu Nov 16 15:32:35 EST 2006)
<6>[   15.279627] megasas: 06.803.01.00-rc1 Mon. Mar. 10 17:00:00 PDT 2014
<6>[   15.279645] megasas: 0x1000:0x0079:0x8086:0x9256: bus 7:slot 0:func 0
<6>[   15.280103] megasas: FW now in Ready state
<7>[   15.280129] megaraid_sas 0000:07:00.0: irq 102 for MSI/MSI-X
<6>[   15.280142] megaraid_sas 0000:07:00.0: [scsi0]: FW supports<0> MSIX vector,Online CPUs: <80>,Current MSIX <1>
<5>[   15.349727] megasas_init_mfi: fw_support_ieee=0
<3>[   15.349727] megasas: INIT adapter done
<6>[   15.421783] megaraid_sas 0000:07:00.0: Controller type: MR,Memory size is: 512MB
<6>[   15.421800] scsi0 : LSI SAS based MegaRAID driver
<4>[   15.422099] GDT-HA: Storage RAID Controller Driver. Version: 3.05
<6>[   15.422165] RocketRAID 3xxx/4xxx Controller driver v1.8
<7>[   15.422540] ata_piix 0000:00:1f.2: version 2.13
<6>[   15.422774] ata_piix 0000:00:1f.2: MAP [ P0 P2 P1 P3 ]
<6>[   15.424205] scsi1 : ata_piix
<6>[   15.424688] scsi2 : ata_piix
<6>[   15.424775] ata1: SATA max UDMA/133 cmd 0x6138 ctl 0x614c bmdma 0x6110 irq 19
<6>[   15.424780] ata2: SATA max UDMA/133 cmd 0x6130 ctl 0x6148 bmdma 0x6118 irq 19
<6>[   15.424963] ata_piix 0000:00:1f.5: MAP [ P0 -- P1 -- ]
<5>[   15.425071] scsi 0:0:25:0: Direct-Access     SEAGATE  ST9300603SS      0006 PQ: 0 ANSI: 5
<5>[   15.425560] scsi 0:0:26:0: Direct-Access     ATA      SSDSA2SH032G1GN  8621 PQ: 0 ANSI: 5
<5>[   15.446984] scsi 0:2:0:0: Direct-Access     INTEL    RS2BL080DE       2.70 PQ: 0 ANSI: 5
<5>[   15.447255] scsi 0:2:2:0: Direct-Access     INTEL    RS2BL080DE       2.70 PQ: 0 ANSI: 5
<5>[   15.458156] sd 0:2:0:0: [sda] 583983104 512-byte logical blocks: (298 GB/278 GiB)
<5>[   15.458236] sd 0:2:0:0: Attached scsi generic sg0 type 0
<5>[   15.458398] sd 0:2:0:0: [sda] Write Protect is off
<7>[   15.458401] sd 0:2:0:0: [sda] Mode Sense: 1f 00 10 08
<5>[   15.458525] sd 0:2:0:0: [sda] Write cache: disabled, read cache: enabled, supports DPO and FUA
<5>[   15.458599] sd 0:2:2:0: Attached scsi generic sg1 type 0
<5>[   15.458839] sd 0:2:2:0: [sdb] 57376768 512-byte logical blocks: (29.3 GB/27.3 GiB)
<5>[   15.458958] sd 0:2:2:0: [sdb] Write Protect is off
<7>[   15.458960] sd 0:2:2:0: [sdb] Mode Sense: 1f 00 10 08
<5>[   15.459081] sd 0:2:2:0: [sdb] Write cache: disabled, read cache: enabled, supports DPO and FUA
<6>[   15.460590]  sdb: sdb1 sdb9
<5>[   15.461561] sd 0:2:2:0: [sdb] Attached SCSI disk
<6>[   15.470698]  sda: sda1
<6>[   15.470698]  sda1: <solaris: [s0] sda5 [s2] sda6 [s8] sda7 >
<5>[   15.472054] sd 0:2:0:0: [sda] Attached SCSI disk
<6>[   15.578959] scsi3 : ata_piix
<6>[   15.579520] scsi4 : ata_piix
<6>[   15.579601] ata3: SATA max UDMA/133 cmd 0x6128 ctl 0x6144 bmdma 0x60f0 irq 21
<6>[   15.579604] ata4: SATA max UDMA/133 cmd 0x6120 ctl 0x6140 bmdma 0x60f8 irq 21
<6>[   15.579808] tun: Universal TUN/TAP device driver, 1.6
<6>[   15.579808] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
<6>[   15.580181] pcnet32: pcnet32.c:v1.35 21.Apr.2008 tsbogend@alpha.franken.de
<6>[   15.580248] Atheros(R) L2 Ethernet Driver - version 2.2.3
<6>[   15.580248] Copyright (c) 2007 Atheros Corporation.
<6>[   15.580476] dmfe: Davicom DM9xxx net driver, version 1.36.4 (2002-01-17)
<4>[   15.580512] v1.01-e (2.4 port) Sep-11-2006  Donald Becker <becker@scyld.com>
<4>[   15.580512]   http://www.scyld.com/network/drivers.html
<6>[   15.580624] uli526x: ULi M5261/M5263 net driver, version 0.9.3 (2005-7-29)
<6>[   15.580704] e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
<6>[   15.580705] e100: Copyright(c) 1999-2006 Intel Corporation
<6>[   15.580764] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-NAPI
<6>[   15.580764] e1000: Copyright (c) 1999-2006 Intel Corporation.
<6>[   15.580823] e1000e: Intel(R) PRO/1000 Network Driver - 2.3.2-k
<6>[   15.580823] e1000e: Copyright(c) 1999 - 2014 Intel Corporation.
<6>[   15.580900] igb: Intel(R) Gigabit Ethernet Network Driver - version 5.0.5-k
<6>[   15.580901] igb: Copyright (c) 2007-2014 Intel Corporation.
<7>[   15.581266] igb 0000:01:00.0: irq 103 for MSI/MSI-X
<7>[   15.581287] igb 0000:01:00.0: irq 104 for MSI/MSI-X
<7>[   15.581296] igb 0000:01:00.0: irq 105 for MSI/MSI-X
<7>[   15.581306] igb 0000:01:00.0: irq 106 for MSI/MSI-X
<7>[   15.581315] igb 0000:01:00.0: irq 107 for MSI/MSI-X
<7>[   15.581324] igb 0000:01:00.0: irq 108 for MSI/MSI-X
<7>[   15.581342] igb 0000:01:00.0: irq 109 for MSI/MSI-X
<7>[   15.581352] igb 0000:01:00.0: irq 110 for MSI/MSI-X
<7>[   15.581361] igb 0000:01:00.0: irq 111 for MSI/MSI-X
<7>[   15.581445] igb 0000:01:00.0: irq 103 for MSI/MSI-X
<7>[   15.581454] igb 0000:01:00.0: irq 104 for MSI/MSI-X
<7>[   15.581463] igb 0000:01:00.0: irq 105 for MSI/MSI-X
<7>[   15.581472] igb 0000:01:00.0: irq 106 for MSI/MSI-X
<7>[   15.581481] igb 0000:01:00.0: irq 107 for MSI/MSI-X
<7>[   15.581489] igb 0000:01:00.0: irq 108 for MSI/MSI-X
<7>[   15.581499] igb 0000:01:00.0: irq 109 for MSI/MSI-X
<7>[   15.581508] igb 0000:01:00.0: irq 110 for MSI/MSI-X
<7>[   15.581517] igb 0000:01:00.0: irq 111 for MSI/MSI-X
<6>[   15.773191] igb 0000:01:00.0: added PHC on eth0
<6>[   15.773192] igb 0000:01:00.0: Intel(R) Gigabit Ethernet Network Connection
<6>[   15.773195] igb 0000:01:00.0: eth0: (PCIe:2.5Gb/s:Width x2) 60:eb:69:82:38:2a
<6>[   15.773199] igb 0000:01:00.0: eth0: PBA No: Unknown
<6>[   15.773200] igb 0000:01:00.0: Using MSI-X interrupts. 8 rx queue(s), 8 tx queue(s)
<7>[   15.773284] IOAPIC[1]: Set routing entry (9-16 -> 0x65 -> IRQ 40 Mode:1 Active:1 Dest:0)
<7>[   15.773571] igb 0000:01:00.1: irq 112 for MSI/MSI-X
<7>[   15.773581] igb 0000:01:00.1: irq 113 for MSI/MSI-X
<7>[   15.773590] igb 0000:01:00.1: irq 114 for MSI/MSI-X
<7>[   15.773614] igb 0000:01:00.1: irq 115 for MSI/MSI-X
<7>[   15.773623] igb 0000:01:00.1: irq 116 for MSI/MSI-X
<7>[   15.773643] igb 0000:01:00.1: irq 117 for MSI/MSI-X
<7>[   15.773652] igb 0000:01:00.1: irq 118 for MSI/MSI-X
<7>[   15.773662] igb 0000:01:00.1: irq 119 for MSI/MSI-X
<7>[   15.773671] igb 0000:01:00.1: irq 120 for MSI/MSI-X
<7>[   15.773756] igb 0000:01:00.1: irq 112 for MSI/MSI-X
<7>[   15.773765] igb 0000:01:00.1: irq 113 for MSI/MSI-X
<7>[   15.773774] igb 0000:01:00.1: irq 114 for MSI/MSI-X
<7>[   15.773783] igb 0000:01:00.1: irq 115 for MSI/MSI-X
<7>[   15.773792] igb 0000:01:00.1: irq 116 for MSI/MSI-X
<7>[   15.773801] igb 0000:01:00.1: irq 117 for MSI/MSI-X
<7>[   15.773810] igb 0000:01:00.1: irq 118 for MSI/MSI-X
<7>[   15.773819] igb 0000:01:00.1: irq 119 for MSI/MSI-X
<7>[   15.773828] igb 0000:01:00.1: irq 120 for MSI/MSI-X
<6>[   15.908840] ata3: SATA link down (SStatus 4 SControl 300)
<6>[   15.962629] igb 0000:01:00.1: added PHC on eth1
<6>[   15.962631] igb 0000:01:00.1: Intel(R) Gigabit Ethernet Network Connection
<6>[   15.962633] igb 0000:01:00.1: eth1: (PCIe:2.5Gb/s:Width x2) 60:eb:69:82:38:2b
<6>[   15.962636] igb 0000:01:00.1: eth1: PBA No: Unknown
<6>[   15.962638] igb 0000:01:00.1: Using MSI-X interrupts. 8 rx queue(s), 8 tx queue(s)
<7>[   15.962968] igb 0000:04:00.0: irq 121 for MSI/MSI-X
<7>[   15.962978] igb 0000:04:00.0: irq 122 for MSI/MSI-X
<7>[   15.962996] igb 0000:04:00.0: irq 123 for MSI/MSI-X
<7>[   15.963006] igb 0000:04:00.0: irq 124 for MSI/MSI-X
<7>[   15.963015] igb 0000:04:00.0: irq 125 for MSI/MSI-X
<7>[   15.963024] igb 0000:04:00.0: irq 126 for MSI/MSI-X
<7>[   15.963033] igb 0000:04:00.0: irq 127 for MSI/MSI-X
<7>[   15.963044] igb 0000:04:00.0: irq 128 for MSI/MSI-X
<7>[   15.963053] igb 0000:04:00.0: irq 129 for MSI/MSI-X
<7>[   15.963134] igb 0000:04:00.0: irq 121 for MSI/MSI-X
<7>[   15.963143] igb 0000:04:00.0: irq 122 for MSI/MSI-X
<7>[   15.963152] igb 0000:04:00.0: irq 123 for MSI/MSI-X
<7>[   15.963161] igb 0000:04:00.0: irq 124 for MSI/MSI-X
<7>[   15.963170] igb 0000:04:00.0: irq 125 for MSI/MSI-X
<7>[   15.963179] igb 0000:04:00.0: irq 126 for MSI/MSI-X
<7>[   15.963188] igb 0000:04:00.0: irq 127 for MSI/MSI-X
<7>[   15.963197] igb 0000:04:00.0: irq 128 for MSI/MSI-X
<7>[   15.963206] igb 0000:04:00.0: irq 129 for MSI/MSI-X
<6>[   16.062149] ata4: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
<6>[   16.070357] ata4.00: ATAPI: HL-DT-STDVDRAM GT32N, AS00, max UDMA/100
<6>[   16.072973] ata2.00: SATA link down (SStatus 0 SControl 300)
<6>[   16.072991] ata2.01: SATA link down (SStatus 0 SControl 300)
<6>[   16.083890] ata1.00: SATA link down (SStatus 0 SControl 300)
<6>[   16.083909] ata1.01: SATA link down (SStatus 0 SControl 300)
<6>[   16.086296] ata4.00: configured for UDMA/100
<5>[   16.089850] scsi 4:0:0:0: CD-ROM            HL-DT-ST DVDRAM GT32N     AS00 PQ: 0 ANSI: 5
<5>[   16.090135] scsi 4:0:0:0: Attached scsi generic sg2 type 5
<6>[   16.154643] igb 0000:04:00.0: added PHC on eth2
<6>[   16.154644] igb 0000:04:00.0: Intel(R) Gigabit Ethernet Network Connection
<6>[   16.154646] igb 0000:04:00.0: eth2: (PCIe:2.5Gb/s:Width x2) 60:eb:69:82:38:2c
<6>[   16.154649] igb 0000:04:00.0: eth2: PBA No: Unknown
<6>[   16.154651] igb 0000:04:00.0: Using MSI-X interrupts. 8 rx queue(s), 8 tx queue(s)
<7>[   16.154716] IOAPIC[1]: Set routing entry (9-17 -> 0x78 -> IRQ 41 Mode:1 Active:1 Dest:0)
<7>[   16.154991] igb 0000:04:00.1: irq 130 for MSI/MSI-X
<7>[   16.155000] igb 0000:04:00.1: irq 131 for MSI/MSI-X
<7>[   16.155010] igb 0000:04:00.1: irq 132 for MSI/MSI-X
<7>[   16.155019] igb 0000:04:00.1: irq 133 for MSI/MSI-X
<7>[   16.155042] igb 0000:04:00.1: irq 134 for MSI/MSI-X
<7>[   16.155051] igb 0000:04:00.1: irq 135 for MSI/MSI-X
<7>[   16.155061] igb 0000:04:00.1: irq 136 for MSI/MSI-X
<7>[   16.155070] igb 0000:04:00.1: irq 137 for MSI/MSI-X
<7>[   16.155079] igb 0000:04:00.1: irq 138 for MSI/MSI-X
<7>[   16.155158] igb 0000:04:00.1: irq 130 for MSI/MSI-X
<7>[   16.155167] igb 0000:04:00.1: irq 131 for MSI/MSI-X
<7>[   16.155176] igb 0000:04:00.1: irq 132 for MSI/MSI-X
<7>[   16.155185] igb 0000:04:00.1: irq 133 for MSI/MSI-X
<7>[   16.155194] igb 0000:04:00.1: irq 134 for MSI/MSI-X
<7>[   16.155203] igb 0000:04:00.1: irq 135 for MSI/MSI-X
<7>[   16.155212] igb 0000:04:00.1: irq 136 for MSI/MSI-X
<7>[   16.155221] igb 0000:04:00.1: irq 137 for MSI/MSI-X
<7>[   16.155230] igb 0000:04:00.1: irq 138 for MSI/MSI-X
<6>[   16.346724] igb 0000:04:00.1: added PHC on eth3
<6>[   16.346725] igb 0000:04:00.1: Intel(R) Gigabit Ethernet Network Connection
<6>[   16.346727] igb 0000:04:00.1: eth3: (PCIe:2.5Gb/s:Width x2) 60:eb:69:82:38:2d
<6>[   16.346730] igb 0000:04:00.1: eth3: PBA No: Unknown
<6>[   16.346732] igb 0000:04:00.1: Using MSI-X interrupts. 8 rx queue(s), 8 tx queue(s)
<6>[   16.346808] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - version 3.19.1-k
<6>[   16.346809] ixgbe: Copyright (c) 1999-2014 Intel Corporation.
<6>[   16.346874] ixgb: Intel(R) PRO/10GbE Network Driver - version 1.0.135-k2-NAPI
<6>[   16.346874] ixgb: Copyright (c) 1999-2008 Intel Corporation.
<6>[   16.346957] sky2: driver version 1.30
<6>[   16.347314] usbcore: registered new interface driver catc
<6>[   16.347329] usbcore: registered new interface driver kaweth
<6>[   16.347331] pegasus: v0.9.3 (2013/04/25), Pegasus/Pegasus II USB Ethernet driver
<6>[   16.347341] usbcore: registered new interface driver pegasus
<6>[   16.347351] usbcore: registered new interface driver rtl8150
<6>[   16.347365] usbcore: registered new interface driver asix
<6>[   16.347376] usbcore: registered new interface driver ax88179_178a
<6>[   16.347393] usbcore: registered new interface driver cdc_ether
<6>[   16.347408] usbcore: registered new interface driver cdc_eem
<6>[   16.347419] usbcore: registered new interface driver dm9601
<6>[   16.347434] usbcore: registered new interface driver smsc75xx
<6>[   16.347450] usbcore: registered new interface driver smsc95xx
<6>[   16.347465] usbcore: registered new interface driver gl620a
<6>[   16.347476] usbcore: registered new interface driver net1080
<6>[   16.347487] usbcore: registered new interface driver plusb
<6>[   16.347499] usbcore: registered new interface driver rndis_host
<6>[   16.347512] usbcore: registered new interface driver cdc_subset
<6>[   16.347524] usbcore: registered new interface driver zaurus
<6>[   16.347542] usbcore: registered new interface driver MOSCHIP usb-ethernet driver
<6>[   16.347557] usbcore: registered new interface driver int51x1
<6>[   16.347568] usbcore: registered new interface driver ipheth
<6>[   16.347582] usbcore: registered new interface driver sierra_net
<6>[   16.347597] usbcore: registered new interface driver cdc_ncm
<6>[   16.347598] Fusion MPT base driver 3.04.20
<6>[   16.347599] Copyright (c) 1999-2008 LSI Corporation
<6>[   16.347608] Fusion MPT SPI Host driver 3.04.20
<6>[   16.347652] Fusion MPT FC Host driver 3.04.20
<6>[   16.347697] Fusion MPT SAS Host driver 3.04.20
<6>[   16.347737] Fusion MPT misc device (ioctl) driver 3.04.20
<6>[   16.347786] mptctl: Registered with Fusion MPT base driver
<6>[   16.347787] mptctl: /dev/mptctl @ (major,minor=10,220)
<6>[   16.347952] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
<6>[   16.347956] ehci-pci: EHCI PCI platform driver
<6>[   16.348244] ehci-pci 0000:00:1a.7: EHCI Host Controller
<6>[   16.348315] ehci-pci 0000:00:1a.7: new USB bus registered, assigned bus number 1
<6>[   16.348339] ehci-pci 0000:00:1a.7: debug port 1
<7>[   16.352267] ehci-pci 0000:00:1a.7: cache line size of 64 is not supported
<6>[   16.352285] ehci-pci 0000:00:1a.7: irq 18, io mem 0x95c01000
<6>[   16.358276] ehci-pci 0000:00:1a.7: USB 2.0 started, EHCI 1.00
<6>[   16.358491] hub 1-0:1.0: USB hub found
<6>[   16.358511] hub 1-0:1.0: 6 ports detected
<6>[   16.358977] ehci-pci 0000:00:1d.7: EHCI Host Controller
<6>[   16.359126] ehci-pci 0000:00:1d.7: new USB bus registered, assigned bus number 2
<6>[   16.359141] ehci-pci 0000:00:1d.7: debug port 1
<7>[   16.363045] ehci-pci 0000:00:1d.7: cache line size of 64 is not supported
<6>[   16.363062] ehci-pci 0000:00:1d.7: irq 23, io mem 0x95c00000
<6>[   16.370286] ehci-pci 0000:00:1d.7: USB 2.0 started, EHCI 1.00
<6>[   16.370584] hub 2-0:1.0: USB hub found
<6>[   16.370589] hub 2-0:1.0: 6 ports detected
<6>[   16.370844] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
<6>[   16.370848] ohci-pci: OHCI PCI platform driver
<6>[   16.370882] uhci_hcd: USB Universal Host Controller Interface driver
<6>[   16.371080] uhci_hcd 0000:00:1a.0: UHCI Host Controller
<6>[   16.371232] uhci_hcd 0000:00:1a.0: new USB bus registered, assigned bus number 3
<6>[   16.371240] uhci_hcd 0000:00:1a.0: detected 2 ports
<6>[   16.371276] uhci_hcd 0000:00:1a.0: irq 16, io base 0x000060c0
<6>[   16.371563] hub 3-0:1.0: USB hub found
<6>[   16.371570] hub 3-0:1.0: 2 ports detected
<6>[   16.371901] uhci_hcd 0000:00:1a.1: UHCI Host Controller
<6>[   16.372046] uhci_hcd 0000:00:1a.1: new USB bus registered, assigned bus number 4
<6>[   16.372053] uhci_hcd 0000:00:1a.1: detected 2 ports
<6>[   16.372078] uhci_hcd 0000:00:1a.1: irq 21, io base 0x000060a0
<6>[   16.372361] hub 4-0:1.0: USB hub found
<6>[   16.372367] hub 4-0:1.0: 2 ports detected
<6>[   16.372691] uhci_hcd 0000:00:1a.2: UHCI Host Controller
<6>[   16.372837] uhci_hcd 0000:00:1a.2: new USB bus registered, assigned bus number 5
<6>[   16.372844] uhci_hcd 0000:00:1a.2: detected 2 ports
<6>[   16.372868] uhci_hcd 0000:00:1a.2: irq 19, io base 0x00006080
<6>[   16.373150] hub 5-0:1.0: USB hub found
<6>[   16.373155] hub 5-0:1.0: 2 ports detected
<6>[   16.373480] uhci_hcd 0000:00:1d.0: UHCI Host Controller
<6>[   16.373638] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 6
<6>[   16.373646] uhci_hcd 0000:00:1d.0: detected 2 ports
<6>[   16.373668] uhci_hcd 0000:00:1d.0: irq 23, io base 0x00006060
<6>[   16.373971] hub 6-0:1.0: USB hub found
<6>[   16.373977] hub 6-0:1.0: 2 ports detected
<6>[   16.374315] uhci_hcd 0000:00:1d.1: UHCI Host Controller
<6>[   16.374473] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 7
<6>[   16.374480] uhci_hcd 0000:00:1d.1: detected 2 ports
<6>[   16.374502] uhci_hcd 0000:00:1d.1: irq 19, io base 0x00006040
<6>[   16.374778] hub 7-0:1.0: USB hub found
<6>[   16.374784] hub 7-0:1.0: 2 ports detected
<6>[   16.375114] uhci_hcd 0000:00:1d.2: UHCI Host Controller
<6>[   16.375256] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 8
<6>[   16.375263] uhci_hcd 0000:00:1d.2: detected 2 ports
<6>[   16.375286] uhci_hcd 0000:00:1d.2: irq 18, io base 0x00006020
<6>[   16.375609] hub 8-0:1.0: USB hub found
<6>[   16.375615] hub 8-0:1.0: 2 ports detected
<6>[   16.375844] usbcore: registered new interface driver usb-storage
<6>[   16.375854] usbcore: registered new interface driver ums-alauda
<6>[   16.375865] usbcore: registered new interface driver ums-datafab
<6>[   16.375883] usbcore: registered new interface driver ums-freecom
<6>[   16.375904] usbcore: registered new interface driver ums-isd200
<6>[   16.375922] usbcore: registered new interface driver ums-jumpshot
<6>[   16.375934] usbcore: registered new interface driver ums-sddr09
<6>[   16.375945] usbcore: registered new interface driver ums-sddr55
<6>[   16.375957] usbcore: registered new interface driver ums-usbat
<6>[   16.375976] usbcore: registered new interface driver usbtest
<6>[   16.376034] i8042: PNP: No PS/2 controller found. Probing ports directly.
<3>[   17.405635] i8042: No controller found
<6>[   17.410609] mousedev: PS/2 mouse device common for all mice
<6>[   17.418387] rtc_cmos 00:02: RTC can wake from S4
<6>[   17.424332] rtc_cmos 00:02: rtc core: registered rtc_cmos as rtc0
<6>[   17.431581] rtc_cmos 00:02: alarms up to one month, y3k, 114 bytes nvram, hpet irqs
<6>[   17.440919] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.10
<6>[   17.447578] iTCO_wdt: unable to reset NO_REBOOT flag, device disabled by hardware/BIOS
<6>[   17.457172] iTCO_vendor_support: vendor-support=0
<6>[   17.463307] softdog: Software Watchdog Timer: 0.08 initialized. soft_noboot=0 soft_margin=60 sec soft_panic=0 (nowayout=0)
<6>[   17.476416] md: linear personality registered for level -1
<6>[   17.482949] md: raid0 personality registered for level 0
<6>[   17.489292] md: raid1 personality registered for level 1
<6>[   17.495640] md: raid10 personality registered for level 10
<6>[   17.502437] md: raid6 personality registered for level 6
<6>[   17.508784] md: raid5 personality registered for level 5
<6>[   17.515122] md: raid4 personality registered for level 4
<6>[   17.521456] md: multipath personality registered for level -4
<6>[   17.528279] md: faulty personality registered for level -5
<6>[   17.537057] device-mapper: ioctl: 4.27.0-ioctl (2013-10-30) initialised: dm-devel@redhat.com
<6>[   17.554338] device-mapper: multipath: version 1.7.0 loaded
<6>[   17.560897] device-mapper: multipath round-robin: version 1.0.0 loaded
<6>[   17.568622] device-mapper: cache-policy-mq: version 1.2.0 loaded
<6>[   17.575753] device-mapper: cache cleaner: version 1.0.0 loaded
<6>[   17.582809] dcdbas dcdbas: Dell Systems Management Base Driver (version 5.6.0-3.2)
<6>[   17.592392] usbcore: registered new interface driver usbhid
<6>[   17.599029] usbhid: USB HID core driver
<6>[   17.603973] TCP: bic registered
<6>[   17.607877] Initializing XFRM netlink socket
<6>[   17.613261] NET: Registered protocol family 10
<6>[   17.619155] sit: IPv6 over IPv4 tunneling driver
<6>[   17.624932] NET: Registered protocol family 17
<6>[   17.630335] 8021q: 802.1Q VLAN Support v1.8
<6>[   17.637012] DCCP: Activated CCID 2 (TCP-like)
<6>[   17.642304] DCCP: Activated CCID 3 (TCP-Friendly Rate Control)
<6>[   17.650030] sctp: Hash tables configured (established 65536 bind 65536)
<6>[   17.657956] tipc: Activated (version 2.0.0)
<6>[   17.663121] NET: Registered protocol family 30
<6>[   17.669939] tipc: Started in single node mode
<5>[   17.675231] Key type dns_resolver registered
<7>[   17.685148] 
<7>[   17.685148] printing PIC contents
<7>[   17.691241] ... PIC  IMR: ffff
<7>[   17.695054] ... PIC  IRR: 0c20
<7>[   17.698867] ... PIC  ISR: 0000
<7>[   17.702691] ... PIC ELCR: 0e20
<7>[   17.706612] printing local APIC contents on CPU#0/0:
<6>[   17.712559] ... APIC ID:      00000000 (0)
<6>[   17.717530] ... APIC VERSION: 01060015
<7>[   17.722108] ... APIC TASKPRI: 00000000 (00)
<7>[   17.727170] ... APIC PROCPRI: 00000000
<7>[   17.731740] ... APIC LDR: 01000000
<7>[   17.735914] ... APIC DFR: ffffffff
<7>[   17.740095] ... APIC SPIV: 000001ff
<7>[   17.744381] ... APIC ISR field:
<4>[   17.748262] 0000000000000000000000000000000000000000000000000000000000000000
<7>[   17.757082] ... APIC TMR field:
<4>[   17.760975] 0000000000000000000200000002000000000002000000000000000000000000
<7>[   17.769805] ... APIC IRR field:
<4>[   17.773704] 0000000000000000000000000000000000000000000000000000000000000000
<7>[   17.782536] ... APIC ESR: 00000000
<7>[   17.786724] ... APIC ICR: 000000fd
<7>[   17.790909] ... APIC ICR2: a1000000
<7>[   17.795199] ... APIC LVTT: 000000ef
<7>[   17.799487] ... APIC LVTPC: 00000400
<7>[   17.803869] ... APIC LVT0: 00010700
<7>[   17.808145] ... APIC LVT1: 00000400
<7>[   17.812432] ... APIC LVTERR: 000000fe
<7>[   17.816914] ... APIC TMICT: 7fffffff
<7>[   17.821289] ... APIC TMCCT: 7ff08fb4
<7>[   17.825665] ... APIC TDCR: 00000003
<4>[   17.829952] 
<7>[   17.832002] number of MP IRQ sources: 15.
<7>[   17.836887] number of IO-APIC #8 registers: 24.
<7>[   17.842346] number of IO-APIC #9 registers: 24.
<7>[   17.847813] number of IO-APIC #10 registers: 24.
<6>[   17.853379] testing the IO APIC.......................
<7>[   17.859524] IO APIC #8......
<7>[   17.863125] .... register #00: 08000000
<7>[   17.867808] .......    : physical APIC id: 08
<7>[   17.873081] .......    : Delivery Type: 0
<7>[   17.877957] .......    : LTS          : 0
<7>[   17.882845] .... register #01: 00170020
<7>[   17.887528] .......     : max redirection entries: 17
<7>[   17.893583] .......     : PRQ implemented: 0
<7>[   17.898763] .......     : IO APIC version: 20
<7>[   17.904041] .... IRQ redirection table:
<4>[   17.908733] 1    0    0   0   0    0    0    00
<4>[   17.914202] 0    0    0   0   0    0    0    31
<4>[   17.919676] 0    0    0   0   0    0    0    30
<4>[   17.925142] 0    0    0   0   0    0    0    33
<4>[   17.930617] 0    0    0   0   0    0    0    34
<4>[   17.936075] 0    0    0   0   0    0    0    35
<4>[   17.941537] 0    0    0   0   0    0    0    36
<4>[   17.947002] 0    0    0   0   0    0    0    37
<4>[   17.952472] 0    0    0   0   0    0    0    38
<4>[   17.957944] 0    1    0   0   0    0    0    39
<4>[   17.963420] 0    0    0   0   0    0    0    3A
<4>[   17.968895] 0    0    0   0   0    0    0    3B
<4>[   17.974367] 0    0    0   0   0    0    0    3C
<4>[   17.979832] 0    0    0   0   0    0    0    3D
<4>[   17.985300] 0    0    0   0   0    0    0    3E
<4>[   17.990771] 0    0    0   0   0    0    0    3F
<4>[   17.996237] 0    1    0   1   0    0    0    41
<4>[   18.001710] 1    0    0   0   0    0    0    00
<4>[   18.007167] 0    1    0   1   0    0    0    71
<4>[   18.012631] 0    1    0   1   0    0    0    61
<4>[   18.018096] 1    0    0   0   0    0    0    00
<4>[   18.023568] 0    1    0   1   0    0    0    51
<4>[   18.029041] 1    0    0   0   0    0    0    00
<4>[   18.034515] 0    1    0   1   0    0    0    81
<7>[   18.039990] IO APIC #9......
<7>[   18.043610] .... register #00: 09000000
<7>[   18.048300] .......    : physical APIC id: 09
<7>[   18.053574] .......    : Delivery Type: 0
<7>[   18.058457] .......    : LTS          : 0
<7>[   18.063331] .... register #01: 00170020
<7>[   18.068011] .......     : max redirection entries: 17
<7>[   18.074063] .......     : PRQ implemented: 0
<7>[   18.079225] .......     : IO APIC version: 20
<7>[   18.084489] .... register #02: 00000000
<7>[   18.089171] .......     : arbitration: 00
<7>[   18.094053] .... register #03: 00000001
<7>[   18.098747] .......     : Boot DT    : 1
<7>[   18.103538] .... IRQ redirection table:
<4>[   18.108233] 1    1    0   1   0    0    0    D1
<4>[   18.113703] 1    0    0   0   0    0    0    00
<4>[   18.119170] 1    1    0   1   0    0    0    22
<4>[   18.124636] 1    0    0   0   0    0    0    00
<4>[   18.130110] 1    1    0   1   0    0    0    91
<4>[   18.135569] 1    1    0   1   0    0    0    B1
<4>[   18.141031] 1    1    0   1   0    0    0    52
<4>[   18.146494] 1    0    0   0   0    0    0    00
<4>[   18.151957] 1    1    0   1   0    0    0    72
<4>[   18.157429] 1    1    0   1   0    0    0    92
<4>[   18.162901] 1    0    0   0   0    0    0    00
<4>[   18.168373] 1    0    0   0   0    0    0    00
<4>[   18.173845] 1    0    0   0   0    0    0    00
<4>[   18.179305] 1    0    0   0   0    0    0    00
<4>[   18.184774] 1    0    0   0   0    0    0    00
<4>[   18.190247] 1    0    0   0   0    0    0    00
<4>[   18.195717] 1    1    0   1   0    0    0    65
<4>[   18.201192] 1    1    0   1   0    0    0    78
<4>[   18.206653] 1    0    0   0   0    0    0    00
<4>[   18.212116] 1    0    0   0   0    0    0    00
<4>[   18.217581] 1    0    0   0   0    0    0    00
<4>[   18.223059] 1    0    0   0   0    0    0    00
<4>[   18.228577] 1    0    0   0   0    0    0    00
<4>[   18.234055] 1    0    0   0   0    0    0    00
<7>[   18.239539] IO APIC #10......
<7>[   18.243257] .... register #00: 0A000000
<7>[   18.248026] .......    : physical APIC id: 0A
<7>[   18.253308] .......    : Delivery Type: 0
<7>[   18.258198] .......    : LTS          : 0
<7>[   18.263086] .... register #01: 00170020
<7>[   18.267834] .......     : max redirection entries: 17
<7>[   18.273887] .......     : PRQ implemented: 0
<7>[   18.279068] .......     : IO APIC version: 20
<7>[   18.284408] .... register #02: 00000000
<7>[   18.289103] .......     : arbitration: 00
<7>[   18.293988] .... register #03: 00000001
<7>[   18.298686] .......     : Boot DT    : 1
<7>[   18.303544] .... IRQ redirection table:
<4>[   18.308244] 1    1    0   1   0    0    0    53
<4>[   18.313722] 1    0    0   0   0    0    0    00
<4>[   18.319188] 1    0    0   0   0    0    0    00
<4>[   18.324745] 1    0    0   0   0    0    0    00
<4>[   18.338695] 1    1    0   1   0    0    0    23
<4>[   18.344169] 1    0    0   0   0    0    0    00
<4>[   18.349633] 1    1    0   1   0    0    0    73
<4>[   18.355092] 1    0    0   0   0    0    0    00
<4>[   18.360572] 1    1    0   1   0    0    0    93
<4>[   18.366039] 1    0    0   0   0    0    0    00
<4>[   18.371590] 1    0    0   0   0    0    0    00
<4>[   18.377059] 1    0    0   0   0    0    0    00
<4>[   18.382534] 1    0    0   0   0    0    0    00
<4>[   18.388009] 1    0    0   0   0    0    0    00
<4>[   18.393486] 1    0    0   0   0    0    0    00
<4>[   18.398956] 1    0    0   0   0    0    0    00
<4>[   18.404430] 1    0    0   0   0    0    0    00
<4>[   18.409900] 1    0    0   0   0    0    0    00
<4>[   18.415365] 1    0    0   0   0    0    0    00
<4>[   18.420909] 1    0    0   0   0    0    0    00
<4>[   18.426373] 1    0    0   0   0    0    0    00
<4>[   18.431846] 1    0    0   0   0    0    0    00
<4>[   18.437310] 1    0    0   0   0    0    0    00
<4>[   18.442779] 1    1    0   1   0    0    0    D2
<7>[   18.448241] IRQ to pin mappings:
<7>[   18.452253] IRQ0 -> 0:2
<7>[   18.455532] IRQ1 -> 0:1
<7>[   18.458876] IRQ3 -> 0:3
<7>[   18.462158] IRQ4 -> 0:4
<7>[   18.465441] IRQ5 -> 0:5
<7>[   18.468716] IRQ6 -> 0:6
<7>[   18.472065] IRQ7 -> 0:7
<7>[   18.475329] IRQ8 -> 0:8
<7>[   18.478614] IRQ9 -> 0:9
<7>[   18.481893] IRQ10 -> 0:10
<7>[   18.485362] IRQ11 -> 0:11
<7>[   18.488832] IRQ12 -> 0:12
<7>[   18.492312] IRQ13 -> 0:13
<7>[   18.495814] IRQ14 -> 0:14
<7>[   18.499273] IRQ15 -> 0:15
<7>[   18.502754] IRQ16 -> 0:16
<7>[   18.506225] IRQ18 -> 0:18
<7>[   18.509695] IRQ19 -> 0:19
<7>[   18.513164] IRQ21 -> 0:21
<7>[   18.516636] IRQ23 -> 0:23
<7>[   18.520174] IRQ24 -> 1:0
<7>[   18.523541] IRQ26 -> 1:2
<7>[   18.526954] IRQ28 -> 1:4
<7>[   18.530338] IRQ29 -> 1:5
<7>[   18.533713] IRQ30 -> 1:6
<7>[   18.537094] IRQ32 -> 1:8
<7>[   18.540474] IRQ33 -> 1:9
<7>[   18.543874] IRQ40 -> 1:16
<7>[   18.547338] IRQ41 -> 1:17
<7>[   18.550819] IRQ48 -> 2:0
<7>[   18.554192] IRQ52 -> 2:4
<7>[   18.557559] IRQ54 -> 2:6
<7>[   18.560974] IRQ56 -> 2:8
<7>[   18.564350] IRQ71 -> 2:23
<6>[   18.567830] .................................... done.
<6>[   18.574077] Switched to clocksource tsc
<6>[   18.574702] registered taskstats version 1
<6>[   18.582053] Btrfs loaded
<6>[   18.590970] rtc_cmos 00:02: setting system clock to 2014-03-18 03:42:57 UTC (1395114177)
<6>[   18.600764] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
<6>[   18.607885] EDD information not available.
<6>[   18.627906] usb 4-1: new full-speed USB device number 2 using uhci_hcd
<6>[   18.724643] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
<6>[   18.731569] 8021q: adding VLAN 0 to HW filter on device eth0
<6>[   18.803975] input: American Megatrends Inc. Virtual Keyboard and Mouse as /devices/pci0000:00/0000:00:1a.1/usb4/4-1/4-1:1.0/0003:046B:FF10.0001/input/input2
<6>[   18.820906] hid-generic 0003:046B:FF10.0001: input: USB HID v1.10 Keyboard [American Megatrends Inc. Virtual Keyboard and Mouse] on usb-0000:00:1a.1-1/input0
<6>[   18.843933] input: American Megatrends Inc. Virtual Keyboard and Mouse as /devices/pci0000:00/0000:00:1a.1/usb4/4-1/4-1:1.1/0003:046B:FF10.0002/input/input3
<6>[   18.848584] IPv6: ADDRCONF(NETDEV_UP): eth1: link is not ready
<6>[   18.848585] 8021q: adding VLAN 0 to HW filter on device eth1
<6>[   18.874616] hid-generic 0003:046B:FF10.0002: input: USB HID v1.10 Mouse [American Megatrends Inc. Virtual Keyboard and Mouse] on usb-0000:00:1a.1-1/input1
<6>[   18.960691] IPv6: ADDRCONF(NETDEV_UP): eth2: link is not ready
<6>[   18.967707] 8021q: adding VLAN 0 to HW filter on device eth2
<6>[   19.084807] IPv6: ADDRCONF(NETDEV_UP): eth3: link is not ready
<6>[   19.091734] 8021q: adding VLAN 0 to HW filter on device eth3
<6>[   19.128117] usb 7-2: new full-speed USB device number 2 using uhci_hcd
<6>[   19.287508] hub 7-2:1.0: USB hub found
<6>[   19.293412] hub 7-2:1.0: 4 ports detected
<6>[   19.633617] usb 7-2.1: new low-speed USB device number 3 using uhci_hcd
<6>[   19.859043] input: ATEN International Co. Ltd CS1716A V1.0.098 as /devices/pci0000:00/0000:00:1d.1/usb7/7-2/7-2.1/7-2.1:1.0/0003:0557:2261.0003/input/input4
<6>[   19.875916] hid-generic 0003:0557:2261.0003: input: USB HID v1.00 Keyboard [ATEN International Co. Ltd CS1716A V1.0.098] on usb-0000:00:1d.1-2.1/input0
<6>[   19.926945] input: ATEN International Co. Ltd CS1716A V1.0.098 as /devices/pci0000:00/0000:00:1d.1/usb7/7-2/7-2.1/7-2.1:1.1/0003:0557:2261.0004/input/input5
<6>[   19.943669] hid-generic 0003:0557:2261.0004: input: USB HID v1.00 Device [ATEN International Co. Ltd CS1716A V1.0.098] on usb-0000:00:1d.1-2.1/input1
<6>[   19.982085] input: ATEN International Co. Ltd CS1716A V1.0.098 as /devices/pci0000:00/0000:00:1d.1/usb7/7-2/7-2.1/7-2.1:1.2/0003:0557:2261.0005/input/input6
<6>[   19.999092] hid-generic 0003:0557:2261.0005: input: USB HID v1.10 Mouse [ATEN International Co. Ltd CS1716A V1.0.098] on usb-0000:00:1d.1-2.1/input2
<6>[   21.353918] igb: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX
<6>[   21.369553] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
<5>[   21.385487] Sending DHCP requests .., OK
<4>[   25.560152] IP-Config: Got DHCP answer from 192.168.1.1, my address is 192.168.1.191
<6>[   26.133319] IP-Config: Complete:
<6>[   26.137420]      device=eth0, hwaddr=60:eb:69:82:38:2a, ipaddr=192.168.1.191, mask=255.255.255.0, gw=192.168.1.1
<6>[   26.149520]      host=lkp-wsx02, domain=lkp.intel.com, nis-domain=(none)
<6>[   26.157399]      bootserver=192.168.1.1, rootserver=192.168.1.1, rootpath=
<6>[   26.164967]      nameserver0=192.168.1.1
<7>[   26.170390] PM: Hibernation image not present or could not be loaded.
<6>[   26.198284] Freeing unused kernel memory: 1436K (ffffffff8233f000 - ffffffff824a6000)
<6>[   26.207768] Write protecting the kernel read-only data: 18432k
<6>[   26.251995] Freeing unused kernel memory: 1720K (ffff880001a52000 - ffff880001c00000)
<6>[   26.279269] Freeing unused kernel memory: 1852K (ffff880002031000 - ffff880002200000)
<6>[   26.670238] ipmi message handler version 39.2
<6>[   26.715704] IPMI System Interface driver.
<6>[   26.720715] ipmi_si: probing via ACPI
<6>[   26.725244] ipmi_si 00:0a: [io  0x0ca2] regsize 1 spacing 1 irq 0
<6>[   26.732472] ipmi_si: Adding ACPI-specified kcs state machine
<6>[   26.741396] ipmi_si: probing via SMBIOS
<6>[   26.746096] ipmi_si: SMBIOS: io 0xca2 regsize 1 spacing 1 irq 0
<6>[   26.753114] ipmi_si: Adding SMBIOS-specified kcs state machine duplicate interface
<6>[   26.762396] ipmi_si: Trying ACPI-specified kcs state machine at i/o address 0xca2, slave address 0x0, irq 0
<6>[   26.795556] microcode: CPU0 sig=0x206f2, pf=0x4, revision=0x26
<6>[   26.802588] microcode: CPU1 sig=0x206f2, pf=0x4, revision=0x26
<6>[   26.809675] microcode: CPU2 sig=0x206f2, pf=0x4, revision=0x26
<6>[   26.816878] microcode: CPU3 sig=0x206f2, pf=0x4, revision=0x26
<6>[   26.823838] microcode: CPU4 sig=0x206f2, pf=0x4, revision=0x26
<6>[   26.830954] microcode: CPU5 sig=0x206f2, pf=0x4, revision=0x26
<6>[   26.837958] microcode: CPU6 sig=0x206f2, pf=0x4, revision=0x26
<6>[   26.844944] microcode: CPU7 sig=0x206f2, pf=0x4, revision=0x26
<6>[   26.851966] microcode: CPU8 sig=0x206f2, pf=0x4, revision=0x26
<6>[   26.858950] microcode: CPU9 sig=0x206f2, pf=0x4, revision=0x26
<6>[   26.865991] microcode: CPU10 sig=0x206f2, pf=0x4, revision=0x26
<6>[   26.873103] microcode: CPU11 sig=0x206f2, pf=0x4, revision=0x26
<6>[   26.880194] microcode: CPU12 sig=0x206f2, pf=0x4, revision=0x26
<6>[   26.887316] microcode: CPU13 sig=0x206f2, pf=0x4, revision=0x26
<6>[   26.894437] microcode: CPU14 sig=0x206f2, pf=0x4, revision=0x26
<6>[   26.901755] microcode: CPU15 sig=0x206f2, pf=0x4, revision=0x26
<6>[   26.909082] microcode: CPU16 sig=0x206f2, pf=0x4, revision=0x26
<6>[   26.916399] microcode: CPU17 sig=0x206f2, pf=0x4, revision=0x26
<6>[   26.923745] microcode: CPU18 sig=0x206f2, pf=0x4, revision=0x26
<6>[   26.931045] microcode: CPU19 sig=0x206f2, pf=0x4, revision=0x26
<6>[   26.931340] ipmi_si 00:0a: Found new BMC (man_id: 0x000157, prod_id: 0x0040, dev_id: 0x21)
<6>[   26.931350] ipmi_si 00:0a: IPMI kcs interface initialized
<6>[   26.954604] microcode: CPU20 sig=0x206f2, pf=0x4, revision=0x26
<6>[   26.961730] microcode: CPU21 sig=0x206f2, pf=0x4, revision=0x26
<6>[   26.968854] microcode: CPU22 sig=0x206f2, pf=0x4, revision=0x26
<6>[   26.975966] microcode: CPU23 sig=0x206f2, pf=0x4, revision=0x26
<6>[   26.983071] microcode: CPU24 sig=0x206f2, pf=0x4, revision=0x26
<6>[   26.990214] microcode: CPU25 sig=0x206f2, pf=0x4, revision=0x26
<6>[   26.997376] microcode: CPU26 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.004487] microcode: CPU27 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.011607] microcode: CPU28 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.018754] microcode: CPU29 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.025919] microcode: CPU30 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.032990] microcode: CPU31 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.040108] microcode: CPU32 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.047231] microcode: CPU33 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.054394] microcode: CPU34 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.061509] microcode: CPU35 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.068550] microcode: CPU36 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.075680] microcode: CPU37 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.082851] microcode: CPU38 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.089963] microcode: CPU39 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.097075] microcode: CPU40 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.104214] microcode: CPU41 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.111377] microcode: CPU42 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.118481] microcode: CPU43 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.133934] microcode: CPU44 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.141068] microcode: CPU45 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.148225] microcode: CPU46 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.155337] microcode: CPU47 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.162447] microcode: CPU48 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.169574] microcode: CPU49 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.176728] microcode: CPU50 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.183832] microcode: CPU51 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.190951] microcode: CPU52 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.198101] microcode: CPU53 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.205259] microcode: CPU54 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.212384] microcode: CPU55 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.219501] microcode: CPU56 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.226639] microcode: CPU57 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.233804] microcode: CPU58 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.240905] microcode: CPU59 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.248037] microcode: CPU60 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.255175] microcode: CPU61 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.262338] microcode: CPU62 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.269443] microcode: CPU63 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.276551] microcode: CPU64 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.283699] microcode: CPU65 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.290859] microcode: CPU66 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.297976] microcode: CPU67 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.305204] microcode: CPU68 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.312354] microcode: CPU69 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.319515] microcode: CPU70 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.326558] microcode: CPU71 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.333664] microcode: CPU72 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.340799] microcode: CPU73 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.347961] microcode: CPU74 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.355066] microcode: CPU75 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.362190] microcode: CPU76 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.369249] microcode: CPU77 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.376428] microcode: CPU78 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.383471] microcode: CPU79 sig=0x206f2, pf=0x4, revision=0x26
<6>[   27.390837] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
<5>[   30.170456] random: vgscan urandom read with 91 bits of entropy available
<5>[   41.398124] random: nonblocking pool is initialized
<3>[  137.904961] BUG: sleeping function called from invalid context at /c/kernel-tests/src/lkp/mm/vmalloc.c:74
<3>[  137.916404] in_atomic(): 1, irqs_disabled(): 1, pid: 0, name: swapper/0
<4>[  137.924414] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.14.0-rc6-next-20140317 #1
<4>[  137.933884] Hardware name: QCI QSSC-S4R/QSSC-S4R, BIOS QSSC-S4R.QCI.01.00.0030.031120111710 03/11/2011
<4>[  137.945375]  0000000000000000 ffff88085f806d00 ffffffff81a3ae8a ffffc9001cc5c000
<4>[  137.955190]  ffff88085f806d10 ffffffff81101256 ffff88085f806d88 ffffffff811b1540
<4>[  137.964998]  ffffc9001cc5cfff ffffc9001cc5cfff 0000000000000001 000037005f1bc000
<4>[  137.974832] Call Trace:
<4>[  137.978170]  <NMI>  [<ffffffff81a3ae8a>] dump_stack+0x4d/0x66
<4>[  137.985439]  [<ffffffff81101256>] __might_sleep+0x10a/0x10c
<4>[  137.992283]  [<ffffffff811b1540>] vunmap_page_range+0x143/0x2b2
<4>[  137.999508]  [<ffffffff811b16c0>] unmap_kernel_range_noflush+0x11/0x13
<4>[  138.007422]  [<ffffffff8156f578>] ghes_copy_tofrom_phys+0x11f/0x189
<4>[  138.015027]  [<ffffffff8156f66a>] ghes_read_estatus+0x88/0x134
<4>[  138.022155]  [<ffffffff81570379>] ghes_notify_nmi+0x53/0x1e7
<4>[  138.029084]  [<ffffffff81a4370c>] nmi_handle.isra.4+0x68/0x113
<4>[  138.036217]  [<ffffffff81a43e51>] ? perf_ibs_nmi_handler+0x3d/0x3d
<4>[  138.043730]  [<ffffffff81a43867>] do_nmi+0xb0/0x2de
<4>[  138.049788]  [<ffffffff81a42e91>] end_repeat_nmi+0x1e/0x2e
<4>[  138.056529]  [<ffffffff81066ac0>] ? native_write_msr_safe+0xa/0xe
<4>[  138.063955]  [<ffffffff81066ac0>] ? native_write_msr_safe+0xa/0xe
<4>[  138.071375]  [<ffffffff81066ac0>] ? native_write_msr_safe+0xa/0xe
<4>[  138.078800]  <<EOE>>  <IRQ>  [<ffffffff8104e597>] intel_pmu_enable_all+0x4c/0x9b
<4>[  138.088517]  [<ffffffff8104e607>] intel_pmu_nhm_enable_all+0x21/0x152
<4>[  138.096325]  [<ffffffff81049b00>] x86_pmu_enable+0x134/0x273
<4>[  138.103255]  [<ffffffff81176942>] perf_pmu_enable+0x22/0x24
<4>[  138.110082]  [<ffffffff81048268>] x86_pmu_commit_txn+0x7b/0x98
<4>[  138.117215]  [<ffffffff81a4220b>] ? _raw_spin_lock_irqsave+0x25/0x56
<4>[  138.124927]  [<ffffffff81a42396>] ? _raw_spin_unlock_irqrestore+0x25/0x41
<4>[  138.133125]  [<ffffffff810fb494>] ? hrtimer_get_next_event+0x83/0x98
<4>[  138.140837]  [<ffffffff81177ad6>] ? event_sched_in+0x133/0x143
<4>[  138.147968]  [<ffffffff81177b79>] group_sched_in+0x93/0x13c
<4>[  138.154813]  [<ffffffff8103edc7>] ? native_sched_clock+0x31/0x93
<4>[  138.162141]  [<ffffffff81178a83>] __perf_event_enable+0x1ad/0x1ea
<4>[  138.169567]  [<ffffffff81175275>] remote_function+0x17/0x40
<4>[  138.176413]  [<ffffffff8113786f>] generic_smp_call_function_single_interrupt+0x74/0xdb
<4>[  138.186372]  [<ffffffff8105bb9e>] smp_call_function_single_interrupt+0x27/0x36
<4>[  138.195541]  [<ffffffff81a4ae32>] call_function_single_interrupt+0x72/0x80
<4>[  138.203833]  <EOI>  [<ffffffff81a42860>] ? retint_restore_args+0x13/0x13
<4>[  138.212144]  [<ffffffff818e7546>] ? cpuidle_enter_state+0x59/0xb5
<4>[  138.219564]  [<ffffffff818e7542>] ? cpuidle_enter_state+0x55/0xb5
<4>[  138.226990]  [<ffffffff818e75ce>] cpuidle_enter+0x17/0x19
<4>[  138.233638]  [<ffffffff81113271>] cpu_startup_entry+0x227/0x3b8
<4>[  138.240871]  [<ffffffff81a2ca43>] rest_init+0x87/0x89
<4>[  138.247131]  [<ffffffff82353dda>] start_kernel+0x401/0x40c
<4>[  138.253875]  [<ffffffff823537e7>] ? repair_env_string+0x58/0x58
<4>[  138.261106]  [<ffffffff82353120>] ? early_idt_handlers+0x120/0x120
<4>[  138.268631]  [<ffffffff823534a2>] x86_64_start_reservations+0x2a/0x2c
<4>[  138.276435]  [<ffffffff823535df>] x86_64_start_kernel+0x13b/0x148
<6>[  138.283868] INFO: NMI handler (ghes_notify_nmi) took too long to run: 378.902 msecs
<3>[  138.906140] BUG: sleeping function called from invalid context at /c/kernel-tests/src/lkp/mm/vmalloc.c:74
<3>[  138.917561] in_atomic(): 1, irqs_disabled(): 1, pid: 0, name: swapper/14
<4>[  138.925441] CPU: 14 PID: 0 Comm: swapper/14 Not tainted 3.14.0-rc6-next-20140317 #1
<4>[  138.934726] Hardware name: QCI QSSC-S4R/QSSC-S4R, BIOS QSSC-S4R.QCI.01.00.0030.031120111710 03/11/2011
<4>[  138.945858]  0000000000000000 ffff88105f8c6d00 ffffffff81a3ae8a ffffc9001cc5c000
<4>[  138.955127]  ffff88105f8c6d10 ffffffff81101256 ffff88105f8c6d88 ffffffff811b1540
<4>[  138.964389]  ffffc9001cc5cfff ffffc9001cc5cfff 0000000000000001 000037005f1bc000
<4>[  138.973646] Call Trace:
<4>[  138.976751]  <NMI>  [<ffffffff81a3ae8a>] dump_stack+0x4d/0x66
<4>[  138.983699]  [<ffffffff81101256>] __might_sleep+0x10a/0x10c
<4>[  138.990322]  [<ffffffff811b1540>] vunmap_page_range+0x143/0x2b2
<4>[  138.997336]  [<ffffffff811b16c0>] unmap_kernel_range_noflush+0x11/0x13
<4>[  139.005033]  [<ffffffff8156f578>] ghes_copy_tofrom_phys+0x11f/0x189
<4>[  139.012437]  [<ffffffff8156f66a>] ghes_read_estatus+0x88/0x134
<4>[  139.019350]  [<ffffffff81570379>] ghes_notify_nmi+0x53/0x1e7
<4>[  139.026068]  [<ffffffff81a4370c>] nmi_handle.isra.4+0x68/0x113
<4>[  139.032979]  [<ffffffff81a43e51>] ? perf_ibs_nmi_handler+0x3d/0x3d
<4>[  139.040287]  [<ffffffff81a43867>] do_nmi+0xb0/0x2de
<4>[  139.046126]  [<ffffffff81a42e91>] end_repeat_nmi+0x1e/0x2e
<4>[  139.052652]  [<ffffffff81540f5a>] ? intel_idle+0xdc/0x132
<4>[  139.059082]  [<ffffffff81540f5a>] ? intel_idle+0xdc/0x132
<4>[  139.065496]  [<ffffffff81540f5a>] ? intel_idle+0xdc/0x132
<4>[  139.071920]  <<EOE>>  [<ffffffff818e7532>] cpuidle_enter_state+0x45/0xb5
<4>[  139.079950]  [<ffffffff818e75ce>] cpuidle_enter+0x17/0x19
<4>[  139.086383]  [<ffffffff81113271>] cpu_startup_entry+0x227/0x3b8
<4>[  139.093401]  [<ffffffff8105c3cf>] start_secondary+0x234/0x236
<3>[  139.906619] BUG: sleeping function called from invalid context at /c/kernel-tests/src/lkp/mm/vmalloc.c:74
<3>[  139.918052] in_atomic(): 1, irqs_disabled(): 1, pid: 0, name: swapper/68
<4>[  139.925936] CPU: 68 PID: 0 Comm: swapper/68 Not tainted 3.14.0-rc6-next-20140317 #1
<4>[  139.935183] Hardware name: QCI QSSC-S4R/QSSC-S4R, BIOS QSSC-S4R.QCI.01.00.0030.031120111710 03/11/2011
<4>[  139.946319]  0000000000000000 ffff88085fc46d00 ffffffff81a3ae8a ffffc9001cc5c000
<4>[  139.955569]  ffff88085fc46d10 ffffffff81101256 ffff88085fc46d88 ffffffff811b1540
<4>[  139.964842]  ffffc9001cc5cfff ffffc9001cc5cfff 0000000000000001 000037005f1bc000
<4>[  139.974119] Call Trace:
<4>[  139.977236]  <NMI>  [<ffffffff81a3ae8a>] dump_stack+0x4d/0x66
<4>[  139.984194]  [<ffffffff81101256>] __might_sleep+0x10a/0x10c
<4>[  139.998953]  [<ffffffff811b1540>] vunmap_page_range+0x143/0x2b2
<4>[  140.005961]  [<ffffffff811b16c0>] unmap_kernel_range_noflush+0x11/0x13
<4>[  140.013654]  [<ffffffff8156f578>] ghes_copy_tofrom_phys+0x11f/0x189
<4>[  140.021044]  [<ffffffff8156f66a>] ghes_read_estatus+0x88/0x134
<4>[  140.027963]  [<ffffffff81570379>] ghes_notify_nmi+0x53/0x1e7
<4>[  140.034683]  [<ffffffff81a4370c>] nmi_handle.isra.4+0x68/0x113
<4>[  140.041589]  [<ffffffff81a43e51>] ? perf_ibs_nmi_handler+0x3d/0x3d
<4>[  140.048892]  [<ffffffff81a43867>] do_nmi+0xb0/0x2de
<4>[  140.054737]  [<ffffffff81a42e91>] end_repeat_nmi+0x1e/0x2e
<4>[  140.061259]  [<ffffffff81a09e86>] ? sctp_chunk_put+0x5b/0x5e
<4>[  140.067985]  [<ffffffff811c6e8b>] ? kmem_cache_alloc+0x27/0x1bf
<4>[  140.074985]  [<ffffffff811c6e8b>] ? kmem_cache_alloc+0x27/0x1bf
<4>[  140.081992]  [<ffffffff811c6e8b>] ? kmem_cache_alloc+0x27/0x1bf
<4>[  140.089000]  <<EOE>>  <IRQ>  [<ffffffff81a09b16>] ? sctp_chunkify+0x2a/0xaa
<4>[  140.097378]  [<ffffffff81a09b16>] sctp_chunkify+0x2a/0xaa
<4>[  140.103795]  [<ffffffff81a1a3cd>] sctp_rcv+0x53e/0x73d
<4>[  140.109926]  [<ffffffff814fc8c1>] ? cpumask_next_and+0x1f/0x3d
<4>[  140.116836]  [<ffffffff8194472f>] ip_local_deliver+0xe9/0x19a
<4>[  140.123648]  [<ffffffff81944ca7>] ip_rcv+0x4c7/0x50a
<4>[  140.129590]  [<ffffffff819202ed>] __netif_receive_skb_core+0x3ec/0x494
<4>[  140.137283]  [<ffffffff81920a0f>] __netif_receive_skb+0x1d/0x5f
<4>[  140.144296]  [<ffffffff81921b2f>] process_backlog+0xb7/0x192
<4>[  140.151018]  [<ffffffff81921968>] net_rx_action+0xb6/0x1c6
<4>[  140.157545]  [<ffffffff8110e7dd>] ? run_rebalance_domains+0x3d/0x15f
<4>[  140.165046]  [<ffffffff810e0651>] __do_softirq+0x121/0x2b7
<4>[  140.171574]  [<ffffffff810e0a23>] irq_exit+0x4a/0xa0
<4>[  140.177519]  [<ffffffff81a4bcc6>] smp_apic_timer_interrupt+0x44/0x50
<4>[  140.185014]  [<ffffffff81a4a9b2>] apic_timer_interrupt+0x72/0x80
<4>[  140.192110]  <EOI>  [<ffffffff818e7546>] ? cpuidle_enter_state+0x59/0xb5
<4>[  140.200127]  [<ffffffff818e7542>] ? cpuidle_enter_state+0x55/0xb5
<4>[  140.207330]  [<ffffffff818e75ce>] cpuidle_enter+0x17/0x19
<4>[  140.213752]  [<ffffffff81113271>] cpu_startup_entry+0x227/0x3b8
<4>[  140.220759]  [<ffffffff8105c3cf>] start_secondary+0x234/0x236
<3>[  140.967463] BUG: sleeping function called from invalid context at /c/kernel-tests/src/lkp/mm/vmalloc.c:74
<3>[  140.978910] in_atomic(): 1, irqs_disabled(): 1, pid: 6749, name: netperf
<4>[  140.986801] CPU: 17 PID: 6749 Comm: netperf Not tainted 3.14.0-rc6-next-20140317 #1
<4>[  140.996103] Hardware name: QCI QSSC-S4R/QSSC-S4R, BIOS QSSC-S4R.QCI.01.00.0030.031120111710 03/11/2011
<4>[  141.007236]  0000000000000000 ffff88185f906d00 ffffffff81a3ae8a ffffc9001cc5c000
<4>[  141.016523]  ffff88185f906d10 ffffffff81101256 ffff88185f906d88 ffffffff811b1540
<4>[  141.025814]  ffffc9001cc5cfff ffffc9001cc5cfff 0000000000000001 000037005f1bc000
<4>[  141.035088] Call Trace:
<4>[  141.038202]  <NMI>  [<ffffffff81a3ae8a>] dump_stack+0x4d/0x66
<4>[  141.045175]  [<ffffffff81101256>] __might_sleep+0x10a/0x10c
<4>[  141.051811]  [<ffffffff811b1540>] vunmap_page_range+0x143/0x2b2
<4>[  141.058835]  [<ffffffff811b16c0>] unmap_kernel_range_noflush+0x11/0x13
<4>[  141.066537]  [<ffffffff8156f578>] ghes_copy_tofrom_phys+0x11f/0x189
<4>[  141.073943]  [<ffffffff8156f66a>] ghes_read_estatus+0x88/0x134
<4>[  141.080858]  [<ffffffff81570379>] ghes_notify_nmi+0x53/0x1e7
<4>[  141.087586]  [<ffffffff81a4370c>] nmi_handle.isra.4+0x68/0x113
<4>[  141.094506]  [<ffffffff81a43e51>] ? perf_ibs_nmi_handler+0x3d/0x3d
<4>[  141.101817]  [<ffffffff81a43867>] do_nmi+0xb0/0x2de
<4>[  141.107665]  [<ffffffff81a42e91>] end_repeat_nmi+0x1e/0x2e
<4>[  141.114196]  [<ffffffff8110da86>] ? find_busiest_group+0x182/0x601
<4>[  141.121513]  [<ffffffff8110da86>] ? find_busiest_group+0x182/0x601
<4>[  141.128824]  [<ffffffff8110da86>] ? find_busiest_group+0x182/0x601
<4>[  141.136138]  <<EOE>>  [<ffffffff8110e050>] load_balance+0x14b/0x6a3
<4>[  141.143693]  [<ffffffff8110eb8b>] pick_next_task_fair+0x28c/0x39a
<4>[  141.150914]  [<ffffffff81a3f0a0>] __schedule+0x1a6/0x71a
<4>[  141.157258]  [<ffffffff81a03c8a>] ? sctp_do_sm+0x159/0x2a1
<4>[  141.163788]  [<ffffffff81a1af6b>] ? sctp_cname+0x5e/0x5e
<4>[  141.170117]  [<ffffffff81a3f687>] schedule+0x73/0x75
<4>[  141.176069]  [<ffffffff81a3e94f>] schedule_timeout+0x2f/0x1bf
<4>[  141.182891]  [<ffffffff810e0966>] ? __local_bh_enable_ip+0xb2/0xbe
<4>[  141.190199]  [<ffffffff81a42135>] ? _raw_spin_unlock_bh+0x1b/0x1d
<4>[  141.197411]  [<ffffffff819103e7>] ? release_sock+0x152/0x17a
<4>[  141.204139]  [<ffffffff81a12a48>] sctp_wait_for_sndbuf+0x159/0x1cd
<4>[  141.211455]  [<ffffffff81112e1e>] ? __wake_up_sync+0x12/0x12
<4>[  141.218188]  [<ffffffff81a14d3b>] sctp_sendmsg+0x6e6/0xa2d
<4>[  141.224726]  [<ffffffff81188a7b>] ? __alloc_pages_nodemask+0x183/0x984
<4>[  141.232430]  [<ffffffff8197178a>] inet_sendmsg+0x6d/0xa4
<4>[  141.238777]  [<ffffffff8150761b>] ? trace_hardirqs_on_thunk+0x3a/0x3c
<4>[  141.246383]  [<ffffffff8190c003>] sock_sendmsg+0x6e/0x7f
<4>[  141.252706]  [<ffffffff811a234a>] ? might_fault+0x3e/0x40
<4>[  141.259137]  [<ffffffff8190c863>] ___sys_sendmsg+0x1f9/0x277
<4>[  141.265858]  [<ffffffff811092ef>] ? __enqueue_entity+0x6c/0x6e
<4>[  141.272779]  [<ffffffff81109fd9>] ? put_prev_entity+0x3c/0x1e6
<4>[  141.279699]  [<ffffffff8110e9f8>] ? pick_next_task_fair+0xf9/0x39a
<4>[  141.287008]  [<ffffffff8103768a>] ? __switch_to+0x227/0x423
<4>[  141.293632]  [<ffffffff81100a33>] ? finish_task_switch+0x54/0xef
<4>[  141.300757]  [<ffffffff81a3f3a4>] ? __schedule+0x4aa/0x71a
<4>[  141.307295]  [<ffffffff8190dfb0>] __sys_sendmsg+0x42/0x63
<4>[  141.313735]  [<ffffffff8190dfe3>] SyS_sendmsg+0x12/0x1c
<4>[  141.319980]  [<ffffffff81a49de9>] system_call_fastpath+0x16/0x1b
<4>[  141.359538] perf interrupt took too long (2508 > 2500), lowering kernel.perf_event_max_sample_rate to 50000
<3>[  142.028070] BUG: sleeping function called from invalid context at /c/kernel-tests/src/lkp/mm/vmalloc.c:74
<3>[  142.039466] in_atomic(): 1, irqs_disabled(): 1, pid: 59, name: ksoftirqd/12
<4>[  142.047649] CPU: 12 PID: 59 Comm: ksoftirqd/12 Not tainted 3.14.0-rc6-next-20140317 #1
<4>[  142.057213] Hardware name: QCI QSSC-S4R/QSSC-S4R, BIOS QSSC-S4R.QCI.01.00.0030.031120111710 03/11/2011
<4>[  142.068347]  0000000000000000 ffff88085f8c6d00 ffffffff81a3ae8a ffffc9001cc5c000
<4>[  142.077619]  ffff88085f8c6d10 ffffffff81101256 ffff88085f8c6d88 ffffffff811b1540
<4>[  142.086884]  ffffc9001cc5cfff ffffc9001cc5cfff 0000000000000001 000037005f1bc000
<4>[  142.096142] Call Trace:
<4>[  142.099262]  <NMI>  [<ffffffff81a3ae8a>] dump_stack+0x4d/0x66
<4>[  142.106217]  [<ffffffff81101256>] __might_sleep+0x10a/0x10c
<4>[  142.112837]  [<ffffffff811b1540>] vunmap_page_range+0x143/0x2b2
<4>[  142.119847]  [<ffffffff811b16c0>] unmap_kernel_range_noflush+0x11/0x13
<4>[  142.127537]  [<ffffffff8156f578>] ghes_copy_tofrom_phys+0x11f/0x189
<4>[  142.134979]  [<ffffffff8156f66a>] ghes_read_estatus+0x88/0x134
<4>[  142.141897]  [<ffffffff81570379>] ghes_notify_nmi+0x53/0x1e7
<4>[  142.148622]  [<ffffffff81a4370c>] nmi_handle.isra.4+0x68/0x113
<4>[  142.155539]  [<ffffffff81a43e51>] ? perf_ibs_nmi_handler+0x3d/0x3d
<4>[  142.162844]  [<ffffffff81a43867>] do_nmi+0xb0/0x2de
<4>[  142.168694]  [<ffffffff81a42e91>] end_repeat_nmi+0x1e/0x2e
<4>[  142.175214]  [<ffffffff81066ba4>] ? native_load_sp0+0x4/0xe
<4>[  142.181834]  [<ffffffff81066ba4>] ? native_load_sp0+0x4/0xe
<4>[  142.188461]  [<ffffffff81066ba4>] ? native_load_sp0+0x4/0xe
<4>[  142.195075]  <<EOE>>  <UNK> 
<3>[  143.028493] BUG: sleeping function called from invalid context at /c/kernel-tests/src/lkp/mm/vmalloc.c:74
<3>[  143.040855] in_atomic(): 1, irqs_disabled(): 1, pid: 0, name: swapper/13
<4>[  143.048748] CPU: 13 PID: 0 Comm: swapper/13 Not tainted 3.14.0-rc6-next-20140317 #1
<4>[  143.058052] Hardware name: QCI QSSC-S4R/QSSC-S4R, BIOS QSSC-S4R.QCI.01.00.0030.031120111710 03/11/2011
<4>[  143.069202]  0000000000000000 ffff88185f8c6d00 ffffffff81a3ae8a ffffc9001cc5c000
<4>[  143.078499]  ffff88185f8c6d10 ffffffff81101256 ffff88185f8c6d88 ffffffff811b1540
<4>[  143.087780]  ffffc9001cc5cfff ffffc9001cc5cfff 0000000000000001 000037005f1bc000
<4>[  143.097056] Call Trace:
<4>[  143.100171]  <NMI>  [<ffffffff81a3ae8a>] dump_stack+0x4d/0x66
<4>[  143.107145]  [<ffffffff81101256>] __might_sleep+0x10a/0x10c
<4>[  143.113779]  [<ffffffff811b1540>] vunmap_page_range+0x143/0x2b2
<4>[  143.120802]  [<ffffffff811b16c0>] unmap_kernel_range_noflush+0x11/0x13
<4>[  143.128508]  [<ffffffff8156f578>] ghes_copy_tofrom_phys+0x11f/0x189
<4>[  143.135920]  [<ffffffff8156f66a>] ghes_read_estatus+0x88/0x134
<4>[  143.142840]  [<ffffffff81570379>] ghes_notify_nmi+0x53/0x1e7
<4>[  143.149573]  [<ffffffff81a4370c>] nmi_handle.isra.4+0x68/0x113
<4>[  143.156488]  [<ffffffff81a43e51>] ? perf_ibs_nmi_handler+0x3d/0x3d
<4>[  143.163793]  [<ffffffff81a43867>] do_nmi+0xb0/0x2de
<4>[  143.169647]  [<ffffffff81a42e91>] end_repeat_nmi+0x1e/0x2e
<4>[  143.176177]  [<ffffffff81a09e86>] ? sctp_chunk_put+0x5b/0x5e
<4>[  143.182908]  [<ffffffff811040b3>] ? idle_cpu+0x2d/0x45
<4>[  143.189043]  [<ffffffff811040b3>] ? idle_cpu+0x2d/0x45
<4>[  143.195192]  [<ffffffff811040b3>] ? idle_cpu+0x2d/0x45
<4>[  143.201339]  <<EOE>>  <IRQ>  [<ffffffff810e74d5>] mod_timer+0xdf/0x19a
<4>[  143.209259]  [<ffffffff81a09320>] sctp_transport_reset_timers+0x31/0x63
<4>[  143.217059]  [<ffffffff81a0e98e>] sctp_outq_flush+0x8bc/0x930
<4>[  143.223887]  [<ffffffff811c6c2f>] ? kmem_cache_free+0x18d/0x1e9
<4>[  143.230911]  [<ffffffff81a0f4dc>] sctp_outq_uncork+0x1a/0x1c
<4>[  143.237638]  [<ffffffff81a051be>] sctp_cmd_interpreter.isra.23+0xfc1/0xfe0
<4>[  143.245722]  [<ffffffff81a0546c>] ? sctp_v4_xmit+0x88/0x90
<4>[  143.252242]  [<ffffffff81a03c8a>] sctp_do_sm+0x159/0x2a1
<4>[  143.258577]  [<ffffffff81a1af0d>] ? sctp_has_association+0x6f/0x6f
<4>[  143.265886]  [<ffffffff81a07689>] sctp_assoc_bh_rcv+0xf5/0x127
<4>[  143.272806]  [<ffffffff81a0dce1>] sctp_inq_push+0x4f/0x51
<4>[  143.279239]  [<ffffffff81a1a52b>] sctp_rcv+0x69c/0x73d
<4>[  143.285389]  [<ffffffff814fc8c1>] ? cpumask_next_and+0x1f/0x3d
<4>[  143.292318]  [<ffffffff8194472f>] ip_local_deliver+0xe9/0x19a
<4>[  143.299146]  [<ffffffff81944ca7>] ip_rcv+0x4c7/0x50a
<4>[  143.305099]  [<ffffffff819202ed>] __netif_receive_skb_core+0x3ec/0x494
<4>[  143.312804]  [<ffffffff81920a0f>] __netif_receive_skb+0x1d/0x5f
<4>[  143.319829]  [<ffffffff81921b2f>] process_backlog+0xb7/0x192
<4>[  143.326564]  [<ffffffff81921968>] net_rx_action+0xb6/0x1c6
<4>[  143.333103]  [<ffffffff8110e7dd>] ? run_rebalance_domains+0x3d/0x15f
<4>[  143.340614]  [<ffffffff810e0651>] __do_softirq+0x121/0x2b7
<4>[  143.347142]  [<ffffffff810e0a23>] irq_exit+0x4a/0xa0
<4>[  143.353097]  [<ffffffff81a4bcc6>] smp_apic_timer_interrupt+0x44/0x50
<4>[  143.360599]  [<ffffffff81a4a9b2>] apic_timer_interrupt+0x72/0x80
<4>[  143.367718]  <EOI>  [<ffffffff818e7546>] ? cpuidle_enter_state+0x59/0xb5
<4>[  143.375762]  [<ffffffff818e7542>] ? cpuidle_enter_state+0x55/0xb5
<4>[  143.382981]  [<ffffffff818e75ce>] cpuidle_enter+0x17/0x19
<4>[  143.389424]  [<ffffffff81113271>] cpu_startup_entry+0x227/0x3b8
<4>[  143.396449]  [<ffffffff8105c3cf>] start_secondary+0x234/0x236
<3>[  144.229484] BUG: sleeping function called from invalid context at /c/kernel-tests/src/lkp/mm/vmalloc.c:74
<3>[  144.249260] in_atomic(): 1, irqs_disabled(): 1, pid: 0, name: swapper/23
<4>[  144.257146] CPU: 23 PID: 0 Comm: swapper/23 Not tainted 3.14.0-rc6-next-20140317 #1
<4>[  144.266443] Hardware name: QCI QSSC-S4R/QSSC-S4R, BIOS QSSC-S4R.QCI.01.00.0030.031120111710 03/11/2011
<4>[  144.277585]  0000000000000000 ffff88205f146d00 ffffffff81a3ae8a ffffc9001cc5c000
<4>[  144.286881]  ffff88205f146d10 ffffffff81101256 ffff88205f146d88 ffffffff811b1540
<4>[  144.296176]  ffffc9001cc5cfff ffffc9001cc5cfff 0000000000000001 000037005f1bc000
<4>[  144.305470] Call Trace:
<4>[  144.308591]  <NMI>  [<ffffffff81a3ae8a>] dump_stack+0x4d/0x66
<4>[  144.315567]  [<ffffffff81101256>] __might_sleep+0x10a/0x10c
<4>[  144.322192]  [<ffffffff811b1540>] vunmap_page_range+0x143/0x2b2
<4>[  144.329206]  [<ffffffff811b16c0>] unmap_kernel_range_noflush+0x11/0x13
<4>[  144.336901]  [<ffffffff8156f578>] ghes_copy_tofrom_phys+0x11f/0x189
<4>[  144.344308]  [<ffffffff8156f66a>] ghes_read_estatus+0x88/0x134
<4>[  144.351225]  [<ffffffff81570379>] ghes_notify_nmi+0x53/0x1e7
<4>[  144.357950]  [<ffffffff81a4370c>] nmi_handle.isra.4+0x68/0x113
<4>[  144.364874]  [<ffffffff81a43e51>] ? perf_ibs_nmi_handler+0x3d/0x3d
<4>[  144.372191]  [<ffffffff81a43867>] do_nmi+0xb0/0x2de
<4>[  144.378048]  [<ffffffff81a42e91>] end_repeat_nmi+0x1e/0x2e
<4>[  144.384583]  [<ffffffff814fdeb7>] ? int_sqrt+0x2d/0x3c
<4>[  144.390733]  [<ffffffff814fdeb7>] ? int_sqrt+0x2d/0x3c
<4>[  144.396876]  [<ffffffff814fdeb7>] ? int_sqrt+0x2d/0x3c
<4>[  144.403016]  <<EOE>>  [<ffffffff818e89fc>] menu_select+0x206/0x316
<4>[  144.410462]  [<ffffffff818e75b5>] cpuidle_select+0x13/0x15
<4>[  144.416991]  [<ffffffff811131db>] cpu_startup_entry+0x191/0x3b8
<4>[  144.424007]  [<ffffffff8105c3cf>] start_secondary+0x234/0x236
<3>[  145.229846] BUG: sleeping function called from invalid context at /c/kernel-tests/src/lkp/mm/vmalloc.c:74
<3>[  145.241256] in_atomic(): 1, irqs_disabled(): 1, pid: 0, name: swapper/16
<4>[  145.249144] CPU: 16 PID: 0 Comm: swapper/16 Not tainted 3.14.0-rc6-next-20140317 #1
<4>[  145.258426] Hardware name: QCI QSSC-S4R/QSSC-S4R, BIOS QSSC-S4R.QCI.01.00.0030.031120111710 03/11/2011
<4>[  145.269543]  0000000000000000 ffff88085f906d00 ffffffff81a3ae8a ffffc9001cc5c000
<4>[  145.278794]  ffff88085f906d10 ffffffff81101256 ffff88085f906d88 ffffffff811b1540
<4>[  145.288037]  ffffc9001cc5cfff ffffc9001cc5cfff 0000000000000001 000037005f1bc000
<4>[  145.297291] Call Trace:
<4>[  145.300407]  <NMI>  [<ffffffff81a3ae8a>] dump_stack+0x4d/0x66
<4>[  145.307362]  [<ffffffff81101256>] __might_sleep+0x10a/0x10c
<4>[  145.313989]  [<ffffffff811b1540>] vunmap_page_range+0x143/0x2b2
<4>[  145.321007]  [<ffffffff811b16c0>] unmap_kernel_range_noflush+0x11/0x13
<4>[  145.328704]  [<ffffffff8156f578>] ghes_copy_tofrom_phys+0x11f/0x189
<4>[  145.336107]  [<ffffffff8156f66a>] ghes_read_estatus+0x88/0x134
<4>[  145.343021]  [<ffffffff81570379>] ghes_notify_nmi+0x53/0x1e7
<4>[  145.349742]  [<ffffffff81a4370c>] nmi_handle.isra.4+0x68/0x113
<4>[  145.356638]  [<ffffffff81a43e51>] ? perf_ibs_nmi_handler+0x3d/0x3d
<4>[  145.363925]  [<ffffffff81a43867>] do_nmi+0xb0/0x2de
<4>[  145.369772]  [<ffffffff81a42e91>] end_repeat_nmi+0x1e/0x2e
<4>[  145.376291]  [<ffffffff81a076dc>] ? sctp_association_get_next_tsn+0x21/0x21
<4>[  145.384463]  [<ffffffff81a076dc>] ? sctp_association_get_next_tsn+0x21/0x21
<4>[  145.392642]  [<ffffffff81a076dc>] ? sctp_association_get_next_tsn+0x21/0x21
<4>[  145.400822]  <<EOE>>  <IRQ>  [<ffffffff81a0773d>] ? sctp_assoc_lookup_paddr+0x30/0x47
<4>[  145.410512]  [<ffffffff81a07b61>] sctp_assoc_is_match+0x46/0x73
<4>[  145.417526]  [<ffffffff81a19d73>] __sctp_lookup_association+0x80/0xbf
<4>[  145.425116]  [<ffffffff81a1a08d>] sctp_rcv+0x1fe/0x73d
<4>[  145.431253]  [<ffffffff8194472f>] ip_local_deliver+0xe9/0x19a
<4>[  145.438071]  [<ffffffff81944ca7>] ip_rcv+0x4c7/0x50a
<4>[  145.444015]  [<ffffffff819202ed>] __netif_receive_skb_core+0x3ec/0x494
<4>[  145.451711]  [<ffffffff81920a0f>] __netif_receive_skb+0x1d/0x5f
<4>[  145.458713]  [<ffffffff81921b2f>] process_backlog+0xb7/0x192
<4>[  145.465424]  [<ffffffff81921968>] net_rx_action+0xb6/0x1c6
<4>[  145.471955]  [<ffffffff8110e7dd>] ? run_rebalance_domains+0x3d/0x15f
<4>[  145.479441]  [<ffffffff810e0651>] __do_softirq+0x121/0x2b7
<4>[  145.485965]  [<ffffffff810e0a23>] irq_exit+0x4a/0xa0
<4>[  145.491901]  [<ffffffff81a4bcc6>] smp_apic_timer_interrupt+0x44/0x50
<4>[  145.499402]  [<ffffffff81a4a9b2>] apic_timer_interrupt+0x72/0x80
<4>[  145.506511]  <EOI>  [<ffffffff818e7546>] ? cpuidle_enter_state+0x59/0xb5
<4>[  145.514540]  [<ffffffff818e7542>] ? cpuidle_enter_state+0x55/0xb5
<4>[  145.521747]  [<ffffffff818e75ce>] cpuidle_enter+0x17/0x19
<4>[  145.528174]  [<ffffffff81113271>] cpu_startup_entry+0x227/0x3b8
<4>[  145.535173]  [<ffffffff8105c3cf>] start_secondary+0x234/0x236
<3>[  146.266518] BUG: sleeping function called from invalid context at /c/kernel-tests/src/lkp/mm/vmalloc.c:74
<3>[  146.277949] in_atomic(): 1, irqs_disabled(): 1, pid: 0, name: swapper/64
<4>[  146.285834] CPU: 64 PID: 0 Comm: swapper/64 Not tainted 3.14.0-rc6-next-20140317 #1
<4>[  146.295123] Hardware name: QCI QSSC-S4R/QSSC-S4R, BIOS QSSC-S4R.QCI.01.00.0030.031120111710 03/11/2011
<4>[  146.306263]  0000000000000000 ffff88085fc06d00 ffffffff81a3ae8a ffffc9001cc5c000
<4>[  146.315532]  ffff88085fc06d10 ffffffff81101256 ffff88085fc06d88 ffffffff811b1540
<4>[  146.324794]  ffffc9001cc5cfff ffffc9001cc5cfff 0000000000000001 000037005f1bc000
<4>[  146.334050] Call Trace:
<4>[  146.337170]  <NMI>  [<ffffffff81a3ae8a>] dump_stack+0x4d/0x66
<4>[  146.344114]  [<ffffffff81101256>] __might_sleep+0x10a/0x10c
<4>[  146.350741]  [<ffffffff811b1540>] vunmap_page_range+0x143/0x2b2
<4>[  146.357744]  [<ffffffff811b16c0>] unmap_kernel_range_noflush+0x11/0x13
<4>[  146.365441]  [<ffffffff8156f578>] ghes_copy_tofrom_phys+0x11f/0x189
<4>[  146.372844]  [<ffffffff8156f66a>] ghes_read_estatus+0x88/0x134
<4>[  146.379752]  [<ffffffff81570379>] ghes_notify_nmi+0x53/0x1e7
<4>[  146.386473]  [<ffffffff81a4370c>] nmi_handle.isra.4+0x68/0x113
<4>[  146.393393]  [<ffffffff81a43e51>] ? perf_ibs_nmi_handler+0x3d/0x3d
<4>[  146.400698]  [<ffffffff81a43867>] do_nmi+0xb0/0x2de
<4>[  146.406535]  [<ffffffff81a42e91>] end_repeat_nmi+0x1e/0x2e
<4>[  146.413051]  [<ffffffff81a1997e>] ? sctp_packet_transmit+0x2a6/0x55f
<4>[  146.420541]  [<ffffffff81a1997e>] ? sctp_packet_transmit+0x2a6/0x55f
<4>[  146.428032]  [<ffffffff81a1997e>] ? sctp_packet_transmit+0x2a6/0x55f
<4>[  146.435510]  <<EOE>>  <IRQ>  [<ffffffff810e6ae5>] ? lock_timer_base.isra.37+0x2b/0x4f
<4>[  146.445169]  [<ffffffff81a0e9d3>] sctp_outq_flush+0x901/0x930
<4>[  146.451993]  [<ffffffff811c6c2f>] ? kmem_cache_free+0x18d/0x1e9
<4>[  146.459005]  [<ffffffff81a0f4dc>] sctp_outq_uncork+0x1a/0x1c
<4>[  146.465717]  [<ffffffff81a051be>] sctp_cmd_interpreter.isra.23+0xfc1/0xfe0
<4>[  146.473799]  [<ffffffff81a0546c>] ? sctp_v4_xmit+0x88/0x90
<4>[  146.480318]  [<ffffffff81a03c8a>] sctp_do_sm+0x159/0x2a1
<4>[  146.486651]  [<ffffffff81a1af0d>] ? sctp_has_association+0x6f/0x6f
<4>[  146.493948]  [<ffffffff81a07689>] sctp_assoc_bh_rcv+0xf5/0x127
<4>[  146.500845]  [<ffffffff81a0dce1>] sctp_inq_push+0x4f/0x51
<4>[  146.507263]  [<ffffffff81a1a52b>] sctp_rcv+0x69c/0x73d
<4>[  146.513399]  [<ffffffff814fc8c1>] ? cpumask_next_and+0x1f/0x3d
<4>[  146.520311]  [<ffffffff8194472f>] ip_local_deliver+0xe9/0x19a
<4>[  146.527123]  [<ffffffff81944ca7>] ip_rcv+0x4c7/0x50a
<4>[  146.533063]  [<ffffffff819202ed>] __netif_receive_skb_core+0x3ec/0x494
<4>[  146.540760]  [<ffffffff81920a0f>] __netif_receive_skb+0x1d/0x5f
<4>[  146.547772]  [<ffffffff81921b2f>] process_backlog+0xb7/0x192
<4>[  146.554485]  [<ffffffff81921968>] net_rx_action+0xb6/0x1c6
<4>[  146.561013]  [<ffffffff8110e7dd>] ? run_rebalance_domains+0x3d/0x15f
<4>[  146.568512]  [<ffffffff810e0651>] __do_softirq+0x121/0x2b7
<4>[  146.575042]  [<ffffffff810e0a23>] irq_exit+0x4a/0xa0
<4>[  146.580990]  [<ffffffff81a4bcc6>] smp_apic_timer_interrupt+0x44/0x50
<4>[  146.588486]  [<ffffffff81a4a9b2>] apic_timer_interrupt+0x72/0x80
<4>[  146.595599]  <EOI>  [<ffffffff818e7546>] ? cpuidle_enter_state+0x59/0xb5
<4>[  146.603622]  [<ffffffff818e7542>] ? cpuidle_enter_state+0x55/0xb5
<4>[  146.610832]  [<ffffffff818e75ce>] cpuidle_enter+0x17/0x19
<4>[  146.617257]  [<ffffffff81113271>] cpu_startup_entry+0x227/0x3b8
<4>[  146.624272]  [<ffffffff8105c3cf>] start_secondary+0x234/0x236
<3>[  147.343169] BUG: sleeping function called from invalid context at /c/kernel-tests/src/lkp/mm/vmalloc.c:74
<3>[  147.354607] in_atomic(): 1, irqs_disabled(): 1, pid: 59, name: ksoftirqd/12
<4>[  147.362789] CPU: 12 PID: 59 Comm: ksoftirqd/12 Not tainted 3.14.0-rc6-next-20140317 #1
<4>[  147.372348] Hardware name: QCI QSSC-S4R/QSSC-S4R, BIOS QSSC-S4R.QCI.01.00.0030.031120111710 03/11/2011
<4>[  147.383458]  0000000000000000 ffff88085f8c6d00 ffffffff81a3ae8a ffffc9001cc5c000
<4>[  147.392719]  ffff88085f8c6d10 ffffffff81101256 ffff88085f8c6d88 ffffffff811b1540
<4>[  147.401980]  ffffc9001cc5cfff ffffc9001cc5cfff 0000000000000001 000037005f1bc000
<4>[  147.411253] Call Trace:
<4>[  147.414373]  <NMI>  [<ffffffff81a3ae8a>] dump_stack+0x4d/0x66
<4>[  147.421331]  [<ffffffff81101256>] __might_sleep+0x10a/0x10c
<4>[  147.427958]  [<ffffffff811b1540>] vunmap_page_range+0x143/0x2b2
<4>[  147.434973]  [<ffffffff811b16c0>] unmap_kernel_range_noflush+0x11/0x13
<4>[  147.442667]  [<ffffffff8156f578>] ghes_copy_tofrom_phys+0x11f/0x189
<4>[  147.450068]  [<ffffffff8156f66a>] ghes_read_estatus+0x88/0x134
<4>[  147.456977]  [<ffffffff81570379>] ghes_notify_nmi+0x53/0x1e7
<4>[  147.463687]  [<ffffffff81a4370c>] nmi_handle.isra.4+0x68/0x113
<4>[  147.470599]  [<ffffffff81a43e51>] ? perf_ibs_nmi_handler+0x3d/0x3d
<4>[  147.477904]  [<ffffffff81a43867>] do_nmi+0xb0/0x2de
<4>[  147.483745]  [<ffffffff81a42e91>] end_repeat_nmi+0x1e/0x2e
<4>[  147.490269]  [<ffffffff81a09590>] ? sctp_datamsg_put+0xd6/0xe2
<4>[  147.497180]  [<ffffffff819116e6>] ? sock_wfree+0x37/0x4d
<4>[  147.503513]  [<ffffffff819116e6>] ? sock_wfree+0x37/0x4d
<4>[  147.509845]  [<ffffffff819116e6>] ? sock_wfree+0x37/0x4d
<4>[  147.516175]  <<EOE>>  [<ffffffff81a14592>] sctp_wfree+0x67/0x7a
<4>[  147.523317]  [<ffffffff8191306f>] skb_release_head_state+0x6e/0x7a
<4>[  147.530613]  [<ffffffff81916059>] skb_release_all+0x12/0x27
<4>[  147.537225]  [<ffffffff81916084>] __kfree_skb+0x16/0x6d
<4>[  147.543447]  [<ffffffff81916481>] consume_skb+0x47/0x75
<4>[  147.549672]  [<ffffffff81a09e6b>] sctp_chunk_put+0x40/0x5e
<4>[  147.556198]  [<ffffffff81a09eaf>] sctp_chunk_free+0x26/0x29
<4>[  147.562823]  [<ffffffff81a0f980>] sctp_outq_sack+0x47b/0x497
<4>[  147.569534]  [<ffffffff81a045e4>] sctp_cmd_interpreter.isra.23+0x3e7/0xfe0
<4>[  147.577618]  [<ffffffff81a03c8a>] sctp_do_sm+0x159/0x2a1
<4>[  147.583943]  [<ffffffff81a1af0d>] ? sctp_has_association+0x6f/0x6f
<4>[  147.591249]  [<ffffffff81a07689>] sctp_assoc_bh_rcv+0xf5/0x127
<4>[  147.598166]  [<ffffffff81a0dce1>] sctp_inq_push+0x4f/0x51
<4>[  147.604599]  [<ffffffff81a1a52b>] sctp_rcv+0x69c/0x73d
<4>[  147.610732]  [<ffffffff8194472f>] ip_local_deliver+0xe9/0x19a
<4>[  147.625671]  [<ffffffff81944ca7>] ip_rcv+0x4c7/0x50a
<4>[  147.631614]  [<ffffffff819202ed>] __netif_receive_skb_core+0x3ec/0x494
<4>[  147.639297]  [<ffffffff81920a0f>] __netif_receive_skb+0x1d/0x5f
<4>[  147.646302]  [<ffffffff81921b2f>] process_backlog+0xb7/0x192
<4>[  147.653021]  [<ffffffff81921968>] net_rx_action+0xb6/0x1c6
<4>[  147.659540]  [<ffffffff810e0651>] __do_softirq+0x121/0x2b7
<4>[  147.666062]  [<ffffffff810e0810>] run_ksoftirqd+0x29/0x65
<4>[  147.672488]  [<ffffffff810fe1a5>] smpboot_thread_fn+0x187/0x1a5
<4>[  147.679502]  [<ffffffff810fe01e>] ? SyS_setgroups+0x10c/0x10c
<4>[  147.686314]  [<ffffffff810f8834>] kthread+0xdb/0xe3
<4>[  147.692157]  [<ffffffff810f8759>] ? kthread_create_on_node+0x16f/0x16f
<4>[  147.699851]  [<ffffffff81a49d3c>] ret_from_fork+0x7c/0xb0
<4>[  147.706279]  [<ffffffff810f8759>] ? kthread_create_on_node+0x16f/0x16f

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
