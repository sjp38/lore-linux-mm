Received: by wx-out-0506.google.com with SMTP id h31so5228036wxd.11
        for <linux-mm@kvack.org>; Tue, 12 Feb 2008 23:39:31 -0800 (PST)
Message-ID: <e2e108260802122339j3b861e74vf7b72a34747dcade@mail.gmail.com>
Date: Wed, 13 Feb 2008 08:39:30 +0100
From: "Bart Van Assche" <bart.vanassche@gmail.com>
Subject: Re: [Bug 9941] New: Zone "Normal" missing in /proc/zoneinfo
In-Reply-To: <20080212100623.4fd6cf85.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <bug-9941-27@http.bugzilla.kernel.org/>
	 <20080212100623.4fd6cf85.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Feb 12, 2008 7:06 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Tue, 12 Feb 2008 02:39:40 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:
>
> > http://bugzilla.kernel.org/show_bug.cgi?id=9941
> >
> >            Summary: Zone "Normal" missing in /proc/zoneinfo
> >            Product: Memory Management
> >            Version: 2.5
> >      KernelVersion: 2.6.24.2
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: Other
> >         AssignedTo: akpm@osdl.org
> >         ReportedBy: bart.vanassche@gmail.com
> >
> >
> > Latest working kernel version: 2.6.24
> > Earliest failing kernel version: 2.6.24.2
> > Distribution: Ubuntu 7.10 server
> > Hardware Environment: Intel S5000PAL
> > Software Environment:
> > Problem Description:
> >
> > There is only information about the zones "DMA" and "DMA32" in /proc/zoneinfo,
> > not about zone "Normal".
> >
> > Steps to reproduce:
> >
> > Run the following command in a shell:
> > $ grep zone /proc/zoneinfo
> >
> > Output with 2.6.24:
> > Node 0, zone      DMA
> > Node 0, zone    DMA32
> > Node 0, zone   Normal
> >
> > Output with 2.6.24.2:
> > Node 0, zone      DMA
> > Node 0, zone    DMA32
> >
>
> hm, I don't think that was expected.   Please send the full kernel boot log
> (the dmesg -s 1000000 output).  Please send it via emailed reply-to-all, not
> via the bugzilla web interface, thanks.

This is the output of dmesg -s 1000000:

Linux version 2.6.24.2-dbg (root@INF012) (gcc version 4.1.3 20070929
(prerelease) (Ubuntu 4.1.2-16ubuntu2)) #1 SMP Tue Feb 12 08:19:21 CET
2008
Command line: root=UUID=4604bcf5-93b6-46ba-9d80-f2f89a844a78 ro quiet splash
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
 BIOS-e820: 000000000009fc00 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 000000007e2d9000 (usable)
 BIOS-e820: 000000007e2d9000 - 000000007e39b000 (ACPI NVS)
 BIOS-e820: 000000007e39b000 - 000000007fa32000 (usable)
 BIOS-e820: 000000007fa32000 - 000000007fa9a000 (reserved)
 BIOS-e820: 000000007fa9a000 - 000000007facc000 (usable)
 BIOS-e820: 000000007facc000 - 000000007fb1a000 (ACPI NVS)
 BIOS-e820: 000000007fb1a000 - 000000007fb26000 (usable)
 BIOS-e820: 000000007fb26000 - 000000007fb3a000 (ACPI data)
 BIOS-e820: 000000007fb3a000 - 000000007fc00000 (usable)
 BIOS-e820: 000000007fc00000 - 0000000080000000 (reserved)
 BIOS-e820: 00000000a0000000 - 00000000b0000000 (reserved)
 BIOS-e820: 00000000ffe00000 - 00000000ffe0c000 (reserved)
Entering add_active_range(0, 0, 159) 0 entries of 256 used
Entering add_active_range(0, 256, 516825) 1 entries of 256 used
Entering add_active_range(0, 517019, 522802) 2 entries of 256 used
Entering add_active_range(0, 522906, 522956) 3 entries of 256 used
Entering add_active_range(0, 523034, 523046) 4 entries of 256 used
Entering add_active_range(0, 523066, 523264) 5 entries of 256 used
end_pfn_map = 1048076
DMI 2.5 present.
Entering add_active_range(0, 0, 159) 0 entries of 256 used
Entering add_active_range(0, 256, 516825) 1 entries of 256 used
Entering add_active_range(0, 517019, 522802) 2 entries of 256 used
Entering add_active_range(0, 522906, 522956) 3 entries of 256 used
Entering add_active_range(0, 523034, 523046) 4 entries of 256 used
Entering add_active_range(0, 523066, 523264) 5 entries of 256 used
Zone PFN ranges:
  DMA             0 ->     4096
  DMA32        4096 ->  1048576
  Normal    1048576 ->  1048576
Movable zone start PFN for each node
early_node_map[6] active PFN ranges
    0:        0 ->      159
    0:      256 ->   516825
    0:   517019 ->   522802
    0:   522906 ->   522956
    0:   523034 ->   523046
    0:   523066 ->   523264
On node 0 totalpages: 522771
  DMA zone: 96 pages used for memmap
  DMA zone: 2170 pages reserved
  DMA zone: 1733 pages, LIFO batch:0
  DMA32 zone: 12168 pages used for memmap
  DMA32 zone: 506604 pages, LIFO batch:31
  Normal zone: 0 pages used for memmap
  Movable zone: 0 pages used for memmap
Intel MultiProcessor Specification v1.4
MPTABLE: OEM ID: INTEL    MPTABLE: Product ID: S5000PAL     MPTABLE:
APIC at: 0xFEE00000
Processor #0 (Bootup-CPU)
Processor #1
I/O APIC #8 at 0xFEC00000.
I/O APIC #9 at 0xFEC80000.
Setting APIC routing to flat
Processors: 2
Allocating PCI resources starting at b8000000 (gap: b0000000:4fe00000)
SMP: Allowing 2 CPUs, 0 hotplug CPUs
PERCPU: Allocating 427632 bytes of per cpu data
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 508337
Kernel command line: root=UUID=4604bcf5-93b6-46ba-9d80-f2f89a844a78 ro
quiet splash
Initializing CPU#0
PID hash table entries: 4096 (order: 12, 32768 bytes)
TSC calibrated against PIT
time.c: Detected 1995.051 MHz processor.
Console: colour VGA+ 80x25
console [tty0] enabled
Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
... MAX_LOCKDEP_SUBCLASSES:    8
... MAX_LOCK_DEPTH:          30
... MAX_LOCKDEP_KEYS:        2048
... CLASSHASH_SIZE:           1024
... MAX_LOCKDEP_ENTRIES:     8192
... MAX_LOCKDEP_CHAINS:      16384
... CHAINHASH_SIZE:          8192
 memory used by lock dependency info: 1712 kB
 per task-struct memory footprint: 2160 bytes
------------------------
| Locking API testsuite:
----------------------------------------------------------------------------
                                 | spin |wlock |rlock |mutex | wsem | rsem |
  --------------------------------------------------------------------------
                     A-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
                 A-B-B-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
             A-B-B-C-C-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
             A-B-C-A-B-C deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
         A-B-B-C-C-D-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
         A-B-C-D-B-D-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
         A-B-C-D-B-C-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
                    double unlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
                  initialize held:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
                 bad unlock order:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
  --------------------------------------------------------------------------
              recursive read-lock:             |  ok  |             |  ok  |
           recursive read-lock #2:             |  ok  |             |  ok  |
            mixed read-write-lock:             |  ok  |             |  ok  |
            mixed write-read-lock:             |  ok  |             |  ok  |
  --------------------------------------------------------------------------
     hard-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
     soft-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
     hard-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
     soft-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
       sirq-safe-A => hirqs-on/12:  ok  |  ok  |  ok  |
       sirq-safe-A => hirqs-on/21:  ok  |  ok  |  ok  |
         hard-safe-A + irqs-on/12:  ok  |  ok  |  ok  |
         soft-safe-A + irqs-on/12:  ok  |  ok  |  ok  |
         hard-safe-A + irqs-on/21:  ok  |  ok  |  ok  |
         soft-safe-A + irqs-on/21:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |
      hard-irq lock-inversion/123:  ok  |  ok  |  ok  |
      soft-irq lock-inversion/123:  ok  |  ok  |  ok  |
      hard-irq lock-inversion/132:  ok  |  ok  |  ok  |
      soft-irq lock-inversion/132:  ok  |  ok  |  ok  |
      hard-irq lock-inversion/213:  ok  |  ok  |  ok  |
      soft-irq lock-inversion/213:  ok  |  ok  |  ok  |
      hard-irq lock-inversion/231:  ok  |  ok  |  ok  |
      soft-irq lock-inversion/231:  ok  |  ok  |  ok  |
      hard-irq lock-inversion/312:  ok  |  ok  |  ok  |
      soft-irq lock-inversion/312:  ok  |  ok  |  ok  |
      hard-irq lock-inversion/321:  ok  |  ok  |  ok  |
      soft-irq lock-inversion/321:  ok  |  ok  |  ok  |
      hard-irq read-recursion/123:  ok  |
      soft-irq read-recursion/123:  ok  |
      hard-irq read-recursion/132:  ok  |
      soft-irq read-recursion/132:  ok  |
      hard-irq read-recursion/213:  ok  |
      soft-irq read-recursion/213:  ok  |
      hard-irq read-recursion/231:  ok  |
      soft-irq read-recursion/231:  ok  |
      hard-irq read-recursion/312:  ok  |
      soft-irq read-recursion/312:  ok  |
      hard-irq read-recursion/321:  ok  |
      soft-irq read-recursion/321:  ok  |
-------------------------------------------------------
Good, all 218 testcases passed! |
---------------------------------
Dentry cache hash table entries: 262144 (order: 9, 2097152 bytes)
Inode-cache hash table entries: 131072 (order: 8, 1048576 bytes)
Checking aperture...
Calgary: detecting Calgary via BIOS EBDA area
Calgary: Unable to locate Rio Grande table in EBDA - bailing!
Memory: 2021900k/2093056k available (2280k kernel code, 68540k
reserved, 1244k data, 592k init)
SLUB: Genslabs=11, HWalign=64, Order=0-1, MinObjects=4, CPUs=2, Nodes=1
Calibrating delay using timer specific routine.. 3994.13 BogoMIPS (lpj=19970665)
Security Framework initialized
SELinux:  Disabled at boot.
Mount-cache hash table entries: 256
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 4096K
using mwait in idle threads.
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
CPU0: Thermal monitoring enabled (TM1)
lockdep: not fixing up alternatives.
ExtINT not setup in hardware but reported by MP table
Using local APIC timer interrupts.
APIC timer calibration result 20781772
Detected 20.781 MHz APIC timer.
lockdep: not fixing up alternatives.
Booting processor 1/2 APIC 0x1
Initializing CPU#1
Calibrating delay using timer specific routine.. 3990.13 BogoMIPS (lpj=19950697)
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 4096K
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 1
CPU1: Thermal monitoring enabled (TM1)
Intel(R) Xeon(R) CPU            5130  @ 2.00GHz stepping 06
checking TSC synchronization [CPU#0 -> CPU#1]: passed.
Brought up 2 CPUs
CPU0 attaching sched-domain:
 domain 0: span 3
  groups: 1 2
CPU1 attaching sched-domain:
 domain 0: span 3
  groups: 2 1
WARNING: at kernel/lockdep.c:2662 check_flags()
Pid: 0, comm: swapper Not tainted 2.6.24.2-dbg #1

Call Trace:
 [<ffffffff8025ac1c>] check_flags+0x19c/0x1d0
 [<ffffffff8025f1d8>] lock_acquire+0x68/0xe0
 [<ffffffff80436521>] __atomic_notifier_call_chain+0x51/0xa0
 [<ffffffff8020b510>] mwait_idle+0x0/0x60
 [<ffffffff8020b46a>] cpu_idle+0x7a/0xd0

possible reason: unannotated irqs-on.
irq event stamp: 10
hardirqs last  enabled at (9): [<ffffffff80433bd4>] _spin_unlock_irq+0x24/0x30
hardirqs last disabled at (10): [<ffffffff8020b45e>] cpu_idle+0x6e/0xd0
softirqs last  enabled at (0): [<ffffffff80238587>] copy_process+0x337/0x1550
softirqs last disabled at (0): [<0000000000000000>] 0x0
net_namespace: 152 bytes
NET: Registered protocol family 16
PCI: Using configuration type 1
PCI: Probing PCI hardware
PCI: Probing PCI hardware (bus 00)
Force enabled HPET at base address 0xfed00000
PCI: Transparent bridge - 0000:00:1e.0
PCI: Discovered primary peer bus ff [IRQ]
PCI: Using IRQ router PIIX/ICH [8086/2670] at 0000:00:1f.0
PCI->APIC IRQ transform: 0000:00:1d.0[A] -> IRQ 23
PCI->APIC IRQ transform: 0000:00:1d.1[B] -> IRQ 22
PCI->APIC IRQ transform: 0000:00:1d.2[C] -> IRQ 23
PCI->APIC IRQ transform: 0000:00:1d.3[D] -> IRQ 22
PCI->APIC IRQ transform: 0000:00:1d.7[A] -> IRQ 23
PCI->APIC IRQ transform: 0000:00:1f.1[A] -> IRQ 20
PCI->APIC IRQ transform: 0000:00:1f.2[B] -> IRQ 20
PCI->APIC IRQ transform: 0000:00:1f.3[B] -> IRQ 20
PCI->APIC IRQ transform: 0000:05:00.0[A] -> IRQ 18
PCI->APIC IRQ transform: 0000:05:00.1[B] -> IRQ 19
PCI->APIC IRQ transform: 0000:08:00.0[A] -> IRQ 16
PCI->APIC IRQ transform: 0000:0c:0c.0[A] -> IRQ 17
NET: Registered protocol family 8
NET: Registered protocol family 20
NetLabel: Initializing
NetLabel:  domain hash size = 128
NetLabel:  protocols = UNLABELED CIPSOv4
NetLabel:  unlabeled traffic allowed by default
PCI-GART: No AMD northbridge found.
hpet clockevent registered
PCI: Bridge: 0000:02:00.0
  IO window: disabled.
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Bridge: 0000:02:01.0
  IO window: disabled.
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Bridge: 0000:02:02.0
  IO window: 2000-2fff
  MEM window: b8800000-b90fffff
  PREFETCH window: disabled.
PCI: Bridge: 0000:01:00.0
  IO window: 2000-2fff
  MEM window: b8800000-b90fffff
  PREFETCH window: disabled.
PCI: Bridge: 0000:01:00.3
  IO window: disabled.
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:02.0
  IO window: 2000-2fff
  MEM window: b8800000-b91fffff
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:03.0
  IO window: disabled.
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:04.0
  IO window: disabled.
  MEM window: b9300000-b93fffff
  PREFETCH window: b8000000-b87fffff
PCI: Bridge: 0000:00:05.0
  IO window: disabled.
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:06.0
  IO window: disabled.
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:07.0
  IO window: disabled.
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:1e.0
  IO window: 1000-1fff
  MEM window: b9200000-b92fffff
  PREFETCH window: b0000000-b7ffffff
PCI: No IRQ known for interrupt pin A of device 0000:00:02.0. Probably
buggy MP table.
PCI: Setting latency timer of device 0000:00:02.0 to 64
PCI: Setting latency timer of device 0000:01:00.0 to 64
PCI: Setting latency timer of device 0000:02:00.0 to 64
PCI: Setting latency timer of device 0000:02:01.0 to 64
Time: tsc clocksource has been installed.
PCI: Setting latency timer of device 0000:02:02.0 to 64
PCI: Setting latency timer of device 0000:01:00.3 to 64
PCI: No IRQ known for interrupt pin A of device 0000:00:03.0. Probably
buggy MP table.
PCI: Setting latency timer of device 0000:00:03.0 to 64
PCI: No IRQ known for interrupt pin A of device 0000:00:04.0. Probably
buggy MP table.
PCI: Setting latency timer of device 0000:00:04.0 to 64
PCI: No IRQ known for interrupt pin A of device 0000:00:05.0. Probably
buggy MP table.
PCI: Setting latency timer of device 0000:00:05.0 to 64
PCI: No IRQ known for interrupt pin A of device 0000:00:06.0. Probably
buggy MP table.
PCI: Setting latency timer of device 0000:00:06.0 to 64
PCI: No IRQ known for interrupt pin A of device 0000:00:07.0. Probably
buggy MP table.
PCI: Setting latency timer of device 0000:00:07.0 to 64
PCI: Setting latency timer of device 0000:00:1e.0 to 64
NET: Registered protocol family 2
IP route cache hash table entries: 65536 (order: 7, 524288 bytes)
TCP established hash table entries: 262144 (order: 10, 4194304 bytes)
TCP bind hash table entries: 65536 (order: 10, 4194304 bytes)
TCP: Hash tables configured (established 262144 bind 65536)
TCP reno registered
checking if image is initramfs... it is
Freeing initrd memory: 6705k freed
audit: initializing netlink socket (disabled)
audit(1202887897.310:1): initialized
VFS: Disk quotas dquot_6.5.1
Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
io scheduler noop registered
io scheduler anticipatory registered
io scheduler deadline registered (default)
io scheduler cfq registered
Boot video device is 0000:0c:0c.0
PCI: Setting latency timer of device 0000:00:02.0 to 64
pcie_portdrv_probe->Dev[8086:25f7] has invalid IRQ. Check vendor BIOS
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:02.0:pcie00]
PCI: Setting latency timer of device 0000:00:03.0 to 64
pcie_portdrv_probe->Dev[8086:25e3] has invalid IRQ. Check vendor BIOS
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:03.0:pcie00]
PCI: Setting latency timer of device 0000:00:04.0 to 64
pcie_portdrv_probe->Dev[8086:25f8] has invalid IRQ. Check vendor BIOS
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:04.0:pcie00]
PCI: Setting latency timer of device 0000:00:05.0 to 64
pcie_portdrv_probe->Dev[8086:25e5] has invalid IRQ. Check vendor BIOS
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:05.0:pcie00]
PCI: Setting latency timer of device 0000:00:06.0 to 64
pcie_portdrv_probe->Dev[8086:25e6] has invalid IRQ. Check vendor BIOS
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:06.0:pcie00]
PCI: Setting latency timer of device 0000:00:07.0 to 64
pcie_portdrv_probe->Dev[8086:25e7] has invalid IRQ. Check vendor BIOS
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:07.0:pcie00]
PCI: Setting latency timer of device 0000:01:00.0 to 64
Allocate Port Service[0000:01:00.0:pcie10]
PCI: Setting latency timer of device 0000:02:00.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:02:00.0:pcie20]
Allocate Port Service[0000:02:00.0:pcie22]
PCI: Setting latency timer of device 0000:02:01.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:02:01.0:pcie20]
PCI: Setting latency timer of device 0000:02:02.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:02:02.0:pcie20]
Real Time Clock Driver v1.12ac
Linux agpgart interface v0.102
Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing enabled
serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
serial8250: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
RAMDISK driver initialized: 16 RAM disks of 65536K size 1024 blocksize
input: Macintosh mouse button emulation as /class/input/input0
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
mice: PS/2 mouse device common for all mice
TCP cubic registered
NET: Registered protocol family 1
drivers/rtc/hctosys.c: unable to open rtc device (rtc0)
Freeing unused kernel memory: 592k freed
fuse init (API version 7.9)
Intel(R) PRO/1000 Network Driver - version 7.3.20-k2-NAPI
Copyright (c) 1999-2006 Intel Corporation.
PCI: Setting latency timer of device 0000:05:00.0 to 64
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
PCI: Setting latency timer of device 0000:00:1d.7 to 64
ehci_hcd 0000:00:1d.7: EHCI Host Controller
ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 1
ehci_hcd 0000:00:1d.7: debug port 1
PCI: cache line size of 32 is not supported by device 0000:00:1d.7
ehci_hcd 0000:00:1d.7: irq 23, io mem 0xb9400400
USB Universal Host Controller Interface driver v3.0
SCSI subsystem initialized
e1000: 0000:05:00.0: e1000_probe: (PCI Express:2.5Gb/s:Width x4)
00:04:23:d9:9b:4a
ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
usb usb1: configuration #1 chosen from 1 choice
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 8 ports detected
libata version 3.00 loaded.
e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
PCI: Setting latency timer of device 0000:05:00.1 to 64
e1000: 0000:05:00.1: e1000_probe: (PCI Express:2.5Gb/s:Width x4)
00:04:23:d9:9b:4b
PCI: Setting latency timer of device 0000:00:1d.0 to 64
uhci_hcd 0000:00:1d.0: UHCI Host Controller
uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 2
uhci_hcd 0000:00:1d.0: irq 23, io base 0x00003080
usb usb2: configuration #1 chosen from 1 choice
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 2 ports detected
e1000: eth1: e1000_probe: Intel(R) PRO/1000 Network Connection
PCI: Setting latency timer of device 0000:00:1d.1 to 64
uhci_hcd 0000:00:1d.1: UHCI Host Controller
uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 3
uhci_hcd 0000:00:1d.1: irq 22, io base 0x00003060
usb usb3: configuration #1 chosen from 1 choice
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 2 ports detected
PCI: Setting latency timer of device 0000:00:1d.2 to 64
uhci_hcd 0000:00:1d.2: UHCI Host Controller
uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 4
uhci_hcd 0000:00:1d.2: irq 23, io base 0x00003040
usb usb4: configuration #1 chosen from 1 choice
hub 4-0:1.0: USB hub found
hub 4-0:1.0: 2 ports detected
PCI: Setting latency timer of device 0000:00:1d.3 to 64
uhci_hcd 0000:00:1d.3: UHCI Host Controller
uhci_hcd 0000:00:1d.3: new USB bus registered, assigned bus number 5
uhci_hcd 0000:00:1d.3: irq 22, io base 0x00003020
usb usb5: configuration #1 chosen from 1 choice
hub 5-0:1.0: USB hub found
hub 5-0:1.0: 2 ports detected
ata_piix 0000:00:1f.1: version 2.12
PCI: Setting latency timer of device 0000:00:1f.1 to 64
scsi0 : ata_piix
scsi1 : ata_piix
ata1: PATA max UDMA/100 cmd 0x1f0 ctl 0x3f6 bmdma 0x30b0 irq 14
ata2: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0x30b8 irq 15
ata1.00: ATAPI: SONY DVD RW DW-Q78A, SYS1, max UDMA/33
ata1.00: configured for UDMA/33
scsi 0:0:0:0: CD-ROM            SONY     DVD RW DW-Q78A   SYS1 PQ: 0 ANSI: 5
ata_piix 0000:00:1f.2: MAP [ P0 P2 P1 P3 ]
PCI: Setting latency timer of device 0000:00:1f.2 to 64
scsi2 : ata_piix
scsi3 : ata_piix
ata3: SATA max UDMA/133 cmd 0x30c8 ctl 0x30e4 bmdma 0x30a0 irq 20
ata4: SATA max UDMA/133 cmd 0x30c0 ctl 0x30e0 bmdma 0x30a8 irq 20
ata3.00: ATA-7: WDC WD3200YS-01PGB0, 21.00M21, max UDMA/133
ata3.00: 625142448 sectors, multi 16: LBA48 NCQ (depth 0/1)
ata3.01: ATA-7: WDC WD3200YS-01PGB0, 21.00M21, max UDMA/133
ata3.01: 625142448 sectors, multi 16: LBA48 NCQ (depth 0/1)
ata3.00: configured for UDMA/133
ata3.01: configured for UDMA/133
ata4.00: ATA-7: WDC WD3200YS-01PGB0, 21.00M21, max UDMA/133
ata4.00: 625142448 sectors, multi 16: LBA48 NCQ (depth 0/1)
ata4.01: ATA-7: WDC WD3200YS-01PGB0, 21.00M21, max UDMA/133
ata4.01: 625142448 sectors, multi 16: LBA48 NCQ (depth 0/1)
ata4.00: configured for UDMA/133
ata4.01: configured for UDMA/133
scsi 2:0:0:0: Direct-Access     ATA      WDC WD3200YS-01P 21.0 PQ: 0 ANSI: 5
scsi 2:0:1:0: Direct-Access     ATA      WDC WD3200YS-01P 21.0 PQ: 0 ANSI: 5
scsi 3:0:0:0: Direct-Access     ATA      WDC WD3200YS-01P 21.0 PQ: 0 ANSI: 5
scsi 3:0:1:0: Direct-Access     ATA      WDC WD3200YS-01P 21.0 PQ: 0 ANSI: 5
Driver 'sr' needs updating - please use bus_type methods
Driver 'sd' needs updating - please use bus_type methods
sr0: scsi3-mmc drive: 24x/24x writer cd/rw xa/form2 cdda tray
Uniform CD-ROM driver Revision: 3.20
sr 0:0:0:0: Attached scsi CD-ROM sr0
sd 2:0:0:0: [sda] 625142448 512-byte hardware sectors (320073 MB)
sd 2:0:0:0: [sda] Write Protect is off
sd 2:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 2:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't
support DPO or FUA
sd 2:0:0:0: [sda] 625142448 512-byte hardware sectors (320073 MB)
sd 2:0:0:0: [sda] Write Protect is off
sd 2:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 2:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't
support DPO or FUA
 sda:<5>sr 0:0:0:0: Attached scsi generic sg0 type 5
sd 2:0:0:0: Attached scsi generic sg1 type 0
scsi 2:0:1:0: Attached scsi generic sg2 type 0
scsi 3:0:0:0: Attached scsi generic sg3 type 0
scsi 3:0:1:0: Attached scsi generic sg4 type 0
 sda1 sda2 < sda5 >
sd 2:0:0:0: [sda] Attached SCSI disk
sd 2:0:1:0: [sdb] 625142448 512-byte hardware sectors (320073 MB)
sd 2:0:1:0: [sdb] Write Protect is off
sd 2:0:1:0: [sdb] Mode Sense: 00 3a 00 00
sd 2:0:1:0: [sdb] Write cache: enabled, read cache: enabled, doesn't
support DPO or FUA
sd 2:0:1:0: [sdb] 625142448 512-byte hardware sectors (320073 MB)
sd 2:0:1:0: [sdb] Write Protect is off
sd 2:0:1:0: [sdb] Mode Sense: 00 3a 00 00
sd 2:0:1:0: [sdb] Write cache: enabled, read cache: enabled, doesn't
support DPO or FUA
 sdb: unknown partition table
sd 2:0:1:0: [sdb] Attached SCSI disk
sd 3:0:0:0: [sdc] 625142448 512-byte hardware sectors (320073 MB)
sd 3:0:0:0: [sdc] Write Protect is off
sd 3:0:0:0: [sdc] Mode Sense: 00 3a 00 00
sd 3:0:0:0: [sdc] Write cache: enabled, read cache: enabled, doesn't
support DPO or FUA
sd 3:0:0:0: [sdc] 625142448 512-byte hardware sectors (320073 MB)
sd 3:0:0:0: [sdc] Write Protect is off
sd 3:0:0:0: [sdc] Mode Sense: 00 3a 00 00
sd 3:0:0:0: [sdc] Write cache: enabled, read cache: enabled, doesn't
support DPO or FUA
 sdc:
sd 3:0:0:0: [sdc] Attached SCSI disk
sd 3:0:1:0: [sdd] 625142448 512-byte hardware sectors (320073 MB)
sd 3:0:1:0: [sdd] Write Protect is off
sd 3:0:1:0: [sdd] Mode Sense: 00 3a 00 00
sd 3:0:1:0: [sdd] Write cache: enabled, read cache: enabled, doesn't
support DPO or FUA
sd 3:0:1:0: [sdd] 625142448 512-byte hardware sectors (320073 MB)
sd 3:0:1:0: [sdd] Write Protect is off
sd 3:0:1:0: [sdd] Mode Sense: 00 3a 00 00
sd 3:0:1:0: [sdd] Write cache: enabled, read cache: enabled, doesn't
support DPO or FUA
 sdd: unknown partition table
sd 3:0:1:0: [sdd] Attached SCSI disk
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
e1000: eth0: e1000_watchdog: NIC Link is Up 1000 Mbps Full Duplex,
Flow Control: RX
pci_hotplug: PCI Hot Plug PCI Core version: 0.5
shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
iTCO_vendor_support: vendor-support=0
iTCO_wdt: Intel TCO WatchDog Timer Driver v1.02 (26-Jul-2007)
iTCO_wdt: Found a 631xESB/632xESB TCO device (Version=2, TCOBASE=0x0460)
iTCO_wdt: initialized. heartbeat=30 sec (nowayout=0)
ib_mthca: Mellanox InfiniBand HCA driver v0.08 (February 14, 2006)
ib_mthca: Initializing 0000:08:00.0
PCI: Setting latency timer of device 0000:08:00.0 to 64
intel_rng: Firmware space is locked read-only. If you can't or
intel_rng: don't want to disable this in firmware setup, and if
intel_rng: you are certain that your system has a functional
intel_rng: RNG, try using the 'no_fwh_detect' option.
input: PC Speaker as /class/input/input1
NET: Registered protocol family 17
ib_mthca 0000:08:00.0: HCA FW version 1.0.800 is old (1.2.000 is current).
ib_mthca 0000:08:00.0: If you have problems, try updating your HCA FW.
loop: module loaded
lp: driver loaded but no devices found
NET: Registered protocol family 10
lo: Disabled Privacy Extensions
ADDRCONF(NETDEV_UP): ib0: link is not ready
ADDRCONF(NETDEV_CHANGE): ib0: link becomes ready
Adding 6024332k swap on /dev/sda5.  Priority:-1 extents:1 across:6024332k
EXT3 FS on sda1, internal journal
Loading iSCSI transport class v2.0-724.
iscsi: registered transport (tcp)
iscsi: registered transport (iser)
eth0: no IPv6 routers present
ib0: no IPv6 routers present

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
