Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7545F6B0038
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 23:55:38 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id f26so606608iob.13
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 20:55:38 -0800 (PST)
Received: from wolff.to (wolff.to. [98.103.208.27])
        by mx.google.com with SMTP id m87si3394946ioi.304.2017.12.21.20.55.36
        for <linux-mm@kvack.org>;
        Thu, 21 Dec 2017 20:55:37 -0800 (PST)
Date: Thu, 21 Dec 2017 22:53:18 -0600
From: Bruno Wolff III <bruno@wolff.to>
Subject: Re: Regression with a0747a859ef6 ("bdi: add error handle for
 bdi_debug_register")
Message-ID: <20171222045318.GA4505@wolff.to>
References: <20171221130057.GA26743@wolff.to>
 <CAA70yB6Z=r+zO7E+ZP74jXNk_XM2CggYthAD=TKOdBVsHLLV-w@mail.gmail.com>
 <20171221151843.GA453@wolff.to>
 <CAA70yB496Nuy2FM5idxLZthBwOVbhtsZ4VtXNJ_9mj2cvNC4kA@mail.gmail.com>
 <20171221153631.GA2300@wolff.to>
 <CAA70yB6nD7CiDZUpVPy7cGhi7ooQ5SPkrcXPDKqSYD2ezLrGHA@mail.gmail.com>
 <20171221164221.GA23680@wolff.to>
 <14f04d43-728a-953f-e07c-e7f9d5e3392d@kernel.dk>
 <20171221181531.GA21050@wolff.to>
 <20171221231603.GA15702@wolff.to>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="BOKacYhQ+x31HxR3"
Content-Disposition: inline
In-Reply-To: <20171221231603.GA15702@wolff.to>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: weiping zhang <zwp10758@gmail.com>, Laura Abbott <labbott@redhat.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, regressions@leemhuis.info, weiping zhang <zhangweiping@didichuxing.com>, linux-block@vger.kernel.org


--BOKacYhQ+x31HxR3
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline

On Thu, Dec 21, 2017 at 17:16:03 -0600,
  Bruno Wolff III <bruno@wolff.to> wrote:
>
>Enforcing mode alone isn't enough as I tested that one one machine at 
>home and it didn't trigger the problem. I'll try another machine late 
>tonight.

I got the problem to occur on my i686 machine when booting in enforcing 
mode. This machine uses raid 1 vua mdraid which may or may not be a 
factor in this problem. The boot log has a trace at the end and might be 
helpful, so I'm attaching it here.

--BOKacYhQ+x31HxR3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="boot-i686.log"

-- Logs begin at Sun 2017-09-24 07:43:45 CDT, end at Thu 2017-12-21 22:46:47 CST. --
Dec 21 21:36:32 wolff.to kernel: Linux version 4.15.0-0.rc4.git1.2.fc28.i686 (mockbuild@buildvm-15.phx2.fedoraproject.org) (gcc version 7.2.1 20170915 (Red Hat 7.2.1-4) (GCC)) #1 SMP Tue Dec 19 17:26:41 UTC 2017
Dec 21 21:36:32 wolff.to kernel: x86/fpu: x87 FPU will use FXSAVE
Dec 21 21:36:32 wolff.to kernel: e820: BIOS-provided physical RAM map:
Dec 21 21:36:32 wolff.to kernel: BIOS-e820: [mem 0x0000000000000000-0x000000000009cbff] usable
Dec 21 21:36:32 wolff.to kernel: BIOS-e820: [mem 0x000000000009cc00-0x000000000009ffff] reserved
Dec 21 21:36:32 wolff.to kernel: BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] reserved
Dec 21 21:36:32 wolff.to kernel: BIOS-e820: [mem 0x0000000000100000-0x00000000bfeeffff] usable
Dec 21 21:36:32 wolff.to kernel: BIOS-e820: [mem 0x00000000bfef0000-0x00000000bfefbfff] ACPI data
Dec 21 21:36:32 wolff.to kernel: BIOS-e820: [mem 0x00000000bfefc000-0x00000000bfefffff] ACPI NVS
Dec 21 21:36:32 wolff.to kernel: BIOS-e820: [mem 0x00000000bff00000-0x00000000bff7ffff] usable
Dec 21 21:36:32 wolff.to kernel: BIOS-e820: [mem 0x00000000bff80000-0x00000000bfffffff] reserved
Dec 21 21:36:32 wolff.to kernel: BIOS-e820: [mem 0x00000000fec00000-0x00000000fec0ffff] reserved
Dec 21 21:36:32 wolff.to kernel: BIOS-e820: [mem 0x00000000fee00000-0x00000000fee00fff] reserved
Dec 21 21:36:32 wolff.to kernel: BIOS-e820: [mem 0x00000000ff800000-0x00000000ffbfffff] reserved
Dec 21 21:36:32 wolff.to kernel: BIOS-e820: [mem 0x00000000fff00000-0x00000000ffffffff] reserved
Dec 21 21:36:32 wolff.to kernel: Notice: NX (Execute Disable) protection missing in CPU!
Dec 21 21:36:32 wolff.to kernel: random: fast init done
Dec 21 21:36:32 wolff.to kernel: SMBIOS 2.32 present.
Dec 21 21:36:32 wolff.to kernel: DMI: Hewlett-Packard hp workstation xw8000/0844, BIOS JQ.W1.19US      04/13/05
Dec 21 21:36:32 wolff.to kernel: e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
Dec 21 21:36:32 wolff.to kernel: e820: remove [mem 0x000a0000-0x000fffff] usable
Dec 21 21:36:32 wolff.to kernel: e820: last_pfn = 0xbff80 max_arch_pfn = 0x100000
Dec 21 21:36:32 wolff.to kernel: MTRR default type: uncachable
Dec 21 21:36:32 wolff.to kernel: MTRR fixed ranges enabled:
Dec 21 21:36:32 wolff.to kernel:   00000-9FFFF write-back
Dec 21 21:36:32 wolff.to kernel:   A0000-BFFFF uncachable
Dec 21 21:36:32 wolff.to kernel:   C0000-FFFFF write-protect
Dec 21 21:36:32 wolff.to kernel: MTRR variable ranges enabled:
Dec 21 21:36:32 wolff.to kernel:   0 base 000000000 mask F80000000 write-back
Dec 21 21:36:32 wolff.to kernel:   1 base 080000000 mask FC0000000 write-back
Dec 21 21:36:32 wolff.to kernel:   2 disabled
Dec 21 21:36:32 wolff.to kernel:   3 disabled
Dec 21 21:36:32 wolff.to kernel:   4 disabled
Dec 21 21:36:32 wolff.to kernel:   5 disabled
Dec 21 21:36:32 wolff.to kernel:   6 disabled
Dec 21 21:36:32 wolff.to kernel:   7 disabled
Dec 21 21:36:32 wolff.to kernel: x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WC  UC- UC  
Dec 21 21:36:32 wolff.to kernel: found SMP MP-table at [mem 0x000f63a0-0x000f63af] mapped at [(ptrval)]
Dec 21 21:36:32 wolff.to kernel: initial memory mapped: [mem 0x00000000-0x0a7fffff]
Dec 21 21:36:32 wolff.to kernel: Base memory trampoline at [(ptrval)] 98000 size 16384
Dec 21 21:36:32 wolff.to kernel: BRK [0x0a53f000, 0x0a53ffff] PGTABLE
Dec 21 21:36:32 wolff.to kernel: BRK [0x0a540000, 0x0a541fff] PGTABLE
Dec 21 21:36:32 wolff.to kernel: BRK [0x0a542000, 0x0a542fff] PGTABLE
Dec 21 21:36:32 wolff.to kernel: RAMDISK: [mem 0x36732000-0x37feffff]
Dec 21 21:36:32 wolff.to kernel: Allocated new RAMDISK: [mem 0x34e74000-0x367318b1]
Dec 21 21:36:32 wolff.to kernel: Move RAMDISK from [mem 0x36732000-0x37fef8b1] to [mem 0x34e74000-0x367318b1]
Dec 21 21:36:32 wolff.to kernel: ACPI: Early table checksum verification disabled
Dec 21 21:36:32 wolff.to kernel: ACPI: RSDP 0x00000000000F6370 000014 (v00 PTLTD )
Dec 21 21:36:32 wolff.to kernel: ACPI: RSDT 0x00000000BFEF8D1D 000034 (v01 PTLTD    RSDT   06040000  LTP 00000000)
Dec 21 21:36:32 wolff.to kernel: ACPI: FACP 0x00000000BFEFBDB5 000074 (v01 INTEL  PLACER   06040000 PTL  00000008)
Dec 21 21:36:32 wolff.to kernel: ACPI: DSDT 0x00000000BFEF8D51 003064 (v01 hp     silvertn 06040000 MSFT 0100000E)
Dec 21 21:36:32 wolff.to kernel: ACPI: FACS 0x00000000BFEFCFC0 000040
Dec 21 21:36:32 wolff.to kernel: ACPI: _HP_ 0x00000000BFEFBE29 000113 (v01 HPINVT HPINVENT 06040000 ?    5F50485F)
Dec 21 21:36:32 wolff.to kernel: ACPI: APIC 0x00000000BFEFBF3C 00009C (v01 PTLTD  ? APIC   06040000  LTP 00000000)
Dec 21 21:36:32 wolff.to kernel: ACPI: BOOT 0x00000000BFEFBFD8 000028 (v01 PTLTD  $SBFTBL$ 06040000  LTP 00000001)
Dec 21 21:36:32 wolff.to kernel: ACPI: Local APIC address 0xfee00000
Dec 21 21:36:32 wolff.to kernel: 2187MB HIGHMEM available.
Dec 21 21:36:32 wolff.to kernel: 883MB LOWMEM available.
Dec 21 21:36:32 wolff.to kernel:   mapped low ram: 0 - 373fe000
Dec 21 21:36:32 wolff.to kernel:   low ram: 0 - 373fe000
Dec 21 21:36:32 wolff.to kernel: tsc: Fast TSC calibration using PIT
Dec 21 21:36:32 wolff.to kernel: Zone ranges:
Dec 21 21:36:32 wolff.to kernel:   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
Dec 21 21:36:32 wolff.to kernel:   Normal   [mem 0x0000000001000000-0x00000000373fdfff]
Dec 21 21:36:32 wolff.to kernel:   HighMem  [mem 0x00000000373fe000-0x00000000bff7ffff]
Dec 21 21:36:32 wolff.to kernel: Movable zone start for each node
Dec 21 21:36:32 wolff.to kernel: Early memory node ranges
Dec 21 21:36:32 wolff.to kernel:   node   0: [mem 0x0000000000001000-0x000000000009bfff]
Dec 21 21:36:32 wolff.to kernel:   node   0: [mem 0x0000000000100000-0x00000000bfeeffff]
Dec 21 21:36:32 wolff.to kernel:   node   0: [mem 0x00000000bff00000-0x00000000bff7ffff]
Dec 21 21:36:32 wolff.to kernel: Initmem setup node 0 [mem 0x0000000000001000-0x00000000bff7ffff]
Dec 21 21:36:32 wolff.to kernel: On node 0 totalpages: 786187
Dec 21 21:36:32 wolff.to kernel:   DMA zone: 40 pages used for memmap
Dec 21 21:36:32 wolff.to kernel:   DMA zone: 0 pages reserved
Dec 21 21:36:32 wolff.to kernel:   DMA zone: 3995 pages, LIFO batch:0
Dec 21 21:36:32 wolff.to kernel:   Normal zone: 2170 pages used for memmap
Dec 21 21:36:32 wolff.to kernel:   Normal zone: 222206 pages, LIFO batch:31
Dec 21 21:36:32 wolff.to kernel:   HighMem zone: 559986 pages, LIFO batch:31
Dec 21 21:36:32 wolff.to kernel: Reserved but unavailable: 101 pages
Dec 21 21:36:32 wolff.to kernel: Using APIC driver default
Dec 21 21:36:32 wolff.to kernel: ACPI: PM-Timer IO Port: 0x1008
Dec 21 21:36:32 wolff.to kernel: ACPI: Local APIC address 0xfee00000
Dec 21 21:36:32 wolff.to kernel: ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
Dec 21 21:36:32 wolff.to kernel: ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
Dec 21 21:36:32 wolff.to kernel: ACPI: LAPIC_NMI (acpi_id[0x02] high edge lint[0x1])
Dec 21 21:36:32 wolff.to kernel: ACPI: LAPIC_NMI (acpi_id[0x03] high edge lint[0x1])
Dec 21 21:36:32 wolff.to kernel: IOAPIC[0]: apic_id 2, version 32, address 0xfec00000, GSI 0-23
Dec 21 21:36:32 wolff.to kernel: IOAPIC[1]: apic_id 3, version 32, address 0xfec80000, GSI 24-47
Dec 21 21:36:32 wolff.to kernel: IOAPIC[2]: apic_id 4, version 32, address 0xfec80400, GSI 48-71
Dec 21 21:36:32 wolff.to kernel: ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 high edge)
Dec 21 21:36:32 wolff.to kernel: ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
Dec 21 21:36:32 wolff.to kernel: ACPI: IRQ0 used by override.
Dec 21 21:36:32 wolff.to kernel: ACPI: IRQ9 used by override.
Dec 21 21:36:32 wolff.to kernel: Using ACPI (MADT) for SMP configuration information
Dec 21 21:36:32 wolff.to kernel: smpboot: Allowing 4 CPUs, 0 hotplug CPUs
Dec 21 21:36:32 wolff.to kernel: PM: Registered nosave memory: [mem 0x00000000-0x00000fff]
Dec 21 21:36:32 wolff.to kernel: PM: Registered nosave memory: [mem 0x0009c000-0x0009cfff]
Dec 21 21:36:32 wolff.to kernel: PM: Registered nosave memory: [mem 0x0009d000-0x0009ffff]
Dec 21 21:36:32 wolff.to kernel: PM: Registered nosave memory: [mem 0x000a0000-0x000dffff]
Dec 21 21:36:32 wolff.to kernel: PM: Registered nosave memory: [mem 0x000e0000-0x000fffff]
Dec 21 21:36:32 wolff.to kernel: e820: [mem 0xc0000000-0xfebfffff] available for PCI devices
Dec 21 21:36:32 wolff.to kernel: Booting paravirtualized kernel on bare hardware
Dec 21 21:36:32 wolff.to kernel: clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 1910969940391419 ns
Dec 21 21:36:32 wolff.to kernel: setup_percpu: NR_CPUS:32 nr_cpumask_bits:4 nr_cpu_ids:4 nr_node_ids:1
Dec 21 21:36:32 wolff.to kernel: percpu: Embedded 24 pages/cpu @(ptrval) s65676 r0 d32628 u98304
Dec 21 21:36:32 wolff.to kernel: pcpu-alloc: s65676 r0 d32628 u98304 alloc=24*4096
Dec 21 21:36:32 wolff.to kernel: pcpu-alloc: [0] 0 [0] 1 [0] 2 [0] 3 
Dec 21 21:36:32 wolff.to kernel: Built 1 zonelists, mobility grouping on.  Total pages: 783977
Dec 21 21:36:32 wolff.to kernel: Kernel command line: ro root=/dev/mapper/luks-6298c7e5-aadf-44d5-be91-28734671492a SYSFONT=latarcyrheb-sun16 LANG=en_US.UTF-8 KEYTABLE=us slub_debug=- nomodeset vga=795
Dec 21 21:36:32 wolff.to kernel: Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
Dec 21 21:36:32 wolff.to kernel: Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
Dec 21 21:36:32 wolff.to kernel: Initializing CPU#0
Dec 21 21:36:32 wolff.to kernel: Initializing HighMem for node 0 (000373fe:000bff80)
Dec 21 21:36:32 wolff.to kernel: Initializing Movable for node 0 (00000000:00000000)
Dec 21 21:36:32 wolff.to kernel: Memory: 3073868K/3144748K available (7826K kernel code, 766K rwdata, 3152K rodata, 884K init, 624K bss, 70880K reserved, 0K cma-reserved, 2239944K highmem)
Dec 21 21:36:32 wolff.to kernel: virtual kernel memory layout:
                                     fixmap  : 0xff9d4000 - 0xfffff000   (6316 kB)
                                     pkmap   : 0xff400000 - 0xff800000   (4096 kB)
                                     vmalloc : 0xf7bfe000 - 0xff3fe000   ( 120 MB)
                                     lowmem  : 0xc0000000 - 0xf73fe000   ( 883 MB)
                                       .init : 0xca393000 - 0xca470000   ( 884 kB)
                                       .data : 0xc9fa4b88 - 0xca37d840   (3939 kB)
                                       .text : 0xc9800000 - 0xc9fa4b88   (7826 kB)
Dec 21 21:36:32 wolff.to kernel: Checking if this processor honours the WP bit even in supervisor mode...Ok.
Dec 21 21:36:32 wolff.to kernel: SLUB: HWalign=128, Order=0-3, MinObjects=0, CPUs=4, Nodes=1
Dec 21 21:36:32 wolff.to kernel: ftrace: allocating 33584 entries in 66 pages
Dec 21 21:36:32 wolff.to kernel: Hierarchical RCU implementation.
Dec 21 21:36:32 wolff.to kernel:         RCU restricting CPUs from NR_CPUS=32 to nr_cpu_ids=4.
Dec 21 21:36:32 wolff.to kernel:         Tasks RCU enabled.
Dec 21 21:36:32 wolff.to kernel: RCU: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=4
Dec 21 21:36:32 wolff.to kernel: NR_IRQS: 2304, nr_irqs: 1024, preallocated irqs: 16
Dec 21 21:36:32 wolff.to kernel: CPU 0 irqstacks, hard=(ptrval) soft=(ptrval)
Dec 21 21:36:32 wolff.to kernel: Console: colour dummy device 80x25
Dec 21 21:36:32 wolff.to kernel: console [tty0] enabled
Dec 21 21:36:32 wolff.to kernel: ACPI: Core revision 20170831
Dec 21 21:36:32 wolff.to kernel: ACPI: 1 ACPI AML tables successfully acquired and loaded
Dec 21 21:36:32 wolff.to kernel: APIC: Switch to symmetric I/O mode setup
Dec 21 21:36:32 wolff.to kernel: Enabling APIC mode:  Flat.  Using 3 I/O APICs
Dec 21 21:36:32 wolff.to kernel: ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
Dec 21 21:36:32 wolff.to kernel: tsc: Fast TSC calibration using PIT
Dec 21 21:36:32 wolff.to kernel: tsc: Detected 2657.635 MHz processor
Dec 21 21:36:32 wolff.to kernel: Calibrating delay loop (skipped), value calculated using timer frequency.. 5315.27 BogoMIPS (lpj=2657635)
Dec 21 21:36:32 wolff.to kernel: pid_max: default: 32768 minimum: 301
Dec 21 21:36:32 wolff.to kernel: Security Framework initialized
Dec 21 21:36:32 wolff.to kernel: Yama: becoming mindful.
Dec 21 21:36:32 wolff.to kernel: SELinux:  Initializing.
Dec 21 21:36:32 wolff.to kernel: SELinux:  Starting in permissive mode
Dec 21 21:36:32 wolff.to kernel: Mount-cache hash table entries: 2048 (order: 1, 8192 bytes)
Dec 21 21:36:32 wolff.to kernel: Mountpoint-cache hash table entries: 2048 (order: 1, 8192 bytes)
Dec 21 21:36:32 wolff.to kernel: CPU: Physical Processor ID: 0
Dec 21 21:36:32 wolff.to kernel: CPU: Processor Core ID: 0
Dec 21 21:36:32 wolff.to kernel: mce: CPU supports 4 MCE banks
Dec 21 21:36:32 wolff.to kernel: CPU0: Thermal monitoring enabled (TM1)
Dec 21 21:36:32 wolff.to kernel: Last level iTLB entries: 4KB 64, 2MB 64, 4MB 64
Dec 21 21:36:32 wolff.to kernel: Last level dTLB entries: 4KB 64, 2MB 0, 4MB 64, 1GB 0
Dec 21 21:36:32 wolff.to kernel: Freeing SMP alternatives memory: 32K
Dec 21 21:36:32 wolff.to kernel: smpboot: CPU0: Intel(R) Xeon(TM) CPU 2.66GHz (family: 0xf, model: 0x2, stepping: 0x9)
Dec 21 21:36:32 wolff.to kernel: Performance Events: Netburst events, Netburst P4/Xeon PMU driver.
Dec 21 21:36:32 wolff.to kernel: ... version:                0
Dec 21 21:36:32 wolff.to kernel: ... bit width:              40
Dec 21 21:36:32 wolff.to kernel: ... generic registers:      18
Dec 21 21:36:32 wolff.to kernel: ... value mask:             000000ffffffffff
Dec 21 21:36:32 wolff.to kernel: ... max period:             0000007fffffffff
Dec 21 21:36:32 wolff.to kernel: ... fixed-purpose events:   0
Dec 21 21:36:32 wolff.to kernel: ... event mask:             000000000003ffff
Dec 21 21:36:32 wolff.to kernel: Hierarchical SRCU implementation.
Dec 21 21:36:32 wolff.to kernel: NMI watchdog: Enabled. Permanently consumes one hw-PMU counter.
Dec 21 21:36:32 wolff.to kernel: smp: Bringing up secondary CPUs ...
Dec 21 21:36:32 wolff.to kernel: CPU 1 irqstacks, hard=91786052 soft=dd4da3c7
Dec 21 21:36:32 wolff.to kernel: x86: Booting SMP configuration:
Dec 21 21:36:32 wolff.to kernel: .... node  #0, CPUs:      #1
Dec 21 21:36:32 wolff.to kernel: Initializing CPU#1
Dec 21 21:36:32 wolff.to kernel: smpboot: CPU 1 Converting physical 3 to logical package 1
Dec 21 21:36:32 wolff.to kernel: CPU 2 irqstacks, hard=0a74345e soft=03089ece
Dec 21 21:36:32 wolff.to kernel:  #2
Dec 21 21:36:32 wolff.to kernel: Initializing CPU#2
Dec 21 21:36:32 wolff.to kernel: CPU 3 irqstacks, hard=e52ed12e soft=296c5adc
Dec 21 21:36:32 wolff.to kernel:  #3
Dec 21 21:36:32 wolff.to kernel: Initializing CPU#3
Dec 21 21:36:32 wolff.to kernel: smp: Brought up 1 node, 4 CPUs
Dec 21 21:36:32 wolff.to kernel: smpboot: Max logical packages: 2
Dec 21 21:36:32 wolff.to kernel: smpboot: Total of 4 processors activated (21259.31 BogoMIPS)
Dec 21 21:36:32 wolff.to kernel: devtmpfs: initialized
Dec 21 21:36:32 wolff.to kernel: PM: Registering ACPI NVS region [mem 0xbfefc000-0xbfefffff] (16384 bytes)
Dec 21 21:36:32 wolff.to kernel: clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 1911260446275000 ns
Dec 21 21:36:32 wolff.to kernel: futex hash table entries: 1024 (order: 4, 65536 bytes)
Dec 21 21:36:32 wolff.to kernel: pinctrl core: initialized pinctrl subsystem
Dec 21 21:36:32 wolff.to kernel: RTC time:  3:36:26, date: 12/22/17
Dec 21 21:36:32 wolff.to kernel: NET: Registered protocol family 16
Dec 21 21:36:32 wolff.to kernel: audit: initializing netlink subsys (disabled)
Dec 21 21:36:32 wolff.to kernel: audit: type=2000 audit(1513913786.230:1): state=initialized audit_enabled=0 res=1
Dec 21 21:36:32 wolff.to kernel: cpuidle: using governor menu
Dec 21 21:36:32 wolff.to kernel: Simple Boot Flag at 0x36 set to 0x1
Dec 21 21:36:32 wolff.to kernel: ACPI: bus type PCI registered
Dec 21 21:36:32 wolff.to kernel: acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
Dec 21 21:36:32 wolff.to kernel: PCI: PCI BIOS revision 2.10 entry at 0xfd895, last bus=5
Dec 21 21:36:32 wolff.to kernel: PCI: Using configuration type 1 for base access
Dec 21 21:36:32 wolff.to kernel: HugeTLB registered 4.00 MiB page size, pre-allocated 0 pages
Dec 21 21:36:32 wolff.to kernel: ACPI: Added _OSI(Module Device)
Dec 21 21:36:32 wolff.to kernel: ACPI: Added _OSI(Processor Device)
Dec 21 21:36:32 wolff.to kernel: ACPI: Added _OSI(3.0 _SCP Extensions)
Dec 21 21:36:32 wolff.to kernel: ACPI: Added _OSI(Processor Aggregator Device)
Dec 21 21:36:32 wolff.to kernel: ACPI: Interpreter enabled
Dec 21 21:36:32 wolff.to kernel: ACPI: (supports S0 S1 S4 S5)
Dec 21 21:36:32 wolff.to kernel: ACPI: Using IOAPIC for interrupt routing
Dec 21 21:36:32 wolff.to kernel: PCI: Ignoring host bridge windows from ACPI; if necessary, use "pci=use_crs" and report a bug
Dec 21 21:36:32 wolff.to kernel: ACPI: Enabled 7 GPEs in block 00 to 1F
Dec 21 21:36:32 wolff.to kernel: ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
Dec 21 21:36:32 wolff.to kernel: acpi PNP0A03:00: _OSC: OS supports [ASPM ClockPM Segments MSI]
Dec 21 21:36:32 wolff.to kernel: acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
Dec 21 21:36:32 wolff.to kernel: acpi PNP0A03:00: fail to add MMCONFIG information, can't access extended PCI configuration space under this bridge.
Dec 21 21:36:32 wolff.to kernel: acpi PNP0A03:00: host bridge window [io  0x0cf8-0x0cff] (ignored)
Dec 21 21:36:32 wolff.to kernel: acpi PNP0A03:00: host bridge window [io  0x0000-0x0cf7 window] (ignored)
Dec 21 21:36:32 wolff.to kernel: acpi PNP0A03:00: host bridge window [mem 0x000a0000-0x000bffff window] (ignored)
Dec 21 21:36:32 wolff.to kernel: acpi PNP0A03:00: host bridge window [mem 0x000d4000-0x000d7fff window] (ignored)
Dec 21 21:36:32 wolff.to kernel: acpi PNP0A03:00: host bridge window [mem 0x000d8000-0x000dbfff window] (ignored)
Dec 21 21:36:32 wolff.to kernel: acpi PNP0A03:00: host bridge window [mem 0x000dc000-0x000dffff window] (ignored)
Dec 21 21:36:32 wolff.to kernel: acpi PNP0A03:00: host bridge window [mem 0xc0000000-0xfebfffff window] (ignored)
Dec 21 21:36:32 wolff.to kernel: acpi PNP0A03:00: host bridge window [io  0x0d00-0xffff window] (ignored)
Dec 21 21:36:32 wolff.to kernel: PCI: root bus 00: using default resources
Dec 21 21:36:32 wolff.to kernel: PCI host bridge to bus 0000:00
Dec 21 21:36:32 wolff.to kernel: pci_bus 0000:00: root bus resource [io  0x0000-0xffff]
Dec 21 21:36:32 wolff.to kernel: pci_bus 0000:00: root bus resource [mem 0x00000000-0xffffffff]
Dec 21 21:36:32 wolff.to kernel: pci_bus 0000:00: root bus resource [bus 00-ff]
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:00.0: [8086:2550] type 00 class 0x060000
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:00.0: reg 0x10: [mem 0xd8000000-0xdfffffff pref]
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:00.1: [8086:2551] type 00 class 0xff0000
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:01.0: [8086:2552] type 01 class 0x060400
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:01.0: reg 0x10: [mem 0xe0000000-0xe7ffffff pref]
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:02.0: [8086:2553] type 01 class 0x060400
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:1d.0: [8086:24c2] type 00 class 0x0c0300
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:1d.0: reg 0x20: [io  0x1880-0x189f]
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:1d.1: [8086:24c4] type 00 class 0x0c0300
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:1d.1: reg 0x20: [io  0x18a0-0x18bf]
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:1d.2: [8086:24c7] type 00 class 0x0c0300
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:1d.2: reg 0x20: [io  0x18c0-0x18df]
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:1d.7: [8086:24cd] type 00 class 0x0c0320
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:1d.7: reg 0x10: [mem 0xd0000c00-0xd0000fff]
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:1e.0: [8086:244e] type 01 class 0x060400
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:1f.0: [8086:24c0] type 00 class 0x060100
Dec 21 21:36:32 wolff.to kernel: * The chipset may have PM-Timer Bug. Due to workarounds for a bug,
                                 * this clock source is slow. If you are sure your timer does not have
                                 * this bug, please use "acpi_pm_good" to disable the workaround
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:1f.0: quirk: [io  0x1000-0x107f] claimed by ICH4 ACPI/GPIO/TCO
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:1f.0: quirk: [io  0x1180-0x11bf] claimed by ICH4 GPIO
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:1f.1: [8086:24cb] type 00 class 0x01018a
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:1f.1: reg 0x10: [io  0x0000-0x0007]
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:1f.1: reg 0x14: [io  0x0000-0x0003]
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:1f.1: reg 0x18: [io  0x0000-0x0007]
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:1f.1: reg 0x1c: [io  0x0000-0x0003]
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:1f.1: reg 0x20: [io  0x1800-0x180f]
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:1f.1: reg 0x24: [mem 0x00000000-0x000003ff]
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:1f.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x01f7]
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:1f.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:1f.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x0177]
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:1f.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:1f.3: [8086:24c3] type 00 class 0x0c0500
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:1f.3: reg 0x20: [io  0x1820-0x183f]
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:1f.5: [8086:24c5] type 00 class 0x040100
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:1f.5: reg 0x10: [io  0x1c00-0x1cff]
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:1f.5: reg 0x14: [io  0x1840-0x187f]
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:1f.5: reg 0x18: [mem 0xd0000800-0xd00009ff]
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:1f.5: reg 0x1c: [mem 0xd0000400-0xd00004ff]
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:1f.5: PME# supported from D0 D3hot D3cold
Dec 21 21:36:32 wolff.to kernel: pci 0000:01:00.0: [1002:5961] type 00 class 0x030000
Dec 21 21:36:32 wolff.to kernel: pci 0000:01:00.0: reg 0x10: [mem 0xe8000000-0xefffffff pref]
Dec 21 21:36:32 wolff.to kernel: pci 0000:01:00.0: reg 0x14: [io  0x2000-0x20ff]
Dec 21 21:36:32 wolff.to kernel: pci 0000:01:00.0: reg 0x18: [mem 0xd0100000-0xd010ffff]
Dec 21 21:36:32 wolff.to kernel: pci 0000:01:00.0: reg 0x30: [mem 0x00000000-0x0001ffff pref]
Dec 21 21:36:32 wolff.to kernel: pci 0000:01:00.0: supports D1 D2
Dec 21 21:36:32 wolff.to kernel: pci 0000:01:00.1: [1002:5941] type 00 class 0x038000
Dec 21 21:36:32 wolff.to kernel: pci 0000:01:00.1: reg 0x10: [mem 0xf0000000-0xf7ffffff pref]
Dec 21 21:36:32 wolff.to kernel: pci 0000:01:00.1: reg 0x14: [mem 0xd0110000-0xd011ffff]
Dec 21 21:36:32 wolff.to kernel: pci 0000:01:00.1: supports D1 D2
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:01.0: PCI bridge to [bus 01]
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:01.0:   bridge window [io  0x2000-0x2fff]
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:01.0:   bridge window [mem 0xd0100000-0xd01fffff]
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:01.0:   bridge window [mem 0xe8000000-0xf7ffffff pref]
Dec 21 21:36:32 wolff.to kernel: pci 0000:02:1c.0: [8086:1461] type 00 class 0x080020
Dec 21 21:36:32 wolff.to kernel: pci 0000:02:1c.0: reg 0x10: [mem 0xd0200000-0xd0200fff]
Dec 21 21:36:32 wolff.to kernel: pci 0000:02:1d.0: [8086:1460] type 01 class 0x060400
Dec 21 21:36:32 wolff.to kernel: pci 0000:02:1e.0: [8086:1461] type 00 class 0x080020
Dec 21 21:36:32 wolff.to kernel: pci 0000:02:1e.0: reg 0x10: [mem 0xd0201000-0xd0201fff]
Dec 21 21:36:32 wolff.to kernel: pci 0000:02:1f.0: [8086:1460] type 01 class 0x060400
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:02.0: PCI bridge to [bus 02-04]
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:02.0:   bridge window [io  0x3000-0x3fff]
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:02.0:   bridge window [mem 0xd0200000-0xd03fffff]
Dec 21 21:36:32 wolff.to kernel: pci 0000:03:05.0: [1000:0030] type 00 class 0x010000
Dec 21 21:36:32 wolff.to kernel: pci 0000:03:05.0: reg 0x10: [io  0x3000-0x30ff]
Dec 21 21:36:32 wolff.to kernel: pci 0000:03:05.0: reg 0x14: [mem 0xd0310000-0xd031ffff 64bit]
Dec 21 21:36:32 wolff.to kernel: pci 0000:03:05.0: reg 0x1c: [mem 0xd0300000-0xd030ffff 64bit]
Dec 21 21:36:32 wolff.to kernel: pci 0000:03:05.0: reg 0x30: [mem 0x00000000-0x000fffff pref]
Dec 21 21:36:32 wolff.to kernel: pci 0000:03:05.0: supports D1 D2
Dec 21 21:36:32 wolff.to kernel: pci 0000:03:05.1: [1000:0030] type 00 class 0x010000
Dec 21 21:36:32 wolff.to kernel: pci 0000:03:05.1: reg 0x10: [io  0x3400-0x34ff]
Dec 21 21:36:32 wolff.to kernel: pci 0000:03:05.1: reg 0x14: [mem 0xd0330000-0xd033ffff 64bit]
Dec 21 21:36:32 wolff.to kernel: pci 0000:03:05.1: reg 0x1c: [mem 0xd0320000-0xd032ffff 64bit]
Dec 21 21:36:32 wolff.to kernel: pci 0000:03:05.1: reg 0x30: [mem 0x00000000-0x000fffff pref]
Dec 21 21:36:32 wolff.to kernel: pci 0000:03:05.1: supports D1 D2
Dec 21 21:36:32 wolff.to kernel: pci 0000:02:1d.0: PCI bridge to [bus 03]
Dec 21 21:36:32 wolff.to kernel: pci 0000:02:1d.0:   bridge window [io  0x3000-0x3fff]
Dec 21 21:36:32 wolff.to kernel: pci 0000:02:1d.0:   bridge window [mem 0xd0300000-0xd03fffff]
Dec 21 21:36:32 wolff.to kernel: pci 0000:02:1f.0: PCI bridge to [bus 04]
Dec 21 21:36:32 wolff.to kernel: pci 0000:05:03.0: [8086:100e] type 00 class 0x020000
Dec 21 21:36:32 wolff.to kernel: pci 0000:05:03.0: reg 0x10: [mem 0xd0400000-0xd041ffff]
Dec 21 21:36:32 wolff.to kernel: pci 0000:05:03.0: reg 0x18: [io  0x4000-0x403f]
Dec 21 21:36:32 wolff.to kernel: pci 0000:05:03.0: PME# supported from D0 D3hot D3cold
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:1e.0: PCI bridge to [bus 05] (subtractive decode)
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:1e.0:   bridge window [io  0x4000-0x4fff]
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:1e.0:   bridge window [mem 0xd0400000-0xd04fffff]
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:1e.0:   bridge window [io  0x0000-0xffff] (subtractive decode)
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:1e.0:   bridge window [mem 0x00000000-0xffffffff] (subtractive decode)
Dec 21 21:36:32 wolff.to kernel: pci_bus 0000:00: on NUMA node 0
Dec 21 21:36:32 wolff.to kernel: ACPI: PCI Interrupt Link [LNKA] (IRQs 3 *10 11 14 15)
Dec 21 21:36:32 wolff.to kernel: ACPI: PCI Interrupt Link [LNKB] (IRQs 3 10 *11 14 15)
Dec 21 21:36:32 wolff.to kernel: ACPI: PCI Interrupt Link [LNKC] (IRQs *3 10 11 14 15)
Dec 21 21:36:32 wolff.to kernel: ACPI: PCI Interrupt Link [LNKD] (IRQs 3 10 11 14 15) *5
Dec 21 21:36:32 wolff.to kernel: ACPI: PCI Interrupt Link [LNKE] (IRQs 3 10 11 14 15) *0, disabled.
Dec 21 21:36:32 wolff.to kernel: ACPI: PCI Interrupt Link [LNKF] (IRQs 3 10 11 14 15) *0, disabled.
Dec 21 21:36:32 wolff.to kernel: ACPI: PCI Interrupt Link [LNKG] (IRQs 3 10 11 14 15) *0, disabled.
Dec 21 21:36:32 wolff.to kernel: ACPI: PCI Interrupt Link [LNKH] (IRQs 3 10 *11 14 15)
Dec 21 21:36:32 wolff.to kernel: pci 0000:01:00.0: vgaarb: setting as boot VGA device
Dec 21 21:36:32 wolff.to kernel: pci 0000:01:00.0: vgaarb: VGA device added: decodes=io+mem,owns=io+mem,locks=none
Dec 21 21:36:32 wolff.to kernel: pci 0000:01:00.0: vgaarb: bridge control possible
Dec 21 21:36:32 wolff.to kernel: vgaarb: loaded
Dec 21 21:36:32 wolff.to kernel: SCSI subsystem initialized
Dec 21 21:36:32 wolff.to kernel: libata version 3.00 loaded.
Dec 21 21:36:32 wolff.to kernel: ACPI: bus type USB registered
Dec 21 21:36:32 wolff.to kernel: usbcore: registered new interface driver usbfs
Dec 21 21:36:32 wolff.to kernel: usbcore: registered new interface driver hub
Dec 21 21:36:32 wolff.to kernel: usbcore: registered new device driver usb
Dec 21 21:36:32 wolff.to kernel: EDAC MC: Ver: 3.0.0
Dec 21 21:36:32 wolff.to kernel: PCI: Using ACPI for IRQ routing
Dec 21 21:36:32 wolff.to kernel: PCI: pci_cache_line_size set to 64 bytes
Dec 21 21:36:32 wolff.to kernel: e820: reserve RAM buffer [mem 0x0009cc00-0x0009ffff]
Dec 21 21:36:32 wolff.to kernel: e820: reserve RAM buffer [mem 0xbfef0000-0xbfffffff]
Dec 21 21:36:32 wolff.to kernel: e820: reserve RAM buffer [mem 0xbff80000-0xbfffffff]
Dec 21 21:36:32 wolff.to kernel: NetLabel: Initializing
Dec 21 21:36:32 wolff.to kernel: NetLabel:  domain hash size = 128
Dec 21 21:36:32 wolff.to kernel: NetLabel:  protocols = UNLABELED CIPSOv4 CALIPSO
Dec 21 21:36:32 wolff.to kernel: NetLabel:  unlabeled traffic allowed by default
Dec 21 21:36:32 wolff.to kernel: clocksource: Switched to clocksource refined-jiffies
Dec 21 21:36:32 wolff.to kernel: VFS: Disk quotas dquot_6.6.0
Dec 21 21:36:32 wolff.to kernel: VFS: Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
Dec 21 21:36:32 wolff.to kernel: pnp: PnP ACPI init
Dec 21 21:36:32 wolff.to kernel: system 00:00: [io  0x0200-0x0207] has been reserved
Dec 21 21:36:32 wolff.to kernel: system 00:00: [io  0x0330-0x0331] has been reserved
Dec 21 21:36:32 wolff.to kernel: system 00:00: [io  0x04d0-0x04d1] has been reserved
Dec 21 21:36:32 wolff.to kernel: system 00:00: [io  0x1000-0x107f] has been reserved
Dec 21 21:36:32 wolff.to kernel: system 00:00: [io  0x1180-0x11bf] has been reserved
Dec 21 21:36:32 wolff.to kernel: system 00:00: [io  0xfe00] has been reserved
Dec 21 21:36:32 wolff.to kernel: system 00:00: Plug and Play ACPI device, IDs PNP0c02 (active)
Dec 21 21:36:32 wolff.to kernel: pnp 00:01: Plug and Play ACPI device, IDs PNP0b00 (active)
Dec 21 21:36:32 wolff.to kernel: pnp 00:02: Plug and Play ACPI device, IDs PNP0303 (active)
Dec 21 21:36:32 wolff.to kernel: pnp 00:03: Plug and Play ACPI device, IDs PNP0f13 (active)
Dec 21 21:36:32 wolff.to kernel: pnp 00:04: Plug and Play ACPI device, IDs PNP0501 (active)
Dec 21 21:36:32 wolff.to kernel: pnp 00:05: [dma 2]
Dec 21 21:36:32 wolff.to kernel: pnp 00:05: Plug and Play ACPI device, IDs PNP0700 (active)
Dec 21 21:36:32 wolff.to kernel: pnp 00:06: [dma 3]
Dec 21 21:36:32 wolff.to kernel: pnp 00:06: Plug and Play ACPI device, IDs PNP0401 (active)
Dec 21 21:36:32 wolff.to kernel: pnp: PnP ACPI: found 7 devices
Dec 21 21:36:32 wolff.to kernel: clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, max_idle_ns: 2085701024 ns
Dec 21 21:36:32 wolff.to kernel: clocksource: Switched to clocksource acpi_pm
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:1f.1: BAR 5: assigned [mem 0xc0000000-0xc00003ff]
Dec 21 21:36:32 wolff.to kernel: pci 0000:01:00.0: BAR 6: assigned [mem 0xd0120000-0xd013ffff pref]
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:01.0: PCI bridge to [bus 01]
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:01.0:   bridge window [io  0x2000-0x2fff]
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:01.0:   bridge window [mem 0xd0100000-0xd01fffff]
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:01.0:   bridge window [mem 0xe8000000-0xf7ffffff pref]
Dec 21 21:36:32 wolff.to kernel: pci 0000:03:05.0: BAR 6: no space for [mem size 0x00100000 pref]
Dec 21 21:36:32 wolff.to kernel: pci 0000:03:05.0: BAR 6: failed to assign [mem size 0x00100000 pref]
Dec 21 21:36:32 wolff.to kernel: pci 0000:03:05.1: BAR 6: no space for [mem size 0x00100000 pref]
Dec 21 21:36:32 wolff.to kernel: pci 0000:03:05.1: BAR 6: failed to assign [mem size 0x00100000 pref]
Dec 21 21:36:32 wolff.to kernel: pci 0000:02:1d.0: PCI bridge to [bus 03]
Dec 21 21:36:32 wolff.to kernel: pci 0000:02:1d.0:   bridge window [io  0x3000-0x3fff]
Dec 21 21:36:32 wolff.to kernel: pci 0000:02:1d.0:   bridge window [mem 0xd0300000-0xd03fffff]
Dec 21 21:36:32 wolff.to kernel: pci 0000:02:1f.0: PCI bridge to [bus 04]
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:02.0: PCI bridge to [bus 02-04]
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:02.0:   bridge window [io  0x3000-0x3fff]
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:02.0:   bridge window [mem 0xd0200000-0xd03fffff]
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:1e.0: PCI bridge to [bus 05]
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:1e.0:   bridge window [io  0x4000-0x4fff]
Dec 21 21:36:32 wolff.to kernel: pci 0000:00:1e.0:   bridge window [mem 0xd0400000-0xd04fffff]
Dec 21 21:36:32 wolff.to kernel: pci_bus 0000:00: resource 4 [io  0x0000-0xffff]
Dec 21 21:36:32 wolff.to kernel: pci_bus 0000:00: resource 5 [mem 0x00000000-0xffffffff]
Dec 21 21:36:32 wolff.to kernel: pci_bus 0000:01: resource 0 [io  0x2000-0x2fff]
Dec 21 21:36:32 wolff.to kernel: pci_bus 0000:01: resource 1 [mem 0xd0100000-0xd01fffff]
Dec 21 21:36:32 wolff.to kernel: pci_bus 0000:01: resource 2 [mem 0xe8000000-0xf7ffffff pref]
Dec 21 21:36:32 wolff.to kernel: pci_bus 0000:02: resource 0 [io  0x3000-0x3fff]
Dec 21 21:36:32 wolff.to kernel: pci_bus 0000:02: resource 1 [mem 0xd0200000-0xd03fffff]
Dec 21 21:36:32 wolff.to kernel: pci_bus 0000:03: resource 0 [io  0x3000-0x3fff]
Dec 21 21:36:32 wolff.to kernel: pci_bus 0000:03: resource 1 [mem 0xd0300000-0xd03fffff]
Dec 21 21:36:32 wolff.to kernel: pci_bus 0000:05: resource 0 [io  0x4000-0x4fff]
Dec 21 21:36:32 wolff.to kernel: pci_bus 0000:05: resource 1 [mem 0xd0400000-0xd04fffff]
Dec 21 21:36:32 wolff.to kernel: pci_bus 0000:05: resource 4 [io  0x0000-0xffff]
Dec 21 21:36:32 wolff.to kernel: pci_bus 0000:05: resource 5 [mem 0x00000000-0xffffffff]
Dec 21 21:36:32 wolff.to kernel: NET: Registered protocol family 2
Dec 21 21:36:32 wolff.to kernel: TCP established hash table entries: 8192 (order: 3, 32768 bytes)
Dec 21 21:36:32 wolff.to kernel: TCP bind hash table entries: 8192 (order: 4, 65536 bytes)
Dec 21 21:36:32 wolff.to kernel: TCP: Hash tables configured (established 8192 bind 8192)
Dec 21 21:36:32 wolff.to kernel: UDP hash table entries: 512 (order: 2, 16384 bytes)
Dec 21 21:36:32 wolff.to kernel: UDP-Lite hash table entries: 512 (order: 2, 16384 bytes)
Dec 21 21:36:32 wolff.to kernel: NET: Registered protocol family 1
Dec 21 21:36:32 wolff.to kernel: pci 0000:01:00.0: Video device with shadowed ROM at [mem 0x000c0000-0x000dffff]
Dec 21 21:36:32 wolff.to kernel: PCI: CLS mismatch (32 != 64), using 64 bytes
Dec 21 21:36:32 wolff.to kernel: Unpacking initramfs...
Dec 21 21:36:32 wolff.to kernel: Freeing initrd memory: 25336K
Dec 21 21:36:32 wolff.to kernel: apm: BIOS version 1.2 Flags 0x03 (Driver version 1.16ac)
Dec 21 21:36:32 wolff.to kernel: apm: disabled - APM is not SMP safe.
Dec 21 21:36:32 wolff.to kernel: Initialise system trusted keyrings
Dec 21 21:36:32 wolff.to kernel: Key type blacklist registered
Dec 21 21:36:32 wolff.to kernel: workingset: timestamp_bits=14 max_order=20 bucket_order=6
Dec 21 21:36:32 wolff.to kernel: zbud: loaded
Dec 21 21:36:32 wolff.to kernel: SELinux:  Registering netfilter hooks
Dec 21 21:36:32 wolff.to kernel: tsc: Refined TSC clocksource calibration: 2657.812 MHz
Dec 21 21:36:32 wolff.to kernel: clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x264f913f74d, max_idle_ns: 440795309567 ns
Dec 21 21:36:32 wolff.to kernel: NET: Registered protocol family 38
Dec 21 21:36:32 wolff.to kernel: Key type asymmetric registered
Dec 21 21:36:32 wolff.to kernel: Asymmetric key parser 'x509' registered
Dec 21 21:36:32 wolff.to kernel: bounce: pool size: 64 pages
Dec 21 21:36:32 wolff.to kernel: Block layer SCSI generic (bsg) driver version 0.4 loaded (major 250)
Dec 21 21:36:32 wolff.to kernel: io scheduler noop registered
Dec 21 21:36:32 wolff.to kernel: io scheduler deadline registered
Dec 21 21:36:32 wolff.to kernel: io scheduler cfq registered (default)
Dec 21 21:36:32 wolff.to kernel: io scheduler mq-deadline registered
Dec 21 21:36:32 wolff.to kernel: atomic64_test: passed for i586+ platform with CX8 and with SSE
Dec 21 21:36:32 wolff.to kernel: vesafb: cannot reserve video memory at 0xe8000000
Dec 21 21:36:32 wolff.to kernel: vesafb: mode is 1280x1024x24, linelength=3840, pages=67
Dec 21 21:36:32 wolff.to kernel: vesafb: protected mode interface info at c000:56df
Dec 21 21:36:32 wolff.to kernel: vesafb: pmi: set display start = a928c552, set palette = 73e7564e
Dec 21 21:36:32 wolff.to kernel: vesafb: pmi: ports = 
Dec 21 21:36:32 wolff.to kernel: 2010 
Dec 21 21:36:32 wolff.to kernel: 2016 
Dec 21 21:36:32 wolff.to kernel: 2054 
Dec 21 21:36:32 wolff.to kernel: 2038 
Dec 21 21:36:32 wolff.to kernel: 203c 
Dec 21 21:36:32 wolff.to kernel: 205c 
Dec 21 21:36:32 wolff.to kernel: 2000 
Dec 21 21:36:32 wolff.to kernel: 2004 
Dec 21 21:36:32 wolff.to kernel: 20b0 
Dec 21 21:36:32 wolff.to kernel: 20b2 
Dec 21 21:36:32 wolff.to kernel: 20b4 
Dec 21 21:36:32 wolff.to kernel: 
Dec 21 21:36:32 wolff.to kernel: vesafb: scrolling: redraw
Dec 21 21:36:32 wolff.to kernel: vesafb: Truecolor: size=0:8:8:8, shift=0:16:8:0
Dec 21 21:36:32 wolff.to kernel: vesafb: framebuffer at 0xe8000000, mapped to 0xd4ae3250, using 7680k, total 262144k
Dec 21 21:36:32 wolff.to kernel: Console: switching to colour frame buffer device 160x64
Dec 21 21:36:32 wolff.to kernel: fb0: VESA VGA frame buffer device
Dec 21 21:36:32 wolff.to kernel: input: Power Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0A03:00/PNP0C0C:00/input/input0
Dec 21 21:36:32 wolff.to kernel: ACPI: Power Button [PWRB]
Dec 21 21:36:32 wolff.to kernel: input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
Dec 21 21:36:32 wolff.to kernel: ACPI: Power Button [PWRF]
Dec 21 21:36:32 wolff.to kernel: Serial: 8250/16550 driver, 32 ports, IRQ sharing enabled
Dec 21 21:36:32 wolff.to kernel: 00:04: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
Dec 21 21:36:32 wolff.to kernel: Non-volatile memory driver v1.3
Dec 21 21:36:32 wolff.to kernel: Linux agpgart interface v0.103
Dec 21 21:36:32 wolff.to kernel: agpgart-intel 0000:00:00.0: Intel E7505 Chipset
Dec 21 21:36:32 wolff.to kernel: agpgart-intel 0000:00:00.0: AGP aperture is 128M @ 0xd8000000
Dec 21 21:36:32 wolff.to kernel: ata_piix 0000:00:1f.1: version 2.13
Dec 21 21:36:32 wolff.to kernel: ata_piix 0000:00:1f.1: enabling device (0005 -> 0007)
Dec 21 21:36:32 wolff.to kernel: scsi host0: ata_piix
Dec 21 21:36:32 wolff.to kernel: scsi host1: ata_piix
Dec 21 21:36:32 wolff.to kernel: ata1: PATA max UDMA/100 cmd 0x1f0 ctl 0x3f6 bmdma 0x1800 irq 14
Dec 21 21:36:32 wolff.to kernel: ata2: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0x1808 irq 15
Dec 21 21:36:32 wolff.to kernel: libphy: Fixed MDIO Bus: probed
Dec 21 21:36:32 wolff.to kernel: ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
Dec 21 21:36:32 wolff.to kernel: ehci-pci: EHCI PCI platform driver
Dec 21 21:36:32 wolff.to kernel: ehci-pci 0000:00:1d.7: EHCI Host Controller
Dec 21 21:36:32 wolff.to kernel: ehci-pci 0000:00:1d.7: new USB bus registered, assigned bus number 1
Dec 21 21:36:32 wolff.to kernel: ehci-pci 0000:00:1d.7: debug port 1
Dec 21 21:36:32 wolff.to kernel: ehci-pci 0000:00:1d.7: cache line size of 64 is not supported
Dec 21 21:36:32 wolff.to kernel: ehci-pci 0000:00:1d.7: irq 23, io mem 0xd0000c00
Dec 21 21:36:32 wolff.to kernel: ehci-pci 0000:00:1d.7: USB 2.0 started, EHCI 1.00
Dec 21 21:36:32 wolff.to kernel: usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
Dec 21 21:36:32 wolff.to kernel: usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
Dec 21 21:36:32 wolff.to kernel: usb usb1: Product: EHCI Host Controller
Dec 21 21:36:32 wolff.to kernel: usb usb1: Manufacturer: Linux 4.15.0-0.rc4.git1.2.fc28.i686 ehci_hcd
Dec 21 21:36:32 wolff.to kernel: usb usb1: SerialNumber: 0000:00:1d.7
Dec 21 21:36:32 wolff.to kernel: hub 1-0:1.0: USB hub found
Dec 21 21:36:32 wolff.to kernel: hub 1-0:1.0: 6 ports detected
Dec 21 21:36:32 wolff.to kernel: ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
Dec 21 21:36:32 wolff.to kernel: ohci-pci: OHCI PCI platform driver
Dec 21 21:36:32 wolff.to kernel: uhci_hcd: USB Universal Host Controller Interface driver
Dec 21 21:36:32 wolff.to kernel: uhci_hcd 0000:00:1d.0: UHCI Host Controller
Dec 21 21:36:32 wolff.to kernel: uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 2
Dec 21 21:36:32 wolff.to kernel: uhci_hcd 0000:00:1d.0: detected 2 ports
Dec 21 21:36:32 wolff.to kernel: uhci_hcd 0000:00:1d.0: irq 16, io base 0x00001880
Dec 21 21:36:32 wolff.to kernel: usb usb2: New USB device found, idVendor=1d6b, idProduct=0001
Dec 21 21:36:32 wolff.to kernel: usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
Dec 21 21:36:32 wolff.to kernel: ata1.00: ATA-6: WDC WD3200JB-00KFA0, 08.05J08, max UDMA/100
Dec 21 21:36:32 wolff.to kernel: ata1.00: 625142448 sectors, multi 16: LBA48 
Dec 21 21:36:32 wolff.to kernel: ata1.00: configured for UDMA/100
Dec 21 21:36:32 wolff.to kernel: scsi 0:0:0:0: Direct-Access     ATA      WDC WD3200JB-00K 5J08 PQ: 0 ANSI: 5
Dec 21 21:36:32 wolff.to kernel: sd 0:0:0:0: Attached scsi generic sg0 type 0
Dec 21 21:36:32 wolff.to kernel: sd 0:0:0:0: [sda] 625142448 512-byte logical blocks: (320 GB/298 GiB)
Dec 21 21:36:32 wolff.to kernel: sd 0:0:0:0: [sda] Write Protect is off
Dec 21 21:36:32 wolff.to kernel: sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
Dec 21 21:36:32 wolff.to kernel: sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
Dec 21 21:36:32 wolff.to kernel:  sda: sda1 sda2 sda3 sda4
Dec 21 21:36:32 wolff.to kernel: sd 0:0:0:0: [sda] Attached SCSI disk
Dec 21 21:36:32 wolff.to kernel: ata2.00: ATA-6: WDC WD3200JB-00KFA0, 08.05J08, max UDMA/100
Dec 21 21:36:32 wolff.to kernel: ata2.00: 625142448 sectors, multi 16: LBA48 
Dec 21 21:36:32 wolff.to kernel: ata2.00: configured for UDMA/100
Dec 21 21:36:32 wolff.to kernel: scsi 1:0:0:0: Direct-Access     ATA      WDC WD3200JB-00K 5J08 PQ: 0 ANSI: 5
Dec 21 21:36:32 wolff.to kernel: sd 1:0:0:0: [sdb] 625142448 512-byte logical blocks: (320 GB/298 GiB)
Dec 21 21:36:32 wolff.to kernel: sd 1:0:0:0: [sdb] Write Protect is off
Dec 21 21:36:32 wolff.to kernel: sd 1:0:0:0: [sdb] Mode Sense: 00 3a 00 00
Dec 21 21:36:32 wolff.to kernel: sd 1:0:0:0: Attached scsi generic sg1 type 0
Dec 21 21:36:32 wolff.to kernel: sd 1:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
Dec 21 21:36:32 wolff.to kernel:  sdb: sdb1 sdb2 sdb3 sdb4
Dec 21 21:36:32 wolff.to kernel: sd 1:0:0:0: [sdb] Attached SCSI disk
Dec 21 21:36:32 wolff.to kernel: usb usb2: Product: UHCI Host Controller
Dec 21 21:36:32 wolff.to kernel: usb usb2: Manufacturer: Linux 4.15.0-0.rc4.git1.2.fc28.i686 uhci_hcd
Dec 21 21:36:32 wolff.to kernel: usb usb2: SerialNumber: 0000:00:1d.0
Dec 21 21:36:32 wolff.to kernel: clocksource: Switched to clocksource tsc
Dec 21 21:36:32 wolff.to kernel: hub 2-0:1.0: USB hub found
Dec 21 21:36:32 wolff.to kernel: hub 2-0:1.0: 2 ports detected
Dec 21 21:36:32 wolff.to kernel: uhci_hcd 0000:00:1d.1: UHCI Host Controller
Dec 21 21:36:32 wolff.to kernel: uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 3
Dec 21 21:36:32 wolff.to kernel: uhci_hcd 0000:00:1d.1: detected 2 ports
Dec 21 21:36:32 wolff.to kernel: uhci_hcd 0000:00:1d.1: irq 19, io base 0x000018a0
Dec 21 21:36:32 wolff.to kernel: usb usb3: New USB device found, idVendor=1d6b, idProduct=0001
Dec 21 21:36:32 wolff.to kernel: usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
Dec 21 21:36:32 wolff.to kernel: usb usb3: Product: UHCI Host Controller
Dec 21 21:36:32 wolff.to kernel: usb usb3: Manufacturer: Linux 4.15.0-0.rc4.git1.2.fc28.i686 uhci_hcd
Dec 21 21:36:32 wolff.to kernel: usb usb3: SerialNumber: 0000:00:1d.1
Dec 21 21:36:32 wolff.to kernel: hub 3-0:1.0: USB hub found
Dec 21 21:36:32 wolff.to kernel: hub 3-0:1.0: 2 ports detected
Dec 21 21:36:32 wolff.to kernel: uhci_hcd 0000:00:1d.2: UHCI Host Controller
Dec 21 21:36:32 wolff.to kernel: uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 4
Dec 21 21:36:32 wolff.to kernel: uhci_hcd 0000:00:1d.2: detected 2 ports
Dec 21 21:36:32 wolff.to kernel: uhci_hcd 0000:00:1d.2: irq 18, io base 0x000018c0
Dec 21 21:36:32 wolff.to kernel: usb usb4: New USB device found, idVendor=1d6b, idProduct=0001
Dec 21 21:36:32 wolff.to kernel: usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
Dec 21 21:36:32 wolff.to kernel: usb usb4: Product: UHCI Host Controller
Dec 21 21:36:32 wolff.to kernel: usb usb4: Manufacturer: Linux 4.15.0-0.rc4.git1.2.fc28.i686 uhci_hcd
Dec 21 21:36:32 wolff.to kernel: usb usb4: SerialNumber: 0000:00:1d.2
Dec 21 21:36:32 wolff.to kernel: hub 4-0:1.0: USB hub found
Dec 21 21:36:32 wolff.to kernel: hub 4-0:1.0: 2 ports detected
Dec 21 21:36:32 wolff.to kernel: usbcore: registered new interface driver usbserial_generic
Dec 21 21:36:32 wolff.to kernel: usbserial: USB Serial support registered for generic
Dec 21 21:36:32 wolff.to kernel: i8042: PNP: PS/2 Controller [PNP0303:KBC0,PNP0f13:MOUS] at 0x60,0x64 irq 1,12
Dec 21 21:36:32 wolff.to kernel: serio: i8042 KBD port at 0x60,0x64 irq 1
Dec 21 21:36:32 wolff.to kernel: mousedev: PS/2 mouse device common for all mice
Dec 21 21:36:32 wolff.to kernel: rtc_cmos 00:01: RTC can wake from S4
Dec 21 21:36:32 wolff.to kernel: rtc_cmos 00:01: rtc core: registered rtc_cmos as rtc0
Dec 21 21:36:32 wolff.to kernel: rtc_cmos 00:01: alarms up to one month, y3k, 114 bytes nvram
Dec 21 21:36:32 wolff.to kernel: device-mapper: uevent: version 1.0.3
Dec 21 21:36:32 wolff.to kernel: device-mapper: ioctl: 4.37.0-ioctl (2017-09-20) initialised: dm-devel@redhat.com
Dec 21 21:36:32 wolff.to kernel: hidraw: raw HID events driver (C) Jiri Kosina
Dec 21 21:36:32 wolff.to kernel: usbcore: registered new interface driver usbhid
Dec 21 21:36:32 wolff.to kernel: usbhid: USB HID core driver
Dec 21 21:36:32 wolff.to kernel: drop_monitor: Initializing network drop monitor service
Dec 21 21:36:32 wolff.to kernel: ip_tables: (C) 2000-2006 Netfilter Core Team
Dec 21 21:36:32 wolff.to kernel: input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input2
Dec 21 21:36:32 wolff.to kernel: Initializing XFRM netlink socket
Dec 21 21:36:32 wolff.to kernel: NET: Registered protocol family 10
Dec 21 21:36:32 wolff.to kernel: Segment Routing with IPv6
Dec 21 21:36:32 wolff.to kernel: mip6: Mobile IPv6
Dec 21 21:36:32 wolff.to kernel: NET: Registered protocol family 17
Dec 21 21:36:32 wolff.to kernel: RAS: Correctable Errors collector initialized.
Dec 21 21:36:32 wolff.to kernel: microcode: sig=0xf29, pf=0x2, revision=0x2d
Dec 21 21:36:32 wolff.to kernel: microcode: Microcode Update Driver: v2.2.
Dec 21 21:36:32 wolff.to kernel: Using IPI No-Shortcut mode
Dec 21 21:36:32 wolff.to kernel: sched_clock: Marking stable (4690937605, 0)->(4807466556, -116528951)
Dec 21 21:36:32 wolff.to kernel: registered taskstats version 1
Dec 21 21:36:32 wolff.to kernel: Loading compiled-in X.509 certificates
Dec 21 21:36:32 wolff.to kernel: Loaded X.509 cert 'Fedora kernel signing key: d7fa16559f9a1d68f393d57450f4491f8ebf752d'
Dec 21 21:36:32 wolff.to kernel: zswap: loaded using pool lzo/zbud
Dec 21 21:36:32 wolff.to kernel: Key type big_key registered
Dec 21 21:36:32 wolff.to kernel: Key type encrypted registered
Dec 21 21:36:32 wolff.to kernel:   Magic number: 13:586:614
Dec 21 21:36:32 wolff.to kernel: acpi PNP0303:00: hash matches
Dec 21 21:36:32 wolff.to kernel: rtc_cmos 00:01: setting system clock to 2017-12-22 03:36:31 UTC (1513913791)
Dec 21 21:36:32 wolff.to kernel: Freeing unused kernel memory: 884K
Dec 21 21:36:32 wolff.to kernel: Write protecting the kernel text: 7828k
Dec 21 21:36:32 wolff.to kernel: Write protecting the kernel read-only data: 3172k
Dec 21 21:36:32 wolff.to kernel: rodata_test: all tests were successful
Dec 21 21:36:32 wolff.to systemd[1]: systemd 236 running in system mode. (+PAM +AUDIT +SELINUX +IMA -APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT +GNUTLS +ACL +XZ +LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD +IDN2 -IDN default-hierarchy=hybrid)
Dec 21 21:36:32 wolff.to systemd[1]: Detected architecture x86.
Dec 21 21:36:32 wolff.to systemd[1]: Running in initial RAM disk.
Dec 21 21:36:32 wolff.to systemd[1]: Set hostname to <wolff.to>.
Dec 21 21:36:32 wolff.to systemd[1]: Reached target Swap.
Dec 21 21:36:32 wolff.to systemd[1]: Reached target Local File Systems.
Dec 21 21:36:32 wolff.to systemd[1]: Reached target Timers.
Dec 21 21:36:32 wolff.to systemd[1]: Created slice System Slice.
Dec 21 21:36:32 wolff.to systemd[1]: Created slice system-systemd\x2dcryptsetup.slice.
Dec 21 21:36:32 wolff.to systemd[1]: Listening on Journal Socket.
Dec 21 21:36:32 wolff.to kernel: netpoll: netconsole: local port 6665
Dec 21 21:36:32 wolff.to kernel: netpoll: netconsole: local IPv4 address 98.103.208.27
Dec 21 21:36:32 wolff.to kernel: netpoll: netconsole: interface 'eth0'
Dec 21 21:36:32 wolff.to kernel: netpoll: netconsole: remote port 6666
Dec 21 21:36:32 wolff.to kernel: netpoll: netconsole: remote IPv4 address 98.103.208.28
Dec 21 21:36:32 wolff.to kernel: netpoll: netconsole: remote ethernet address ff:ff:ff:ff:ff:ff
Dec 21 21:36:32 wolff.to kernel: netpoll: netconsole: eth0 doesn't exist, aborting
Dec 21 21:36:32 wolff.to kernel: netconsole: cleaning up
Dec 21 21:36:33 wolff.to kernel: audit: type=1130 audit(1513913793.031:2): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-journald comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 21 21:36:33 wolff.to kernel: audit: type=1130 audit(1513913793.148:3): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-modules-load comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=failed'
Dec 21 21:36:33 wolff.to kernel: audit: type=1130 audit(1513913793.244:4): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=dracut-cmdline-ask comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 21 21:36:33 wolff.to kernel: audit: type=1130 audit(1513913793.344:5): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-tmpfiles-setup comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 21 21:36:33 wolff.to kernel: audit: type=1130 audit(1513913793.447:6): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=kmod-static-nodes comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 21 21:36:33 wolff.to kernel: audit: type=1130 audit(1513913793.555:7): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-vconsole-setup comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 21 21:36:33 wolff.to kernel: audit: type=1131 audit(1513913793.555:8): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-vconsole-setup comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 21 21:36:33 wolff.to kernel: audit: type=1130 audit(1513913793.908:9): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-tmpfiles-setup-dev comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 21 21:36:34 wolff.to kernel: audit: type=1130 audit(1513913794.038:10): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-sysctl comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 21 21:36:34 wolff.to kernel: audit: type=1130 audit(1513913794.327:11): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=dracut-cmdline comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 21 21:36:35 wolff.to kernel: Fusion MPT base driver 3.04.20
Dec 21 21:36:35 wolff.to kernel: Copyright (c) 1999-2008 LSI Corporation
Dec 21 21:36:35 wolff.to kernel: e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-NAPI
Dec 21 21:36:35 wolff.to kernel: e1000: Copyright (c) 1999-2006 Intel Corporation.
Dec 21 21:36:35 wolff.to kernel: Fusion MPT SPI Host driver 3.04.20
Dec 21 21:36:35 wolff.to kernel: mptbase: ioc0: Initiating bringup
Dec 21 21:36:36 wolff.to kernel: e1000 0000:05:03.0 eth0: (PCI:33MHz:32-bit) 00:0d:9d:ff:20:ab
Dec 21 21:36:36 wolff.to kernel: e1000 0000:05:03.0 eth0: Intel(R) PRO/1000 Network Connection
Dec 21 21:36:36 wolff.to kernel: e1000 0000:05:03.0 enp5s3: renamed from eth0
Dec 21 21:36:36 wolff.to kernel: ioc0: LSI53C1030 B2: Capabilities={Initiator}
Dec 21 21:36:36 wolff.to kernel: [drm] VGACON disable radeon kernel modesetting.
Dec 21 21:36:36 wolff.to kernel: [drm:radeon_init [radeon]] *ERROR* No UMS support in radeon module!
Dec 21 21:36:36 wolff.to kernel: random: crng init done
Dec 21 21:36:36 wolff.to kernel: scsi host2: ioc0: LSI53C1030 B2, FwRev=01030a00h, Ports=1, MaxQ=255, IRQ=24
Dec 21 21:36:36 wolff.to kernel: md/raid1:md11: active with 2 out of 2 mirrors
Dec 21 21:36:36 wolff.to kernel: md/raid1:md12: active with 2 out of 2 mirrors
Dec 21 21:36:36 wolff.to kernel: md12: detected capacity change from 0 to 10736295936
Dec 21 21:36:36 wolff.to kernel: md/raid1:md13: active with 2 out of 2 mirrors
Dec 21 21:36:36 wolff.to kernel: md13: detected capacity change from 0 to 85898223616
Dec 21 21:36:36 wolff.to kernel: mptbase: ioc1: Initiating bringup
Dec 21 21:36:36 wolff.to kernel: md11: detected capacity change from 0 to 1073729536
Dec 21 21:36:36 wolff.to kernel: ioc1: LSI53C1030 B2: Capabilities={Initiator}
Dec 21 21:36:37 wolff.to kernel: scsi host3: ioc1: LSI53C1030 B2, FwRev=01030a00h, Ports=1, MaxQ=255, IRQ=25
Dec 21 21:36:37 wolff.to kernel: scsi 2:0:0:0: Direct-Access     SEAGATE  ST336753LW       HPS2 PQ: 0 ANSI: 3
Dec 21 21:36:37 wolff.to kernel: scsi target2:0:0: Beginning Domain Validation
Dec 21 21:36:37 wolff.to kernel: scsi 2:0:0:0: Power-on or device reset occurred
Dec 21 21:36:37 wolff.to kernel: scsi target2:0:0: Ending Domain Validation
Dec 21 21:36:37 wolff.to kernel: scsi target2:0:0: FAST-160 WIDE SCSI 320.0 MB/s DT IU QAS RTI WRFLOW PCOMP (6.25 ns, offset 63)
Dec 21 21:36:37 wolff.to kernel: scsi 2:0:1:0: Direct-Access     SEAGATE  ST336753LW       HPS2 PQ: 0 ANSI: 3
Dec 21 21:36:37 wolff.to kernel: scsi target2:0:1: Beginning Domain Validation
Dec 21 21:36:37 wolff.to kernel: scsi 2:0:1:0: Power-on or device reset occurred
Dec 21 21:36:38 wolff.to kernel: scsi target2:0:1: Ending Domain Validation
Dec 21 21:36:38 wolff.to kernel: scsi target2:0:1: FAST-160 WIDE SCSI 320.0 MB/s DT IU QAS RTI WRFLOW PCOMP (6.25 ns, offset 63)
Dec 21 21:36:41 wolff.to kernel: sd 2:0:0:0: Attached scsi generic sg2 type 0
Dec 21 21:36:41 wolff.to kernel: sd 2:0:0:0: [sdc] 71132960 512-byte logical blocks: (36.4 GB/33.9 GiB)
Dec 21 21:36:41 wolff.to kernel: sd 2:0:0:0: [sdc] Write Protect is off
Dec 21 21:36:41 wolff.to kernel: sd 2:0:0:0: [sdc] Mode Sense: ab 00 10 08
Dec 21 21:36:41 wolff.to kernel: sd 2:0:0:0: [sdc] Write cache: enabled, read cache: enabled, supports DPO and FUA
Dec 21 21:36:41 wolff.to kernel:  sdc: sdc1
Dec 21 21:36:41 wolff.to kernel: sd 2:0:0:0: [sdc] Attached SCSI disk
Dec 21 21:36:41 wolff.to kernel: sd 2:0:1:0: Attached scsi generic sg3 type 0
Dec 21 21:36:41 wolff.to kernel: sd 2:0:1:0: [sdd] 71132960 512-byte logical blocks: (36.4 GB/33.9 GiB)
Dec 21 21:36:41 wolff.to kernel: sd 2:0:1:0: [sdd] Write Protect is off
Dec 21 21:36:41 wolff.to kernel: sd 2:0:1:0: [sdd] Mode Sense: ab 00 10 08
Dec 21 21:36:41 wolff.to kernel: sd 2:0:1:0: [sdd] Write cache: enabled, read cache: enabled, supports DPO and FUA
Dec 21 21:36:41 wolff.to kernel:  sdd: sdd1
Dec 21 21:36:41 wolff.to kernel: sd 2:0:1:0: [sdd] Attached SCSI disk
Dec 21 21:36:55 wolff.to kernel: kauditd_printk_skb: 8 callbacks suppressed
Dec 21 21:36:55 wolff.to kernel: audit: type=1130 audit(1513913815.663:20): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-cryptsetup@luks\x2d6298c7e5\x2daadf\x2d44d5\x2dbe91\x2d28734671492a comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 21 21:36:55 wolff.to kernel: audit: type=1130 audit(1513913815.764:21): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=dracut-initqueue comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 21 21:36:55 wolff.to kernel: audit: type=1130 audit(1513913815.870:22): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-cryptsetup@luks\x2d11707d7d\x2d2c96\x2d4dd9\x2d8bb4\x2d506d8e7dcdd8 comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 21 21:36:56 wolff.to kernel: audit: type=1130 audit(1513913816.111:23): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=dracut-pre-mount comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 21 21:36:56 wolff.to kernel: audit: type=1130 audit(1513913816.525:24): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-fsck-root comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 21 21:36:56 wolff.to kernel: EXT4-fs: Warning: mounting with data=journal disables delayed allocation and O_DIRECT support!
Dec 21 21:36:56 wolff.to kernel: EXT4-fs (dm-0): mounted filesystem with journalled data mode. Opts: (null)
Dec 21 21:36:57 wolff.to kernel: audit: type=1130 audit(1513913817.139:25): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=initrd-parse-etc comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 21 21:36:57 wolff.to kernel: audit: type=1131 audit(1513913817.139:26): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=initrd-parse-etc comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 21 21:36:57 wolff.to kernel: audit: type=1130 audit(1513913817.581:27): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=dracut-pre-pivot comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 21 21:36:57 wolff.to kernel: audit: type=1131 audit(1513913817.720:28): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=dracut-pre-pivot comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 21 21:36:58 wolff.to kernel: audit: type=1130 audit(1513913818.085:29): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-sysctl comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 21 21:37:10 wolff.to systemd-journald[176]: Received SIGTERM from PID 1 (systemd).
Dec 21 21:37:10 wolff.to kernel: systemd: 13 output lines suppressed due to ratelimiting
Dec 21 21:37:10 wolff.to kernel: kauditd_printk_skb: 33 callbacks suppressed
Dec 21 21:37:10 wolff.to kernel: audit: type=1404 audit(1513913822.042:63): enforcing=1 old_enforcing=0 auid=4294967295 ses=4294967295
Dec 21 21:37:10 wolff.to kernel: SELinux: 32768 avtab hash slots, 109731 rules.
Dec 21 21:37:10 wolff.to kernel: SELinux: 32768 avtab hash slots, 109731 rules.
Dec 21 21:37:10 wolff.to kernel: SELinux:  8 users, 14 roles, 5120 types, 317 bools, 1 sens, 1024 cats
Dec 21 21:37:10 wolff.to kernel: SELinux:  97 classes, 109731 rules
Dec 21 21:37:10 wolff.to kernel: SELinux:  Permission getrlimit in class process not defined in policy.
Dec 21 21:37:10 wolff.to kernel: SELinux:  Class sctp_socket not defined in policy.
Dec 21 21:37:10 wolff.to kernel: SELinux:  Class icmp_socket not defined in policy.
Dec 21 21:37:10 wolff.to kernel: SELinux:  Class ax25_socket not defined in policy.
Dec 21 21:37:10 wolff.to kernel: SELinux:  Class ipx_socket not defined in policy.
Dec 21 21:37:10 wolff.to kernel: SELinux:  Class netrom_socket not defined in policy.
Dec 21 21:37:10 wolff.to kernel: SELinux:  Class atmpvc_socket not defined in policy.
Dec 21 21:37:10 wolff.to kernel: SELinux:  Class x25_socket not defined in policy.
Dec 21 21:37:10 wolff.to kernel: SELinux:  Class rose_socket not defined in policy.
Dec 21 21:37:10 wolff.to kernel: SELinux:  Class decnet_socket not defined in policy.
Dec 21 21:37:10 wolff.to kernel: SELinux:  Class atmsvc_socket not defined in policy.
Dec 21 21:37:10 wolff.to kernel: SELinux:  Class rds_socket not defined in policy.
Dec 21 21:37:10 wolff.to kernel: SELinux:  Class irda_socket not defined in policy.
Dec 21 21:37:10 wolff.to kernel: SELinux:  Class pppox_socket not defined in policy.
Dec 21 21:37:10 wolff.to kernel: SELinux:  Class llc_socket not defined in policy.
Dec 21 21:37:10 wolff.to kernel: SELinux:  Class can_socket not defined in policy.
Dec 21 21:37:10 wolff.to kernel: SELinux:  Class tipc_socket not defined in policy.
Dec 21 21:37:10 wolff.to kernel: SELinux:  Class bluetooth_socket not defined in policy.
Dec 21 21:37:10 wolff.to kernel: SELinux:  Class iucv_socket not defined in policy.
Dec 21 21:37:10 wolff.to kernel: SELinux:  Class rxrpc_socket not defined in policy.
Dec 21 21:37:10 wolff.to kernel: SELinux:  Class isdn_socket not defined in policy.
Dec 21 21:37:10 wolff.to kernel: SELinux:  Class phonet_socket not defined in policy.
Dec 21 21:37:10 wolff.to kernel: SELinux:  Class ieee802154_socket not defined in policy.
Dec 21 21:37:10 wolff.to kernel: SELinux:  Class caif_socket not defined in policy.
Dec 21 21:37:10 wolff.to kernel: SELinux:  Class alg_socket not defined in policy.
Dec 21 21:37:10 wolff.to kernel: SELinux:  Class nfc_socket not defined in policy.
Dec 21 21:37:10 wolff.to kernel: SELinux:  Class vsock_socket not defined in policy.
Dec 21 21:37:10 wolff.to kernel: SELinux:  Class kcm_socket not defined in policy.
Dec 21 21:37:10 wolff.to kernel: SELinux:  Class qipcrtr_socket not defined in policy.
Dec 21 21:37:10 wolff.to kernel: SELinux:  Class smc_socket not defined in policy.
Dec 21 21:37:10 wolff.to kernel: SELinux:  Class bpf not defined in policy.
Dec 21 21:37:10 wolff.to kernel: SELinux: the above unknown classes and permissions will be allowed
Dec 21 21:37:10 wolff.to kernel: SELinux:  policy capability network_peer_controls=1
Dec 21 21:37:10 wolff.to kernel: SELinux:  policy capability open_perms=1
Dec 21 21:37:10 wolff.to kernel: SELinux:  policy capability extended_socket_class=0
Dec 21 21:37:10 wolff.to kernel: SELinux:  policy capability always_check_network=0
Dec 21 21:37:10 wolff.to kernel: SELinux:  policy capability cgroup_seclabel=1
Dec 21 21:37:10 wolff.to kernel: SELinux:  policy capability nnp_nosuid_transition=1
Dec 21 21:37:10 wolff.to kernel: SELinux:  Completing initialization.
Dec 21 21:37:10 wolff.to kernel: SELinux:  Setting up existing superblocks.
Dec 21 21:37:10 wolff.to kernel: audit: type=1403 audit(1513913823.759:64): policy loaded auid=4294967295 ses=4294967295
Dec 21 21:37:10 wolff.to systemd[1]: Successfully loaded SELinux policy in 1.732257s.
Dec 21 21:37:10 wolff.to kernel: audit: type=1400 audit(1513913824.191:65): avc:  denied  { relabelfrom } for  pid=1 comm="systemd" name="invocation:initrd-switch-root.service" dev="tmpfs" ino=15253 scontext=system_u:system_r:init_t:s0 tcontext=system_u:object_r:tmpfs_t:s0 tclass=lnk_file permissive=0
Dec 21 21:37:10 wolff.to systemd[1]: Unable to fix SELinux security context of /run/systemd/units/invocation:initrd-switch-root.service: Permission denied
Dec 21 21:37:10 wolff.to systemd[1]: Unable to fix SELinux security context of /run/systemd/units/invocation:sysroot.mount: Permission denied
Dec 21 21:37:10 wolff.to systemd[1]: Unable to fix SELinux security context of /run/systemd/units/invocation:systemd-fsck-root.service: Permission denied
Dec 21 21:37:10 wolff.to systemd[1]: Unable to fix SELinux security context of /run/systemd/units/invocation:systemd-cryptsetup@luks\x2d6298c7e5\x2daadf\x2d44d5\x2dbe91\x2d28734671492a.service: Permission denied
Dec 21 21:37:10 wolff.to systemd[1]: Unable to fix SELinux security context of /run/systemd/units/invocation:systemd-cryptsetup@luks\x2d11707d7d\x2d2c96\x2d4dd9\x2d8bb4\x2d506d8e7dcdd8.service: Permission denied
Dec 21 21:37:10 wolff.to systemd[1]: Unable to fix SELinux security context of /run/systemd/units/invocation:plymouth-start.service: Permission denied
Dec 21 21:37:10 wolff.to systemd[1]: Unable to fix SELinux security context of /run/systemd/units/invocation:sys-kernel-config.mount: Permission denied
Dec 21 21:37:10 wolff.to systemd[1]: Unable to fix SELinux security context of /run/systemd/units/invocation:systemd-journald.service: Permission denied
Dec 21 21:37:10 wolff.to systemd[1]: Relabelled /dev, /run and /sys/fs/cgroup in 176.458ms.
Dec 21 21:37:10 wolff.to kernel: audit: type=1400 audit(1513913824.192:66): avc:  denied  { relabelfrom } for  pid=1 comm="systemd" name="invocation:sysroot.mount" dev="tmpfs" ino=15224 scontext=system_u:system_r:init_t:s0 tcontext=system_u:object_r:tmpfs_t:s0 tclass=lnk_file permissive=0
Dec 21 21:37:10 wolff.to kernel: audit: type=1400 audit(1513913824.193:67): avc:  denied  { relabelfrom } for  pid=1 comm="systemd" name="invocation:systemd-fsck-root.service" dev="tmpfs" ino=15221 scontext=system_u:system_r:init_t:s0 tcontext=system_u:object_r:tmpfs_t:s0 tclass=lnk_file permissive=0
Dec 21 21:37:10 wolff.to kernel: audit: type=1400 audit(1513913824.194:68): avc:  denied  { relabelfrom } for  pid=1 comm="systemd" name="invocation:systemd-cryptsetup@luks\x2d6298c7e5\x2daadf\x2d44d5\x2dbe91\x2d28734671492a.service" dev="tmpfs" ino=14918 scontext=system_u:system_r:init_t:s0 tcontext=system_u:object_r:tmpfs_t:s0 tclass=lnk_file permissive=0
Dec 21 21:37:10 wolff.to kernel: audit: type=1400 audit(1513913824.195:69): avc:  denied  { relabelfrom } for  pid=1 comm="systemd" name="invocation:systemd-cryptsetup@luks\x2d11707d7d\x2d2c96\x2d4dd9\x2d8bb4\x2d506d8e7dcdd8.service" dev="tmpfs" ino=14914 scontext=system_u:system_r:init_t:s0 tcontext=system_u:object_r:tmpfs_t:s0 tclass=lnk_file permissive=0
Dec 21 21:37:10 wolff.to kernel: audit: type=1400 audit(1513913824.195:70): avc:  denied  { relabelfrom } for  pid=1 comm="systemd" name="invocation:plymouth-start.service" dev="tmpfs" ino=13744 scontext=system_u:system_r:init_t:s0 tcontext=system_u:object_r:tmpfs_t:s0 tclass=lnk_file permissive=0
Dec 21 21:37:10 wolff.to kernel: audit: type=1400 audit(1513913824.196:71): avc:  denied  { relabelfrom } for  pid=1 comm="systemd" name="invocation:sys-kernel-config.mount" dev="tmpfs" ino=13734 scontext=system_u:system_r:init_t:s0 tcontext=system_u:object_r:tmpfs_t:s0 tclass=lnk_file permissive=0
Dec 21 21:37:10 wolff.to kernel: audit: type=1400 audit(1513913824.197:72): avc:  denied  { relabelfrom } for  pid=1 comm="systemd" name="invocation:systemd-journald.service" dev="tmpfs" ino=14368 scontext=system_u:system_r:init_t:s0 tcontext=system_u:object_r:tmpfs_t:s0 tclass=lnk_file permissive=0
Dec 21 21:37:10 wolff.to systemd-sysv-generator[867]: stat() failed on /etc/rc.d/init.d/qmailctl, ignoring: No such file or directory
Dec 21 21:37:10 wolff.to kernel: audit: type=1400 audit(1513913827.060:73): avc:  denied  { map } for  pid=852 comm="anaconda-genera" path="/etc/passwd" dev="dm-0" ino=2638674 scontext=system_u:system_r:init_t:s0 tcontext=system_u:object_r:passwd_file_t:s0 tclass=file permissive=0
Dec 21 21:37:10 wolff.to kernel: audit: type=1300 audit(1513913827.060:73): arch=40000003 syscall=192 success=no exit=-13 a0=0 a1=2792 a2=1 a3=1 items=0 ppid=851 pid=852 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="anaconda-genera" exe="/usr/bin/bash" subj=system_u:system_r:init_t:s0 key=(null)
Dec 21 21:37:10 wolff.to kernel: audit: type=1327 audit(1513913827.060:73): proctitle=2F62696E2F62617368002F7573722F6C69622F73797374656D642F73797374656D2D67656E657261746F72732F616E61636F6E64612D67656E657261746F72002F72756E2F73797374656D642F67656E657261746F72002F72756E2F73797374656D642F67656E657261746F722E6561726C79002F72756E2F73797374656D64
Dec 21 21:37:10 wolff.to kernel: audit: type=1400 audit(1513913827.061:74): avc:  denied  { map } for  pid=858 comm="selinux-autorel" path="/etc/passwd" dev="dm-0" ino=2638674 scontext=system_u:system_r:init_t:s0 tcontext=system_u:object_r:passwd_file_t:s0 tclass=file permissive=0
Dec 21 21:37:10 wolff.to kernel: audit: type=1400 audit(1513913827.061:75): avc:  denied  { map } for  pid=853 comm="kdump-dep-gener" path="/etc/passwd" dev="dm-0" ino=2638674 scontext=system_u:system_r:init_t:s0 tcontext=system_u:object_r:passwd_file_t:s0 tclass=file permissive=0
Dec 21 21:37:10 wolff.to kernel: audit: type=1300 audit(1513913827.061:74): arch=40000003 syscall=192 success=no exit=-13 a0=0 a1=2792 a2=1 a3=1 items=0 ppid=851 pid=858 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="selinux-autorel" exe="/usr/bin/bash" subj=system_u:system_r:init_t:s0 key=(null)
Dec 21 21:37:10 wolff.to kernel: audit: type=1300 audit(1513913827.061:75): arch=40000003 syscall=192 success=no exit=-13 a0=0 a1=2792 a2=1 a3=1 items=0 ppid=851 pid=853 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="kdump-dep-gener" exe="/usr/bin/bash" subj=system_u:system_r:init_t:s0 key=(null)
Dec 21 21:37:10 wolff.to kernel: audit: type=1327 audit(1513913827.061:74): proctitle=2F62696E2F7368002F7573722F6C69622F73797374656D642F73797374656D2D67656E657261746F72732F73656C696E75782D6175746F72656C6162656C2D67656E657261746F722E7368002F72756E2F73797374656D642F67656E657261746F72002F72756E2F73797374656D642F67656E657261746F722E6561726C79
Dec 21 21:37:10 wolff.to kernel: audit: type=1327 audit(1513913827.061:75): proctitle=2F62696E2F7368002F7573722F6C69622F73797374656D642F73797374656D2D67656E657261746F72732F6B64756D702D6465702D67656E657261746F722E7368002F72756E2F73797374656D642F67656E657261746F72002F72756E2F73797374656D642F67656E657261746F722E6561726C79002F72756E2F7379737465
Dec 21 21:37:10 wolff.to kernel: audit: type=1400 audit(1513913827.061:76): avc:  denied  { map } for  pid=869 comm="vsftpd-generato" path="/etc/passwd" dev="dm-0" ino=2638674 scontext=system_u:system_r:init_t:s0 tcontext=system_u:object_r:passwd_file_t:s0 tclass=file permissive=0
Dec 21 21:37:11 wolff.to kernel: EXT4-fs (dm-0): re-mounted. Opts: barrier=1
Dec 21 21:37:12 wolff.to kernel: netpoll: netconsole: local port 6665
Dec 21 21:37:12 wolff.to kernel: netpoll: netconsole: local IPv4 address 98.103.208.27
Dec 21 21:37:12 wolff.to kernel: netpoll: netconsole: interface 'eth0'
Dec 21 21:37:12 wolff.to kernel: netpoll: netconsole: remote port 6666
Dec 21 21:37:12 wolff.to kernel: netpoll: netconsole: remote IPv4 address 98.103.208.28
Dec 21 21:37:12 wolff.to kernel: netpoll: netconsole: remote ethernet address ff:ff:ff:ff:ff:ff
Dec 21 21:37:12 wolff.to kernel: netpoll: netconsole: eth0 doesn't exist, aborting
Dec 21 21:37:12 wolff.to kernel: netconsole: cleaning up
Dec 21 21:37:13 wolff.to kernel: kauditd_printk_skb: 12 callbacks suppressed
Dec 21 21:37:13 wolff.to kernel: audit: type=1400 audit(1513913832.659:85): avc:  denied  { read } for  pid=880 comm="systemd-journal" name="invocation:systemd-modules-load.service" dev="tmpfs" ino=15290 scontext=system_u:system_r:syslogd_t:s0 tcontext=system_u:object_r:init_var_run_t:s0 tclass=lnk_file permissive=0
Dec 21 21:37:13 wolff.to kernel: audit: type=1300 audit(1513913832.659:85): arch=40000003 syscall=305 success=no exit=-13 a0=ffffff9c a1=bfb408f0 a2=238a680 a3=63 items=0 ppid=1 pid=880 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="systemd-journal" exe="/usr/lib/systemd/systemd-journald" subj=system_u:system_r:syslogd_t:s0 key=(null)
Dec 21 21:37:13 wolff.to kernel: audit: type=1327 audit(1513913832.659:85): proctitle="/usr/lib/systemd/systemd-journald"
Dec 21 21:37:13 wolff.to kernel: audit: type=1130 audit(1513913833.212:86): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=systemd-journald comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 21 21:37:13 wolff.to kernel: audit: type=1130 audit(1513913833.382:87): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=systemd-remount-fs comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 21 21:37:13 wolff.to kernel: audit: type=1130 audit(1513913833.533:88): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=systemd-modules-load comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=failed'
Dec 21 21:37:13 wolff.to kernel: audit: type=1130 audit(1513913833.662:89): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=kmod-static-nodes comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 21 21:37:13 wolff.to kernel: audit: type=1130 audit(1513913833.745:90): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=systemd-udev-trigger comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 21 21:37:14 wolff.to kernel: audit: type=1400 audit(1513913833.779:91): avc:  denied  { map } for  pid=905 comm="sh" path="/etc/passwd" dev="dm-0" ino=2638674 scontext=system_u:system_r:loadkeys_t:s0 tcontext=system_u:object_r:passwd_file_t:s0 tclass=file permissive=0
Dec 21 21:37:14 wolff.to kernel: audit: type=1300 audit(1513913833.779:91): arch=40000003 syscall=192 success=no exit=-13 a0=0 a1=2792 a2=1 a3=1 items=0 ppid=902 pid=905 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="sh" exe="/usr/bin/bash" subj=system_u:system_r:loadkeys_t:s0 key=(null)
Dec 21 21:37:26 wolff.to kernel: kauditd_printk_skb: 68 callbacks suppressed
Dec 21 21:37:26 wolff.to kernel: audit: type=1130 audit(1513913838.491:119): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=systemd-udevd comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 21 21:37:26 wolff.to kernel: i801_smbus 0000:00:1f.3: SMBus using polling
Dec 21 21:37:26 wolff.to kernel: intel_rng: FWH not detected
Dec 21 21:37:26 wolff.to kernel: parport_pc 00:06: reported by Plug and Play ACPI
Dec 21 21:37:26 wolff.to kernel: parport0: PC-style at 0x378 (0x778), irq 7 [PCSPP,TRISTATE,EPP]
Dec 21 21:37:26 wolff.to kernel: [drm] VGACON disable radeon kernel modesetting.
Dec 21 21:37:26 wolff.to kernel: [drm:radeon_init [radeon]] *ERROR* No UMS support in radeon module!
Dec 21 21:37:26 wolff.to kernel: snd_intel8x0 0000:00:1f.5: intel8x0_measure_ac97_clock: measured 52000 usecs (2506 samples)
Dec 21 21:37:26 wolff.to kernel: snd_intel8x0 0000:00:1f.5: clocking to 48000
Dec 21 21:37:26 wolff.to kernel: e1000 0000:05:03.0 eth0: renamed from enp5s3
Dec 21 21:37:26 wolff.to kernel: ppdev: user-space parallel port driver
Dec 21 21:37:26 wolff.to kernel: iTCO_vendor_support: vendor-support=0
Dec 21 21:37:26 wolff.to kernel: iTCO_wdt: Intel TCO WatchDog Timer Driver v1.11
Dec 21 21:37:26 wolff.to kernel: iTCO_wdt: Found a ICH4 TCO device (Version=1, TCOBASE=0x1060)
Dec 21 21:37:26 wolff.to kernel: iTCO_wdt: initialized. heartbeat=30 sec (nowayout=0)
Dec 21 21:37:26 wolff.to kernel: netpoll: netconsole: local port 6665
Dec 21 21:37:26 wolff.to kernel: netpoll: netconsole: local IPv4 address 98.103.208.27
Dec 21 21:37:26 wolff.to kernel: netpoll: netconsole: interface 'eth0'
Dec 21 21:37:26 wolff.to kernel: netpoll: netconsole: remote port 6666
Dec 21 21:37:26 wolff.to kernel: netpoll: netconsole: remote IPv4 address 98.103.208.28
Dec 21 21:37:26 wolff.to kernel: netpoll: netconsole: remote ethernet address ff:ff:ff:ff:ff:ff
Dec 21 21:37:26 wolff.to kernel: netpoll: netconsole: device eth0 not up yet, forcing it
Dec 21 21:37:26 wolff.to kernel: IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
Dec 21 21:37:26 wolff.to kernel: e1000: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX
Dec 21 21:37:26 wolff.to kernel: IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
Dec 21 21:37:26 wolff.to kernel: netpoll: netconsole: carrier detect appears untrustworthy, waiting 4 seconds
Dec 21 21:37:26 wolff.to kernel: WARNING: CPU: 1 PID: 991 at block/genhd.c:680 device_add_disk+0x3a0/0x420
Dec 21 21:37:26 wolff.to kernel: Modules linked in: netconsole(+) iTCO_wdt iTCO_vendor_support ppdev snd_intel8x0 lpc_ich snd_ac97_codec parport_pc ac97_bus i2c_i801 e7xxx_edac parport binfmt_misc snd_pcm_oss snd_mixer_oss dm_crypt raid1 i2c_algo_bit drm_kms_helper syscopyarea sysfillrect sysimgblt mptspi fb_sys_fops ttm scsi_transport_spi mptscsih ata_generic serio_raw drm e1000 pata_acpi mptbase snd_pcm snd_timer snd soundcore analog gameport joydev
Dec 21 21:37:26 wolff.to kernel: CPU: 1 PID: 991 Comm: mdadm Not tainted 4.15.0-0.rc4.git1.2.fc28.i686 #1
Dec 21 21:37:26 wolff.to kernel: Hardware name: Hewlett-Packard hp workstation xw8000/0844, BIOS JQ.W1.19US      04/13/05
Dec 21 21:37:26 wolff.to kernel: EIP: device_add_disk+0x3a0/0x420
Dec 21 21:37:26 wolff.to kernel: EFLAGS: 00010282 CPU: 1
Dec 21 21:37:26 wolff.to kernel: EAX: fffffff4 EBX: f6388800 ECX: 820001fd EDX: 820001fe
Dec 21 21:37:26 wolff.to kernel: ESI: f638885c EDI: 00000000 EBP: f22a7d38 ESP: f22a7d10
Dec 21 21:37:26 wolff.to kernel:  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
Dec 21 21:37:26 wolff.to kernel: CR0: 80050033 CR2: 004c8014 CR3: 323d3000 CR4: 000006d0
Dec 21 21:37:26 wolff.to kernel: Call Trace:
Dec 21 21:37:26 wolff.to kernel:  md_alloc+0x185/0x340
Dec 21 21:37:26 wolff.to kernel:  ? md_alloc+0x340/0x340
Dec 21 21:37:26 wolff.to kernel:  md_probe+0x22/0x30
Dec 21 21:37:26 wolff.to kernel:  kobj_lookup+0xd0/0x130
Dec 21 21:37:26 wolff.to kernel:  ? md_alloc+0x340/0x340
Dec 21 21:37:26 wolff.to kernel:  get_gendisk+0x26/0xf0
Dec 21 21:37:27 wolff.to kernel:  blkdev_get+0x55/0x2c0
Dec 21 21:37:27 wolff.to kernel:  ? unlock_new_inode+0x33/0x50
Dec 21 21:37:27 wolff.to kernel:  blkdev_open+0x7d/0x90
Dec 21 21:37:27 wolff.to kernel:  do_dentry_open+0x1a9/0x2d0
Dec 21 21:37:27 wolff.to kernel:  ? bd_acquire+0xb0/0xb0
Dec 21 21:37:27 wolff.to kernel:  vfs_open+0x41/0x70
Dec 21 21:37:27 wolff.to kernel:  path_openat+0x560/0x11e0
Dec 21 21:37:27 wolff.to kernel:  do_filp_open+0x6a/0xd0
Dec 21 21:37:27 wolff.to kernel:  ? __alloc_fd+0x2e/0x150
Dec 21 21:37:27 wolff.to kernel:  do_sys_open+0x1b5/0x250
Dec 21 21:37:27 wolff.to kernel:  SyS_openat+0x1b/0x20
Dec 21 21:37:27 wolff.to kernel:  do_fast_syscall_32+0x71/0x1a0
Dec 21 21:37:27 wolff.to kernel:  entry_SYSENTER_32+0x4e/0x7c
Dec 21 21:37:27 wolff.to kernel: EIP: 0xb7fb9cd9
Dec 21 21:37:27 wolff.to kernel: EFLAGS: 00000246 CPU: 1
Dec 21 21:37:27 wolff.to kernel: EAX: ffffffda EBX: ffffff9c ECX: bf9adadc EDX: 0000c082
Dec 21 21:37:27 wolff.to kernel: ESI: 00000000 EDI: 00000000 EBP: bf9adadc ESP: bf9ada60
Dec 21 21:37:27 wolff.to kernel:  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
Dec 21 21:37:27 wolff.to kernel: Code: 0f ff e9 fe fd ff ff 8d 74 26 00 80 a3 84 00 00 00 ef e9 ee fd ff ff 8d 74 26 00 0f ff e9 fd fd ff ff 89 f6 8d bc 27 00 00 00 00 <0f> ff e9 bd fe ff ff 31 d2 89 d8 e8 50 ef ff ff 85 c0 89 c6 0f
Dec 21 21:37:27 wolff.to kernel: ---[ end trace 0b0feb86adcc7001 ]---
Dec 21 21:37:27 wolff.to kernel: BUG: unable to handle kernel NULL pointer dereference at 00000020
Dec 21 21:37:27 wolff.to kernel: IP: sysfs_do_create_link_sd.isra.2+0x27/0xb0
Dec 21 21:37:27 wolff.to kernel: *pde = 00000000 
Dec 21 21:37:27 wolff.to kernel: Oops: 0000 [#1] SMP
Dec 21 21:37:27 wolff.to kernel: Modules linked in: netconsole(+) iTCO_wdt iTCO_vendor_support ppdev snd_intel8x0 lpc_ich snd_ac97_codec parport_pc ac97_bus i2c_i801 e7xxx_edac parport binfmt_misc snd_pcm_oss snd_mixer_oss dm_crypt raid1 i2c_algo_bit drm_kms_helper syscopyarea sysfillrect sysimgblt mptspi fb_sys_fops ttm scsi_transport_spi mptscsih ata_generic serio_raw drm e1000 pata_acpi mptbase snd_pcm snd_timer snd soundcore analog gameport joydev
Dec 21 21:37:27 wolff.to kernel: CPU: 3 PID: 991 Comm: mdadm Tainted: G        W        4.15.0-0.rc4.git1.2.fc28.i686 #1
Dec 21 21:37:27 wolff.to kernel: Hardware name: Hewlett-Packard hp workstation xw8000/0844, BIOS JQ.W1.19US      04/13/05
Dec 21 21:37:27 wolff.to kernel: EIP: sysfs_do_create_link_sd.isra.2+0x27/0xb0
Dec 21 21:37:27 wolff.to kernel: EFLAGS: 00010246 CPU: 3
Dec 21 21:37:27 wolff.to kernel: EAX: 00000000 EBX: ca1dadc7 ECX: 00000001 EDX: ca4f464c
Dec 21 21:37:27 wolff.to kernel: ESI: 00000020 EDI: f6388864 EBP: f22a7cfc ESP: f22a7cec
Dec 21 21:37:27 wolff.to kernel:  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
Dec 21 21:37:27 wolff.to kernel: CR0: 80050033 CR2: 00680ef0 CR3: 323d3000 CR4: 000006d0
Dec 21 21:37:27 wolff.to kernel: Call Trace:
Dec 21 21:37:27 wolff.to kernel:  sysfs_create_link+0x1d/0x40
Dec 21 21:37:27 wolff.to kernel:  device_add_disk+0x36d/0x420
Dec 21 21:37:27 wolff.to kernel:  md_alloc+0x185/0x340
Dec 21 21:37:27 wolff.to kernel:  ? md_alloc+0x340/0x340
Dec 21 21:37:28 wolff.to kernel:  md_probe+0x22/0x30
Dec 21 21:37:28 wolff.to kernel:  kobj_lookup+0xd0/0x130
Dec 21 21:37:28 wolff.to kernel:  ? md_alloc+0x340/0x340
Dec 21 21:37:28 wolff.to kernel:  get_gendisk+0x26/0xf0
Dec 21 21:37:28 wolff.to kernel:  blkdev_get+0x55/0x2c0
Dec 21 21:37:28 wolff.to kernel:  ? unlock_new_inode+0x33/0x50
Dec 21 21:37:28 wolff.to kernel:  blkdev_open+0x7d/0x90
Dec 21 21:37:28 wolff.to kernel:  do_dentry_open+0x1a9/0x2d0
Dec 21 21:37:28 wolff.to kernel:  ? bd_acquire+0xb0/0xb0
Dec 21 21:37:28 wolff.to kernel:  vfs_open+0x41/0x70

--BOKacYhQ+x31HxR3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
