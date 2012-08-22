Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id BB3156B005D
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 05:30:05 -0400 (EDT)
Message-ID: <5034A5E0.4040702@parallels.com>
Date: Wed, 22 Aug 2012 13:26:56 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: C12 [16/19] Create common functions for boot slab creation
References: <20120820204021.494276880@linux.com> <0000013945cd3433-333c73bf-d671-4896-9e40-8735ef8f856d-000000@email.amazonses.com>
In-Reply-To: <0000013945cd3433-333c73bf-d671-4896-9e40-8735ef8f856d-000000@email.amazonses.com>
Content-Type: multipart/mixed;
	boundary="------------030308020203010601020805"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

--------------030308020203010601020805
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit

On 08/21/2012 12:50 AM, Christoph Lameter wrote:
> Use a special function to create kmalloc caches and use that function in
> SLAB and SLUB.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> ---
>  mm/slab.c        |   48 ++++++++++++++----------------------------------
>  mm/slab.h        |    5 +++++
>  mm/slab_common.c |   32 ++++++++++++++++++++++++++++++++
>  mm/slub.c        |   36 +++---------------------------------
>  4 files changed, 54 insertions(+), 67 deletions(-)
> 
>
Doesn't boot, dmesg attached.
Issue seems to be fixed in the next patch.

By the way, the problem I described with my use case starts happening in
one of them, either 16 or 17. But since I cannot boot this one, I can't
tell which one is the culprit.




--------------030308020203010601020805
Content-Type: text/plain; charset="UTF-8"; name="noboot"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="noboot"

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.6.0-rc1+ (glauber@straightjacket.localdomain) (gcc version 4.7.0 20120507 (Red Hat 4.7.0-5) (GCC) ) #464 SMP Wed Aug 22 12:57:47 MSK 2012
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
[    0.000000] Memory: 989024k/1048568k available (5318k kernel code, 452k absent, 59092k reserved, 5892k data, 948k init)
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
[    0.001568] pid_max: default: 32768 minimum: 301
[    0.002394] Security Framework initialized
[    0.003014] SELinux:  Disabled at boot.
[    0.003999] Dentry cache hash table entries: 131072 (order: 8, 1048576 bytes)
[    0.005365] Inode-cache hash table entries: 65536 (order: 7, 524288 bytes)
[    0.006260] Mount-cache hash table entries: 256
[    0.009292] Initializing cgroup subsys cpuacct
[    0.010005] Initializing cgroup subsys memory
[    0.010998] Initializing cgroup subsys devices
[    0.011016] Initializing cgroup subsys freezer
[    0.011905] Initializing cgroup subsys net_cls
[    0.011998] Initializing cgroup subsys blkio
[    0.012008] Initializing cgroup subsys perf_event
[    0.012998] mce: CPU supports 10 MCE banks
[    0.012998] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.012998] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.012998] tlb_flushall_shift is 0x6
[    0.013200] SMP alternatives: switching to UP code
[    0.021661] Freeing SMP alternatives: 12k freed
[    0.022016] ACPI: Core revision 20120711
[    0.052554] ftrace: allocating 23587 entries in 93 pages
[    0.061383] ..TIMER: vector=0x51 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.062017] smpboot: CPU0: Intel QEMU Virtual CPU version 1.0,1 stepping 03
[    0.064990] Performance Events: unsupported p6 CPU model 2 no PMU driver, software events only.
[    0.068076] NMI watchdog: disabled (cpu0): hardware events not enabled
[    0.069101] Brought up 1 CPUs
[    0.069995] smpboot: Total of 1 processors activated (5382.51 BogoMIPS)
[    0.072679] devtmpfs: initialized
[    0.080715] atomic64 test passed for x86-64 platform with CX8 and with SSE
[    0.082253] RTC time:  9:24:15, date: 08/22/12
[    0.084280] NET: Registered protocol family 16
[    0.087400] ACPI: bus type pci registered
[    0.088992] PCI: Using configuration type 1 for base access
[    0.110342] bio: create slab <bio-0> at 0
[    0.113264] ACPI: Added _OSI(Module Device)
[    0.115020] ACPI: Added _OSI(Processor Device)
[    0.117016] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.119022] ACPI: Added _OSI(Processor Aggregator Device)
[    0.183830] ACPI: Interpreter enabled
[    0.184985] ACPI: (supports S0 S5)
[    0.186258] ACPI: Using IOAPIC for interrupt routing
[    0.260306] ACPI: No dock devices found.
[    0.260977] PCI: Ignoring host bridge windows from ACPI; if necessary, use "pci=use_crs" and report a bug
[    0.263290] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.265253] pci_root PNP0A03:00: fail to add MMCONFIG information, can't access extended PCI configuration space under this bridge.
[    0.268263] PCI host bridge to bus 0000:00
[    0.268984] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.269980] pci_bus 0000:00: root bus resource [io  0x0000-0xffff]
[    0.270973] pci_bus 0000:00: root bus resource [mem 0x00000000-0xffffffffff]
[    0.275162] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX4 ACPI
[    0.275984] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX4 SMB
[    0.300646]  pci0000:00: Unable to request _OSC control (_OSC support mask: 0x1e)
[    0.392717] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    0.395167] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    0.397647] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    0.400097] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    0.402361] ACPI: PCI Interrupt Link [LNKS] (IRQs 9) *0
[    0.404785] vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
[    0.405963] vgaarb: loaded
[    0.406942] vgaarb: bridge control possible 0000:00:02.0
[    0.409443] SCSI subsystem initialized
[    0.409953] ACPI: bus type scsi registered
[    0.411592] ACPI: bus type usb registered
[    0.412948] usbcore: registered new interface driver usbfs
[    0.414118] usbcore: registered new interface driver hub
[    0.415261] usbcore: registered new device driver usb
[    0.418028] PCI: Using ACPI for IRQ routing
[    0.420991] NetLabel: Initializing
[    0.421899] NetLabel:  domain hash size = 128
[    0.421943] NetLabel:  protocols = UNLABELED CIPSOv4
[    0.424183] NetLabel:  unlabeled traffic allowed by default
[    0.425119] HPET: 3 timers in total, 0 timers will be used for per-cpu timer
[    0.426966] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    0.428139] hpet0: 3 comparators, 64-bit 100.000000 MHz counter
[    0.432413] Switching to clocksource kvm-clock
[    0.533735] pnp: PnP ACPI init
[    0.534607] ACPI: bus type pnp registered
[    0.547059] pnp: PnP ACPI: found 8 devices
[    0.548520] ACPI: ACPI bus type pnp unregistered
[    0.570681] NET: Registered protocol family 2
[    0.572612] TCP established hash table entries: 131072 (order: 9, 2097152 bytes)
[    0.575192] TCP bind hash table entries: 65536 (order: 10, 4194304 bytes)
[    0.581814] TCP: Hash tables configured (established 131072 bind 65536)
[    0.583261] TCP: reno registered
[    0.583959] UDP hash table entries: 512 (order: 4, 81920 bytes)
[    0.585252] UDP-Lite hash table entries: 512 (order: 4, 81920 bytes)
[    0.587088] NET: Registered protocol family 1
[    0.588445] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    0.589642] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    0.590824] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    0.592623] Trying to unpack rootfs image as initramfs...
[    1.098979] Freeing initrd memory: 19488k freed
[    1.108153] audit: initializing netlink socket (disabled)
[    1.109058] type=2000 audit(1345627457.108:1): initialized
[    1.130679] cryptomgr_test (22) used greatest stack depth: 6432 bytes left
[    1.133566] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    1.174431] kobject (ffff88003e400078): tried to init an initialized object, something is seriously wrong.
[    1.176270] Pid: 1, comm: swapper/0 Not tainted 3.6.0-rc1+ #464
[    1.177446] Call Trace:
[    1.177943]  [<ffffffff8127a1c7>] kobject_init+0x33/0x83
[    1.179023]  [<ffffffff8127a49c>] kobject_init_and_add+0x23/0x7d
[    1.180231]  [<ffffffff811a7761>] ? sysfs_addrm_finish+0x1b/0x4d
[    1.181426]  [<ffffffff811a5eac>] ? sysfs_hash_and_remove+0x7b/0x8f
[    1.182673]  [<ffffffff811386e9>] sysfs_slab_add+0x112/0x179
[    1.183802]  [<ffffffff81b2c219>] ? kmem_cache_init_late+0x6/0x6
[    1.184999]  [<ffffffff81b2c292>] slab_sysfs_init+0x79/0xf8
[    1.186188]  [<ffffffff81b2c219>] ? kmem_cache_init_late+0x6/0x6
[    1.187306]  [<ffffffff81002099>] do_one_initcall+0x7f/0x13a
[    1.188429]  [<ffffffff81b09d0e>] kernel_init+0x157/0x1db
[    1.189507]  [<ffffffff81b09590>] ? do_early_param+0x8c/0x8c
[    1.190638]  [<ffffffff8152ef44>] kernel_thread_helper+0x4/0x10
[    1.191815]  [<ffffffff81527170>] ? retint_restore_args+0x13/0x13
[    1.193019]  [<ffffffff81b09bb7>] ? start_kernel+0x3d5/0x3d5
[    1.194133]  [<ffffffff8152ef40>] ? gs_change+0x13/0x13
[    1.195510] BUG: unable to handle kernel paging request at 00000001000e000e
[    1.196158] IP: [<ffffffff811a6e72>] sysfs_name_hash+0x17/0x7b
[    1.196158] PGD 0 
[    1.196158] Oops: 0000 [#1] SMP 
[    1.196158] Modules linked in:
[    1.196158] CPU 0 
[    1.196158] Pid: 1, comm: swapper/0 Not tainted 3.6.0-rc1+ #464 Bochs Bochs
[    1.196158] RIP: 0010:[<ffffffff811a6e72>]  [<ffffffff811a6e72>] sysfs_name_hash+0x17/0x7b
[    1.196158] RSP: 0018:ffff88003ce3bdb0  EFLAGS: 00010246
[    1.196158] RAX: 0000000000000000 RBX: ffff8800383a3480 RCX: ffffffffffffffff
[    1.196158] RDX: 0000000000000000 RSI: 00000001000e000e RDI: 00000001000e000e
[    1.196158] RBP: ffff88003ce3bdb0 R08: ffff88003ce3bd50 R09: 0000000000000000
[    1.196158] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000000
[    1.196158] R13: 00000001000e000e R14: 0000000000000001 R15: 0000000000000000
[    1.196158] FS:  0000000000000000(0000) GS:ffff88003ea00000(0000) knlGS:0000000000000000
[    1.196158] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[    1.196158] CR2: 00000001000e000e CR3: 0000000001a0b000 CR4: 00000000000006f0
[    1.196158] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[    1.196158] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[    1.196158] Process swapper/0 (pid: 1, threadinfo ffff88003ce3a000, task ffff88003ce98000)
[    1.196158] Stack:
[    1.196158]  ffff88003ce3bde0 ffffffff811a78e8 ffff8800383a2938 0000000000000000
[    1.196158]  0000000000000000 0000000000000001 ffff88003ce3be20 ffffffff811a5e8f
[    1.196158]  ffff8800383a6048 00000001000e000e ffff8800383a2938 0000000000000000
[    1.196158] Call Trace:
[    1.196158]  [<ffffffff811a78e8>] sysfs_find_dirent+0x73/0xc8
[    1.196158]  [<ffffffff811a5e8f>] sysfs_hash_and_remove+0x5e/0x8f
[    1.196158]  [<ffffffff81b2c219>] ? kmem_cache_init_late+0x6/0x6
[    1.196158]  [<ffffffff811a7ebf>] sysfs_remove_link+0x25/0x27
[    1.196158]  [<ffffffff8113861e>] sysfs_slab_add+0x47/0x179
[    1.196158]  [<ffffffff81b2c219>] ? kmem_cache_init_late+0x6/0x6
[    1.196158]  [<ffffffff81b2c292>] slab_sysfs_init+0x79/0xf8
[    1.196158]  [<ffffffff81b2c219>] ? kmem_cache_init_late+0x6/0x6
[    1.196158]  [<ffffffff81002099>] do_one_initcall+0x7f/0x13a
[    1.196158]  [<ffffffff81b09d0e>] kernel_init+0x157/0x1db
[    1.196158]  [<ffffffff81b09590>] ? do_early_param+0x8c/0x8c
[    1.196158]  [<ffffffff8152ef44>] kernel_thread_helper+0x4/0x10
[    1.196158]  [<ffffffff81527170>] ? retint_restore_args+0x13/0x13
[    1.196158]  [<ffffffff81b09bb7>] ? start_kernel+0x3d5/0x3d5
[    1.196158]  [<ffffffff8152ef40>] ? gs_change+0x13/0x13
[    1.196158] Code: 8b 74 24 30 48 89 df e8 ae 85 0d 00 48 89 d8 5b 41 5c 5d c3 55 48 89 e5 66 66 66 66 90 31 c0 48 83 c9 ff 31 d2 49 89 f9 48 89 f7 <f2> ae 48 f7 d1 8d 79 ff 31 c9 eb 1d 4c 0f be 04 16 48 ff c2 4c 
[    1.196158] RIP  [<ffffffff811a6e72>] sysfs_name_hash+0x17/0x7b
[    1.196158]  RSP <ffff88003ce3bdb0>
[    1.196158] CR2: 00000001000e000e
[    1.249177] ---[ end trace 2435bf9aa6be7909 ]---
[    1.250112] swapper/0 (1) used greatest stack depth: 3824 bytes left
[    1.251395] Kernel panic - not syncing: Attempted to kill init! exitcode=0x00000009
[    1.251395] 

--------------030308020203010601020805--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
