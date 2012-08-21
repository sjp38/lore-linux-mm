Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id B91986B0068
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 07:58:22 -0400 (EDT)
Message-ID: <50337722.3040908@parallels.com>
Date: Tue, 21 Aug 2012 15:55:14 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: C12 [12/19] Move kmem_cache allocations into common code.
References: <20120820204021.494276880@linux.com> <0000013945cd2d87-d71d0827-51b3-4c98-890f-12beb8ecc72b-000000@email.amazonses.com>
In-Reply-To: <0000013945cd2d87-d71d0827-51b3-4c98-890f-12beb8ecc72b-000000@email.amazonses.com>
Content-Type: multipart/mixed;
	boundary="------------060408080708080904020203"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

--------------060408080708080904020203
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit

On 08/21/2012 12:50 AM, Christoph Lameter wrote:
> Shift the allocations to common code. That way the allocation
> and freeing of the kmem_cache structures is handled by common code.
> 
> V2->V3: Use GFP_KERNEL instead of GFP_NOWAIT (JoonSoo Kim).
> V1->V2: Use the return code from setup_cpucache() in slab instead of returning -ENOSPC
> 
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

Doesn't boot (SLUB + debug options)

dmesg attached.




--------------060408080708080904020203
Content-Type: text/plain; charset="UTF-8"; name="bisect"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="bisect"

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.6.0-rc1+ (glauber@straightjacket.localdomain) (gcc version 4.7.0 20120507 (Red Hat 4.7.0-5) (GCC) ) #458 SMP Tue Aug 21 15:39:36 MSK 2012
[    0.000000] Command line: ro root=/dev/mapper/vg_containers2-lv_root console=ttyS0 earlyprintk=ttyS0 selinux=0 slub_nomerge=1
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009f3ff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009f400-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000003fffdfff] usable
[    0.000000] BIOS-e820: [mem 0x000000003fffe000-0x000000003fffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] DMI 2.4 present.
[    0.000000] Hypervisor detected: KVM
[    0.000000] No AGP bridge found
[    0.000000] e820: last_pfn = 0x3fffe max_arch_pfn = 0x400000000
[    0.000000] PAT not supported by CPU.
[    0.000000] found SMP MP-table at [mem 0x000fdb00-0x000fdb0f] mapped at [ffff8800000fdb00]
[    0.000000] init_memory_mapping: [mem 0x00000000-0x3fffdfff]
[    0.000000] RAMDISK: [mem 0x3ece8000-0x3ffeffff]
[    0.000000] ACPI: RSDP 00000000000fd9a0 00014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 000000003fffe5d0 00038 (v01 BOCHS  BXPCRSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: FACP 000000003fffff80 00074 (v01 BOCHS  BXPCFACP 00000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 000000003fffe610 01109 (v01   BXPC   BXDSDT 00000001 INTL 20100528)
[    0.000000] ACPI: FACS 000000003fffff40 00040
[    0.000000] ACPI: SSDT 000000003ffffea0 0009E (v01 BOCHS  BXPCSSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: APIC 000000003ffffdb0 00078 (v01 BOCHS  BXPCAPIC 00000001 BXPC 00000001)
[    0.000000] ACPI: HPET 000000003ffffd70 00038 (v01 BOCHS  BXPCHPET 00000001 BXPC 00000001)
[    0.000000] ACPI: SSDT 000000003ffff720 00644 (v01   BXPC BXSSDTPC 00000001 INTL 20100528)
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at [mem 0x0000000000000000-0x000000003fffdfff]
[    0.000000] Initmem setup node 0 [mem 0x00000000-0x3fffdfff]
[    0.000000]   NODE_DATA [mem 0x3ecd3000-0x3ece7fff]
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:1b08181, boot clock
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00010000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00010000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x3fffdfff]
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x01] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 1, version 17, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] smpboot: Allowing 1 CPUs, 0 hotplug CPUs
[    0.000000] PM: Registered nosave memory: 000000000009f000 - 00000000000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 00000000000f0000
[    0.000000] PM: Registered nosave memory: 00000000000f0000 - 0000000000100000
[    0.000000] e820: [mem 0x40000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] setup_percpu: NR_CPUS:256 nr_cpumask_bits:256 nr_cpu_ids:1 nr_node_ids:1
[    0.000000] PERCPU: Embedded 28 pages/cpu @ffff88003ea00000 s86016 r8192 d20480 u2097152
[    0.000000] kvm-clock: cpu 0, msr 0:3ea14181, primary cpu clock
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 3ea0dfc0
[    0.000000] Built 1 zonelists in Node order, mobility grouping on.  Total pages: 257927
[    0.000000] Policy zone: DMA32
[    0.000000] Kernel command line: ro root=/dev/mapper/vg_containers2-lv_root console=ttyS0 earlyprintk=ttyS0 selinux=0 slub_nomerge=1
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] __ex_table already sorted, skipping sort
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Memory: 989028k/1048568k available (5318k kernel code, 452k absent, 59088k reserved, 5892k data, 944k init)
[    0.000000] SLUB: Genslabs=15, HWalign=64, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
[    0.000000] Hierarchical RCU implementation.
[    0.000000] 	RCU dyntick-idle grace-period acceleration is enabled.
[    0.000000] 	RCU lockdep checking is enabled.
[    0.000000] 	RCU restricting CPUs from NR_CPUS=256 to nr_cpu_ids=1.
[    0.000000] NR_IRQS:16640 nr_irqs:256 16
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [ttyS0] enabled, bootconsole disabled
[    0.000000] console [ttyS0] enabled, bootconsole disabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     16384
[    0.000000] ... MAX_LOCKDEP_CHAINS:      32768
[    0.000000] ... CHAINHASH_SIZE:          16384
[    0.000000]  memory used by lock dependency info: 5855 kB
[    0.000000]  per task-struct memory footprint: 1920 bytes
[    0.000000] allocated 4194304 bytes of page_cgroup
[    0.000000] please try 'cgroup_disable=memory' option if you don't want memory cgroups
[    0.000000] tsc: Detected 2691.258 MHz processor
[    0.000999] Calibrating delay loop (skipped) preset value.. 5382.51 BogoMIPS (lpj=2691258)
[    0.002024] pid_max: default: 32768 minimum: 301
[    0.003419] Security Framework initialized
[    0.004039] SELinux:  Disabled at boot.
[    0.005552] Dentry cache hash table entries: 131072 (order: 8, 1048576 bytes)
[    0.008290] Inode-cache hash table entries: 65536 (order: 7, 524288 bytes)
[    0.009148] Mount-cache hash table entries: 256
[    0.012203] Initializing cgroup subsys cpuacct
[    0.013004] Initializing cgroup subsys memory
[    0.014137] Initializing cgroup subsys devices
[    0.015012] Initializing cgroup subsys freezer
[    0.016008] Initializing cgroup subsys net_cls
[    0.017008] Initializing cgroup subsys blkio
[    0.017884] Initializing cgroup subsys perf_event
[    0.019222] mce: CPU supports 10 MCE banks
[    0.020059] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.020059] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.020059] tlb_flushall_shift is 0x6
[    0.021203] SMP alternatives: switching to UP code
[    0.030146] Freeing SMP alternatives: 12k freed
[    0.031023] ACPI: Core revision 20120711
[    0.060905] ftrace: allocating 23588 entries in 93 pages
[    0.068958] ..TIMER: vector=0x51 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.069014] smpboot: CPU0: Intel QEMU Virtual CPU version 1.0,1 stepping 03
[    0.070989] Performance Events: unsupported p6 CPU model 2 no PMU driver, software events only.
[    0.073953] NMI watchdog: disabled (cpu0): hardware events not enabled
[    0.074095] Brought up 1 CPUs
[    0.074992] smpboot: Total of 1 processors activated (5382.51 BogoMIPS)
[    0.077574] devtmpfs: initialized
[    0.085311] atomic64 test passed for x86-64 platform with CX8 and with SSE
[    0.086144] RTC time: 11:46:05, date: 08/21/12
[    0.088235] NET: Registered protocol family 16
[    0.090576] ACPI: bus type pci registered
[    0.091419] PCI: Using configuration type 1 for base access
[    0.109228] bio: create slab <bio-0> at 0
[    0.111496] ACPI: Added _OSI(Module Device)
[    0.112002] ACPI: Added _OSI(Processor Device)
[    0.112995] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.113995] ACPI: Added _OSI(Processor Aggregator Device)
[    0.165137] ACPI: Interpreter enabled
[    0.165912] ACPI: (supports S0 S5)
[    0.166313] ACPI: Using IOAPIC for interrupt routing
[    0.235666] ACPI: No dock devices found.
[    0.235970] PCI: Ignoring host bridge windows from ACPI; if necessary, use "pci=use_crs" and report a bug
[    0.238158] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.240220] pci_root PNP0A03:00: fail to add MMCONFIG information, can't access extended PCI configuration space under this bridge.
[    0.243066] PCI host bridge to bus 0000:00
[    0.243908] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.244974] pci_bus 0000:00: root bus resource [io  0x0000-0xffff]
[    0.245973] pci_bus 0000:00: root bus resource [mem 0x00000000-0xffffffffff]
[    0.249577] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX4 ACPI
[    0.250976] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX4 SMB
[    0.274107]  pci0000:00: Unable to request _OSC control (_OSC support mask: 0x1e)
[    0.360828] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    0.363261] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    0.365675] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    0.368069] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    0.370355] ACPI: PCI Interrupt Link [LNKS] (IRQs 9) *0
[    0.372709] vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
[    0.373963] vgaarb: loaded
[    0.374510] vgaarb: bridge control possible 0000:00:02.0
[    0.377298] SCSI subsystem initialized
[    0.377957] ACPI: bus type scsi registered
[    0.379422] ACPI: bus type usb registered
[    0.380170] usbcore: registered new interface driver usbfs
[    0.381053] usbcore: registered new interface driver hub
[    0.383000] usbcore: registered new device driver usb
[    0.384537] PCI: Using ACPI for IRQ routing
[    0.386912] NetLabel: Initializing
[    0.386946] NetLabel:  domain hash size = 128
[    0.387944] NetLabel:  protocols = UNLABELED CIPSOv4
[    0.389149] NetLabel:  unlabeled traffic allowed by default
[    0.391105] HPET: 3 timers in total, 0 timers will be used for per-cpu timer
[    0.391972] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    0.393258] hpet0: 3 comparators, 64-bit 100.000000 MHz counter
[    0.401253] Switching to clocksource kvm-clock
[    0.496759] pnp: PnP ACPI init
[    0.497559] ACPI: bus type pnp registered
[    0.508614] pnp: PnP ACPI: found 8 devices
[    0.509447] ACPI: ACPI bus type pnp unregistered
[    0.532429] NET: Registered protocol family 2
[    0.536319] TCP established hash table entries: 131072 (order: 9, 2097152 bytes)
[    0.539439] TCP bind hash table entries: 65536 (order: 10, 4194304 bytes)
[    0.546053] TCP: Hash tables configured (established 131072 bind 65536)
[    0.547476] TCP: reno registered
[    0.548181] UDP hash table entries: 512 (order: 4, 81920 bytes)
[    0.549471] UDP-Lite hash table entries: 512 (order: 4, 81920 bytes)
[    0.551302] NET: Registered protocol family 1
[    0.552722] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    0.553997] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    0.555193] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    0.557260] Trying to unpack rootfs image as initramfs...
[    1.067172] Freeing initrd memory: 19488k freed
[    1.076310] audit: initializing netlink socket (disabled)
[    1.077649] type=2000 audit(1345549567.076:1): initialized
[    1.099820] cryptomgr_test (22) used greatest stack depth: 6432 bytes left
[    1.103701] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    1.136261] kobject (ffff88003e405038): tried to init an initialized object, something is seriously wrong.
[    1.138378] Pid: 1, comm: swapper/0 Not tainted 3.6.0-rc1+ #458
[    1.139725] Call Trace:
[    1.140310]  [<ffffffff8127a1f7>] kobject_init+0x33/0x83
[    1.141505]  [<ffffffff8127a4cc>] kobject_init_and_add+0x23/0x7d
[    1.142795]  [<ffffffff811a7791>] ? sysfs_addrm_finish+0x1b/0x4d
[    1.144053]  [<ffffffff811a5edc>] ? sysfs_hash_and_remove+0x7b/0x8f
[    1.145313]  [<ffffffff81138718>] sysfs_slab_add+0x113/0x17b
[    1.146461]  [<ffffffff81b2c1b9>] ? kmem_cache_init_late+0x6/0x6
[    1.147758]  [<ffffffff81b2c232>] slab_sysfs_init+0x79/0xf8
[    1.148890]  [<ffffffff81002099>] do_one_initcall+0x7f/0x13a
[    1.150029]  [<ffffffff81b09d0e>] kernel_init+0x157/0x1db
[    1.151120]  [<ffffffff81b09590>] ? do_early_param+0x8c/0x8c
[    1.152267]  [<ffffffff8152ef84>] kernel_thread_helper+0x4/0x10
[    1.153469]  [<ffffffff815271b0>] ? retint_restore_args+0x13/0x13
[    1.154695]  [<ffffffff81b09bb7>] ? start_kernel+0x3d5/0x3d5
[    1.155844]  [<ffffffff8152ef80>] ? gs_change+0x13/0x13
[    1.156953] general protection fault: 0000 [#1] SMP 
[    1.157929] Modules linked in:
[    1.157929] CPU 0 
[    1.157929] Pid: 1, comm: swapper/0 Not tainted 3.6.0-rc1+ #458 Bochs Bochs
[    1.157929] RIP: 0010:[<ffffffff81133ade>]  [<ffffffff81133ade>] virt_to_head_page+0x1e/0x2c
[    1.157929] RSP: 0018:ffff88003ce3bd60  EFLAGS: 00010203
[    1.157929] RAX: 01ad998dadadad80 RBX: 6b6b6b6b6b6b6b6b RCX: 0000000000000000
[    1.157929] RDX: ffffea0000000000 RSI: 000000000000002f RDI: 6b6b6b6b6b6b6b6b
[    1.157929] RBP: ffff88003ce3bd60 R08: 0000000000000010 R09: 00000001000b0008
[    1.157929] R10: ffff88003ea0b000 R11: ffff88003ea0b000 R12: 6b6b6b6b6b6b6b6b
[    1.157929] R13: ffffffff8127a49b R14: 0000000000000001 R15: 0000000000000000
[    1.157929] FS:  0000000000000000(0000) GS:ffff88003ea00000(0000) knlGS:0000000000000000
[    1.157929] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[    1.157929] CR2: 0000000000000000 CR3: 0000000001a0b000 CR4: 00000000000006f0
[    1.157929] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[    1.157929] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[    1.157929] Process swapper/0 (pid: 1, threadinfo ffff88003ce3a000, task ffff88003ce98000)
[    1.157929] Stack:
[    1.157929]  ffff88003ce3bd90 ffffffff811363a6 ffff88003e405038 6b6b6b6b6b6b6b6b
[    1.157929]  0000000000000000 0000000000000001 ffff88003ce3bdb0 ffffffff8127a49b
[    1.157929]  ffff88003e405038 ffff88003e409ca8 ffff88003ce3be30 ffffffff8127a4f2
[    1.157929] Call Trace:
[    1.157929]  [<ffffffff811363a6>] kfree+0x4c/0x111
[    1.157929]  [<ffffffff8127a49b>] kobject_set_name_vargs+0x48/0x56
[    1.157929]  [<ffffffff8127a4f2>] kobject_init_and_add+0x49/0x7d
[    1.157929]  [<ffffffff811a5edc>] ? sysfs_hash_and_remove+0x7b/0x8f
[    1.157929]  [<ffffffff81138718>] sysfs_slab_add+0x113/0x17b
[    1.157929]  [<ffffffff81b2c1b9>] ? kmem_cache_init_late+0x6/0x6
[    1.157929]  [<ffffffff81b2c232>] slab_sysfs_init+0x79/0xf8
[    1.157929]  [<ffffffff81002099>] do_one_initcall+0x7f/0x13a
[    1.157929]  [<ffffffff81b09d0e>] kernel_init+0x157/0x1db
[    1.157929]  [<ffffffff81b09590>] ? do_early_param+0x8c/0x8c
[    1.157929]  [<ffffffff8152ef84>] kernel_thread_helper+0x4/0x10
[    1.157929]  [<ffffffff815271b0>] ? retint_restore_args+0x13/0x13
[    1.157929]  [<ffffffff81b09bb7>] ? start_kernel+0x3d5/0x3d5
[    1.157929]  [<ffffffff8152ef80>] ? gs_change+0x13/0x13
[    1.157929] Code: f9 03 48 89 e5 48 83 e1 f8 f3 aa 5d c3 55 48 89 e5 e8 ef 6c f0 ff 48 c1 e8 0c 48 ba 00 00 00 00 00 ea ff ff 48 c1 e0 06 48 01 d0 <48> 8b 10 80 e6 80 74 04 48 8b 40 30 5d c3 55 48 89 e5 53 50 66 
[    1.157929] RIP  [<ffffffff81133ade>] virt_to_head_page+0x1e/0x2c
[    1.157929]  RSP <ffff88003ce3bd60>
[    1.209925] ---[ end trace b5f25d4895b83fbe ]---
[    1.210893] swapper/0 (1) used greatest stack depth: 3824 bytes left
[    1.212195] Kernel panic - not syncing: Attempted to kill init! exitcode=0x0000000b
[    1.212195] 

--------------060408080708080904020203--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
