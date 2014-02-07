Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id E01826B0035
	for <linux-mm@kvack.org>; Thu,  6 Feb 2014 21:29:35 -0500 (EST)
Received: by mail-pb0-f46.google.com with SMTP id um1so2622147pbc.33
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 18:29:35 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id ye6si3098457pbc.200.2014.02.06.18.29.32
        for <linux-mm@kvack.org>;
        Thu, 06 Feb 2014 18:29:33 -0800 (PST)
Date: Fri, 7 Feb 2014 10:28:50 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [cgroup] BUG: unable to handle kernel NULL pointer dereference
Message-ID: <20140207022850.GB11051@localhost>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="f2QGlHpHGjS2mn6Y"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--f2QGlHpHGjS2mn6Y
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Greetings,

I got the below dmesg and the first bad commit is

git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-post-kernfs-conversion
commit 0f23a4ecfbef2a707ddfd9d8359ae5220c8d76c1
Author:     Tejun Heo <tj@kernel.org>
AuthorDate: Mon Feb 3 14:29:00 2014 -0500
Commit:     Tejun Heo <tj@kernel.org>
CommitDate: Mon Feb 3 14:29:00 2014 -0500

    cgroup: remove cgroup->name

+---------------------------------------------------------------------------------+--------------+--------------+
|                                                                                 | 7cff430cffc7 | 9cbc6246a800 |
+---------------------------------------------------------------------------------+--------------+--------------+
| boot_successes                                                                  | 54           | 0            |
| boot_failures                                                                   | 6            | 19           |
| Kernel_panic-not_syncing:No_working_init_found                                  | 6            |              |
| backtrace:panic                                                                 | 6            |              |
| BUG:unable_to_handle_kernel                                                     | 0            | 19           |
| BUG:unable_to_handle_kernel_NULL_pointer_dereferenceNULL_pointer_dereference_at | 0            | 19           |
| Oops                                                                            | 0            | 19           |
| Oops:DEBUG_PAGEALLOCDEBUG_PAGEALLOC                                             | 0            | 19           |
| EIP_is_at_kernfs_path_locked                                                    | 0            | 19           |
| Kernel_panic-not_syncing:Fatal_exception                                        | 0            | 19           |
| backtrace:disk_events_workfn                                                    | 0            | 19           |
+---------------------------------------------------------------------------------+--------------+--------------+

[    6.616956] usbcore: registered new interface driver keyspan_pda
[    6.616956] usbcore: registered new interface driver keyspan_pda
[    6.619153] usbserial: USB Serial support registered for Keyspan PDA
[    6.619153] usbserial: USB Serial support registered for Keyspan PDA
[    6.621546] usbserial: USB Serial support registered for Xircom / Entregra PGS - (prerenumeration)
[    6.621546] usbserial: USB Serial support registered for Xircom / Entregra PGS - (prerenumeration)
[    6.625016] driver ftdi-elan
[    6.625016] driver ftdi-elan
[    6.626390] BUG: unable to handle kernel
[    6.626390] BUG: unable to handle kernel NULL pointer dereferenceNULL pointer dereference at 0000001c
 at 0000001c
[    6.628888] IP:
[    6.628888] IP: [<c10ef404>] kernfs_path_locked+0x15/0x5c
 [<c10ef404>] kernfs_path_locked+0x15/0x5c
[    6.630640] *pde = 00000000
[    6.630640] *pde = 00000000

[    6.631599] Oops: 0000 [#1]
[    6.631599] Oops: 0000 [#1] DEBUG_PAGEALLOCDEBUG_PAGEALLOC

[    6.633000] Modules linked in:
[    6.633000] Modules linked in:

[    6.634124] CPU: 0 PID: 16 Comm: kworker/0:1 Not tainted 3.14.0-rc1-wl-ath-00992-g9cbc624 #2
[    6.634124] CPU: 0 PID: 16 Comm: kworker/0:1 Not tainted 3.14.0-rc1-wl-ath-00992-g9cbc624 #2
[    6.635001] Workqueue: events_freezable_power_ disk_events_workfn
[    6.635001] Workqueue: events_freezable_power_ disk_events_workfn

[    6.635001] task: cf4ee000 ti: cf4f0000 task.ti: cf4f0000
[    6.635001] task: cf4ee000 ti: cf4f0000 task.ti: cf4f0000
[    6.635001] EIP: 0060:[<c10ef404>] EFLAGS: 00010086 CPU: 0
[    6.635001] EIP: 0060:[<c10ef404>] EFLAGS: 00010086 CPU: 0
[    6.635001] EIP is at kernfs_path_locked+0x15/0x5c
[    6.635001] EIP is at kernfs_path_locked+0x15/0x5c
[    6.635001] EAX: 00000000 EBX: 00000000 ECX: cf4f1c44 EDX: cf4f1bc4
[    6.635001] EAX: 00000000 EBX: 00000000 ECX: cf4f1c44 EDX: cf4f1bc4
[    6.635001] ESI: cf4f1c43 EDI: 00000000 EBP: cf4f1b90 ESP: cf4f1b80
[    6.635001] ESI: cf4f1c43 EDI: 00000000 EBP: cf4f1b90 ESP: cf4f1b80
[    6.635001]  DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
[    6.635001]  DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
[    6.635001] CR0: 8005003b CR2: 0000001c CR3: 0172f000 CR4: 00000690
[    6.635001] CR0: 8005003b CR2: 0000001c CR3: 0172f000 CR4: 00000690
[    6.635001] Stack:
[    6.635001] Stack:
[    6.635001]  cf4f1bc4
[    6.635001]  cf4f1bc4 00000000 00000000 00000092 00000092 00000000 00000000 cf4f1ba8 cf4f1ba8 c10ef474 c10ef474 cf4f1bc4 cf4f1bc4
00000080 00000080

[    6.635001]  ce697a58
[    6.635001]  ce697a58 00000040 00000040 cf4f1c50 cf4f1c50 c122f801 c122f801 cf4ee438 cf4ee438 cf4ee000 cf4ee000 00000001 00000001
ce64a1f8 ce64a1f8

[    6.635001]  ce697a18
[    6.635001]  ce697a18 00000001 00000001 00000046 00000046 ce697a18 ce697a18 00000000 00000000 c1c311e8 c1c311e8 cf4f1c74 cf4f1c74
c122eebb c122eebb

[    6.635001] Call Trace:
[    6.635001] Call Trace:
[    6.635001]  [<c10ef474>] kernfs_path+0x29/0x3f
[    6.635001]  [<c10ef474>] kernfs_path+0x29/0x3f
[    6.635001]  [<c122f801>] cfq_find_alloc_queue+0x2d7/0x381
[    6.635001]  [<c122f801>] cfq_find_alloc_queue+0x2d7/0x381

git bisect start 9cbc6246a8001debc81dd3ccf8636ebe0348ffcc 38dbfb59d1175ef458d006556061adeaa8751b72 --
git bisect good d5ee1c1d299197f6625747f7cc7a96124722e104  # 19:15     19+     19  Merge 'spi/fix/nuc900' into devel-hourly-2014020521
git bisect  bad 6a85ae334d8dd720f2fc34aab76fd643074a0e59  # 19:46      0-      2  Merge 'usb/usb-linus' into devel-hourly-2014020521
git bisect good e41ba5b60e23bebb480c4a07de940c9db2111e08  # 20:21     20+     20  Merge 'arm-perf/misc-patches' into devel-hourly-2014020521
git bisect good ec9f9cb128e86f1d12deb4922621c123cb37b4f7  # 20:57     20+     20  Merge 'drm-intel/drm-intel-nightly' into devel-hourly-2014020521
git bisect  bad 7939b799b88d4fbb782a1935169a8ff089c2bfce  # 21:38      0-      5  Merge 'asoc/for-next' into devel-hourly-2014020521
git bisect  bad 37edb03368ab460ea2fd5099467bd75d7f0dcd01  # 21:58      0-      2  Merge 'cgroup/review-post-kernfs-conversion' into devel-hourly-2014020521
git bisect good 7bac9560a270d2fca5b65893851aa29676db2f4e  # 22:55     20+      0  kernfs: add CONFIG_KERNFS
git bisect good c48b4c28016fdf927148616940279291d028cbc2  # 23:21     20+      0  cgroup: introduce cgroup_ino()
git bisect good 044c79a581aa54cd9ba306f74d92fda6621a8ec1  # 23:53     20+      0  cgroup: remove cftype_set
git bisect  bad 0f23a4ecfbef2a707ddfd9d8359ae5220c8d76c1  # 00:13      0-      3  cgroup: remove cgroup->name
git bisect good 7cff430cffc79be4ca11d90b03fe8fd7feae580f  # 00:39     20+      0  cgroup: make cgroup hold onto its kernfs_node
# first bad commit: [0f23a4ecfbef2a707ddfd9d8359ae5220c8d76c1] cgroup: remove cgroup->name
git bisect good 7cff430cffc79be4ca11d90b03fe8fd7feae580f  # 00:44     60+      6  cgroup: make cgroup hold onto its kernfs_node
git bisect  bad 9cbc6246a8001debc81dd3ccf8636ebe0348ffcc  # 00:44      0-     19  0day head guard for 'devel-hourly-2014020521'
git bisect good ef42c58a5b4b8060a3931aab36bf2b4f81b44afc  # 01:53     60+     60  Merge branch 'irq-core-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
git bisect good 0cc2aa51be9d2f2b001c0e070b2e5cdde89b39f4  # 03:09     60+     60  Add linux-next specific files for 20140206

Thanks,
Fengguang

--f2QGlHpHGjS2mn6Y
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-yocto-inn-21:20140205223517:i386-randconfig-j5-02052126:3.14.0-rc1-wl-ath-00992-g9cbc624:2"
Content-Transfer-Encoding: quoted-printable

early console in setup code
Probing EDD (edd=3Doff to disable)... ok
early console in decompress_kernel

Decompressing Linux... Parsing ELF... No relocation needed... done.
Booting the kernel.
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.14.0-rc1-wl-ath-00992-g9cbc624 (kbuild@jaket=
own) (gcc version 4.8.1 (Debian 4.8.1-8) ) #2 Wed Feb 5 22:31:23 CST 2014
[    0.000000] KERNEL supported cpus:
[    0.000000]   AMD AuthenticAMD
[    0.000000]   Centaur CentaurHauls
[    0.000000] CPU: vendor_id 'GenuineIntel' unknown, using generic init.
[    0.000000] CPU: Your system may be unstable.
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000000fffdfff] usable
[    0.000000] BIOS-e820: [mem 0x000000000fffe000-0x000000000fffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reser=
ved
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] Notice: NX (Execute Disable) protection cannot be enabled: n=
on-PAE kernel!
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn =3D 0xfffe max_arch_pfn =3D 0x100000
[    0.000000] MTRR default type: write-back
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 0080000000 mask FF80000000 uncachable
[    0.000000]   1 disabled
[    0.000000]   2 disabled
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x70406, new 0x7010600070106
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] initial memory mapped: [mem 0x00000000-0x01ffffff]
[    0.000000] Base memory trampoline at [c009b000] 9b000 size 16384
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x0f800000-0x0fbfffff]
[    0.000000]  [mem 0x0f800000-0x0fbfffff] page 4k
[    0.000000] BRK [0x01c83000, 0x01c83fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x08000000-0x0f7fffff]
[    0.000000]  [mem 0x08000000-0x0f7fffff] page 4k
[    0.000000] BRK [0x01c84000, 0x01c84fff] PGTABLE
[    0.000000] BRK [0x01c85000, 0x01c85fff] PGTABLE
[    0.000000] BRK [0x01c86000, 0x01c86fff] PGTABLE
[    0.000000] BRK [0x01c87000, 0x01c87fff] PGTABLE
[    0.000000] BRK [0x01c88000, 0x01c88fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x00100000-0x07ffffff]
[    0.000000]  [mem 0x00100000-0x07ffffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x0fc00000-0x0fffdfff]
[    0.000000]  [mem 0x0fc00000-0x0fffdfff] page 4k
[    0.000000] RAMDISK: [mem 0x0fcbd000-0x0ffeffff]
[    0.000000] ACPI: RSDP 000fd930 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0fffe450 000034 (v01 BOCHS  BXPCRSDT 00000001 BXP=
C 00000001)
[    0.000000] ACPI: FACP 0fffff80 000074 (v01 BOCHS  BXPCFACP 00000001 BXP=
C 00000001)
[    0.000000] ACPI: DSDT 0fffe490 0011A9 (v01   BXPC   BXDSDT 00000001 INT=
L 20100528)
[    0.000000] ACPI: FACS 0fffff40 000040
[    0.000000] ACPI: SSDT 0ffff7a0 000796 (v01 BOCHS  BXPCSSDT 00000001 BXP=
C 00000001)
[    0.000000] ACPI: APIC 0ffff680 000080 (v01 BOCHS  BXPCAPIC 00000001 BXP=
C 00000001)
[    0.000000] ACPI: HPET 0ffff640 000038 (v01 BOCHS  BXPCHPET 00000001 BXP=
C 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffa000 (        fee00000)
[    0.000000] 255MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 0fffe000
[    0.000000]   low ram: 0 - 0fffe000
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:fffd001, boot clock
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   Normal   [mem 0x01000000-0x0fffdfff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x0fffdfff]
[    0.000000] On node 0 totalpages: 65436
[    0.000000] free_area_init_node: node 0, pgdat c16dcfac, node_mem_map cf=
98e024
[    0.000000]   DMA zone: 36 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   Normal zone: 540 pages used for memmap
[    0.000000]   Normal zone: 61438 pages, LIFO batch:15
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffa000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: NR_CPUS/possible_cpus limit of 1 reached.  Processor 1=
/0x1 ignored.
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x00] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GSI 0-=
23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 0, APIC =
INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 05, APIC ID 0, APIC =
INT 05
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 0, APIC =
INT 09
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0a, APIC ID 0, APIC =
INT 0a
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0b, APIC ID 0, APIC =
INT 0b
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 0, APIC =
INT 01
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 0, APIC =
INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 0, APIC =
INT 04
[    0.000000] ACPI: IRQ5 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 0, APIC =
INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 0, APIC =
INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 0, APIC =
INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ10 used by override.
[    0.000000] ACPI: IRQ11 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 0, APIC =
INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 0, APIC =
INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 0, APIC =
INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 0, APIC =
INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] mapped IOAPIC to ffff9000 (fec00000)
[    0.000000] nr_irqs_gsi: 40
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 169cc40
[    0.000000] PM: Registered nosave memory: [mem 0x0009f000-0x0009ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000effff]
[    0.000000] PM: Registered nosave memory: [mem 0x000f0000-0x000fffff]
[    0.000000] e820: [mem 0x10000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] pcpu-alloc: s0 r0 d32768 u32768 alloc=3D1*32768
[    0.000000] pcpu-alloc: [0] 0=20
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 64860
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0=
,115200 debug apic=3Ddebug sysrq_always_enabled panic=3D10 softlockup_panic=
=3D1 nmi_watchdog=3Dpanic  prompt_ramdisk=3D0 console=3DttyS0,115200 consol=
e=3Dtty0 vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kernel-tests/run-queue/k=
vm/i386-randconfig-j5-02052126/linux-devel:devel-hourly-2014020521/.vmlinuz=
-9cbc6246a8001debc81dd3ccf8636ebe0348ffcc-20140205223213-6-inn branch=3Dlin=
ux-devel/devel-hourly-2014020521 BOOT_IMAGE=3D/kernel/i386-randconfig-j5-02=
052126/9cbc6246a8001debc81dd3ccf8636ebe0348ffcc/vmlinuz-3.14.0-rc1-wl-ath-0=
0992-g9cbc624
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 1024 (order: 0, 4096 bytes)
[    0.000000] Dentry cache hash table entries: 32768 (order: 5, 131072 byt=
es)
[    0.000000] Inode-cache hash table entries: 16384 (order: 4, 65536 bytes)
[    0.000000] Initializing CPU#0
[    0.000000] Memory: 242800K/261744K available (4181K kernel code, 355K r=
wdata, 2496K rodata, 304K init, 5436K bss, 18944K reserved)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xfffa1000 - 0xfffff000   ( 376 kB)
[    0.000000]     vmalloc : 0xd07fe000 - 0xfff9f000   ( 759 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xcfffe000   ( 255 MB)
[    0.000000]       .init : 0xc16e0000 - 0xc172c000   ( 304 kB)
[    0.000000]       .data : 0xc141597f - 0xc16dffc0   (2857 kB)
[    0.000000]       .text : 0xc1000000 - 0xc141597f   (4182 kB)
[    0.000000] Checking if this processor honours the WP bit even in superv=
isor mode...Ok.
[    0.000000] NR_IRQS:2304 nr_irqs:256 16
[    0.000000] CPU 0 irqstacks, hard=3Dcf402000 soft=3Dcf404000
[    0.000000] ACPI: Core revision 20131218
[    0.000000] ACPI: All ACPI Tables successfully acquired
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.14.0-rc1-wl-ath-00992-g9cbc624 (kbuild@jaket=
own) (gcc version 4.8.1 (Debian 4.8.1-8) ) #2 Wed Feb 5 22:31:23 CST 2014
[    0.000000] KERNEL supported cpus:
[    0.000000]   AMD AuthenticAMD
[    0.000000]   Centaur CentaurHauls
[    0.000000] CPU: vendor_id 'GenuineIntel' unknown, using generic init.
[    0.000000] CPU: Your system may be unstable.
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000000fffdfff] usable
[    0.000000] BIOS-e820: [mem 0x000000000fffe000-0x000000000fffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reser=
ved
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] Notice: NX (Execute Disable) protection cannot be enabled: n=
on-PAE kernel!
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn =3D 0xfffe max_arch_pfn =3D 0x100000
[    0.000000] MTRR default type: write-back
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 0080000000 mask FF80000000 uncachable
[    0.000000]   1 disabled
[    0.000000]   2 disabled
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x70406, new 0x7010600070106
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] initial memory mapped: [mem 0x00000000-0x01ffffff]
[    0.000000] Base memory trampoline at [c009b000] 9b000 size 16384
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x0f800000-0x0fbfffff]
[    0.000000]  [mem 0x0f800000-0x0fbfffff] page 4k
[    0.000000] BRK [0x01c83000, 0x01c83fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x08000000-0x0f7fffff]
[    0.000000]  [mem 0x08000000-0x0f7fffff] page 4k
[    0.000000] BRK [0x01c84000, 0x01c84fff] PGTABLE
[    0.000000] BRK [0x01c85000, 0x01c85fff] PGTABLE
[    0.000000] BRK [0x01c86000, 0x01c86fff] PGTABLE
[    0.000000] BRK [0x01c87000, 0x01c87fff] PGTABLE
[    0.000000] BRK [0x01c88000, 0x01c88fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x00100000-0x07ffffff]
[    0.000000]  [mem 0x00100000-0x07ffffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x0fc00000-0x0fffdfff]
[    0.000000]  [mem 0x0fc00000-0x0fffdfff] page 4k
[    0.000000] RAMDISK: [mem 0x0fcbd000-0x0ffeffff]
[    0.000000] ACPI: RSDP 000fd930 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0fffe450 000034 (v01 BOCHS  BXPCRSDT 00000001 BXP=
C 00000001)
[    0.000000] ACPI: FACP 0fffff80 000074 (v01 BOCHS  BXPCFACP 00000001 BXP=
C 00000001)
[    0.000000] ACPI: DSDT 0fffe490 0011A9 (v01   BXPC   BXDSDT 00000001 INT=
L 20100528)
[    0.000000] ACPI: FACS 0fffff40 000040
[    0.000000] ACPI: SSDT 0ffff7a0 000796 (v01 BOCHS  BXPCSSDT 00000001 BXP=
C 00000001)
[    0.000000] ACPI: APIC 0ffff680 000080 (v01 BOCHS  BXPCAPIC 00000001 BXP=
C 00000001)
[    0.000000] ACPI: HPET 0ffff640 000038 (v01 BOCHS  BXPCHPET 00000001 BXP=
C 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffa000 (        fee00000)
[    0.000000] 255MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 0fffe000
[    0.000000]   low ram: 0 - 0fffe000
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:fffd001, boot clock
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   Normal   [mem 0x01000000-0x0fffdfff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x0fffdfff]
[    0.000000] On node 0 totalpages: 65436
[    0.000000] free_area_init_node: node 0, pgdat c16dcfac, node_mem_map cf=
98e024
[    0.000000]   DMA zone: 36 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   Normal zone: 540 pages used for memmap
[    0.000000]   Normal zone: 61438 pages, LIFO batch:15
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffa000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: NR_CPUS/possible_cpus limit of 1 reached.  Processor 1=
/0x1 ignored.
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x00] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GSI 0-=
23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 0, APIC =
INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 05, APIC ID 0, APIC =
INT 05
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 0, APIC =
INT 09
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0a, APIC ID 0, APIC =
INT 0a
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0b, APIC ID 0, APIC =
INT 0b
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 0, APIC =
INT 01
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 0, APIC =
INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 0, APIC =
INT 04
[    0.000000] ACPI: IRQ5 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 0, APIC =
INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 0, APIC =
INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 0, APIC =
INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ10 used by override.
[    0.000000] ACPI: IRQ11 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 0, APIC =
INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 0, APIC =
INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 0, APIC =
INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 0, APIC =
INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] mapped IOAPIC to ffff9000 (fec00000)
[    0.000000] nr_irqs_gsi: 40
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 169cc40
[    0.000000] PM: Registered nosave memory: [mem 0x0009f000-0x0009ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000effff]
[    0.000000] PM: Registered nosave memory: [mem 0x000f0000-0x000fffff]
[    0.000000] e820: [mem 0x10000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] pcpu-alloc: s0 r0 d32768 u32768 alloc=3D1*32768
[    0.000000] pcpu-alloc: [0] 0=20
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 64860
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0=
,115200 debug apic=3Ddebug sysrq_always_enabled panic=3D10 softlockup_panic=
=3D1 nmi_watchdog=3Dpanic  prompt_ramdisk=3D0 console=3DttyS0,115200 consol=
e=3Dtty0 vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kernel-tests/run-queue/k=
vm/i386-randconfig-j5-02052126/linux-devel:devel-hourly-2014020521/.vmlinuz=
-9cbc6246a8001debc81dd3ccf8636ebe0348ffcc-20140205223213-6-inn branch=3Dlin=
ux-devel/devel-hourly-2014020521 BOOT_IMAGE=3D/kernel/i386-randconfig-j5-02=
052126/9cbc6246a8001debc81dd3ccf8636ebe0348ffcc/vmlinuz-3.14.0-rc1-wl-ath-0=
0992-g9cbc624
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 1024 (order: 0, 4096 bytes)
[    0.000000] Dentry cache hash table entries: 32768 (order: 5, 131072 byt=
es)
[    0.000000] Inode-cache hash table entries: 16384 (order: 4, 65536 bytes)
[    0.000000] Initializing CPU#0
[    0.000000] Memory: 242800K/261744K available (4181K kernel code, 355K r=
wdata, 2496K rodata, 304K init, 5436K bss, 18944K reserved)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xfffa1000 - 0xfffff000   ( 376 kB)
[    0.000000]     vmalloc : 0xd07fe000 - 0xfff9f000   ( 759 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xcfffe000   ( 255 MB)
[    0.000000]       .init : 0xc16e0000 - 0xc172c000   ( 304 kB)
[    0.000000]       .data : 0xc141597f - 0xc16dffc0   (2857 kB)
[    0.000000]       .text : 0xc1000000 - 0xc141597f   (4182 kB)
[    0.000000] Checking if this processor honours the WP bit even in superv=
isor mode...Ok.
[    0.000000] NR_IRQS:2304 nr_irqs:256 16
[    0.000000] CPU 0 irqstacks, hard=3Dcf402000 soft=3Dcf404000
[    0.000000] ACPI: Core revision 20131218
[    0.000000] ACPI: All ACPI Tables successfully acquired
[    0.000000] console [ttyS0] enabled
[    0.000000] console [ttyS0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc.,=
 Ingo Molnar
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc.,=
 Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     16384
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     16384
[    0.000000] ... MAX_LOCKDEP_CHAINS:      32768
[    0.000000] ... MAX_LOCKDEP_CHAINS:      32768
[    0.000000] ... CHAINHASH_SIZE:          16384
[    0.000000] ... CHAINHASH_SIZE:          16384
[    0.000000]  memory used by lock dependency info: 3567 kB
[    0.000000]  memory used by lock dependency info: 3567 kB
[    0.000000]  per task-struct memory footprint: 1152 bytes
[    0.000000]  per task-struct memory footprint: 1152 bytes
[    0.000000] hpet clockevent registered
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Detected 2693.542 MHz processor
[    0.000000] tsc: Detected 2693.542 MHz processor
[    0.020000] Calibrating delay loop (skipped) preset value..=20
[    0.020000] Calibrating delay loop (skipped) preset value.. lpj=3D269354=
20
lpj=3D26935420
[    0.020000] pid_max: default: 32768 minimum: 301
[    0.020000] pid_max: default: 32768 minimum: 301
[    0.020000] Mount-cache hash table entries: 512
[    0.020000] Mount-cache hash table entries: 512
[    0.020000] Initializing cgroup subsys debug
[    0.020000] Initializing cgroup subsys debug
[    0.020000] Initializing cgroup subsys devices
[    0.020000] Initializing cgroup subsys devices
[    0.020032] Initializing cgroup subsys blkio
[    0.020032] Initializing cgroup subsys blkio
[    0.021238] mce: CPU supports 10 MCE banks
[    0.021238] mce: CPU supports 10 MCE banks
[    0.022289] mce: unknown CPU type - not enabling MCE support
[    0.022289] mce: unknown CPU type - not enabling MCE support
[    0.023820] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.023820] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.023820] tlb_flushall_shift: -1
[    0.023820] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.023820] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.023820] tlb_flushall_shift: -1
[    0.027647] CPU:=20
[    0.027647] CPU: GenuineIntel GenuineIntel Common KVM processorCommon KV=
M processor (fam: 0f, model: 06 (fam: 0f, model: 06, stepping: 01)
, stepping: 01)
[    0.033484] Performance Events:=20
[    0.033484] Performance Events: no PMU driver, software events only.
no PMU driver, software events only.
[    0.036016] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.036016] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.037446] Getting VERSION: 50014
[    0.037446] Getting VERSION: 50014
[    0.038375] Getting VERSION: 50014
[    0.038375] Getting VERSION: 50014
[    0.039297] Getting ID: 0
[    0.039297] Getting ID: 0
[    0.040029] Getting ID: f000000
[    0.040029] Getting ID: f000000
[    0.040874] Getting LVT0: 8700
[    0.040874] Getting LVT0: 8700
[    0.041682] Getting LVT1: 8400
[    0.041682] Getting LVT1: 8400
[    0.042582] enabled ExtINT on CPU#0
[    0.042582] enabled ExtINT on CPU#0
[    0.044856] ENABLING IO-APIC IRQs
[    0.044856] ENABLING IO-APIC IRQs
[    0.045779] init IO_APIC IRQs
[    0.045779] init IO_APIC IRQs
[    0.046578]  apic 0 pin 0 not connected
[    0.046578]  apic 0 pin 0 not connected
[    0.047657] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.047657] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.050046] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.050046] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.052180] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    0.052180] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    0.054150] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.054150] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.056265] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:1 Ac=
tive:0 Dest:1)
[    0.056265] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:1 Ac=
tive:0 Dest:1)
[    0.058362] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.058362] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.060046] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.060046] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.062123] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.062123] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.064161] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.064161] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.066165] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    0.066165] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    0.070050] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    0.070050] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    0.072188] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.072188] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.074142] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 =
Active:0 Dest:1)
[    0.074142] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 =
Active:0 Dest:1)
[    0.076275] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 =
Active:0 Dest:1)
[    0.076275] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 =
Active:0 Dest:1)
[    0.078375] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 =
Active:0 Dest:1)
[    0.078375] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 =
Active:0 Dest:1)
[    0.080045]  apic 0 pin 16 not connected
[    0.080045]  apic 0 pin 16 not connected
[    0.081112]  apic 0 pin 17 not connected
[    0.081112]  apic 0 pin 17 not connected
[    0.082165]  apic 0 pin 18 not connected
[    0.082165]  apic 0 pin 18 not connected
[    0.083170]  apic 0 pin 19 not connected
[    0.083170]  apic 0 pin 19 not connected
[    0.084189]  apic 0 pin 20 not connected
[    0.084189]  apic 0 pin 20 not connected
[    0.085208]  apic 0 pin 21 not connected
[    0.085208]  apic 0 pin 21 not connected
[    0.086203]  apic 0 pin 22 not connected
[    0.086203]  apic 0 pin 22 not connected
[    0.087226]  apic 0 pin 23 not connected
[    0.087226]  apic 0 pin 23 not connected
[    0.090175] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.090175] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.092352] Using local APIC timer interrupts.
[    0.092352] calibrating APIC timer ...
[    0.092352] Using local APIC timer interrupts.
[    0.092352] calibrating APIC timer ...
[    0.100000] ... lapic delta =3D 6249942
[    0.100000] ... lapic delta =3D 6249942
[    0.100000] ... PM-Timer delta =3D 357948
[    0.100000] ... PM-Timer delta =3D 357948
[    0.100000] ... PM-Timer result ok
[    0.100000] ... PM-Timer result ok
[    0.100000] ..... delta 6249942
[    0.100000] ..... delta 6249942
[    0.100000] ..... mult: 268432964
[    0.100000] ..... mult: 268432964
[    0.100000] ..... calibration result: 9999907
[    0.100000] ..... calibration result: 9999907
[    0.100000] ..... CPU clock speed is 2693.3510 MHz.
[    0.100000] ..... CPU clock speed is 2693.3510 MHz.
[    0.100000] ..... host bus clock speed is 999.9907 MHz.
[    0.100000] ..... host bus clock speed is 999.9907 MHz.
[    0.100251] NMI watchdog: disabled (cpu0): hardware events not enabled
[    0.100251] NMI watchdog: disabled (cpu0): hardware events not enabled
[    0.103462] devtmpfs: initialized
[    0.103462] devtmpfs: initialized
[    0.106083] xor: measuring software checksum speed
[    0.106083] xor: measuring software checksum speed
[    0.200022]    pIII_sse  :   155.600 MB/sec
[    0.200022]    pIII_sse  :   155.600 MB/sec
[    0.300018]    prefetch64-sse:   161.200 MB/sec
[    0.300018]    prefetch64-sse:   161.200 MB/sec
[    0.301680] xor: using function: prefetch64-sse (161.200 MB/sec)
[    0.301680] xor: using function: prefetch64-sse (161.200 MB/sec)
[    0.304734] regulator-dummy: no parameters
[    0.304734] regulator-dummy: no parameters
[    0.306649] NET: Registered protocol family 16
[    0.306649] NET: Registered protocol family 16
[    0.308943] EISA bus registered
[    0.308943] EISA bus registered
[    0.310024] cpuidle: using governor ladder
[    0.310024] cpuidle: using governor ladder
[    0.311493] cpuidle: using governor menu
[    0.311493] cpuidle: using governor menu
[    0.313385] ACPI: bus type PCI registered
[    0.313385] ACPI: bus type PCI registered
[    0.315066] PCI: PCI BIOS revision 2.10 entry at 0xfc6d5, last bus=3D0
[    0.315066] PCI: PCI BIOS revision 2.10 entry at 0xfc6d5, last bus=3D0
[    0.324142] bio: create slab <bio-0> at 0
[    0.324142] bio: create slab <bio-0> at 0
[    0.490019] raid6: mmxx1     2643 MB/s
[    0.490019] raid6: mmxx1     2643 MB/s
[    0.660023] raid6: mmxx2     3159 MB/s
[    0.660023] raid6: mmxx2     3159 MB/s
[    0.830037] raid6: sse1x1    2087 MB/s
[    0.830037] raid6: sse1x1    2087 MB/s
[    1.000014] raid6: sse1x2    4794 MB/s
[    1.000014] raid6: sse1x2    4794 MB/s
[    1.170024] raid6: sse2x1    5189 MB/s
[    1.170024] raid6: sse2x1    5189 MB/s
[    1.340015] raid6: sse2x2   10062 MB/s
[    1.340015] raid6: sse2x2   10062 MB/s
[    1.340902] raid6: using algorithm sse2x2 (10062 MB/s)
[    1.340902] raid6: using algorithm sse2x2 (10062 MB/s)
[    1.342110] raid6: using intx1 recovery algorithm
[    1.342110] raid6: using intx1 recovery algorithm
[    1.343383] ACPI: Added _OSI(Module Device)
[    1.343383] ACPI: Added _OSI(Module Device)
[    1.344319] ACPI: Added _OSI(Processor Device)
[    1.344319] ACPI: Added _OSI(Processor Device)
[    1.345343] ACPI: Added _OSI(3.0 _SCP Extensions)
[    1.345343] ACPI: Added _OSI(3.0 _SCP Extensions)
[    1.346424] ACPI: Added _OSI(Processor Aggregator Device)
[    1.346424] ACPI: Added _OSI(Processor Aggregator Device)
[    1.354323] ACPI: Interpreter enabled
[    1.354323] ACPI: Interpreter enabled
[    1.355176] ACPI Exception: AE_NOT_FOUND,=20
[    1.355176] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [=
\_S1_]While evaluating Sleep State [\_S1_] (20131218/hwxface-580)
 (20131218/hwxface-580)
[    1.357155] ACPI Exception: AE_NOT_FOUND,=20
[    1.357155] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [=
\_S2_]While evaluating Sleep State [\_S2_] (20131218/hwxface-580)
 (20131218/hwxface-580)
[    1.359208] ACPI: (supports S0 S3 S4 S5)
[    1.359208] ACPI: (supports S0 S3 S4 S5)
[    1.360006] ACPI: Using IOAPIC for interrupt routing
[    1.360006] ACPI: Using IOAPIC for interrupt routing
[    1.361118] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    1.361118] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    1.373064] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    1.373064] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    1.374494] acpi PNP0A03:00: _OSC: OS supports [Segments MSI]
[    1.374494] acpi PNP0A03:00: _OSC: OS supports [Segments MSI]
[    1.375813] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    1.375813] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    1.377845] PCI host bridge to bus 0000:00
[    1.377845] PCI host bridge to bus 0000:00
[    1.378837] pci_bus 0000:00: root bus resource [bus 00-ff]
[    1.378837] pci_bus 0000:00: root bus resource [bus 00-ff]
[    1.380007] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    1.380007] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    1.381419] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    1.381419] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    1.382762] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f]
[    1.382762] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f]
[    1.384182] pci_bus 0000:00: root bus resource [mem 0x80000000-0xfebffff=
f]
[    1.384182] pci_bus 0000:00: root bus resource [mem 0x80000000-0xfebffff=
f]
[    1.385806] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    1.385806] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    1.387726] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    1.387726] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    1.389835] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    1.389835] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    1.392768] pci 0000:00:01.1: reg 0x20: [io  0xc1c0-0xc1cf]
[    1.392768] pci 0000:00:01.1: reg 0x20: [io  0xc1c0-0xc1cf]
[    1.395586] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    1.395586] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    1.397154] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX=
4 ACPI
[    1.397154] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX=
4 ACPI
[    1.398705] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX=
4 SMB
[    1.398705] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX=
4 SMB
[    1.400403] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    1.400403] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    1.404041] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
[    1.404041] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
[    1.407001] pci 0000:00:02.0: reg 0x14: [mem 0xfebf0000-0xfebf0fff]
[    1.407001] pci 0000:00:02.0: reg 0x14: [mem 0xfebf0000-0xfebf0fff]
[    1.416347] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pref]
[    1.416347] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pref]
[    1.418587] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    1.418587] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    1.420533] pci 0000:00:03.0: reg 0x10: [mem 0xfeba0000-0xfebbffff]
[    1.420533] pci 0000:00:03.0: reg 0x10: [mem 0xfeba0000-0xfebbffff]
[    1.423002] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
[    1.423002] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
[    1.429340] pci 0000:00:03.0: reg 0x30: [mem 0xfebc0000-0xfebdffff pref]
[    1.429340] pci 0000:00:03.0: reg 0x30: [mem 0xfebc0000-0xfebdffff pref]
[    1.430513] pci 0000:00:04.0: [1af4:1001] type 00 class 0x010000
[    1.430513] pci 0000:00:04.0: [1af4:1001] type 00 class 0x010000
[    1.432923] pci 0000:00:04.0: reg 0x10: [io  0xc040-0xc07f]
[    1.432923] pci 0000:00:04.0: reg 0x10: [io  0xc040-0xc07f]
[    1.435274] pci 0000:00:04.0: reg 0x14: [mem 0xfebf1000-0xfebf1fff]
[    1.435274] pci 0000:00:04.0: reg 0x14: [mem 0xfebf1000-0xfebf1fff]
[    1.443628] pci 0000:00:05.0: [1af4:1001] type 00 class 0x010000
[    1.443628] pci 0000:00:05.0: [1af4:1001] type 00 class 0x010000
[    1.446122] pci 0000:00:05.0: reg 0x10: [io  0xc080-0xc0bf]
[    1.446122] pci 0000:00:05.0: reg 0x10: [io  0xc080-0xc0bf]
[    1.448445] pci 0000:00:05.0: reg 0x14: [mem 0xfebf2000-0xfebf2fff]
[    1.448445] pci 0000:00:05.0: reg 0x14: [mem 0xfebf2000-0xfebf2fff]
[    1.455779] pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000
[    1.455779] pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000
[    1.458149] pci 0000:00:06.0: reg 0x10: [io  0xc0c0-0xc0ff]
[    1.458149] pci 0000:00:06.0: reg 0x10: [io  0xc0c0-0xc0ff]
[    1.460516] pci 0000:00:06.0: reg 0x14: [mem 0xfebf3000-0xfebf3fff]
[    1.460516] pci 0000:00:06.0: reg 0x14: [mem 0xfebf3000-0xfebf3fff]
[    1.467762] pci 0000:00:07.0: [1af4:1001] type 00 class 0x010000
[    1.467762] pci 0000:00:07.0: [1af4:1001] type 00 class 0x010000
[    1.471482] pci 0000:00:07.0: reg 0x10: [io  0xc100-0xc13f]
[    1.471482] pci 0000:00:07.0: reg 0x10: [io  0xc100-0xc13f]
[    1.473820] pci 0000:00:07.0: reg 0x14: [mem 0xfebf4000-0xfebf4fff]
[    1.473820] pci 0000:00:07.0: reg 0x14: [mem 0xfebf4000-0xfebf4fff]
[    1.480619] pci 0000:00:08.0: [1af4:1001] type 00 class 0x010000
[    1.480619] pci 0000:00:08.0: [1af4:1001] type 00 class 0x010000
[    1.483028] pci 0000:00:08.0: reg 0x10: [io  0xc140-0xc17f]
[    1.483028] pci 0000:00:08.0: reg 0x10: [io  0xc140-0xc17f]
[    1.485329] pci 0000:00:08.0: reg 0x14: [mem 0xfebf5000-0xfebf5fff]
[    1.485329] pci 0000:00:08.0: reg 0x14: [mem 0xfebf5000-0xfebf5fff]
[    1.492634] pci 0000:00:09.0: [1af4:1001] type 00 class 0x010000
[    1.492634] pci 0000:00:09.0: [1af4:1001] type 00 class 0x010000
[    1.495091] pci 0000:00:09.0: reg 0x10: [io  0xc180-0xc1bf]
[    1.495091] pci 0000:00:09.0: reg 0x10: [io  0xc180-0xc1bf]
[    1.497410] pci 0000:00:09.0: reg 0x14: [mem 0xfebf6000-0xfebf6fff]
[    1.497410] pci 0000:00:09.0: reg 0x14: [mem 0xfebf6000-0xfebf6fff]
[    1.504157] pci 0000:00:0a.0: [8086:25ab] type 00 class 0x088000
[    1.504157] pci 0000:00:0a.0: [8086:25ab] type 00 class 0x088000
[    1.506121] pci 0000:00:0a.0: reg 0x10: [mem 0xfebf7000-0xfebf700f]
[    1.506121] pci 0000:00:0a.0: reg 0x10: [mem 0xfebf7000-0xfebf700f]
[    1.511626] pci_bus 0000:00: on NUMA node 0
[    1.511626] pci_bus 0000:00: on NUMA node 0
[    1.513514] ACPI: PCI Interrupt Link [LNKA] (IRQs
[    1.513514] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 5 *10 *10 11 11))

[    1.515134] ACPI: PCI Interrupt Link [LNKB] (IRQs
[    1.515134] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 5 *10 *10 11 11))

[    1.516698] ACPI: PCI Interrupt Link [LNKC] (IRQs
[    1.516698] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 5 10 10 *11 *11))

[    1.518286] ACPI: PCI Interrupt Link [LNKD] (IRQs
[    1.518286] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 5 10 10 *11 *11))

[    1.519773] ACPI: PCI Interrupt Link [LNKS] (IRQs
[    1.519773] ACPI: PCI Interrupt Link [LNKS] (IRQs *9 *9))

[    1.521183] ACPI:=20
[    1.521183] ACPI: Enabled 16 GPEs in block 00 to 0FEnabled 16 GPEs in bl=
ock 00 to 0F

[    1.522965] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,owns=
=3Dio+mem,locks=3Dnone
[    1.522965] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,owns=
=3Dio+mem,locks=3Dnone
[    1.524794] vgaarb: loaded
[    1.524794] vgaarb: loaded
[    1.525399] vgaarb: bridge control possible 0000:00:02.0
[    1.525399] vgaarb: bridge control possible 0000:00:02.0
[    1.527078] SCSI subsystem initialized
[    1.527078] SCSI subsystem initialized
[    1.527954] ACPI: bus type USB registered
[    1.527954] ACPI: bus type USB registered
[    1.528994] usbcore: registered new interface driver usbfs
[    1.528994] usbcore: registered new interface driver usbfs
[    1.530044] usbcore: registered new interface driver hub
[    1.530044] usbcore: registered new interface driver hub
[    1.531400] usbcore: registered new device driver usb
[    1.531400] usbcore: registered new device driver usb
[    1.532740] pps_core: LinuxPPS API ver. 1 registered
[    1.532740] pps_core: LinuxPPS API ver. 1 registered
[    1.533841] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[    1.533841] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[    1.535964] EDAC MC: Ver: 3.0.0
[    1.535964] EDAC MC: Ver: 3.0.0
[    1.537237] PCI: Using ACPI for IRQ routing
[    1.537237] PCI: Using ACPI for IRQ routing
[    1.538187] PCI: pci_cache_line_size set to 64 bytes
[    1.538187] PCI: pci_cache_line_size set to 64 bytes
[    1.540176] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    1.540176] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    1.541524] e820: reserve RAM buffer [mem 0x0fffe000-0x0fffffff]
[    1.541524] e820: reserve RAM buffer [mem 0x0fffe000-0x0fffffff]
[    1.543847] HPET: 3 timers in total, 0 timers will be used for per-cpu t=
imer
[    1.543847] HPET: 3 timers in total, 0 timers will be used for per-cpu t=
imer
[    1.545923] Switched to clocksource kvm-clock
[    1.545923] Switched to clocksource kvm-clock
[    1.547873] FS-Cache: Loaded
[    1.547873] FS-Cache: Loaded
[    1.549077] pnp: PnP ACPI init
[    1.549077] pnp: PnP ACPI init
[    1.549077] ACPI: bus type PNP registered
[    1.549077] ACPI: bus type PNP registered
[    1.549077] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    1.549077] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    1.549313] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    1.549313] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    1.551622] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    1.551622] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    1.554520] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    1.554520] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    1.556778] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    1.556778] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    1.559664] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    1.559664] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    1.562292] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    1.562292] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    1.565043] pnp 00:03: [dma 2]
[    1.565043] pnp 00:03: [dma 2]
[    1.566311] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    1.566311] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    1.568649] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    1.568649] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    1.571439] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    1.571439] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    1.573907] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    1.573907] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    1.576878] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    1.576878] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    1.579864] pnp 00:06: Plug and Play ACPI device, IDs PNP0103 (active)
[    1.579864] pnp 00:06: Plug and Play ACPI device, IDs PNP0103 (active)
[    1.582663] pnp: PnP ACPI: found 7 devices
[    1.582663] pnp: PnP ACPI: found 7 devices
[    1.584208] ACPI: bus type PNP unregistered
[    1.584208] ACPI: bus type PNP unregistered
[    1.622417] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    1.622417] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    1.624511] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    1.624511] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    1.626472] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    1.626472] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    1.628711] pci_bus 0000:00: resource 7 [mem 0x80000000-0xfebfffff]
[    1.628711] pci_bus 0000:00: resource 7 [mem 0x80000000-0xfebfffff]
[    1.630958] NET: Registered protocol family 1
[    1.630958] NET: Registered protocol family 1
[    1.632541] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    1.632541] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    1.634486] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    1.634486] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    1.635857] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    1.635857] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    1.637306] pci 0000:00:02.0: Boot video device
[    1.637306] pci 0000:00:02.0: Boot video device
[    1.638371] PCI: CLS 0 bytes, default 64
[    1.638371] PCI: CLS 0 bytes, default 64
[    1.639562] Trying to unpack rootfs image as initramfs...
[    1.639562] Trying to unpack rootfs image as initramfs...
[    1.737460] debug: unmapping init [mem 0xcfcbd000-0xcffeffff]
[    1.737460] debug: unmapping init [mem 0xcfcbd000-0xcffeffff]
[    2.372861] DMA-API: preallocated 65536 debug entries
[    2.372861] DMA-API: preallocated 65536 debug entries
[    2.374794] DMA-API: debugging enabled by kernel config
[    2.374794] DMA-API: debugging enabled by kernel config
[    2.376968] microcode: no support for this CPU vendor
[    2.376968] microcode: no support for this CPU vendor
[    2.378862] apm: BIOS not found.
[    2.378862] apm: BIOS not found.
[    2.380062] Scanning for low memory corruption every 60 seconds
[    2.380062] Scanning for low memory corruption every 60 seconds
[    2.389257] futex hash table entries: 256 (order: 1, 10240 bytes)
[    2.389257] futex hash table entries: 256 (order: 1, 10240 bytes)
[    2.391556] Initialise system trusted keyring
[    2.391556] Initialise system trusted keyring
[    2.396394] HugeTLB registered 4 MB page size, pre-allocated 0 pages
[    2.396394] HugeTLB registered 4 MB page size, pre-allocated 0 pages
[    2.400435] EFS: 1.0a - http://aeschi.ch.eu.org/efs/
[    2.400435] EFS: 1.0a - http://aeschi.ch.eu.org/efs/
[    2.402445] fuse init (API version 7.22)
[    2.402445] fuse init (API version 7.22)
[    2.405766] GFS2 installed
[    2.405766] GFS2 installed
[    2.410860] alg: No test for crc32 (crc32-table)
[    2.410860] alg: No test for crc32 (crc32-table)
[    2.412817] alg: No test for stdrng (krng)
[    2.412817] alg: No test for stdrng (krng)
[    2.424757] alg: No test for fips(ansi_cprng) (fips_ansi_cprng)
[    2.424757] alg: No test for fips(ansi_cprng) (fips_ansi_cprng)
[    2.427264] Key type asymmetric registered
[    2.427264] Key type asymmetric registered
[    2.428723] Asymmetric key parser 'x509' registered
[    2.428723] Asymmetric key parser 'x509' registered
[    2.430424] Block layer SCSI generic (bsg) driver version 0.4 loaded (ma=
jor 251)
[    2.430424] Block layer SCSI generic (bsg) driver version 0.4 loaded (ma=
jor 251)
[    2.433068] io scheduler noop registered
[    2.433068] io scheduler noop registered
[    2.434467] io scheduler cfq registered (default)
[    2.434467] io scheduler cfq registered (default)
[    2.438008] crc32: CRC_LE_BITS =3D 64, CRC_BE BITS =3D 64
[    2.438008] crc32: CRC_LE_BITS =3D 64, CRC_BE BITS =3D 64
[    2.439794] crc32: self tests passed, processed 225944 bytes in 186063 n=
sec
[    2.439794] crc32: self tests passed, processed 225944 bytes in 186063 n=
sec
[    2.442439] crc32c: CRC_LE_BITS =3D 64
[    2.442439] crc32c: CRC_LE_BITS =3D 64
[    2.443802] crc32c: self tests passed, processed 225944 bytes in 89178 n=
sec
[    2.443802] crc32c: self tests passed, processed 225944 bytes in 89178 n=
sec
[    2.653381] crc32_combine: 8373 self tests passed
[    2.653381] crc32_combine: 8373 self tests passed
[    2.847593] crc32c_combine: 8373 self tests passed
[    2.847593] crc32c_combine: 8373 self tests passed
[    2.849330] rbtree testing
[    2.849330] rbtree testing -> 9454 cycles
 -> 9454 cycles
[    3.240941] augmented rbtree testing
[    3.240941] augmented rbtree testing -> 12065 cycles
 -> 12065 cycles
[    3.746713] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input0
[    3.746713] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input0
[    3.749458] ACPI: Power Button [PWRF]
[    3.749458] ACPI: Power Button [PWRF]
[    3.752690] isapnp: Scanning for PnP cards...
[    3.752690] isapnp: Scanning for PnP cards...
[    4.121472] isapnp: No Plug & Play device found
[    4.121472] isapnp: No Plug & Play device found
[    4.128474] ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 11
[    4.128474] ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 11
[    4.130600] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    4.130600] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    4.140761] ACPI: PCI Interrupt Link [LNKA] enabled at IRQ 10
[    4.140761] ACPI: PCI Interrupt Link [LNKA] enabled at IRQ 10
[    4.142780] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    4.142780] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    4.152650] ACPI: PCI Interrupt Link [LNKB] enabled at IRQ 10
[    4.152650] ACPI: PCI Interrupt Link [LNKB] enabled at IRQ 10
[    4.162336] ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 11
[    4.162336] ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 11
[    4.184130] tsc: Refined TSC clocksource calibration: 2693.432 MHz
[    4.184130] tsc: Refined TSC clocksource calibration: 2693.432 MHz
[    4.186565] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    4.186565] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    4.215401] 00:05: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115200) =
is a 16550A
[    4.215401] 00:05: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115200) =
is a 16550A
[    4.227111] serial: Freescale lpuart driver
[    4.227111] serial: Freescale lpuart driver
[    4.231852] lp: driver loaded but no devices found
[    4.231852] lp: driver loaded but no devices found
[    4.233634] DoubleTalk PC - not found
[    4.233634] DoubleTalk PC - not found
[    4.234903] sonypi: Sony Programmable I/O Controller Driver v1.26.
[    4.234903] sonypi: Sony Programmable I/O Controller Driver v1.26.
[    4.237426] ppdev: user-space parallel port driver
[    4.237426] ppdev: user-space parallel port driver
[    4.239190] telclk_interrupt =3D 0xf non-mcpbl0010 hw.
[    4.239190] telclk_interrupt =3D 0xf non-mcpbl0010 hw.
[    4.240971] smapi::smapi_init, ERROR invalid usSmapiID
[    4.240971] smapi::smapi_init, ERROR invalid usSmapiID
[    4.242675] mwave: tp3780i::tp3780I_InitializeBoardData: Error: SMAPI is=
 not available on this machine
[    4.242675] mwave: tp3780i::tp3780I_InitializeBoardData: Error: SMAPI is=
 not available on this machine
[    4.246020] mwave: mwavedd::mwave_init: Error: Failed to initialize boar=
d data
[    4.246020] mwave: mwavedd::mwave_init: Error: Failed to initialize boar=
d data
[    4.248620] mwave: mwavedd::mwave_init: Error: Failed to initialize
[    4.248620] mwave: mwavedd::mwave_init: Error: Failed to initialize
[    4.250949] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 secon=
ds, margin is 60 seconds).
[    4.250949] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 secon=
ds, margin is 60 seconds).
[    4.254112] Hangcheck: Using getrawmonotonic().
[    4.254112] Hangcheck: Using getrawmonotonic().
[    4.261649] Floppy drive(s):
[    4.261649] Floppy drive(s): fd0 is 1.44M fd0 is 1.44M

[    4.277461] FDC 0 is a S82078B
[    4.277461] FDC 0 is a S82078B
[    4.303915] brd: module loaded
[    4.303915] brd: module loaded
[    4.305072] mtip32xx Version 1.3.0
[    4.305072] mtip32xx Version 1.3.0
[    4.306507] Silicon Labs C2 port support v. 0.51.0 - (C) 2007 Rodolfo Gi=
ometti
[    4.306507] Silicon Labs C2 port support v. 0.51.0 - (C) 2007 Rodolfo Gi=
ometti
[    4.310840] c2port c2port0: C2 port uc added
[    4.310840] c2port c2port0: C2 port uc added
[    4.312407] c2port c2port0: uc flash has 30 blocks x 512 bytes (15360 by=
tes total)
[    4.312407] c2port c2port0: uc flash has 30 blocks x 512 bytes (15360 by=
tes total)
[    4.315355] Guest personality initialized and is inactive
[    4.315355] Guest personality initialized and is inactive
[    4.318852] VMCI host device registered (name=3Dvmci, major=3D10, minor=
=3D62)
[    4.318852] VMCI host device registered (name=3Dvmci, major=3D10, minor=
=3D62)
[    4.321405] Initialized host personality
[    4.321405] Initialized host personality
[    4.323120] usbcore: registered new interface driver viperboard
[    4.323120] usbcore: registered new interface driver viperboard
[    4.325296] Uniform Multi-Platform E-IDE driver
[    4.325296] Uniform Multi-Platform E-IDE driver
[    4.329940] piix 0000:00:01.1: IDE controller (0x8086:0x7010 rev 0x00)
[    4.329940] piix 0000:00:01.1: IDE controller (0x8086:0x7010 rev 0x00)
[    4.332589] piix 0000:00:01.1: not 100% native mode: will probe irqs lat=
er
[    4.332589] piix 0000:00:01.1: not 100% native mode: will probe irqs lat=
er
[    4.337762]     ide0: BM-DMA at 0xc1c0-0xc1c7
[    4.337762]     ide0: BM-DMA at 0xc1c0-0xc1c7
[    4.339408]     ide1: BM-DMA at 0xc1c8-0xc1cf
[    4.339408]     ide1: BM-DMA at 0xc1c8-0xc1cf
[    4.340924] Probing IDE interface ide0...
[    4.340924] Probing IDE interface ide0...
[    4.945255] Probing IDE interface ide1...
[    4.945255] Probing IDE interface ide1...
[    5.733558] hdc: QEMU DVD-ROM, ATAPI=20
[    5.733558] hdc: QEMU DVD-ROM, ATAPI CD/DVD-ROMCD/DVD-ROM drive
 drive
[    6.453739] hdc: host max PIO4 wanted PIO255(auto-tune) selected PIO0
[    6.453739] hdc: host max PIO4 wanted PIO255(auto-tune) selected PIO0
[    6.456479] hdc: MWDMA2 mode selected
[    6.456479] hdc: MWDMA2 mode selected
[    6.458154] ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
[    6.458154] ide0 at 0x1f0-0x1f7,0x3f6 on irq 14

[    6.460105] ide1 at 0x170-0x177,0x376 on irq 15
[    6.460105] ide1 at 0x170-0x177,0x376 on irq 15

[    6.465424] ide_generic: please use "probe_mask=3D0x3f" module parameter=
 for probing all legacy ISA IDE ports
[    6.465424] ide_generic: please use "probe_mask=3D0x3f" module parameter=
 for probing all legacy ISA IDE ports
[    6.470395] ide-gd driver 1.18
[    6.470395] ide-gd driver 1.18
[    6.474330] ide-cd driver 5.00
[    6.474330] ide-cd driver 5.00
[    6.476163] ide-cd: hdc: ATAPI
[    6.476163] ide-cd: hdc: ATAPI 4X 4X DVD-ROM DVD-ROM drive drive, 512kB =
Cache
, 512kB Cache
[    6.478348] cdrom: Uniform CD-ROM driver Revision: 3.20
[    6.478348] cdrom: Uniform CD-ROM driver Revision: 3.20
[    6.486926] hp_sw: device handler registered
[    6.486926] hp_sw: device handler registered
[    6.488626] osst :I: Tape driver with OnStream support version 0.99.4
[    6.488626] osst :I: $Id: osst.c,v 1.73 2005/01/01 21:13:34 wriede Exp $
[    6.488626] osst :I: Tape driver with OnStream support version 0.99.4
[    6.488626] osst :I: $Id: osst.c,v 1.73 2005/01/01 21:13:34 wriede Exp $
[    6.496080] Rounding down aligned max_sectors from 4294967295 to 4294967=
288
[    6.496080] Rounding down aligned max_sectors from 4294967295 to 4294967=
288
[    6.501406] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    6.501406] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    6.503155] fusbh200_hcd: FUSBH200 Host Controller (EHCI) Driver
[    6.503155] fusbh200_hcd: FUSBH200 Host Controller (EHCI) Driver
[    6.504770] Warning! fusbh200_hcd should always be loaded before uhci_hc=
d and ohci_hcd, not after
[    6.504770] Warning! fusbh200_hcd should always be loaded before uhci_hc=
d and ohci_hcd, not after
[    6.507975] usbcore: registered new interface driver cdc_acm
[    6.507975] usbcore: registered new interface driver cdc_acm
[    6.510087] cdc_acm: USB Abstract Control Model driver for USB modems an=
d ISDN adapters
[    6.510087] cdc_acm: USB Abstract Control Model driver for USB modems an=
d ISDN adapters
[    6.513181] usbcore: registered new interface driver cdc_wdm
[    6.513181] usbcore: registered new interface driver cdc_wdm
[    6.517027] usbcore: registered new interface driver usbserial
[    6.517027] usbcore: registered new interface driver usbserial
[    6.519353] usbcore: registered new interface driver aircable
[    6.519353] usbcore: registered new interface driver aircable
[    6.521675] usbserial: USB Serial support registered for aircable
[    6.521675] usbserial: USB Serial support registered for aircable
[    6.524079] usbcore: registered new interface driver ark3116
[    6.524079] usbcore: registered new interface driver ark3116
[    6.526275] usbserial: USB Serial support registered for ark3116
[    6.526275] usbserial: USB Serial support registered for ark3116
[    6.530023] usbcore: registered new interface driver belkin_sa
[    6.530023] usbcore: registered new interface driver belkin_sa
[    6.532388] usbserial: USB Serial support registered for Belkin / Peraco=
m / GoHubs USB Serial Adapter
[    6.532388] usbserial: USB Serial support registered for Belkin / Peraco=
m / GoHubs USB Serial Adapter
[    6.536002] usbcore: registered new interface driver cp210x
[    6.536002] usbcore: registered new interface driver cp210x
[    6.538183] usbserial: USB Serial support registered for cp210x
[    6.538183] usbserial: USB Serial support registered for cp210x
[    6.540490] usbcore: registered new interface driver io_edgeport
[    6.540490] usbcore: registered new interface driver io_edgeport
[    6.542789] usbserial: USB Serial support registered for Edgeport 2 port=
 adapter
[    6.542789] usbserial: USB Serial support registered for Edgeport 2 port=
 adapter
[    6.545623] usbserial: USB Serial support registered for Edgeport 4 port=
 adapter
[    6.545623] usbserial: USB Serial support registered for Edgeport 4 port=
 adapter
[    6.549859] usbserial: USB Serial support registered for Edgeport 8 port=
 adapter
[    6.549859] usbserial: USB Serial support registered for Edgeport 8 port=
 adapter
[    6.552432] usbserial: USB Serial support registered for EPiC device
[    6.552432] usbserial: USB Serial support registered for EPiC device
[    6.554618] usbcore: registered new interface driver io_ti
[    6.554618] usbcore: registered new interface driver io_ti
[    6.556633] usbserial: USB Serial support registered for Edgeport TI 1 p=
ort adapter
[    6.556633] usbserial: USB Serial support registered for Edgeport TI 1 p=
ort adapter
[    6.559410] usbserial: USB Serial support registered for Edgeport TI 2 p=
ort adapter
[    6.559410] usbserial: USB Serial support registered for Edgeport TI 2 p=
ort adapter
[    6.562216] usbcore: registered new interface driver empeg
[    6.562216] usbcore: registered new interface driver empeg
[    6.565646] usbserial: USB Serial support registered for empeg
[    6.565646] usbserial: USB Serial support registered for empeg
[    6.567785] usbcore: registered new interface driver garmin_gps
[    6.567785] usbcore: registered new interface driver garmin_gps
[    6.569929] usbserial: USB Serial support registered for Garmin GPS usb/=
tty
[    6.569929] usbserial: USB Serial support registered for Garmin GPS usb/=
tty
[    6.572399] usbcore: registered new interface driver keyspan
[    6.572399] usbcore: registered new interface driver keyspan
[    6.574406] usbserial: USB Serial support registered for Keyspan - (with=
out firmware)
[    6.574406] usbserial: USB Serial support registered for Keyspan - (with=
out firmware)
[    6.577286] usbserial: USB Serial support registered for Keyspan 1 port =
adapter
[    6.577286] usbserial: USB Serial support registered for Keyspan 1 port =
adapter
[    6.579947] usbserial: USB Serial support registered for Keyspan 2 port =
adapter
[    6.579947] usbserial: USB Serial support registered for Keyspan 2 port =
adapter
[    6.584051] usbserial: USB Serial support registered for Keyspan 4 port =
adapter
[    6.584051] usbserial: USB Serial support registered for Keyspan 4 port =
adapter
[    6.586747] usbcore: registered new interface driver omninet
[    6.586747] usbcore: registered new interface driver omninet
[    6.588761] usbserial: USB Serial support registered for ZyXEL - omni.ne=
t lcd plus usb
[    6.588761] usbserial: USB Serial support registered for ZyXEL - omni.ne=
t lcd plus usb
[    6.591650] usbcore: registered new interface driver opticon
[    6.591650] usbcore: registered new interface driver opticon
[    6.593803] usbserial: USB Serial support registered for opticon
[    6.593803] usbserial: USB Serial support registered for opticon
[    6.596031] usbcore: registered new interface driver option
[    6.596031] usbcore: registered new interface driver option
[    6.599523] usbserial: USB Serial support registered for GSM modem (1-po=
rt)
[    6.599523] usbserial: USB Serial support registered for GSM modem (1-po=
rt)
[    6.602124] usbcore: registered new interface driver oti6858
[    6.602124] usbcore: registered new interface driver oti6858
[    6.604291] usbserial: USB Serial support registered for oti6858
[    6.604291] usbserial: USB Serial support registered for oti6858
[    6.606558] usbcore: registered new interface driver sierra
[    6.606558] usbcore: registered new interface driver sierra
[    6.608633] usbserial: USB Serial support registered for Sierra USB modem
[    6.608633] usbserial: USB Serial support registered for Sierra USB modem
[    6.611099] usbcore: registered new interface driver symbolserial
[    6.611099] usbcore: registered new interface driver symbolserial
[    6.613374] usbserial: USB Serial support registered for symbol
[    6.613374] usbserial: USB Serial support registered for symbol
[    6.616956] usbcore: registered new interface driver keyspan_pda
[    6.616956] usbcore: registered new interface driver keyspan_pda
[    6.619153] usbserial: USB Serial support registered for Keyspan PDA
[    6.619153] usbserial: USB Serial support registered for Keyspan PDA
[    6.621546] usbserial: USB Serial support registered for Xircom / Entreg=
ra PGS - (prerenumeration)
[    6.621546] usbserial: USB Serial support registered for Xircom / Entreg=
ra PGS - (prerenumeration)
[    6.625016] driver ftdi-elan
[    6.625016] driver ftdi-elan
[    6.626390] BUG: unable to handle kernel=20
[    6.626390] BUG: unable to handle kernel NULL pointer dereferenceNULL po=
inter dereference at 0000001c
 at 0000001c
[    6.628888] IP:
[    6.628888] IP: [<c10ef404>] kernfs_path_locked+0x15/0x5c
 [<c10ef404>] kernfs_path_locked+0x15/0x5c
[    6.630640] *pde =3D 00000000=20
[    6.630640] *pde =3D 00000000=20

[    6.631599] Oops: 0000 [#1]=20
[    6.631599] Oops: 0000 [#1] DEBUG_PAGEALLOCDEBUG_PAGEALLOC

[    6.633000] Modules linked in:
[    6.633000] Modules linked in:

[    6.634124] CPU: 0 PID: 16 Comm: kworker/0:1 Not tainted 3.14.0-rc1-wl-a=
th-00992-g9cbc624 #2
[    6.634124] CPU: 0 PID: 16 Comm: kworker/0:1 Not tainted 3.14.0-rc1-wl-a=
th-00992-g9cbc624 #2
[    6.635001] Workqueue: events_freezable_power_ disk_events_workfn
[    6.635001] Workqueue: events_freezable_power_ disk_events_workfn

[    6.635001] task: cf4ee000 ti: cf4f0000 task.ti: cf4f0000
[    6.635001] task: cf4ee000 ti: cf4f0000 task.ti: cf4f0000
[    6.635001] EIP: 0060:[<c10ef404>] EFLAGS: 00010086 CPU: 0
[    6.635001] EIP: 0060:[<c10ef404>] EFLAGS: 00010086 CPU: 0
[    6.635001] EIP is at kernfs_path_locked+0x15/0x5c
[    6.635001] EIP is at kernfs_path_locked+0x15/0x5c
[    6.635001] EAX: 00000000 EBX: 00000000 ECX: cf4f1c44 EDX: cf4f1bc4
[    6.635001] EAX: 00000000 EBX: 00000000 ECX: cf4f1c44 EDX: cf4f1bc4
[    6.635001] ESI: cf4f1c43 EDI: 00000000 EBP: cf4f1b90 ESP: cf4f1b80
[    6.635001] ESI: cf4f1c43 EDI: 00000000 EBP: cf4f1b90 ESP: cf4f1b80
[    6.635001]  DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
[    6.635001]  DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
[    6.635001] CR0: 8005003b CR2: 0000001c CR3: 0172f000 CR4: 00000690
[    6.635001] CR0: 8005003b CR2: 0000001c CR3: 0172f000 CR4: 00000690
[    6.635001] Stack:
[    6.635001] Stack:
[    6.635001]  cf4f1bc4
[    6.635001]  cf4f1bc4 00000000 00000000 00000092 00000092 00000000 00000=
000 cf4f1ba8 cf4f1ba8 c10ef474 c10ef474 cf4f1bc4 cf4f1bc4 00000080 00000080

[    6.635001]  ce697a58
[    6.635001]  ce697a58 00000040 00000040 cf4f1c50 cf4f1c50 c122f801 c122f=
801 cf4ee438 cf4ee438 cf4ee000 cf4ee000 00000001 00000001 ce64a1f8 ce64a1f8

[    6.635001]  ce697a18
[    6.635001]  ce697a18 00000001 00000001 00000046 00000046 ce697a18 ce697=
a18 00000000 00000000 c1c311e8 c1c311e8 cf4f1c74 cf4f1c74 c122eebb c122eebb

[    6.635001] Call Trace:
[    6.635001] Call Trace:
[    6.635001]  [<c10ef474>] kernfs_path+0x29/0x3f
[    6.635001]  [<c10ef474>] kernfs_path+0x29/0x3f
[    6.635001]  [<c122f801>] cfq_find_alloc_queue+0x2d7/0x381
[    6.635001]  [<c122f801>] cfq_find_alloc_queue+0x2d7/0x381
[    6.635001]  [<c122eebb>] ? check_blkcg_changed+0x15a/0x1fb
[    6.635001]  [<c122eebb>] ? check_blkcg_changed+0x15a/0x1fb
[    6.635001]  [<c100391e>] ? print_context_stack+0x7e/0x91
[    6.635001]  [<c100391e>] ? print_context_stack+0x7e/0x91
[    6.635001]  [<c122fdca>] ? cfq_set_request+0x75/0x289
[    6.635001]  [<c122fdca>] ? cfq_set_request+0x75/0x289
[    6.635001]  [<c122f917>] cfq_get_queue+0x6c/0x8b
[    6.635001]  [<c122f917>] cfq_get_queue+0x6c/0x8b
[    6.635001]  [<c122fe72>] cfq_set_request+0x11d/0x289
[    6.635001]  [<c122fe72>] cfq_set_request+0x11d/0x289
[    6.635001]  [<c1413be4>] ? _raw_spin_unlock_irqrestore+0x39/0x4b
[    6.635001]  [<c1413be4>] ? _raw_spin_unlock_irqrestore+0x39/0x4b
[    6.635001]  [<c104d286>] ? mark_held_locks+0xab/0xcc
[    6.635001]  [<c104d286>] ? mark_held_locks+0xab/0xcc
[    6.635001]  [<c1413c18>] ? _raw_spin_unlock_irq+0x22/0x31
[    6.635001]  [<c1413c18>] ? _raw_spin_unlock_irq+0x22/0x31
[    6.635001]  [<c104d469>] ? trace_hardirqs_on+0xb/0xd
[    6.635001]  [<c104d469>] ? trace_hardirqs_on+0xb/0xd
[    6.635001]  [<c1413c18>] ? _raw_spin_unlock_irq+0x22/0x31
[    6.635001]  [<c1413c18>] ? _raw_spin_unlock_irq+0x22/0x31
[    6.635001]  [<c122fd55>] ? cfq_insert_request+0x41f/0x41f
[    6.635001]  [<c122fd55>] ? cfq_insert_request+0x41f/0x41f
[    6.635001]  [<c1217957>] elv_set_request+0x15/0x1f
[    6.635001]  [<c1217957>] elv_set_request+0x15/0x1f
[    6.635001]  [<c1218d16>] get_request+0x463/0x67a
[    6.635001]  [<c1218d16>] get_request+0x463/0x67a
[    6.635001]  [<c104866f>] ? __wake_up_sync+0xd/0xd
[    6.635001]  [<c104866f>] ? __wake_up_sync+0xd/0xd
[    6.635001]  [<c1218fb6>] blk_get_request+0x89/0xa5
[    6.635001]  [<c1218fb6>] blk_get_request+0x89/0xa5
[    6.635001]  [<c13041bd>] ide_cd_queue_pc+0x49/0x14e
[    6.635001]  [<c13041bd>] ide_cd_queue_pc+0x49/0x14e
[    6.635001]  [<c104fb62>] ? __lock_acquire+0x1620/0x1652
[    6.635001]  [<c104fb62>] ? __lock_acquire+0x1620/0x1652
[    6.635001]  [<c101e1b5>] ? kvm_clock_read+0x14/0x1d
[    6.635001]  [<c101e1b5>] ? kvm_clock_read+0x14/0x1d
[    6.635001]  [<c130445c>] cdrom_check_status+0x45/0x4d
[    6.635001]  [<c130445c>] cdrom_check_status+0x45/0x4d
[    6.635001]  [<c1304f5c>] ide_cdrom_check_events_real+0x1a/0x33
[    6.635001]  [<c1304f5c>] ide_cdrom_check_events_real+0x1a/0x33
[    6.635001]  [<c13394e1>] cdrom_update_events+0x11/0x1b
[    6.635001]  [<c13394e1>] cdrom_update_events+0x11/0x1b
[    6.635001]  [<c13394f6>] cdrom_check_events+0xb/0x18
[    6.635001]  [<c13394f6>] cdrom_check_events+0xb/0x18
[    6.635001]  [<c1303408>] idecd_check_events+0x13/0x15
[    6.635001]  [<c1303408>] idecd_check_events+0x13/0x15
[    6.635001]  [<c1222e3d>] disk_check_events+0x2f/0xcd
[    6.635001]  [<c1222e3d>] disk_check_events+0x2f/0xcd
[    6.635001]  [<c1222eee>] disk_events_workfn+0x13/0x15
[    6.635001]  [<c1222eee>] disk_events_workfn+0x13/0x15
[    6.635001]  [<c1037ed1>] process_one_work+0x1d9/0x352
[    6.635001]  [<c1037ed1>] process_one_work+0x1d9/0x352
[    6.635001]  [<c1037e78>] ? process_one_work+0x180/0x352
[    6.635001]  [<c1037e78>] ? process_one_work+0x180/0x352
[    6.635001]  [<c103893a>] worker_thread+0x19c/0x27c
[    6.635001]  [<c103893a>] worker_thread+0x19c/0x27c
[    6.635001]  [<c103879e>] ? rescuer_thread+0x204/0x204
[    6.635001]  [<c103879e>] ? rescuer_thread+0x204/0x204
[    6.635001]  [<c103cd96>] kthread+0xa3/0xa8
[    6.635001]  [<c103cd96>] kthread+0xa3/0xa8
[    6.635001]  [<c14149fb>] ret_from_kernel_thread+0x1b/0x30
[    6.635001]  [<c14149fb>] ret_from_kernel_thread+0x1b/0x30
[    6.635001]  [<c103ccf3>] ? kthread_stop+0x48/0x48
[    6.635001]  [<c103ccf3>] ? kthread_stop+0x48/0x48
[    6.635001] Code:
[    6.635001] Code: 74 74 09 09 eb eb 0c 0c b8 b8 02 02 00 00 00 00 00 00 =
eb eb 05 05 b8 b8 fe fe ff ff ff ff 7f 7f 5a 5a 5b 5b 5e 5e 5f 5f 5d 5d c3 =
c3 55 55 01 01 d1 d1 89 89 e5 e5 57 57 56 56 53 53 89 89 c3 c3 56 56 8d 8d =
71 71 ff ff 89 89 55 55 f0 f0 c6 c6 41 41 ff ff 00 00 <8b> <8b> 43 43 1c 1c=
 e8 e8 4e 4e a1 a1 14 14 00 00 89 89 f2 f2 2b 2b 55 55 f0 f0 89 89 c1 c1 8d=
 8d 40 40 01 01 39 39 c2 c2 7d 7d

[    6.635001] EIP: [<c10ef404>]=20
[    6.635001] EIP: [<c10ef404>] kernfs_path_locked+0x15/0x5ckernfs_path_lo=
cked+0x15/0x5c SS:ESP 0068:cf4f1b80
 SS:ESP 0068:cf4f1b80
[    6.635001] CR2: 000000000000001c
[    6.635001] CR2: 000000000000001c
[    6.635001] ---[ end trace 071f3c024c2eb5a4 ]---
[    6.635001] ---[ end trace 071f3c024c2eb5a4 ]---
[    6.635001] Kernel panic - not syncing: Fatal exception
[    6.635001] Kernel panic - not syncing: Fatal exception
[    6.635001] Kernel Offset: 0x0 from 0xc1000000 (relocation range: 0xc000=
0000-0xd07fdfff)
[    6.635001] Kernel Offset: 0x0 from 0xc1000000 (relocation range: 0xc000=
0000-0xd07fdfff)
[    6.635001] Rebooting in 10 seconds..
[    6.635001] Rebooting in 10 seconds..
Elapsed time: 10
qemu-system-x86_64 -cpu kvm64 -enable-kvm -kernel /kernel/i386-randconfig-j=
5-02052126/9cbc6246a8001debc81dd3ccf8636ebe0348ffcc/vmlinuz-3.14.0-rc1-wl-a=
th-00992-g9cbc624 -append 'hung_task_panic=3D1 earlyprintk=3DttyS0,115200 d=
ebug apic=3Ddebug sysrq_always_enabled panic=3D10 softlockup_panic=3D1 nmi_=
watchdog=3Dpanic  prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 =
vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kernel-tests/run-queue/kvm/i386-r=
andconfig-j5-02052126/linux-devel:devel-hourly-2014020521/.vmlinuz-9cbc6246=
a8001debc81dd3ccf8636ebe0348ffcc-20140205223213-6-inn branch=3Dlinux-devel/=
devel-hourly-2014020521 BOOT_IMAGE=3D/kernel/i386-randconfig-j5-02052126/9c=
bc6246a8001debc81dd3ccf8636ebe0348ffcc/vmlinuz-3.14.0-rc1-wl-ath-00992-g9cb=
c624'  -initrd /kernel-tests/initrd/yocto-minimal-i386.cgz -m 256M -smp 2 -=
net nic,vlan=3D1,model=3De1000 -net user,vlan=3D1,hostfwd=3Dtcp::21041-:22 =
-boot order=3Dnc -no-reboot -watchdog i6300esb -rtc base=3Dlocaltime -drive=
 file=3D/fs/LABEL=3DKVM/disk0-yocto-inn-21,media=3Ddisk,if=3Dvirtio -drive =
file=3D/fs/LABEL=3DKVM/disk1-yocto-inn-21,media=3Ddisk,if=3Dvirtio -drive f=
ile=3D/fs/LABEL=3DKVM/disk2-yocto-inn-21,media=3Ddisk,if=3Dvirtio -drive fi=
le=3D/fs/LABEL=3DKVM/disk3-yocto-inn-21,media=3Ddisk,if=3Dvirtio -drive fil=
e=3D/fs/LABEL=3DKVM/disk4-yocto-inn-21,media=3Ddisk,if=3Dvirtio -drive file=
=3D/fs/LABEL=3DKVM/disk5-yocto-inn-21,media=3Ddisk,if=3Dvirtio -pidfile /de=
v/shm/kboot/pid-yocto-inn-21 -serial file:/dev/shm/kboot/serial-yocto-inn-2=
1 -daemonize -display none -monitor null=20

--f2QGlHpHGjS2mn6Y
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-3.14.0-rc1-wl-ath-00992-g9cbc624"

#
# Automatically generated file; DO NOT EDIT.
# Linux/i386 3.14.0-rc1 Kernel Configuration
#
# CONFIG_64BIT is not set
CONFIG_X86_32=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf32-i386"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/i386_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_HAVE_LATENCYTOP_SUPPORT=y
CONFIG_MMU=y
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_ARCH_HAS_CPU_AUTOPROBE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ARCH_WANT_HUGE_PMD_SHARE=y
CONFIG_ARCH_WANT_GENERAL_HUGETLB=y
# CONFIG_ZONE_DMA32 is not set
# CONFIG_AUDIT_ARCH is not set
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_X86_32_LAZY_GS=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-ecx -fcall-saved-edx"
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
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
CONFIG_KERNEL_BZIP2=y
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
CONFIG_SWAP=y
# CONFIG_SYSVIPC is not set
# CONFIG_POSIX_MQUEUE is not set
CONFIG_FHANDLE=y
# CONFIG_AUDIT is not set

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_IRQ_CHIP=y
CONFIG_IRQ_DOMAIN=y
CONFIG_IRQ_DOMAIN_DEBUG=y
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_KTIME_SCALAR=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
CONFIG_GENERIC_CMOS_UPDATE=y

#
# Timers subsystem
#
CONFIG_HZ_PERIODIC=y
# CONFIG_NO_HZ_IDLE is not set
# CONFIG_NO_HZ is not set
# CONFIG_HIGH_RES_TIMERS is not set

#
# CPU/Task time and stats accounting
#
CONFIG_TICK_CPU_ACCOUNTING=y
# CONFIG_IRQ_TIME_ACCOUNTING is not set
# CONFIG_BSD_PROCESS_ACCT is not set
# CONFIG_TASKSTATS is not set

#
# RCU Subsystem
#
CONFIG_TINY_RCU=y
# CONFIG_PREEMPT_RCU is not set
# CONFIG_RCU_STALL_COMMON is not set
# CONFIG_TREE_RCU_TRACE is not set
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=17
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANTS_PROT_NUMA_PROT_NONE=y
CONFIG_CGROUPS=y
CONFIG_CGROUP_DEBUG=y
# CONFIG_CGROUP_FREEZER is not set
CONFIG_CGROUP_DEVICE=y
# CONFIG_CPUSETS is not set
# CONFIG_CGROUP_CPUACCT is not set
# CONFIG_RESOURCE_COUNTERS is not set
# CONFIG_CGROUP_PERF is not set
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
# CONFIG_CFS_BANDWIDTH is not set
# CONFIG_RT_GROUP_SCHED is not set
CONFIG_BLK_CGROUP=y
# CONFIG_DEBUG_BLK_CGROUP is not set
CONFIG_CHECKPOINT_RESTORE=y
# CONFIG_NAMESPACES is not set
# CONFIG_SCHED_AUTOGROUP is not set
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
# CONFIG_RD_BZIP2 is not set
# CONFIG_RD_LZMA is not set
# CONFIG_RD_XZ is not set
# CONFIG_RD_LZO is not set
CONFIG_RD_LZ4=y
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
CONFIG_HAVE_UID16=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_EXPERT=y
# CONFIG_UID16 is not set
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_PRINTK=y
CONFIG_BUG=y
# CONFIG_ELF_CORE is not set
CONFIG_PCSPKR_PLATFORM=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
# CONFIG_AIO is not set
CONFIG_PCI_QUIRKS=y
# CONFIG_EMBEDDED is not set
CONFIG_HAVE_PERF_EVENTS=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
CONFIG_VM_EVENT_COUNTERS=y
# CONFIG_COMPAT_BRK is not set
# CONFIG_SLAB is not set
# CONFIG_SLUB is not set
CONFIG_SLOB=y
# CONFIG_PROFILING is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
# CONFIG_KPROBES is not set
# CONFIG_JUMP_LABEL is not set
# CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_ATTRS=y
CONFIG_HAVE_DMA_CONTIGUOUS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
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
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_ARCH_WANT_IPC_PARSE_VERSION=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_SECCOMP_FILTER=y
CONFIG_HAVE_CC_STACKPROTECTOR=y
# CONFIG_CC_STACKPROTECTOR is not set
CONFIG_CC_STACKPROTECTOR_NONE=y
# CONFIG_CC_STACKPROTECTOR_REGULAR is not set
# CONFIG_CC_STACKPROTECTOR_STRONG is not set
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_HAVE_ARCH_SOFT_DIRTY=y
CONFIG_MODULES_USE_ELF_REL=y
CONFIG_HAVE_SG_CHAIN=y
CONFIG_CLONE_BACKWARDS=y
CONFIG_OLD_SIGSUSPEND3=y
CONFIG_OLD_SIGACTION=y

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
CONFIG_HAVE_GENERIC_DMA_COHERENT=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
CONFIG_SYSTEM_TRUSTED_KEYRING=y
CONFIG_MODULES=y
CONFIG_MODULE_FORCE_LOAD=y
# CONFIG_MODULE_UNLOAD is not set
# CONFIG_MODVERSIONS is not set
# CONFIG_MODULE_SRCVERSION_ALL is not set
CONFIG_MODULE_SIG=y
# CONFIG_MODULE_SIG_FORCE is not set
# CONFIG_MODULE_SIG_ALL is not set
# CONFIG_MODULE_SIG_SHA1 is not set
CONFIG_MODULE_SIG_SHA224=y
# CONFIG_MODULE_SIG_SHA256 is not set
# CONFIG_MODULE_SIG_SHA384 is not set
# CONFIG_MODULE_SIG_SHA512 is not set
CONFIG_MODULE_SIG_HASH="sha224"
CONFIG_BLOCK=y
CONFIG_LBDAF=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
# CONFIG_BLK_DEV_INTEGRITY is not set
CONFIG_BLK_DEV_THROTTLING=y
CONFIG_BLK_CMDLINE_PARSER=y

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
# CONFIG_ACORN_PARTITION is not set
# CONFIG_AIX_PARTITION is not set
CONFIG_OSF_PARTITION=y
CONFIG_AMIGA_PARTITION=y
CONFIG_ATARI_PARTITION=y
CONFIG_MAC_PARTITION=y
# CONFIG_MSDOS_PARTITION is not set
# CONFIG_LDM_PARTITION is not set
# CONFIG_SGI_PARTITION is not set
CONFIG_ULTRIX_PARTITION=y
CONFIG_SUN_PARTITION=y
# CONFIG_KARMA_PARTITION is not set
CONFIG_EFI_PARTITION=y
# CONFIG_SYSV68_PARTITION is not set
# CONFIG_CMDLINE_PARTITION is not set

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_DEADLINE=m
CONFIG_IOSCHED_CFQ=y
CONFIG_CFQ_GROUP_IOSCHED=y
CONFIG_DEFAULT_CFQ=y
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="cfq"
CONFIG_ASN1=y
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_FREEZER=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
# CONFIG_SMP is not set
# CONFIG_X86_MPPARSE is not set
CONFIG_GOLDFISH=y
CONFIG_X86_EXTENDED_PLATFORM=y
CONFIG_X86_GOLDFISH=y
# CONFIG_X86_INTEL_LPSS is not set
CONFIG_X86_RDC321X=y
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
# CONFIG_X86_32_IRIS is not set
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
# CONFIG_XEN_PRIVILEGED_GUEST is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
# CONFIG_LGUEST_GUEST is not set
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
CONFIG_NO_BOOTMEM=y
CONFIG_MEMTEST=y
# CONFIG_M486 is not set
# CONFIG_M586 is not set
# CONFIG_M586TSC is not set
CONFIG_M586MMX=y
# CONFIG_M686 is not set
# CONFIG_MPENTIUMII is not set
# CONFIG_MPENTIUMIII is not set
# CONFIG_MPENTIUMM is not set
# CONFIG_MPENTIUM4 is not set
# CONFIG_MK6 is not set
# CONFIG_MK7 is not set
# CONFIG_MK8 is not set
# CONFIG_MCRUSOE is not set
# CONFIG_MEFFICEON is not set
# CONFIG_MWINCHIPC6 is not set
# CONFIG_MWINCHIP3D is not set
# CONFIG_MELAN is not set
# CONFIG_MGEODEGX1 is not set
# CONFIG_MGEODE_LX is not set
# CONFIG_MCYRIXIII is not set
# CONFIG_MVIAC3_2 is not set
# CONFIG_MVIAC7 is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
CONFIG_X86_GENERIC=y
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_L1_CACHE_SHIFT=6
# CONFIG_X86_PPRO_FENCE is not set
CONFIG_X86_F00F_BUG=y
CONFIG_X86_ALIGNMENT_16=y
CONFIG_X86_INTEL_USERCOPY=y
CONFIG_X86_TSC=y
CONFIG_X86_MINIMUM_CPU_FAMILY=4
CONFIG_PROCESSOR_SELECT=y
# CONFIG_CPU_SUP_INTEL is not set
# CONFIG_CPU_SUP_CYRIX_32 is not set
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
# CONFIG_CPU_SUP_TRANSMETA_32 is not set
# CONFIG_CPU_SUP_UMC_32 is not set
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
# CONFIG_DMI is not set
CONFIG_NR_CPUS=1
CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
# CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
CONFIG_X86_MCE=y
# CONFIG_X86_MCE_INTEL is not set
CONFIG_X86_MCE_AMD=y
# CONFIG_X86_ANCIENT_MCE is not set
CONFIG_X86_MCE_THRESHOLD=y
# CONFIG_X86_MCE_INJECT is not set
CONFIG_VM86=y
# CONFIG_TOSHIBA is not set
CONFIG_I8K=y
CONFIG_X86_REBOOTFIXUPS=y
CONFIG_MICROCODE=y
CONFIG_MICROCODE_INTEL=y
CONFIG_MICROCODE_AMD=y
CONFIG_MICROCODE_OLD_INTERFACE=y
CONFIG_MICROCODE_INTEL_EARLY=y
CONFIG_MICROCODE_AMD_EARLY=y
CONFIG_MICROCODE_EARLY=y
CONFIG_X86_MSR=m
# CONFIG_X86_CPUID is not set
CONFIG_NOHIGHMEM=y
# CONFIG_HIGHMEM4G is not set
# CONFIG_HIGHMEM64G is not set
CONFIG_VMSPLIT_3G=y
# CONFIG_VMSPLIT_3G_OPT is not set
# CONFIG_VMSPLIT_2G is not set
# CONFIG_VMSPLIT_2G_OPT is not set
# CONFIG_VMSPLIT_1G is not set
CONFIG_PAGE_OFFSET=0xC0000000
# CONFIG_X86_PAE is not set
CONFIG_ARCH_FLATMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ILLEGAL_POINTER_VALUE=0
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_FLATMEM_MANUAL=y
# CONFIG_SPARSEMEM_MANUAL is not set
CONFIG_FLATMEM=y
CONFIG_FLAT_NODE_MEM_MAP=y
CONFIG_SPARSEMEM_STATIC=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
# CONFIG_HAVE_BOOTMEM_INFO_NODE is not set
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=4
# CONFIG_BALLOON_COMPACTION is not set
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
# CONFIG_PHYS_ADDR_T_64BIT is not set
CONFIG_ZONE_DMA_FLAG=1
CONFIG_BOUNCE=y
CONFIG_VIRT_TO_BUS=y
# CONFIG_KSM is not set
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
CONFIG_MEMORY_FAILURE=y
CONFIG_HWPOISON_INJECT=y
# CONFIG_TRANSPARENT_HUGEPAGE is not set
CONFIG_CROSS_MEMORY_ATTACH=y
CONFIG_NEED_PER_CPU_KM=y
# CONFIG_CLEANCACHE is not set
# CONFIG_FRONTSWAP is not set
# CONFIG_CMA is not set
# CONFIG_ZBUD is not set
CONFIG_MEM_SOFT_DIRTY=y
# CONFIG_ZSMALLOC is not set
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK=y
CONFIG_X86_RESERVE_LOW=64
CONFIG_MATH_EMULATION=y
CONFIG_MTRR=y
# CONFIG_MTRR_SANITIZER is not set
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
CONFIG_ARCH_RANDOM=y
# CONFIG_X86_SMAP is not set
# CONFIG_EFI is not set
CONFIG_SECCOMP=y
CONFIG_HZ_100=y
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=100
# CONFIG_SCHED_HRTICK is not set
CONFIG_KEXEC=y
CONFIG_KEXEC_JUMP=y
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
CONFIG_X86_NEED_RELOCS=y
CONFIG_PHYSICAL_ALIGN=0x200000
CONFIG_COMPAT_VDSO=y
# CONFIG_CMDLINE_BOOL is not set

#
# Power management and ACPI options
#
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
CONFIG_HIBERNATE_CALLBACKS=y
CONFIG_HIBERNATION=y
CONFIG_PM_STD_PARTITION=""
CONFIG_PM_SLEEP=y
CONFIG_PM_AUTOSLEEP=y
CONFIG_PM_WAKELOCKS=y
CONFIG_PM_WAKELOCKS_LIMIT=100
# CONFIG_PM_WAKELOCKS_GC is not set
CONFIG_PM_RUNTIME=y
CONFIG_PM=y
CONFIG_PM_DEBUG=y
# CONFIG_PM_ADVANCED_DEBUG is not set
# CONFIG_PM_TEST_SUSPEND is not set
CONFIG_PM_SLEEP_DEBUG=y
# CONFIG_DPM_WATCHDOG is not set
# CONFIG_PM_TRACE_RTC is not set
# CONFIG_WQ_POWER_EFFICIENT_DEFAULT is not set
CONFIG_ACPI=y
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_PROCFS is not set
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_VIDEO=m
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_PROCESSOR=y
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
CONFIG_ACPI_THERMAL=y
# CONFIG_ACPI_CUSTOM_DSDT is not set
# CONFIG_ACPI_INITRD_TABLE_OVERRIDE is not set
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
# CONFIG_ACPI_CONTAINER is not set
# CONFIG_ACPI_SBS is not set
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
# CONFIG_ACPI_APEI is not set
# CONFIG_ACPI_EXTLOG is not set
CONFIG_SFI=y
CONFIG_X86_APM_BOOT=y
CONFIG_APM=y
CONFIG_APM_IGNORE_USER_SUSPEND=y
CONFIG_APM_DO_ENABLE=y
# CONFIG_APM_CPU_IDLE is not set
CONFIG_APM_DISPLAY_BLANK=y
CONFIG_APM_ALLOW_INTS=y

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_GOV_COMMON=y
CONFIG_CPU_FREQ_STAT=y
# CONFIG_CPU_FREQ_STAT_DETAILS is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_GOV_POWERSAVE=y
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y

#
# x86 CPU frequency scaling drivers
#
# CONFIG_X86_INTEL_PSTATE is not set
# CONFIG_X86_PCC_CPUFREQ is not set
# CONFIG_X86_ACPI_CPUFREQ is not set
CONFIG_X86_POWERNOW_K6=m
CONFIG_X86_POWERNOW_K7=y
CONFIG_X86_POWERNOW_K7_ACPI=y
# CONFIG_X86_GX_SUSPMOD is not set
# CONFIG_X86_SPEEDSTEP_CENTRINO is not set
# CONFIG_X86_SPEEDSTEP_ICH is not set
CONFIG_X86_SPEEDSTEP_SMI=y
CONFIG_X86_P4_CLOCKMOD=m
CONFIG_X86_CPUFREQ_NFORCE2=y
# CONFIG_X86_LONGRUN is not set
# CONFIG_X86_LONGHAUL is not set
# CONFIG_X86_E_POWERSAVER is not set

#
# shared options
#
CONFIG_X86_SPEEDSTEP_LIB=y
# CONFIG_X86_SPEEDSTEP_RELAXED_CAP_CHECK is not set

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
# CONFIG_CPU_IDLE_MULTIPLE_DRIVERS is not set
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_GOBIOS=y
# CONFIG_PCI_GOMMCONFIG is not set
# CONFIG_PCI_GODIRECT is not set
# CONFIG_PCI_GOOLPC is not set
# CONFIG_PCI_GOANY is not set
CONFIG_PCI_BIOS=y
CONFIG_PCI_DOMAINS=y
CONFIG_PCI_CNB20LE_QUIRK=y
CONFIG_PCIEPORTBUS=y
CONFIG_PCIEAER=y
# CONFIG_PCIE_ECRC is not set
# CONFIG_PCIEAER_INJECT is not set
# CONFIG_PCIEASPM is not set
CONFIG_PCIE_PME=y
CONFIG_PCI_MSI=y
# CONFIG_PCI_DEBUG is not set
CONFIG_PCI_REALLOC_ENABLE_AUTO=y
CONFIG_PCI_STUB=y
# CONFIG_HT_IRQ is not set
CONFIG_PCI_ATS=y
CONFIG_PCI_IOV=y
# CONFIG_PCI_PRI is not set
CONFIG_PCI_PASID=y
# CONFIG_PCI_IOAPIC is not set
CONFIG_PCI_LABEL=y

#
# PCI host controller drivers
#
CONFIG_ISA_DMA_API=y
CONFIG_ISA=y
CONFIG_EISA=y
CONFIG_EISA_VLB_PRIMING=y
CONFIG_EISA_PCI_EISA=y
# CONFIG_EISA_VIRTUAL_ROOT is not set
# CONFIG_EISA_NAMES is not set
CONFIG_SCx200=m
# CONFIG_SCx200HR_TIMER is not set
CONFIG_OLPC=y
# CONFIG_OLPC_XO15_SCI is not set
CONFIG_ALIX=y
# CONFIG_NET5501 is not set
CONFIG_AMD_NB=y
# CONFIG_PCCARD is not set
# CONFIG_HOTPLUG_PCI is not set
# CONFIG_RAPIDIO is not set
# CONFIG_X86_SYSFB is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=y
CONFIG_BINFMT_SCRIPT=y
CONFIG_HAVE_AOUT=y
# CONFIG_BINFMT_AOUT is not set
# CONFIG_BINFMT_MISC is not set
CONFIG_COREDUMP=y
CONFIG_HAVE_ATOMIC_IOMAP=y
CONFIG_NET=y

#
# Networking options
#
# CONFIG_PACKET is not set
CONFIG_UNIX=y
# CONFIG_UNIX_DIAG is not set
# CONFIG_NET_KEY is not set
# CONFIG_INET is not set
# CONFIG_NETWORK_SECMARK is not set
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
# CONFIG_DNS_RESOLVER is not set
# CONFIG_BATMAN_ADV is not set
# CONFIG_OPENVSWITCH is not set
# CONFIG_VSOCKETS is not set
# CONFIG_NETLINK_MMAP is not set
# CONFIG_NETLINK_DIAG is not set
# CONFIG_NET_MPLS_GSO is not set
# CONFIG_HSR is not set
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
# CONFIG_CFG80211 is not set
# CONFIG_LIB80211 is not set

#
# CFG80211 needs to be enabled for MAC80211
#
# CONFIG_WIMAX is not set
# CONFIG_RFKILL is not set
# CONFIG_RFKILL_REGULATOR is not set
# CONFIG_NET_9P is not set
# CONFIG_CAIF is not set
# CONFIG_NFC is not set

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH=""
CONFIG_DEVTMPFS=y
CONFIG_DEVTMPFS_MOUNT=y
CONFIG_STANDALONE=y
# CONFIG_PREVENT_FIRMWARE_BUILD is not set
CONFIG_FW_LOADER=y
CONFIG_FIRMWARE_IN_KERNEL=y
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=m
CONFIG_REGMAP_SPI=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y

#
# Bus devices
#
# CONFIG_CONNECTOR is not set
# CONFIG_MTD is not set
CONFIG_OF=y

#
# Device Tree and Open Firmware support
#
# CONFIG_PROC_DEVICETREE is not set
CONFIG_OF_SELFTEST=y
CONFIG_OF_PROMTREE=y
CONFIG_OF_ADDRESS=y
CONFIG_OF_IRQ=y
CONFIG_OF_PCI=y
CONFIG_OF_PCI_IRQ=y
CONFIG_PARPORT=y
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
# CONFIG_PARPORT_PC is not set
# CONFIG_PARPORT_GSC is not set
# CONFIG_PARPORT_AX88796 is not set
CONFIG_PARPORT_1284=y
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_ISAPNP=y
# CONFIG_PNPBIOS is not set
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
CONFIG_BLK_DEV_NULL_BLK=m
CONFIG_BLK_DEV_FD=y
CONFIG_BLK_DEV_PCIESSD_MTIP32XX=y
CONFIG_BLK_CPQ_CISS_DA=m
# CONFIG_CISS_SCSI_TAPE is not set
CONFIG_BLK_DEV_DAC960=m
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=m
CONFIG_BLK_DEV_LOOP_MIN_COUNT=8
# CONFIG_BLK_DEV_CRYPTOLOOP is not set

#
# DRBD disabled because PROC_FS or INET not selected
#
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_NVME is not set
CONFIG_BLK_DEV_SX8=m
CONFIG_BLK_DEV_RAM=y
CONFIG_BLK_DEV_RAM_COUNT=16
CONFIG_BLK_DEV_RAM_SIZE=4096
# CONFIG_BLK_DEV_XIP is not set
CONFIG_CDROM_PKTCDVD=m
CONFIG_CDROM_PKTCDVD_BUFFERS=8
# CONFIG_CDROM_PKTCDVD_WCACHE is not set
# CONFIG_ATA_OVER_ETH is not set
# CONFIG_VIRTIO_BLK is not set
CONFIG_BLK_DEV_HD=y
# CONFIG_BLK_DEV_RSXX is not set

#
# Misc devices
#
# CONFIG_SENSORS_LIS3LV02D is not set
CONFIG_AD525X_DPOT=y
CONFIG_AD525X_DPOT_I2C=m
CONFIG_AD525X_DPOT_SPI=m
CONFIG_DUMMY_IRQ=m
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
CONFIG_SGI_IOC4=y
CONFIG_TIFM_CORE=m
# CONFIG_TIFM_7XX1 is not set
# CONFIG_ICS932S401 is not set
CONFIG_ATMEL_SSC=y
CONFIG_ENCLOSURE_SERVICES=y
CONFIG_HP_ILO=m
CONFIG_APDS9802ALS=m
# CONFIG_ISL29003 is not set
# CONFIG_ISL29020 is not set
CONFIG_SENSORS_TSL2550=m
CONFIG_SENSORS_BH1780=m
# CONFIG_SENSORS_BH1770 is not set
CONFIG_SENSORS_APDS990X=m
CONFIG_HMC6352=m
CONFIG_DS1682=m
CONFIG_TI_DAC7512=y
# CONFIG_VMWARE_BALLOON is not set
CONFIG_BMP085=y
CONFIG_BMP085_I2C=m
CONFIG_BMP085_SPI=m
CONFIG_PCH_PHUB=m
CONFIG_USB_SWITCH_FSA9480=m
CONFIG_LATTICE_ECP3_CONFIG=m
# CONFIG_SRAM is not set
CONFIG_C2PORT=y
CONFIG_C2PORT_DURAMAR_2150=y

#
# EEPROM support
#
CONFIG_EEPROM_AT24=m
CONFIG_EEPROM_AT25=y
CONFIG_EEPROM_LEGACY=m
# CONFIG_EEPROM_MAX6875 is not set
# CONFIG_EEPROM_93CX6 is not set
# CONFIG_EEPROM_93XX46 is not set
# CONFIG_CB710_CORE is not set

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
# CONFIG_SENSORS_LIS3_I2C is not set

#
# Altera FPGA firmware download module
#
CONFIG_ALTERA_STAPL=m
CONFIG_INTEL_MEI=m
CONFIG_INTEL_MEI_ME=m
CONFIG_VMWARE_VMCI=y

#
# Intel MIC Host Driver
#

#
# Intel MIC Card Driver
#
CONFIG_HAVE_IDE=y
CONFIG_IDE=y

#
# Please see Documentation/ide/ide.txt for help/info on IDE drives
#
CONFIG_IDE_XFER_MODE=y
CONFIG_IDE_TIMINGS=y
CONFIG_IDE_ATAPI=y
CONFIG_IDE_LEGACY=y
# CONFIG_BLK_DEV_IDE_SATA is not set
CONFIG_IDE_GD=y
# CONFIG_IDE_GD_ATA is not set
# CONFIG_IDE_GD_ATAPI is not set
CONFIG_BLK_DEV_IDECD=y
CONFIG_BLK_DEV_IDECD_VERBOSE_ERRORS=y
# CONFIG_BLK_DEV_IDETAPE is not set
# CONFIG_BLK_DEV_IDEACPI is not set
CONFIG_IDE_TASK_IOCTL=y
CONFIG_IDE_PROC_FS=y

#
# IDE chipset support/bugfixes
#
CONFIG_IDE_GENERIC=y
# CONFIG_BLK_DEV_PLATFORM is not set
CONFIG_BLK_DEV_CMD640=m
CONFIG_BLK_DEV_CMD640_ENHANCED=y
# CONFIG_BLK_DEV_IDEPNP is not set
CONFIG_BLK_DEV_IDEDMA_SFF=y

#
# PCI IDE chipsets support
#
CONFIG_BLK_DEV_IDEPCI=y
# CONFIG_IDEPCI_PCIBUS_ORDER is not set
CONFIG_BLK_DEV_OFFBOARD=y
# CONFIG_BLK_DEV_GENERIC is not set
CONFIG_BLK_DEV_OPTI621=y
CONFIG_BLK_DEV_RZ1000=m
CONFIG_BLK_DEV_IDEDMA_PCI=y
CONFIG_BLK_DEV_AEC62XX=m
# CONFIG_BLK_DEV_ALI15X3 is not set
CONFIG_BLK_DEV_AMD74XX=y
CONFIG_BLK_DEV_ATIIXP=y
# CONFIG_BLK_DEV_CMD64X is not set
CONFIG_BLK_DEV_TRIFLEX=y
CONFIG_BLK_DEV_CS5520=m
CONFIG_BLK_DEV_CS5530=m
# CONFIG_BLK_DEV_CS5535 is not set
CONFIG_BLK_DEV_CS5536=m
CONFIG_BLK_DEV_HPT366=m
CONFIG_BLK_DEV_JMICRON=m
CONFIG_BLK_DEV_SC1200=m
CONFIG_BLK_DEV_PIIX=y
CONFIG_BLK_DEV_IT8172=y
# CONFIG_BLK_DEV_IT8213 is not set
CONFIG_BLK_DEV_IT821X=y
CONFIG_BLK_DEV_NS87415=y
CONFIG_BLK_DEV_PDC202XX_OLD=m
CONFIG_BLK_DEV_PDC202XX_NEW=y
# CONFIG_BLK_DEV_SVWKS is not set
CONFIG_BLK_DEV_SIIMAGE=m
# CONFIG_BLK_DEV_SIS5513 is not set
CONFIG_BLK_DEV_SLC90E66=y
CONFIG_BLK_DEV_TRM290=m
CONFIG_BLK_DEV_VIA82CXXX=y
CONFIG_BLK_DEV_TC86C001=m

#
# Other IDE chipsets support
#

#
# Note: most of these also require special kernel boot parameters
#
CONFIG_BLK_DEV_4DRIVES=y
CONFIG_BLK_DEV_ALI14XX=m
CONFIG_BLK_DEV_DTC2278=y
CONFIG_BLK_DEV_HT6560B=m
CONFIG_BLK_DEV_QD65XX=y
CONFIG_BLK_DEV_UMC8672=m
CONFIG_BLK_DEV_IDEDMA=y

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
# CONFIG_RAID_ATTRS is not set
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
CONFIG_SCSI_TGT=y
# CONFIG_SCSI_NETLINK is not set
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
# CONFIG_BLK_DEV_SD is not set
CONFIG_CHR_DEV_ST=m
CONFIG_CHR_DEV_OSST=y
CONFIG_BLK_DEV_SR=m
# CONFIG_BLK_DEV_SR_VENDOR is not set
CONFIG_CHR_DEV_SG=y
CONFIG_CHR_DEV_SCH=m
CONFIG_SCSI_ENCLOSURE=m
CONFIG_SCSI_MULTI_LUN=y
CONFIG_SCSI_CONSTANTS=y
CONFIG_SCSI_LOGGING=y
CONFIG_SCSI_SCAN_ASYNC=y

#
# SCSI Transports
#
# CONFIG_SCSI_SPI_ATTRS is not set
# CONFIG_SCSI_FC_ATTRS is not set
# CONFIG_SCSI_ISCSI_ATTRS is not set
CONFIG_SCSI_SAS_ATTRS=m
CONFIG_SCSI_SAS_LIBSAS=m
# CONFIG_SCSI_SAS_HOST_SMP is not set
# CONFIG_SCSI_SRP_ATTRS is not set
# CONFIG_SCSI_LOWLEVEL is not set
CONFIG_SCSI_DH=y
CONFIG_SCSI_DH_RDAC=m
CONFIG_SCSI_DH_HP_SW=y
CONFIG_SCSI_DH_EMC=m
# CONFIG_SCSI_DH_ALUA is not set
# CONFIG_SCSI_OSD_INITIATOR is not set
# CONFIG_ATA is not set
# CONFIG_MD is not set
CONFIG_TARGET_CORE=y
# CONFIG_TCM_IBLOCK is not set
# CONFIG_TCM_FILEIO is not set
CONFIG_TCM_PSCSI=y
# CONFIG_LOOPBACK_TARGET is not set
# CONFIG_ISCSI_TARGET is not set
# CONFIG_SBP_TARGET is not set
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
CONFIG_FIREWIRE=m
# CONFIG_FIREWIRE_OHCI is not set
CONFIG_FIREWIRE_SBP2=m
# CONFIG_FIREWIRE_NOSY is not set
CONFIG_I2O=m
# CONFIG_I2O_LCT_NOTIFY_ON_CHANGES is not set
# CONFIG_I2O_EXT_ADAPTEC is not set
CONFIG_I2O_CONFIG=m
CONFIG_I2O_CONFIG_OLD_IOCTL=y
CONFIG_I2O_BUS=m
CONFIG_I2O_BLOCK=m
CONFIG_I2O_SCSI=m
# CONFIG_I2O_PROC is not set
# CONFIG_MACINTOSH_DRIVERS is not set
# CONFIG_NETDEVICES is not set
# CONFIG_VHOST_NET is not set
CONFIG_VHOST_SCSI=m
CONFIG_VHOST_RING=m
CONFIG_VHOST=m

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_FF_MEMLESS=m
CONFIG_INPUT_POLLDEV=y
CONFIG_INPUT_SPARSEKMAP=y
# CONFIG_INPUT_MATRIXKMAP is not set

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
CONFIG_INPUT_MOUSEDEV_PSAUX=y
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
# CONFIG_INPUT_JOYDEV is not set
CONFIG_INPUT_EVDEV=m
CONFIG_INPUT_EVBUG=y

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
# CONFIG_KEYBOARD_GOLDFISH_EVENTS is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_KEYBOARD_CROS_EC is not set
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=m
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
# CONFIG_MOUSE_PS2_CYPRESS is not set
# CONFIG_MOUSE_PS2_TRACKPOINT is not set
CONFIG_MOUSE_PS2_ELANTECH=y
CONFIG_MOUSE_PS2_SENTELIC=y
CONFIG_MOUSE_PS2_TOUCHKIT=y
CONFIG_MOUSE_PS2_OLPC=y
# CONFIG_MOUSE_SERIAL is not set
CONFIG_MOUSE_APPLETOUCH=y
CONFIG_MOUSE_BCM5974=m
CONFIG_MOUSE_CYAPA=m
CONFIG_MOUSE_INPORT=y
# CONFIG_MOUSE_ATIXL is not set
CONFIG_MOUSE_LOGIBM=m
CONFIG_MOUSE_PC110PAD=y
# CONFIG_MOUSE_VSXXXAA is not set
CONFIG_MOUSE_GPIO=y
CONFIG_MOUSE_SYNAPTICS_I2C=m
# CONFIG_MOUSE_SYNAPTICS_USB is not set
CONFIG_INPUT_JOYSTICK=y
CONFIG_JOYSTICK_ANALOG=y
CONFIG_JOYSTICK_A3D=m
CONFIG_JOYSTICK_ADI=m
CONFIG_JOYSTICK_COBRA=m
CONFIG_JOYSTICK_GF2K=m
# CONFIG_JOYSTICK_GRIP is not set
CONFIG_JOYSTICK_GRIP_MP=y
CONFIG_JOYSTICK_GUILLEMOT=y
CONFIG_JOYSTICK_INTERACT=m
CONFIG_JOYSTICK_SIDEWINDER=y
CONFIG_JOYSTICK_TMDC=y
CONFIG_JOYSTICK_IFORCE=m
CONFIG_JOYSTICK_IFORCE_USB=y
# CONFIG_JOYSTICK_IFORCE_232 is not set
CONFIG_JOYSTICK_WARRIOR=m
# CONFIG_JOYSTICK_MAGELLAN is not set
CONFIG_JOYSTICK_SPACEORB=y
CONFIG_JOYSTICK_SPACEBALL=y
CONFIG_JOYSTICK_STINGER=m
# CONFIG_JOYSTICK_TWIDJOY is not set
CONFIG_JOYSTICK_ZHENHUA=y
# CONFIG_JOYSTICK_DB9 is not set
# CONFIG_JOYSTICK_GAMECON is not set
# CONFIG_JOYSTICK_TURBOGRAFX is not set
CONFIG_JOYSTICK_AS5011=m
# CONFIG_JOYSTICK_JOYDUMP is not set
CONFIG_JOYSTICK_XPAD=y
# CONFIG_JOYSTICK_XPAD_FF is not set
# CONFIG_JOYSTICK_XPAD_LEDS is not set
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
CONFIG_INPUT_MISC=y
CONFIG_INPUT_AD714X=m
CONFIG_INPUT_AD714X_I2C=m
CONFIG_INPUT_AD714X_SPI=m
CONFIG_INPUT_BMA150=m
CONFIG_INPUT_PCSPKR=m
# CONFIG_INPUT_MC13783_PWRBUTTON is not set
# CONFIG_INPUT_MMA8450 is not set
# CONFIG_INPUT_MPU3050 is not set
CONFIG_INPUT_APANEL=m
# CONFIG_INPUT_GP2A is not set
CONFIG_INPUT_GPIO_BEEPER=m
CONFIG_INPUT_GPIO_TILT_POLLED=m
# CONFIG_INPUT_WISTRON_BTNS is not set
# CONFIG_INPUT_ATLAS_BTNS is not set
CONFIG_INPUT_ATI_REMOTE2=m
CONFIG_INPUT_KEYSPAN_REMOTE=m
CONFIG_INPUT_KXTJ9=m
CONFIG_INPUT_KXTJ9_POLLED_MODE=y
CONFIG_INPUT_POWERMATE=m
CONFIG_INPUT_YEALINK=m
# CONFIG_INPUT_CM109 is not set
CONFIG_INPUT_RETU_PWRBUTTON=m
# CONFIG_INPUT_UINPUT is not set
CONFIG_INPUT_PCF8574=m
# CONFIG_INPUT_GPIO_ROTARY_ENCODER is not set
CONFIG_INPUT_DA9052_ONKEY=m
CONFIG_INPUT_WM831X_ON=m
CONFIG_INPUT_PCAP=y
# CONFIG_INPUT_ADXL34X is not set
CONFIG_INPUT_IMS_PCU=y
CONFIG_INPUT_CMA3000=y
# CONFIG_INPUT_CMA3000_I2C is not set
CONFIG_INPUT_IDEAPAD_SLIDEBAR=m

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
# CONFIG_SERIO_CT82C710 is not set
CONFIG_SERIO_PARKBD=y
CONFIG_SERIO_PCIPS2=m
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=y
# CONFIG_SERIO_ALTERA_PS2 is not set
CONFIG_SERIO_PS2MULT=y
CONFIG_SERIO_ARC_PS2=y
# CONFIG_SERIO_APBPS2 is not set
# CONFIG_SERIO_OLPC_APSP is not set
CONFIG_GAMEPORT=y
CONFIG_GAMEPORT_NS558=y
CONFIG_GAMEPORT_L4=y
# CONFIG_GAMEPORT_EMU10K1 is not set
# CONFIG_GAMEPORT_FM801 is not set

#
# Character devices
#
CONFIG_TTY=y
# CONFIG_VT is not set
CONFIG_UNIX98_PTYS=y
# CONFIG_DEVPTS_MULTIPLE_INSTANCES is not set
# CONFIG_LEGACY_PTYS is not set
# CONFIG_SERIAL_NONSTANDARD is not set
CONFIG_NOZOMI=m
# CONFIG_N_GSM is not set
# CONFIG_TRACE_SINK is not set
# CONFIG_GOLDFISH_TTY is not set
CONFIG_DEVKMEM=y

#
# Serial drivers
#
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_DEPRECATED_OPTIONS=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
# CONFIG_SERIAL_8250_MANY_PORTS is not set
CONFIG_SERIAL_8250_SHARE_IRQ=y
# CONFIG_SERIAL_8250_DETECT_IRQ is not set
CONFIG_SERIAL_8250_RSA=y
CONFIG_SERIAL_8250_DW=y

#
# Non-8250 serial port support
#
CONFIG_SERIAL_MAX3100=y
CONFIG_SERIAL_MAX310X=y
CONFIG_SERIAL_MFD_HSU=y
# CONFIG_SERIAL_MFD_HSU_CONSOLE is not set
# CONFIG_SERIAL_UARTLITE is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
CONFIG_SERIAL_JSM=y
CONFIG_SERIAL_OF_PLATFORM=m
CONFIG_SERIAL_SCCNXP=y
# CONFIG_SERIAL_SCCNXP_CONSOLE is not set
CONFIG_SERIAL_TIMBERDALE=y
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
CONFIG_SERIAL_ALTERA_UART=m
CONFIG_SERIAL_ALTERA_UART_MAXPORTS=4
CONFIG_SERIAL_ALTERA_UART_BAUDRATE=115200
CONFIG_SERIAL_IFX6X60=y
# CONFIG_SERIAL_PCH_UART is not set
CONFIG_SERIAL_XILINX_PS_UART=y
# CONFIG_SERIAL_XILINX_PS_UART_CONSOLE is not set
# CONFIG_SERIAL_ARC is not set
# CONFIG_SERIAL_RP2 is not set
CONFIG_SERIAL_FSL_LPUART=y
# CONFIG_SERIAL_FSL_LPUART_CONSOLE is not set
CONFIG_TTY_PRINTK=y
CONFIG_PRINTER=y
# CONFIG_LP_CONSOLE is not set
CONFIG_PPDEV=y
CONFIG_HVC_DRIVER=y
CONFIG_VIRTIO_CONSOLE=y
# CONFIG_IPMI_HANDLER is not set
CONFIG_HW_RANDOM=y
CONFIG_HW_RANDOM_TIMERIOMEM=m
CONFIG_HW_RANDOM_INTEL=y
CONFIG_HW_RANDOM_AMD=y
CONFIG_HW_RANDOM_GEODE=y
# CONFIG_HW_RANDOM_VIA is not set
# CONFIG_HW_RANDOM_VIRTIO is not set
CONFIG_HW_RANDOM_TPM=m
CONFIG_NVRAM=m
CONFIG_DTLK=y
CONFIG_R3964=m
# CONFIG_APPLICOM is not set
CONFIG_SONYPI=y
CONFIG_MWAVE=y
CONFIG_SCx200_GPIO=m
CONFIG_PC8736x_GPIO=m
CONFIG_NSC_GPIO=m
# CONFIG_RAW_DRIVER is not set
# CONFIG_HPET is not set
CONFIG_HANGCHECK_TIMER=y
CONFIG_TCG_TPM=m
CONFIG_TCG_TIS=m
CONFIG_TCG_TIS_I2C_ATMEL=m
CONFIG_TCG_TIS_I2C_INFINEON=m
CONFIG_TCG_TIS_I2C_NUVOTON=m
CONFIG_TCG_NSC=m
CONFIG_TCG_ATMEL=m
# CONFIG_TCG_INFINEON is not set
CONFIG_TCG_ST33_I2C=m
CONFIG_TELCLOCK=y
CONFIG_DEVPORT=y
CONFIG_I2C=m
CONFIG_I2C_BOARDINFO=y
# CONFIG_I2C_COMPAT is not set
CONFIG_I2C_CHARDEV=m
CONFIG_I2C_MUX=m

#
# Multiplexer I2C Chip support
#
CONFIG_I2C_ARB_GPIO_CHALLENGE=m
CONFIG_I2C_MUX_GPIO=m
# CONFIG_I2C_MUX_PCA9541 is not set
# CONFIG_I2C_MUX_PCA954x is not set
# CONFIG_I2C_HELPER_AUTO is not set
CONFIG_I2C_SMBUS=m

#
# I2C Algorithms
#
CONFIG_I2C_ALGOBIT=m
CONFIG_I2C_ALGOPCF=m
CONFIG_I2C_ALGOPCA=m

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
CONFIG_I2C_ALI1535=m
CONFIG_I2C_ALI1563=m
CONFIG_I2C_ALI15X3=m
CONFIG_I2C_AMD756=m
CONFIG_I2C_AMD756_S4882=m
CONFIG_I2C_AMD8111=m
CONFIG_I2C_I801=m
CONFIG_I2C_ISCH=m
CONFIG_I2C_ISMT=m
CONFIG_I2C_PIIX4=m
CONFIG_I2C_NFORCE2=m
# CONFIG_I2C_NFORCE2_S4985 is not set
CONFIG_I2C_SIS5595=m
# CONFIG_I2C_SIS630 is not set
CONFIG_I2C_SIS96X=m
CONFIG_I2C_VIA=m
CONFIG_I2C_VIAPRO=m

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
# CONFIG_I2C_CBUS_GPIO is not set
CONFIG_I2C_DESIGNWARE_CORE=m
# CONFIG_I2C_DESIGNWARE_PLATFORM is not set
CONFIG_I2C_DESIGNWARE_PCI=m
CONFIG_I2C_EG20T=m
CONFIG_I2C_GPIO=m
CONFIG_I2C_OCORES=m
CONFIG_I2C_PCA_PLATFORM=m
# CONFIG_I2C_PXA is not set
# CONFIG_I2C_PXA_PCI is not set
# CONFIG_I2C_SIMTEC is not set
CONFIG_I2C_XILINX=m

#
# External I2C/SMBus adapter drivers
#
# CONFIG_I2C_DIOLAN_U2C is not set
CONFIG_I2C_PARPORT=m
CONFIG_I2C_PARPORT_LIGHT=m
CONFIG_I2C_ROBOTFUZZ_OSIF=m
# CONFIG_I2C_TAOS_EVM is not set
# CONFIG_I2C_TINY_USB is not set
CONFIG_I2C_VIPERBOARD=m

#
# Other I2C/SMBus bus drivers
#
# CONFIG_I2C_ELEKTOR is not set
# CONFIG_I2C_PCA_ISA is not set
# CONFIG_SCx200_I2C is not set
# CONFIG_SCx200_ACB is not set
CONFIG_I2C_STUB=m
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
CONFIG_SPI=y
CONFIG_SPI_DEBUG=y
CONFIG_SPI_MASTER=y

#
# SPI Master Controller Drivers
#
CONFIG_SPI_ALTERA=y
CONFIG_SPI_BITBANG=y
CONFIG_SPI_BUTTERFLY=m
# CONFIG_SPI_GPIO is not set
# CONFIG_SPI_LM70_LLP is not set
# CONFIG_SPI_FSL_SPI is not set
CONFIG_SPI_OC_TINY=m
# CONFIG_SPI_PXA2XX is not set
# CONFIG_SPI_PXA2XX_PCI is not set
CONFIG_SPI_SC18IS602=m
# CONFIG_SPI_TOPCLIFF_PCH is not set
CONFIG_SPI_XCOMM=m
# CONFIG_SPI_XILINX is not set
# CONFIG_SPI_DESIGNWARE is not set

#
# SPI Protocol Masters
#
# CONFIG_SPI_SPIDEV is not set
CONFIG_SPI_TLE62X0=m
CONFIG_HSI=m
CONFIG_HSI_BOARDINFO=y

#
# HSI clients
#
CONFIG_HSI_CHAR=m

#
# PPS support
#
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set
# CONFIG_NTP_PPS is not set

#
# PPS clients support
#
# CONFIG_PPS_CLIENT_KTIMER is not set
CONFIG_PPS_CLIENT_LDISC=m
CONFIG_PPS_CLIENT_PARPORT=y
CONFIG_PPS_CLIENT_GPIO=m

#
# PPS generators support
#

#
# PTP clock support
#
CONFIG_PTP_1588_CLOCK=m

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
CONFIG_PTP_1588_CLOCK_PCH=m
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
CONFIG_GPIOLIB=y
CONFIG_GPIO_DEVRES=y
CONFIG_OF_GPIO=y
CONFIG_GPIO_ACPI=y
# CONFIG_DEBUG_GPIO is not set
# CONFIG_GPIO_SYSFS is not set
CONFIG_GPIO_GENERIC=m
CONFIG_GPIO_DA9052=y
CONFIG_GPIO_MAX730X=m

#
# Memory mapped GPIO drivers:
#
CONFIG_GPIO_GENERIC_PLATFORM=m
CONFIG_GPIO_IT8761E=y
CONFIG_GPIO_F7188X=y
# CONFIG_GPIO_SCH311X is not set
# CONFIG_GPIO_TS5500 is not set
CONFIG_GPIO_SCH=m
# CONFIG_GPIO_ICH is not set
# CONFIG_GPIO_VX855 is not set
# CONFIG_GPIO_LYNXPOINT is not set
# CONFIG_GPIO_GRGPIO is not set

#
# I2C GPIO expanders:
#
CONFIG_GPIO_ARIZONA=y
CONFIG_GPIO_LP3943=m
CONFIG_GPIO_MAX7300=m
# CONFIG_GPIO_MAX732X is not set
CONFIG_GPIO_PCA953X=m
CONFIG_GPIO_PCF857X=m
CONFIG_GPIO_TPS65912=y
CONFIG_GPIO_WM831X=m
CONFIG_GPIO_ADP5588=m
CONFIG_GPIO_ADNP=m

#
# PCI GPIO expanders:
#
CONFIG_GPIO_BT8XX=m
CONFIG_GPIO_AMD8111=m
CONFIG_GPIO_INTEL_MID=y
CONFIG_GPIO_PCH=y
CONFIG_GPIO_ML_IOH=y
# CONFIG_GPIO_SODAVILLE is not set
CONFIG_GPIO_TIMBERDALE=y
# CONFIG_GPIO_RDC321X is not set

#
# SPI GPIO expanders:
#
CONFIG_GPIO_MAX7301=m
CONFIG_GPIO_MCP23S08=m
CONFIG_GPIO_MC33880=y
CONFIG_GPIO_74X164=m

#
# AC97 GPIO expanders:
#

#
# LPC GPIO expanders:
#

#
# MODULbus GPIO expanders:
#
CONFIG_GPIO_JANZ_TTL=m
# CONFIG_GPIO_BCM_KONA is not set

#
# USB GPIO expanders:
#
CONFIG_GPIO_VIPERBOARD=m
CONFIG_W1=y

#
# 1-wire Bus Masters
#
# CONFIG_W1_MASTER_MATROX is not set
# CONFIG_W1_MASTER_DS2490 is not set
CONFIG_W1_MASTER_DS2482=m
CONFIG_W1_MASTER_DS1WM=m
CONFIG_W1_MASTER_GPIO=m

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=m
CONFIG_W1_SLAVE_SMEM=m
CONFIG_W1_SLAVE_DS2408=m
CONFIG_W1_SLAVE_DS2408_READBACK=y
CONFIG_W1_SLAVE_DS2413=m
CONFIG_W1_SLAVE_DS2423=y
# CONFIG_W1_SLAVE_DS2431 is not set
CONFIG_W1_SLAVE_DS2433=m
CONFIG_W1_SLAVE_DS2433_CRC=y
CONFIG_W1_SLAVE_DS2760=y
CONFIG_W1_SLAVE_DS2780=y
CONFIG_W1_SLAVE_DS2781=y
# CONFIG_W1_SLAVE_DS28E04 is not set
CONFIG_W1_SLAVE_BQ27000=m
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
CONFIG_PDA_POWER=y
# CONFIG_GENERIC_ADC_BATTERY is not set
CONFIG_WM831X_BACKUP=y
# CONFIG_WM831X_POWER is not set
CONFIG_TEST_POWER=m
# CONFIG_BATTERY_DS2760 is not set
CONFIG_BATTERY_DS2780=y
CONFIG_BATTERY_DS2781=m
CONFIG_BATTERY_DS2782=m
CONFIG_BATTERY_OLPC=m
CONFIG_BATTERY_SBS=m
CONFIG_BATTERY_BQ27x00=m
CONFIG_BATTERY_BQ27X00_I2C=y
# CONFIG_BATTERY_BQ27X00_PLATFORM is not set
# CONFIG_BATTERY_DA9052 is not set
# CONFIG_BATTERY_MAX17040 is not set
CONFIG_BATTERY_MAX17042=m
CONFIG_CHARGER_ISP1704=y
CONFIG_CHARGER_MAX8903=y
CONFIG_CHARGER_LP8727=m
CONFIG_CHARGER_GPIO=m
CONFIG_CHARGER_MANAGER=y
CONFIG_CHARGER_BQ2415X=m
# CONFIG_CHARGER_BQ24190 is not set
# CONFIG_CHARGER_BQ24735 is not set
# CONFIG_CHARGER_SMB347 is not set
CONFIG_BATTERY_GOLDFISH=m
# CONFIG_POWER_RESET is not set
CONFIG_POWER_AVS=y
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
CONFIG_SENSORS_AD7314=m
CONFIG_SENSORS_AD7414=m
# CONFIG_SENSORS_AD7418 is not set
# CONFIG_SENSORS_ADCXX is not set
CONFIG_SENSORS_ADM1021=m
CONFIG_SENSORS_ADM1025=m
# CONFIG_SENSORS_ADM1026 is not set
CONFIG_SENSORS_ADM1029=m
CONFIG_SENSORS_ADM1031=m
CONFIG_SENSORS_ADM9240=m
CONFIG_SENSORS_ADT7X10=y
CONFIG_SENSORS_ADT7310=y
# CONFIG_SENSORS_ADT7410 is not set
CONFIG_SENSORS_ADT7411=m
# CONFIG_SENSORS_ADT7462 is not set
# CONFIG_SENSORS_ADT7470 is not set
CONFIG_SENSORS_ADT7475=m
CONFIG_SENSORS_ASC7621=m
# CONFIG_SENSORS_K8TEMP is not set
CONFIG_SENSORS_K10TEMP=y
CONFIG_SENSORS_FAM15H_POWER=y
# CONFIG_SENSORS_ASB100 is not set
CONFIG_SENSORS_ATXP1=m
# CONFIG_SENSORS_DS620 is not set
CONFIG_SENSORS_DS1621=m
CONFIG_SENSORS_DA9052_ADC=y
CONFIG_SENSORS_I5K_AMB=m
# CONFIG_SENSORS_F71805F is not set
# CONFIG_SENSORS_F71882FG is not set
CONFIG_SENSORS_F75375S=m
# CONFIG_SENSORS_FSCHMD is not set
CONFIG_SENSORS_G760A=m
CONFIG_SENSORS_G762=m
# CONFIG_SENSORS_GL518SM is not set
# CONFIG_SENSORS_GL520SM is not set
# CONFIG_SENSORS_GPIO_FAN is not set
CONFIG_SENSORS_HIH6130=m
CONFIG_SENSORS_HTU21=m
CONFIG_SENSORS_CORETEMP=y
CONFIG_SENSORS_IIO_HWMON=m
CONFIG_SENSORS_IT87=y
CONFIG_SENSORS_JC42=m
CONFIG_SENSORS_LINEAGE=m
CONFIG_SENSORS_LM63=m
CONFIG_SENSORS_LM70=y
CONFIG_SENSORS_LM73=m
CONFIG_SENSORS_LM75=m
CONFIG_SENSORS_LM77=m
CONFIG_SENSORS_LM78=m
# CONFIG_SENSORS_LM80 is not set
# CONFIG_SENSORS_LM83 is not set
# CONFIG_SENSORS_LM85 is not set
CONFIG_SENSORS_LM87=m
CONFIG_SENSORS_LM90=m
# CONFIG_SENSORS_LM92 is not set
CONFIG_SENSORS_LM93=m
CONFIG_SENSORS_LTC4151=m
CONFIG_SENSORS_LTC4215=m
CONFIG_SENSORS_LTC4245=m
CONFIG_SENSORS_LTC4261=m
CONFIG_SENSORS_LM95234=m
CONFIG_SENSORS_LM95241=m
# CONFIG_SENSORS_LM95245 is not set
CONFIG_SENSORS_MAX1111=m
CONFIG_SENSORS_MAX16065=m
# CONFIG_SENSORS_MAX1619 is not set
CONFIG_SENSORS_MAX1668=m
CONFIG_SENSORS_MAX197=y
# CONFIG_SENSORS_MAX6639 is not set
CONFIG_SENSORS_MAX6642=m
# CONFIG_SENSORS_MAX6650 is not set
# CONFIG_SENSORS_MAX6697 is not set
CONFIG_SENSORS_MCP3021=m
# CONFIG_SENSORS_NCT6775 is not set
CONFIG_SENSORS_NTC_THERMISTOR=m
# CONFIG_SENSORS_PC87360 is not set
CONFIG_SENSORS_PC87427=m
CONFIG_SENSORS_PCF8591=m
CONFIG_PMBUS=m
# CONFIG_SENSORS_PMBUS is not set
CONFIG_SENSORS_ADM1275=m
# CONFIG_SENSORS_LM25066 is not set
CONFIG_SENSORS_LTC2978=m
CONFIG_SENSORS_MAX16064=m
CONFIG_SENSORS_MAX34440=m
# CONFIG_SENSORS_MAX8688 is not set
# CONFIG_SENSORS_UCD9000 is not set
# CONFIG_SENSORS_UCD9200 is not set
# CONFIG_SENSORS_ZL6100 is not set
CONFIG_SENSORS_SHT15=y
CONFIG_SENSORS_SHT21=m
CONFIG_SENSORS_SIS5595=m
# CONFIG_SENSORS_SMM665 is not set
CONFIG_SENSORS_DME1737=m
CONFIG_SENSORS_EMC1403=m
CONFIG_SENSORS_EMC2103=m
CONFIG_SENSORS_EMC6W201=m
CONFIG_SENSORS_SMSC47M1=m
# CONFIG_SENSORS_SMSC47M192 is not set
CONFIG_SENSORS_SMSC47B397=m
CONFIG_SENSORS_SCH56XX_COMMON=y
# CONFIG_SENSORS_SCH5627 is not set
CONFIG_SENSORS_SCH5636=y
CONFIG_SENSORS_ADS1015=m
# CONFIG_SENSORS_ADS7828 is not set
CONFIG_SENSORS_ADS7871=y
# CONFIG_SENSORS_AMC6821 is not set
# CONFIG_SENSORS_INA209 is not set
CONFIG_SENSORS_INA2XX=m
# CONFIG_SENSORS_THMC50 is not set
CONFIG_SENSORS_TMP102=m
# CONFIG_SENSORS_TMP401 is not set
CONFIG_SENSORS_TMP421=m
CONFIG_SENSORS_VIA_CPUTEMP=y
CONFIG_SENSORS_VIA686A=m
# CONFIG_SENSORS_VT1211 is not set
CONFIG_SENSORS_VT8231=m
CONFIG_SENSORS_W83781D=m
CONFIG_SENSORS_W83791D=m
CONFIG_SENSORS_W83792D=m
# CONFIG_SENSORS_W83793 is not set
CONFIG_SENSORS_W83795=m
# CONFIG_SENSORS_W83795_FANCTRL is not set
CONFIG_SENSORS_W83L785TS=m
CONFIG_SENSORS_W83L786NG=m
CONFIG_SENSORS_W83627HF=m
CONFIG_SENSORS_W83627EHF=m
CONFIG_SENSORS_WM831X=y
CONFIG_SENSORS_APPLESMC=y
CONFIG_SENSORS_MC13783_ADC=m

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
CONFIG_THERMAL_HWMON=y
CONFIG_THERMAL_OF=y
CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE=y
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_THERMAL_GOV_FAIR_SHARE is not set
CONFIG_THERMAL_GOV_STEP_WISE=y
# CONFIG_THERMAL_GOV_USER_SPACE is not set
# CONFIG_CPU_THERMAL is not set
# CONFIG_THERMAL_EMULATION is not set
# CONFIG_ACPI_INT3403_THERMAL is not set

#
# Texas Instruments thermal drivers
#
CONFIG_WATCHDOG=y
CONFIG_WATCHDOG_CORE=y
# CONFIG_WATCHDOG_NOWAYOUT is not set

#
# Watchdog Device Drivers
#
# CONFIG_SOFT_WATCHDOG is not set
# CONFIG_DA9052_WATCHDOG is not set
CONFIG_GPIO_WATCHDOG=m
CONFIG_WM831X_WATCHDOG=y
# CONFIG_DW_WATCHDOG is not set
# CONFIG_RETU_WATCHDOG is not set
CONFIG_ACQUIRE_WDT=y
CONFIG_ADVANTECH_WDT=m
CONFIG_ALIM1535_WDT=y
# CONFIG_ALIM7101_WDT is not set
# CONFIG_F71808E_WDT is not set
CONFIG_SP5100_TCO=m
CONFIG_SC520_WDT=y
# CONFIG_SBC_FITPC2_WATCHDOG is not set
# CONFIG_EUROTECH_WDT is not set
CONFIG_IB700_WDT=y
# CONFIG_IBMASR is not set
CONFIG_WAFER_WDT=y
CONFIG_I6300ESB_WDT=y
# CONFIG_IE6XX_WDT is not set
# CONFIG_ITCO_WDT is not set
CONFIG_IT8712F_WDT=y
CONFIG_IT87_WDT=m
# CONFIG_HP_WATCHDOG is not set
# CONFIG_SC1200_WDT is not set
CONFIG_SCx200_WDT=m
CONFIG_PC87413_WDT=m
CONFIG_NV_TCO=m
CONFIG_RDC321X_WDT=m
CONFIG_60XX_WDT=y
CONFIG_SBC8360_WDT=m
CONFIG_SBC7240_WDT=y
CONFIG_CPU5_WDT=y
CONFIG_SMSC_SCH311X_WDT=m
CONFIG_SMSC37B787_WDT=y
# CONFIG_VIA_WDT is not set
# CONFIG_W83627HF_WDT is not set
CONFIG_W83697HF_WDT=m
# CONFIG_W83697UG_WDT is not set
# CONFIG_W83877F_WDT is not set
CONFIG_W83977F_WDT=m
CONFIG_MACHZ_WDT=m
CONFIG_SBC_EPX_C3_WATCHDOG=y
CONFIG_MEN_A21_WDT=y

#
# ISA-based Watchdog Cards
#
# CONFIG_PCWATCHDOG is not set
# CONFIG_MIXCOMWD is not set
# CONFIG_WDT is not set

#
# PCI-based Watchdog Cards
#
CONFIG_PCIPCWATCHDOG=y
CONFIG_WDTPCI=m

#
# USB-based Watchdog Cards
#
CONFIG_USBPCWATCHDOG=y
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
CONFIG_SSB=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
# CONFIG_SSB_PCIHOST is not set
# CONFIG_SSB_SILENT is not set
CONFIG_SSB_DEBUG=y
CONFIG_SSB_DRIVER_GPIO=y
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
# CONFIG_BCMA is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
# CONFIG_MFD_CS5535 is not set
CONFIG_MFD_CROS_EC=m
CONFIG_MFD_CROS_EC_I2C=m
CONFIG_MFD_CROS_EC_SPI=m
CONFIG_PMIC_DA9052=y
CONFIG_MFD_DA9052_SPI=y
CONFIG_MFD_MC13XXX=m
CONFIG_MFD_MC13XXX_SPI=m
CONFIG_MFD_MC13XXX_I2C=m
# CONFIG_HTC_PASIC3 is not set
CONFIG_LPC_ICH=y
CONFIG_LPC_SCH=y
CONFIG_MFD_JANZ_CMODIO=m
# CONFIG_MFD_KEMPLD is not set
CONFIG_EZX_PCAP=y
CONFIG_MFD_VIPERBOARD=y
CONFIG_MFD_RETU=m
# CONFIG_MFD_PCF50633 is not set
CONFIG_MFD_RDC321X=m
# CONFIG_MFD_RTSX_PCI is not set
CONFIG_MFD_SI476X_CORE=m
# CONFIG_MFD_SM501 is not set
CONFIG_ABX500_CORE=y
# CONFIG_MFD_STMPE is not set
CONFIG_MFD_SYSCON=y
CONFIG_MFD_TI_AM335X_TSCADC=m
CONFIG_MFD_LP3943=m
# CONFIG_TPS6105X is not set
# CONFIG_TPS65010 is not set
# CONFIG_TPS6507X is not set
CONFIG_MFD_TPS65217=m
CONFIG_MFD_TPS65912=y
CONFIG_MFD_TPS65912_SPI=y
# CONFIG_MFD_WL1273_CORE is not set
CONFIG_MFD_LM3533=m
CONFIG_MFD_TIMBERDALE=m
# CONFIG_MFD_TMIO is not set
# CONFIG_MFD_VX855 is not set
CONFIG_MFD_ARIZONA=y
CONFIG_MFD_ARIZONA_I2C=m
# CONFIG_MFD_ARIZONA_SPI is not set
# CONFIG_MFD_WM5102 is not set
CONFIG_MFD_WM5110=y
# CONFIG_MFD_WM8997 is not set
CONFIG_MFD_WM831X=y
CONFIG_MFD_WM831X_SPI=y
CONFIG_REGULATOR=y
CONFIG_REGULATOR_DEBUG=y
CONFIG_REGULATOR_FIXED_VOLTAGE=m
CONFIG_REGULATOR_VIRTUAL_CONSUMER=y
CONFIG_REGULATOR_USERSPACE_CONSUMER=y
# CONFIG_REGULATOR_ACT8865 is not set
CONFIG_REGULATOR_AD5398=m
CONFIG_REGULATOR_ANATOP=m
# CONFIG_REGULATOR_DA9052 is not set
# CONFIG_REGULATOR_DA9210 is not set
CONFIG_REGULATOR_FAN53555=m
CONFIG_REGULATOR_GPIO=y
CONFIG_REGULATOR_ISL6271A=m
# CONFIG_REGULATOR_LP3971 is not set
CONFIG_REGULATOR_LP3972=m
CONFIG_REGULATOR_LP872X=m
CONFIG_REGULATOR_LP8755=m
# CONFIG_REGULATOR_MAX1586 is not set
CONFIG_REGULATOR_MAX8649=m
# CONFIG_REGULATOR_MAX8660 is not set
CONFIG_REGULATOR_MAX8952=m
CONFIG_REGULATOR_MAX8973=m
CONFIG_REGULATOR_MC13XXX_CORE=m
# CONFIG_REGULATOR_MC13783 is not set
CONFIG_REGULATOR_MC13892=m
CONFIG_REGULATOR_PCAP=m
# CONFIG_REGULATOR_PFUZE100 is not set
# CONFIG_REGULATOR_TPS51632 is not set
CONFIG_REGULATOR_TPS62360=m
# CONFIG_REGULATOR_TPS65023 is not set
# CONFIG_REGULATOR_TPS6507X is not set
CONFIG_REGULATOR_TPS65217=m
# CONFIG_REGULATOR_TPS6524X is not set
# CONFIG_REGULATOR_TPS65912 is not set
CONFIG_REGULATOR_WM831X=m
# CONFIG_MEDIA_SUPPORT is not set

#
# Graphics support
#
# CONFIG_AGP is not set
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
CONFIG_DRM=m
CONFIG_DRM_USB=m
CONFIG_DRM_KMS_HELPER=m
CONFIG_DRM_KMS_FB_HELPER=y
# CONFIG_DRM_LOAD_EDID_FIRMWARE is not set
CONFIG_DRM_TTM=m

#
# I2C encoder or helper chips
#
CONFIG_DRM_I2C_CH7006=m
# CONFIG_DRM_I2C_SIL164 is not set
# CONFIG_DRM_I2C_NXP_TDA998X is not set
# CONFIG_DRM_TDFX is not set
CONFIG_DRM_R128=m
CONFIG_DRM_RADEON=m
CONFIG_DRM_RADEON_UMS=y
CONFIG_DRM_NOUVEAU=m
CONFIG_NOUVEAU_DEBUG=5
CONFIG_NOUVEAU_DEBUG_DEFAULT=3
# CONFIG_DRM_NOUVEAU_BACKLIGHT is not set
# CONFIG_DRM_I915 is not set
CONFIG_DRM_MGA=m
CONFIG_DRM_VIA=m
# CONFIG_DRM_SAVAGE is not set
CONFIG_DRM_VMWGFX=m
# CONFIG_DRM_VMWGFX_FBCON is not set
CONFIG_DRM_GMA500=m
CONFIG_DRM_GMA600=y
CONFIG_DRM_GMA3600=y
CONFIG_DRM_UDL=m
CONFIG_DRM_AST=m
# CONFIG_DRM_MGAG200 is not set
CONFIG_DRM_CIRRUS_QEMU=m
CONFIG_DRM_QXL=m
CONFIG_DRM_BOCHS=m
CONFIG_VGASTATE=m
CONFIG_VIDEO_OUTPUT_CONTROL=m
CONFIG_HDMI=y
CONFIG_FB=m
CONFIG_FIRMWARE_EDID=y
CONFIG_FB_DDC=m
# CONFIG_FB_BOOT_VESA_SUPPORT is not set
CONFIG_FB_CFB_FILLRECT=m
CONFIG_FB_CFB_COPYAREA=m
CONFIG_FB_CFB_IMAGEBLIT=m
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
CONFIG_FB_SYS_FILLRECT=m
CONFIG_FB_SYS_COPYAREA=m
CONFIG_FB_SYS_IMAGEBLIT=m
# CONFIG_FB_FOREIGN_ENDIAN is not set
CONFIG_FB_SYS_FOPS=m
CONFIG_FB_DEFERRED_IO=y
CONFIG_FB_HECUBA=m
CONFIG_FB_SVGALIB=m
# CONFIG_FB_MACMODES is not set
CONFIG_FB_BACKLIGHT=y
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
CONFIG_FB_CIRRUS=m
# CONFIG_FB_PM2 is not set
CONFIG_FB_CYBER2000=m
# CONFIG_FB_CYBER2000_DDC is not set
CONFIG_FB_ARC=m
# CONFIG_FB_VGA16 is not set
CONFIG_FB_N411=m
CONFIG_FB_HGA=m
# CONFIG_FB_OPENCORES is not set
CONFIG_FB_S1D13XXX=m
# CONFIG_FB_NVIDIA is not set
CONFIG_FB_RIVA=m
# CONFIG_FB_RIVA_I2C is not set
# CONFIG_FB_RIVA_DEBUG is not set
# CONFIG_FB_RIVA_BACKLIGHT is not set
# CONFIG_FB_I740 is not set
# CONFIG_FB_LE80578 is not set
CONFIG_FB_MATROX=m
CONFIG_FB_MATROX_MILLENIUM=y
CONFIG_FB_MATROX_MYSTIQUE=y
# CONFIG_FB_MATROX_G is not set
# CONFIG_FB_MATROX_I2C is not set
CONFIG_FB_RADEON=m
CONFIG_FB_RADEON_I2C=y
CONFIG_FB_RADEON_BACKLIGHT=y
# CONFIG_FB_RADEON_DEBUG is not set
CONFIG_FB_ATY128=m
# CONFIG_FB_ATY128_BACKLIGHT is not set
CONFIG_FB_ATY=m
# CONFIG_FB_ATY_CT is not set
CONFIG_FB_ATY_GX=y
CONFIG_FB_ATY_BACKLIGHT=y
CONFIG_FB_S3=m
CONFIG_FB_S3_DDC=y
# CONFIG_FB_SAVAGE is not set
CONFIG_FB_SIS=m
# CONFIG_FB_SIS_300 is not set
CONFIG_FB_SIS_315=y
# CONFIG_FB_VIA is not set
CONFIG_FB_NEOMAGIC=m
CONFIG_FB_KYRO=m
CONFIG_FB_3DFX=m
# CONFIG_FB_3DFX_ACCEL is not set
# CONFIG_FB_3DFX_I2C is not set
CONFIG_FB_VOODOO1=m
CONFIG_FB_VT8623=m
CONFIG_FB_TRIDENT=m
CONFIG_FB_ARK=m
CONFIG_FB_PM3=m
CONFIG_FB_CARMINE=m
CONFIG_FB_CARMINE_DRAM_EVAL=y
# CONFIG_CARMINE_DRAM_CUSTOM is not set
CONFIG_FB_GEODE=y
CONFIG_FB_GEODE_LX=m
# CONFIG_FB_GEODE_GX is not set
CONFIG_FB_GEODE_GX1=m
CONFIG_FB_TMIO=m
CONFIG_FB_TMIO_ACCELL=y
CONFIG_FB_SMSCUFX=m
# CONFIG_FB_UDL is not set
CONFIG_FB_GOLDFISH=m
CONFIG_FB_VIRTUAL=m
CONFIG_FB_METRONOME=m
# CONFIG_FB_MB862XX is not set
CONFIG_FB_BROADSHEET=m
# CONFIG_FB_AUO_K190X is not set
# CONFIG_EXYNOS_VIDEO is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
# CONFIG_LCD_CLASS_DEVICE is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=m
CONFIG_BACKLIGHT_GENERIC=m
# CONFIG_BACKLIGHT_LM3533 is not set
CONFIG_BACKLIGHT_PWM=m
CONFIG_BACKLIGHT_DA9052=m
# CONFIG_BACKLIGHT_APPLE is not set
# CONFIG_BACKLIGHT_SAHARA is not set
CONFIG_BACKLIGHT_WM831X=m
# CONFIG_BACKLIGHT_ADP8860 is not set
# CONFIG_BACKLIGHT_ADP8870 is not set
CONFIG_BACKLIGHT_LM3630A=m
CONFIG_BACKLIGHT_LM3639=m
CONFIG_BACKLIGHT_LP855X=m
CONFIG_BACKLIGHT_TPS65217=m
CONFIG_BACKLIGHT_GPIO=m
CONFIG_BACKLIGHT_LV5207LP=m
# CONFIG_BACKLIGHT_BD6107 is not set
# CONFIG_LOGO is not set
CONFIG_FB_SSD1307=m
CONFIG_SOUND=y
# CONFIG_SOUND_OSS_CORE is not set
# CONFIG_SND is not set
# CONFIG_SOUND_PRIME is not set

#
# HID support
#
CONFIG_HID=m
# CONFIG_HIDRAW is not set
CONFIG_UHID=m
CONFIG_HID_GENERIC=m

#
# Special HID drivers
#
CONFIG_HID_A4TECH=m
CONFIG_HID_ACRUX=m
# CONFIG_HID_ACRUX_FF is not set
CONFIG_HID_APPLE=m
# CONFIG_HID_APPLEIR is not set
CONFIG_HID_AUREAL=m
# CONFIG_HID_BELKIN is not set
CONFIG_HID_CHERRY=m
CONFIG_HID_CHICONY=m
CONFIG_HID_CYPRESS=m
CONFIG_HID_DRAGONRISE=m
CONFIG_DRAGONRISE_FF=y
CONFIG_HID_EMS_FF=m
CONFIG_HID_ELECOM=m
# CONFIG_HID_ELO is not set
CONFIG_HID_EZKEY=m
CONFIG_HID_HOLTEK=m
# CONFIG_HOLTEK_FF is not set
# CONFIG_HID_HUION is not set
CONFIG_HID_KEYTOUCH=m
# CONFIG_HID_KYE is not set
# CONFIG_HID_UCLOGIC is not set
CONFIG_HID_WALTOP=m
CONFIG_HID_GYRATION=m
CONFIG_HID_ICADE=m
CONFIG_HID_TWINHAN=m
CONFIG_HID_KENSINGTON=m
CONFIG_HID_LCPOWER=m
# CONFIG_HID_LENOVO_TPKBD is not set
# CONFIG_HID_LOGITECH is not set
CONFIG_HID_MAGICMOUSE=m
CONFIG_HID_MICROSOFT=m
# CONFIG_HID_MONTEREY is not set
# CONFIG_HID_MULTITOUCH is not set
# CONFIG_HID_NTRIG is not set
CONFIG_HID_ORTEK=m
CONFIG_HID_PANTHERLORD=m
CONFIG_PANTHERLORD_FF=y
CONFIG_HID_PETALYNX=m
# CONFIG_HID_PICOLCD is not set
# CONFIG_HID_PRIMAX is not set
CONFIG_HID_ROCCAT=m
CONFIG_HID_SAITEK=m
CONFIG_HID_SAMSUNG=m
CONFIG_HID_SONY=m
# CONFIG_SONY_FF is not set
# CONFIG_HID_SPEEDLINK is not set
CONFIG_HID_STEELSERIES=m
CONFIG_HID_SUNPLUS=m
CONFIG_HID_GREENASIA=m
# CONFIG_GREENASIA_FF is not set
CONFIG_HID_SMARTJOYPLUS=m
# CONFIG_SMARTJOYPLUS_FF is not set
# CONFIG_HID_TIVO is not set
CONFIG_HID_TOPSEED=m
# CONFIG_HID_THINGM is not set
CONFIG_HID_THRUSTMASTER=m
CONFIG_THRUSTMASTER_FF=y
CONFIG_HID_WACOM=m
# CONFIG_HID_WIIMOTE is not set
# CONFIG_HID_XINMO is not set
CONFIG_HID_ZEROPLUS=m
# CONFIG_ZEROPLUS_FF is not set
CONFIG_HID_ZYDACRON=m
CONFIG_HID_SENSOR_HUB=m

#
# USB HID support
#
CONFIG_USB_HID=m
CONFIG_HID_PID=y
# CONFIG_USB_HIDDEV is not set

#
# USB HID Boot Protocol drivers
#
CONFIG_USB_KBD=m
CONFIG_USB_MOUSE=y

#
# I2C HID support
#
# CONFIG_I2C_HID is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=y
# CONFIG_USB_DEBUG is not set
CONFIG_USB_ANNOUNCE_NEW_DEVICES=y

#
# Miscellaneous USB options
#
CONFIG_USB_DEFAULT_PERSIST=y
CONFIG_USB_DYNAMIC_MINORS=y
CONFIG_USB_OTG=y
# CONFIG_USB_OTG_WHITELIST is not set
CONFIG_USB_OTG_BLACKLIST_HUB=y
CONFIG_USB_MON=y
# CONFIG_USB_WUSB_CBAF is not set

#
# USB Host Controller Drivers
#
CONFIG_USB_C67X00_HCD=y
CONFIG_USB_XHCI_HCD=m
# CONFIG_USB_EHCI_HCD is not set
# CONFIG_USB_OXU210HP_HCD is not set
CONFIG_USB_ISP116X_HCD=y
CONFIG_USB_ISP1760_HCD=m
CONFIG_USB_ISP1362_HCD=y
CONFIG_USB_FUSBH200_HCD=y
CONFIG_USB_FOTG210_HCD=m
CONFIG_USB_OHCI_HCD=y
CONFIG_USB_OHCI_HCD_PCI=m
# CONFIG_USB_OHCI_HCD_SSB is not set
CONFIG_USB_OHCI_HCD_PLATFORM=m
CONFIG_USB_UHCI_HCD=m
CONFIG_USB_U132_HCD=m
CONFIG_USB_SL811_HCD=m
# CONFIG_USB_SL811_HCD_ISO is not set
# CONFIG_USB_R8A66597_HCD is not set
CONFIG_USB_HCD_SSB=m
CONFIG_USB_HCD_TEST_MODE=y

#
# USB Device Class drivers
#
CONFIG_USB_ACM=y
# CONFIG_USB_PRINTER is not set
CONFIG_USB_WDM=y
CONFIG_USB_TMC=m

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#
# CONFIG_USB_STORAGE is not set

#
# USB Imaging devices
#
# CONFIG_USB_MDC800 is not set
CONFIG_USB_MICROTEK=m
CONFIG_USB_MUSB_HDRC=m
CONFIG_USB_MUSB_HOST=y
CONFIG_USB_MUSB_TUSB6010=m
CONFIG_USB_MUSB_DSPS=m
CONFIG_USB_MUSB_UX500=m
CONFIG_USB_MUSB_AM335X_CHILD=m
CONFIG_USB_UX500_DMA=y
# CONFIG_MUSB_PIO_ONLY is not set
# CONFIG_USB_DWC3 is not set
CONFIG_USB_DWC2=m
CONFIG_USB_DWC2_DEBUG=y
# CONFIG_USB_DWC2_VERBOSE is not set
# CONFIG_USB_DWC2_TRACK_MISSED_SOFS is not set
CONFIG_USB_DWC2_DEBUG_PERIODIC=y

#
# USB port drivers
#
CONFIG_USB_USS720=y
CONFIG_USB_SERIAL=y
# CONFIG_USB_SERIAL_CONSOLE is not set
# CONFIG_USB_SERIAL_GENERIC is not set
CONFIG_USB_SERIAL_SIMPLE=m
CONFIG_USB_SERIAL_AIRCABLE=y
CONFIG_USB_SERIAL_ARK3116=y
CONFIG_USB_SERIAL_BELKIN=y
CONFIG_USB_SERIAL_CH341=m
CONFIG_USB_SERIAL_WHITEHEAT=m
CONFIG_USB_SERIAL_DIGI_ACCELEPORT=m
CONFIG_USB_SERIAL_CP210X=y
# CONFIG_USB_SERIAL_CYPRESS_M8 is not set
CONFIG_USB_SERIAL_EMPEG=y
# CONFIG_USB_SERIAL_FTDI_SIO is not set
# CONFIG_USB_SERIAL_VISOR is not set
# CONFIG_USB_SERIAL_IPAQ is not set
# CONFIG_USB_SERIAL_IR is not set
CONFIG_USB_SERIAL_EDGEPORT=y
CONFIG_USB_SERIAL_EDGEPORT_TI=y
CONFIG_USB_SERIAL_F81232=m
CONFIG_USB_SERIAL_GARMIN=y
CONFIG_USB_SERIAL_IPW=m
CONFIG_USB_SERIAL_IUU=m
# CONFIG_USB_SERIAL_KEYSPAN_PDA is not set
CONFIG_USB_SERIAL_KEYSPAN=y
# CONFIG_USB_SERIAL_KEYSPAN_MPR is not set
CONFIG_USB_SERIAL_KEYSPAN_USA28=y
CONFIG_USB_SERIAL_KEYSPAN_USA28X=y
# CONFIG_USB_SERIAL_KEYSPAN_USA28XA is not set
CONFIG_USB_SERIAL_KEYSPAN_USA28XB=y
CONFIG_USB_SERIAL_KEYSPAN_USA19=y
CONFIG_USB_SERIAL_KEYSPAN_USA18X=y
CONFIG_USB_SERIAL_KEYSPAN_USA19W=y
# CONFIG_USB_SERIAL_KEYSPAN_USA19QW is not set
CONFIG_USB_SERIAL_KEYSPAN_USA19QI=y
# CONFIG_USB_SERIAL_KEYSPAN_USA49W is not set
# CONFIG_USB_SERIAL_KEYSPAN_USA49WLC is not set
# CONFIG_USB_SERIAL_KLSI is not set
# CONFIG_USB_SERIAL_KOBIL_SCT is not set
CONFIG_USB_SERIAL_MCT_U232=m
CONFIG_USB_SERIAL_METRO=m
# CONFIG_USB_SERIAL_MOS7720 is not set
# CONFIG_USB_SERIAL_MOS7840 is not set
# CONFIG_USB_SERIAL_MXUPORT is not set
CONFIG_USB_SERIAL_NAVMAN=m
CONFIG_USB_SERIAL_PL2303=m
CONFIG_USB_SERIAL_OTI6858=y
# CONFIG_USB_SERIAL_QCAUX is not set
# CONFIG_USB_SERIAL_QUALCOMM is not set
# CONFIG_USB_SERIAL_SPCP8X5 is not set
CONFIG_USB_SERIAL_SAFE=m
# CONFIG_USB_SERIAL_SAFE_PADDED is not set
CONFIG_USB_SERIAL_SIERRAWIRELESS=y
CONFIG_USB_SERIAL_SYMBOL=y
# CONFIG_USB_SERIAL_TI is not set
CONFIG_USB_SERIAL_CYBERJACK=m
CONFIG_USB_SERIAL_XIRCOM=y
CONFIG_USB_SERIAL_WWAN=y
CONFIG_USB_SERIAL_OPTION=y
CONFIG_USB_SERIAL_OMNINET=y
CONFIG_USB_SERIAL_OPTICON=y
CONFIG_USB_SERIAL_XSENS_MT=m
CONFIG_USB_SERIAL_WISHBONE=m
CONFIG_USB_SERIAL_ZTE=m
CONFIG_USB_SERIAL_SSU100=m
CONFIG_USB_SERIAL_QT2=m
# CONFIG_USB_SERIAL_DEBUG is not set

#
# USB Miscellaneous drivers
#
CONFIG_USB_EMI62=m
# CONFIG_USB_EMI26 is not set
# CONFIG_USB_ADUTUX is not set
CONFIG_USB_SEVSEG=m
CONFIG_USB_RIO500=m
CONFIG_USB_LEGOTOWER=m
# CONFIG_USB_LCD is not set
CONFIG_USB_LED=y
# CONFIG_USB_CYPRESS_CY7C63 is not set
# CONFIG_USB_CYTHERM is not set
CONFIG_USB_IDMOUSE=y
CONFIG_USB_FTDI_ELAN=y
# CONFIG_USB_APPLEDISPLAY is not set
CONFIG_USB_SISUSBVGA=m
CONFIG_USB_LD=y
CONFIG_USB_TRANCEVIBRATOR=y
CONFIG_USB_IOWARRIOR=y
CONFIG_USB_TEST=m
# CONFIG_USB_EHSET_TEST_FIXTURE is not set
CONFIG_USB_ISIGHTFW=y
CONFIG_USB_YUREX=y
CONFIG_USB_EZUSB_FX2=y
# CONFIG_USB_HSIC_USB3503 is not set

#
# USB Physical Layer drivers
#
CONFIG_USB_PHY=y
CONFIG_USB_OTG_FSM=m
CONFIG_NOP_USB_XCEIV=m
CONFIG_SAMSUNG_USBPHY=y
# CONFIG_SAMSUNG_USB2PHY is not set
CONFIG_SAMSUNG_USB3PHY=y
# CONFIG_USB_GPIO_VBUS is not set
CONFIG_TAHVO_USB=m
CONFIG_TAHVO_USB_HOST_BY_DEFAULT=y
CONFIG_USB_ISP1301=m
# CONFIG_USB_RCAR_PHY is not set
# CONFIG_USB_GADGET is not set
# CONFIG_UWB is not set
# CONFIG_MMC is not set
CONFIG_MEMSTICK=y
# CONFIG_MEMSTICK_DEBUG is not set

#
# MemoryStick drivers
#
# CONFIG_MEMSTICK_UNSAFE_RESUME is not set
CONFIG_MSPRO_BLOCK=y
CONFIG_MS_BLOCK=m

#
# MemoryStick Host Controller Drivers
#
CONFIG_MEMSTICK_TIFM_MS=m
# CONFIG_MEMSTICK_JMICRON_38X is not set
CONFIG_MEMSTICK_R592=m
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y

#
# LED drivers
#
CONFIG_LEDS_LM3530=m
CONFIG_LEDS_LM3533=m
# CONFIG_LEDS_LM3642 is not set
CONFIG_LEDS_NET48XX=m
CONFIG_LEDS_WRAP=m
CONFIG_LEDS_PCA9532=m
# CONFIG_LEDS_PCA9532_GPIO is not set
CONFIG_LEDS_GPIO=y
CONFIG_LEDS_LP3944=m
CONFIG_LEDS_LP55XX_COMMON=m
CONFIG_LEDS_LP5521=m
# CONFIG_LEDS_LP5523 is not set
# CONFIG_LEDS_LP5562 is not set
CONFIG_LEDS_LP8501=m
CONFIG_LEDS_PCA955X=m
# CONFIG_LEDS_PCA963X is not set
CONFIG_LEDS_PCA9685=m
# CONFIG_LEDS_WM831X_STATUS is not set
CONFIG_LEDS_DA9052=y
# CONFIG_LEDS_DAC124S085 is not set
CONFIG_LEDS_PWM=y
# CONFIG_LEDS_REGULATOR is not set
CONFIG_LEDS_BD2802=m
# CONFIG_LEDS_LT3593 is not set
# CONFIG_LEDS_DELL_NETBOOKS is not set
CONFIG_LEDS_MC13783=m
# CONFIG_LEDS_TCA6507 is not set
CONFIG_LEDS_LM355x=m
# CONFIG_LEDS_OT200 is not set
CONFIG_LEDS_BLINKM=m

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
CONFIG_LEDS_TRIGGER_TIMER=y
CONFIG_LEDS_TRIGGER_ONESHOT=m
CONFIG_LEDS_TRIGGER_HEARTBEAT=m
CONFIG_LEDS_TRIGGER_BACKLIGHT=m
CONFIG_LEDS_TRIGGER_CPU=y
CONFIG_LEDS_TRIGGER_GPIO=y
# CONFIG_LEDS_TRIGGER_DEFAULT_ON is not set

#
# iptables trigger is under Netfilter config (LED target)
#
CONFIG_LEDS_TRIGGER_TRANSIENT=m
CONFIG_LEDS_TRIGGER_CAMERA=y
# CONFIG_ACCESSIBILITY is not set
CONFIG_EDAC=y
# CONFIG_EDAC_LEGACY_SYSFS is not set
# CONFIG_EDAC_DEBUG is not set
CONFIG_EDAC_DECODE_MCE=y
# CONFIG_EDAC_MCE_INJ is not set
CONFIG_EDAC_MM_EDAC=y
CONFIG_EDAC_AMD76X=y
CONFIG_EDAC_E7XXX=m
CONFIG_EDAC_E752X=m
CONFIG_EDAC_I82875P=y
CONFIG_EDAC_I82975X=y
# CONFIG_EDAC_I3000 is not set
CONFIG_EDAC_I3200=y
CONFIG_EDAC_X38=m
CONFIG_EDAC_I5400=y
CONFIG_EDAC_I82860=m
CONFIG_EDAC_R82600=y
# CONFIG_EDAC_I5000 is not set
CONFIG_EDAC_I5100=y
CONFIG_EDAC_I7300=m
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
# CONFIG_RTC_HCTOSYS is not set
CONFIG_RTC_SYSTOHC=y
CONFIG_RTC_HCTOSYS_DEVICE="rtc0"
CONFIG_RTC_DEBUG=y

#
# RTC interfaces
#
CONFIG_RTC_INTF_SYSFS=y
# CONFIG_RTC_INTF_PROC is not set
CONFIG_RTC_INTF_DEV=y
# CONFIG_RTC_INTF_DEV_UIE_EMUL is not set
CONFIG_RTC_DRV_TEST=m

#
# I2C RTC drivers
#
# CONFIG_RTC_DRV_DS1307 is not set
CONFIG_RTC_DRV_DS1374=m
# CONFIG_RTC_DRV_DS1672 is not set
CONFIG_RTC_DRV_DS3232=m
CONFIG_RTC_DRV_HYM8563=m
# CONFIG_RTC_DRV_MAX6900 is not set
CONFIG_RTC_DRV_RS5C372=m
# CONFIG_RTC_DRV_ISL1208 is not set
CONFIG_RTC_DRV_ISL12022=m
CONFIG_RTC_DRV_ISL12057=m
CONFIG_RTC_DRV_X1205=m
CONFIG_RTC_DRV_PCF2127=m
CONFIG_RTC_DRV_PCF8523=m
# CONFIG_RTC_DRV_PCF8563 is not set
# CONFIG_RTC_DRV_PCF8583 is not set
CONFIG_RTC_DRV_M41T80=m
CONFIG_RTC_DRV_M41T80_WDT=y
CONFIG_RTC_DRV_BQ32K=m
CONFIG_RTC_DRV_S35390A=m
CONFIG_RTC_DRV_FM3130=m
# CONFIG_RTC_DRV_RX8581 is not set
CONFIG_RTC_DRV_RX8025=m
CONFIG_RTC_DRV_EM3027=m
CONFIG_RTC_DRV_RV3029C2=m

#
# SPI RTC drivers
#
CONFIG_RTC_DRV_M41T93=m
CONFIG_RTC_DRV_M41T94=m
# CONFIG_RTC_DRV_DS1305 is not set
CONFIG_RTC_DRV_DS1390=y
CONFIG_RTC_DRV_MAX6902=m
CONFIG_RTC_DRV_R9701=m
CONFIG_RTC_DRV_RS5C348=m
CONFIG_RTC_DRV_DS3234=y
CONFIG_RTC_DRV_PCF2123=y
# CONFIG_RTC_DRV_RX4581 is not set

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=y
CONFIG_RTC_DRV_DS1286=m
# CONFIG_RTC_DRV_DS1511 is not set
CONFIG_RTC_DRV_DS1553=m
CONFIG_RTC_DRV_DS1742=m
CONFIG_RTC_DRV_DA9052=y
# CONFIG_RTC_DRV_STK17TA8 is not set
# CONFIG_RTC_DRV_M48T86 is not set
# CONFIG_RTC_DRV_M48T35 is not set
CONFIG_RTC_DRV_M48T59=y
CONFIG_RTC_DRV_MSM6242=y
CONFIG_RTC_DRV_BQ4802=m
CONFIG_RTC_DRV_RP5C01=m
# CONFIG_RTC_DRV_V3020 is not set
CONFIG_RTC_DRV_DS2404=y
CONFIG_RTC_DRV_WM831X=m

#
# on-CPU RTC drivers
#
CONFIG_RTC_DRV_PCAP=m
CONFIG_RTC_DRV_MC13XXX=m
# CONFIG_RTC_DRV_SNVS is not set
# CONFIG_RTC_DRV_MOXART is not set

#
# HID Sensor RTC drivers
#
CONFIG_RTC_DRV_HID_SENSOR_TIME=m
# CONFIG_DMADEVICES is not set
# CONFIG_AUXDISPLAY is not set
CONFIG_UIO=y
CONFIG_UIO_CIF=m
CONFIG_UIO_PDRV_GENIRQ=y
CONFIG_UIO_DMEM_GENIRQ=y
CONFIG_UIO_AEC=m
# CONFIG_UIO_SERCOS3 is not set
# CONFIG_UIO_PCI_GENERIC is not set
# CONFIG_UIO_NETX is not set
# CONFIG_UIO_MF624 is not set
CONFIG_VIRT_DRIVERS=y
CONFIG_VIRTIO=y

#
# Virtio drivers
#
CONFIG_VIRTIO_PCI=y
CONFIG_VIRTIO_BALLOON=y
CONFIG_VIRTIO_MMIO=m
# CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES is not set

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
# CONFIG_STAGING is not set
CONFIG_X86_PLATFORM_DEVICES=y
# CONFIG_ACER_WMI is not set
# CONFIG_ACERHDF is not set
# CONFIG_ASUS_LAPTOP is not set
CONFIG_DELL_LAPTOP=m
# CONFIG_DELL_WMI is not set
# CONFIG_DELL_WMI_AIO is not set
# CONFIG_FUJITSU_LAPTOP is not set
# CONFIG_FUJITSU_TABLET is not set
# CONFIG_TC1100_WMI is not set
# CONFIG_HP_ACCEL is not set
# CONFIG_HP_WIRELESS is not set
# CONFIG_HP_WMI is not set
# CONFIG_PANASONIC_LAPTOP is not set
# CONFIG_THINKPAD_ACPI is not set
# CONFIG_SENSORS_HDAPS is not set
# CONFIG_INTEL_MENLOW is not set
CONFIG_ACPI_WMI=m
# CONFIG_MSI_WMI is not set
# CONFIG_TOPSTAR_LAPTOP is not set
# CONFIG_ACPI_TOSHIBA is not set
# CONFIG_TOSHIBA_BT_RFKILL is not set
# CONFIG_ACPI_CMPC is not set
# CONFIG_INTEL_IPS is not set
CONFIG_IBM_RTL=y
# CONFIG_XO15_EBOOK is not set
CONFIG_SAMSUNG_LAPTOP=m
CONFIG_MXM_WMI=m
# CONFIG_SAMSUNG_Q10 is not set
# CONFIG_APPLE_GMUX is not set
# CONFIG_INTEL_RST is not set
# CONFIG_INTEL_SMARTCONNECT is not set
# CONFIG_PVPANIC is not set
# CONFIG_GOLDFISH_PIPE is not set
# CONFIG_CHROME_PLATFORMS is not set

#
# Hardware Spinlock drivers
#
CONFIG_CLKSRC_I8253=y
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
# CONFIG_MAILBOX is not set
# CONFIG_IOMMU_SUPPORT is not set

#
# Remoteproc drivers
#
# CONFIG_STE_MODEM_RPROC is not set

#
# Rpmsg drivers
#
CONFIG_PM_DEVFREQ=y

#
# DEVFREQ Governors
#
CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND=m
CONFIG_DEVFREQ_GOV_PERFORMANCE=m
CONFIG_DEVFREQ_GOV_POWERSAVE=m
CONFIG_DEVFREQ_GOV_USERSPACE=y

#
# DEVFREQ Drivers
#
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
CONFIG_OF_EXTCON=y
CONFIG_EXTCON_GPIO=m
# CONFIG_EXTCON_ADC_JACK is not set
# CONFIG_MEMORY is not set
CONFIG_IIO=m
CONFIG_IIO_BUFFER=y
CONFIG_IIO_BUFFER_CB=y
CONFIG_IIO_KFIFO_BUF=m
CONFIG_IIO_TRIGGERED_BUFFER=m
CONFIG_IIO_TRIGGER=y
CONFIG_IIO_CONSUMERS_PER_TRIGGER=2

#
# Accelerometers
#
# CONFIG_BMA180 is not set
# CONFIG_HID_SENSOR_ACCEL_3D is not set
# CONFIG_IIO_ST_ACCEL_3AXIS is not set
CONFIG_KXSD9=m

#
# Analog to digital converters
#
CONFIG_AD_SIGMA_DELTA=m
CONFIG_AD7266=m
CONFIG_AD7298=m
# CONFIG_AD7476 is not set
CONFIG_AD7791=m
CONFIG_AD7793=m
# CONFIG_AD7887 is not set
CONFIG_AD7923=m
# CONFIG_EXYNOS_ADC is not set
# CONFIG_MAX1363 is not set
CONFIG_MCP320X=m
CONFIG_MCP3422=m
# CONFIG_NAU7802 is not set
CONFIG_TI_ADC081C=m
CONFIG_TI_AM335X_ADC=m
CONFIG_VIPERBOARD_ADC=m

#
# Amplifiers
#
# CONFIG_AD8366 is not set

#
# Hid Sensor IIO Common
#
CONFIG_HID_SENSOR_IIO_COMMON=m
CONFIG_HID_SENSOR_IIO_TRIGGER=m
CONFIG_IIO_ST_SENSORS_I2C=m
CONFIG_IIO_ST_SENSORS_SPI=m
CONFIG_IIO_ST_SENSORS_CORE=m

#
# Digital to analog converters
#
CONFIG_AD5064=m
# CONFIG_AD5360 is not set
CONFIG_AD5380=m
# CONFIG_AD5421 is not set
# CONFIG_AD5446 is not set
CONFIG_AD5449=m
CONFIG_AD5504=m
CONFIG_AD5624R_SPI=m
CONFIG_AD5686=m
CONFIG_AD5755=m
CONFIG_AD5764=m
CONFIG_AD5791=m
# CONFIG_AD7303 is not set
CONFIG_MAX517=m
# CONFIG_MCP4725 is not set

#
# Frequency Synthesizers DDS/PLL
#

#
# Clock Generator/Distribution
#
CONFIG_AD9523=m

#
# Phase-Locked Loop (PLL) frequency synthesizers
#
# CONFIG_ADF4350 is not set

#
# Digital gyroscope sensors
#
CONFIG_ADIS16080=m
CONFIG_ADIS16130=m
CONFIG_ADIS16136=m
CONFIG_ADIS16260=m
CONFIG_ADXRS450=m
# CONFIG_HID_SENSOR_GYRO_3D is not set
CONFIG_IIO_ST_GYRO_3AXIS=m
CONFIG_IIO_ST_GYRO_I2C_3AXIS=m
CONFIG_IIO_ST_GYRO_SPI_3AXIS=m
CONFIG_ITG3200=m

#
# Humidity sensors
#
CONFIG_DHT11=m

#
# Inertial measurement units
#
# CONFIG_ADIS16400 is not set
# CONFIG_ADIS16480 is not set
CONFIG_IIO_ADIS_LIB=m
CONFIG_IIO_ADIS_LIB_BUFFER=y
# CONFIG_INV_MPU6050_IIO is not set

#
# Light sensors
#
CONFIG_ADJD_S311=m
# CONFIG_APDS9300 is not set
CONFIG_CM32181=m
CONFIG_CM36651=m
# CONFIG_GP2AP020A00F is not set
CONFIG_HID_SENSOR_ALS=m
CONFIG_SENSORS_LM3533=m
# CONFIG_TCS3472 is not set
CONFIG_SENSORS_TSL2563=m
# CONFIG_TSL4531 is not set
# CONFIG_VCNL4000 is not set

#
# Magnetometer sensors
#
CONFIG_AK8975=m
CONFIG_MAG3110=m
# CONFIG_HID_SENSOR_MAGNETOMETER_3D is not set
CONFIG_IIO_ST_MAGN_3AXIS=m
CONFIG_IIO_ST_MAGN_I2C_3AXIS=m
CONFIG_IIO_ST_MAGN_SPI_3AXIS=m

#
# Inclinometer sensors
#
CONFIG_HID_SENSOR_INCLINOMETER_3D=m

#
# Triggers - standalone
#
CONFIG_IIO_INTERRUPT_TRIGGER=m
# CONFIG_IIO_SYSFS_TRIGGER is not set

#
# Pressure sensors
#
CONFIG_MPL3115=m
# CONFIG_IIO_ST_PRESS is not set

#
# Temperature sensors
#
CONFIG_TMP006=m
CONFIG_NTB=m
# CONFIG_VME_BUS is not set
CONFIG_PWM=y
CONFIG_PWM_SYSFS=y
# CONFIG_PWM_LP3943 is not set
CONFIG_PWM_PCA9685=m
CONFIG_IRQCHIP=y
CONFIG_IPACK_BUS=y
CONFIG_BOARD_TPCI200=m
CONFIG_SERIAL_IPOCTAL=m
# CONFIG_RESET_CONTROLLER is not set
CONFIG_FMC=y
CONFIG_FMC_FAKEDEV=m
CONFIG_FMC_TRIVIAL=m
# CONFIG_FMC_WRITE_EEPROM is not set
CONFIG_FMC_CHARDEV=m

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
CONFIG_PHY_EXYNOS_MIPI_VIDEO=y
CONFIG_PHY_EXYNOS_DP_VIDEO=m
# CONFIG_BCM_KONA_USB2_PHY is not set
# CONFIG_POWERCAP is not set

#
# Firmware Drivers
#
CONFIG_EDD=m
# CONFIG_EDD_OFF is not set
CONFIG_FIRMWARE_MEMMAP=y
CONFIG_DELL_RBU=y
CONFIG_DCDBAS=m
# CONFIG_ISCSI_IBFT_FIND is not set
CONFIG_GOOGLE_FIRMWARE=y

#
# Google Firmware Drivers
#

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_EXT2_FS=y
# CONFIG_EXT2_FS_XATTR is not set
# CONFIG_EXT2_FS_XIP is not set
CONFIG_EXT3_FS=m
CONFIG_EXT3_DEFAULTS_TO_ORDERED=y
CONFIG_EXT3_FS_XATTR=y
CONFIG_EXT3_FS_POSIX_ACL=y
CONFIG_EXT3_FS_SECURITY=y
CONFIG_EXT4_FS=m
CONFIG_EXT4_FS_POSIX_ACL=y
CONFIG_EXT4_FS_SECURITY=y
CONFIG_EXT4_DEBUG=y
CONFIG_JBD=m
CONFIG_JBD_DEBUG=y
CONFIG_JBD2=m
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=m
CONFIG_REISERFS_FS=y
# CONFIG_REISERFS_CHECK is not set
CONFIG_REISERFS_PROC_INFO=y
CONFIG_REISERFS_FS_XATTR=y
# CONFIG_REISERFS_FS_POSIX_ACL is not set
# CONFIG_REISERFS_FS_SECURITY is not set
# CONFIG_JFS_FS is not set
CONFIG_XFS_FS=m
CONFIG_XFS_QUOTA=y
CONFIG_XFS_POSIX_ACL=y
# CONFIG_XFS_RT is not set
CONFIG_XFS_DEBUG=y
CONFIG_GFS2_FS=y
# CONFIG_OCFS2_FS is not set
CONFIG_BTRFS_FS=y
# CONFIG_BTRFS_FS_POSIX_ACL is not set
# CONFIG_BTRFS_FS_CHECK_INTEGRITY is not set
CONFIG_BTRFS_FS_RUN_SANITY_TESTS=y
# CONFIG_BTRFS_DEBUG is not set
CONFIG_BTRFS_ASSERT=y
CONFIG_NILFS2_FS=m
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
# CONFIG_FILE_LOCKING is not set
CONFIG_FSNOTIFY=y
# CONFIG_DNOTIFY is not set
CONFIG_INOTIFY_USER=y
CONFIG_FANOTIFY=y
# CONFIG_QUOTA is not set
# CONFIG_QUOTA_NETLINK_INTERFACE is not set
CONFIG_QUOTACTL=y
CONFIG_AUTOFS4_FS=y
CONFIG_FUSE_FS=y
CONFIG_CUSE=m

#
# Caches
#
CONFIG_FSCACHE=y
# CONFIG_FSCACHE_STATS is not set
CONFIG_FSCACHE_HISTOGRAM=y
# CONFIG_FSCACHE_DEBUG is not set
CONFIG_FSCACHE_OBJECT_LIST=y
CONFIG_CACHEFILES=m
# CONFIG_CACHEFILES_DEBUG is not set
# CONFIG_CACHEFILES_HISTOGRAM is not set

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=y
# CONFIG_JOLIET is not set
CONFIG_ZISOFS=y
CONFIG_UDF_FS=y
CONFIG_UDF_NLS=y

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=m
# CONFIG_MSDOS_FS is not set
CONFIG_VFAT_FS=m
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
CONFIG_NTFS_FS=m
# CONFIG_NTFS_DEBUG is not set
# CONFIG_NTFS_RW is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
# CONFIG_PROC_KCORE is not set
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_KERNFS=y
CONFIG_SYSFS=y
# CONFIG_TMPFS is not set
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_CONFIGFS_FS=y
CONFIG_MISC_FILESYSTEMS=y
CONFIG_ADFS_FS=m
# CONFIG_ADFS_FS_RW is not set
CONFIG_AFFS_FS=y
CONFIG_ECRYPT_FS=m
# CONFIG_ECRYPT_FS_MESSAGING is not set
# CONFIG_HFS_FS is not set
CONFIG_HFSPLUS_FS=m
CONFIG_HFSPLUS_FS_POSIX_ACL=y
# CONFIG_BEFS_FS is not set
# CONFIG_BFS_FS is not set
CONFIG_EFS_FS=y
CONFIG_LOGFS=m
# CONFIG_CRAMFS is not set
# CONFIG_SQUASHFS is not set
CONFIG_VXFS_FS=y
CONFIG_MINIX_FS=y
# CONFIG_OMFS_FS is not set
# CONFIG_HPFS_FS is not set
# CONFIG_QNX4FS_FS is not set
CONFIG_QNX6FS_FS=m
# CONFIG_QNX6FS_DEBUG is not set
# CONFIG_ROMFS_FS is not set
CONFIG_PSTORE=y
CONFIG_PSTORE_CONSOLE=y
CONFIG_PSTORE_RAM=y
CONFIG_SYSV_FS=y
CONFIG_UFS_FS=m
CONFIG_UFS_FS_WRITE=y
CONFIG_UFS_DEBUG=y
CONFIG_F2FS_FS=m
# CONFIG_F2FS_STAT_FS is not set
# CONFIG_F2FS_FS_XATTR is not set
# CONFIG_F2FS_CHECK_FS is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
# CONFIG_NLS_CODEPAGE_437 is not set
CONFIG_NLS_CODEPAGE_737=m
# CONFIG_NLS_CODEPAGE_775 is not set
CONFIG_NLS_CODEPAGE_850=m
CONFIG_NLS_CODEPAGE_852=y
CONFIG_NLS_CODEPAGE_855=m
CONFIG_NLS_CODEPAGE_857=m
CONFIG_NLS_CODEPAGE_860=y
# CONFIG_NLS_CODEPAGE_861 is not set
CONFIG_NLS_CODEPAGE_862=y
# CONFIG_NLS_CODEPAGE_863 is not set
# CONFIG_NLS_CODEPAGE_864 is not set
# CONFIG_NLS_CODEPAGE_865 is not set
CONFIG_NLS_CODEPAGE_866=y
# CONFIG_NLS_CODEPAGE_869 is not set
# CONFIG_NLS_CODEPAGE_936 is not set
CONFIG_NLS_CODEPAGE_950=y
CONFIG_NLS_CODEPAGE_932=y
CONFIG_NLS_CODEPAGE_949=y
CONFIG_NLS_CODEPAGE_874=y
# CONFIG_NLS_ISO8859_8 is not set
CONFIG_NLS_CODEPAGE_1250=m
# CONFIG_NLS_CODEPAGE_1251 is not set
# CONFIG_NLS_ASCII is not set
CONFIG_NLS_ISO8859_1=y
# CONFIG_NLS_ISO8859_2 is not set
CONFIG_NLS_ISO8859_3=m
CONFIG_NLS_ISO8859_4=y
# CONFIG_NLS_ISO8859_5 is not set
# CONFIG_NLS_ISO8859_6 is not set
# CONFIG_NLS_ISO8859_7 is not set
CONFIG_NLS_ISO8859_9=m
CONFIG_NLS_ISO8859_13=y
CONFIG_NLS_ISO8859_14=y
# CONFIG_NLS_ISO8859_15 is not set
CONFIG_NLS_KOI8_R=m
CONFIG_NLS_KOI8_U=m
CONFIG_NLS_MAC_ROMAN=y
CONFIG_NLS_MAC_CELTIC=m
CONFIG_NLS_MAC_CENTEURO=y
# CONFIG_NLS_MAC_CROATIAN is not set
# CONFIG_NLS_MAC_CYRILLIC is not set
CONFIG_NLS_MAC_GAELIC=y
CONFIG_NLS_MAC_GREEK=m
CONFIG_NLS_MAC_ICELAND=y
# CONFIG_NLS_MAC_INUIT is not set
# CONFIG_NLS_MAC_ROMANIAN is not set
CONFIG_NLS_MAC_TURKISH=y
CONFIG_NLS_UTF8=m

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=y
CONFIG_DEFAULT_MESSAGE_LOGLEVEL=4
# CONFIG_BOOT_PRINTK_DELAY is not set
# CONFIG_DYNAMIC_DEBUG is not set

#
# Compile-time checks and compiler options
#
# CONFIG_DEBUG_INFO is not set
# CONFIG_ENABLE_WARN_DEPRECATED is not set
# CONFIG_ENABLE_MUST_CHECK is not set
CONFIG_FRAME_WARN=1024
# CONFIG_STRIP_ASM_SYMS is not set
CONFIG_READABLE_ASM=y
# CONFIG_UNUSED_SYMBOLS is not set
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
# CONFIG_DEBUG_SECTION_MISMATCH is not set
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
CONFIG_DEBUG_FORCE_WEAK_PER_CPU=y
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
CONFIG_DEBUG_PAGEALLOC=y
CONFIG_WANT_PAGE_DEBUG_FLAGS=y
CONFIG_PAGE_GUARD=y
# CONFIG_DEBUG_OBJECTS is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
# CONFIG_DEBUG_STACK_USAGE is not set
CONFIG_DEBUG_VM=y
CONFIG_DEBUG_VM_RB=y
CONFIG_DEBUG_VIRTUAL=y
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
CONFIG_DEBUG_STACKOVERFLOW=y
CONFIG_HAVE_ARCH_KMEMCHECK=y
# CONFIG_DEBUG_SHIRQ is not set

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
CONFIG_BOOTPARAM_HUNG_TASK_PANIC=y
CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=1
CONFIG_PANIC_ON_OOPS=y
CONFIG_PANIC_ON_OOPS_VALUE=1
CONFIG_PANIC_TIMEOUT=0
CONFIG_SCHED_DEBUG=y
CONFIG_SCHEDSTATS=y
# CONFIG_TIMER_STATS is not set

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
CONFIG_DEBUG_RT_MUTEXES=y
CONFIG_DEBUG_PI_LIST=y
# CONFIG_RT_MUTEX_TESTER is not set
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
# CONFIG_DEBUG_WW_MUTEX_SLOWPATH is not set
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_PROVE_LOCKING=y
CONFIG_LOCKDEP=y
# CONFIG_LOCK_STAT is not set
CONFIG_DEBUG_LOCKDEP=y
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
CONFIG_TRACE_IRQFLAGS=y
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
# CONFIG_DEBUG_WRITECOUNT is not set
# CONFIG_DEBUG_LIST is not set
CONFIG_DEBUG_SG=y
CONFIG_DEBUG_NOTIFIERS=y
# CONFIG_DEBUG_CREDENTIALS is not set

#
# RCU Debugging
#
CONFIG_PROVE_RCU=y
# CONFIG_PROVE_RCU_REPEATEDLY is not set
# CONFIG_SPARSE_RCU_POINTER is not set
# CONFIG_RCU_TORTURE_TEST is not set
# CONFIG_RCU_TRACE is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
# CONFIG_NOTIFIER_ERROR_INJECTION is not set
# CONFIG_FAULT_INJECTION is not set
CONFIG_LATENCYTOP=y
CONFIG_ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS=y
# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACING_SUPPORT=y
# CONFIG_FTRACE is not set

#
# Runtime Testing
#
# CONFIG_LKDTM is not set
# CONFIG_TEST_LIST_SORT is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
CONFIG_RBTREE_TEST=y
CONFIG_INTERVAL_TREE_TEST=m
CONFIG_PERCPU_TEST=m
# CONFIG_ATOMIC64_SELFTEST is not set
# CONFIG_TEST_STRING_HELPERS is not set
# CONFIG_TEST_KSTRTOX is not set
CONFIG_PROVIDE_OHCI1394_DMA_INIT=y
CONFIG_BUILD_DOCSRC=y
CONFIG_DMA_API_DEBUG=y
CONFIG_TEST_MODULE=m
CONFIG_TEST_USER_COPY=m
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_STRICT_DEVMEM=y
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
CONFIG_EARLY_PRINTK_DBGP=y
# CONFIG_X86_PTDUMP is not set
CONFIG_DEBUG_RODATA=y
# CONFIG_DEBUG_RODATA_TEST is not set
CONFIG_DEBUG_SET_MODULE_RONX=y
# CONFIG_DEBUG_NX_TEST is not set
CONFIG_DOUBLEFAULT=y
CONFIG_DEBUG_TLBFLUSH=y
CONFIG_IOMMU_STRESS=y
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
CONFIG_IO_DELAY_0X80=y
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=0
# CONFIG_DEBUG_BOOT_PARAMS is not set
# CONFIG_CPA_DEBUG is not set
# CONFIG_OPTIMIZE_INLINING is not set
# CONFIG_DEBUG_NMI_SELFTEST is not set
# CONFIG_X86_DEBUG_STATIC_CPU_HAS is not set

#
# Security options
#
CONFIG_KEYS=y
CONFIG_PERSISTENT_KEYRINGS=y
CONFIG_TRUSTED_KEYS=m
CONFIG_ENCRYPTED_KEYS=m
CONFIG_KEYS_DEBUG_PROC_KEYS=y
# CONFIG_SECURITY_DMESG_RESTRICT is not set
# CONFIG_SECURITY is not set
CONFIG_SECURITYFS=y
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_XOR_BLOCKS=y
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_FIPS=y
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
CONFIG_CRYPTO_PCOMP2=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_USER is not set
# CONFIG_CRYPTO_MANAGER_DISABLE_TESTS is not set
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_TEST=m

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=y
CONFIG_CRYPTO_GCM=y
CONFIG_CRYPTO_SEQIV=y

#
# Block modes
#
CONFIG_CRYPTO_CBC=m
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_CTS=y
CONFIG_CRYPTO_ECB=m
# CONFIG_CRYPTO_LRW is not set
CONFIG_CRYPTO_PCBC=m
CONFIG_CRYPTO_XTS=m

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=m
CONFIG_CRYPTO_HMAC=m
# CONFIG_CRYPTO_XCBC is not set
CONFIG_CRYPTO_VMAC=y

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
# CONFIG_CRYPTO_CRC32C_INTEL is not set
CONFIG_CRYPTO_CRC32=y
CONFIG_CRYPTO_CRC32_PCLMUL=m
CONFIG_CRYPTO_CRCT10DIF=y
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_MD4=m
CONFIG_CRYPTO_MD5=y
# CONFIG_CRYPTO_MICHAEL_MIC is not set
CONFIG_CRYPTO_RMD128=y
# CONFIG_CRYPTO_RMD160 is not set
CONFIG_CRYPTO_RMD256=m
# CONFIG_CRYPTO_RMD320 is not set
CONFIG_CRYPTO_SHA1=m
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=m
# CONFIG_CRYPTO_TGR192 is not set
CONFIG_CRYPTO_WP512=m

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
# CONFIG_CRYPTO_AES_586 is not set
# CONFIG_CRYPTO_AES_NI_INTEL is not set
CONFIG_CRYPTO_ANUBIS=m
CONFIG_CRYPTO_ARC4=m
CONFIG_CRYPTO_BLOWFISH=m
CONFIG_CRYPTO_BLOWFISH_COMMON=m
CONFIG_CRYPTO_CAMELLIA=y
CONFIG_CRYPTO_CAST_COMMON=m
CONFIG_CRYPTO_CAST5=m
CONFIG_CRYPTO_CAST6=m
CONFIG_CRYPTO_DES=m
CONFIG_CRYPTO_FCRYPT=m
CONFIG_CRYPTO_KHAZAD=m
CONFIG_CRYPTO_SALSA20=y
CONFIG_CRYPTO_SALSA20_586=m
CONFIG_CRYPTO_SEED=m
# CONFIG_CRYPTO_SERPENT is not set
# CONFIG_CRYPTO_SERPENT_SSE2_586 is not set
# CONFIG_CRYPTO_TEA is not set
CONFIG_CRYPTO_TWOFISH=y
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_586=y

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=m
# CONFIG_CRYPTO_ZLIB is not set
CONFIG_CRYPTO_LZO=m
CONFIG_CRYPTO_LZ4=m
# CONFIG_CRYPTO_LZ4HC is not set

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=y
# CONFIG_CRYPTO_USER_API_HASH is not set
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
CONFIG_CRYPTO_HASH_INFO=y
CONFIG_CRYPTO_HW=y
# CONFIG_CRYPTO_DEV_PADLOCK is not set
CONFIG_CRYPTO_DEV_GEODE=m
# CONFIG_CRYPTO_DEV_HIFN_795X is not set
CONFIG_CRYPTO_DEV_CCP=y
CONFIG_CRYPTO_DEV_CCP_DD=y
CONFIG_CRYPTO_DEV_CCP_CRYPTO=y
CONFIG_ASYMMETRIC_KEY_TYPE=y
CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=y
CONFIG_PUBLIC_KEY_ALGO_RSA=y
CONFIG_X509_CERTIFICATE_PARSER=y
CONFIG_HAVE_KVM=y
CONFIG_VIRTUALIZATION=y
CONFIG_LGUEST=m
# CONFIG_BINARY_PRINTF is not set

#
# Library routines
#
CONFIG_RAID6_PQ=y
CONFIG_BITREVERSE=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_IO=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
CONFIG_CRC32_SELFTEST=y
CONFIG_CRC32_SLICEBY8=y
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
CONFIG_CRC7=m
CONFIG_LIBCRC32C=y
CONFIG_CRC8=m
# CONFIG_RANDOM32_SELFTEST is not set
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4_COMPRESS=m
CONFIG_LZ4_DECOMPRESS=y
CONFIG_XZ_DEC=m
CONFIG_XZ_DEC_X86=y
# CONFIG_XZ_DEC_POWERPC is not set
# CONFIG_XZ_DEC_IA64 is not set
# CONFIG_XZ_DEC_ARM is not set
# CONFIG_XZ_DEC_ARMTHUMB is not set
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
CONFIG_XZ_DEC_TEST=m
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_REED_SOLOMON=y
CONFIG_REED_SOLOMON_ENC8=y
CONFIG_REED_SOLOMON_DEC8=y
CONFIG_BTREE=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y
CONFIG_CHECK_SIGNATURE=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
# CONFIG_AVERAGE is not set
CONFIG_CLZ_TAB=y
CONFIG_CORDIC=y
# CONFIG_DDR is not set
CONFIG_MPILIB=y
CONFIG_OID_REGISTRY=y

--f2QGlHpHGjS2mn6Y
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

_______________________________________________
LKP mailing list
LKP@linux.intel.com

--f2QGlHpHGjS2mn6Y--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
