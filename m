Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8E20C8D0039
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 07:09:13 -0500 (EST)
Subject: Re: [Bug 29772] New: memory compaction crashed
From: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <20110223233934.GN15652@csn.ul.ie>
References: <bug-29772-27@https.bugzilla.kernel.org/>
	 <20110223134015.be96110b.akpm@linux-foundation.org>
	 <20110223233934.GN15652@csn.ul.ie>
Content-Type: multipart/mixed; boundary="=-oRNTX2gd2OOS+/2drPH3"
Date: Thu, 24 Feb 2011 13:07:29 +0100
Message-ID: <1298549249.3875.0.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org


--=-oRNTX2gd2OOS+/2drPH3
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

On Wed, 2011-02-23 at 23:39 +0000, Mel Gorman wrote:

> Can I also see a full dmesg with the kernel parameters "loglevel=9
> mminit_loglevel=4" please? I know the crash won't be included but I want
> to see what your memory layout looks like to see can I spot anything
> unusual about it.

Attached. Also attached new config. The kernel version is different
because I added some more wireless code to it, no core changes though.

johannes

--=-oRNTX2gd2OOS+/2drPH3
Content-Type: application/x-gzip; name="config.gz"
Content-Disposition: attachment; filename="config.gz"
Content-Transfer-Encoding: base64

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


--=-oRNTX2gd2OOS+/2drPH3
Content-Disposition: attachment; filename="log"
Content-Type: text/plain; name="log"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

[    0.000000] Linux version 2.6.38-rc6-wl-65414-ge1b6053-dirty (johannes@jlt3.sipsolutions.net) (gcc version 4.5.2 (Debian 4.5.2-2) ) #208 SMP PREEMPT Thu Feb 24 12:55:52 CET 2011
[    0.000000] Command line: BOOT_IMAGE=/boot/vmlinuz-2.6.38-rc6-wl-65414-ge1b6053-dirty root=UUID=c4c96801-db1f-44df-acb4-3d600be51419 ro quiet no_console_suspend reboot=pci loglevel=9 mminit_loglevel=4
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
[    0.000000]  BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
[    0.000000]  BIOS-e820: 00000000000e0000 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 0000000040000000 (usable)
[    0.000000]  BIOS-e820: 0000000040000000 - 0000000050000000 (reserved)
[    0.000000]  BIOS-e820: 0000000050000000 - 000000007e86e000 (usable)
[    0.000000]  BIOS-e820: 000000007e86e000 - 000000007e870000 (ACPI NVS)
[    0.000000]  BIOS-e820: 000000007e870000 - 000000007e871000 (ACPI data)
[    0.000000]  BIOS-e820: 000000007e871000 - 000000007e873000 (ACPI NVS)
[    0.000000]  BIOS-e820: 000000007e873000 - 000000007e88e000 (ACPI data)
[    0.000000]  BIOS-e820: 000000007e88e000 - 000000007ea8f000 (ACPI NVS)
[    0.000000]  BIOS-e820: 000000007ea8f000 - 000000007fec6000 (ACPI data)
[    0.000000]  BIOS-e820: 000000007fec6000 - 000000007fec8000 (ACPI NVS)
[    0.000000]  BIOS-e820: 000000007fec8000 - 000000007fec9000 (ACPI data)
[    0.000000]  BIOS-e820: 000000007fec9000 - 000000007fecb000 (ACPI NVS)
[    0.000000]  BIOS-e820: 000000007fecb000 - 000000007fecd000 (ACPI data)
[    0.000000]  BIOS-e820: 000000007fecd000 - 000000007fedf000 (ACPI NVS)
[    0.000000]  BIOS-e820: 000000007fedf000 - 000000007fef9000 (ACPI data)
[    0.000000]  BIOS-e820: 000000007fef9000 - 000000007feff000 (reserved)
[    0.000000]  BIOS-e820: 000000007feff000 - 000000007ff00000 (ACPI data)
[    0.000000]  BIOS-e820: 0000000093300000 - 0000000093301000 (reserved)
[    0.000000]  BIOS-e820: 00000000f0000000 - 00000000f4000000 (reserved)
[    0.000000]  BIOS-e820: 00000000fec00000 - 00000000fec01000 (reserved)
[    0.000000]  BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
[    0.000000]  BIOS-e820: 00000000ffc00000 - 0000000100000000 (reserved)
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] DMI 2.4 present.
[    0.000000] DMI: Apple Inc. MacBook5,1/Mac-F42D89C8, BIOS     MB51.88Z.007D.B03.0904271443 04/27/09
[    0.000000] e820 update range: 0000000000000000 - 0000000000010000 (usable) ==> (reserved)
[    0.000000] e820 remove range: 00000000000a0000 - 0000000000100000 (usable)
[    0.000000] No AGP bridge found
[    0.000000] last_pfn = 0x7e86e max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-FFFFF uncachable
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 disabled
[    0.000000]   1 base 000000000 mask F80000000 write-back
[    0.000000]   2 base 07FF00000 mask FFFF00000 uncachable
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
[    0.000000] initial memory mapped : 0 - 20000000
[    0.000000] init_memory_mapping: 0000000000000000-000000007e86e000
[    0.000000]  0000000000 - 007e86e000 page 4k
[    0.000000] kernel direct mapping tables up to 7e86e000 @ 1fc08000-20000000
[    0.000000] RAMDISK: 36ff0000 - 377f0000
[    0.000000] ACPI: RSDP 00000000000fe020 00024 (v02 APPLE )
[    0.000000] ACPI: XSDT 000000007feee1c0 00074 (v01 APPLE   Apple00 0000007D      01000013)
[    0.000000] ACPI: FACP 000000007feec000 000F4 (v03 APPLE   Apple00 0000007D Loki 0000005F)
[    0.000000] ACPI: DSDT 000000007fee0000 058CA (v01 APPLE   MacBook 00050001 INTL 20061109)
[    0.000000] ACPI: FACS 000000007fecd000 00040
[    0.000000] ACPI: HPET 000000007feeb000 00038 (v01 APPLE   Apple00 00000001 Loki 0000005F)
[    0.000000] ACPI: APIC 000000007feea000 00068 (v01 APPLE   Apple00 00000001 Loki 0000005F)
[    0.000000] ACPI: MCFG 000000007fee9000 0003C (v01 APPLE   Apple00 00000001 Loki 0000005F)
[    0.000000] ACPI: ASF! 000000007fee8000 000A5 (v32 APPLE   Apple00 00000001 Loki 0000005F)
[    0.000000] ACPI: SBST 000000007fee7000 00030 (v01 APPLE   Apple00 00000001 Loki 0000005F)
[    0.000000] ACPI: ECDT 000000007fee6000 00053 (v01 APPLE   Apple00 00000001 Loki 0000005F)
[    0.000000] ACPI: SSDT 000000007fec8000 004DC (v01  APPLE    CpuPm 00003000 INTL 20061109)
[    0.000000] ACPI: SSDT 000000007fedf000 000A5 (v01 SataRe  SataPri 00001000 INTL 20061109)
[    0.000000] ACPI: SSDT 000000007fecc000 0009F (v01 SataRe  SataSec 00001000 INTL 20061109)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000]  [ffffea0000000000-ffffea0001bfffff] PMD -> [ffff88003da00000-ffff88003f3fffff] on node 0
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000010 -> 0x00001000
[    0.000000]   DMA32    0x00001000 -> 0x00100000
[    0.000000]   Normal   empty
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[3] active PFN ranges
[    0.000000]     0: 0x00000010 -> 0x0000009f
[    0.000000]     0: 0x00000100 -> 0x00040000
[    0.000000]     0: 0x00050000 -> 0x0007e86e
[    0.000000] On node 0 totalpages: 452605
[    0.000000]   DMA zone: 56 pages used for memmap
[    0.000000]   DMA zone: 6 pages reserved
[    0.000000]   DMA zone: 3921 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 7030 pages used for memmap
[    0.000000]   DMA32 zone: 441592 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0x408
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x01] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 1, version 17, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x10de8201 base: 0xfed00000
[    0.000000] SMP: Allowing 2 CPUs, 0 hotplug CPUs
[    0.000000] nr_irqs_gsi: 40
[    0.000000] PM: Registered nosave memory: 000000000009f000 - 00000000000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 00000000000e0000
[    0.000000] PM: Registered nosave memory: 00000000000e0000 - 0000000000100000
[    0.000000] PM: Registered nosave memory: 0000000040000000 - 0000000050000000
[    0.000000] Allocating PCI resources starting at 93301000 (gap: 93301000:5ccff000)
[    0.000000] setup_percpu: NR_CPUS:2 nr_cpumask_bits:2 nr_cpu_ids:2 nr_node_ids:1
[    0.000000] PERCPU: Embedded 474 pages/cpu @ffff88003d600000 s1912704 r8192 d20608 u2097152
[    0.000000] pcpu-alloc: s1912704 r8192 d20608 u2097152 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 0 [0] 1 
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 445513
[    0.000000] Kernel command line: BOOT_IMAGE=/boot/vmlinuz-2.6.38-rc6-wl-65414-ge1b6053-dirty root=UUID=c4c96801-db1f-44df-acb4-3d600be51419 ro quiet no_console_suspend reboot=pci loglevel=9 mminit_loglevel=4
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Dentry cache hash table entries: 262144 (order: 9, 2097152 bytes)
[    0.000000] Inode-cache hash table entries: 131072 (order: 8, 1048576 bytes)
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Memory: 1740736k/2073016k available (4760k kernel code, 262596k absent, 69684k reserved, 3980k data, 2192k init)
[    0.000000] SLUB: Genslabs=15, HWalign=64, Order=0-3, MinObjects=0, CPUs=2, Nodes=1
[    0.000000] Preemptable hierarchical RCU implementation.
[    0.000000] 	RCU lockdep checking is enabled.
[    0.000000] NR_IRQS:320
[    0.000000] Extended CMOS year: 2000
[    0.000000] spurious 8259A interrupt: IRQ7.
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     16384
[    0.000000] ... MAX_LOCKDEP_CHAINS:      32768
[    0.000000] ... CHAINHASH_SIZE:          16384
[    0.000000]  memory used by lock dependency info: 6367 kB
[    0.000000]  per task-struct memory footprint: 2688 bytes
[    0.000000] ------------------------
[    0.000000] | Locking API testsuite:
[    0.000000] ----------------------------------------------------------------------------
[    0.000000]                                  | spin |wlock |rlock |mutex | wsem | rsem |
[    0.000000]   --------------------------------------------------------------------------
[    0.000000]                      A-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]                  A-B-B-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]              A-B-B-C-C-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]              A-B-C-A-B-C deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]          A-B-B-C-C-D-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]          A-B-C-D-B-D-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]          A-B-C-D-B-C-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]                     double unlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]                   initialize held:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]                  bad unlock order:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]   --------------------------------------------------------------------------
[    0.000000]               recursive read-lock:             |  ok  |             |  ok  |
[    0.000000]            recursive read-lock #2:             |  ok  |             |  ok  |
[    0.000000]             mixed read-write-lock:             |  ok  |             |  ok  |
[    0.000000]             mixed write-read-lock:             |  ok  |             |  ok  |
[    0.000000]   --------------------------------------------------------------------------
[    0.000000]      hard-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
[    0.000000]      soft-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
[    0.000000]      hard-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
[    0.000000]      soft-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
[    0.000000]        sirq-safe-A => hirqs-on/12:  ok  |  ok  |  ok  |
[    0.000000]        sirq-safe-A => hirqs-on/21:  ok  |  ok  |  ok  |
[    0.000000]          hard-safe-A + irqs-on/12:  ok  |  ok  |  ok  |
[    0.000000]          soft-safe-A + irqs-on/12:  ok  |  ok  |  ok  |
[    0.000000]          hard-safe-A + irqs-on/21:  ok  |  ok  |  ok  |
[    0.000000]          soft-safe-A + irqs-on/21:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/123:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/123:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/132:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/132:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/213:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/213:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/231:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/231:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/312:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/312:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/321:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/321:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq read-recursion/123:  ok  |
[    0.000000]       soft-irq read-recursion/123:  ok  |
[    0.000000]       hard-irq read-recursion/132:  ok  |
[    0.000000]       soft-irq read-recursion/132:  ok  |
[    0.000000]       hard-irq read-recursion/213:  ok  |
[    0.000000]       soft-irq read-recursion/213:  ok  |
[    0.000000]       hard-irq read-recursion/231:  ok  |
[    0.000000]       soft-irq read-recursion/231:  ok  |
[    0.000000]       hard-irq read-recursion/312:  ok  |
[    0.000000]       soft-irq read-recursion/312:  ok  |
[    0.000000]       hard-irq read-recursion/321:  ok  |
[    0.000000]       soft-irq read-recursion/321:  ok  |
[    0.000000] -------------------------------------------------------
[    0.000000] Good, all 218 testcases passed! |
[    0.000000] ---------------------------------
[    0.000000] ODEBUG: 1 of 1 active objects replaced
[    0.000000] hpet clockevent registered
[    0.000000] Fast TSC calibration using PIT
[    0.000000] Detected 1989.753 MHz processor.
[    0.010005] Calibrating delay loop (skipped), value calculated using timer frequency.. 3979.50 BogoMIPS (lpj=19897530)
[    0.010202] pid_max: default: 32768 minimum: 301
[    0.010625] Mount-cache hash table entries: 256
[    0.012849] CPU: Physical Processor ID: 0
[    0.012949] CPU: Processor Core ID: 0
[    0.013047] mce: CPU supports 6 MCE banks
[    0.013154] CPU0: Thermal monitoring enabled (TM2)
[    0.013255] using mwait in idle threads.
[    0.013468] ACPI: Core revision 20110112
[    0.072124] Setting APIC routing to flat
[    0.072782] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.172897] CPU0: Intel(R) Core(TM)2 Duo CPU     P7350  @ 2.00GHz stepping 06
[    0.180000] Performance Events: PEBS fmt0+, Core2 events, Intel PMU driver.
[    0.180000] ... version:                2
[    0.180000] ... bit width:              40
[    0.180000] ... generic registers:      2
[    0.180000] ... value mask:             000000ffffffffff
[    0.180000] ... max period:             000000007fffffff
[    0.180000] ... fixed-purpose events:   3
[    0.180000] ... event mask:             0000000700000003
[    0.200463] NMI watchdog enabled, takes one hw-pmu counter.
[    0.230083] lockdep: fixing up alternatives.
[    0.240369] Booting Node   0, Processors  #1 Ok.
[    0.410193] NMI watchdog enabled, takes one hw-pmu counter.
[    0.420027] Brought up 2 CPUs
[    0.420127] Total of 2 processors activated (7959.55 BogoMIPS).
[    0.421481] devtmpfs: initialized
[    0.421481] NET: Registered protocol family 16
[    0.430261] ACPI: bus type pci registered
[    0.430462] PCI: Using configuration type 1 for base access
[    0.450736] bio: create slab <bio-0> at 0
[    0.480627] ACPI: EC: EC description table is found, configuring boot EC
[    0.516619] [Firmware Bug]: ACPI: BIOS _OSI(Linux) query ignored
[    0.520214] ACPI: SSDT 000000007fecac98 001F6 (v01  APPLE  Cpu0Ist 00003000 INTL 20061109)
[    0.525367] ACPI: Dynamic OEM Table Load:
[    0.525557] ACPI: SSDT           (null) 001F6 (v01  APPLE  Cpu0Ist 00003000 INTL 20061109)
[    0.527079] ACPI: SSDT 000000007fec9c18 002AD (v01  APPLE  Cpu0Cst 00003001 INTL 20061109)
[    0.532346] ACPI: Dynamic OEM Table Load:
[    0.532540] ACPI: SSDT           (null) 002AD (v01  APPLE  Cpu0Cst 00003001 INTL 20061109)
[    0.612659] ACPI: SSDT 000000007fecaf18 000C8 (v01  APPLE  Cpu1Ist 00003000 INTL 20061109)
[    0.617710] ACPI: Dynamic OEM Table Load:
[    0.617902] ACPI: SSDT           (null) 000C8 (v01  APPLE  Cpu1Ist 00003000 INTL 20061109)
[    0.619247] ACPI: SSDT 000000007fec9f18 00085 (v01  APPLE  Cpu1Cst 00003000 INTL 20061109)
[    0.624143] ACPI: Dynamic OEM Table Load:
[    0.624337] ACPI: SSDT           (null) 00085 (v01  APPLE  Cpu1Cst 00003000 INTL 20061109)
[    0.683384] ACPI: Interpreter enabled
[    0.683479] ACPI: (supports S0 S4 S5)
[    0.683858] ACPI: Using IOAPIC for interrupt routing
[    0.795143] ACPI: EC: GPE = 0x3f, I/O: command/status = 0x66, data = 0x62
[    0.832304] ACPI: No dock devices found.
[    0.832407] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    0.834524] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.835463] pci_root PNP0A08:00: host bridge window [io  0x0000-0x0cf7]
[    0.835463] pci_root PNP0A08:00: host bridge window [io  0x0d00-0xffff]
[    0.835463] pci_root PNP0A08:00: host bridge window [mem 0x000a0000-0x000bffff]
[    0.835463] pci_root PNP0A08:00: host bridge window [mem 0x000c0000-0x000c3fff]
[    0.835463] pci_root PNP0A08:00: host bridge window [mem 0x000c4000-0x000c7fff]
[    0.835463] pci_root PNP0A08:00: host bridge window [mem 0x000c8000-0x000cbfff]
[    0.835463] pci_root PNP0A08:00: host bridge window [mem 0x000cc000-0x000cffff]
[    0.835463] pci_root PNP0A08:00: host bridge window [mem 0x000d0000-0x000d3fff]
[    0.835463] pci_root PNP0A08:00: host bridge window [mem 0x000d4000-0x000d7fff]
[    0.835463] pci_root PNP0A08:00: host bridge window [mem 0x000d8000-0x000dbfff]
[    0.835463] pci_root PNP0A08:00: host bridge window [mem 0x000dc000-0x000dffff]
[    0.835463] pci_root PNP0A08:00: host bridge window [mem 0x000e0000-0x000e3fff]
[    0.835463] pci_root PNP0A08:00: host bridge window [mem 0x000e4000-0x000e7fff]
[    0.835463] pci_root PNP0A08:00: host bridge window [mem 0x000e8000-0x000ebfff]
[    0.835463] pci_root PNP0A08:00: host bridge window [mem 0x000ec000-0x000effff]
[    0.835463] pci_root PNP0A08:00: host bridge window [mem 0x000f0000-0x000fffff]
[    0.835463] pci_root PNP0A08:00: host bridge window [mem 0x80000000-0xfebfffff]
[    0.835463] pci 0000:00:00.0: [10de:0a82] type 0 class 0x000600
[    0.835463] pci 0000:00:00.1: [10de:0a88] type 0 class 0x000500
[    0.835463] pci 0000:00:03.0: [10de:0aae] type 0 class 0x000601
[    0.835463] pci 0000:00:03.0: reg 10: [io  0x2000-0x20ff]
[    0.840175] pci 0000:00:03.1: [10de:0aa4] type 0 class 0x000500
[    0.840498] pci 0000:00:03.2: [10de:0aa2] type 0 class 0x000c05
[    0.840636] pci 0000:00:03.2: reg 10: [io  0x2180-0x21bf]
[    0.840812] pci 0000:00:03.2: reg 20: [io  0x2140-0x217f]
[    0.840931] pci 0000:00:03.2: reg 24: [io  0x2100-0x213f]
[    0.841102] pci 0000:00:03.2: PME# supported from D3hot D3cold
[    0.841212] pci 0000:00:03.2: PME# disabled
[    0.841357] pci 0000:00:03.3: [10de:0a89] type 0 class 0x000500
[    0.841731] pci 0000:00:03.4: [10de:0a98] type 0 class 0x000500
[    0.842041] pci 0000:00:03.5: [10de:0aa3] type 0 class 0x000b40
[    0.842179] pci 0000:00:03.5: reg 10: [mem 0x93300000-0x9337ffff]
[    0.842529] pci 0000:00:04.0: [10de:0aa5] type 0 class 0x000c03
[    0.842666] pci 0000:00:04.0: reg 10: [mem 0x93388000-0x93388fff]
[    0.842921] pci 0000:00:04.0: supports D1 D2
[    0.843020] pci 0000:00:04.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.843128] pci 0000:00:04.0: PME# disabled
[    0.844524] pci 0000:00:04.1: [10de:0aa6] type 0 class 0x000c03
[    0.844667] pci 0000:00:04.1: reg 10: [mem 0x93389200-0x933892ff]
[    0.844939] pci 0000:00:04.1: supports D1 D2
[    0.845038] pci 0000:00:04.1: PME# supported from D0 D1 D2 D3hot D3cold
[    0.845146] pci 0000:00:04.1: PME# disabled
[    0.845322] pci 0000:00:06.0: [10de:0aa7] type 0 class 0x000c03
[    0.845460] pci 0000:00:06.0: reg 10: [mem 0x93387000-0x93387fff]
[    0.845712] pci 0000:00:06.0: supports D1 D2
[    0.845811] pci 0000:00:06.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.845919] pci 0000:00:06.0: PME# disabled
[    0.846068] pci 0000:00:06.1: [10de:0aa9] type 0 class 0x000c03
[    0.846206] pci 0000:00:06.1: reg 10: [mem 0x93389100-0x933891ff]
[    0.846478] pci 0000:00:06.1: supports D1 D2
[    0.846577] pci 0000:00:06.1: PME# supported from D0 D1 D2 D3hot D3cold
[    0.846685] pci 0000:00:06.1: PME# disabled
[    0.846858] pci 0000:00:08.0: [10de:0ac0] type 0 class 0x000403
[    0.846995] pci 0000:00:08.0: reg 10: [mem 0x93380000-0x93383fff]
[    0.847251] pci 0000:00:08.0: PME# supported from D3hot D3cold
[    0.847355] pci 0000:00:08.0: PME# disabled
[    0.847499] pci 0000:00:09.0: [10de:0aab] type 1 class 0x000604
[    0.847781] pci 0000:00:0a.0: [10de:0ab0] type 0 class 0x000200
[    0.847923] pci 0000:00:0a.0: reg 10: [mem 0x93386000-0x93386fff]
[    0.848039] pci 0000:00:0a.0: reg 14: [io  0x21e0-0x21e7]
[    0.848158] pci 0000:00:0a.0: reg 18: [mem 0x93389000-0x933890ff]
[    0.848278] pci 0000:00:0a.0: reg 1c: [mem 0x93389300-0x9338930f]
[    0.848488] pci 0000:00:0a.0: supports D1 D2
[    0.848582] pci 0000:00:0a.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.848691] pci 0000:00:0a.0: PME# disabled
[    0.848850] pci 0000:00:0b.0: [10de:0ab5] type 0 class 0x000101
[    0.848995] pci 0000:00:0b.0: reg 10: [io  0x21d8-0x21df]
[    0.849114] pci 0000:00:0b.0: reg 14: [io  0x21ec-0x21ef]
[    0.849229] pci 0000:00:0b.0: reg 18: [io  0x21d0-0x21d7]
[    0.849347] pci 0000:00:0b.0: reg 1c: [io  0x21e8-0x21eb]
[    0.849466] pci 0000:00:0b.0: reg 20: [io  0x21c0-0x21cf]
[    0.849584] pci 0000:00:0b.0: reg 24: [mem 0x93384000-0x93385fff]
[    0.849844] pci 0000:00:10.0: [10de:0aa0] type 1 class 0x000604
[    0.850187] pci 0000:00:10.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.850296] pci 0000:00:10.0: PME# disabled
[    0.850510] pci 0000:00:15.0: [10de:0ac6] type 1 class 0x000604
[    0.850887] pci 0000:00:15.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.851000] pci 0000:00:15.0: PME# disabled
[    0.851371] pci 0000:00:09.0: PCI bridge to [bus 01-01] (subtractive decode)
[    0.851480] pci 0000:00:09.0:   bridge window [io  0xf000-0x0000] (disabled)
[    0.851589] pci 0000:00:09.0:   bridge window [mem 0x93200000-0x932fffff]
[    0.851694] pci 0000:00:09.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
[    0.851844] pci 0000:00:09.0:   bridge window [io  0x0000-0x0cf7] (subtractive decode)
[    0.851993] pci 0000:00:09.0:   bridge window [io  0x0d00-0xffff] (subtractive decode)
[    0.852143] pci 0000:00:09.0:   bridge window [mem 0x000a0000-0x000bffff] (subtractive decode)
[    0.852288] pci 0000:00:09.0:   bridge window [mem 0x000c0000-0x000c3fff] (subtractive decode)
[    0.852438] pci 0000:00:09.0:   bridge window [mem 0x000c4000-0x000c7fff] (subtractive decode)
[    0.852588] pci 0000:00:09.0:   bridge window [mem 0x000c8000-0x000cbfff] (subtractive decode)
[    0.852738] pci 0000:00:09.0:   bridge window [mem 0x000cc000-0x000cffff] (subtractive decode)
[    0.852884] pci 0000:00:09.0:   bridge window [mem 0x000d0000-0x000d3fff] (subtractive decode)
[    0.853034] pci 0000:00:09.0:   bridge window [mem 0x000d4000-0x000d7fff] (subtractive decode)
[    0.853184] pci 0000:00:09.0:   bridge window [mem 0x000d8000-0x000dbfff] (subtractive decode)
[    0.853334] pci 0000:00:09.0:   bridge window [mem 0x000dc000-0x000dffff] (subtractive decode)
[    0.853479] pci 0000:00:09.0:   bridge window [mem 0x000e0000-0x000e3fff] (subtractive decode)
[    0.853629] pci 0000:00:09.0:   bridge window [mem 0x000e4000-0x000e7fff] (subtractive decode)
[    0.853779] pci 0000:00:09.0:   bridge window [mem 0x000e8000-0x000ebfff] (subtractive decode)
[    0.853929] pci 0000:00:09.0:   bridge window [mem 0x000ec000-0x000effff] (subtractive decode)
[    0.854077] pci 0000:00:09.0:   bridge window [mem 0x000f0000-0x000fffff] (subtractive decode)
[    0.854227] pci 0000:00:09.0:   bridge window [mem 0x80000000-0xfebfffff] (subtractive decode)
[    0.854513] pci 0000:02:00.0: [10de:0863] type 0 class 0x000300
[    0.854657] pci 0000:02:00.0: reg 10: [mem 0x92000000-0x92ffffff]
[    0.854791] pci 0000:02:00.0: reg 14: [mem 0x80000000-0x8fffffff 64bit pref]
[    0.854926] pci 0000:02:00.0: reg 1c: [mem 0x90000000-0x91ffffff 64bit pref]
[    0.855051] pci 0000:02:00.0: reg 24: [io  0x1000-0x107f]
[    0.855172] pci 0000:02:00.0: reg 30: [mem 0x93000000-0x9301ffff pref]
[    0.855463] pci 0000:00:10.0: PCI bridge to [bus 02-02]
[    0.855573] pci 0000:00:10.0:   bridge window [io  0x1000-0x1fff]
[    0.855680] pci 0000:00:10.0:   bridge window [mem 0x92000000-0x930fffff]
[    0.855793] pci 0000:00:10.0:   bridge window [mem 0x80000000-0x91ffffff 64bit pref]
[    0.856373] pci 0000:03:00.0: [14e4:432b] type 0 class 0x000280
[    0.856516] pci 0000:03:00.0: reg 10: [mem 0x93100000-0x93103fff 64bit]
[    0.856817] pci 0000:03:00.0: supports D1 D2
[    0.856917] pci 0000:03:00.0: PME# supported from D0 D3hot D3cold
[    0.857025] pci 0000:03:00.0: PME# disabled
[    0.857153] pci 0000:00:15.0: PCI bridge to [bus 03-03]
[    0.857274] pci 0000:00:15.0:   bridge window [io  0xfffffffffffff000-0x0000] (disabled)
[    0.857432] pci 0000:00:15.0:   bridge window [mem 0x93100000-0x931fffff]
[    0.857555] pci 0000:00:15.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
[    0.857744] pci_bus 0000:00: on NUMA node 0
[    0.857852] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    0.860329] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.IXVE._PRT]
[    1.133737] ACPI: PCI Interrupt Link [LNK1] (IRQs 5 7 10 11 14 15) *0, disabled.
[    1.133737] ACPI: PCI Interrupt Link [LNK2] (IRQs 5 7 10 11 14 15) *0, disabled.
[    1.140864] ACPI: PCI Interrupt Link [LNK3] (IRQs 5 7 10 11 14 15) *0, disabled.
[    1.142509] ACPI: PCI Interrupt Link [LNK4] (IRQs 5 7 10 11 14 15) *0, disabled.
[    1.144149] ACPI: PCI Interrupt Link [Z003] (IRQs 16 17 18 19 20 21 22 23) *0, disabled.
[    1.145878] ACPI: PCI Interrupt Link [Z004] (IRQs 16 17 18 19 20 21 22 23) *0, disabled.
[    1.147607] ACPI: PCI Interrupt Link [Z005] (IRQs 16 17 18 19 20 21 22 23) *0, disabled.
[    1.149335] ACPI: PCI Interrupt Link [Z006] (IRQs 16 17 18 19 20 21 22 23) *0, disabled.
[    1.151059] ACPI: PCI Interrupt Link [Z007] (IRQs 16 17 18 19 20 21 22 23) *0, disabled.
[    1.152794] ACPI: PCI Interrupt Link [Z008] (IRQs 16 17 18 19 20 21 22 23) *0, disabled.
[    1.154517] ACPI: PCI Interrupt Link [Z009] (IRQs 16 17 18 19 20 21 22 23) *0, disabled.
[    1.156238] ACPI: PCI Interrupt Link [Z00A] (IRQs 16 17 18 19 20 21 22 23) *0, disabled.
[    1.157960] ACPI: PCI Interrupt Link [Z00B] (IRQs 16 17 18 19 20 21 22 23) *0, disabled.
[    1.159682] ACPI: PCI Interrupt Link [Z00C] (IRQs 16 17 18 19 20 21 22 23) *0, disabled.
[    1.161729] ACPI: PCI Interrupt Link [Z00D] (IRQs 16 17 18 19 20 21 22 23) *0, disabled.
[    1.163445] ACPI: PCI Interrupt Link [Z00E] (IRQs 16 17 18 19 20 21 22 23) *0, disabled.
[    1.165241] ACPI: PCI Interrupt Link [Z00F] (IRQs 16 17 18 19 20 21 22 23) *10
[    1.167004] ACPI: PCI Interrupt Link [Z00G] (IRQs 16 17 18 19 20 21 22 23) *0, disabled.
[    1.168758] ACPI: PCI Interrupt Link [Z00H] (IRQs 16 17 18 19 20 21 22 23) *0, disabled.
[    1.170548] ACPI: PCI Interrupt Link [Z00I] (IRQs 16 17 18 19 20 21 22 23) *0, disabled.
[    1.172296] ACPI: PCI Interrupt Link [Z00J] (IRQs 16 17 18 19 20 21 22 23) *0, disabled.
[    1.174044] ACPI: PCI Interrupt Link [Z00K] (IRQs 16 17 18 19 20 21 22 23) *0, disabled.
[    1.175795] ACPI: PCI Interrupt Link [Z00L] (IRQs 16 17 18 19 20 21 22 23) *0, disabled.
[    1.177539] ACPI: PCI Interrupt Link [Z00M] (IRQs 16 17 18 19 20 21 22 23) *0, disabled.
[    1.179282] ACPI: PCI Interrupt Link [Z00N] (IRQs 16 17 18 19 20 21 22 23) *0, disabled.
[    1.181075] ACPI: PCI Interrupt Link [Z00O] (IRQs 16 17 18 19 20 21 22 23) *0, disabled.
[    1.182816] ACPI: PCI Interrupt Link [Z00P] (IRQs 16 17 18 19 20 21 22 23) *0, disabled.
[    1.184553] ACPI: PCI Interrupt Link [Z00Q] (IRQs 16 17 18 19 20 21 22 23) *0, disabled.
[    1.186286] ACPI: PCI Interrupt Link [Z00R] (IRQs 16 17 18 19 20 21 22 23) *0, disabled.
[    1.188032] ACPI: PCI Interrupt Link [Z00S] (IRQs 16 17 18 19 20 21 22 23) *0, disabled.
[    1.189771] ACPI: PCI Interrupt Link [Z00T] (IRQs 16 17 18 19 20 21 22 23) *0, disabled.
[    1.191520] ACPI: PCI Interrupt Link [Z00U] (IRQs 16 17 18 19 20 21 22 23) *0, disabled.
[    1.193258] ACPI: PCI Interrupt Link [LSMB] (IRQs 16 17 18 19 20 21 22 23) *15
[    1.194941] ACPI: PCI Interrupt Link [LUS0] (IRQs 16 17 18 19 20 21 22 23) *11
[    1.196625] ACPI: PCI Interrupt Link [LUS2] (IRQs 16 17 18 19 20 21 22 23) *10
[    1.198305] ACPI: PCI Interrupt Link [LMAC] (IRQs 16 17 18 19 20 21 22 23) *14
[    1.200073] ACPI: PCI Interrupt Link [LAZA] (IRQs 16 17 18 19 20 21 22 23) *15
[    1.201771] ACPI: PCI Interrupt Link [LGPU] (IRQs 16 17 18 19 20 21 22 23) *11
[    1.204701] ACPI: PCI Interrupt Link [LPID] (IRQs 16 17 18 19 20 21 22 23) *0, disabled.
[    1.206450] ACPI: PCI Interrupt Link [LSI0] (IRQs 16 17 18 19 20 21 22 23) *11
[    1.208148] ACPI: PCI Interrupt Link [LSI1] (IRQs 16 17 18 19 20 21 22 23) *0, disabled.
[    1.209889] ACPI: PCI Interrupt Link [Z000] (IRQs 16 17 18 19 20 21 22 23) *7
[    1.211557] ACPI: PCI Interrupt Link [Z001] (IRQs 16 17 18 19 20 21 22 23) *5
[    1.213196] ACPI: PCI Interrupt Link [LPMU] (IRQs 16 17 18 19 20 21 22 23) *14
[    1.214147] vgaarb: device added: PCI:0000:02:00.0,decodes=io+mem,owns=io+mem,locks=none
[    1.214147] vgaarb: loaded
[    1.214147] SCSI subsystem initialized
[    1.214147] libata version 3.00 loaded.
[    1.214147] PCI: Using ACPI for IRQ routing
[    1.214147] PCI: pci_cache_line_size set to 64 bytes
[    1.214147] reserve RAM buffer: 000000000009fc00 - 000000000009ffff 
[    1.214147] reserve RAM buffer: 000000007e86e000 - 000000007fffffff 
[    1.220897] HPET: 4 timers in total, 0 timers will be used for per-cpu timer
[    1.250160] Switching to clocksource hpet
[    1.259555] Switched to NOHz mode on CPU #0
[    1.259623] Switched to NOHz mode on CPU #1
[    1.293263] pnp: PnP ACPI init
[    1.293510] ACPI: bus type pnp registered
[    1.294358] pnp 00:00: [bus 00-ff]
[    1.294460] pnp 00:00: [io  0x0cf8-0x0cff]
[    1.294560] pnp 00:00: [io  0x0000-0x0cf7 window]
[    1.294661] pnp 00:00: [io  0x0d00-0xffff window]
[    1.294762] pnp 00:00: [mem 0x000a0000-0x000bffff window]
[    1.294864] pnp 00:00: [mem 0x000c0000-0x000c3fff window]
[    1.294961] pnp 00:00: [mem 0x000c4000-0x000c7fff window]
[    1.295063] pnp 00:00: [mem 0x000c8000-0x000cbfff window]
[    1.295165] pnp 00:00: [mem 0x000cc000-0x000cffff window]
[    1.295267] pnp 00:00: [mem 0x000d0000-0x000d3fff window]
[    1.295369] pnp 00:00: [mem 0x000d4000-0x000d7fff window]
[    1.295470] pnp 00:00: [mem 0x000d8000-0x000dbfff window]
[    1.295567] pnp 00:00: [mem 0x000dc000-0x000dffff window]
[    1.295669] pnp 00:00: [mem 0x000e0000-0x000e3fff window]
[    1.295771] pnp 00:00: [mem 0x000e4000-0x000e7fff window]
[    1.295873] pnp 00:00: [mem 0x000e8000-0x000ebfff window]
[    1.295975] pnp 00:00: [mem 0x000ec000-0x000effff window]
[    1.296077] pnp 00:00: [mem 0x000f0000-0x000fffff window]
[    1.296174] pnp 00:00: [mem 0x80000000-0xfebfffff window]
[    1.297048] pnp 00:00: Plug and Play ACPI device, IDs PNP0a08 PNP0a03 (active)
[    1.297368] pnp 00:01: [mem 0x00000000-0xffffffffffffffff disabled]
[    1.297484] pnp 00:01: [mem 0xf0000000-0xf3ffffff]
[    1.298169] system 00:01: [mem 0xf0000000-0xf3ffffff] has been reserved
[    1.298284] system 00:01: Plug and Play ACPI device, IDs PNP0c02 (active)
[    1.298482] pnp 00:02: [io  0x0300-0x031f]
[    1.298599] pnp 00:02: [irq 6]
[    1.299102] pnp 00:02: Plug and Play ACPI device, IDs APP0001 (active)
[    1.299571] pnp 00:03: [io  0x0000-0x0008]
[    1.299672] pnp 00:03: [io  0x000a-0x000f]
[    1.299771] pnp 00:03: [io  0x0081-0x0083]
[    1.299868] pnp 00:03: [io  0x0087]
[    1.299966] pnp 00:03: [io  0x0089-0x008b]
[    1.300094] pnp 00:03: [io  0x008f]
[    1.300193] pnp 00:03: [io  0x00c0-0x00d1]
[    1.300293] pnp 00:03: [io  0x00d4-0x00df]
[    1.300390] pnp 00:03: [dma 4]
[    1.300922] pnp 00:03: Plug and Play ACPI device, IDs PNP0200 (active)
[    1.301614] pnp 00:04: [irq 0 disabled]
[    1.301728] pnp 00:04: [irq 8]
[    1.301827] pnp 00:04: [mem 0xfed00000-0xfed003ff]
[    1.302484] system 00:04: [mem 0xfed00000-0xfed003ff] has been reserved
[    1.302597] system 00:04: Plug and Play ACPI device, IDs PNP0103 PNP0c01 (active)
[    1.302830] pnp 00:05: [io  0x00f0-0x00f1]
[    1.302943] pnp 00:05: [irq 13]
[    1.303565] pnp 00:05: Plug and Play ACPI device, IDs PNP0c04 (active)
[    1.305034] pnp 00:06: [io  0x0400-0x047f]
[    1.305136] pnp 00:06: [io  0x0480-0x04ff]
[    1.305233] pnp 00:06: [io  0x0500-0x057f]
[    1.305332] pnp 00:06: [io  0x0580-0x05ff]
[    1.305431] pnp 00:06: [io  0x0800-0x087f]
[    1.305541] pnp 00:06: [io  0x0880-0x08ff]
[    1.305640] pnp 00:06: [io  0x2140-0x217f]
[    1.305740] pnp 00:06: [io  0x2100-0x213f]
[    1.305839] pnp 00:06: [io  0x0010-0x001f]
[    1.305938] pnp 00:06: [io  0x0022-0x003f]
[    1.306038] pnp 00:06: [io  0x0044-0x005f]
[    1.306137] pnp 00:06: [io  0x0062-0x0063]
[    1.306236] pnp 00:06: [io  0x0065-0x006f]
[    1.306335] pnp 00:06: [io  0x0072-0x0073]
[    1.306435] pnp 00:06: [io  0x0074-0x007f]
[    1.306534] pnp 00:06: [io  0x0091-0x0093]
[    1.306633] pnp 00:06: [io  0x0097-0x009f]
[    1.306732] pnp 00:06: [io  0x00a2-0x00bf]
[    1.306831] pnp 00:06: [io  0x00e0-0x00ef]
[    1.306931] pnp 00:06: [io  0x04d0-0x04d1]
[    1.307030] pnp 00:06: [io  0x0080]
[    1.307129] pnp 00:06: [io  0x0295-0x0296]
[    1.307829] system 00:06: [io  0x0400-0x047f] has been reserved
[    1.307937] system 00:06: [io  0x0480-0x04ff] has been reserved
[    1.308042] system 00:06: [io  0x0500-0x057f] has been reserved
[    1.308148] system 00:06: [io  0x0580-0x05ff] has been reserved
[    1.308253] system 00:06: [io  0x0800-0x087f] has been reserved
[    1.308359] system 00:06: [io  0x0880-0x08ff] has been reserved
[    1.308464] system 00:06: [io  0x2140-0x217f] has been reserved
[    1.308567] system 00:06: [io  0x2100-0x213f] has been reserved
[    1.308674] system 00:06: [io  0x04d0-0x04d1] has been reserved
[    1.308779] system 00:06: [io  0x0295-0x0296] has been reserved
[    1.308889] system 00:06: Plug and Play ACPI device, IDs PNP0c02 (active)
[    1.309096] pnp 00:07: [io  0x0070-0x0077]
[    1.309631] pnp 00:07: Plug and Play ACPI device, IDs PNP0b00 (active)
[    1.323391] pnp: PnP ACPI: found 8 devices
[    1.323493] ACPI: ACPI bus type pnp unregistered
[    1.361031] pci 0000:00:09.0: PCI bridge to [bus 01-01]
[    1.361138] pci 0000:00:09.0:   bridge window [io  disabled]
[    1.361248] pci 0000:00:09.0:   bridge window [mem 0x93200000-0x932fffff]
[    1.361355] pci 0000:00:09.0:   bridge window [mem pref disabled]
[    1.361467] pci 0000:00:10.0: PCI bridge to [bus 02-02]
[    1.361570] pci 0000:00:10.0:   bridge window [io  0x1000-0x1fff]
[    1.361679] pci 0000:00:10.0:   bridge window [mem 0x92000000-0x930fffff]
[    1.361786] pci 0000:00:10.0:   bridge window [mem 0x80000000-0x91ffffff 64bit pref]
[    1.361939] pci 0000:00:15.0: PCI bridge to [bus 03-03]
[    1.362039] pci 0000:00:15.0:   bridge window [io  disabled]
[    1.362154] pci 0000:00:15.0:   bridge window [mem 0x93100000-0x931fffff]
[    1.362265] pci 0000:00:15.0:   bridge window [mem pref disabled]
[    1.362390] pci 0000:00:09.0: enabling device (0000 -> 0002)
[    1.362500] pci 0000:00:09.0: setting latency timer to 64
[    1.362621] pci 0000:00:10.0: setting latency timer to 64
[    1.364540] ACPI: PCI Interrupt Link [Z00F] enabled at IRQ 23
[    1.364664] pci 0000:00:15.0: PCI INT A -> Link[Z00F] -> GSI 23 (level, low) -> IRQ 23
[    1.364824] pci 0000:00:15.0: setting latency timer to 64
[    1.364928] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    1.365030] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    1.365131] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    1.365233] pci_bus 0000:00: resource 7 [mem 0x000c0000-0x000c3fff]
[    1.365336] pci_bus 0000:00: resource 8 [mem 0x000c4000-0x000c7fff]
[    1.365438] pci_bus 0000:00: resource 9 [mem 0x000c8000-0x000cbfff]
[    1.365535] pci_bus 0000:00: resource 10 [mem 0x000cc000-0x000cffff]
[    1.365637] pci_bus 0000:00: resource 11 [mem 0x000d0000-0x000d3fff]
[    1.365740] pci_bus 0000:00: resource 12 [mem 0x000d4000-0x000d7fff]
[    1.365842] pci_bus 0000:00: resource 13 [mem 0x000d8000-0x000dbfff]
[    1.365944] pci_bus 0000:00: resource 14 [mem 0x000dc000-0x000dffff]
[    1.366046] pci_bus 0000:00: resource 15 [mem 0x000e0000-0x000e3fff]
[    1.366145] pci_bus 0000:00: resource 16 [mem 0x000e4000-0x000e7fff]
[    1.366247] pci_bus 0000:00: resource 17 [mem 0x000e8000-0x000ebfff]
[    1.366349] pci_bus 0000:00: resource 18 [mem 0x000ec000-0x000effff]
[    1.366451] pci_bus 0000:00: resource 19 [mem 0x000f0000-0x000fffff]
[    1.366554] pci_bus 0000:00: resource 20 [mem 0x80000000-0xfebfffff]
[    1.366656] pci_bus 0000:01: resource 1 [mem 0x93200000-0x932fffff]
[    1.366756] pci_bus 0000:01: resource 4 [io  0x0000-0x0cf7]
[    1.366856] pci_bus 0000:01: resource 5 [io  0x0d00-0xffff]
[    1.366957] pci_bus 0000:01: resource 6 [mem 0x000a0000-0x000bffff]
[    1.367059] pci_bus 0000:01: resource 7 [mem 0x000c0000-0x000c3fff]
[    1.367162] pci_bus 0000:01: resource 8 [mem 0x000c4000-0x000c7fff]
[    1.367264] pci_bus 0000:01: resource 9 [mem 0x000c8000-0x000cbfff]
[    1.367361] pci_bus 0000:01: resource 10 [mem 0x000cc000-0x000cffff]
[    1.367463] pci_bus 0000:01: resource 11 [mem 0x000d0000-0x000d3fff]
[    1.367565] pci_bus 0000:01: resource 12 [mem 0x000d4000-0x000d7fff]
[    1.367667] pci_bus 0000:01: resource 13 [mem 0x000d8000-0x000dbfff]
[    1.367770] pci_bus 0000:01: resource 14 [mem 0x000dc000-0x000dffff]
[    1.367872] pci_bus 0000:01: resource 15 [mem 0x000e0000-0x000e3fff]
[    1.367969] pci_bus 0000:01: resource 16 [mem 0x000e4000-0x000e7fff]
[    1.368071] pci_bus 0000:01: resource 17 [mem 0x000e8000-0x000ebfff]
[    1.368173] pci_bus 0000:01: resource 18 [mem 0x000ec000-0x000effff]
[    1.368275] pci_bus 0000:01: resource 19 [mem 0x000f0000-0x000fffff]
[    1.368377] pci_bus 0000:01: resource 20 [mem 0x80000000-0xfebfffff]
[    1.368480] pci_bus 0000:02: resource 0 [io  0x1000-0x1fff]
[    1.368576] pci_bus 0000:02: resource 1 [mem 0x92000000-0x930fffff]
[    1.368678] pci_bus 0000:02: resource 2 [mem 0x80000000-0x91ffffff 64bit pref]
[    1.368826] pci_bus 0000:03: resource 1 [mem 0x93100000-0x931fffff]
[    1.369158] NET: Registered protocol family 2
[    1.369809] IP route cache hash table entries: 65536 (order: 7, 524288 bytes)
[    1.372089] TCP established hash table entries: 262144 (order: 10, 4194304 bytes)
[    1.374601] TCP bind hash table entries: 32768 (order: 9, 2621440 bytes)
[    1.379074] TCP: Hash tables configured (established 262144 bind 32768)
[    1.379260] TCP reno registered
[    1.379391] UDP hash table entries: 1024 (order: 5, 196608 bytes)
[    1.379801] UDP-Lite hash table entries: 1024 (order: 5, 196608 bytes)
[    1.400468] pci 0000:02:00.0: Boot video device
[    1.401989] PCI: CLS 256 bytes, default 64
[    1.402820] Unpacking initramfs...
[    1.695493] debug: unmapping init memory ffff880036ff0000..ffff8800377f0000
[    1.703137] audit: initializing netlink socket (disabled)
[    1.703326] type=2000 audit(1298549134.700:1): initialized
[    1.765785] SGI XFS with ACLs, security attributes, large block/inode numbers, no debug enabled
[    1.773153] msgmni has been set to 3399
[    1.775383] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 254)
[    1.775564] io scheduler noop registered
[    1.775664] io scheduler deadline registered
[    1.776488] io scheduler cfq registered (default)
[    1.786618] ACPI: AC Adapter [ADP1] (on-line)
[    1.788176] input: Lid Switch as /devices/LNXSYSTM:00/device:00/PNP0C0D:00/input/input0
[    1.850115] ACPI: Lid Switch [LID0]
[    1.850777] input: Power Button as /devices/LNXSYSTM:00/device:00/PNP0C0C:00/input/input1
[    1.851016] ACPI: Power Button [PWRB]
[    1.851663] input: Sleep Button as /devices/LNXSYSTM:00/device:00/PNP0C0E:00/input/input2
[    1.851823] ACPI: Sleep Button [SLPB]
[    1.852563] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input3
[    1.852718] ACPI: Power Button [PWRF]
[    1.853469] ACPI: acpi_idle registered with cpuidle
[    1.854762] Monitor-Mwait will be used to enter C-1 state
[    1.854990] Monitor-Mwait will be used to enter C-2 state
[    1.855199] Monitor-Mwait will be used to enter C-3 state
[    1.855316] Marking TSC unstable due to TSC halts in idle
[    1.891045] Real Time Clock Driver v1.12b
[    1.892193] Non-volatile memory driver v1.3
[    1.893133] Linux agpgart interface v0.103
[    1.894981] ahci 0000:00:0b.0: version 3.0
[    1.897493] ACPI: PCI Interrupt Link [LSI0] enabled at IRQ 22
[    1.897705] ahci 0000:00:0b.0: PCI INT A -> Link[LSI0] -> GSI 22 (level, low) -> IRQ 22
[    1.898003] ahci 0000:00:0b.0: irq 40 for MSI/MSI-X
[    1.898118] ahci 0000:00:0b.0: controller can't do PMP, turning off CAP_PMP
[    1.898414] ahci 0000:00:0b.0: AHCI 0001.0200 32 slots 6 ports 3 Gbps 0x3 impl IDE mode
[    1.898565] ahci 0000:00:0b.0: flags: 64bit ncq sntf pm led pio slum part boh 
[    1.898718] ahci 0000:00:0b.0: setting latency timer to 64
[    1.913586] scsi0 : ahci
[    1.916978] scsi1 : ahci
[    1.918034] scsi2 : ahci
[    1.919191] scsi3 : ahci
[    1.920735] scsi4 : ahci
[    1.922935] scsi5 : ahci
[    1.926536] ata1: SATA max UDMA/133 irq_stat 0x00400040, connection status changed irq 40
[    1.926687] ata2: SATA max UDMA/133 irq_stat 0x00400040, connection status changed irq 40
[    1.926836] ata3: DUMMY
[    1.926931] ata4: DUMMY
[    1.927027] ata5: DUMMY
[    1.927120] ata6: DUMMY
[    1.928510] forcedeth: Reverse Engineered nForce ethernet driver. Version 0.64.
[    1.930534] ACPI: PCI Interrupt Link [LMAC] enabled at IRQ 21
[    1.930662] forcedeth 0000:00:0a.0: PCI INT A -> Link[LMAC] -> GSI 21 (level, low) -> IRQ 21
[    1.930879] forcedeth 0000:00:0a.0: setting latency timer to 64
[    2.013942] forcedeth 0000:00:0a.0: ifname eth0, PHY OUI 0x732 @ 1, addr 00:23:df:7d:c0:88
[    2.014095] forcedeth 0000:00:0a.0: highdma csum pwrctl gbit lnktim msi desc-v3
[    2.015507] console [netcon0] enabled
[    2.015603] netconsole: network logging started
[    2.016612] mousedev: PS/2 mouse device common for all mice
[    2.016714] i2c /dev entries driver
[    2.022095] device-mapper: uevent: version 1.0.3
[    2.023513] device-mapper: ioctl: 4.19.1-ioctl (2011-01-07) initialised: dm-devel@redhat.com
[    2.026112] cpuidle: using governor ladder
[    2.031047] cpuidle: using governor menu
[    2.035477] TCP cubic registered
[    2.038611] NET: Registered protocol family 10
[    2.046975] IPv6 over IPv4 tunneling driver
[    2.052036] Registering the dns_resolver key type
[    2.053939] PM: Hibernation image not present or could not be loaded.
[    2.054127] registered taskstats version 1
[    2.064115] ACPI: Battery Slot [BAT0] (battery present)
[    2.670166] ata2: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
[    2.670365] ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[    2.670923] ata1.00: ATA-7: INTEL SSDSA2M080G2GN, 2CV102HA, max UDMA/133
[    2.671033] ata1.00: 156301488 sectors, multi 16: LBA48 NCQ (depth 31/32)
[    2.671459] ata2.00: ATAPI: OPTIARC  DVD RW AD-5960S, 1APG, max UDMA/100
[    2.671612] ata1.00: configured for UDMA/133
[    2.673258] ata2.00: configured for UDMA/100
[    2.673393] scsi 0:0:0:0: Direct-Access     ATA      INTEL SSDSA2M080 2CV1 PQ: 0 ANSI: 5
[    2.678874] scsi 1:0:0:0: CD-ROM            OPTIARC  DVD RW AD-5960S  1APG PQ: 0 ANSI: 5
[    2.681077] debug: unmapping init memory ffffffff8188b000..ffffffff81aaf000
[    2.681371] Write protecting the kernel read-only data: 8192k
[    2.681757] debug: unmapping init memory ffff8800014ab000..ffff880001600000
[    2.681999] debug: unmapping init memory ffff8800017ea000..ffff880001800000
[    2.779383] NET: Registered protocol family 1
[    2.785420] udev[758]: starting version 166
[    3.283302] sd 0:0:0:0: [sda] 156301488 512-byte logical blocks: (80.0 GB/74.5 GiB)
[    3.283988] sd 0:0:0:0: [sda] Write Protect is off
[    3.284091] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    3.284346] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    3.289552]  sda: sda1 sda2 sda3 sda4 sda5 sda6
[    3.293042] sd 0:0:0:0: [sda] Attached SCSI disk
[    3.317791] usbcore: registered new interface driver usbfs
[    3.318650] sr0: scsi3-mmc drive: 24x/24x writer cd/rw xa/form2 cdda caddy
[    3.318758] cdrom: Uniform CD-ROM driver Revision: 3.20
[    3.324720] sr 1:0:0:0: Attached scsi CD-ROM sr0
[    3.334202] usbcore: registered new interface driver hub
[    3.345258] usbcore: registered new device driver usb
[    3.356088] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    3.358165] ACPI: PCI Interrupt Link [LUS2] enabled at IRQ 20
[    3.358293] ehci_hcd 0000:00:04.1: PCI INT B -> Link[LUS2] -> GSI 20 (level, low) -> IRQ 20
[    3.358491] ehci_hcd 0000:00:04.1: setting latency timer to 64
[    3.358596] ehci_hcd 0000:00:04.1: EHCI Host Controller
[    3.359819] ehci_hcd 0000:00:04.1: new USB bus registered, assigned bus number 1
[    3.386671] sd 0:0:0:0: Attached scsi generic sg0 type 0
[    3.387135] ehci_hcd 0000:00:04.1: debug port 1
[    3.387250] ehci_hcd 0000:00:04.1: cache line size of 256 is not supported
[    3.397366] ehci_hcd 0000:00:04.1: irq 20, io mem 0x93389200
[    3.410218] ehci_hcd 0000:00:04.1: USB 2.0 started, EHCI 1.00
[    3.410911] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[    3.411016] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    3.411166] usb usb1: Product: EHCI Host Controller
[    3.411267] usb usb1: Manufacturer: Linux 2.6.38-rc6-wl-65414-ge1b6053-dirty ehci_hcd
[    3.411482] usb usb1: SerialNumber: 0000:00:04.1
[    3.416835] sr 1:0:0:0: Attached scsi generic sg1 type 5
[    3.417684] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    3.435635] hub 1-0:1.0: USB hub found
[    3.435864] hub 1-0:1.0: 7 ports detected
[    3.441980] ACPI: PCI Interrupt Link [LUS0] enabled at IRQ 19
[    3.442110] ohci_hcd 0000:00:04.0: PCI INT A -> Link[LUS0] -> GSI 19 (level, low) -> IRQ 19
[    3.442309] ohci_hcd 0000:00:04.0: setting latency timer to 64
[    3.442415] ohci_hcd 0000:00:04.0: OHCI Host Controller
[    3.442600] ohci_hcd 0000:00:04.0: new USB bus registered, assigned bus number 2
[    3.470510] ohci_hcd 0000:00:04.0: irq 19, io mem 0x93388000
[    3.532892] usb usb2: New USB device found, idVendor=1d6b, idProduct=0001
[    3.533002] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    3.533150] usb usb2: Product: OHCI Host Controller
[    3.533245] usb usb2: Manufacturer: Linux 2.6.38-rc6-wl-65414-ge1b6053-dirty ohci_hcd
[    3.533393] usb usb2: SerialNumber: 0000:00:04.0
[    3.534475] hub 2-0:1.0: USB hub found
[    3.534619] hub 2-0:1.0: 7 ports detected
[    3.537500] ACPI: PCI Interrupt Link [Z000] enabled at IRQ 18
[    3.537626] ohci_hcd 0000:00:06.0: PCI INT A -> Link[Z000] -> GSI 18 (level, low) -> IRQ 18
[    3.537829] ohci_hcd 0000:00:06.0: setting latency timer to 64
[    3.537934] ohci_hcd 0000:00:06.0: OHCI Host Controller
[    3.538121] ohci_hcd 0000:00:06.0: new USB bus registered, assigned bus number 3
[    3.560289] ohci_hcd 0000:00:06.0: irq 18, io mem 0x93387000
[    3.622418] usb usb3: New USB device found, idVendor=1d6b, idProduct=0001
[    3.622528] usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    3.622675] usb usb3: Product: OHCI Host Controller
[    3.622774] usb usb3: Manufacturer: Linux 2.6.38-rc6-wl-65414-ge1b6053-dirty ohci_hcd
[    3.622919] usb usb3: SerialNumber: 0000:00:06.0
[    3.623965] hub 3-0:1.0: USB hub found
[    3.624108] hub 3-0:1.0: 5 ports detected
[    3.627125] ACPI: PCI Interrupt Link [Z001] enabled at IRQ 17
[    3.627254] ehci_hcd 0000:00:06.1: PCI INT B -> Link[Z001] -> GSI 17 (level, low) -> IRQ 17
[    3.627460] ehci_hcd 0000:00:06.1: setting latency timer to 64
[    3.627566] ehci_hcd 0000:00:06.1: EHCI Host Controller
[    3.628978] ehci_hcd 0000:00:06.1: new USB bus registered, assigned bus number 4
[    3.660367] ehci_hcd 0000:00:06.1: debug port 1
[    3.660486] ehci_hcd 0000:00:06.1: cache line size of 256 is not supported
[    3.660693] ehci_hcd 0000:00:06.1: irq 17, io mem 0x93389100
[    3.760263] usb 1-4: new high speed USB device using ehci_hcd and address 2
[    3.780227] ehci_hcd 0000:00:06.1: USB 2.0 started, EHCI 1.00
[    3.780512] usb usb4: New USB device found, idVendor=1d6b, idProduct=0002
[    3.780619] usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    3.780766] usb usb4: Product: EHCI Host Controller
[    3.780863] usb usb4: Manufacturer: Linux 2.6.38-rc6-wl-65414-ge1b6053-dirty ehci_hcd
[    3.781010] usb usb4: SerialNumber: 0000:00:06.1
[    3.782226] hub 4-0:1.0: USB hub found
[    3.782370] hub 4-0:1.0: 5 ports detected
[    3.958897] usb 1-4: New USB device found, idVendor=05ac, idProduct=8507
[    3.959008] usb 1-4: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[    3.959112] usb 1-4: Product: Built-in iSight
[    3.959210] usb 1-4: Manufacturer: Apple Inc.
[    3.959309] usb 1-4: SerialNumber: 8J8B41B6T40U3A00
[    4.061901] PM: Starting manual resume from disk
[    4.062021] PM: Hibernation image partition 8:4 present
[    4.062121] PM: Looking for hibernation image.
[    4.062764] PM: Image not found (code -22)
[    4.062863] PM: Hibernation image not present or could not be loaded.
[    4.075200] EXT3-fs: barriers not enabled
[    4.075926] kjournald starting.  Commit interval 5 seconds
[    4.076359] EXT3-fs (sda3): mounted filesystem with ordered data mode
[    4.500224] usb 2-5: new low speed USB device using ohci_hcd and address 2
[    4.599567] udev[994]: starting version 166
[    4.729231] usb 2-5: New USB device found, idVendor=05ac, idProduct=8242
[    4.729387] usb 2-5: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    4.729488] usb 2-5: Product: IR Receiver
[    4.729586] usb 2-5: Manufacturer: Apple Computer, Inc.
[    5.070548] usb 2-6: new full speed USB device using ohci_hcd and address 3
[    5.187430] b43-pci-bridge 0000:03:00.0: power state changed by ACPI to D0
[    5.187557] b43-pci-bridge 0000:03:00.0: power state changed by ACPI to D0
[    5.187682] b43-pci-bridge 0000:03:00.0: PCI INT A -> Link[Z00F] -> GSI 23 (level, low) -> IRQ 23
[    5.187847] b43-pci-bridge 0000:03:00.0: setting latency timer to 64
[    5.200512] mbp_nvidia_bl: MacBook 5,1 detected
[    5.230605] ssb: Core 0 found: ChipCommon (cc 0x800, rev 0x17, vendor 0x4243)
[    5.230725] ssb: Core 1 found: IEEE 802.11 (cc 0x812, rev 0x10, vendor 0x4243)
[    5.230878] ssb: Core 2 found: PCI-E (cc 0x820, rev 0x0B, vendor 0x4243)
[    5.230989] ssb: Core 3 found: PCI (cc 0x804, rev 0x0E, vendor 0x4243)
[    5.231101] ssb: Core 4 found: USB 2.0 Device (cc 0x81A, rev 0x05, vendor 0x4243)
[    5.231258] ssb: Core 5 found: UNKNOWN (cc 0x8FF, rev 0x00, vendor 0x4243)
[    5.231369] ssb: Core 6 found: Internal Memory (cc 0x80E, rev 0x03, vendor 0x4243)
[    5.272808] ssb: chipcommon status is 0x68040
[    5.272917] ssb: Found rev 2 PMU (capabilities 0x04583002)
[    5.273022] ssb: SPROM offset is 0x1000
[    5.311929] usb 2-6: New USB device found, idVendor=05ac, idProduct=0237
[    5.312083] usb 2-6: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    5.312188] usb 2-6: Product: Apple Internal Keyboard / Trackpad
[    5.312289] usb 2-6: Manufacturer: Apple, Inc.
[    5.321878] ssb: SPROM revision 8 detected.
[    5.365077] ssb: Sonics Silicon Backplane found on PCI device 0000:03:00.0
[    5.643720] Linux video capture interface: v2.00
[    5.661151] usbcore: registered new interface driver usbhid
[    5.661261] usbhid: USB HID core driver
[    5.752277] cfg80211: Calling CRDA to update world regulatory domain
[    5.760715] uvcvideo: Found UVC 1.00 device Built-in iSight (05ac:8507)
[    5.791570] input: Built-in iSight as /devices/pci0000:00/0000:00:04.1/usb1/1-4/1-4:1.0/input/input4
[    5.792498] usbcore: registered new interface driver uvcvideo
[    5.793088] USB Video Class driver (v1.0.0)
[    5.946969] apple 0003:05AC:8242.0001: hiddev0,hidraw0: USB HID v1.11 Device [Apple Computer, Inc. IR Receiver] on usb-0000:00:04.0-5/input0
[    5.970090] usb 4-2: new high speed USB device using ehci_hcd and address 3
[    6.010618] input: Apple, Inc. Apple Internal Keyboard / Trackpad as /devices/pci0000:00/0000:00:04.0/usb2/2-6/2-6:1.0/input/input5
[    6.016084] apple 0003:05AC:0237.0002: input,hidraw1: USB HID v1.11 Keyboard [Apple, Inc. Apple Internal Keyboard / Trackpad] on usb-0000:00:04.0-6/input0
[    6.025167] apple 0003:05AC:0237.0003: hidraw2: USB HID v1.11 Device [Apple, Inc. Apple Internal Keyboard / Trackpad] on usb-0000:00:04.0-6/input1
[    6.068840] input: bcm5974 as /devices/pci0000:00/0000:00:04.0/usb2/2-6/2-6:1.2/input/input6
[    6.075049] usbcore: registered new interface driver bcm5974
[    6.087676] ACPI: PCI Interrupt Link [LAZA] enabled at IRQ 16
[    6.087807] HDA Intel 0000:00:08.0: PCI INT A -> Link[LAZA] -> GSI 16 (level, low) -> IRQ 16
[    6.087960] hda_intel: Disable MSI for Nvidia chipset
[    6.088282] HDA Intel 0000:00:08.0: setting latency timer to 64
[    6.124461] usb 4-2: New USB device found, idVendor=05e3, idProduct=0608
[    6.124572] usb 4-2: New USB device strings: Mfr=0, Product=1, SerialNumber=0
[    6.124676] usb 4-2: Product: USB2.0 Hub
[    6.129454] hub 4-2:1.0: USB hub found
[    6.129949] hub 4-2:1.0: 4 ports detected
[    6.144545] applesmc: : read arg fail
[    6.197766] b43-phy0: Broadcom 4322 WLAN found (core revision 16)
[    6.248043] applesmc: key=271 fan=1 temp=14 acc=1 lux=2 kbd=1
[    6.248145] applesmc: init_smcreg() took 50 ms
[    6.290291] b43-phy0 debug: Found PHY: Analog 8, Type 4, Revision 4
[    6.290416] b43-phy0 debug: Found Radio: Manuf 0x17F, Version 0x2056, Revision 3
[    6.291397] input: applesmc as /devices/platform/applesmc.768/input/input7
[    6.295031] Registered led device: smc::kbd_backlight
[    6.351630] cfg80211: Updating information on frequency 2412 MHz for a 20 MHz width channel with regulatory rule:
[    6.351789] cfg80211: 2402000 KHz - 2472000 KHz @  KHz), (600 mBi, 2000 mBm)
[    6.351892] cfg80211: Updating information on frequency 2417 MHz for a 20 MHz width channel with regulatory rule:
[    6.352043] cfg80211: 2402000 KHz - 2472000 KHz @  KHz), (600 mBi, 2000 mBm)
[    6.352146] cfg80211: Updating information on frequency 2422 MHz for a 20 MHz width channel with regulatory rule:
[    6.352294] cfg80211: 2402000 KHz - 2472000 KHz @  KHz), (600 mBi, 2000 mBm)
[    6.352396] cfg80211: Updating information on frequency 2427 MHz for a 20 MHz width channel with regulatory rule:
[    6.352548] cfg80211: 2402000 KHz - 2472000 KHz @  KHz), (600 mBi, 2000 mBm)
[    6.352650] cfg80211: Updating information on frequency 2432 MHz for a 20 MHz width channel with regulatory rule:
[    6.352797] cfg80211: 2402000 KHz - 2472000 KHz @  KHz), (600 mBi, 2000 mBm)
[    6.352900] cfg80211: Updating information on frequency 2437 MHz for a 20 MHz width channel with regulatory rule:
[    6.353051] cfg80211: 2402000 KHz - 2472000 KHz @  KHz), (600 mBi, 2000 mBm)
[    6.353154] cfg80211: Updating information on frequency 2442 MHz for a 20 MHz width channel with regulatory rule:
[    6.353304] cfg80211: 2402000 KHz - 2472000 KHz @  KHz), (600 mBi, 2000 mBm)
[    6.353402] cfg80211: Updating information on frequency 2447 MHz for a 20 MHz width channel with regulatory rule:
[    6.353553] cfg80211: 2402000 KHz - 2472000 KHz @  KHz), (600 mBi, 2000 mBm)
[    6.353655] cfg80211: Updating information on frequency 2452 MHz for a 20 MHz width channel with regulatory rule:
[    6.353806] cfg80211: 2402000 KHz - 2472000 KHz @  KHz), (600 mBi, 2000 mBm)
[    6.353909] cfg80211: Updating information on frequency 2457 MHz for a 20 MHz width channel with regulatory rule:
[    6.354055] cfg80211: 2402000 KHz - 2472000 KHz @  KHz), (600 mBi, 2000 mBm)
[    6.354158] cfg80211: Updating information on frequency 2462 MHz for a 20 MHz width channel with regulatory rule:
[    6.354309] cfg80211: 2402000 KHz - 2472000 KHz @  KHz), (600 mBi, 2000 mBm)
[    6.354411] cfg80211: Updating information on frequency 2467 MHz for a 20 MHz width channel with regulatory rule:
[    6.354562] cfg80211: 2457000 KHz - 2482000 KHz @  KHz), (600 mBi, 2000 mBm)
[    6.354662] cfg80211: Updating information on frequency 2472 MHz for a 20 MHz width channel with regulatory rule:
[    6.354813] cfg80211: 2457000 KHz - 2482000 KHz @  KHz), (600 mBi, 2000 mBm)
[    6.354916] cfg80211: Updating information on frequency 2484 MHz for a 20 MHz width channel with regulatory rule:
[    6.355067] cfg80211: 2474000 KHz - 2494000 KHz @  KHz), (600 mBi, 2000 mBm)
[    6.377733] ieee80211 phy0: Selected rate control algorithm 'minstrel_ht'
[    6.384083] Registered led device: b43-phy0::tx
[    6.384385] Registered led device: b43-phy0::rx
[    6.384683] Registered led device: b43-phy0::radio
[    6.384887] Broadcom 43xx driver loaded [ Features: PNL, Firmware-ID: FW13 ]
[    6.470665] usb 3-1: new full speed USB device using ohci_hcd and address 2
[    6.706321] usb 3-1: New USB device found, idVendor=0a5c, idProduct=4500
[    6.706432] usb 3-1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    6.706536] usb 3-1: Product: BRCM2046 Hub
[    6.706630] usb 3-1: Manufacturer: Apple Inc.
[    6.709590] hub 3-1:1.0: USB hub found
[    6.712284] hub 3-1:1.0: 3 ports detected
[    6.801117] usb 4-2.1: new high speed USB device using ehci_hcd and address 4
[    6.911592] usb 4-2.1: New USB device found, idVendor=0424, idProduct=2514
[    6.911702] usb 4-2.1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[    6.915768] hub 4-2.1:1.0: USB hub found
[    6.916138] hub 4-2.1:1.0: 4 ports detected
[    7.001216] usb 4-2.2: new low speed USB device using ehci_hcd and address 5
[    7.116465] usb 4-2.2: New USB device found, idVendor=05ac, idProduct=0304
[    7.116576] usb 4-2.2: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    7.116723] usb 4-2.2: Product: Apple Optical USB Mouse
[    7.116823] usb 4-2.2: Manufacturer: Mitsumi Electric
[    7.121981] input: Mitsumi Electric Apple Optical USB Mouse as /devices/pci0000:00/0000:00:06.1/usb4/4-2/4-2.2/4-2.2:1.0/input/input8
[    7.123279] apple 0003:05AC:0304.0004: input,hidraw3: USB HID v1.10 Mouse [Mitsumi Electric Apple Optical USB Mouse] on usb-0000:00:06.1-2.2/input0
[    7.201218] usb 4-2.3: new full speed USB device using ehci_hcd and address 6
[    7.317221] usb 4-2.3: New USB device found, idVendor=046d, idProduct=c318
[    7.317331] usb 4-2.3: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    7.317476] usb 4-2.3: Product: Logitech Illuminated Keyboard
[    7.317577] usb 4-2.3: Manufacturer: Logitech
[    7.350587] input: Logitech Logitech Illuminated Keyboard as /devices/pci0000:00/0000:00:06.1/usb4/4-2/4-2.3/4-2.3:1.0/input/input9
[    7.351625] generic-usb 0003:046D:C318.0005: input,hidraw4: USB HID v1.11 Keyboard [Logitech Logitech Illuminated Keyboard] on usb-0000:00:06.1-2.3/input0
[    7.355513] input: Logitech Logitech Illuminated Keyboard as /devices/pci0000:00/0000:00:06.1/usb4/4-2/4-2.3/4-2.3:1.1/input/input10
[    7.356674] generic-usb 0003:046D:C318.0006: input,hiddev0,hidraw5: USB HID v1.11 Device [Logitech Logitech Illuminated Keyboard] on usb-0000:00:06.1-2.3/input1
[    7.443230] usb 3-1.1: new full speed USB device using ohci_hcd and address 3
[    7.579322] usb 3-1.1: New USB device found, idVendor=05ac, idProduct=8213
[    7.579433] usb 3-1.1: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[    7.579582] usb 3-1.1: Product: Bluetooth USB Host Controller
[    7.579683] usb 3-1.1: Manufacturer: Apple Inc.
[    7.579777] usb 3-1.1: SerialNumber: 00236CABC2EA
[    7.655112] hda_codec: ALC889A: SKU not ready 0x400000f0
[    7.679814] Bluetooth: Core ver 2.16
[    7.680087] NET: Registered protocol family 31
[    7.680188] Bluetooth: HCI device and connection manager initialized
[    7.680400] Bluetooth: HCI socket layer initialized
[    7.680500] Bluetooth: L2CAP socket layer initialized
[    7.681044] Bluetooth: L2CAP socket layer initialized
[    7.681167] Bluetooth: SCO socket layer initialized
[    7.688316] Bluetooth: Generic Bluetooth USB driver ver 0.6
[    7.691629] usbcore: registered new interface driver btusb
[    8.825701] Adding 1534200k swap on /dev/sda4.  Priority:-1 extents:1 across:1534200k SS
[    8.934749] EXT3-fs (sda3): using internal journal
[    9.201595] loop: module loaded
[   11.663045] RPC: Registered udp transport module.
[   11.663195] RPC: Registered tcp transport module.
[   11.663296] RPC: Registered tcp NFSv4.1 backchannel transport module.
[   12.608696] fuse init (API version 7.16)
[   13.973450] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
[   13.973558] Bluetooth: BNEP filters: protocol multicast
[   14.020080] Bluetooth: RFCOMM TTY layer initialized
[   14.020213] Bluetooth: RFCOMM socket layer initialized
[   14.020316] Bluetooth: RFCOMM ver 1.11
[   14.532401] [drm] Initialized drm 1.1.0 20060810
[   14.696224] ACPI: PCI Interrupt Link [LGPU] enabled at IRQ 23
[   14.696237] nouveau 0000:02:00.0: PCI INT A -> Link[LGPU] -> GSI 23 (level, low) -> IRQ 23
[   14.696250] nouveau 0000:02:00.0: setting latency timer to 64
[   14.748825] [drm] nouveau 0000:02:00.0: Detected an NV50 generation card (0x0ac180b1)
[   14.838133] [drm] nouveau 0000:02:00.0: Attempting to load BIOS image from PRAMIN
[   15.100660] [drm] nouveau 0000:02:00.0: ... appears to be valid
[   15.100669] [drm] nouveau 0000:02:00.0: BIT BIOS found
[   15.100673] [drm] nouveau 0000:02:00.0: Bios version 62.79.40.00
[   15.100679] [drm] nouveau 0000:02:00.0: TMDS table version 2.0
[   15.100683] [drm] nouveau 0000:02:00.0: Found Display Configuration Block version 4.0
[   15.100687] [drm] nouveau 0000:02:00.0: Raw DCB entry 0: 01000123 00010014
[   15.100692] [drm] nouveau 0000:02:00.0: Raw DCB entry 1: 02021232 00000010
[   15.100696] [drm] nouveau 0000:02:00.0: Raw DCB entry 2: 02021286 0f220010
[   15.100699] [drm] nouveau 0000:02:00.0: Raw DCB entry 3: 0000000e 00000000
[   15.100704] [drm] nouveau 0000:02:00.0: DCB connector table: VHER 0x40 5 16 4
[   15.100709] [drm] nouveau 0000:02:00.0:   0: 0x00000040: type 0x40 idx 0 tag 0xff
[   15.100713] [drm] nouveau 0000:02:00.0:   1: 0x0000a146: type 0x46 idx 1 tag 0x08
[   15.100719] [drm] nouveau 0000:02:00.0: Parsing VBIOS init table 0 at offset 0xD814
[   15.220746] [drm] nouveau 0000:02:00.0: Register 0x00004028 not found in PLL limits table
[   15.240173] [drm] nouveau 0000:02:00.0: Parsing VBIOS init table 1 at offset 0xDAC8
[   15.240181] [drm] nouveau 0000:02:00.0: Parsing VBIOS init table 2 at offset 0xDACA
[   15.240191] [drm] nouveau 0000:02:00.0: Parsing VBIOS init table 3 at offset 0xDBAF
[   15.240203] [drm] nouveau 0000:02:00.0: Parsing VBIOS init table 4 at offset 0xDC74
[   15.240207] [drm] nouveau 0000:02:00.0: Parsing VBIOS init table at offset 0xDCD9
[   15.270060] [drm] nouveau 0000:02:00.0: 0xDCD9: Condition still not met after 20ms, skipping following opcodes
[   15.323537] [drm] nouveau 0000:02:00.0: 4 available performance level(s)
[   15.323546] [drm] nouveau 0000:02:00.0: 0: memory 0MHz core 100MHz shader 200MHz voltage 900mV fanspeed 100%
[   15.323552] [drm] nouveau 0000:02:00.0: 1: memory 0MHz core 150MHz shader 300MHz voltage 900mV fanspeed 100%
[   15.323558] [drm] nouveau 0000:02:00.0: 2: memory 0MHz core 350MHz shader 800MHz voltage 900mV fanspeed 100%
[   15.323564] [drm] nouveau 0000:02:00.0: 3: memory 0MHz core 450MHz shader 1100MHz voltage 1010mV fanspeed 100%
[   15.323571] [drm] nouveau 0000:02:00.0: Register 0x00004028 not found in PLL limits table
[   15.323576] [drm] nouveau 0000:02:00.0: Register 0x00004008 not found in PLL limits table
[   15.323583] [drm] nouveau 0000:02:00.0: Register 0x00004030 not found in PLL limits table
[   15.323588] [drm] nouveau 0000:02:00.0: c: memory 0MHz shader 800MHz
[   15.344220] [TTM] Zone  kernel: Available graphics memory: 870368 kiB.
[   15.344227] [TTM] Initializing pool allocator.
[   15.344577] [drm] nouveau 0000:02:00.0: Detected 256MiB VRAM
[   15.344581] [drm] nouveau 0000:02:00.0: Stolen system memory at: 0x0040000000
[   15.379662] forcedeth 0000:00:0a.0: irq 41 for MSI/MSI-X
[   15.418308] [drm] nouveau 0000:02:00.0: 512 MiB GART (aperture)
[   15.497628] [drm] Supports vblank timestamp caching Rev 1 (10.10.2010).
[   15.497636] [drm] No driver support for vblank timestamp query.
[   15.670212] NET: Registered protocol family 17
[   15.964718] [drm] nouveau 0000:02:00.0: allocated 1920x1080 fb: 0x60000000, bo ffff88007be0de30
[   15.975974] Console: switching to colour frame buffer device 160x50
[   15.976108] fb0: nouveaufb frame buffer device
[   15.976112] drm: registered panic notifier
[   15.976185] [drm] Initialized nouveau 0.0.16 20090420 for 0000:02:00.0 on minor 0
[   16.185312] Ebtables v2.0 registered
[   16.330621] ip_tables: (C) 2000-2006 Netfilter Core Team
[   26.330018] eth0: no IPv6 routers present
[   34.028186] EXT3-fs: barriers not enabled
[   34.028639] kjournald starting.  Commit interval 5 seconds
[   34.028708] EXT3-fs (dm-0): warning: maximal mount count reached, running e2fsck is recommended
[   34.029226] EXT3-fs (dm-0): using internal journal
[   34.029246] EXT3-fs (dm-0): mounted filesystem with ordered data mode
[   40.045993] Bluetooth: HIDP (Human Interface Emulation) ver 1.2

--=-oRNTX2gd2OOS+/2drPH3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
