Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id B117E6B0039
	for <linux-mm@kvack.org>; Wed,  9 Oct 2013 12:29:50 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id kl14so1285151pab.25
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 09:29:50 -0700 (PDT)
Received: by mail-ea0-f176.google.com with SMTP id q16so537983ead.35
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 09:29:45 -0700 (PDT)
Date: Wed, 9 Oct 2013 18:29:42 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/63] Basic scheduler support for automatic NUMA
 balancing V9
Message-ID: <20131009162942.GA12178@gmail.com>
References: <1381141781-10992-1-git-send-email-mgorman@suse.de>
 <20131009162801.GA10452@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="LZvS9be/3tNcYl/X"
Content-Disposition: inline
In-Reply-To: <20131009162801.GA10452@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


--LZvS9be/3tNcYl/X
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


full crashlog attached.

	Ingo

--LZvS9be/3tNcYl/X
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="crash.log"
Content-Transfer-Encoding: quoted-printable

Linux version 3.12.0-rc4-01668-gfd71a04-dirty (mingo@earth5) (gcc version 4=
=2E7.2 20120921 (Red Hat 4.7.2-2) (GCC) ) #229484 Wed Oct 9 16:59:58 CEST 2=
013
KERNEL supported cpus:
  Centaur CentaurHauls
  Transmeta GenuineTMx86
  Transmeta TransmetaCPU
CPU: vendor_id 'AuthenticAMD' unknown, using generic init.
CPU: Your system may be unstable.
e820: BIOS-provided physical RAM map:
BIOS-e820: [mem 0x0000000000000000-0x000000000009f7ff] usable
BIOS-e820: [mem 0x000000000009f800-0x000000000009ffff] reserved
BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
BIOS-e820: [mem 0x0000000000100000-0x000000003ffeffff] usable
BIOS-e820: [mem 0x000000003fff0000-0x000000003fff2fff] ACPI NVS
BIOS-e820: [mem 0x000000003fff3000-0x000000003fffffff] ACPI data
BIOS-e820: [mem 0x00000000e0000000-0x00000000efffffff] reserved
BIOS-e820: [mem 0x00000000fec00000-0x00000000ffffffff] reserved
console [earlyser0] enabled
debug: ignoring loglevel setting.
Notice: NX (Execute Disable) protection cannot be enabled: non-PAE kernel!
e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> reserved
e820: remove [mem 0x000a0000-0x000fffff] usable
e820: last_pfn =3D 0x3fff0 max_arch_pfn =3D 0x100000
MTRR default type: uncachable
MTRR fixed ranges enabled:
  00000-9FFFF write-back
  A0000-BFFFF uncachable
  C0000-C7FFF write-protect
  C8000-FFFFF uncachable
MTRR variable ranges enabled:
  0 base 0000000000 mask FFC0000000 write-back
  1 disabled
  2 disabled
  3 disabled
  4 disabled
  5 disabled
  6 disabled
  7 disabled
x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
Scanning 1 areas for low memory corruption
initial memory mapped: [mem 0x00000000-0x037fffff]
Base memory trampoline at [b009b000] 9b000 size 16384
init_memory_mapping: [mem 0x00000000-0x000fffff]
 [mem 0x00000000-0x000fffff] page 4k
init_memory_mapping: [mem 0x3f800000-0x3fbfffff]
 [mem 0x3f800000-0x3fbfffff] page 4k
BRK [0x0335b000, 0x0335bfff] PGTABLE
init_memory_mapping: [mem 0x38000000-0x3f7fffff]
 [mem 0x38000000-0x3f7fffff] page 4k
BRK [0x0335c000, 0x0335cfff] PGTABLE
BRK [0x0335d000, 0x0335dfff] PGTABLE
BRK [0x0335e000, 0x0335efff] PGTABLE
BRK [0x0335f000, 0x0335ffff] PGTABLE
BRK [0x03360000, 0x03360fff] PGTABLE
init_memory_mapping: [mem 0x00100000-0x37ffffff]
 [mem 0x00100000-0x37ffffff] page 4k
init_memory_mapping: [mem 0x3fc00000-0x3ffeffff]
 [mem 0x3fc00000-0x3ffeffff] page 4k
0MB HIGHMEM available.
1023MB LOWMEM available.
  mapped low ram: 0 - 3fff0000
  low ram: 0 - 3fff0000
Zone ranges:
  Normal   [mem 0x00001000-0x3ffeffff]
  HighMem  empty
Movable zone start for each node
Early memory node ranges
  node   0: [mem 0x00001000-0x0009efff]
  node   0: [mem 0x00100000-0x3ffeffff]
On node 0 totalpages: 262030
free_area_init_node: node 0, pgdat b2cac760, node_mem_map ef214024
  Normal zone: 2304 pages used for memmap
  Normal zone: 0 pages reserved
  Normal zone: 262030 pages, LIFO batch:31
Using APIC driver default
SFI: Simple Firmware Interface v0.81 http://simplefirmware.org
No local APIC present or hardware disabled
APIC: disable apic facility
APIC: switched to apic NOOP
------------[ cut here ]------------
WARNING: CPU: 0 PID: 0 at arch/x86/kernel/apic/apic_noop.c:113 noop_apic_re=
ad+0x29/0x3f()
CPU: 0 PID: 0 Comm: swapper Not tainted 3.12.0-rc4-01668-gfd71a04-dirty #22=
9484
 b286bb7c b2b4def8 b235a604 b2b4df28 b1028784 b286ec98 00000000 00000000
 b286bb7c 00000071 b1015bba b1015bba 00000071 00000000 b2dc0000 b2b4df38
 b102882f 00000009 00000000 b2b4df40 b1015bba b2b4df48 b10142e8 b2b4df58
Call Trace:
 [<b235a604>] dump_stack+0x16/0x18
 [<b1028784>] warn_slowpath_common+0x73/0x89
 [<b1015bba>] ? noop_apic_read+0x29/0x3f
 [<b102882f>] warn_slowpath_null+0x1d/0x1f
 [<b1015bba>] noop_apic_read+0x29/0x3f
 [<b10142e8>] read_apic_id+0x14/0x1f
 [<b2d0ed8d>] init_apic_mappings+0xea/0x140
 [<b2d080f3>] setup_arch+0xa45/0xab3
 [<b23557b4>] ? printk+0x38/0x3a
 [<b2d057e7>] start_kernel+0xb9/0x354
 [<b2d05384>] i386_start_kernel+0x12e/0x131
---[ end trace a7919e7f17c0a725 ]---
nr_irqs_gsi: 16
e820: [mem 0x40000000-0xdfffffff] available for PCI devices
pcpu-alloc: s0 r0 d32768 u32768 alloc=3D1*32768
pcpu-alloc: [0] 0=20
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 259726
Kernel command line: root=3D/dev/sda1 earlyprintk=3DttyS0,115200,keep conso=
le=3DttyS0,115200 debug initcall_debug enforcing=3D0 apic=3Dverbose ignore_=
loglevel sysrq_always_enabled selinux=3D0 nmi_watchdog=3D0 3 panic=3D1 3
sysrq: sysrq always enabled.
PID hash table entries: 4096 (order: 2, 16384 bytes)
Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
Initializing CPU#0
Initializing HighMem for node 0 (00000000:00000000)
Memory: 1000788K/1048120K available (19921K kernel code, 1764K rwdata, 8020=
K rodata, 732K init, 5700K bss, 47332K reserved, 0K highmem)
virtual kernel memory layout:
    fixmap  : 0xfffa3000 - 0xfffff000   ( 368 kB)
    pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
    vmalloc : 0xf07f0000 - 0xff7fe000   ( 240 MB)
    lowmem  : 0xb0000000 - 0xefff0000   (1023 MB)
      .init : 0xb2d05000 - 0xb2dbc000   ( 732 kB)
      .data : 0xb237475f - 0xb2d040e0   (9790 kB)
      .text : 0xb1000000 - 0xb237475f   (19921 kB)
Checking if this processor honours the WP bit even in supervisor mode...Ok.
NR_IRQS:2304 nr_irqs:256 16
------------[ cut here ]------------
WARNING: CPU: 0 PID: 0 at arch/x86/kernel/apic/apic_noop.c:119 noop_apic_wr=
ite+0x26/0x3b()
CPU: 0 PID: 0 Comm: swapper Tainted: G        W    3.12.0-rc4-01668-gfd71a0=
4-dirty #229484
 b286bb7c b2b4df4c b235a604 b2b4df7c b1028784 b286ec98 00000000 00000000
 b286bb7c 00000077 b1015b7c b1015b7c 00000077 b2d91900 b2b54460 b2b4df8c
 b102882f 00000009 00000000 b2b4df94 b1015b7c b2b4df9c b2d0eb47 b2b4dfb4
Call Trace:
 [<b235a604>] dump_stack+0x16/0x18
 [<b1028784>] warn_slowpath_common+0x73/0x89
 [<b1015b7c>] ? noop_apic_write+0x26/0x3b
 [<b102882f>] warn_slowpath_null+0x1d/0x1f
 [<b1015b7c>] noop_apic_write+0x26/0x3b
 [<b2d0eb47>] init_bsp_APIC+0x64/0xb4
 [<b2d081bc>] init_ISA_irqs+0x16/0x46
 [<b2d0821c>] native_init_IRQ+0xa/0x1ae
 [<b2d08210>] init_IRQ+0x24/0x26
 [<b2d0591f>] start_kernel+0x1f1/0x354
 [<b2d054d3>] ? repair_env_string+0x5e/0x5e
 [<b2d05384>] i386_start_kernel+0x12e/0x131
---[ end trace a7919e7f17c0a726 ]---
CPU 0 irqstacks, hard=3Db008c000 soft=3Db008e000
spurious 8259A interrupt: IRQ7.
Console: colour VGA+ 80x25
console [ttyS0] enabled
Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
=2E.. MAX_LOCKDEP_SUBCLASSES:  8
=2E.. MAX_LOCK_DEPTH:          48
=2E.. MAX_LOCKDEP_KEYS:        8191
=2E.. CLASSHASH_SIZE:          4096
=2E.. MAX_LOCKDEP_ENTRIES:     16384
=2E.. MAX_LOCKDEP_CHAINS:      32768
=2E.. CHAINHASH_SIZE:          16384
 memory used by lock dependency info: 3551 kB
 per task-struct memory footprint: 1152 bytes
------------------------
| Locking API testsuite:
----------------------------------------------------------------------------
                                 | spin |wlock |rlock |mutex | wsem | rsem |
  --------------------------------------------------------------------------
                     A-A deadlock:                     A-A deadlock:failed|=
failed|failed|failed|  ok  |  ok  |failed|failed|failed|failed|failed|faile=
d|

                 A-B-B-A deadlock:                 A-B-B-A deadlock:failed|=
failed|failed|failed|  ok  |  ok  |failed|failed|failed|failed|failed|faile=
d|

             A-B-B-C-C-A deadlock:             A-B-B-C-C-A deadlock:failed|=
failed|failed|failed|  ok  |  ok  |failed|failed|failed|failed|failed|faile=
d|

             A-B-C-A-B-C deadlock:             A-B-C-A-B-C deadlock:failed|=
failed|failed|failed|  ok  |  ok  |failed|failed|failed|failed|failed|faile=
d|

         A-B-B-C-C-D-D-A deadlock:         A-B-B-C-C-D-D-A deadlock:failed|=
failed|failed|failed|  ok  |  ok  |failed|failed|failed|failed|failed|faile=
d|

         A-B-C-D-B-D-D-A deadlock:         A-B-C-D-B-D-D-A deadlock:failed|=
failed|failed|failed|  ok  |  ok  |failed|failed|failed|failed|failed|faile=
d|

         A-B-C-D-B-C-D-A deadlock:         A-B-C-D-B-C-D-A deadlock:failed|=
failed|failed|failed|  ok  |  ok  |failed|failed|failed|failed|failed|faile=
d|

                    double unlock:                    double unlock:  ok  |=
  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok =
 |

                  initialize held:                  initialize held:  ok  |=
  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok =
 |

                 bad unlock order:                 bad unlock order:  ok  |=
  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok =
 |

  --------------------------------------------------------------------------
              recursive read-lock:              recursive read-lock:       =
      |             |  ok  |  ok  |             |             |failed|faile=
d|

           recursive read-lock #2:           recursive read-lock #2:       =
      |             |  ok  |  ok  |             |             |failed|faile=
d|

            mixed read-write-lock:            mixed read-write-lock:       =
      |             |failed|failed|             |             |failed|faile=
d|

            mixed write-read-lock:            mixed write-read-lock:       =
      |             |failed|failed|             |             |failed|faile=
d|

  --------------------------------------------------------------------------
     hard-irqs-on + irq-safe-A/12:     hard-irqs-on + irq-safe-A/12:failed|=
failed|failed|failed|  ok  |  ok  |

     soft-irqs-on + irq-safe-A/12:     soft-irqs-on + irq-safe-A/12:failed|=
failed|failed|failed|  ok  |  ok  |

     hard-irqs-on + irq-safe-A/21:     hard-irqs-on + irq-safe-A/21:failed|=
failed|failed|failed|  ok  |  ok  |

     soft-irqs-on + irq-safe-A/21:     soft-irqs-on + irq-safe-A/21:failed|=
failed|failed|failed|  ok  |  ok  |

       sirq-safe-A =3D> hirqs-on/12:       sirq-safe-A =3D> hirqs-on/12:fai=
led|failed|failed|failed|  ok  |  ok  |

       sirq-safe-A =3D> hirqs-on/21:       sirq-safe-A =3D> hirqs-on/21:fai=
led|failed|failed|failed|  ok  |  ok  |

         hard-safe-A + irqs-on/12:         hard-safe-A + irqs-on/12:failed|=
failed|failed|failed|  ok  |  ok  |

         soft-safe-A + irqs-on/12:         soft-safe-A + irqs-on/12:failed|=
failed|failed|failed|  ok  |  ok  |

         hard-safe-A + irqs-on/21:         hard-safe-A + irqs-on/21:failed|=
failed|failed|failed|  ok  |  ok  |

         soft-safe-A + irqs-on/21:         soft-safe-A + irqs-on/21:failed|=
failed|failed|failed|  ok  |  ok  |

    hard-safe-A + unsafe-B #1/123:    hard-safe-A + unsafe-B #1/123:failed|=
failed|failed|failed|  ok  |  ok  |

    soft-safe-A + unsafe-B #1/123:    soft-safe-A + unsafe-B #1/123:failed|=
failed|failed|failed|  ok  |  ok  |

    hard-safe-A + unsafe-B #1/132:    hard-safe-A + unsafe-B #1/132:failed|=
failed|failed|failed|  ok  |  ok  |

    soft-safe-A + unsafe-B #1/132:    soft-safe-A + unsafe-B #1/132:failed|=
failed|failed|failed|  ok  |  ok  |

    hard-safe-A + unsafe-B #1/213:    hard-safe-A + unsafe-B #1/213:failed|=
failed|failed|failed|  ok  |  ok  |

    soft-safe-A + unsafe-B #1/213:    soft-safe-A + unsafe-B #1/213:failed|=
failed|failed|failed|  ok  |  ok  |

    hard-safe-A + unsafe-B #1/231:    hard-safe-A + unsafe-B #1/231:failed|=
failed|failed|failed|  ok  |  ok  |

    soft-safe-A + unsafe-B #1/231:    soft-safe-A + unsafe-B #1/231:failed|=
failed|failed|failed|  ok  |  ok  |

    hard-safe-A + unsafe-B #1/312:    hard-safe-A + unsafe-B #1/312:failed|=
failed|failed|failed|  ok  |  ok  |

    soft-safe-A + unsafe-B #1/312:    soft-safe-A + unsafe-B #1/312:failed|=
failed|failed|failed|  ok  |  ok  |

    hard-safe-A + unsafe-B #1/321:    hard-safe-A + unsafe-B #1/321:failed|=
failed|failed|failed|  ok  |  ok  |

    soft-safe-A + unsafe-B #1/321:    soft-safe-A + unsafe-B #1/321:failed|=
failed|failed|failed|  ok  |  ok  |

    hard-safe-A + unsafe-B #2/123:    hard-safe-A + unsafe-B #2/123:failed|=
failed|failed|failed|  ok  |  ok  |

    soft-safe-A + unsafe-B #2/123:    soft-safe-A + unsafe-B #2/123:failed|=
failed|failed|failed|  ok  |  ok  |

    hard-safe-A + unsafe-B #2/132:    hard-safe-A + unsafe-B #2/132:failed|=
failed|failed|failed|  ok  |  ok  |

    soft-safe-A + unsafe-B #2/132:    soft-safe-A + unsafe-B #2/132:failed|=
failed|failed|failed|  ok  |  ok  |

    hard-safe-A + unsafe-B #2/213:    hard-safe-A + unsafe-B #2/213:failed|=
failed|failed|failed|  ok  |  ok  |

    soft-safe-A + unsafe-B #2/213:    soft-safe-A + unsafe-B #2/213:failed|=
failed|failed|failed|  ok  |  ok  |

    hard-safe-A + unsafe-B #2/231:    hard-safe-A + unsafe-B #2/231:failed|=
failed|failed|failed|  ok  |  ok  |

    soft-safe-A + unsafe-B #2/231:    soft-safe-A + unsafe-B #2/231:failed|=
failed|failed|failed|  ok  |  ok  |

    hard-safe-A + unsafe-B #2/312:    hard-safe-A + unsafe-B #2/312:failed|=
failed|failed|failed|  ok  |  ok  |

    soft-safe-A + unsafe-B #2/312:    soft-safe-A + unsafe-B #2/312:failed|=
failed|failed|failed|  ok  |  ok  |

    hard-safe-A + unsafe-B #2/321:    hard-safe-A + unsafe-B #2/321:failed|=
failed|failed|failed|  ok  |  ok  |

    soft-safe-A + unsafe-B #2/321:    soft-safe-A + unsafe-B #2/321:failed|=
failed|failed|failed|  ok  |  ok  |

      hard-irq lock-inversion/123:      hard-irq lock-inversion/123:failed|=
failed|failed|failed|  ok  |  ok  |

      soft-irq lock-inversion/123:      soft-irq lock-inversion/123:failed|=
failed|failed|failed|  ok  |  ok  |

      hard-irq lock-inversion/132:      hard-irq lock-inversion/132:failed|=
failed|failed|failed|  ok  |  ok  |

      soft-irq lock-inversion/132:      soft-irq lock-inversion/132:failed|=
failed|failed|failed|  ok  |  ok  |

      hard-irq lock-inversion/213:      hard-irq lock-inversion/213:failed|=
failed|failed|failed|  ok  |  ok  |

      soft-irq lock-inversion/213:      soft-irq lock-inversion/213:failed|=
failed|failed|failed|  ok  |  ok  |

      hard-irq lock-inversion/231:      hard-irq lock-inversion/231:failed|=
failed|failed|failed|  ok  |  ok  |

      soft-irq lock-inversion/231:      soft-irq lock-inversion/231:failed|=
failed|failed|failed|  ok  |  ok  |

      hard-irq lock-inversion/312:      hard-irq lock-inversion/312:failed|=
failed|failed|failed|  ok  |  ok  |

      soft-irq lock-inversion/312:      soft-irq lock-inversion/312:failed|=
failed|failed|failed|  ok  |  ok  |

      hard-irq lock-inversion/321:      hard-irq lock-inversion/321:failed|=
failed|failed|failed|  ok  |  ok  |

      soft-irq lock-inversion/321:      soft-irq lock-inversion/321:failed|=
failed|failed|failed|  ok  |  ok  |

      hard-irq read-recursion/123:      hard-irq read-recursion/123:  ok  |=
  ok  |

      soft-irq read-recursion/123:      soft-irq read-recursion/123:  ok  |=
  ok  |

      hard-irq read-recursion/132:      hard-irq read-recursion/132:  ok  |=
  ok  |

      soft-irq read-recursion/132:      soft-irq read-recursion/132:  ok  |=
  ok  |

      hard-irq read-recursion/213:      hard-irq read-recursion/213:  ok  |=
  ok  |

      soft-irq read-recursion/213:      soft-irq read-recursion/213:  ok  |=
  ok  |

      hard-irq read-recursion/231:      hard-irq read-recursion/231:  ok  |=
  ok  |

      soft-irq read-recursion/231:      soft-irq read-recursion/231:  ok  |=
  ok  |

      hard-irq read-recursion/312:      hard-irq read-recursion/312:  ok  |=
  ok  |

      soft-irq read-recursion/312:      soft-irq read-recursion/312:  ok  |=
  ok  |

      hard-irq read-recursion/321:      hard-irq read-recursion/321:  ok  |=
  ok  |

      soft-irq read-recursion/321:      soft-irq read-recursion/321:  ok  |=
  ok  |

  --------------------------------------------------------------------------
  | Wound/wait tests |
  ---------------------
                  ww api failures:                  ww api failures:  ok  |=
  ok  |  ok  |  ok  |  ok  |  ok  |

               ww contexts mixing:               ww contexts mixing:failed|=
failed|  ok  |  ok  |

             finishing ww context:             finishing ww context:  ok  |=
  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

               locking mismatches:               locking mismatches:  ok  |=
  ok  |  ok  |  ok  |  ok  |  ok  |

                 EDEADLK handling:                 EDEADLK handling:  ok  |=
  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

           spinlock nest unlocked:           spinlock nest unlocked:  ok  |=
  ok  |

  -----------------------------------------------------
                                 |block | try  |context|
  -----------------------------------------------------
                          context:                          context:failed|=
failed|  ok  |  ok  |  ok  |  ok  |

                              try:                              try:failed|=
failed|  ok  |  ok  |failed|failed|

                            block:                            block:failed|=
failed|  ok  |  ok  |failed|failed|

                         spinlock:                         spinlock:failed|=
failed|  ok  |  ok  |failed|failed|

--------------------------------------------------------
141 out of 253 testcases failed, as expected. |
----------------------------------------------------
tsc: Fast TSC calibration using PIT
tsc: Detected 2010.210 MHz processor
Calibrating delay loop (skipped), value calculated using timer frequency.. =
Calibrating delay loop (skipped), value calculated using timer frequency.. =
4020.42 BogoMIPS (lpj=3D2010210)
4020.42 BogoMIPS (lpj=3D2010210)
pid_max: default: 32768 minimum: 301
Security Framework initialized
TOMOYO Linux initialized
AppArmor: AppArmor disabled by boot time parameter
Mount-cache hash table entries: 512
mce: CPU supports 5 MCE banks
mce: unknown CPU type - not enabling MCE support
Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0
tlb_flushall_shift: -1
Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0
tlb_flushall_shift: -1
CPU: CPU: AuthenticAMD AuthenticAMD AMD Athlon(tm) 64 X2 Dual Core Processo=
r 3800+AMD Athlon(tm) 64 X2 Dual Core Processor 3800+ (fam: 0f, model: 23 (=
fam: 0f, model: 23, stepping: 02)
, stepping: 02)
calling  set_real_mode_permissions+0x0/0x7c @ 1
initcall set_real_mode_permissions+0x0/0x7c returned 0 after 0 usecs
calling  trace_init_flags_sys_exit+0x0/0x11 @ 1
initcall trace_init_flags_sys_exit+0x0/0x11 returned 0 after 0 usecs
calling  trace_init_flags_sys_enter+0x0/0x11 @ 1
initcall trace_init_flags_sys_enter+0x0/0x11 returned 0 after 0 usecs
calling  init_hw_perf_events+0x0/0x4bb @ 1
Performance Events: Performance Events: no PMU driver, software events only.
no PMU driver, software events only.
initcall init_hw_perf_events+0x0/0x4bb returned 0 after 1953 usecs
calling  register_trigger_all_cpu_backtrace+0x0/0x13 @ 1
initcall register_trigger_all_cpu_backtrace+0x0/0x13 returned 0 after 0 use=
cs
calling  spawn_ksoftirqd+0x0/0x17 @ 1
initcall spawn_ksoftirqd+0x0/0x17 returned 0 after 0 usecs
calling  init_workqueues+0x0/0x2cf @ 1
initcall init_workqueues+0x0/0x2cf returned 0 after 0 usecs
calling  relay_init+0x0/0x7 @ 1
initcall relay_init+0x0/0x7 returned 0 after 0 usecs
calling  tracer_alloc_buffers+0x0/0x18c @ 1
initcall tracer_alloc_buffers+0x0/0x18c returned 0 after 976 usecs
calling  init_events+0x0/0x5d @ 1
initcall init_events+0x0/0x5d returned 0 after 0 usecs
calling  init_trace_printk+0x0/0x7 @ 1
initcall init_trace_printk+0x0/0x7 returned 0 after 0 usecs
calling  event_trace_memsetup+0x0/0x5a @ 1
initcall event_trace_memsetup+0x0/0x5a returned 0 after 0 usecs
calling  init_ftrace_syscalls+0x0/0x5e @ 1
initcall init_ftrace_syscalls+0x0/0x5e returned 0 after 976 usecs
calling  dynamic_debug_init+0x0/0x22c @ 1
initcall dynamic_debug_init+0x0/0x22c returned 0 after 2929 usecs
enabled ExtINT on CPU#0
No ESR for 82489DX.
Using local APIC timer interrupts.
calibrating APIC timer ...
Using local APIC timer interrupts.
calibrating APIC timer ...
=2E.. lapic delta =3D 0
------------[ cut here ]------------
WARNING: CPU: 0 PID: 1 at kernel/time/clockevents.c:49 clockevent_delta2ns+=
0x53/0xb7()
CPU: 0 PID: 1 Comm: swapper Tainted: G        W    3.12.0-rc4-01668-gfd71a0=
4-dirty #229484
 b2879283 b2879283 b010dedc b010dedc b235a604 b235a604 b010df0c b010df0c b1=
028784 b1028784 b286ec98 b286ec98 00000000 00000000 00000001 00000001

 b2879283 b2879283 00000031 00000031 b10613a9 b10613a9 b10613a9 b10613a9 00=
000031 00000031 00000000 00000000 b2b5a120 b2b5a120 b010df1c b010df1c

 b102882f b102882f 00000009 00000009 00000000 00000000 b010df34 b010df34 b1=
0613a9 b10613a9 00000000 00000000 00000000 00000000 7fffffff 7fffffff

Call Trace:
 [<b235a604>] dump_stack+0x16/0x18
 [<b1028784>] warn_slowpath_common+0x73/0x89
 [<b10613a9>] ? clockevent_delta2ns+0x53/0xb7
 [<b102882f>] warn_slowpath_null+0x1d/0x1f
 [<b10613a9>] clockevent_delta2ns+0x53/0xb7
 [<b2d0e6fe>] setup_boot_APIC_clock+0x1e4/0x3d1
 [<b2d0ef11>] APIC_init_uniprocessor+0xef/0xfb
 [<b2d05c2a>] kernel_init_freeable+0x5a/0x178
 [<b1047d39>] ? finish_task_switch.constprop.64+0x28/0x9d
 [<b2350e9e>] kernel_init+0xb/0xc3
 [<b23735d7>] ret_from_kernel_thread+0x1b/0x28
 [<b2350e93>] ? rest_init+0xb7/0xb7
---[ end trace a7919e7f17c0a727 ]---
=2E.... delta 0
=2E.... mult: 1
=2E.... calibration result: 0
=2E.... CPU clock speed is 2009.0995 MHz.
=2E.... host bus clock speed is 0.0000 MHz.
APIC frequency too slow, disabling apic timer
devtmpfs: initialized
calling  init_mmap_min_addr+0x0/0x11 @ 1
initcall init_mmap_min_addr+0x0/0x11 returned 0 after 0 usecs
calling  net_ns_init+0x0/0x142 @ 1
initcall net_ns_init+0x0/0x142 returned 0 after 0 usecs
calling  reboot_init+0x0/0x7 @ 1
initcall reboot_init+0x0/0x7 returned 0 after 0 usecs
calling  init_lapic_sysfs+0x0/0x1e @ 1
initcall init_lapic_sysfs+0x0/0x1e returned 0 after 0 usecs
calling  wq_sysfs_init+0x0/0x11 @ 1
initcall wq_sysfs_init+0x0/0x11 returned 0 after 0 usecs
calling  ksysfs_init+0x0/0x7a @ 1
initcall ksysfs_init+0x0/0x7a returned 0 after 0 usecs
calling  pm_init+0x0/0x7a @ 1
initcall pm_init+0x0/0x7a returned 0 after 0 usecs
calling  init_jiffies_clocksource+0x0/0xf @ 1
initcall init_jiffies_clocksource+0x0/0xf returned 0 after 0 usecs
calling  init_wakeup_tracer+0x0/0x1d @ 1
initcall init_wakeup_tracer+0x0/0x1d returned 0 after 0 usecs
calling  event_trace_enable+0x0/0xf1 @ 1
initcall event_trace_enable+0x0/0xf1 returned 0 after 2929 usecs
calling  init_zero_pfn+0x0/0x25 @ 1
initcall init_zero_pfn+0x0/0x25 returned 0 after 0 usecs
calling  memory_failure_init+0x0/0x91 @ 1
initcall memory_failure_init+0x0/0x91 returned 0 after 0 usecs
calling  fsnotify_init+0x0/0x2c @ 1
initcall fsnotify_init+0x0/0x2c returned 0 after 0 usecs
calling  filelock_init+0x0/0x48 @ 1
initcall filelock_init+0x0/0x48 returned 0 after 0 usecs
calling  init_aout_binfmt+0x0/0x13 @ 1
initcall init_aout_binfmt+0x0/0x13 returned 0 after 0 usecs
calling  init_misc_binfmt+0x0/0x28 @ 1
initcall init_misc_binfmt+0x0/0x28 returned 0 after 0 usecs
calling  init_elf_binfmt+0x0/0x13 @ 1
initcall init_elf_binfmt+0x0/0x13 returned 0 after 0 usecs
calling  debugfs_init+0x0/0x4c @ 1
initcall debugfs_init+0x0/0x4c returned 0 after 0 usecs
calling  securityfs_init+0x0/0x43 @ 1
initcall securityfs_init+0x0/0x43 returned 0 after 0 usecs
calling  calibrate_xor_blocks+0x0/0x189 @ 1
xor: measuring software checksum speed
   pIII_sse  :  3716.000 MB/sec
   prefetch64-sse:  4840.000 MB/sec
xor: using function: prefetch64-sse (4840.000 MB/sec)
initcall calibrate_xor_blocks+0x0/0x189 returned 0 after 23437 usecs
calling  prandom_init+0x0/0x85 @ 1
initcall prandom_init+0x0/0x85 returned 0 after 0 usecs
calling  test_atomic64+0x0/0x629 @ 1
atomic64 test passed for i386+ platform with CX8 and with SSE
initcall test_atomic64+0x0/0x629 returned 0 after 976 usecs
calling  sfi_sysfs_init+0x0/0xc3 @ 1
initcall sfi_sysfs_init+0x0/0xc3 returned 0 after 0 usecs
calling  virtio_init+0x0/0x22 @ 1
initcall virtio_init+0x0/0x22 returned 0 after 0 usecs
calling  regulator_init+0x0/0x69 @ 1
regulator-dummy: no parameters
initcall regulator_init+0x0/0x69 returned 0 after 976 usecs
calling  early_resume_init+0x0/0x1c3 @ 1
RTC time: 20:27:31, date: 10/05/13
initcall early_resume_init+0x0/0x1c3 returned 0 after 976 usecs
calling  bsp_pm_check_init+0x0/0x11 @ 1
initcall bsp_pm_check_init+0x0/0x11 returned 0 after 0 usecs
calling  sock_init+0x0/0x89 @ 1
initcall sock_init+0x0/0x89 returned 0 after 0 usecs
calling  netpoll_init+0x0/0x39 @ 1
initcall netpoll_init+0x0/0x39 returned 0 after 0 usecs
calling  netlink_proto_init+0x0/0x197 @ 1
NET: Registered protocol family 16
initcall netlink_proto_init+0x0/0x197 returned 0 after 976 usecs
calling  olpc_init+0x0/0xfc @ 1
initcall olpc_init+0x0/0xfc returned 0 after 0 usecs
calling  bdi_class_init+0x0/0x3c @ 1
initcall bdi_class_init+0x0/0x3c returned 0 after 0 usecs
calling  kobject_uevent_init+0x0/0xf @ 1
initcall kobject_uevent_init+0x0/0xf returned 0 after 976 usecs
calling  gpiolib_sysfs_init+0x0/0x78 @ 1
initcall gpiolib_sysfs_init+0x0/0x78 returned 0 after 0 usecs
calling  pcibus_class_init+0x0/0x14 @ 1
initcall pcibus_class_init+0x0/0x14 returned 0 after 0 usecs
calling  pci_driver_init+0x0/0xf @ 1
initcall pci_driver_init+0x0/0xf returned 0 after 0 usecs
calling  backlight_class_init+0x0/0x4c @ 1
initcall backlight_class_init+0x0/0x4c returned 0 after 0 usecs
calling  video_output_class_init+0x0/0x14 @ 1
initcall video_output_class_init+0x0/0x14 returned 0 after 0 usecs
calling  anatop_regulator_init+0x0/0x11 @ 1
initcall anatop_regulator_init+0x0/0x11 returned 0 after 0 usecs
calling  tty_class_init+0x0/0x2b @ 1
initcall tty_class_init+0x0/0x2b returned 0 after 0 usecs
calling  vtconsole_class_init+0x0/0xc9 @ 1
initcall vtconsole_class_init+0x0/0xc9 returned 0 after 976 usecs
calling  wakeup_sources_debugfs_init+0x0/0x2f @ 1
initcall wakeup_sources_debugfs_init+0x0/0x2f returned 0 after 0 usecs
calling  regmap_initcall+0x0/0xc @ 1
initcall regmap_initcall+0x0/0xc returned 0 after 0 usecs
calling  syscon_init+0x0/0x11 @ 1
initcall syscon_init+0x0/0x11 returned 0 after 0 usecs
calling  hsi_init+0x0/0xf @ 1
initcall hsi_init+0x0/0xf returned 0 after 976 usecs
calling  i2c_init+0x0/0x35 @ 1
initcall i2c_init+0x0/0x35 returned 0 after 0 usecs
calling  arch_kdebugfs_init+0x0/0x2b4 @ 1
initcall arch_kdebugfs_init+0x0/0x2b4 returned 0 after 0 usecs
calling  init_pit_clocksource+0x0/0x15 @ 1
initcall init_pit_clocksource+0x0/0x15 returned 0 after 0 usecs
calling  mtrr_if_init+0x0/0x56 @ 1
initcall mtrr_if_init+0x0/0x56 returned 0 after 0 usecs
calling  kdump_buf_page_init+0x0/0x38 @ 1
initcall kdump_buf_page_init+0x0/0x38 returned 0 after 0 usecs
calling  olpc_ec_init_module+0x0/0x11 @ 1
initcall olpc_ec_init_module+0x0/0x11 returned 0 after 0 usecs
calling  pci_arch_init+0x0/0x55 @ 1
PCI: Using configuration type 1 for base access
initcall pci_arch_init+0x0/0x55 returned 0 after 1953 usecs
calling  topology_init+0x0/0x13 @ 1
Missing cpus node, bailing out
initcall topology_init+0x0/0x13 returned 0 after 976 usecs
calling  mtrr_init_finialize+0x0/0x30 @ 1
initcall mtrr_init_finialize+0x0/0x30 returned 0 after 0 usecs
calling  param_sysfs_init+0x0/0x2be @ 1
initcall param_sysfs_init+0x0/0x2be returned 0 after 37109 usecs
calling  pm_sysrq_init+0x0/0x16 @ 1
initcall pm_sysrq_init+0x0/0x16 returned 0 after 0 usecs
calling  default_bdi_init+0x0/0x78 @ 1
initcall default_bdi_init+0x0/0x78 returned 0 after 0 usecs
calling  init_bio+0x0/0xee @ 1
bio: create slab <bio-0> at 0
initcall init_bio+0x0/0xee returned 0 after 976 usecs
calling  fsnotify_notification_init+0x0/0x9c @ 1
initcall fsnotify_notification_init+0x0/0x9c returned 0 after 0 usecs
calling  cryptomgr_init+0x0/0xf @ 1
initcall cryptomgr_init+0x0/0xf returned 0 after 0 usecs
calling  cryptd_init+0x0/0x80 @ 1
initcall cryptd_init+0x0/0x80 returned 0 after 0 usecs
calling  blk_settings_init+0x0/0x1d @ 1
initcall blk_settings_init+0x0/0x1d returned 0 after 0 usecs
calling  blk_ioc_init+0x0/0x2f @ 1
initcall blk_ioc_init+0x0/0x2f returned 0 after 0 usecs
calling  blk_softirq_init+0x0/0x2a @ 1
initcall blk_softirq_init+0x0/0x2a returned 0 after 0 usecs
calling  blk_iopoll_setup+0x0/0x2a @ 1
initcall blk_iopoll_setup+0x0/0x2a returned 0 after 0 usecs
calling  genhd_device_init+0x0/0x6a @ 1
initcall genhd_device_init+0x0/0x6a returned 0 after 0 usecs
calling  blk_dev_integrity_init+0x0/0x2f @ 1
initcall blk_dev_integrity_init+0x0/0x2f returned 0 after 0 usecs
calling  raid6_select_algo+0x0/0x1e9 @ 1
raid6: mmxx1     1648 MB/s
raid6: mmxx2     2992 MB/s
raid6: sse1x1     464 MB/s
raid6: sse1x2     757 MB/s
raid6: sse2x1     777 MB/s
raid6: sse2x2    1312 MB/s
raid6: int32x1    347 MB/s
raid6: int32x2    546 MB/s
raid6: int32x4    718 MB/s
raid6: int32x8    714 MB/s
raid6: using algorithm mmxx2 (2992 MB/s)
raid6: using intx1 recovery algorithm
initcall raid6_select_algo+0x0/0x1e9 returned 0 after 177734 usecs
calling  gpiolib_debugfs_init+0x0/0x2a @ 1
initcall gpiolib_debugfs_init+0x0/0x2a returned 0 after 0 usecs
calling  max7300_init+0x0/0x11 @ 1
initcall max7300_init+0x0/0x11 returned 0 after 0 usecs
calling  max732x_init+0x0/0x11 @ 1
initcall max732x_init+0x0/0x11 returned 0 after 0 usecs
calling  mcp23s08_init+0x0/0x11 @ 1
initcall mcp23s08_init+0x0/0x11 returned 0 after 0 usecs
calling  pca953x_init+0x0/0x11 @ 1
initcall pca953x_init+0x0/0x11 returned 0 after 0 usecs
calling  pcf857x_init+0x0/0x11 @ 1
initcall pcf857x_init+0x0/0x11 returned 0 after 0 usecs
calling  sx150x_init+0x0/0x11 @ 1
initcall sx150x_init+0x0/0x11 returned 0 after 0 usecs
calling  tc3589x_gpio_init+0x0/0x11 @ 1
initcall tc3589x_gpio_init+0x0/0x11 returned 0 after 0 usecs
calling  gpio_twl4030_init+0x0/0x11 @ 1
initcall gpio_twl4030_init+0x0/0x11 returned 0 after 0 usecs
calling  wm8350_gpio_init+0x0/0x11 @ 1
initcall wm8350_gpio_init+0x0/0x11 returned 0 after 0 usecs
calling  pwm_debugfs_init+0x0/0x2a @ 1
initcall pwm_debugfs_init+0x0/0x2a returned 0 after 0 usecs
calling  pwm_sysfs_init+0x0/0x14 @ 1
initcall pwm_sysfs_init+0x0/0x14 returned 0 after 0 usecs
calling  pci_slot_init+0x0/0x3d @ 1
initcall pci_slot_init+0x0/0x3d returned 0 after 0 usecs
calling  fbmem_init+0x0/0x96 @ 1
initcall fbmem_init+0x0/0x96 returned 0 after 0 usecs
calling  pnp_init+0x0/0xf @ 1
initcall pnp_init+0x0/0xf returned 0 after 0 usecs
calling  regulator_fixed_voltage_init+0x0/0x11 @ 1
initcall regulator_fixed_voltage_init+0x0/0x11 returned 0 after 0 usecs
calling  pm8607_regulator_init+0x0/0x11 @ 1
initcall pm8607_regulator_init+0x0/0x11 returned 0 after 0 usecs
calling  ad5398_init+0x0/0x11 @ 1
initcall ad5398_init+0x0/0x11 returned 0 after 0 usecs
calling  as3711_regulator_init+0x0/0x11 @ 1
initcall as3711_regulator_init+0x0/0x11 returned 0 after 0 usecs
calling  da903x_regulator_init+0x0/0x11 @ 1
initcall da903x_regulator_init+0x0/0x11 returned 0 after 0 usecs
calling  gpio_regulator_init+0x0/0x11 @ 1
initcall gpio_regulator_init+0x0/0x11 returned 0 after 0 usecs
calling  isl6271a_init+0x0/0x11 @ 1
initcall isl6271a_init+0x0/0x11 returned 0 after 0 usecs
calling  lp3972_module_init+0x0/0x11 @ 1
initcall lp3972_module_init+0x0/0x11 returned 0 after 0 usecs
calling  lp8755_init+0x0/0x11 @ 1
initcall lp8755_init+0x0/0x11 returned 0 after 0 usecs
calling  max1586_pmic_init+0x0/0x11 @ 1
initcall max1586_pmic_init+0x0/0x11 returned 0 after 0 usecs
calling  max8649_init+0x0/0x11 @ 1
initcall max8649_init+0x0/0x11 returned 0 after 0 usecs
calling  max8660_init+0x0/0x11 @ 1
initcall max8660_init+0x0/0x11 returned 0 after 0 usecs
calling  max8998_pmic_init+0x0/0x11 @ 1
initcall max8998_pmic_init+0x0/0x11 returned 0 after 0 usecs
calling  tps51632_init+0x0/0x11 @ 1
initcall tps51632_init+0x0/0x11 returned 0 after 0 usecs
calling  pcf50633_regulator_init+0x0/0x11 @ 1
initcall pcf50633_regulator_init+0x0/0x11 returned 0 after 0 usecs
calling  tps6105x_regulator_init+0x0/0x11 @ 1
initcall tps6105x_regulator_init+0x0/0x11 returned 0 after 0 usecs
calling  tps62360_init+0x0/0x11 @ 1
initcall tps62360_init+0x0/0x11 returned 0 after 0 usecs
calling  tps_65023_init+0x0/0x11 @ 1
initcall tps_65023_init+0x0/0x11 returned 0 after 0 usecs
calling  tps65090_regulator_init+0x0/0x11 @ 1
initcall tps65090_regulator_init+0x0/0x11 returned 0 after 0 usecs
calling  tps65217_regulator_init+0x0/0x11 @ 1
initcall tps65217_regulator_init+0x0/0x11 returned 0 after 0 usecs
calling  tps65910_init+0x0/0x11 @ 1
initcall tps65910_init+0x0/0x11 returned 0 after 0 usecs
calling  twlreg_init+0x0/0x11 @ 1
initcall twlreg_init+0x0/0x11 returned 0 after 0 usecs
calling  wm831x_dcdc_init+0x0/0x8a @ 1
initcall wm831x_dcdc_init+0x0/0x8a returned 0 after 0 usecs
calling  wm831x_isink_init+0x0/0x30 @ 1
initcall wm831x_isink_init+0x0/0x30 returned 0 after 0 usecs
calling  wm831x_ldo_init+0x0/0x6a @ 1
initcall wm831x_ldo_init+0x0/0x6a returned 0 after 0 usecs
calling  wm8350_regulator_init+0x0/0x11 @ 1
initcall wm8350_regulator_init+0x0/0x11 returned 0 after 0 usecs
calling  misc_init+0x0/0xad @ 1
initcall misc_init+0x0/0xad returned 0 after 0 usecs
calling  tifm_init+0x0/0x8c @ 1
initcall tifm_init+0x0/0x8c returned 0 after 0 usecs
calling  pm860x_i2c_init+0x0/0x30 @ 1
initcall pm860x_i2c_init+0x0/0x30 returned 0 after 0 usecs
calling  pm800_i2c_init+0x0/0x11 @ 1
initcall pm800_i2c_init+0x0/0x11 returned 0 after 0 usecs
calling  tc3589x_init+0x0/0x11 @ 1
initcall tc3589x_init+0x0/0x11 returned 0 after 0 usecs
calling  wm8400_module_init+0x0/0x30 @ 1
initcall wm8400_module_init+0x0/0x30 returned 0 after 0 usecs
calling  wm831x_i2c_init+0x0/0x30 @ 1
initcall wm831x_i2c_init+0x0/0x30 returned 0 after 0 usecs
calling  wm8350_i2c_init+0x0/0x11 @ 1
initcall wm8350_i2c_init+0x0/0x11 returned 0 after 0 usecs
calling  tps6105x_init+0x0/0x11 @ 1
initcall tps6105x_init+0x0/0x11 returned 0 after 0 usecs
calling  tps6507x_i2c_init+0x0/0x11 @ 1
initcall tps6507x_i2c_init+0x0/0x11 returned 0 after 0 usecs
calling  tps65217_init+0x0/0x11 @ 1
initcall tps65217_init+0x0/0x11 returned 0 after 0 usecs
calling  tps65910_i2c_init+0x0/0x11 @ 1
initcall tps65910_i2c_init+0x0/0x11 returned 0 after 0 usecs
calling  da903x_init+0x0/0x11 @ 1
initcall da903x_init+0x0/0x11 returned 0 after 0 usecs
calling  lp8788_init+0x0/0x11 @ 1
initcall lp8788_init+0x0/0x11 returned 0 after 0 usecs
calling  max77693_i2c_init+0x0/0x11 @ 1
initcall max77693_i2c_init+0x0/0x11 returned 0 after 0 usecs
calling  max8998_i2c_init+0x0/0x11 @ 1
initcall max8998_i2c_init+0x0/0x11 returned 0 after 0 usecs
calling  pcf50633_init+0x0/0x11 @ 1
initcall pcf50633_init+0x0/0x11 returned 0 after 0 usecs
calling  tps65090_init+0x0/0x11 @ 1
initcall tps65090_init+0x0/0x11 returned 0 after 0 usecs
calling  lm3533_i2c_init+0x0/0x11 @ 1
initcall lm3533_i2c_init+0x0/0x11 returned 0 after 0 usecs
calling  as3711_i2c_init+0x0/0x11 @ 1
initcall as3711_i2c_init+0x0/0x11 returned 0 after 0 usecs
calling  init_scsi+0x0/0x80 @ 1
SCSI subsystem initialized
initcall init_scsi+0x0/0x80 returned 0 after 976 usecs
calling  ata_init+0x0/0x2a1 @ 1
libata version 3.00 loaded.
initcall ata_init+0x0/0x2a1 returned 0 after 976 usecs
calling  phy_init+0x0/0x28 @ 1
initcall phy_init+0x0/0x28 returned 0 after 0 usecs
calling  init_pcmcia_cs+0x0/0x32 @ 1
initcall init_pcmcia_cs+0x0/0x32 returned 0 after 0 usecs
calling  usb_init+0x0/0x146 @ 1
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
initcall usb_init+0x0/0x146 returned 0 after 3906 usecs
calling  usb_phy_gen_xceiv_init+0x0/0x11 @ 1
initcall usb_phy_gen_xceiv_init+0x0/0x11 returned 0 after 0 usecs
calling  usb_udc_init+0x0/0x45 @ 1
initcall usb_udc_init+0x0/0x45 returned 0 after 0 usecs
calling  serio_init+0x0/0x2e @ 1
initcall serio_init+0x0/0x2e returned 0 after 0 usecs
calling  gameport_init+0x0/0x2e @ 1
initcall gameport_init+0x0/0x2e returned 0 after 0 usecs
calling  input_init+0x0/0xf9 @ 1
initcall input_init+0x0/0xf9 returned 0 after 0 usecs
calling  tca6416_keypad_init+0x0/0x11 @ 1
initcall tca6416_keypad_init+0x0/0x11 returned 0 after 0 usecs
calling  tca8418_keypad_init+0x0/0x11 @ 1
initcall tca8418_keypad_init+0x0/0x11 returned 0 after 0 usecs
calling  rtc_init+0x0/0x44 @ 1
initcall rtc_init+0x0/0x44 returned 0 after 0 usecs
calling  i2c_gpio_init+0x0/0x30 @ 1
initcall i2c_gpio_init+0x0/0x30 returned 0 after 0 usecs
calling  videodev_init+0x0/0x7f @ 1
Linux video capture interface: v2.00
initcall videodev_init+0x0/0x7f returned 0 after 976 usecs
calling  init_dvbdev+0x0/0xc2 @ 1
initcall init_dvbdev+0x0/0xc2 returned 0 after 0 usecs
calling  pps_init+0x0/0xa6 @ 1
pps_core: LinuxPPS API ver. 1 registered
pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giome=
tti@linux.it>
initcall pps_init+0x0/0xa6 returned 0 after 1953 usecs
calling  ptp_init+0x0/0x8c @ 1
PTP clock support registered
initcall ptp_init+0x0/0x8c returned 0 after 976 usecs
calling  power_supply_class_init+0x0/0x35 @ 1
initcall power_supply_class_init+0x0/0x35 returned 0 after 0 usecs
calling  hwmon_init+0x0/0xea @ 1
initcall hwmon_init+0x0/0xea returned 0 after 976 usecs
calling  mmc_init+0x0/0x80 @ 1
initcall mmc_init+0x0/0x80 returned 0 after 0 usecs
calling  leds_init+0x0/0x32 @ 1
initcall leds_init+0x0/0x32 returned 0 after 0 usecs
calling  iio_init+0x0/0x85 @ 1
initcall iio_init+0x0/0x85 returned 0 after 0 usecs
calling  pci_subsys_init+0x0/0x44 @ 1
PCI: Probing PCI hardware
PCI: root bus 00: using default resources
PCI: Probing PCI hardware (bus 00)
PCI host bridge to bus 0000:00
pci_bus 0000:00: root bus resource [io  0x0000-0xffff]
pci_bus 0000:00: root bus resource [mem 0x00000000-0xffffffff]
pci_bus 0000:00: No busn resource found for root bus, will use [bus 00-ff]
pci 0000:00:00.0: [10de:005e] type 00 class 0x058000
pci 0000:00:01.0: [10de:0050] type 00 class 0x060100
pci 0000:00:01.1: [10de:0052] type 00 class 0x0c0500
pci 0000:00:01.1: reg 0x10: [io  0xe400-0xe41f]
pci 0000:00:01.1: reg 0x20: [io  0x4c00-0x4c3f]
pci 0000:00:01.1: reg 0x24: [io  0x4c40-0x4c7f]
pci 0000:00:01.1: PME# supported from D3hot D3cold
pci 0000:00:02.0: [10de:005a] type 00 class 0x0c0310
pci 0000:00:02.0: reg 0x10: [mem 0xda004000-0xda004fff]
pci 0000:00:02.0: supports D1 D2
pci 0000:00:02.0: PME# supported from D0 D1 D2 D3hot D3cold
pci 0000:00:02.1: [10de:005b] type 00 class 0x0c0320
pci 0000:00:02.1: reg 0x10: [mem 0xfeb00000-0xfeb000ff]
pci 0000:00:02.1: supports D1 D2
pci 0000:00:02.1: PME# supported from D0 D1 D2 D3hot D3cold
pci 0000:00:04.0: [10de:0059] type 00 class 0x040100
pci 0000:00:04.0: reg 0x10: [io  0xdc00-0xdcff]
pci 0000:00:04.0: reg 0x14: [io  0xe000-0xe0ff]
pci 0000:00:04.0: reg 0x18: [mem 0xda003000-0xda003fff]
pci 0000:00:04.0: supports D1 D2
pci 0000:00:06.0: [10de:0053] type 00 class 0x01018a
pci 0000:00:06.0: reg 0x20: [io  0xf000-0xf00f]
pci 0000:00:07.0: [10de:0054] type 00 class 0x010185
pci 0000:00:07.0: reg 0x10: [io  0x09f0-0x09f7]
pci 0000:00:07.0: reg 0x14: [io  0x0bf0-0x0bf3]
pci 0000:00:07.0: reg 0x18: [io  0x0970-0x0977]
pci 0000:00:07.0: reg 0x1c: [io  0x0b70-0x0b73]
pci 0000:00:07.0: reg 0x20: [io  0xd800-0xd80f]
pci 0000:00:07.0: reg 0x24: [mem 0xda002000-0xda002fff]
pci 0000:00:08.0: [10de:0055] type 00 class 0x010185
pci 0000:00:08.0: reg 0x10: [io  0x09e0-0x09e7]
pci 0000:00:08.0: reg 0x14: [io  0x0be0-0x0be3]
pci 0000:00:08.0: reg 0x18: [io  0x0960-0x0967]
pci 0000:00:08.0: reg 0x1c: [io  0x0b60-0x0b63]
pci 0000:00:08.0: reg 0x20: [io  0xc400-0xc40f]
pci 0000:00:08.0: reg 0x24: [mem 0xda001000-0xda001fff]
pci 0000:00:09.0: [10de:005c] type 01 class 0x060401
pci 0000:00:0a.0: [10de:0057] type 00 class 0x068000
pci 0000:00:0a.0: reg 0x10: [mem 0xda000000-0xda000fff]
pci 0000:00:0a.0: reg 0x14: [io  0xb000-0xb007]
pci 0000:00:0a.0: supports D1 D2
pci 0000:00:0a.0: PME# supported from D0 D1 D2 D3hot D3cold
pci 0000:00:0b.0: [10de:005d] type 01 class 0x060400
pci 0000:00:0b.0: PME# supported from D0 D1 D2 D3hot D3cold
pci 0000:00:0c.0: [10de:005d] type 01 class 0x060400
pci 0000:00:0c.0: PME# supported from D0 D1 D2 D3hot D3cold
pci 0000:00:0d.0: [10de:005d] type 01 class 0x060400
pci 0000:00:0d.0: PME# supported from D0 D1 D2 D3hot D3cold
pci 0000:00:0e.0: [10de:005d] type 01 class 0x060400
pci 0000:00:0e.0: PME# supported from D0 D1 D2 D3hot D3cold
pci 0000:00:18.0: [1022:1100] type 00 class 0x060000
pci 0000:00:18.1: [1022:1101] type 00 class 0x060000
pci 0000:00:18.2: [1022:1102] type 00 class 0x060000
pci 0000:00:18.3: [1022:1103] type 00 class 0x060000
pci 0000:00:09.0: PCI bridge to [bus 05] (subtractive decode)
pci 0000:00:09.0:   bridge window [io  0x0000-0xffff] (subtractive decode)
pci 0000:00:09.0:   bridge window [mem 0x00000000-0xffffffff] (subtractive =
decode)
pci 0000:00:0b.0: PCI bridge to [bus 04]
pci 0000:00:0c.0: PCI bridge to [bus 03]
pci 0000:00:0d.0: PCI bridge to [bus 02]
pci 0000:01:00.0: [1002:5b60] type 00 class 0x030000
pci 0000:01:00.0: reg 0x10: [mem 0xd0000000-0xd7ffffff pref]
pci 0000:01:00.0: reg 0x14: [io  0xa000-0xa0ff]
pci 0000:01:00.0: reg 0x18: [mem 0xd9000000-0xd900ffff]
pci 0000:01:00.0: reg 0x30: [mem 0x00000000-0x0001ffff pref]
pci 0000:01:00.0: supports D1 D2
pci 0000:01:00.1: [1002:5b70] type 00 class 0x038000
pci 0000:01:00.1: reg 0x10: [mem 0xd9010000-0xd901ffff]
pci 0000:01:00.1: supports D1 D2
pci 0000:00:0e.0: PCI bridge to [bus 01]
pci 0000:00:0e.0:   bridge window [io  0xa000-0xafff]
pci 0000:00:0e.0:   bridge window [mem 0xd8000000-0xd9ffffff]
pci 0000:00:0e.0:   bridge window [mem 0xd0000000-0xd7ffffff 64bit pref]
pci_bus 0000:00: busn_res: [bus 00-ff] end is updated to 05
pci 0000:00:00.0: default IRQ router [10de:005e]
PCI: pci_cache_line_size set to 64 bytes
e820: reserve RAM buffer [mem 0x0009f800-0x0009ffff]
e820: reserve RAM buffer [mem 0x3fff0000-0x3fffffff]
initcall pci_subsys_init+0x0/0x44 returned 0 after 85937 usecs
calling  proto_init+0x0/0xf @ 1
initcall proto_init+0x0/0xf returned 0 after 0 usecs
calling  net_dev_init+0x0/0x197 @ 1
initcall net_dev_init+0x0/0x197 returned 0 after 0 usecs
calling  neigh_init+0x0/0xa4 @ 1
initcall neigh_init+0x0/0xa4 returned 0 after 0 usecs
calling  fib_rules_init+0x0/0xbd @ 1
initcall fib_rules_init+0x0/0xbd returned 0 after 0 usecs
calling  genl_init+0x0/0x76 @ 1
initcall genl_init+0x0/0x76 returned 0 after 0 usecs
calling  cipso_v4_init+0x0/0x76 @ 1
initcall cipso_v4_init+0x0/0x76 returned 0 after 0 usecs
calling  irda_init+0x0/0x88 @ 1
NET: Registered protocol family 23
initcall irda_init+0x0/0x88 returned 0 after 976 usecs
calling  bt_init+0x0/0x89 @ 1
Bluetooth: Core ver 2.16
NET: Registered protocol family 31
Bluetooth: HCI device and connection manager initialized
Bluetooth: HCI socket layer initialized
Bluetooth: L2CAP socket layer initialized
Bluetooth: SCO socket layer initialized
initcall bt_init+0x0/0x89 returned 0 after 5859 usecs
calling  atm_init+0x0/0xd0 @ 1
NET: Registered protocol family 8
NET: Registered protocol family 20
initcall atm_init+0x0/0xd0 returned 0 after 1953 usecs
calling  cfg80211_init+0x0/0xd7 @ 1
cfg80211: Calling CRDA to update world regulatory domain
initcall cfg80211_init+0x0/0xd7 returned 0 after 1953 usecs
calling  wireless_nlevent_init+0x0/0xf @ 1
initcall wireless_nlevent_init+0x0/0xf returned 0 after 0 usecs
calling  ieee80211_init+0x0/0xa @ 1
initcall ieee80211_init+0x0/0xa returned 0 after 0 usecs
calling  netlbl_init+0x0/0x7d @ 1
NetLabel: Initializing
NetLabel:  domain hash size =3D 128
NetLabel:  protocols =3D UNLABELED CIPSOv4
NetLabel:  unlabeled traffic allowed by default
initcall netlbl_init+0x0/0x7d returned 0 after 3906 usecs
calling  wpan_phy_class_init+0x0/0x33 @ 1
initcall wpan_phy_class_init+0x0/0x33 returned 0 after 0 usecs
calling  nfc_init+0x0/0x8f @ 1
nfc: nfc_init: NFC Core ver 0.1
NET: Registered protocol family 39
initcall nfc_init+0x0/0x8f returned 0 after 1953 usecs
calling  nfc_hci_init+0x0/0xa @ 1
initcall nfc_hci_init+0x0/0xa returned 0 after 0 usecs
calling  nmi_warning_debugfs+0x0/0x24 @ 1
initcall nmi_warning_debugfs+0x0/0x24 returned 0 after 0 usecs
calling  clocksource_done_booting+0x0/0x3b @ 1
Switched to clocksource pit
initcall clocksource_done_booting+0x0/0x3b returned 0 after 1025 usecs
calling  tracer_init_debugfs+0x0/0x158 @ 1
initcall tracer_init_debugfs+0x0/0x158 returned 0 after 608 usecs
calling  init_trace_printk_function_export+0x0/0x33 @ 1
initcall init_trace_printk_function_export+0x0/0x33 returned 0 after 14 use=
cs
calling  event_trace_init+0x0/0x1bb @ 1
initcall event_trace_init+0x0/0x1bb returned 0 after 98030 usecs
calling  init_uprobe_trace+0x0/0x59 @ 1
initcall init_uprobe_trace+0x0/0x59 returned 0 after 28 usecs
calling  init_pipe_fs+0x0/0x3d @ 1
initcall init_pipe_fs+0x0/0x3d returned 0 after 103 usecs
calling  eventpoll_init+0x0/0x10d @ 1
initcall eventpoll_init+0x0/0x10d returned 0 after 42 usecs
calling  anon_inode_init+0x0/0x52 @ 1
initcall anon_inode_init+0x0/0x52 returned 0 after 62 usecs
calling  fscache_init+0x0/0x193 @ 1
FS-Cache: Loaded
initcall fscache_init+0x0/0x193 returned 0 after 1112 usecs
calling  cachefiles_init+0x0/0x99 @ 1
CacheFiles: Loaded
initcall cachefiles_init+0x0/0x99 returned 0 after 1510 usecs
calling  tomoyo_initerface_init+0x0/0x17c @ 1
initcall tomoyo_initerface_init+0x0/0x17c returned 0 after 200 usecs
calling  aa_create_aafs+0x0/0xa7 @ 1
initcall aa_create_aafs+0x0/0xa7 returned 0 after 4 usecs
calling  blk_scsi_ioctl_init+0x0/0x288 @ 1
initcall blk_scsi_ioctl_init+0x0/0x288 returned 0 after 4 usecs
calling  dynamic_debug_init_debugfs+0x0/0x6a @ 1
initcall dynamic_debug_init_debugfs+0x0/0x6a returned 0 after 26 usecs
calling  pnp_system_init+0x0/0xf @ 1
initcall pnp_system_init+0x0/0xf returned 0 after 39 usecs
calling  pnpbios_init+0x0/0x337 @ 1
PnPBIOS: Scanning system for PnP BIOS support...
PnPBIOS: Found PnP BIOS installation structure at 0xb00fc550
PnPBIOS: PnP BIOS version 1.0, entry 0xf0000:0xc580, dseg 0xf0000
pnp 00:00: [irq 2]
pnp 00:00: [io  0x0020-0x0021]
pnp 00:00: [io  0x00a0-0x00a1]
pnp 00:00: Plug and Play BIOS device, IDs PNP0000 (active)
pnp 00:01: [dma 4]
pnp 00:01: [io  0x0000-0x000f]
pnp 00:01: [io  0x0081-0x0083]
pnp 00:01: [io  0x0087]
pnp 00:01: [io  0x0089-0x008b]
pnp 00:01: [io  0x008f-0x0091]
pnp 00:01: [io  0x00c0-0x00df]
pnp 00:01: Plug and Play BIOS device, IDs PNP0200 (active)
pnp 00:02: [irq 0]
pnp 00:02: [io  0x0040-0x0043]
pnp 00:02: Plug and Play BIOS device, IDs PNP0100 (active)
pnp 00:03: [irq 8]
pnp 00:03: [io  0x0070-0x0071]
pnp 00:03: Plug and Play BIOS device, IDs PNP0b00 (active)
pnp 00:04: [irq 1]
pnp 00:04: [io  0x0060]
pnp 00:04: [io  0x0064]
pnp 00:04: Plug and Play BIOS device, IDs PNP0303 (active)
pnp 00:05: [io  0x0061]
pnp 00:05: Plug and Play BIOS device, IDs PNP0800 (active)
pnp 00:06: [irq 13]
pnp 00:06: [io  0x00f0-0x00ff]
pnp 00:06: Plug and Play BIOS device, IDs PNP0c04 (active)
pnp 00:07: [mem 0x00000000-0x0009ffff]
pnp 00:07: [mem 0xfffe0000-0xffffffff]
pnp 00:07: [mem 0xfec00000-0xfec0ffff]
pnp 00:07: [mem 0xfee00000-0xfeefffff]
pnp 00:07: [mem 0xfefffc00-0xfeffffff]
pnp 00:07: [mem 0x00100000-0x00ffffff]
system 00:07: [mem 0x00000000-0x0009ffff] could not be reserved
system 00:07: [mem 0xfffe0000-0xffffffff] has been reserved
system 00:07: [mem 0xfec00000-0xfec0ffff] has been reserved
system 00:07: [mem 0xfee00000-0xfeefffff] has been reserved
system 00:07: [mem 0xfefffc00-0xfeffffff] has been reserved
system 00:07: [mem 0x00100000-0x00ffffff] could not be reserved
system 00:07: Plug and Play BIOS device, IDs PNP0c01 (active)
pnp 00:08: [mem 0x000f0000-0x000f3fff]
pnp 00:08: [mem 0x000f4000-0x000f7fff]
pnp 00:08: [mem 0x000f8000-0x000fbfff]
pnp 00:08: [mem 0x000fc000-0x000fffff]
system 00:08: [mem 0x000f0000-0x000f3fff] could not be reserved
system 00:08: [mem 0x000f4000-0x000f7fff] could not be reserved
system 00:08: [mem 0x000f8000-0x000fbfff] could not be reserved
system 00:08: [mem 0x000fc000-0x000fffff] could not be reserved
system 00:08: Plug and Play BIOS device, IDs PNP0c02 (active)
pnp 00:09: [io  0x0290-0x029f]
pnp 00:09: [io  0x04d0-0x04d1]
pnp 00:09: [io  0x0cf8-0x0cff]
pnp 00:09: Plug and Play BIOS device, IDs PNP0a03 (active)
pnp 00:0b: [irq 4]
pnp 00:0b: [io  0x03f8-0x03ff]
pnp 00:0b: Plug and Play BIOS device, IDs PNP0501 (active)
pnp 00:0c: [dma 2]
pnp 00:0c: [io  0x03f0-0x03f5]
pnp 00:0c: [io  0x03f7]
pnp 00:0c: [irq 6]
pnp 00:0c: Plug and Play BIOS device, IDs PNP0700 (active)
pnp 00:0e: [dma 3]
pnp 00:0e: [irq 7]
pnp 00:0e: [io  0x0378-0x037f]
pnp 00:0e: [io  0x0778-0x077f]
pnp 00:0e: Plug and Play BIOS device, IDs PNP0401 (active)
pnp 00:0f: [irq 10]
pnp 00:0f: [io  0x0330-0x0333]
pnp 00:0f: Plug and Play BIOS device, IDs PNPb006 (active)
pnp 00:10: [io  0x0201]
pnp 00:10: Plug and Play BIOS device, IDs PNPb02f (active)
PnPBIOS: 15 nodes reported by PnP BIOS; 15 recorded by driver
initcall pnpbios_init+0x0/0x337 returned 0 after 76635 usecs
calling  chr_dev_init+0x0/0xc3 @ 1
initcall chr_dev_init+0x0/0xc3 returned 0 after 5687 usecs
calling  firmware_class_init+0x0/0x109 @ 1
initcall firmware_class_init+0x0/0x109 returned 0 after 29 usecs
calling  init_pcmcia_bus+0x0/0x5e @ 1
initcall init_pcmcia_bus+0x0/0x5e returned 0 after 55 usecs
calling  thermal_init+0x0/0xb5 @ 1
initcall thermal_init+0x0/0xb5 returned 0 after 85 usecs
calling  ssb_modinit+0x0/0x3f @ 1
initcall ssb_modinit+0x0/0x3f returned 0 after 39 usecs
calling  pcibios_assign_resources+0x0/0x8f @ 1
pci 0000:00:09.0: PCI bridge to [bus 05]
pci 0000:00:0b.0: PCI bridge to [bus 04]
pci 0000:00:0c.0: PCI bridge to [bus 03]
pci 0000:00:0d.0: PCI bridge to [bus 02]
pci 0000:01:00.0: BAR 6: assigned [mem 0xd8000000-0xd801ffff pref]
pci 0000:00:0e.0: PCI bridge to [bus 01]
pci 0000:00:0e.0:   bridge window [io  0xa000-0xafff]
pci 0000:00:0e.0:   bridge window [mem 0xd8000000-0xd9ffffff]
pci 0000:00:0e.0:   bridge window [mem 0xd0000000-0xd7ffffff 64bit pref]
pci_bus 0000:00: resource 4 [io  0x0000-0xffff]
pci_bus 0000:00: resource 5 [mem 0x00000000-0xffffffff]
pci_bus 0000:05: resource 4 [io  0x0000-0xffff]
pci_bus 0000:05: resource 5 [mem 0x00000000-0xffffffff]
pci_bus 0000:01: resource 0 [io  0xa000-0xafff]
pci_bus 0000:01: resource 1 [mem 0xd8000000-0xd9ffffff]
pci_bus 0000:01: resource 2 [mem 0xd0000000-0xd7ffffff 64bit pref]
initcall pcibios_assign_resources+0x0/0x8f returned 0 after 16287 usecs
calling  sysctl_core_init+0x0/0x23 @ 1
initcall sysctl_core_init+0x0/0x23 returned 0 after 36 usecs
calling  inet_init+0x0/0x26f @ 1
NET: Registered protocol family 2
TCP established hash table entries: 8192 (order: 4, 65536 bytes)
TCP bind hash table entries: 8192 (order: 6, 294912 bytes)
TCP: Hash tables configured (established 8192 bind 8192)
TCP: reno registered
UDP hash table entries: 512 (order: 3, 40960 bytes)
UDP-Lite hash table entries: 512 (order: 3, 40960 bytes)
initcall inet_init+0x0/0x26f returned 0 after 8885 usecs
calling  ipv4_offload_init+0x0/0x4e @ 1
initcall ipv4_offload_init+0x0/0x4e returned 0 after 11 usecs
calling  af_unix_init+0x0/0x4d @ 1
NET: Registered protocol family 1
initcall af_unix_init+0x0/0x4d returned 0 after 1086 usecs
calling  ipv6_offload_init+0x0/0x6b @ 1
initcall ipv6_offload_init+0x0/0x6b returned 0 after 4 usecs
calling  init_sunrpc+0x0/0x64 @ 1
RPC: Registered named UNIX socket transport module.
RPC: Registered udp transport module.
RPC: Registered tcp transport module.
RPC: Registered tcp NFSv4.1 backchannel transport module.
initcall init_sunrpc+0x0/0x64 returned 0 after 4243 usecs
calling  pci_apply_final_quirks+0x0/0x10f @ 1
pci 0000:00:00.0: Found enabled HT MSI Mapping
pci 0000:00:0b.0: Found disabled HT MSI Mapping
pci 0000:00:00.0: Found enabled HT MSI Mapping
pci 0000:00:0c.0: Found disabled HT MSI Mapping
pci 0000:00:00.0: Found enabled HT MSI Mapping
pci 0000:00:0d.0: Found disabled HT MSI Mapping
pci 0000:00:00.0: Found enabled HT MSI Mapping
pci 0000:00:0e.0: Found disabled HT MSI Mapping
pci 0000:00:00.0: Found enabled HT MSI Mapping
pci 0000:01:00.0: Boot video device
PCI: CLS 32 bytes, default 64
initcall pci_apply_final_quirks+0x0/0x10f returned 0 after 74263 usecs
calling  populate_rootfs+0x0/0x93 @ 1
initcall populate_rootfs+0x0/0x93 returned 0 after 307 usecs
calling  pci_iommu_init+0x0/0x34 @ 1
initcall pci_iommu_init+0x0/0x34 returned 0 after 4 usecs
calling  i8259A_init_ops+0x0/0x20 @ 1
initcall i8259A_init_ops+0x0/0x20 returned 0 after 4 usecs
calling  sbf_init+0x0/0xc9 @ 1
initcall sbf_init+0x0/0xc9 returned 0 after 4 usecs
calling  init_tsc_clocksource+0x0/0xac @ 1
initcall init_tsc_clocksource+0x0/0xac returned 0 after 24 usecs
calling  add_rtc_cmos+0x0/0x84 @ 1
initcall add_rtc_cmos+0x0/0x84 returned 0 after 5 usecs
calling  i8237A_init_ops+0x0/0x11 @ 1
initcall i8237A_init_ops+0x0/0x11 returned 0 after 4 usecs
calling  cache_sysfs_init+0x0/0x1c4 @ 1
initcall cache_sysfs_init+0x0/0x1c4 returned 0 after 4 usecs
calling  thermal_throttle_init_device+0x0/0xb8 @ 1
initcall thermal_throttle_init_device+0x0/0xb8 returned 0 after 4 usecs
calling  amd_ibs_init+0x0/0x1ce @ 1
initcall amd_ibs_init+0x0/0x1ce returned -19 after 4 usecs
calling  cpuid_init+0x0/0xe7 @ 1
initcall cpuid_init+0x0/0xe7 returned 0 after 188 usecs
calling  ioapic_init_ops+0x0/0x11 @ 1
initcall ioapic_init_ops+0x0/0x11 returned 0 after 4 usecs
calling  add_pcspkr+0x0/0x3c @ 1
initcall add_pcspkr+0x0/0x3c returned 0 after 67 usecs
calling  start_periodic_check_for_corruption+0x0/0x54 @ 1
Scanning for low memory corruption every 60 seconds
initcall start_periodic_check_for_corruption+0x0/0x54 returned 0 after 1177=
 usecs
calling  add_bus_probe+0x0/0x21 @ 1
initcall add_bus_probe+0x0/0x21 returned 0 after 4 usecs
calling  sysfb_init+0x0/0x80 @ 1
initcall sysfb_init+0x0/0x80 returned 0 after 57 usecs
calling  start_pageattr_test+0x0/0x4b @ 1
initcall start_pageattr_test+0x0/0x4b returned 0 after 104 usecs
calling  pt_dump_init+0x0/0x6d @ 1
initcall pt_dump_init+0x0/0x6d returned 0 after 19 usecs
calling  aes_init+0x0/0xf @ 1
initcall aes_init+0x0/0xf returned 0 after 196 usecs
calling  init+0x0/0xf @ 1
initcall init+0x0/0xf returned 0 after 178 usecs
calling  init+0x0/0xf @ 1
initcall init+0x0/0xf returned 0 after 55 usecs
calling  aesni_init+0x0/0x32 @ 1
initcall aesni_init+0x0/0x32 returned -19 after 4 usecs
calling  crc32c_intel_mod_init+0x0/0x24 @ 1
initcall crc32c_intel_mod_init+0x0/0x24 returned -19 after 4 usecs
calling  crc32_pclmul_mod_init+0x0/0x31 @ 1
PCLMULQDQ-NI instructions are not detected.
initcall crc32_pclmul_mod_init+0x0/0x31 returned -19 after 798 usecs
calling  net5501_init+0x0/0x104 @ 1
initcall net5501_init+0x0/0x104 returned 0 after 4 usecs
calling  goldfish_init+0x0/0x3f @ 1
initcall goldfish_init+0x0/0x3f returned 0 after 65 usecs
calling  iris_init+0x0/0xb1 @ 1
The force parameter has not been set to 1. The Iris poweroff handler will n=
ot be installed.
initcall iris_init+0x0/0xb1 returned -19 after 1113 usecs
calling  olpc_create_platform_devices+0x0/0x1c @ 1
initcall olpc_create_platform_devices+0x0/0x1c returned 0 after 4 usecs
calling  scx200_init+0x0/0x23 @ 1
NatSemi SCx200 Driver
initcall scx200_init+0x0/0x23 returned 0 after 1028 usecs
calling  proc_execdomains_init+0x0/0x27 @ 1
initcall proc_execdomains_init+0x0/0x27 returned 0 after 14 usecs
calling  ioresources_init+0x0/0x44 @ 1
initcall ioresources_init+0x0/0x44 returned 0 after 19 usecs
calling  uid_cache_init+0x0/0x81 @ 1
initcall uid_cache_init+0x0/0x81 returned 0 after 27 usecs
calling  init_posix_timers+0x0/0x1dd @ 1
initcall init_posix_timers+0x0/0x1dd returned 0 after 16 usecs
calling  init_posix_cpu_timers+0x0/0x9b @ 1
initcall init_posix_cpu_timers+0x0/0x9b returned 0 after 4 usecs
calling  init_sched_debug_procfs+0x0/0x30 @ 1
initcall init_sched_debug_procfs+0x0/0x30 returned 0 after 12 usecs
calling  irq_gc_init_ops+0x0/0x11 @ 1
initcall irq_gc_init_ops+0x0/0x11 returned 0 after 4 usecs
calling  irq_debugfs_init+0x0/0x30 @ 1
initcall irq_debugfs_init+0x0/0x30 returned 0 after 16 usecs
calling  irq_pm_init_ops+0x0/0x11 @ 1
initcall irq_pm_init_ops+0x0/0x11 returned 0 after 17 usecs
calling  timekeeping_init_ops+0x0/0x11 @ 1
initcall timekeeping_init_ops+0x0/0x11 returned 0 after 4 usecs
calling  init_clocksource_sysfs+0x0/0x58 @ 1
initcall init_clocksource_sysfs+0x0/0x58 returned 0 after 108 usecs
calling  init_timer_list_procfs+0x0/0x30 @ 1
initcall init_timer_list_procfs+0x0/0x30 returned 0 after 12 usecs
calling  alarmtimer_init+0x0/0x168 @ 1
initcall alarmtimer_init+0x0/0x168 returned 0 after 109 usecs
calling  clockevents_init_sysfs+0x0/0x7a @ 1
initcall clockevents_init_sysfs+0x0/0x7a returned 0 after 150 usecs
calling  lockdep_proc_init+0x0/0x4a @ 1
initcall lockdep_proc_init+0x0/0x4a returned 0 after 19 usecs
calling  futex_init+0x0/0x61 @ 1
initcall futex_init+0x0/0x61 returned 0 after 17 usecs
calling  init_rttest+0x0/0x139 @ 1
Initializing RT-Tester: OK
initcall init_rttest+0x0/0x139 returned 0 after 1478 usecs
calling  proc_dma_init+0x0/0x27 @ 1
initcall proc_dma_init+0x0/0x27 returned 0 after 12 usecs
calling  kallsyms_init+0x0/0x2a @ 1
initcall kallsyms_init+0x0/0x2a returned 0 after 18 usecs
calling  backtrace_regression_test+0x0/0xdb @ 1
=3D=3D=3D=3D[ backtrace testing ]=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Testing a backtrace from process context.
The following trace is a kernel self test and not a bug!
CPU: 0 PID: 1 Comm: swapper Tainted: G        W    3.12.0-rc4-01668-gfd71a0=
4-dirty #229484
 b1069b79 b1069b79 b010debc b010debc b235a604 b235a604 b010def8 b010def8 b1=
069ba8 b1069ba8 b2871e98 b2871e98 00000282 00000282 00d17a94 00d17a94

 00000976 00000976 b2c82480 b2c82480 000006aa 000006aa b010def8 b010def8 b1=
05c5f4 b105c5f4 00000001 00000001 00000000 00000000 00000000 00000000

 b1069b79 b1069b79 000006aa 000006aa b010df78 b010df78 b2d05af4 b2d05af4 b2=
cc09a0 b2cc09a0 b2864daa b2864daa b1069b79 b1069b79 00000001 00000001

Call Trace:
 [<b1069b79>] ? backtrace_test_irq_callback+0x14/0x14
 [<b235a604>] dump_stack+0x16/0x18
 [<b1069ba8>] backtrace_regression_test+0x2f/0xdb
 [<b105c5f4>] ? ktime_get+0x58/0xc6
 [<b1069b79>] ? backtrace_test_irq_callback+0x14/0x14
 [<b2d05af4>] do_one_initcall+0x72/0x14e
 [<b1069b79>] ? backtrace_test_irq_callback+0x14/0x14
 [<b103eedc>] ? parse_args+0x243/0x384
 [<b1038bed>] ? __usermodehelper_set_disable_depth+0x3c/0x42
 [<b2d05ca6>] kernel_init_freeable+0xd6/0x178
 [<b2d05475>] ? loglevel+0x2b/0x2b
 [<b2350e9e>] kernel_init+0xb/0xc3
 [<b23735d7>] ret_from_kernel_thread+0x1b/0x28
 [<b2350e93>] ? rest_init+0xb7/0xb7
Testing a backtrace from irq context.
The following trace is a kernel self test and not a bug!
CPU: 0 PID: 3 Comm: ksoftirqd/0 Tainted: G        W    3.12.0-rc4-01668-gfd=
71a04-dirty #229484
 00000006 00000006 b012feb8 b012feb8 b235a604 b235a604 b012fec0 b012fec0 b1=
069b6d b1069b6d b012fecc b012fecc b102be74 b102be74 00000040 00000040

 b012ff0c b012ff0c b102ba58 b102ba58 b012fedc b012fedc 00000046 00000046 b1=
049660 b1049660 b012ff58 b012ff58 00000286 00000286 b012ff48 b012ff48

 04208040 04208040 fffb712d fffb712d 0000000a 0000000a 00000100 00000100 00=
000001 00000001 b0055a20 b0055a20 b2b5db40 b2b5db40 b01137a0 b01137a0

Call Trace:
 [<b235a604>] dump_stack+0x16/0x18
 [<b1069b6d>] backtrace_test_irq_callback+0x8/0x14
 [<b102be74>] tasklet_action+0x65/0x6a
 [<b102ba58>] __do_softirq+0xa9/0x1e8
 [<b1049660>] ? complete+0x42/0x4a
 [<b102bbae>] run_ksoftirqd+0x17/0x3a
 [<b1046629>] smpboot_thread_fn+0x101/0x117
 [<b1046528>] ? lg_global_unlock+0x29/0x29
 [<b1040519>] kthread+0x8e/0x9a
 [<b23735d7>] ret_from_kernel_thread+0x1b/0x28
 [<b104048b>] ? __kthread_unpark+0x29/0x29
Testing a saved backtrace.
The following trace is a kernel self test and not a bug!
  [<b100a677>] save_stack_trace+0x2a/0x44
[<b100a677>] save_stack_trace+0x2a/0x44
  [<b1069c37>] backtrace_regression_test+0xbe/0xdb
[<b1069c37>] backtrace_regression_test+0xbe/0xdb
  [<b2d05af4>] do_one_initcall+0x72/0x14e
[<b2d05af4>] do_one_initcall+0x72/0x14e
  [<b2d05ca6>] kernel_init_freeable+0xd6/0x178
[<b2d05ca6>] kernel_init_freeable+0xd6/0x178
  [<b2350e9e>] kernel_init+0xb/0xc3
[<b2350e9e>] kernel_init+0xb/0xc3
  [<b23735d7>] ret_from_kernel_thread+0x1b/0x28
[<b23735d7>] ret_from_kernel_thread+0x1b/0x28
  [<ffffffff>] 0xffffffff
[<ffffffff>] 0xffffffff
=3D=3D=3D=3D[ end of backtrace testing ]=3D=3D=3D=3D
initcall backtrace_regression_test+0x0/0xdb returned 0 after 95106 usecs
calling  audit_init+0x0/0x14c @ 1
audit: initializing netlink socket (disabled)
type=3D2000 audit(1381004849.342:1): initialized
initcall audit_init+0x0/0x14c returned 0 after 2452 usecs
calling  audit_watch_init+0x0/0x31 @ 1
initcall audit_watch_init+0x0/0x31 returned 0 after 13 usecs
calling  audit_tree_init+0x0/0x42 @ 1
initcall audit_tree_init+0x0/0x42 returned 0 after 10 usecs
calling  hung_task_init+0x0/0x56 @ 1
initcall hung_task_init+0x0/0x56 returned 0 after 44 usecs
calling  utsname_sysctl_init+0x0/0x11 @ 1
initcall utsname_sysctl_init+0x0/0x11 returned 0 after 19 usecs
calling  init_mmio_trace+0x0/0xf @ 1
initcall init_mmio_trace+0x0/0xf returned 0 after 5 usecs
calling  init_blk_tracer+0x0/0x54 @ 1
initcall init_blk_tracer+0x0/0x54 returned 0 after 6 usecs
calling  perf_event_sysfs_init+0x0/0x91 @ 1
initcall perf_event_sysfs_init+0x0/0x91 returned 0 after 184 usecs
calling  init_uprobes+0x0/0x4f @ 1
initcall init_uprobes+0x0/0x4f returned 0 after 18 usecs
calling  init_per_zone_wmark_min+0x0/0x9a @ 1
initcall init_per_zone_wmark_min+0x0/0x9a returned 0 after 68 usecs
calling  kswapd_init+0x0/0x13 @ 1
initcall kswapd_init+0x0/0x13 returned 0 after 46 usecs
calling  extfrag_debug_init+0x0/0x7d @ 1
initcall extfrag_debug_init+0x0/0x7d returned 0 after 40 usecs
calling  setup_vmstat+0x0/0x8a @ 1
initcall setup_vmstat+0x0/0x8a returned 0 after 35 usecs
calling  mm_sysfs_init+0x0/0x22 @ 1
initcall mm_sysfs_init+0x0/0x22 returned 0 after 8 usecs
calling  slab_proc_init+0x0/0x2a @ 1
initcall slab_proc_init+0x0/0x2a returned 0 after 11 usecs
calling  init_reserve_notifier+0x0/0x7 @ 1
initcall init_reserve_notifier+0x0/0x7 returned 0 after 4 usecs
calling  init_admin_reserve+0x0/0x25 @ 1
initcall init_admin_reserve+0x0/0x25 returned 0 after 4 usecs
calling  init_user_reserve+0x0/0x25 @ 1
initcall init_user_reserve+0x0/0x25 returned 0 after 4 usecs
calling  proc_vmalloc_init+0x0/0x2a @ 1
initcall proc_vmalloc_init+0x0/0x2a returned 0 after 12 usecs
calling  ksm_init+0x0/0x15b @ 1
initcall ksm_init+0x0/0x15b returned 0 after 114 usecs
calling  slab_proc_init+0x0/0x7 @ 1
initcall slab_proc_init+0x0/0x7 returned 0 after 3 usecs
calling  cpucache_init+0x0/0xcc @ 1
initcall cpucache_init+0x0/0xcc returned 0 after 4 usecs
calling  hugepage_init+0x0/0x125 @ 1
initcall hugepage_init+0x0/0x125 returned 0 after 146 usecs
calling  pfn_inject_init+0x0/0x131 @ 1
initcall pfn_inject_init+0x0/0x131 returned 0 after 95 usecs
calling  fcntl_init+0x0/0x2f @ 1
initcall fcntl_init+0x0/0x2f returned 0 after 15 usecs
calling  proc_filesystems_init+0x0/0x27 @ 1
initcall proc_filesystems_init+0x0/0x27 returned 0 after 12 usecs
calling  dio_init+0x0/0x32 @ 1
initcall dio_init+0x0/0x32 returned 0 after 14 usecs
calling  fsnotify_mark_init+0x0/0x46 @ 1
initcall fsnotify_mark_init+0x0/0x46 returned 0 after 253 usecs
calling  inotify_user_setup+0x0/0x78 @ 1
initcall inotify_user_setup+0x0/0x78 returned 0 after 25 usecs
calling  fanotify_user_setup+0x0/0x5a @ 1
initcall fanotify_user_setup+0x0/0x5a returned 0 after 24 usecs
calling  aio_setup+0x0/0x8a @ 1
initcall aio_setup+0x0/0x8a returned 0 after 30 usecs
calling  proc_locks_init+0x0/0x27 @ 1
initcall proc_locks_init+0x0/0x27 returned 0 after 12 usecs
calling  init_mbcache+0x0/0x11 @ 1
initcall init_mbcache+0x0/0x11 returned 0 after 4 usecs
calling  dquot_init+0x0/0xfb @ 1
VFS: Disk quotas dquot_6.5.2
Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
initcall dquot_init+0x0/0xfb returned 0 after 1600 usecs
calling  init_v1_quota_format+0x0/0xf @ 1
initcall init_v1_quota_format+0x0/0xf returned 0 after 12 usecs
calling  init_v2_quota_format+0x0/0x1d @ 1
initcall init_v2_quota_format+0x0/0x1d returned 0 after 4 usecs
calling  proc_cmdline_init+0x0/0x27 @ 1
initcall proc_cmdline_init+0x0/0x27 returned 0 after 12 usecs
calling  proc_consoles_init+0x0/0x27 @ 1
initcall proc_consoles_init+0x0/0x27 returned 0 after 11 usecs
calling  proc_cpuinfo_init+0x0/0x27 @ 1
initcall proc_cpuinfo_init+0x0/0x27 returned 0 after 12 usecs
calling  proc_devices_init+0x0/0x27 @ 1
initcall proc_devices_init+0x0/0x27 returned 0 after 13 usecs
calling  proc_interrupts_init+0x0/0x27 @ 1
initcall proc_interrupts_init+0x0/0x27 returned 0 after 11 usecs
calling  proc_loadavg_init+0x0/0x27 @ 1
initcall proc_loadavg_init+0x0/0x27 returned 0 after 12 usecs
calling  proc_meminfo_init+0x0/0x27 @ 1
initcall proc_meminfo_init+0x0/0x27 returned 0 after 11 usecs
calling  proc_stat_init+0x0/0x27 @ 1
initcall proc_stat_init+0x0/0x27 returned 0 after 12 usecs
calling  proc_uptime_init+0x0/0x27 @ 1
initcall proc_uptime_init+0x0/0x27 returned 0 after 11 usecs
calling  proc_version_init+0x0/0x27 @ 1
initcall proc_version_init+0x0/0x27 returned 0 after 11 usecs
calling  proc_softirqs_init+0x0/0x27 @ 1
initcall proc_softirqs_init+0x0/0x27 returned 0 after 11 usecs
calling  proc_kcore_init+0x0/0x7e @ 1
initcall proc_kcore_init+0x0/0x7e returned 0 after 20 usecs
calling  proc_kmsg_init+0x0/0x2a @ 1
initcall proc_kmsg_init+0x0/0x2a returned 0 after 12 usecs
calling  proc_page_init+0x0/0x4a @ 1
initcall proc_page_init+0x0/0x4a returned 0 after 19 usecs
calling  configfs_init+0x0/0xa8 @ 1
initcall configfs_init+0x0/0xa8 returned 0 after 23 usecs
calling  init_devpts_fs+0x0/0x52 @ 1
initcall init_devpts_fs+0x0/0x52 returned 0 after 82 usecs
calling  init_reiserfs_fs+0x0/0x70 @ 1
initcall init_reiserfs_fs+0x0/0x70 returned 0 after 27 usecs
calling  init_ext3_fs+0x0/0x76 @ 1
initcall init_ext3_fs+0x0/0x76 returned 0 after 48 usecs
calling  init_ext2_fs+0x0/0x76 @ 1
initcall init_ext2_fs+0x0/0x76 returned 0 after 38 usecs
calling  ext4_init_fs+0x0/0x1e6 @ 1
initcall ext4_init_fs+0x0/0x1e6 returned 0 after 161 usecs
calling  journal_init+0x0/0xeb @ 1
initcall journal_init+0x0/0xeb returned 0 after 67 usecs
calling  journal_init+0x0/0x120 @ 1
initcall journal_init+0x0/0x120 returned 0 after 87 usecs
calling  init_ramfs_fs+0x0/0x45 @ 1
initcall init_ramfs_fs+0x0/0x45 returned 0 after 4 usecs
calling  init_fat_fs+0x0/0x4c @ 1
initcall init_fat_fs+0x0/0x4c returned 0 after 26 usecs
calling  init_vfat_fs+0x0/0xf @ 1
initcall init_vfat_fs+0x0/0xf returned 0 after 4 usecs
calling  init_msdos_fs+0x0/0xf @ 1
initcall init_msdos_fs+0x0/0xf returned 0 after 4 usecs
calling  init_iso9660_fs+0x0/0x66 @ 1
initcall init_iso9660_fs+0x0/0x66 returned 0 after 16 usecs
calling  init_nfs_fs+0x0/0x159 @ 1
initcall init_nfs_fs+0x0/0x159 returned 0 after 432 usecs
calling  init_nfs_v2+0x0/0x11 @ 1
initcall init_nfs_v2+0x0/0x11 returned 0 after 13 usecs
calling  init_nfs_v4+0x0/0x40 @ 1
NFS: Registering the id_resolver key type
Key type id_resolver registered
Key type id_legacy registered
initcall init_nfs_v4+0x0/0x40 returned 0 after 3527 usecs
calling  init_nfsd+0x0/0x113 @ 1
Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
initcall init_nfsd+0x0/0x113 returned 0 after 1421 usecs
calling  init_nlm+0x0/0x3d @ 1
initcall init_nlm+0x0/0x3d returned 0 after 30 usecs
calling  init_nls_cp437+0x0/0xf @ 1
initcall init_nls_cp437+0x0/0xf returned 0 after 13 usecs
calling  init_nls_cp737+0x0/0xf @ 1
initcall init_nls_cp737+0x0/0xf returned 0 after 4 usecs
calling  init_nls_cp775+0x0/0xf @ 1
initcall init_nls_cp775+0x0/0xf returned 0 after 4 usecs
calling  init_nls_cp850+0x0/0xf @ 1
initcall init_nls_cp850+0x0/0xf returned 0 after 4 usecs
calling  init_nls_cp852+0x0/0xf @ 1
initcall init_nls_cp852+0x0/0xf returned 0 after 4 usecs
calling  init_nls_cp855+0x0/0xf @ 1
initcall init_nls_cp855+0x0/0xf returned 0 after 4 usecs
calling  init_nls_cp857+0x0/0xf @ 1
initcall init_nls_cp857+0x0/0xf returned 0 after 4 usecs
calling  init_nls_cp863+0x0/0xf @ 1
initcall init_nls_cp863+0x0/0xf returned 0 after 4 usecs
calling  init_nls_cp865+0x0/0xf @ 1
initcall init_nls_cp865+0x0/0xf returned 0 after 4 usecs
calling  init_nls_cp866+0x0/0xf @ 1
initcall init_nls_cp866+0x0/0xf returned 0 after 4 usecs
calling  init_nls_cp869+0x0/0xf @ 1
initcall init_nls_cp869+0x0/0xf returned 0 after 4 usecs
calling  init_nls_cp936+0x0/0xf @ 1
initcall init_nls_cp936+0x0/0xf returned 0 after 4 usecs
calling  init_nls_cp949+0x0/0xf @ 1
initcall init_nls_cp949+0x0/0xf returned 0 after 4 usecs
calling  init_nls_cp950+0x0/0xf @ 1
initcall init_nls_cp950+0x0/0xf returned 0 after 4 usecs
calling  init_nls_cp1250+0x0/0xf @ 1
initcall init_nls_cp1250+0x0/0xf returned 0 after 17 usecs
calling  init_nls_ascii+0x0/0xf @ 1
initcall init_nls_ascii+0x0/0xf returned 0 after 4 usecs
calling  init_nls_iso8859_1+0x0/0xf @ 1
initcall init_nls_iso8859_1+0x0/0xf returned 0 after 4 usecs
calling  init_nls_iso8859_2+0x0/0xf @ 1
initcall init_nls_iso8859_2+0x0/0xf returned 0 after 4 usecs
calling  init_nls_iso8859_4+0x0/0xf @ 1
initcall init_nls_iso8859_4+0x0/0xf returned 0 after 4 usecs
calling  init_nls_iso8859_6+0x0/0xf @ 1
initcall init_nls_iso8859_6+0x0/0xf returned 0 after 4 usecs
calling  init_nls_iso8859_7+0x0/0xf @ 1
initcall init_nls_iso8859_7+0x0/0xf returned 0 after 4 usecs
calling  init_nls_cp1255+0x0/0xf @ 1
initcall init_nls_cp1255+0x0/0xf returned 0 after 4 usecs
calling  init_nls_iso8859_9+0x0/0xf @ 1
initcall init_nls_iso8859_9+0x0/0xf returned 0 after 4 usecs
calling  init_nls_iso8859_13+0x0/0xf @ 1
initcall init_nls_iso8859_13+0x0/0xf returned 0 after 4 usecs
calling  init_nls_iso8859_15+0x0/0xf @ 1
initcall init_nls_iso8859_15+0x0/0xf returned 0 after 4 usecs
calling  init_nls_utf8+0x0/0x1f @ 1
initcall init_nls_utf8+0x0/0x1f returned 0 after 4 usecs
calling  init_nls_macceltic+0x0/0xf @ 1
initcall init_nls_macceltic+0x0/0xf returned 0 after 4 usecs
calling  init_nls_maccroatian+0x0/0xf @ 1
initcall init_nls_maccroatian+0x0/0xf returned 0 after 4 usecs
calling  init_nls_maccyrillic+0x0/0xf @ 1
initcall init_nls_maccyrillic+0x0/0xf returned 0 after 4 usecs
calling  init_nls_macgreek+0x0/0xf @ 1
initcall init_nls_macgreek+0x0/0xf returned 0 after 4 usecs
calling  init_nls_maciceland+0x0/0xf @ 1
initcall init_nls_maciceland+0x0/0xf returned 0 after 17 usecs
calling  init_nls_macinuit+0x0/0xf @ 1
initcall init_nls_macinuit+0x0/0xf returned 0 after 4 usecs
calling  init_nls_macromanian+0x0/0xf @ 1
initcall init_nls_macromanian+0x0/0xf returned 0 after 4 usecs
calling  init_cifs+0x0/0x45a @ 1
FS-Cache: Netfs 'cifs' registered for caching
Key type cifs.spnego registered
initcall init_cifs+0x0/0x45a returned 0 after 2218 usecs
calling  init_ncp_fs+0x0/0x66 @ 1
initcall init_ncp_fs+0x0/0x66 returned 0 after 23 usecs
calling  init_ntfs_fs+0x0/0x23c @ 1
NTFS driver 2.1.30 [Flags: R/W DEBUG].
initcall init_ntfs_fs+0x0/0x23c returned 0 after 998 usecs
calling  init_autofs4_fs+0x0/0x24 @ 1
initcall init_autofs4_fs+0x0/0x24 returned 0 after 102 usecs
calling  fuse_init+0x0/0x19d @ 1
fuse init (API version 7.22)
initcall fuse_init+0x0/0x19d returned 0 after 1317 usecs
calling  cuse_init+0x0/0x93 @ 1
initcall cuse_init+0x0/0x93 returned 0 after 90 usecs
calling  init_udf_fs+0x0/0x66 @ 1
initcall init_udf_fs+0x0/0x66 returned 0 after 18 usecs
calling  init_xfs_fs+0x0/0xcf @ 1
SGI XFS with security attributes, realtime, debug enabled
initcall init_xfs_fs+0x0/0xcf returned 0 after 1705 usecs
calling  init_v9fs+0x0/0xf3 @ 1
9p: Installing v9fs 9p2000 file system support
FS-Cache: Netfs '9p' registered for caching
initcall init_v9fs+0x0/0xf3 returned 0 after 1137 usecs
calling  init_btrfs_fs+0x0/0x11f @ 1
bio: create slab <bio-1> at 1
Btrfs loaded, assert=3Don
btrfs: selftest: Running btrfs free space cache tests
btrfs: selftest: Running extent only tests
btrfs: selftest: Running bitmap only tests
btrfs: selftest: Running bitmap and extent tests
btrfs: selftest: Free space cache tests finished
initcall init_btrfs_fs+0x0/0x11f returned 0 after 6991 usecs
calling  init_ceph+0x0/0x146 @ 1
FS-Cache: Netfs 'ceph' registered for caching
ceph: loaded (mds proto 32)
initcall init_ceph+0x0/0x146 returned 0 after 2158 usecs
calling  init_mqueue_fs+0x0/0x9e @ 1
initcall init_mqueue_fs+0x0/0x9e returned 0 after 115 usecs
calling  key_proc_init+0x0/0x37 @ 1
initcall key_proc_init+0x0/0x37 returned 0 after 13 usecs
calling  crypto_wq_init+0x0/0x41 @ 1
initcall crypto_wq_init+0x0/0x41 returned 0 after 50 usecs
calling  crypto_algapi_init+0x0/0xc @ 1
initcall crypto_algapi_init+0x0/0xc returned 0 after 27 usecs
calling  skcipher_module_init+0x0/0x11 @ 1
initcall skcipher_module_init+0x0/0x11 returned 0 after 3 usecs
calling  chainiv_module_init+0x0/0xf @ 1
initcall chainiv_module_init+0x0/0xf returned 0 after 5 usecs
calling  eseqiv_module_init+0x0/0xf @ 1
initcall eseqiv_module_init+0x0/0xf returned 0 after 4 usecs
calling  seqiv_module_init+0x0/0xf @ 1
initcall seqiv_module_init+0x0/0xf returned 0 after 4 usecs
calling  crypto_user_init+0x0/0x42 @ 1
initcall crypto_user_init+0x0/0x42 returned 0 after 26 usecs
calling  crypto_cmac_module_init+0x0/0xf @ 1
initcall crypto_cmac_module_init+0x0/0xf returned 0 after 4 usecs
calling  hmac_module_init+0x0/0xf @ 1
initcall hmac_module_init+0x0/0xf returned 0 after 4 usecs
calling  vmac_module_init+0x0/0xf @ 1
initcall vmac_module_init+0x0/0xf returned 0 after 4 usecs
calling  crypto_xcbc_module_init+0x0/0xf @ 1
initcall crypto_xcbc_module_init+0x0/0xf returned 0 after 4 usecs
calling  crypto_null_mod_init+0x0/0x41 @ 1
initcall crypto_null_mod_init+0x0/0x41 returned 0 after 289 usecs
calling  md4_mod_init+0x0/0xf @ 1
initcall md4_mod_init+0x0/0xf returned 0 after 184 usecs
calling  md5_mod_init+0x0/0xf @ 1
initcall md5_mod_init+0x0/0xf returned 0 after 176 usecs
calling  rmd128_mod_init+0x0/0xf @ 1
initcall rmd128_mod_init+0x0/0xf returned 0 after 210 usecs
calling  rmd160_mod_init+0x0/0xf @ 1
initcall rmd160_mod_init+0x0/0xf returned 0 after 229 usecs
calling  rmd256_mod_init+0x0/0xf @ 1
initcall rmd256_mod_init+0x0/0xf returned 0 after 198 usecs
calling  rmd320_mod_init+0x0/0xf @ 1
initcall rmd320_mod_init+0x0/0xf returned 0 after 214 usecs
calling  sha1_generic_mod_init+0x0/0xf @ 1
initcall sha1_generic_mod_init+0x0/0xf returned 0 after 175 usecs
calling  sha256_generic_mod_init+0x0/0x14 @ 1
initcall sha256_generic_mod_init+0x0/0x14 returned 0 after 351 usecs
calling  sha512_generic_mod_init+0x0/0x14 @ 1
initcall sha512_generic_mod_init+0x0/0x14 returned 0 after 545 usecs
calling  wp512_mod_init+0x0/0x14 @ 1
initcall wp512_mod_init+0x0/0x14 returned 0 after 1128 usecs
calling  crypto_ecb_module_init+0x0/0xf @ 1
initcall crypto_ecb_module_init+0x0/0xf returned 0 after 4 usecs
calling  crypto_cbc_module_init+0x0/0xf @ 1
initcall crypto_cbc_module_init+0x0/0xf returned 0 after 4 usecs
calling  crypto_pcbc_module_init+0x0/0xf @ 1
initcall crypto_pcbc_module_init+0x0/0xf returned 0 after 4 usecs
calling  crypto_module_init+0x0/0xf @ 1
initcall crypto_module_init+0x0/0xf returned 0 after 4 usecs
calling  crypto_module_init+0x0/0xf @ 1
initcall crypto_module_init+0x0/0xf returned 0 after 4 usecs
calling  crypto_ctr_module_init+0x0/0x33 @ 1
initcall crypto_ctr_module_init+0x0/0x33 returned 0 after 4 usecs
calling  crypto_gcm_module_init+0x0/0x95 @ 1
initcall crypto_gcm_module_init+0x0/0x95 returned 0 after 5 usecs
calling  crypto_ccm_module_init+0x0/0x4d @ 1
initcall crypto_ccm_module_init+0x0/0x4d returned 0 after 4 usecs
calling  des_generic_mod_init+0x0/0x14 @ 1
initcall des_generic_mod_init+0x0/0x14 returned 0 after 249 usecs
calling  fcrypt_mod_init+0x0/0xf @ 1
initcall fcrypt_mod_init+0x0/0xf returned 0 after 111 usecs
calling  serpent_mod_init+0x0/0x14 @ 1
initcall serpent_mod_init+0x0/0x14 returned 0 after 250 usecs
calling  aes_init+0x0/0xf @ 1
initcall aes_init+0x0/0xf returned 0 after 133 usecs
calling  camellia_init+0x0/0xf @ 1
initcall camellia_init+0x0/0xf returned 0 after 126 usecs
calling  cast5_mod_init+0x0/0xf @ 1
initcall cast5_mod_init+0x0/0xf returned 0 after 137 usecs
calling  cast6_mod_init+0x0/0xf @ 1
initcall cast6_mod_init+0x0/0xf returned 0 after 139 usecs
calling  arc4_init+0x0/0x14 @ 1
initcall arc4_init+0x0/0x14 returned 0 after 605 usecs
calling  tea_mod_init+0x0/0x14 @ 1
initcall tea_mod_init+0x0/0x14 returned 0 after 329 usecs
calling  anubis_mod_init+0x0/0xf @ 1
initcall anubis_mod_init+0x0/0xf returned 0 after 168 usecs
calling  deflate_mod_init+0x0/0xf @ 1
initcall deflate_mod_init+0x0/0xf returned 0 after 527 usecs
calling  zlib_mod_init+0x0/0xf @ 1
initcall zlib_mod_init+0x0/0xf returned 0 after 727 usecs
calling  michael_mic_init+0x0/0xf @ 1
initcall michael_mic_init+0x0/0xf returned 0 after 234 usecs
calling  crc32c_mod_init+0x0/0xf @ 1
initcall crc32c_mod_init+0x0/0xf returned 0 after 306 usecs
calling  crc32_mod_init+0x0/0xf @ 1
alg: No test for crc32 (crc32-table)
initcall crc32_mod_init+0x0/0xf returned 0 after 609 usecs
calling  crct10dif_mod_init+0x0/0xf @ 1
initcall crct10dif_mod_init+0x0/0xf returned 0 after 142 usecs
calling  crypto_authenc_module_init+0x0/0xf @ 1
initcall crypto_authenc_module_init+0x0/0xf returned 0 after 4 usecs
calling  crypto_authenc_esn_module_init+0x0/0xf @ 1
initcall crypto_authenc_esn_module_init+0x0/0xf returned 0 after 4 usecs
calling  lzo_mod_init+0x0/0xf @ 1
initcall lzo_mod_init+0x0/0xf returned 0 after 107 usecs
calling  lz4_mod_init+0x0/0xf @ 1
alg: No test for lz4 (lz4-generic)
initcall lz4_mod_init+0x0/0xf returned 0 after 271 usecs
calling  lz4hc_mod_init+0x0/0xf @ 1
alg: No test for lz4hc (lz4hc-generic)
initcall lz4hc_mod_init+0x0/0xf returned 0 after 946 usecs
calling  krng_mod_init+0x0/0xf @ 1
alg: No test for stdrng (krng)
initcall krng_mod_init+0x0/0xf returned 0 after 1546 usecs
calling  prng_mod_init+0x0/0x14 @ 1
alg: No test for fips(ansi_cprng) (fips_ansi_cprng)
initcall prng_mod_init+0x0/0x14 returned 0 after 8854 usecs
calling  ghash_mod_init+0x0/0xf @ 1
initcall ghash_mod_init+0x0/0xf returned 0 after 198 usecs
calling  af_alg_init+0x0/0x35 @ 1
NET: Registered protocol family 38
initcall af_alg_init+0x0/0x35 returned 0 after 1229 usecs
calling  algif_hash_init+0x0/0xf @ 1
initcall algif_hash_init+0x0/0xf returned 0 after 13 usecs
calling  asymmetric_key_init+0x0/0xf @ 1
Key type asymmetric registered
initcall asymmetric_key_init+0x0/0xf returned 0 after 1527 usecs
calling  proc_genhd_init+0x0/0x44 @ 1
initcall proc_genhd_init+0x0/0x44 returned 0 after 27 usecs
calling  bsg_init+0x0/0x154 @ 1
Block layer SCSI generic (bsg) driver version 0.4 loaded (major 251)
initcall bsg_init+0x0/0x154 returned 0 after 1127 usecs
calling  noop_init+0x0/0xf @ 1
io scheduler noop registered (default)
initcall noop_init+0x0/0xf returned 0 after 928 usecs
calling  deadline_init+0x0/0xf @ 1
io scheduler deadline registered
initcall deadline_init+0x0/0xf returned 0 after 889 usecs
calling  cfq_init+0x0/0x8b @ 1
io scheduler cfq registered
initcall cfq_init+0x0/0x8b returned 0 after 1019 usecs
calling  test_kstrtox_init+0x0/0xb32 @ 1
initcall test_kstrtox_init+0x0/0xb32 returned -22 after 63 usecs
calling  btree_module_init+0x0/0x2f @ 1
initcall btree_module_init+0x0/0x2f returned 0 after 18 usecs
calling  crc_t10dif_mod_init+0x0/0x35 @ 1
initcall crc_t10dif_mod_init+0x0/0x35 returned 0 after 5 usecs
calling  crc32test_init+0x0/0x339 @ 1
crc32: CRC_LE_BITS =3D 8, CRC_BE BITS =3D 8
crc32: self tests passed, processed 225944 bytes in 0 nsec
crc32c: CRC_LE_BITS =3D 8
crc32c: self tests passed, processed 225944 bytes in 0 nsec
initcall crc32test_init+0x0/0x339 returned 0 after 6803 usecs
calling  libcrc32c_mod_init+0x0/0x24 @ 1
initcall libcrc32c_mod_init+0x0/0x24 returned 0 after 5 usecs
calling  init_kmp+0x0/0xf @ 1
initcall init_kmp+0x0/0xf returned 0 after 13 usecs
calling  init_bm+0x0/0xf @ 1
initcall init_bm+0x0/0xf returned 0 after 4 usecs
calling  init_fsm+0x0/0xf @ 1
initcall init_fsm+0x0/0xf returned 0 after 4 usecs
calling  audit_classes_init+0x0/0x4f @ 1
initcall audit_classes_init+0x0/0x4f returned 0 after 28 usecs
calling  err_inject_init+0x0/0x1e @ 1
initcall err_inject_init+0x0/0x1e returned 0 after 25 usecs
calling  digsig_init+0x0/0x36 @ 1
initcall digsig_init+0x0/0x36 returned 0 after 5 usecs
calling  rbtree_test_init+0x0/0x208 @ 1
rbtree testingrbtree testing -> 20477 cycles
 -> 20477 cycles
augmented rbtree testingaugmented rbtree testing -> 28701 cycles
 -> 28701 cycles
initcall rbtree_test_init+0x0/0x208 returned -11 after 2519126 usecs
calling  bgpio_driver_init+0x0/0x11 @ 1
initcall bgpio_driver_init+0x0/0x11 returned 0 after 40 usecs
calling  adnp_i2c_driver_init+0x0/0x11 @ 1
initcall adnp_i2c_driver_init+0x0/0x11 returned 0 after 52 usecs
calling  adp5588_gpio_driver_init+0x0/0x11 @ 1
initcall adp5588_gpio_driver_init+0x0/0x11 returned 0 after 25 usecs
calling  amd_gpio_init+0x0/0x155 @ 1
initcall amd_gpio_init+0x0/0x155 returned -19 after 19 usecs
calling  bt8xxgpio_pci_driver_init+0x0/0x16 @ 1
initcall bt8xxgpio_pci_driver_init+0x0/0x16 returned 0 after 36 usecs
calling  cs5535_gpio_driver_init+0x0/0x11 @ 1
initcall cs5535_gpio_driver_init+0x0/0x11 returned 0 after 27 usecs
calling  grgpio_driver_init+0x0/0x11 @ 1
initcall grgpio_driver_init+0x0/0x11 returned 0 after 27 usecs
calling  ichx_gpio_driver_init+0x0/0x11 @ 1
initcall ichx_gpio_driver_init+0x0/0x11 returned 0 after 26 usecs
calling  it8761e_gpio_init+0x0/0x180 @ 1
initcall it8761e_gpio_init+0x0/0x180 returned -19 after 46 usecs
calling  ttl_driver_init+0x0/0x11 @ 1
initcall ttl_driver_init+0x0/0x11 returned 0 after 27 usecs
calling  kempld_gpio_driver_init+0x0/0x11 @ 1
initcall kempld_gpio_driver_init+0x0/0x11 returned 0 after 27 usecs
calling  lnw_gpio_init+0x0/0x16 @ 1
initcall lnw_gpio_init+0x0/0x16 returned 0 after 40 usecs
calling  ioh_gpio_driver_init+0x0/0x16 @ 1
initcall ioh_gpio_driver_init+0x0/0x16 returned 0 after 32 usecs
calling  pch_gpio_driver_init+0x0/0x16 @ 1
initcall pch_gpio_driver_init+0x0/0x16 returned 0 after 33 usecs
calling  sch_gpio_driver_init+0x0/0x11 @ 1
initcall sch_gpio_driver_init+0x0/0x11 returned 0 after 33 usecs
calling  sdv_gpio_driver_init+0x0/0x16 @ 1
initcall sdv_gpio_driver_init+0x0/0x16 returned 0 after 33 usecs
calling  timbgpio_platform_driver_init+0x0/0x11 @ 1
initcall timbgpio_platform_driver_init+0x0/0x11 returned 0 after 26 usecs
calling  ts5500_dio_driver_init+0x0/0x11 @ 1
initcall ts5500_dio_driver_init+0x0/0x11 returned 0 after 27 usecs
calling  gpo_twl6040_driver_init+0x0/0x11 @ 1
initcall gpo_twl6040_driver_init+0x0/0x11 returned 0 after 27 usecs
calling  vx855gpio_driver_init+0x0/0x11 @ 1
initcall vx855gpio_driver_init+0x0/0x11 returned 0 after 33 usecs
calling  pca9685_i2c_driver_init+0x0/0x11 @ 1
initcall pca9685_i2c_driver_init+0x0/0x11 returned 0 after 26 usecs
calling  twl_pwmled_driver_init+0x0/0x11 @ 1
initcall twl_pwmled_driver_init+0x0/0x11 returned 0 after 27 usecs
calling  pci_proc_init+0x0/0x64 @ 1
initcall pci_proc_init+0x0/0x64 returned 0 after 222 usecs
calling  pci_hotplug_init+0x0/0x4f @ 1
pci_hotplug: PCI Hot Plug PCI Core version: 0.5
initcall pci_hotplug_init+0x0/0x4f returned 0 after 500 usecs
calling  cpcihp_generic_init+0x0/0x428 @ 1
cpcihp_generic: Generic port I/O CompactPCI Hot Plug Driver version: 0.1
cpcihp_generic: not configured, disabling.
initcall cpcihp_generic_init+0x0/0x428 returned -22 after 2431 usecs
calling  shpcd_init+0x0/0x5f @ 1
shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
initcall shpcd_init+0x0/0x5f returned 0 after 750 usecs
calling  fb_console_init+0x0/0x108 @ 1
initcall fb_console_init+0x0/0x108 returned 0 after 66 usecs
calling  pm860x_backlight_driver_init+0x0/0x11 @ 1
initcall pm860x_backlight_driver_init+0x0/0x11 returned 0 after 27 usecs
calling  bd6107_driver_init+0x0/0x11 @ 1
initcall bd6107_driver_init+0x0/0x11 returned 0 after 31 usecs
calling  da903x_backlight_driver_init+0x0/0x11 @ 1
initcall da903x_backlight_driver_init+0x0/0x11 returned 0 after 27 usecs
calling  gpio_backlight_driver_init+0x0/0x11 @ 1
initcall gpio_backlight_driver_init+0x0/0x11 returned 0 after 26 usecs
calling  lm3533_bl_driver_init+0x0/0x11 @ 1
initcall lm3533_bl_driver_init+0x0/0x11 returned 0 after 27 usecs
calling  lm3630_i2c_driver_init+0x0/0x11 @ 1
initcall lm3630_i2c_driver_init+0x0/0x11 returned 0 after 26 usecs
calling  lp8788_bl_driver_init+0x0/0x11 @ 1
initcall lp8788_bl_driver_init+0x0/0x11 returned 0 after 27 usecs
calling  ot200_backlight_driver_init+0x0/0x11 @ 1
initcall ot200_backlight_driver_init+0x0/0x11 returned 0 after 27 usecs
calling  pandora_backlight_driver_init+0x0/0x11 @ 1
initcall pandora_backlight_driver_init+0x0/0x11 returned 0 after 26 usecs
calling  kb3886_init+0x0/0xa @ 1
initcall kb3886_init+0x0/0xa returned -19 after 4 usecs
calling  tps65217_bl_driver_init+0x0/0x11 @ 1
initcall tps65217_bl_driver_init+0x0/0x11 returned 0 after 27 usecs
calling  arcfb_init+0x0/0x66 @ 1
initcall arcfb_init+0x0/0x66 returned -6 after 4 usecs
calling  pm2fb_init+0x0/0x120 @ 1
initcall pm2fb_init+0x0/0x120 returned 0 after 40 usecs
calling  i740fb_init+0x0/0x99 @ 1
initcall i740fb_init+0x0/0x99 returned 0 after 34 usecs
calling  matroxfb_init+0x0/0x24b @ 1
initcall matroxfb_init+0x0/0x24b returned 0 after 49 usecs
calling  i2c_matroxfb_init+0x0/0x29 @ 1
initcall i2c_matroxfb_init+0x0/0x29 returned 0 after 4 usecs
calling  rivafb_init+0x0/0x18e @ 1
rivafb_setup START
initcall rivafb_init+0x0/0x18e returned 0 after 516 usecs
calling  nvidiafb_init+0x0/0x288 @ 1
nvidiafb_setup START
initcall nvidiafb_init+0x0/0x288 returned 0 after 842 usecs
calling  aty128fb_init+0x0/0x111 @ 1
initcall aty128fb_init+0x0/0x111 returned 0 after 38 usecs
calling  savagefb_init+0x0/0x5e @ 1
initcall savagefb_init+0x0/0x5e returned 0 after 41 usecs
calling  neofb_init+0x0/0x11d @ 1
initcall neofb_init+0x0/0x11d returned 0 after 34 usecs
calling  tdfxfb_init+0x0/0x105 @ 1
initcall tdfxfb_init+0x0/0x105 returned 0 after 33 usecs
calling  imsttfb_init+0x0/0xdd @ 1
initcall imsttfb_init+0x0/0xdd returned 0 after 34 usecs
calling  vt8623fb_init+0x0/0x6c @ 1
initcall vt8623fb_init+0x0/0x6c returned 0 after 33 usecs
calling  tridentfb_init+0x0/0x1db @ 1
initcall tridentfb_init+0x0/0x1db returned 0 after 36 usecs
calling  vmlfb_init+0x0/0x82 @ 1
vmlfb: initializing
initcall vmlfb_init+0x0/0x82 returned 0 after 679 usecs
calling  cr_pll_init+0x0/0xd3 @ 1
Could not find Carillo Ranch MCH device.
initcall cr_pll_init+0x0/0xd3 returned -19 after 1266 usecs
calling  s3fb_init+0x0/0xf1 @ 1
initcall s3fb_init+0x0/0xf1 returned 0 after 34 usecs
calling  arkfb_init+0x0/0x6c @ 1
initcall arkfb_init+0x0/0x6c returned 0 after 33 usecs
calling  hecubafb_init+0x0/0x11 @ 1
initcall hecubafb_init+0x0/0x11 returned 0 after 33 usecs
calling  n411_init+0x0/0x7f @ 1
no IO addresses supplied
initcall n411_init+0x0/0x7f returned -22 after 1501 usecs
calling  hgafb_init+0x0/0x6f @ 1
hgafb: HGA card not detected.
hgafb: probe of hgafb.0 failed with error -22
initcall hgafb_init+0x0/0x6f returned 0 after 2499 usecs
calling  sstfb_init+0x0/0x176 @ 1
initcall sstfb_init+0x0/0x176 returned 0 after 40 usecs
calling  s1d13xxxfb_init+0x0/0x28 @ 1
initcall s1d13xxxfb_init+0x0/0x28 returned 0 after 27 usecs
calling  sm501fb_driver_init+0x0/0x11 @ 1
initcall sm501fb_driver_init+0x0/0x11 returned 0 after 26 usecs
calling  ufx_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver smscufx
initcall ufx_driver_init+0x0/0x16 returned 0 after 670 usecs
calling  carminefb_init+0x0/0x33 @ 1
initcall carminefb_init+0x0/0x33 returned 0 after 33 usecs
calling  ssd1307fb_driver_init+0x0/0x11 @ 1
initcall ssd1307fb_driver_init+0x0/0x11 returned 0 after 40 usecs
calling  ipmi_init_msghandler_mod+0x0/0xc @ 1
ipmi message handler version 39.2
initcall ipmi_init_msghandler_mod+0x0/0xc returned 0 after 1071 usecs
calling  init_ipmi_devintf+0x0/0xf3 @ 1
ipmi device interface
initcall init_ipmi_devintf+0x0/0xf3 returned 0 after 1022 usecs
calling  init_ipmi_si+0x0/0x4e6 @ 1
IPMI System Interface driver.
ipmi_si: Adding default-specified kcs state machineipmi_si: Adding default-=
specified kcs state machine

ipmi_si: Trying default-specified kcs state machine at i/o address 0xca2, s=
lave address 0x0, irq 0
ipmi_si: Interface detection failed
Switched to clocksource tsc
ipmi_si: Adding default-specified smic state machineipmi_si: Adding default=
-specified smic state machine

ipmi_si: Trying default-specified smic state machine at i/o address 0xca9, =
slave address 0x0, irq 0
ipmi_si: Interface detection failed
ipmi_si: Adding default-specified bt state machineipmi_si: Adding default-s=
pecified bt state machine

ipmi_si: Trying default-specified bt state machine at i/o address 0xe4, sla=
ve address 0x0, irq 0
ipmi_si: Interface detection failed
ipmi_si: Unable to find any System Interface(s)
initcall init_ipmi_si+0x0/0x4e6 returned -19 after 82793 usecs
calling  ipmi_wdog_init+0x0/0x117 @ 1
IPMI Watchdog: driver initialized
initcall ipmi_wdog_init+0x0/0x117 returned 0 after 5941 usecs
calling  ipmi_poweroff_init+0x0/0x7f @ 1
Copyright (C) 2004 MontaVista Software - IPMI Powerdown via sys_reboot.
initcall ipmi_poweroff_init+0x0/0x7f returned 0 after 12394 usecs
calling  pnpbios_thread_init+0x0/0x6c @ 1
initcall pnpbios_thread_init+0x0/0x6c returned 0 after 31 usecs
calling  isapnp_init+0x0/0x5de @ 1
isapnp: Scanning for PnP cards...
isapnp: No Plug & Play device found
initcall isapnp_init+0x0/0x5de returned 0 after 359039 usecs
calling  virtio_mmio_init+0x0/0x11 @ 1
initcall virtio_mmio_init+0x0/0x11 returned 0 after 23 usecs
calling  virtio_pci_driver_init+0x0/0x16 @ 1
initcall virtio_pci_driver_init+0x0/0x16 returned 0 after 30 usecs
calling  virtio_balloon_driver_init+0x0/0xf @ 1
initcall virtio_balloon_driver_init+0x0/0xf returned 0 after 21 usecs
calling  regulator_virtual_consumer_driver_init+0x0/0x11 @ 1
initcall regulator_virtual_consumer_driver_init+0x0/0x11 returned 0 after 2=
4 usecs
calling  regulator_userspace_consumer_driver_init+0x0/0x11 @ 1
initcall regulator_userspace_consumer_driver_init+0x0/0x11 returned 0 after=
 23 usecs
calling  pm800_regulator_driver_init+0x0/0x11 @ 1
initcall pm800_regulator_driver_init+0x0/0x11 returned 0 after 23 usecs
calling  da9210_regulator_driver_init+0x0/0x11 @ 1
initcall da9210_regulator_driver_init+0x0/0x11 returned 0 after 22 usecs
calling  lp3971_i2c_driver_init+0x0/0x11 @ 1
initcall lp3971_i2c_driver_init+0x0/0x11 returned 0 after 21 usecs
calling  pfuze_driver_init+0x0/0x11 @ 1
initcall pfuze_driver_init+0x0/0x11 returned 0 after 29 usecs
calling  wm8994_ldo_driver_init+0x0/0x11 @ 1
initcall wm8994_ldo_driver_init+0x0/0x11 returned 0 after 23 usecs
calling  pty_init+0x0/0x357 @ 1
initcall pty_init+0x0/0x357 returned 0 after 34834 usecs
calling  sysrq_init+0x0/0xb6 @ 1
initcall sysrq_init+0x0/0xb6 returned 0 after 20 usecs
calling  gsm_init+0x0/0x141 @ 1
initcall gsm_init+0x0/0x141 returned 0 after 44 usecs
calling  serial8250_init+0x0/0x15a @ 1
Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
serial8250: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115200) is a 16550A
initcall serial8250_init+0x0/0x15a returned 0 after 42661 usecs
calling  serial_pci_driver_init+0x0/0x16 @ 1
initcall serial_pci_driver_init+0x0/0x16 returned 0 after 77 usecs
calling  dw8250_platform_driver_init+0x0/0x11 @ 1
initcall dw8250_platform_driver_init+0x0/0x11 returned 0 after 25 usecs
calling  ulite_init+0x0/0x87 @ 1
initcall ulite_init+0x0/0x87 returned 0 after 53 usecs
calling  altera_uart_init+0x0/0x35 @ 1
initcall altera_uart_init+0x0/0x35 returned 0 after 52 usecs
calling  asc_init+0x0/0x43 @ 1
STMicroelectronics ASC driver initialized
initcall asc_init+0x0/0x43 returned 0 after 7345 usecs
calling  init_kgdboc+0x0/0x15 @ 1
initcall init_kgdboc+0x0/0x15 returned 0 after 1 usecs
calling  timbuart_platform_driver_init+0x0/0x11 @ 1
initcall timbuart_platform_driver_init+0x0/0x11 returned 0 after 24 usecs
calling  altera_jtaguart_init+0x0/0x35 @ 1
initcall altera_jtaguart_init+0x0/0x35 returned 0 after 43 usecs
calling  hsu_pci_init+0x0/0x2b1 @ 1
initcall hsu_pci_init+0x0/0x2b1 returned 0 after 210 usecs
calling  pch_uart_module_init+0x0/0x3a @ 1
initcall pch_uart_module_init+0x0/0x3a returned 0 after 68 usecs
calling  xuartps_init+0x0/0x35 @ 1
initcall xuartps_init+0x0/0x35 returned 0 after 45 usecs
calling  rp2_uart_init+0x0/0x3a @ 1
initcall rp2_uart_init+0x0/0x3a returned 0 after 106 usecs
calling  lpuart_serial_init+0x0/0x43 @ 1
serial: Freescale lpuart driver
initcall lpuart_serial_init+0x0/0x43 returned 0 after 5667 usecs
calling  nozomi_init+0x0/0x100 @ 1
Initializing Nozomi driver 2.1d
initcall nozomi_init+0x0/0x100 returned 0 after 5696 usecs
calling  rand_initialize+0x0/0x25 @ 1
initcall rand_initialize+0x0/0x25 returned 0 after 43 usecs
calling  init+0x0/0xf3 @ 1
initcall init+0x0/0xf3 returned 0 after 77 usecs
calling  raw_init+0x0/0x135 @ 1
initcall raw_init+0x0/0x135 returned 0 after 160 usecs
calling  lp_init_module+0x0/0x210 @ 1
lp: driver loaded but no devices found
initcall lp_init_module+0x0/0x210 returned 0 after 6790 usecs
calling  dtlk_init+0x0/0x1d1 @ 1
DoubleTalk PC - not found
initcall dtlk_init+0x0/0x1d1 returned -19 after 4597 usecs
calling  applicom_init+0x0/0x484 @ 1
Applicom driver: $Id: ac.c,v 1.30 2000/03/22 16:03:57 dwmw2 Exp $
ac.o: No PCI boards found.
ac.o: For an ISA board you must supply memory and irq parameters.
initcall applicom_init+0x0/0x484 returned -6 after 27475 usecs
calling  i8k_init+0x0/0x30d @ 1
initcall i8k_init+0x0/0x30d returned -19 after 0 usecs
calling  timeriomem_rng_driver_init+0x0/0x11 @ 1
initcall timeriomem_rng_driver_init+0x0/0x11 returned 0 after 24 usecs
calling  mod_init+0x0/0x1dc @ 1
initcall mod_init+0x0/0x1dc returned -19 after 111 usecs
calling  mod_init+0x0/0x11a @ 1
initcall mod_init+0x0/0x11a returned -19 after 11 usecs
calling  mod_init+0x0/0x9a @ 1
initcall mod_init+0x0/0x9a returned -19 after 8 usecs
calling  mod_init+0x0/0x48 @ 1
initcall mod_init+0x0/0x48 returned -19 after 0 usecs
calling  virtio_rng_driver_init+0x0/0xf @ 1
initcall virtio_rng_driver_init+0x0/0xf returned 0 after 21 usecs
calling  rng_init+0x0/0xf @ 1
initcall rng_init+0x0/0xf returned 0 after 136 usecs
calling  ppdev_init+0x0/0xba @ 1
ppdev: user-space parallel port driver
initcall ppdev_init+0x0/0xba returned 0 after 6789 usecs
calling  pc8736x_gpio_init+0x0/0x2dd @ 1
platform pc8736x_gpio.0: NatSemi pc8736x GPIO Driver Initializing
platform pc8736x_gpio.0: no device found
initcall pc8736x_gpio_init+0x0/0x2dd returned -19 after 18607 usecs
calling  nsc_gpio_init+0x0/0x14 @ 1
nsc_gpio initializing
initcall nsc_gpio_init+0x0/0x14 returned 0 after 3910 usecs
calling  tlclk_init+0x0/0x1d9 @ 1
telclk_interrupt =3D 0xf non-mcpbl0010 hw.
initcall tlclk_init+0x0/0x1d9 returned -6 after 7128 usecs
calling  mwave_init+0x0/0x1e5 @ 1
smapi::smapi_init, ERROR invalid usSmapiID
mwave: tp3780i::tp3780I_InitializeBoardData: Error: SMAPI is not available =
on this machine
mwave: mwavedd::mwave_init: Error: Failed to initialize board data
mwave: mwavedd::mwave_init: Error: Failed to initialize
initcall mwave_init+0x0/0x1e5 returned -5 after 44250 usecs
calling  agp_init+0x0/0x32 @ 1
Linux agpgart interface v0.103
initcall agp_init+0x0/0x32 returned 0 after 5434 usecs
calling  agp_ali_init+0x0/0x27 @ 1
initcall agp_ali_init+0x0/0x27 returned 0 after 37 usecs
calling  agp_intel_init+0x0/0x27 @ 1
initcall agp_intel_init+0x0/0x27 returned 0 after 34 usecs
calling  agp_nvidia_init+0x0/0x27 @ 1
initcall agp_nvidia_init+0x0/0x27 returned 0 after 36 usecs
calling  agp_sis_init+0x0/0x27 @ 1
initcall agp_sis_init+0x0/0x27 returned 0 after 31 usecs
calling  agp_serverworks_init+0x0/0x27 @ 1
initcall agp_serverworks_init+0x0/0x27 returned 0 after 29 usecs
calling  agp_via_init+0x0/0x27 @ 1
initcall agp_via_init+0x0/0x27 returned 0 after 33 usecs
calling  synclink_cs_init+0x0/0x103 @ 1
SyncLink PC Card driver $Revision: 4.34 $, tty major#242
initcall synclink_cs_init+0x0/0x103 returned 0 after 9837 usecs
calling  cmm_init+0x0/0xa7 @ 1
initcall cmm_init+0x0/0xa7 returned 0 after 53 usecs
calling  cm4040_init+0x0/0xa7 @ 1
initcall cm4040_init+0x0/0xa7 returned 0 after 55 usecs
calling  hangcheck_init+0x0/0xab @ 1
Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 seconds, margin is 6=
0 seconds).
Hangcheck: Using getrawmonotonic().
initcall hangcheck_init+0x0/0xab returned 0 after 21193 usecs
calling  init_tis+0x0/0x9d @ 1
initcall init_tis+0x0/0x9d returned 0 after 32 usecs
calling  tpm_tis_i2c_driver_init+0x0/0x11 @ 1
initcall tpm_tis_i2c_driver_init+0x0/0x11 returned 0 after 35 usecs
calling  init_nsc+0x0/0x570 @ 1
initcall init_nsc+0x0/0x570 returned -19 after 10 usecs
calling  init_inf+0x0/0xf @ 1
initcall init_inf+0x0/0xf returned 0 after 23 usecs
calling  i810fb_init+0x0/0x33e @ 1
initcall i810fb_init+0x0/0x33e returned 0 after 31 usecs
calling  parport_default_proc_register+0x0/0x16 @ 1
initcall parport_default_proc_register+0x0/0x16 returned 0 after 24 usecs
calling  parport_pc_init+0x0/0x336 @ 1
IT8712 SuperIO detected.
parport_pc 00:0e: reported by Plug and Play BIOS
parport0: PC-style at 0x378parport0: PC-style at 0x378 (0x778) (0x778), irq=
 7, irq 7 [ [PCSPPPCSPP,TRISTATE,TRISTATE]
]
lp0: using parport0 (interrupt-driven).
initcall parport_pc_init+0x0/0x336 returned 0 after 110351 usecs
calling  parport_serial_init+0x0/0x16 @ 1
initcall parport_serial_init+0x0/0x16 returned 0 after 35 usecs
calling  parport_cs_driver_init+0x0/0xf @ 1
initcall parport_cs_driver_init+0x0/0xf returned 0 after 24 usecs
calling  axdrv_init+0x0/0x11 @ 1
initcall axdrv_init+0x0/0x11 returned 0 after 25 usecs
calling  topology_sysfs_init+0x0/0x19 @ 1
initcall topology_sysfs_init+0x0/0x19 returned 0 after 10 usecs
calling  isa_bus_init+0x0/0x33 @ 1
initcall isa_bus_init+0x0/0x33 returned 0 after 43 usecs
calling  floppy_init+0x0/0x13 @ 1
initcall floppy_init+0x0/0x13 returned 0 after 15 usecs
calling  loop_init+0x0/0x129 @ 1
loop: module loaded
initcall loop_init+0x0/0x129 returned 0 after 5479 usecs
calling  cpqarray_init+0x0/0x26d @ 1
Compaq SMART2 Driver (v 2.6.0)
initcall cpqarray_init+0x0/0x26d returned -19 after 5496 usecs
calling  cciss_init+0x0/0x9b @ 1
HP CISS Driver (v 3.6.26)
calling  1_floppy_async_init+0x0/0xa @ 6
Floppy drive(s):Floppy drive(s): fd0 is 1.44M fd0 is 1.44M

initcall cciss_init+0x0/0x9b returned 0 after 18234 usecs
calling  pkt_init+0x0/0x169 @ 1
initcall pkt_init+0x0/0x169 returned 0 after 181 usecs
calling  osdblk_init+0x0/0x7a @ 1
initcall osdblk_init+0x0/0x7a returned 0 after 27 usecs
calling  mm_init+0x0/0x168 @ 1
MM: desc_per_page =3D 128
initcall mm_init+0x0/0x168 returned 0 after 4250 usecs
calling  nbd_init+0x0/0x323 @ 1
nbd: registered device at major 43
initcall nbd_init+0x0/0x323 returned 0 after 10245 usecs
calling  init+0x0/0x8b @ 1
initcall init+0x0/0x8b returned 0 after 39 usecs
calling  carm_init+0x0/0x16 @ 1
initcall carm_init+0x0/0x16 returned 0 after 37 usecs
calling  mtip_init+0x0/0x13e @ 1
mtip32xx Version 1.2.6os3
initcall mtip_init+0x0/0x13e returned 0 after 4670 usecs
calling  ibmasm_init+0x0/0x69 @ 1
ibmasm: IBM ASM Service Processor Driver version 1.0 loaded
initcall ibmasm_init+0x0/0x69 returned 0 after 10344 usecs
calling  dummy_irq_init+0x0/0x75 @ 1
dummy-irq: no IRQ given.  Use irq=3DN
initcall dummy_irq_init+0x0/0x75 returned -5 after 6280 usecs
calling  ics932s401_driver_init+0x0/0x11 @ 1
initcall ics932s401_driver_init+0x0/0x11 returned 0 after 28 usecs
calling  lkdtm_module_init+0x0/0x1b4 @ 1
lkdtm: No crash points registered, enable through debugfs
initcall lkdtm_module_init+0x0/0x1b4 returned 0 after 10005 usecs
calling  tifm_7xx1_driver_init+0x0/0x16 @ 1
initcall tifm_7xx1_driver_init+0x0/0x16 returned 0 after 39 usecs
calling  phantom_init+0x0/0xed @ 1
Phantom Linux Driver, version n0.9.8, init OK
initcall phantom_init+0x0/0xed returned 0 after 7975 usecs
calling  bh1780_driver_init+0x0/0x11 @ 1
initcall bh1780_driver_init+0x0/0x11 returned 0 after 30 usecs
calling  apds990x_driver_init+0x0/0x11 @ 1
initcall apds990x_driver_init+0x0/0x11 returned 0 after 29 usecs
calling  ioc4_init+0x0/0x16 @ 1
initcall ioc4_init+0x0/0x16 returned 0 after 30 usecs
calling  enclosure_init+0x0/0x14 @ 1
initcall enclosure_init+0x0/0x14 returned 0 after 22 usecs
calling  init_kgdbts+0x0/0x15 @ 1
initcall init_kgdbts+0x0/0x15 returned 0 after 0 usecs
calling  cs5535_mfgpt_init+0x0/0x11 @ 1
initcall cs5535_mfgpt_init+0x0/0x11 returned 0 after 32 usecs
calling  ilo_init+0x0/0x82 @ 1
initcall ilo_init+0x0/0x82 returned 0 after 78 usecs
calling  isl29020_driver_init+0x0/0x11 @ 1
initcall isl29020_driver_init+0x0/0x11 returned 0 after 30 usecs
calling  tsl2550_driver_init+0x0/0x11 @ 1
initcall tsl2550_driver_init+0x0/0x11 returned 0 after 22 usecs
calling  ds1682_driver_init+0x0/0x11 @ 1
initcall ds1682_driver_init+0x0/0x11 returned 0 after 21 usecs
calling  at24_init+0x0/0x43 @ 1
initcall at24_init+0x0/0x43 returned 0 after 22 usecs
calling  eeprom_driver_init+0x0/0x11 @ 1
initcall eeprom_driver_init+0x0/0x11 returned 0 after 21 usecs
calling  cb710_init_module+0x0/0x16 @ 1
initcall cb710_init_module+0x0/0x16 returned 0 after 32 usecs
calling  kim_platform_driver_init+0x0/0x11 @ 1
initcall kim_platform_driver_init+0x0/0x11 returned 0 after 24 usecs
calling  fsa9480_i2c_driver_init+0x0/0x11 @ 1
initcall fsa9480_i2c_driver_init+0x0/0x11 returned 0 after 22 usecs
calling  vmci_drv_init+0x0/0xcf @ 1
Guest personality initialized and is inactive
VMCI host device registered (name=3Dvmci, major=3D10, minor=3D60)
Initialized host personality
initcall vmci_drv_init+0x0/0xcf returned 0 after 24080 usecs
calling  sm501_base_init+0x0/0x22 @ 1
initcall sm501_base_init+0x0/0x22 returned 0 after 58 usecs
calling  cros_ec_driver_init+0x0/0x11 @ 1
initcall cros_ec_driver_init+0x0/0x11 returned 0 after 23 usecs
calling  rtsx_pci_driver_init+0x0/0x16 @ 1
initcall rtsx_pci_driver_init+0x0/0x16 returned 0 after 39 usecs
calling  pasic3_driver_init+0x0/0x14 @ 1
initcall pasic3_driver_init+0x0/0x14 returned -19 after 44 usecs
calling  htcpld_core_init+0x0/0x24 @ 1
initcall htcpld_core_init+0x0/0x24 returned -19 after 63 usecs
calling  ti_tscadc_driver_init+0x0/0x11 @ 1
initcall ti_tscadc_driver_init+0x0/0x11 returned 0 after 24 usecs
calling  wm8994_i2c_driver_init+0x0/0x11 @ 1
initcall wm8994_i2c_driver_init+0x0/0x11 returned 0 after 57 usecs
calling  twl_driver_init+0x0/0x11 @ 1
initcall twl_driver_init+0x0/0x11 returned 0 after 41 usecs
calling  twl4030_madc_driver_init+0x0/0x11 @ 1
initcall twl4030_madc_driver_init+0x0/0x11 returned 0 after 34 usecs
calling  twl4030_audio_driver_init+0x0/0x11 @ 1
initcall twl4030_audio_driver_init+0x0/0x11 returned 0 after 24 usecs
calling  twl6040_driver_init+0x0/0x11 @ 1
initcall twl6040_driver_init+0x0/0x11 returned 0 after 22 usecs
calling  timberdale_pci_driver_init+0x0/0x16 @ 1
initcall timberdale_pci_driver_init+0x0/0x16 returned 0 after 30 usecs
calling  kempld_init+0x0/0x5f @ 1
initcall kempld_init+0x0/0x5f returned -19 after 0 usecs
calling  lpc_sch_driver_init+0x0/0x16 @ 1
initcall lpc_sch_driver_init+0x0/0x16 returned 0 after 36 usecs
calling  lpc_ich_driver_init+0x0/0x16 @ 1
initcall lpc_ich_driver_init+0x0/0x16 returned 0 after 49 usecs
calling  rdc321x_sb_driver_init+0x0/0x16 @ 1
initcall rdc321x_sb_driver_init+0x0/0x16 returned 0 after 30 usecs
calling  cmodio_pci_driver_init+0x0/0x16 @ 1
initcall cmodio_pci_driver_init+0x0/0x16 returned 0 after 37 usecs
calling  vx855_pci_driver_init+0x0/0x16 @ 1
initcall vx855_pci_driver_init+0x0/0x16 returned 0 after 31 usecs
calling  si476x_core_driver_init+0x0/0x11 @ 1
initcall si476x_core_driver_init+0x0/0x11 returned 0 after 22 usecs
calling  cs5535_mfd_driver_init+0x0/0x16 @ 1
initcall cs5535_mfd_driver_init+0x0/0x16 returned 0 after 37 usecs
calling  vprbrd_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver viperboard
initcall vprbrd_driver_init+0x0/0x16 returned 0 after 8989 usecs
calling  nfcwilink_driver_init+0x0/0x11 @ 1
initcall nfcwilink_driver_init+0x0/0x11 returned 0 after 23 usecs
calling  scsi_tgt_init+0x0/0x9d @ 1
FDC 0 is a post-1991 82077
initcall scsi_tgt_init+0x0/0x9d returned 0 after 5476 usecs
calling  raid_init+0x0/0xf @ 1
initcall raid_init+0x0/0xf returned 0 after 23 usecs
calling  spi_transport_init+0x0/0x79 @ 1
initcall spi_transport_init+0x0/0x79 returned 0 after 46 usecs
calling  fc_transport_init+0x0/0x71 @ 1
initcall fc_transport_init+0x0/0x71 returned 0 after 93 usecs
calling  iscsi_transport_init+0x0/0x199 @ 1
Loading iSCSI transport class v2.0-870.
initcall iscsi_transport_init+0x0/0x199 returned 0 after 7239 usecs
calling  sas_transport_init+0x0/0x9f @ 1
initcall sas_transport_init+0x0/0x9f returned 0 after 127 usecs
calling  sas_class_init+0x0/0x38 @ 1
initcall sas_class_init+0x0/0x38 returned 0 after 14 usecs
calling  srp_transport_init+0x0/0x33 @ 1
initcall srp_transport_init+0x0/0x33 returned 0 after 43 usecs
calling  scsi_dh_init+0x0/0x35 @ 1
initcall scsi_dh_init+0x0/0x35 returned 0 after 1 usecs
calling  rdac_init+0x0/0x85 @ 1
rdac: device handler registered
initcall rdac_init+0x0/0x85 returned 0 after 5661 usecs
calling  hp_sw_init+0x0/0xf @ 1
hp_sw: device handler registered
initcall hp_sw_init+0x0/0xf returned 0 after 5773 usecs
calling  clariion_init+0x0/0x32 @ 1
emc: device handler registered
initcall clariion_init+0x0/0x32 returned 0 after 5434 usecs
calling  alua_init+0x0/0x32 @ 1
alua: device handler registered
initcall alua_init+0x0/0x32 returned 0 after 5603 usecs
calling  libfc_init+0x0/0x37 @ 1
initcall libfc_init+0x0/0x37 returned 0 after 152 usecs
calling  libfcoe_init+0x0/0x23 @ 1
initcall libfcoe_init+0x0/0x23 returned 0 after 37 usecs
calling  fnic_init_module+0x0/0x25d @ 1
fnic: Cisco FCoE HBA Driver, ver 1.5.0.23
fnic: Successfully Initialized Trace Buffer
initcall fnic_init_module+0x0/0x25d returned 0 after 15159 usecs
calling  bnx2fc_mod_init+0x0/0x255 @ 1
bnx2fc: Broadcom NetXtreme II FCoE Driver bnx2fc v1.0.14 (Mar 08, 2013)
initcall 1_floppy_async_init+0x0/0xa returned 0 after 1339307 usecs
initcall bnx2fc_mod_init+0x0/0x255 returned 0 after 24511 usecs
calling  iscsi_sw_tcp_init+0x0/0x43 @ 1
iscsi: registered transport (tcp)
initcall iscsi_sw_tcp_init+0x0/0x43 returned 0 after 5942 usecs
calling  arcmsr_module_init+0x0/0x16 @ 1
initcall arcmsr_module_init+0x0/0x16 returned 0 after 35 usecs
calling  init_this_scsi_driver+0x0/0xc6 @ 1
initcall init_this_scsi_driver+0x0/0xc6 returned -19 after 389 usecs
calling  aha152x_init+0x0/0x615 @ 1
initcall aha152x_init+0x0/0x615 returned -19 after 67 usecs
calling  ahc_linux_init+0x0/0x5a @ 1
initcall ahc_linux_init+0x0/0x5a returned 0 after 52 usecs
calling  ahd_linux_init+0x0/0x6c @ 1
initcall ahd_linux_init+0x0/0x6c returned 0 after 55 usecs
calling  aac_init+0x0/0x76 @ 1
Adaptec aacraid driver 1.2-0[30200]-ms
initcall aac_init+0x0/0x76 returned 0 after 6836 usecs
calling  aic94xx_init+0x0/0x12d @ 1
aic94xx: Adaptec aic94xx SAS/SATA driver version 1.0.3 loaded
initcall aic94xx_init+0x0/0x12d returned 0 after 10762 usecs
calling  pm8001_init+0x0/0x9a @ 1
initcall pm8001_init+0x0/0x9a returned 0 after 58 usecs
calling  ips_module_init+0x0/0x2f3 @ 1
initcall ips_module_init+0x0/0x2f3 returned -19 after 65 usecs
calling  init_this_scsi_driver+0x0/0xc6 @ 1
scsi: <fdomain> Detection failed (no card)
initcall init_this_scsi_driver+0x0/0xc6 returned -19 after 7465 usecs
calling  init_this_scsi_driver+0x0/0xc6 @ 1
initcall init_this_scsi_driver+0x0/0xc6 returned -19 after 3 usecs
calling  init_this_scsi_driver+0x0/0xc6 @ 1
initcall init_this_scsi_driver+0x0/0xc6 returned -19 after 1 usecs
calling  init_this_scsi_driver+0x0/0xc6 @ 1
NCR53c406a: no available ports found
initcall init_this_scsi_driver+0x0/0xc6 returned -19 after 6450 usecs
calling  init_this_scsi_driver+0x0/0xc6 @ 1
sym53c416.c: Version 1.0.0-ac
initcall init_this_scsi_driver+0x0/0xc6 returned -19 after 5277 usecs
calling  qla1280_init+0x0/0x16 @ 1
initcall qla1280_init+0x0/0x16 returned 0 after 30 usecs
calling  qla2x00_module_init+0x0/0x242 @ 1
qla2xxx [0000:00:00.0]-0005: : QLogic Fibre Channel HBA Driver: 8.06.00.08-=
k.
initcall qla2x00_module_init+0x0/0x242 returned 0 after 13430 usecs
calling  tcm_qla2xxx_init+0x0/0x29d @ 1
initcall tcm_qla2xxx_init+0x0/0x29d returned 0 after 94 usecs
calling  qla4xxx_module_init+0x0/0xcc @ 1
iscsi: registered transport (qla4xxx)
QLogic iSCSI HBA Driver
initcall qla4xxx_module_init+0x0/0xcc returned 0 after 10868 usecs
calling  lpfc_init+0x0/0xf0 @ 1
Emulex LightPulse Fibre Channel SCSI driver 8.3.42
Copyright(c) 2004-2013 Emulex.  All rights reserved.
initcall lpfc_init+0x0/0xf0 returned 0 after 18119 usecs
calling  bfad_init+0x0/0xab @ 1
Brocade BFA FC/FCOE SCSI driver - version: 3.2.21.1
initcall bfad_init+0x0/0xab returned 0 after 9048 usecs
calling  init_this_scsi_driver+0x0/0xc6 @ 1
initcall init_this_scsi_driver+0x0/0xc6 returned -19 after 2 usecs
calling  dmx3191d_init+0x0/0x16 @ 1
initcall dmx3191d_init+0x0/0x16 returned 0 after 38 usecs
calling  hpsa_init+0x0/0x16 @ 1
initcall hpsa_init+0x0/0x16 returned 0 after 43 usecs
calling  sym2_init+0x0/0xe0 @ 1
initcall sym2_init+0x0/0xe0 returned 0 after 39 usecs
calling  init_this_scsi_driver+0x0/0xc6 @ 1
Failed initialization of WD-7000 SCSI card!
initcall init_this_scsi_driver+0x0/0xc6 returned -19 after 28676 usecs
calling  init_this_scsi_driver+0x0/0xc6 @ 1
initcall init_this_scsi_driver+0x0/0xc6 returned -19 after 30939 usecs
calling  dc395x_module_init+0x0/0x16 @ 1
initcall dc395x_module_init+0x0/0x16 returned 0 after 31 usecs
calling  dc390_module_init+0x0/0x8f @ 1
DC390: clustering now enabled by default. If you get problems load
       with "disable_clustering=3D1" and report to maintainers
initcall dc390_module_init+0x0/0x8f returned 0 after 22071 usecs
calling  megaraid_init+0x0/0xae @ 1
initcall megaraid_init+0x0/0xae returned 0 after 57 usecs
calling  megasas_init+0x0/0x18e @ 1
megasas: 06.700.06.00-rc1 Sat. Aug. 31 17:00:00 PDT 2013
initcall megasas_init+0x0/0x18e returned 0 after 9887 usecs
calling  _scsih_init+0x0/0x154 @ 1
mpt2sas version 16.100.00.00 loaded
initcall _scsih_init+0x0/0x154 returned 0 after 6401 usecs
calling  _scsih_init+0x0/0x154 @ 1
mpt3sas version 02.100.00.00 loaded
initcall _scsih_init+0x0/0x154 returned 0 after 6407 usecs
calling  ufshcd_pci_driver_init+0x0/0x16 @ 1
initcall ufshcd_pci_driver_init+0x0/0x16 returned 0 after 31 usecs
calling  ufshcd_pltfrm_driver_init+0x0/0x11 @ 1
initcall ufshcd_pltfrm_driver_init+0x0/0x11 returned 0 after 34 usecs
calling  gdth_init+0x0/0x7a5 @ 1
GDT-HA: Storage RAID Controller Driver. Version: 3.05
initcall gdth_init+0x0/0x7a5 returned 0 after 9365 usecs
calling  initio_init_driver+0x0/0x16 @ 1
initcall initio_init_driver+0x0/0x16 returned 0 after 31 usecs
calling  inia100_init+0x0/0x16 @ 1
initcall inia100_init+0x0/0x16 returned 0 after 30 usecs
calling  tw_init+0x0/0x2d @ 1
3ware Storage Controller device driver for Linux v1.26.02.003.
initcall tw_init+0x0/0x2d returned 0 after 10888 usecs
calling  twa_init+0x0/0x2d @ 1
3ware 9000 Storage Controller device driver for Linux v2.26.02.014.
initcall twa_init+0x0/0x2d returned 0 after 11728 usecs
calling  imm_driver_init+0x0/0x26 @ 1
imm: Version 2.05 (for Linux 2.4.0)
initcall imm_driver_init+0x0/0x26 returned 0 after 6646 usecs
calling  init_nsp32+0x0/0x3d @ 1
nsp32: loading...
initcall init_nsp32+0x0/0x3d returned 0 after 3265 usecs
calling  ipr_init+0x0/0x3f @ 1
ipr: IBM Power RAID SCSI Device Driver version: 2.6.0 (November 16, 2012)
initcall ipr_init+0x0/0x3f returned 0 after 12748 usecs
calling  hptiop_module_init+0x0/0x35 @ 1
RocketRAID 3xxx/4xxx Controller driver v1.8
initcall hptiop_module_init+0x0/0x35 returned 0 after 7669 usecs
calling  stex_init+0x0/0x2d @ 1
stex: Promise SuperTrak EX Driver version: 4.6.0000.4
initcall stex_init+0x0/0x2d returned 0 after 9360 usecs
calling  libcxgbi_init_module+0x0/0x17a @ 1
Clocksource tsc unstable (delta =3D 2830721179 ns)
libcxgbi:libcxgbi_init_module: tag itt 0x1fff, 13 bits, age 0xf, 4 bits.
libcxgbi:ddp_setup_host_page_size: system PAGE 4096, ddp idx 0.
initcall libcxgbi_init_module+0x0/0x17a returned 0 after 23559 usecs
calling  cxgb4i_init_module+0x0/0x40 @ 1
Chelsio T4/T5 iSCSI Driver cxgb4i v0.9.4
iscsi: registered transport (cxgb4i)
initcall cxgb4i_init_module+0x0/0x40 returned 0 after 13588 usecs
calling  beiscsi_module_init+0x0/0x75 @ 1
iscsi: registered transport (be2iscsi)
In beiscsi_module_init, tt=3Db2bf7600
initcall beiscsi_module_init+0x0/0x75 returned 0 after 13100 usecs
calling  esas2r_init+0x0/0x287 @ 1
esas2r: driver will not be loaded because no ATTO esas2r devices were found
initcall esas2r_init+0x0/0x287 returned -1 after 13052 usecs
calling  pmcraid_init+0x0/0x126 @ 1
initcall pmcraid_init+0x0/0x126 returned 0 after 87 usecs
calling  init+0x0/0xc4 @ 1
initcall init+0x0/0xc4 returned 0 after 411 usecs
calling  pvscsi_init+0x0/0x35 @ 1
VMware PVSCSI driver - version 1.0.2.0-k
initcall pvscsi_init+0x0/0x35 returned 0 after 7164 usecs
calling  init_sd+0x0/0x14b @ 1
initcall init_sd+0x0/0x14b returned 0 after 83 usecs
calling  init_sg+0x0/0xaf @ 1
initcall init_sg+0x0/0xaf returned 0 after 40 usecs
calling  init_ch_module+0x0/0xab @ 1
SCSI Media Changer driver v0.25=20
initcall init_ch_module+0x0/0xab returned 0 after 5817 usecs
calling  osd_uld_init+0x0/0xbe @ 1
osd: LOADED open-osd 0.2.1
initcall osd_uld_init+0x0/0xbe returned 0 after 4758 usecs
calling  ahci_pci_driver_init+0x0/0x16 @ 1
initcall ahci_pci_driver_init+0x0/0x16 returned 0 after 54 usecs
calling  ahci_driver_init+0x0/0x11 @ 1
initcall ahci_driver_init+0x0/0x11 returned 0 after 27 usecs
calling  sil24_pci_driver_init+0x0/0x16 @ 1
initcall sil24_pci_driver_init+0x0/0x16 returned 0 after 33 usecs
calling  ahci_highbank_driver_init+0x0/0x11 @ 1
initcall ahci_highbank_driver_init+0x0/0x11 returned 0 after 39 usecs
calling  imx_ahci_driver_init+0x0/0x11 @ 1
initcall imx_ahci_driver_init+0x0/0x11 returned 0 after 24 usecs
calling  qs_ata_pci_driver_init+0x0/0x16 @ 1
initcall qs_ata_pci_driver_init+0x0/0x16 returned 0 after 31 usecs
calling  piix_init+0x0/0x24 @ 1
initcall piix_init+0x0/0x24 returned 0 after 40 usecs
calling  mv_init+0x0/0x3c @ 1
initcall mv_init+0x0/0x3c returned 0 after 66 usecs
calling  nv_pci_driver_init+0x0/0x16 @ 1
sata_nv 0000:00:07.0: version 3.5
sata_nv 0000:00:07.0: setting latency timer to 64
scsi0 : sata_nv
scsi1 : sata_nv
ata1: SATA max UDMA/133 cmd 0x9f0 ctl 0xbf0 bmdma 0xd800 irq 11
ata2: SATA max UDMA/133 cmd 0x970 ctl 0xb70 bmdma 0xd808 irq 11
sata_nv 0000:00:08.0: setting latency timer to 64
calling  2_async_port_probe+0x0/0x49 @ 6
calling  3_async_port_probe+0x0/0x49 @ 91
async_waiting @ 91
scsi2 : sata_nv
scsi3 : sata_nv
ata3: SATA max UDMA/133 cmd 0x9e0 ctl 0xbe0 bmdma 0xc400 irq 5
ata4: SATA max UDMA/133 cmd 0x960 ctl 0xb60 bmdma 0xc408 irq 5
initcall nv_pci_driver_init+0x0/0x16 returned 0 after 97585 usecs
calling  pdc_ata_pci_driver_init+0x0/0x16 @ 1
initcall pdc_ata_pci_driver_init+0x0/0x16 returned 0 after 41 usecs
calling  sis_pci_driver_init+0x0/0x16 @ 1
initcall sis_pci_driver_init+0x0/0x16 returned 0 after 31 usecs
calling  k2_sata_pci_driver_init+0x0/0x16 @ 1
initcall k2_sata_pci_driver_init+0x0/0x16 returned 0 after 32 usecs
calling  uli_pci_driver_init+0x0/0x16 @ 1
initcall uli_pci_driver_init+0x0/0x16 returned 0 after 31 usecs
calling  svia_pci_driver_init+0x0/0x16 @ 1
initcall svia_pci_driver_init+0x0/0x16 returned 0 after 32 usecs
calling  vsc_sata_pci_driver_init+0x0/0x16 @ 1
initcall vsc_sata_pci_driver_init+0x0/0x16 returned 0 after 38 usecs
calling  ali_init+0x0/0x40 @ 1
initcall ali_init+0x0/0x40 returned 0 after 36 usecs
calling  amd_pci_driver_init+0x0/0x16 @ 1
pata_amd 0000:00:06.0: version 0.4.1
pata_amd 0000:00:06.0: setting latency timer to 64
scsi4 : pata_amd
scsi5 : pata_amd
ata5: PATA max UDMA/133 cmd 0x1f0 ctl 0x3f6 bmdma 0xf000 irq 14
ata6: PATA max UDMA/133 cmd 0x170 ctl 0x376 bmdma 0xf008 irq 15
initcall amd_pci_driver_init+0x0/0x16 returned 0 after 44162 usecs
calling  atp867x_driver_init+0x0/0x16 @ 1
initcall atp867x_driver_init+0x0/0x16 returned 0 after 40 usecs
calling  cmd64x_pci_driver_init+0x0/0x16 @ 1
initcall cmd64x_pci_driver_init+0x0/0x16 returned 0 after 32 usecs
calling  cs5535_pci_driver_init+0x0/0x16 @ 1
initcall cs5535_pci_driver_init+0x0/0x16 returned 0 after 31 usecs
calling  cs5536_pci_driver_init+0x0/0x16 @ 1
initcall cs5536_pci_driver_init+0x0/0x16 returned 0 after 31 usecs
calling  efar_pci_driver_init+0x0/0x16 @ 1
initcall efar_pci_driver_init+0x0/0x16 returned 0 after 33 usecs
calling  hpt36x_pci_driver_init+0x0/0x16 @ 1
initcall hpt36x_pci_driver_init+0x0/0x16 returned 0 after 31 usecs
calling  hpt37x_pci_driver_init+0x0/0x16 @ 1
initcall hpt37x_pci_driver_init+0x0/0x16 returned 0 after 39 usecs
calling  hpt3x2n_pci_driver_init+0x0/0x16 @ 1
initcall hpt3x2n_pci_driver_init+0x0/0x16 returned 0 after 32 usecs
calling  it821x_pci_driver_init+0x0/0x16 @ 1
initcall it821x_pci_driver_init+0x0/0x16 returned 0 after 31 usecs
calling  jmicron_pci_driver_init+0x0/0x16 @ 1
initcall jmicron_pci_driver_init+0x0/0x16 returned 0 after 39 usecs
calling  marvell_pci_driver_init+0x0/0x16 @ 1
initcall marvell_pci_driver_init+0x0/0x16 returned 0 after 32 usecs
calling  ninja32_pci_driver_init+0x0/0x16 @ 1
initcall ninja32_pci_driver_init+0x0/0x16 returned 0 after 32 usecs
calling  oldpiix_pci_driver_init+0x0/0x16 @ 1
initcall oldpiix_pci_driver_init+0x0/0x16 returned 0 after 39 usecs
calling  optidma_pci_driver_init+0x0/0x16 @ 1
initcall optidma_pci_driver_init+0x0/0x16 returned 0 after 40 usecs
calling  pdc2027x_pci_driver_init+0x0/0x16 @ 1
initcall pdc2027x_pci_driver_init+0x0/0x16 returned 0 after 32 usecs
calling  pdc202xx_pci_driver_init+0x0/0x16 @ 1
initcall pdc202xx_pci_driver_init+0x0/0x16 returned 0 after 33 usecs
calling  radisys_pci_driver_init+0x0/0x16 @ 1
initcall radisys_pci_driver_init+0x0/0x16 returned 0 after 31 usecs
calling  rdc_pci_driver_init+0x0/0x16 @ 1
initcall rdc_pci_driver_init+0x0/0x16 returned 0 after 31 usecs
calling  sc1200_pci_driver_init+0x0/0x16 @ 1
initcall sc1200_pci_driver_init+0x0/0x16 returned 0 after 39 usecs
calling  sch_pci_driver_init+0x0/0x16 @ 1
initcall sch_pci_driver_init+0x0/0x16 returned 0 after 38 usecs
calling  serverworks_pci_driver_init+0x0/0x16 @ 1
initcall serverworks_pci_driver_init+0x0/0x16 returned 0 after 32 usecs
calling  sis_pci_driver_init+0x0/0x16 @ 1
initcall sis_pci_driver_init+0x0/0x16 returned 0 after 40 usecs
calling  ata_tosh_pci_driver_init+0x0/0x16 @ 1
initcall ata_tosh_pci_driver_init+0x0/0x16 returned 0 after 32 usecs
calling  triflex_pci_driver_init+0x0/0x16 @ 1
initcall triflex_pci_driver_init+0x0/0x16 returned 0 after 32 usecs
calling  via_pci_driver_init+0x0/0x16 @ 1
initcall via_pci_driver_init+0x0/0x16 returned 0 after 33 usecs
calling  cmd640_pci_driver_init+0x0/0x16 @ 1
initcall cmd640_pci_driver_init+0x0/0x16 returned 0 after 38 usecs
calling  isapnp_init+0x0/0xf @ 1
initcall isapnp_init+0x0/0xf returned 0 after 29 usecs
calling  mpiix_pci_driver_init+0x0/0x16 @ 1
initcall mpiix_pci_driver_init+0x0/0x16 returned 0 after 31 usecs
calling  ns87410_pci_driver_init+0x0/0x16 @ 1
initcall ns87410_pci_driver_init+0x0/0x16 returned 0 after 32 usecs
calling  opti_pci_driver_init+0x0/0x16 @ 1
initcall opti_pci_driver_init+0x0/0x16 returned 0 after 33 usecs
calling  pata_platform_driver_init+0x0/0x11 @ 1
initcall pata_platform_driver_init+0x0/0x11 returned 0 after 34 usecs
calling  pata_of_platform_driver_init+0x0/0x11 @ 1
initcall pata_of_platform_driver_init+0x0/0x11 returned 0 after 25 usecs
calling  rz1000_pci_driver_init+0x0/0x16 @ 1
initcall rz1000_pci_driver_init+0x0/0x16 returned 0 after 39 usecs
calling  ata_generic_pci_driver_init+0x0/0x16 @ 1
initcall ata_generic_pci_driver_init+0x0/0x16 returned 0 after 34 usecs
calling  legacy_init+0x0/0x874 @ 1
initcall legacy_init+0x0/0x874 returned -19 after 14 usecs
calling  target_core_init_configfs+0x0/0x394 @ 1
calling  4_async_port_probe+0x0/0x49 @ 93
calling  5_async_port_probe+0x0/0x49 @ 109
async_waiting @ 109
calling  6_async_port_probe+0x0/0x49 @ 112
calling  7_async_port_probe+0x0/0x49 @ 113
async_waiting @ 113
Switched to clocksource pit
Rounding down aligned max_sectors from 4294967295 to 4294967288
initcall target_core_init_configfs+0x0/0x394 returned 0 after 39537 usecs
calling  iblock_module_init+0x0/0xf @ 1
initcall iblock_module_init+0x0/0xf returned 0 after 4 usecs
calling  fileio_module_init+0x0/0xf @ 1
initcall fileio_module_init+0x0/0xf returned 0 after 4 usecs
calling  tcm_loop_fabric_init+0x0/0x38f @ 1
initcall tcm_loop_fabric_init+0x0/0x38f returned 0 after 132 usecs
calling  iscsi_target_init_module+0x0/0x21e @ 1
initcall iscsi_target_init_module+0x0/0x21e returned 0 after 2380 usecs
calling  hsc_init+0x0/0x66 @ 1
HSI/SSI char device loaded
initcall hsc_init+0x0/0x66 returned 0 after 1828 usecs
calling  bonding_init+0x0/0x97 @ 1
bonding: Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)
initcall bonding_init+0x0/0x97 returned 0 after 1577 usecs
calling  eql_init_module+0x0/0x6a @ 1
eql: Equalizer2002: Simon Janes (simon@ncm.com) and David S. Miller (davem@=
redhat.com)
initcall eql_init_module+0x0/0x6a returned 0 after 1500 usecs
calling  macvlan_init_module+0x0/0x31 @ 1
initcall macvlan_init_module+0x0/0x31 returned 0 after 4 usecs
calling  macvtap_init+0x0/0xc7 @ 1
initcall macvtap_init+0x0/0xc7 returned 0 after 33 usecs
calling  net_olddevs_init+0x0/0x50 @ 1
LocalTalk card not found; 220 =3D ff, 240 =3D ff.
initcall net_olddevs_init+0x0/0x50 returned 0 after 1451 usecs
calling  cicada_init+0x0/0x14 @ 1
initcall cicada_init+0x0/0x14 returned 0 after 49 usecs
calling  qs6612_init+0x0/0xf @ 1
initcall qs6612_init+0x0/0xf returned 0 after 24 usecs
calling  smsc_init+0x0/0x14 @ 1
initcall smsc_init+0x0/0x14 returned 0 after 119 usecs
calling  broadcom_init+0x0/0x14 @ 1
initcall broadcom_init+0x0/0x14 returned 0 after 253 usecs
calling  bcm87xx_init+0x0/0x14 @ 1
initcall bcm87xx_init+0x0/0x14 returned 0 after 46 usecs
calling  icplus_init+0x0/0x14 @ 1
initcall icplus_init+0x0/0x14 returned 0 after 152 usecs
calling  et1011c_init+0x0/0xf @ 1
initcall et1011c_init+0x0/0xf returned 0 after 23 usecs
calling  ns_init+0x0/0xf @ 1
initcall ns_init+0x0/0xf returned 0 after 24 usecs
calling  ste10Xp_init+0x0/0x14 @ 1
initcall ste10Xp_init+0x0/0x14 returned 0 after 53 usecs
calling  ksphy_init+0x0/0x14 @ 1
initcall ksphy_init+0x0/0x14 returned 0 after 261 usecs
calling  atheros_init+0x0/0x14 @ 1
initcall atheros_init+0x0/0x14 returned 0 after 72 usecs
calling  mdio_mux_gpio_driver_init+0x0/0x11 @ 1
initcall mdio_mux_gpio_driver_init+0x0/0x11 returned 0 after 40 usecs
calling  mdio_mux_mmioreg_driver_init+0x0/0x11 @ 1
initcall mdio_mux_mmioreg_driver_init+0x0/0x11 returned 0 after 29 usecs
calling  team_module_init+0x0/0x80 @ 1
initcall team_module_init+0x0/0x80 returned 0 after 54 usecs
calling  bc_init_module+0x0/0xf @ 1
initcall bc_init_module+0x0/0xf returned 0 after 22 usecs
calling  rr_init_module+0x0/0xf @ 1
initcall rr_init_module+0x0/0xf returned 0 after 4 usecs
calling  rnd_init_module+0x0/0xf @ 1
initcall rnd_init_module+0x0/0xf returned 0 after 4 usecs
calling  ab_init_module+0x0/0xf @ 1
initcall ab_init_module+0x0/0xf returned 0 after 4 usecs
calling  lb_init_module+0x0/0xf @ 1
initcall lb_init_module+0x0/0xf returned 0 after 4 usecs
calling  virtio_net_driver_init+0x0/0xf @ 1
initcall virtio_net_driver_init+0x0/0xf returned 0 after 27 usecs
calling  nlmon_register+0x0/0xf @ 1
initcall nlmon_register+0x0/0xf returned 0 after 4 usecs
calling  ipddp_init_module+0x0/0xed @ 1
ipddp.c:v0.01 8/28/97 Bradford W. Johnson <johns393@maroon.tc.umn.edu>
ipddp0: Appletalk-IP Encap. mode by Bradford W. Johnson <johns393@maroon.tc=
=2Eumn.edu>
initcall ipddp_init_module+0x0/0xed returned 0 after 3465 usecs
calling  can_dev_init+0x0/0x2c @ 1
CAN device driver interface
initcall can_dev_init+0x0/0x2c returned 0 after 1019 usecs
calling  esd_usb2_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver esd_usb2
initcall esd_usb2_driver_init+0x0/0x16 returned 0 after 839 usecs
calling  kvaser_usb_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver kvaser_usb
initcall kvaser_usb_driver_init+0x0/0x16 returned 0 after 1178 usecs
calling  usb_8dev_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver usb_8dev
initcall usb_8dev_driver_init+0x0/0x16 returned 0 after 1813 usecs
calling  softing_driver_init+0x0/0x11 @ 1
initcall softing_driver_init+0x0/0x11 returned 0 after 29 usecs
calling  sja1000_init+0x0/0x1e @ 1
sja1000 CAN netdevice driver
initcall sja1000_init+0x0/0x1e returned 0 after 1189 usecs
calling  sja1000_isa_init+0x0/0x14f @ 1
sja1000_isa: insufficient parameters supplied
initcall sja1000_isa_init+0x0/0x14f returned -22 after 1137 usecs
calling  sp_driver_init+0x0/0x11 @ 1
initcall sp_driver_init+0x0/0x11 returned 0 after 30 usecs
calling  ems_pcmcia_driver_init+0x0/0xf @ 1
initcall ems_pcmcia_driver_init+0x0/0xf returned 0 after 36 usecs
calling  ems_pci_driver_init+0x0/0x16 @ 1
initcall ems_pci_driver_init+0x0/0x16 returned 0 after 53 usecs
calling  pcan_driver_init+0x0/0xf @ 1
initcall pcan_driver_init+0x0/0xf returned 0 after 26 usecs
calling  peak_pci_driver_init+0x0/0x16 @ 1
initcall peak_pci_driver_init+0x0/0x16 returned 0 after 36 usecs
calling  plx_pci_driver_init+0x0/0x16 @ 1
initcall plx_pci_driver_init+0x0/0x16 returned 0 after 36 usecs
calling  tscan1_init+0x0/0x14 @ 1
initcall tscan1_init+0x0/0x14 returned 0 after 263 usecs
calling  cc770_init+0x0/0x2b @ 1
cc770: CAN netdevice driver
initcall cc770_init+0x0/0x2b returned 0 after 1033 usecs
calling  cc770_isa_init+0x0/0x130 @ 1
cc770_isa: insufficient parameters supplied
initcall cc770_isa_init+0x0/0x130 returned -22 after 798 usecs
calling  cc770_platform_driver_init+0x0/0x11 @ 1
initcall cc770_platform_driver_init+0x0/0x11 returned 0 after 45 usecs
calling  pch_can_pci_driver_init+0x0/0x16 @ 1
initcall pch_can_pci_driver_init+0x0/0x16 returned 0 after 36 usecs
calling  grcan_driver_init+0x0/0x11 @ 1
initcall grcan_driver_init+0x0/0x11 returned 0 after 29 usecs
calling  tc589_driver_init+0x0/0xf @ 1
initcall tc589_driver_init+0x0/0xf returned 0 after 27 usecs
calling  vortex_init+0x0/0x9f @ 1
initcall vortex_init+0x0/0x9f returned 0 after 54 usecs
calling  typhoon_init+0x0/0x16 @ 1
initcall typhoon_init+0x0/0x16 returned 0 after 36 usecs
calling  ne_init+0x0/0x21 @ 1
initcall ne_init+0x0/0x21 returned -19 after 361 usecs
calling  NS8390p_init_module+0x0/0x7 @ 1
initcall NS8390p_init_module+0x0/0x7 returned 0 after 4 usecs
calling  ne2k_pci_init+0x0/0x16 @ 1
initcall ne2k_pci_init+0x0/0x16 returned 0 after 37 usecs
calling  axnet_cs_driver_init+0x0/0xf @ 1
initcall axnet_cs_driver_init+0x0/0xf returned 0 after 31 usecs
calling  pcnet_driver_init+0x0/0xf @ 1
initcall pcnet_driver_init+0x0/0xf returned 0 after 61 usecs
calling  amd8111e_driver_init+0x0/0x16 @ 1
initcall amd8111e_driver_init+0x0/0x16 returned 0 after 36 usecs
calling  nmclan_cs_driver_init+0x0/0xf @ 1
initcall nmclan_cs_driver_init+0x0/0xf returned 0 after 27 usecs
calling  pcnet32_init_module+0x0/0x114 @ 1
pcnet32: pcnet32.c:v1.35 21.Apr.2008 tsbogend@alpha.franken.de
initcall pcnet32_init_module+0x0/0x114 returned 0 after 1118 usecs
calling  b44_init+0x0/0x3f @ 1
initcall b44_init+0x0/0x3f returned 0 after 57 usecs
calling  bnx2_pci_driver_init+0x0/0x16 @ 1
initcall bnx2_pci_driver_init+0x0/0x16 returned 0 after 37 usecs
calling  cnic_init+0x0/0x8b @ 1
cnic: Broadcom NetXtreme II CNIC Driver cnic v2.5.18 (Sept 01, 2013)
initcall cnic_init+0x0/0x8b returned 0 after 1371 usecs
calling  tg3_driver_init+0x0/0x16 @ 1
initcall tg3_driver_init+0x0/0x16 returned 0 after 54 usecs
calling  cxgb_pci_driver_init+0x0/0x16 @ 1
initcall cxgb_pci_driver_init+0x0/0x16 returned 0 after 36 usecs
calling  cxgb4_init_module+0x0/0xa9 @ 1
initcall cxgb4_init_module+0x0/0xa9 returned 0 after 136 usecs
calling  dnet_driver_init+0x0/0x11 @ 1
initcall dnet_driver_init+0x0/0x11 returned 0 after 31 usecs
calling  dmfe_init_module+0x0/0xea @ 1
dmfe: Davicom DM9xxx net driver, version 1.36.4 (2002-01-17)
initcall dmfe_init_module+0x0/0xea returned 0 after 1758 usecs
calling  w840_init+0x0/0x23 @ 1
v1.01-e (2.4 port) Sep-11-2006  Donald Becker <becker@scyld.com>
  http://www.scyld.com/network/drivers.html
v1.01-e (2.4 port) Sep-11-2006  Donald Becker <becker@scyld.com>
  http://www.scyld.com/network/drivers.html
initcall w840_init+0x0/0x23 returned 0 after 1263 usecs
calling  de_init+0x0/0x16 @ 1
initcall de_init+0x0/0x16 returned 0 after 36 usecs
calling  tulip_init+0x0/0x2a @ 1
initcall tulip_init+0x0/0x2a returned 0 after 45 usecs
calling  de4x5_module_init+0x0/0x16 @ 1
initcall de4x5_module_init+0x0/0x16 returned 0 after 36 usecs
calling  uli526x_init_module+0x0/0x9e @ 1
uli526x: ULi M5261/M5263 net driver, version 0.9.3 (2005-7-29)
initcall uli526x_init_module+0x0/0x9e returned 0 after 1119 usecs
calling  s2io_starter+0x0/0x16 @ 1
initcall s2io_starter+0x0/0x16 returned 0 after 36 usecs
calling  jme_init_module+0x0/0x2d @ 1
jme: JMicron JMC2XX ethernet driver version 1.0.8
initcall jme_init_module+0x0/0x2d returned 0 after 870 usecs
calling  mlx4_init+0x0/0x12e @ 1
initcall mlx4_init+0x0/0x12e returned 0 after 99 usecs
calling  mlx4_en_init+0x0/0xf @ 1
initcall mlx4_en_init+0x0/0xf returned 0 after 16 usecs
calling  init+0x0/0x5d @ 1
initcall init+0x0/0x5d returned 0 after 83 usecs
calling  ks8851_platform_driver_init+0x0/0x11 @ 1
initcall ks8851_platform_driver_init+0x0/0x11 returned 0 after 36 usecs
calling  pci_device_driver_init+0x0/0x16 @ 1
initcall pci_device_driver_init+0x0/0x16 returned 0 after 38 usecs
calling  fealnx_init+0x0/0x16 @ 1
initcall fealnx_init+0x0/0x16 returned 0 after 36 usecs
calling  natsemi_init_mod+0x0/0x16 @ 1
initcall natsemi_init_mod+0x0/0x16 returned 0 after 36 usecs
calling  forcedeth_pci_driver_init+0x0/0x16 @ 1
forcedeth: Reverse Engineered nForce ethernet driver. Version 0.64.
forcedeth 0000:00:0a.0: setting latency timer to 64
ata5.00: ATA-6: HDS722525VLAT80, V36OA60A, max UDMA/100
ata5.00: 488397168 sectors, multi 1: LBA48=20
ata5: nv_mode_filter: 0x3f39f&0x3f3ff->0x3f39f, BIOS=3D0x3f000 (0xc60000c0)=
 ACPI=3D0x0
ata5.00: configured for UDMA/100
async_waiting @ 112
ata1: SATA link down (SStatus 0 SControl 300)
async_waiting @ 6
async_continuing @ 6 after 4 usec
initcall 2_async_port_probe+0x0/0x49 returned 0 after 1220598 usecs
async_continuing @ 91 after 1210867 usec
ata3: SATA link down (SStatus 0 SControl 300)
async_waiting @ 93
ata2: SATA link down (SStatus 0 SControl 300)
async_waiting @ 91
async_continuing @ 91 after 4 usec
initcall 3_async_port_probe+0x0/0x49 returned 0 after 1514369 usecs
async_continuing @ 93 after 268746 usec
initcall 4_async_port_probe+0x0/0x49 returned 0 after 591892 usecs
async_continuing @ 109 after 581639 usec
forcedeth 0000:00:0a.0: ifname eth0, PHY OUI 0x5043 @ 1, addr 00:13:d4:dc:4=
1:12
forcedeth 0000:00:0a.0: highdma csum gbit lnktim desc-v3
initcall forcedeth_pci_driver_init+0x0/0x16 returned 0 after 514388 usecs
calling  ethoc_driver_init+0x0/0x11 @ 1
initcall ethoc_driver_init+0x0/0x11 returned 0 after 42 usecs
calling  yellowfin_init+0x0/0x16 @ 1
initcall yellowfin_init+0x0/0x16 returned 0 after 45 usecs
calling  sh_eth_driver_init+0x0/0x11 @ 1
initcall sh_eth_driver_init+0x0/0x11 returned 0 after 30 usecs
calling  epic_init+0x0/0x16 @ 1
initcall epic_init+0x0/0x16 returned 0 after 44 usecs
calling  smsc9420_init_module+0x0/0x36 @ 1
initcall smsc9420_init_module+0x0/0x36 returned 0 after 36 usecs
calling  gem_driver_init+0x0/0x16 @ 1
initcall gem_driver_init+0x0/0x16 returned 0 after 36 usecs
calling  cas_init+0x0/0x36 @ 1
initcall cas_init+0x0/0x36 returned 0 after 37 usecs
calling  niu_init+0x0/0x36 @ 1
initcall niu_init+0x0/0x36 returned 0 after 45 usecs
calling  velocity_init_module+0x0/0x48 @ 1
initcall velocity_init_module+0x0/0x48 returned 0 after 62 usecs
calling  xirc2ps_cs_driver_init+0x0/0xf @ 1
initcall xirc2ps_cs_driver_init+0x0/0xf returned 0 after 39 usecs
calling  skfddi_pci_driver_init+0x0/0x16 @ 1
initcall skfddi_pci_driver_init+0x0/0x16 returned 0 after 36 usecs
calling  dmascc_init+0x0/0x89c @ 1
dmascc: autoprobing (dangerous)
dmascc: no adapters found
initcall dmascc_init+0x0/0x89c returned -5 after 52931 usecs
calling  scc_init_driver+0x0/0xa5 @ 1
AX.25: Z8530 SCC driver version 3.0.dl1bke
initcall scc_init_driver+0x0/0xa5 returned 0 after 1870 usecs
calling  mkiss_init_driver+0x0/0x3f @ 1
mkiss: AX.25 Multikiss, Hans Albas PE1AYX
initcall mkiss_init_driver+0x0/0x3f returned 0 after 461 usecs
calling  sixpack_init_driver+0x0/0x3f @ 1
AX.25: 6pack driver, Revision: 0.3.0
initcall sixpack_init_driver+0x0/0x3f returned 0 after 1567 usecs
calling  yam_init_driver+0x0/0x120 @ 1
YAM driver version 0.8 by F1OAT/F6FBB
initcall yam_init_driver+0x0/0x120 returned 0 after 1737 usecs
calling  bpq_init_driver+0x0/0x65 @ 1
AX.25: bpqether driver version 004
initcall bpq_init_driver+0x0/0x65 returned 0 after 252 usecs
calling  init_baycomserfdx+0x0/0x100 @ 1
baycom_ser_fdx: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
baycom_ser_fdx: version 0.10
baycom_ser_fdx: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
baycom_ser_fdx: version 0.10
initcall init_baycomserfdx+0x0/0x100 returned 0 after 2460 usecs
calling  hdlcdrv_init_driver+0x0/0x20 @ 1
hdlcdrv: (C) 1996-2000 Thomas Sailer HB9JNX/AE4WA
hdlcdrv: version 0.8
initcall hdlcdrv_init_driver+0x0/0x20 returned 0 after 1618 usecs
calling  init_baycomserhdx+0x0/0xf3 @ 1
baycom_ser_hdx: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
baycom_ser_hdx: version 0.10
baycom_ser_hdx: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
baycom_ser_hdx: version 0.10
initcall init_baycomserhdx+0x0/0xf3 returned 0 after 1408 usecs
calling  init_baycompar+0x0/0xe5 @ 1
baycom_par: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
baycom_par: version 0.9
baycom_par: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
baycom_par: version 0.9
initcall init_baycompar+0x0/0xe5 returned 0 after 2824 usecs
calling  init_baycomepp+0x0/0x111 @ 1
baycom_epp: (C) 1998-2000 Thomas Sailer, HB9JNX/AE4WA
baycom_epp: version 0.7
baycom_epp: (C) 1998-2000 Thomas Sailer, HB9JNX/AE4WA
baycom_epp: version 0.7
initcall init_baycomepp+0x0/0x111 returned 0 after 1838 usecs
calling  nsc_ircc_init+0x0/0x1d8 @ 1
initcall nsc_ircc_init+0x0/0x1d8 returned -19 after 135 usecs
calling  donauboe_init+0x0/0x16 @ 1
initcall donauboe_init+0x0/0x16 returned 0 after 52 usecs
calling  smsc_ircc_init+0x0/0x4f9 @ 1
initcall smsc_ircc_init+0x0/0x4f9 returned -19 after 162 usecs
calling  vlsi_mod_init+0x0/0x110 @ 1
initcall vlsi_mod_init+0x0/0x110 returned 0 after 53 usecs
calling  via_ircc_init+0x0/0x1c @ 1
initcall via_ircc_init+0x0/0x1c returned 0 after 37 usecs
calling  mcs_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver mcs7780
initcall mcs_driver_init+0x0/0x16 returned 0 after 671 usecs
calling  irtty_sir_init+0x0/0x3c @ 1
initcall irtty_sir_init+0x0/0x3c returned 0 after 4 usecs
calling  sir_wq_init+0x0/0x49 @ 1
initcall sir_wq_init+0x0/0x49 returned 0 after 94 usecs
calling  irda_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver kingsun-sir
initcall irda_driver_init+0x0/0x16 returned 0 after 371 usecs
calling  slip_init+0x0/0xa8 @ 1
SLIP: version 0.8.4-NET3.019-NEWTTY (dynamic channels, max=3D256) (6 bit en=
capsulation enabled).
CSLIP: code copyright 1989 Regents of the University of California.
SLIP linefill/keepalive option.
initcall slip_init+0x0/0xa8 returned 0 after 2324 usecs
calling  init_x25_asy+0x0/0x6c @ 1
x25_asy: X.25 async: version 0.00 ALPHA (dynamic channels, max=3D256)
initcall init_x25_asy+0x0/0x6c returned 0 after 964 usecs
calling  lapbeth_init_driver+0x0/0x28 @ 1
LAPB Ethernet driver version 0.02
initcall lapbeth_init_driver+0x0/0x28 returned 0 after 1059 usecs
calling  ipw2100_init+0x0/0x78 @ 1
ipw2100: Intel(R) PRO/Wireless 2100 Network Driver, git-1.2.2
ipw2100: Copyright(c) 2003-2006 Intel Corporation
initcall ipw2100_init+0x0/0x78 returned 0 after 2832 usecs
calling  ipw_init+0x0/0x73 @ 1
ipw2200: Intel(R) PRO/Wireless 2200/2915 Network Driver, 1.2.2kdmq
ipw2200: Copyright(c) 2003-2006 Intel Corporation
initcall ipw_init+0x0/0x73 returned 0 after 1661 usecs
calling  libipw_init+0x0/0x20 @ 1
libipw: 802.11 data/management/control stack, git-1.1.13
libipw: Copyright (C) 2004-2005 Intel Corporation <jketreno@linux.intel.com>
initcall libipw_init+0x0/0x20 returned 0 after 1573 usecs
calling  init_orinoco+0x0/0x1e @ 1
orinoco 0.15 (David Gibson <hermes@gibson.dropbear.id.au>, Pavel Roskin <pr=
oski@gnu.org>, et al)
initcall init_orinoco+0x0/0x1e returned 0 after 981 usecs
calling  orinoco_driver_init+0x0/0xf @ 1
initcall orinoco_driver_init+0x0/0xf returned 0 after 41 usecs
calling  orinoco_plx_init+0x0/0x2d @ 1
orinoco_plx 0.15 (Pavel Roskin <proski@gnu.org>, David Gibson <hermes@gibso=
n.dropbear.id.au>, Daniel Barlow <dan@telent.net>)
initcall orinoco_plx_init+0x0/0x2d returned 0 after 1052 usecs
calling  orinoco_driver_init+0x0/0xf @ 1
initcall orinoco_driver_init+0x0/0xf returned 0 after 27 usecs
calling  airo_driver_init+0x0/0xf @ 1
initcall airo_driver_init+0x0/0xf returned 0 after 26 usecs
calling  airo_init_module+0x0/0x113 @ 1
airo(): Probing for PCI adapters
airo(): Finished probing for PCI adapters
initcall airo_init_module+0x0/0x113 returned 0 after 2328 usecs
calling  prism54_module_init+0x0/0x35 @ 1
Loaded prism54 driver, version 1.2
initcall prism54_module_init+0x0/0x35 returned 0 after 1268 usecs
calling  hostap_init+0x0/0x40 @ 1
initcall hostap_init+0x0/0x40 returned 0 after 15 usecs
calling  hostap_driver_init+0x0/0xf @ 1
initcall hostap_driver_init+0x0/0xf returned 0 after 32 usecs
calling  prism2_pci_driver_init+0x0/0x16 @ 1
initcall prism2_pci_driver_init+0x0/0x16 returned 0 after 36 usecs
calling  usb_init+0x0/0xf3 @ 1
zd1211rw usb_init()
usbcore: registered new interface driver zd1211rw
zd1211rw initialized
initcall usb_init+0x0/0xf3 returned 0 after 2291 usecs
calling  rtl8180_driver_init+0x0/0x16 @ 1
initcall rtl8180_driver_init+0x0/0x16 returned 0 after 37 usecs
calling  rtl_core_module_init+0x0/0x45 @ 1
initcall rtl_core_module_init+0x0/0x45 returned 0 after 18 usecs
calling  rtl8192cu_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver rtl8192cu
initcall rtl8192cu_driver_init+0x0/0x16 returned 0 after 1009 usecs
calling  rtl92se_driver_init+0x0/0x16 @ 1
initcall rtl92se_driver_init+0x0/0x16 returned 0 after 45 usecs
calling  rtl8723ae_driver_init+0x0/0x16 @ 1
initcall rtl8723ae_driver_init+0x0/0x16 returned 0 after 36 usecs
calling  rtl88ee_driver_init+0x0/0x16 @ 1
initcall rtl88ee_driver_init+0x0/0x16 returned 0 after 43 usecs
calling  wl3501_driver_init+0x0/0xf @ 1
initcall wl3501_driver_init+0x0/0xf returned 0 after 28 usecs
calling  lbtf_init_module+0x0/0xde @ 1
initcall lbtf_init_module+0x0/0xde returned 0 after 58 usecs
calling  adm8211_driver_init+0x0/0x16 @ 1
initcall adm8211_driver_init+0x0/0x16 returned 0 after 84 usecs
calling  mwl8k_driver_init+0x0/0x16 @ 1
initcall mwl8k_driver_init+0x0/0x16 returned 0 after 51 usecs
calling  iwl_drv_init+0x0/0x7b @ 1
Intel(R) Wireless WiFi driver for Linux, in-tree:
Copyright(c) 2003-2013 Intel Corporation
initcall iwl_drv_init+0x0/0x7b returned 0 after 2177 usecs
calling  iwl_init+0x0/0x55 @ 1
initcall iwl_init+0x0/0x55 returned 0 after 20 usecs
calling  iwl_mvm_init+0x0/0x55 @ 1
initcall iwl_mvm_init+0x0/0x55 returned 0 after 4 usecs
calling  il4965_init+0x0/0x6b @ 1
iwl4965: Intel(R) Wireless WiFi 4965 driver for Linux, in-tree:
iwl4965: Copyright(c) 2003-2011 Intel Corporation
initcall il4965_init+0x0/0x6b returned 0 after 2136 usecs
calling  il3945_init+0x0/0x6b @ 1
iwl3945: Intel(R) PRO/Wireless 3945ABG/BG Network Connection driver for Lin=
ux, in-tree:s
iwl3945: Copyright(c) 2003-2011 Intel Corporation
initcall il3945_init+0x0/0x6b returned 0 after 2468 usecs
calling  rt2500pci_driver_init+0x0/0x16 @ 1
initcall rt2500pci_driver_init+0x0/0x16 returned 0 after 36 usecs
calling  rt61pci_driver_init+0x0/0x16 @ 1
initcall rt61pci_driver_init+0x0/0x16 returned 0 after 36 usecs
calling  rt2800pci_init+0x0/0x16 @ 1
initcall rt2800pci_init+0x0/0x16 returned 0 after 39 usecs
calling  rt2800usb_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver rt2800usb
initcall rt2800usb_driver_init+0x0/0x16 returned 0 after 1009 usecs
calling  ath5k_pci_driver_init+0x0/0x16 @ 1
initcall ath5k_pci_driver_init+0x0/0x16 returned 0 after 44 usecs
calling  ath9k_init+0x0/0x39 @ 1
initcall ath9k_init+0x0/0x39 returned 0 after 72 usecs
calling  ath9k_init+0x0/0x7 @ 1
initcall ath9k_init+0x0/0x7 returned 0 after 4 usecs
calling  ath9k_cmn_init+0x0/0x7 @ 1
initcall ath9k_cmn_init+0x0/0x7 returned 0 after 4 usecs
calling  ath9k_htc_init+0x0/0x24 @ 1
usbcore: registered new interface driver ath9k_htc
initcall ath9k_htc_init+0x0/0x24 returned 0 after 1009 usecs
calling  carl9170_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver carl9170
initcall carl9170_driver_init+0x0/0x16 returned 0 after 1816 usecs
calling  ath6kl_sdio_init+0x0/0x2e @ 1
initcall ath6kl_sdio_init+0x0/0x2e returned 0 after 24 usecs
calling  ath6kl_usb_init+0x0/0x36 @ 1
usbcore: registered new interface driver ath6kl_usb
initcall ath6kl_usb_init+0x0/0x36 returned 0 after 1178 usecs
calling  wil6210_driver_init+0x0/0x16 @ 1
initcall wil6210_driver_init+0x0/0x16 returned 0 after 43 usecs
calling  wl12xx_driver_init+0x0/0x11 @ 1
initcall wl12xx_driver_init+0x0/0x11 returned 0 after 29 usecs
calling  brcmfmac_module_init+0x0/0x26 @ 1
initcall brcmfmac_module_init+0x0/0x26 returned 0 after 49 usecs
calling  cw1200_sdio_init+0x0/0x105 @ 1
initcall cw1200_sdio_init+0x0/0x105 returned 0 after 23 usecs
calling  vmxnet3_init_module+0x0/0x35 @ 1
VMware vmxnet3 virtual NIC driver - version 1.2.0.0-k-NAPI
initcall vmxnet3_init_module+0x0/0x35 returned 0 after 1420 usecs
calling  catc_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver catc
initcall catc_driver_init+0x0/0x16 returned 0 after 1138 usecs
calling  pegasus_init+0x0/0x13e @ 1
pegasus: v0.9.3 (2013/04/25), Pegasus/Pegasus II USB Ethernet driver
usbcore: registered new interface driver pegasus
initcall pegasus_init+0x0/0x13e returned 0 after 1795 usecs
calling  rtl8150_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver rtl8150
initcall rtl8150_driver_init+0x0/0x16 returned 0 after 670 usecs
calling  rtl8152_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver r8152
initcall rtl8152_driver_init+0x0/0x16 returned 0 after 1307 usecs
calling  asix_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver asix
initcall asix_driver_init+0x0/0x16 returned 0 after 1139 usecs
calling  ax88179_178a_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver ax88179_178a
initcall ax88179_178a_driver_init+0x0/0x16 returned 0 after 540 usecs
calling  cdc_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver cdc_ether
initcall cdc_driver_init+0x0/0x16 returned 0 after 1009 usecs
calling  r815x_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver r815x
initcall r815x_driver_init+0x0/0x16 returned 0 after 330 usecs
calling  eem_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver cdc_eem
initcall eem_driver_init+0x0/0x16 returned 0 after 671 usecs
calling  dm9601_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver dm9601
initcall dm9601_driver_init+0x0/0x16 returned 0 after 501 usecs
calling  smsc75xx_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver smsc75xx
initcall smsc75xx_driver_init+0x0/0x16 returned 0 after 1816 usecs
calling  smsc95xx_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver smsc95xx
initcall smsc95xx_driver_init+0x0/0x16 returned 0 after 839 usecs
calling  gl620a_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver gl620a
initcall gl620a_driver_init+0x0/0x16 returned 0 after 1478 usecs
calling  net1080_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver net1080
initcall net1080_driver_init+0x0/0x16 returned 0 after 671 usecs
calling  rndis_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver rndis_host
initcall rndis_driver_init+0x0/0x16 returned 0 after 201 usecs
calling  cdc_subset_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver cdc_subset
initcall cdc_subset_driver_init+0x0/0x16 returned 0 after 1178 usecs
calling  zaurus_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver zaurus
initcall zaurus_driver_init+0x0/0x16 returned 0 after 500 usecs
calling  usbnet_init+0x0/0x26 @ 1
initcall usbnet_init+0x0/0x26 returned 0 after 11 usecs
calling  int51x1_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver int51x1
initcall int51x1_driver_init+0x0/0x16 returned 0 after 1646 usecs
calling  kalmia_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver kalmia
initcall kalmia_driver_init+0x0/0x16 returned 0 after 500 usecs
calling  ipheth_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver ipheth
initcall ipheth_driver_init+0x0/0x16 returned 0 after 500 usecs
calling  cx82310_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver cx82310_eth
initcall cx82310_driver_init+0x0/0x16 returned 0 after 1347 usecs
calling  cdc_ncm_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver cdc_ncm
initcall cdc_ncm_driver_init+0x0/0x16 returned 0 after 670 usecs
calling  qmi_wwan_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver qmi_wwan
initcall qmi_wwan_driver_init+0x0/0x16 returned 0 after 840 usecs
calling  cdc_mbim_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver cdc_mbim
initcall cdc_mbim_driver_init+0x0/0x16 returned 0 after 838 usecs
calling  zatm_init_module+0x0/0x16 @ 1
initcall zatm_init_module+0x0/0x16 returned 0 after 51 usecs
calling  uPD98402_module_init+0x0/0x7 @ 1
initcall uPD98402_module_init+0x0/0x7 returned 0 after 4 usecs
calling  nicstar_init+0x0/0x67 @ 1
initcall nicstar_init+0x0/0x67 returned 0 after 36 usecs
calling  hrz_module_init+0x0/0xc6 @ 1
Madge ATM Horizon [Ultra] driver version 1.2.1
initcall hrz_module_init+0x0/0xc6 returned 0 after 1338 usecs
calling  fore200e_module_init+0x0/0x23 @ 1
fore200e: FORE Systems 200E-series ATM driver - version 0.3e
initcall fore200e_module_init+0x0/0x23 returned 0 after 788 usecs
calling  eni_init+0x0/0x16 @ 1
initcall eni_init+0x0/0x16 returned 0 after 36 usecs
calling  idt77252_init+0x0/0x35 @ 1
idt77252_init: at b2d5a532
initcall idt77252_init+0x0/0x35 returned 0 after 1873 usecs
calling  solos_pci_init+0x0/0x2d @ 1
Solos PCI Driver Version 1.04
initcall solos_pci_init+0x0/0x2d returned 0 after 1393 usecs
calling  adummy_init+0x0/0xe6 @ 1
adummy: version 1.0
initcall adummy_init+0x0/0xe6 returned 0 after 749 usecs
calling  he_driver_init+0x0/0x16 @ 1
initcall he_driver_init+0x0/0x16 returned 0 after 37 usecs
calling  lynx_pci_driver_init+0x0/0x16 @ 1
initcall lynx_pci_driver_init+0x0/0x16 returned 0 after 36 usecs
calling  uio_init+0x0/0xd6 @ 1
initcall uio_init+0x0/0xd6 returned 0 after 32 usecs
calling  uio_pdrv_genirq_init+0x0/0x11 @ 1
initcall uio_pdrv_genirq_init+0x0/0x11 returned 0 after 31 usecs
calling  uio_dmem_genirq_init+0x0/0x11 @ 1
initcall uio_dmem_genirq_init+0x0/0x11 returned 0 after 42 usecs
calling  sercos3_pci_driver_init+0x0/0x16 @ 1
initcall sercos3_pci_driver_init+0x0/0x16 returned 0 after 43 usecs
calling  uio_pci_driver_init+0x0/0x16 @ 1
initcall uio_pci_driver_init+0x0/0x16 returned 0 after 36 usecs
calling  mf624_pci_driver_init+0x0/0x16 @ 1
initcall mf624_pci_driver_init+0x0/0x16 returned 0 after 43 usecs
calling  cdrom_init+0x0/0xc @ 1
initcall cdrom_init+0x0/0xc returned 0 after 27 usecs
calling  nonstatic_sysfs_init+0x0/0xf @ 1
initcall nonstatic_sysfs_init+0x0/0xf returned 0 after 4 usecs
calling  yenta_socket_init+0x0/0x16 @ 1
initcall yenta_socket_init+0x0/0x16 returned 0 after 39 usecs
calling  pd6729_module_init+0x0/0x16 @ 1
initcall pd6729_module_init+0x0/0x16 returned 0 after 36 usecs
calling  init_i82365+0x0/0x497 @ 1
Intel ISA PCIC probe: Intel ISA PCIC probe: not found.
not found.
initcall init_i82365+0x0/0x497 returned -19 after 1954 usecs
calling  i82092aa_module_init+0x0/0x16 @ 1
initcall i82092aa_module_init+0x0/0x16 returned 0 after 37 usecs
calling  init_tcic+0x0/0x6b1 @ 1
Databook TCIC-2 PCMCIA probe: Databook TCIC-2 PCMCIA probe: not found.
not found.
initcall init_tcic+0x0/0x6b1 returned -19 after 2282 usecs
calling  mon_init+0x0/0xec @ 1
initcall mon_init+0x0/0xec returned 0 after 217 usecs
calling  ehci_hcd_init+0x0/0xc4 @ 1
ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
initcall ehci_hcd_init+0x0/0xc4 returned 0 after 1397 usecs
calling  ehci_pci_init+0x0/0x62 @ 1
ehci-pci: EHCI PCI platform driver
ehci-pci 0000:00:02.1: setting latency timer to 64
ehci-pci 0000:00:02.1: EHCI Host Controller
ehci-pci 0000:00:02.1: new USB bus registered, assigned bus number 1
ehci-pci 0000:00:02.1: debug port 1
ehci-pci 0000:00:02.1: cache line size of 32 is not supported
ehci-pci 0000:00:02.1: irq 11, io mem 0xfeb00000
ata4: SATA link down (SStatus 0 SControl 300)
async_waiting @ 109
async_continuing @ 109 after 4 usec
initcall 5_async_port_probe+0x0/0x49 returned 0 after 1146508 usecs
async_continuing @ 112 after 904807 usec
ehci-pci 0000:00:02.1: USB 2.0 started, EHCI 1.00
scsi 4:0:0:0: Direct-Access     ATA      HDS722525VLAT80  V36O PQ: 0 ANSI: 5
calling  8_sd_probe_async+0x0/0x1ba @ 91
sd 4:0:0:0: [sda] 488397168 512-byte logical blocks: (250 GB/232 GiB)
hub 1-0:1.0: USB hub found
sd 4:0:0:0: [sda] Write Protect is off
sd 4:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 4:0:0:0: Attached scsi generic sg0 type 0
hub 1-0:1.0: 10 ports detected
initcall 6_async_port_probe+0x0/0x49 returned 0 after 1149272 usecs
async_continuing @ 113 after 1139128 usec
sd 4:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't suppor=
t DPO or FUA
initcall ehci_pci_init+0x0/0x62 returned 0 after 26604 usecs
calling  ehci_platform_init+0x0/0x49 @ 1
ehci-platform: EHCI generic platform driver
initcall ehci_platform_init+0x0/0x49 returned 0 after 1813 usecs
calling  oxu_driver_init+0x0/0x11 @ 1
initcall oxu_driver_init+0x0/0x11 returned 0 after 28 usecs
calling  ohci_hcd_mod_init+0x0/0x84 @ 1
ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
initcall ohci_hcd_mod_init+0x0/0x84 returned 0 after 734 usecs
calling  ohci_platform_init+0x0/0x49 @ 1
ohci-platform: OHCI generic platform driver
initcall ohci_platform_init+0x0/0x49 returned 0 after 1807 usecs
calling  uhci_hcd_init+0x0/0xbb @ 1
uhci_hcd: USB Universal Host Controller Interface driver
initcall uhci_hcd_init+0x0/0xbb returned 0 after 1132 usecs
calling  sl811h_driver_init+0x0/0x11 @ 1
initcall sl811h_driver_init+0x0/0x11 returned 0 after 29 usecs
calling  u132_hcd_init+0x0/0xaf @ 1
driver u132_hcd
initcall u132_hcd_init+0x0/0xaf returned 0 after 2012 usecs
calling  r8a66597_driver_init+0x0/0x11 @ 1
initcall r8a66597_driver_init+0x0/0x11 returned 0 after 29 usecs
calling  isp1760_init+0x0/0x5c @ 1
initcall isp1760_init+0x0/0x5c returned 0 after 162 usecs
calling  ssb_hcd_init+0x0/0x11 @ 1
initcall ssb_hcd_init+0x0/0x11 returned 0 after 31 usecs
calling  fusbh200_hcd_init+0x0/0xae @ 1
fusbh200_hcd: FUSBH200 Host Controller (EHCI) Driver
Warning! fusbh200_hcd should always be loaded before uhci_hcd and ohci_hcd,=
 not after
initcall fusbh200_hcd_init+0x0/0xae returned 0 after 1469 usecs
calling  fotg210_hcd_init+0x0/0xae @ 1
fotg210_hcd: FOTG210 Host Controller (EHCI) Driver
=014Warning! fotg210_hcd should always be loaded before uhci_hcd and ohci_h=
cd, not after
initcall fotg210_hcd_init+0x0/0xae returned 0 after 2277 usecs
calling  c67x00_driver_init+0x0/0x11 @ 1
initcall c67x00_driver_init+0x0/0x11 returned 0 after 29 usecs
calling  acm_init+0x0/0xd8 @ 1
usbcore: registered new interface driver cdc_acm
cdc_acm: USB Abstract Control Model driver for USB modems and ISDN adapters
initcall acm_init+0x0/0xd8 returned 0 after 2002 usecs
calling  usblp_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver usblp
initcall usblp_driver_init+0x0/0x16 returned 0 after 333 usecs
calling  wdm_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver cdc_wdm
initcall wdm_driver_init+0x0/0x16 returned 0 after 1646 usecs
calling  usbtmc_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver usbtmc
initcall usbtmc_driver_init+0x0/0x16 returned 0 after 1478 usecs
calling  usb_storage_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver usb-storage
initcall usb_storage_driver_init+0x0/0x16 returned 0 after 1346 usecs
calling  alauda_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver ums-alauda
initcall alauda_driver_init+0x0/0x16 returned 0 after 1178 usecs
calling  datafab_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver ums-datafab
initcall datafab_driver_init+0x0/0x16 returned 0 after 1348 usecs
calling  ene_ub6250_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver ums_eneub6250
initcall ene_ub6250_driver_init+0x0/0x16 returned 0 after 709 usecs
calling  freecom_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver ums-freecom
initcall freecom_driver_init+0x0/0x16 returned 0 after 1347 usecs
calling  isd200_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver ums-isd200
initcall isd200_driver_init+0x0/0x16 returned 0 after 205 usecs
calling  jumpshot_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver ums-jumpshot
initcall jumpshot_driver_init+0x0/0x16 returned 0 after 539 usecs
calling  realtek_cr_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver ums-realtek
initcall realtek_cr_driver_init+0x0/0x16 returned 0 after 1348 usecs
calling  usb_serial_init+0x0/0x17f @ 1
usbcore: registered new interface driver usbserial
initcall usb_serial_init+0x0/0x17f returned 0 after 1035 usecs
calling  usb_serial_module_init+0x0/0x19 @ 1
usbcore: registered new interface driver ark3116
usbserial: USB Serial support registered for ark3116
initcall usb_serial_module_init+0x0/0x19 returned 0 after 2019 usecs
calling  usb_serial_module_init+0x0/0x19 @ 1
usbcore: registered new interface driver belkin_sa
usbserial: USB Serial support registered for Belkin / Peracom / GoHubs USB =
Serial Adapter
initcall usb_serial_module_init+0x0/0x19 returned 0 after 3737 usecs
calling  usb_serial_module_init+0x0/0x19 @ 1
usbcore: registered new interface driver ch341
usbserial: USB Serial support registered for ch341-uart
initcall usb_serial_module_init+0x0/0x19 returned 0 after 1209 usecs
calling  usb_serial_module_init+0x0/0x19 @ 1
usbcore: registered new interface driver cp210x
usbserial: USB Serial support registered for cp210x
initcall usb_serial_module_init+0x0/0x19 returned 0 after 1681 usecs
calling  usb_serial_module_init+0x0/0x19 @ 1
usbcore: registered new interface driver cyberjack
usbserial: USB Serial support registered for Reiner SCT Cyberjack USB card =
reader
initcall usb_serial_module_init+0x0/0x19 returned 0 after 2382 usecs
calling  usb_serial_module_init+0x0/0x19 @ 1
usbcore: registered new interface driver digi_acceleport
usbserial: USB Serial support registered for Digi 2 port USB adapter
usbserial: USB Serial support registered for Digi 4 port USB adapter
initcall usb_serial_module_init+0x0/0x19 returned 0 after 3299 usecs
calling  usb_serial_module_init+0x0/0x19 @ 1
usbcore: registered new interface driver empeg
usbserial: USB Serial support registered for empeg
initcall usb_serial_module_init+0x0/0x19 returned 0 after 2316 usecs
calling  usb_serial_module_init+0x0/0x19 @ 1
usbcore: registered new interface driver f81232
usbserial: USB Serial support registered for f81232
initcall usb_serial_module_init+0x0/0x19 returned 0 after 1679 usecs
calling  usb_serial_module_init+0x0/0x19 @ 1
usbcore: registered new interface driver ftdi_sio
usbserial: USB Serial support registered for FTDI USB Serial Device
initcall usb_serial_module_init+0x0/0x19 returned 0 after 1807 usecs
calling  usb_serial_module_init+0x0/0x19 @ 1
usbcore: registered new interface driver garmin_gps
usbserial: USB Serial support registered for Garmin GPS usb/tty
initcall usb_serial_module_init+0x0/0x19 returned 0 after 1457 usecs
calling  usb_serial_module_init+0x0/0x19 @ 1
usbcore: registered new interface driver iuu_phoenix
usbserial: USB Serial support registered for iuu_phoenix
initcall usb_serial_module_init+0x0/0x19 returned 0 after 2395 usecs
calling  usb_serial_module_init+0x0/0x19 @ 1
usbcore: registered new interface driver kl5kusb105
usbserial: USB Serial support registered for KL5KUSB105D / PalmConnect
initcall usb_serial_module_init+0x0/0x19 returned 0 after 1666 usecs
calling  usb_serial_module_init+0x0/0x19 @ 1
usbcore: registered new interface driver mct_u232
usbserial: USB Serial support registered for MCT U232
initcall usb_serial_module_init+0x0/0x19 returned 0 after 1379 usecs
calling  usb_serial_module_init+0x0/0x19 @ 1
usbcore: registered new interface driver metro_usb
usbserial: USB Serial support registered for Metrologic USB to Serial
initcall usb_serial_module_init+0x0/0x19 returned 0 after 2304 usecs
calling  usb_serial_module_init+0x0/0x19 @ 1
usbcore: registered new interface driver mos7720
usbserial: USB Serial support registered for Moschip 2 port adapter
initcall usb_serial_module_init+0x0/0x19 returned 0 after 1627 usecs
calling  usb_serial_module_init+0x0/0x19 @ 1
usbcore: registered new interface driver mos7840
usbserial: USB Serial support registered for Moschip 7840/7820 USB Serial D=
river
initcall usb_serial_module_init+0x0/0x19 returned 0 after 1876 usecs
calling  usb_serial_module_init+0x0/0x19 @ 1
usbcore: registered new interface driver navman
usbserial: USB Serial support registered for navman
initcall usb_serial_module_init+0x0/0x19 returned 0 after 1680 usecs
calling  usb_serial_module_init+0x0/0x19 @ 1
usbcore: registered new interface driver opticon
usbserial: USB Serial support registered for opticon
initcall usb_serial_module_init+0x0/0x19 returned 0 after 2018 usecs
calling  usb_serial_module_init+0x0/0x19 @ 1
usbcore: registered new interface driver oti6858
usbserial: USB Serial support registered for oti6858
initcall usb_serial_module_init+0x0/0x19 returned 0 after 2018 usecs
calling  usb_serial_module_init+0x0/0x19 @ 1
usbcore: registered new interface driver pl2303
usbserial: USB Serial support registered for pl2303
initcall usb_serial_module_init+0x0/0x19 returned 0 after 1679 usecs
calling  usb_serial_module_init+0x0/0x19 @ 1
usbcore: registered new interface driver quatech2
usbserial: USB Serial support registered for Quatech 2nd gen USB to Serial =
Driver
initcall usb_serial_module_init+0x0/0x19 returned 0 after 1238 usecs
calling  usb_serial_module_init+0x0/0x19 @ 1
usbcore: registered new interface driver sierra
usbserial: USB Serial support registered for Sierra USB modem
initcall usb_serial_module_init+0x0/0x19 returned 0 after 2397 usecs
calling  usb_serial_module_init+0x0/0x19 @ 1
usbcore: registered new interface driver usb_serial_simple
usbserial: USB Serial support registered for zio
usbserial: USB Serial support registered for funsoft
usbserial: USB Serial support registered for flashloader
usbserial: USB Serial support registered for vivopay
usbserial: USB Serial support registered for moto_modem
usbserial: USB Serial support registered for hp4x
usbserial: USB Serial support registered for suunto
usbserial: USB Serial support registered for siemens_mpi
initcall usb_serial_module_init+0x0/0x19 returned 0 after 8761 usecs
calling  usb_serial_module_init+0x0/0x19 @ 1
usbcore: registered new interface driver ti_usb_3410_5052
usbserial: USB Serial support registered for TI USB 3410 1 port adapter
usbserial: USB Serial support registered for TI USB 5052 2 port adapter
initcall usb_serial_module_init+0x0/0x19 returned 0 after 2533 usecs
calling  usb_serial_module_init+0x0/0x19 @ 1
usbcore: registered new interface driver visor
usbserial: USB Serial support registered for Handspring Visor / Palm OS
usbserial: USB Serial support registered for Sony Clie 5.0
usbserial: USB Serial support registered for Sony Clie 3.5
initcall usb_serial_module_init+0x0/0x19 returned 0 after 4736 usecs
calling  usb_serial_module_init+0x0/0x19 @ 1
usbcore: registered new interface driver wishbone_serial
usbserial: USB Serial support registered for wishbone_serial
initcall usb_serial_module_init+0x0/0x19 returned 0 after 1796 usecs
calling  usb_serial_module_init+0x0/0x19 @ 1
usbcore: registered new interface driver whiteheat
usbserial: USB Serial support registered for Connect Tech - WhiteHEAT - (pr=
erenumeration)
usbserial: USB Serial support registered for Connect Tech - WhiteHEAT
initcall usb_serial_module_init+0x0/0x19 returned 0 after 3078 usecs
calling  usb_serial_module_init+0x0/0x19 @ 1
usbcore: registered new interface driver keyspan_pda
usbserial: USB Serial support registered for Keyspan PDA
usbserial: USB Serial support registered for Xircom / Entregra PGS - (prere=
numeration)
initcall usb_serial_module_init+0x0/0x19 returned 0 after 2662 usecs
calling  usb_serial_module_init+0x0/0x19 @ 1
usbcore: registered new interface driver xsens_mt
usbserial: USB Serial support registered for xsens_mt
initcall usb_serial_module_init+0x0/0x19 returned 0 after 1380 usecs
calling  adu_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver adutux
initcall adu_driver_init+0x0/0x16 returned 0 after 1478 usecs
calling  cypress_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver cypress_cy7c63
initcall cypress_driver_init+0x0/0x16 returned 0 after 1856 usecs
calling  cytherm_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver cytherm
initcall cytherm_driver_init+0x0/0x16 returned 0 after 1646 usecs
calling  emi26_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver emi26 - firmware loader
initcall emi26_driver_init+0x0/0x16 returned 0 after 1427 usecs
calling  emi62_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver emi62 - firmware loader
initcall emi62_driver_init+0x0/0x16 returned 0 after 1425 usecs
calling  ftdi_elan_init+0x0/0x180 @ 1
driver ftdi-elan
ata6.01: ATAPI: DVDRW IDE 16X, VER A079, max UDMA/66
ata6: nv_mode_filter: 0x1f39f&0x73ff->0x739f, BIOS=3D0x7000 (0xc60000c0) AC=
PI=3D0x0
usbcore: registered new interface driver ftdi-elan
initcall ftdi_elan_init+0x0/0x180 returned 0 after 4651 usecs
calling  idmouse_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver idmouse
initcall idmouse_driver_init+0x0/0x16 returned 0 after 1643 usecs
calling  iowarrior_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver iowarrior
initcall iowarrior_driver_init+0x0/0x16 returned 0 after 1009 usecs
calling  lcd_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver usblcd
initcall lcd_driver_init+0x0/0x16 returned 0 after 1477 usecs
calling  ld_usb_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver ldusb
initcall ld_usb_driver_init+0x0/0x16 returned 0 after 330 usecs
calling  led_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver usbled
initcall led_driver_init+0x0/0x16 returned 0 after 1478 usecs
calling  tower_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver legousbtower
initcall tower_driver_init+0x0/0x16 returned 0 after 539 usecs
calling  rio_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver rio500
initcall rio_driver_init+0x0/0x16 returned 0 after 1478 usecs
calling  usbtest_init+0x0/0x54 @ 1
usbcore: registered new interface driver usbtest
initcall usbtest_init+0x0/0x54 returned 0 after 670 usecs
calling  ehset_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver usb_ehset_test
initcall ehset_driver_init+0x0/0x16 returned 0 after 879 usecs
calling  tv_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver trancevibrator
initcall tv_driver_init+0x0/0x16 returned 0 after 878 usecs
calling  uss720_init+0x0/0x52 @ 1
usbcore: registered new interface driver uss720
uss720: v0.6:USB Parport Cable driver for Cables using the Lucent Technolog=
ies USS720 Chip
uss720: NOTE: this is a special purpose driver to allow nonstandard
uss720: protocols (eg. bitbang) over USS720 usb to parallel cables
uss720: If you just want to connect to a printer, use usblp instead
initcall uss720_init+0x0/0x52 returned 0 after 5118 usecs
calling  sevseg_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver usbsevseg
initcall sevseg_driver_init+0x0/0x16 returned 0 after 1009 usecs
calling  usb3503_init+0x0/0x4a @ 1
initcall usb3503_init+0x0/0x4a returned 0 after 76 usecs
calling  usb_sisusb_init+0x0/0x1b @ 1
usbcore: registered new interface driver sisusb
initcall usb_sisusb_init+0x0/0x1b returned 0 after 501 usecs
calling  samsung_usb2phy_driver_init+0x0/0x11 @ 1
initcall samsung_usb2phy_driver_init+0x0/0x11 returned 0 after 29 usecs
calling  samsung_usb3phy_driver_init+0x0/0x11 @ 1
initcall samsung_usb3phy_driver_init+0x0/0x11 returned 0 after 28 usecs
calling  gpio_vbus_driver_init+0x0/0x11 @ 1
initcall gpio_vbus_driver_init+0x0/0x11 returned 0 after 27 usecs
calling  rcar_usb_phy_driver_init+0x0/0x11 @ 1
initcall rcar_usb_phy_driver_init+0x0/0x11 returned 0 after 29 usecs
calling  musb_init+0x0/0x1e @ 1
initcall musb_init+0x0/0x1e returned 0 after 27 usecs
calling  tusb_driver_init+0x0/0x11 @ 1
initcall tusb_driver_init+0x0/0x11 returned 0 after 28 usecs
calling  ci_hdrc_driver_init+0x0/0x11 @ 1
initcall ci_hdrc_driver_init+0x0/0x11 returned 0 after 35 usecs
calling  ci_hdrc_msm_driver_init+0x0/0x11 @ 1
initcall ci_hdrc_msm_driver_init+0x0/0x11 returned 0 after 29 usecs
calling  ci_hdrc_pci_driver_init+0x0/0x16 @ 1
initcall ci_hdrc_pci_driver_init+0x0/0x16 returned 0 after 58 usecs
calling  ci_hdrc_imx_driver_init+0x0/0x11 @ 1
initcall ci_hdrc_imx_driver_init+0x0/0x11 returned 0 after 28 usecs
calling  usbmisc_imx_driver_init+0x0/0x11 @ 1
initcall usbmisc_imx_driver_init+0x0/0x11 returned 0 after 28 usecs
calling  renesas_usbhs_driver_init+0x0/0x11 @ 1
initcall renesas_usbhs_driver_init+0x0/0x11 returned 0 after 28 usecs
calling  gadget_cfs_init+0x0/0x19 @ 1
initcall gadget_cfs_init+0x0/0x19 returned 0 after 25 usecs
calling  init+0x0/0x2e8 @ 1
dummy_hcd dummy_hcd.0: USB Host+Gadget Emulator, driver 02 May 2005
dummy_hcd dummy_hcd.0: Dummy host controller
ata6.01: configured for UDMA/33
dummy_hcd dummy_hcd.0: new USB bus registered, assigned bus number 2
async_waiting @ 113
async_continuing @ 113 after 4 usec
hub 2-0:1.0: USB hub found
scsi 5:0:1:0: CD-ROM            DVDRW    IDE 16X          A079 PQ: 0 ANSI: 5
scsi 5:0:1:0: Attached scsi generic sg1 type 5
hub 2-0:1.0: 1 port detected
initcall 7_async_port_probe+0x0/0x49 returned 0 after 1455987 usecs
initcall init+0x0/0x2e8 returned 0 after 12075 usecs
calling  net2272_init+0x0/0x3c @ 1
initcall net2272_init+0x0/0x3c returned 0 after 94 usecs
calling  udc_pci_driver_init+0x0/0x16 @ 1
initcall udc_pci_driver_init+0x0/0x16 returned 0 after 39 usecs
calling  udc_driver_init+0x0/0x11 @ 1
initcall udc_driver_init+0x0/0x11 returned 0 after 31 usecs
calling  r8a66597_driver_init+0x0/0x14 @ 1
initcall r8a66597_driver_init+0x0/0x14 returned -19 after 49 usecs
calling  ncmmod_init+0x0/0xf @ 1
initcall ncmmod_init+0x0/0xf returned 0 after 18 usecs
calling  init+0x0/0xf @ 1
udc dummy_udc.0: registering UDC driver [g_ncm]
using random self ethernet address
using random host ethernet address
g_ncm gadget: adding config #1 'CDC Ethernet (NCM)'/b2c40ce0
g_ncm gadget: adding 'cdc_network'/eb816f00 to config 'CDC Ethernet (NCM)'/=
b2c40ce0
usb0: HOST MAC aa:99:de:d4:76:38
usb0: MAC 2a:0a:99:90:0a:c2
g_ncm gadget: CDC Network: dual speed IN/ep1in-bulk OUT/ep2out-bulk NOTIFY/=
ep5in-int
g_ncm gadget: cfg 1/b2c40ce0 speeds: high full
g_ncm gadget:   interface 0 =3D cdc_network/eb816f00
g_ncm gadget:   interface 1 =3D cdc_network/eb816f00
g_ncm gadget: NCM Gadget
g_ncm gadget: g_ncm ready
dummy_udc dummy_udc.0: binding gadget driver 'g_ncm'
dummy_hcd dummy_hcd.0: port status 0x00010101 has changes
initcall init+0x0/0xf returned 0 after 15500 usecs
calling  i8042_init+0x0/0x33e @ 1
i8042: PNP: PS/2 Controller [PNP0303] at 0x60,0x64 irq 1
i8042: PNP: PS/2 appears to have AUX port disabled, if this is incorrect pl=
ease boot with i8042.nopnp
serio: i8042 KBD port at 0x60,0x64 irq 1
initcall i8042_init+0x0/0x33e returned 0 after 4027 usecs
calling  parkbd_init+0x0/0x177 @ 1
parport0: cannot grant exclusive access for device parkbd
initcall parkbd_init+0x0/0x177 returned -19 after 241 usecs
calling  serport_init+0x0/0x2c @ 1
initcall serport_init+0x0/0x2c returned 0 after 4 usecs
calling  ct82c710_init+0x0/0x137 @ 1
initcall ct82c710_init+0x0/0x137 returned -19 after 13 usecs
calling  pcips2_driver_init+0x0/0x16 @ 1
initcall pcips2_driver_init+0x0/0x16 returned 0 after 47 usecs
calling  ps2mult_drv_init+0x0/0x16 @ 1
initcall ps2mult_drv_init+0x0/0x16 returned 0 after 29 usecs
calling  altera_ps2_driver_init+0x0/0x11 @ 1
initcall altera_ps2_driver_init+0x0/0x11 returned 0 after 31 usecs
calling  arc_ps2_driver_init+0x0/0x11 @ 1
initcall arc_ps2_driver_init+0x0/0x11 returned 0 after 31 usecs
calling  apbps2_of_driver_init+0x0/0x11 @ 1
initcall apbps2_of_driver_init+0x0/0x11 returned 0 after 30 usecs
calling  olpc_apsp_driver_init+0x0/0x11 @ 1
initcall olpc_apsp_driver_init+0x0/0x11 returned 0 after 44 usecs
calling  fm801_gp_driver_init+0x0/0x16 @ 1
initcall fm801_gp_driver_init+0x0/0x16 returned 0 after 38 usecs
calling  l4_init+0x0/0x27e @ 1
initcall l4_init+0x0/0x27e returned -19 after 15 usecs
calling  ns558_init+0x0/0x2fe @ 1
initcall ns558_init+0x0/0x2fe returned 0 after 7856 usecs
calling  mousedev_init+0x0/0x7c @ 1
mousedev: PS/2 mouse device common for all mice
initcall mousedev_init+0x0/0x7c returned 0 after 1749 usecs
calling  joydev_init+0x0/0xf @ 1
initcall joydev_init+0x0/0xf returned 0 after 4 usecs
calling  evdev_init+0x0/0xf @ 1
initcall evdev_init+0x0/0xf returned 0 after 4 usecs
calling  adp5588_driver_init+0x0/0x11 @ 1
initcall adp5588_driver_init+0x0/0x11 returned 0 after 32 usecs
calling  adp5589_driver_init+0x0/0x11 @ 1
initcall adp5589_driver_init+0x0/0x11 returned 0 after 26 usecs
calling  atkbd_init+0x0/0x16 @ 1
initcall atkbd_init+0x0/0x16 returned 0 after 29 usecs
calling  cros_ec_keyb_driver_init+0x0/0x11 @ 1
initcall cros_ec_keyb_driver_init+0x0/0x11 returned 0 after 40 usecs
calling  events_driver_init+0x0/0x11 @ 1
initcall events_driver_init+0x0/0x11 returned 0 after 29 usecs
calling  gpio_keys_polled_driver_init+0x0/0x11 @ 1
initcall gpio_keys_polled_driver_init+0x0/0x11 returned 0 after 31 usecs
calling  lm8323_i2c_driver_init+0x0/0x11 @ 1
initcall lm8323_i2c_driver_init+0x0/0x11 returned 0 after 26 usecs
calling  lm8333_driver_init+0x0/0x11 @ 1
initcall lm8333_driver_init+0x0/0x11 returned 0 after 26 usecs
calling  matrix_keypad_driver_init+0x0/0x11 @ 1
initcall matrix_keypad_driver_init+0x0/0x11 returned 0 after 30 usecs
calling  max7359_i2c_driver_init+0x0/0x11 @ 1
initcall max7359_i2c_driver_init+0x0/0x11 returned 0 after 27 usecs
calling  mcs_touchkey_driver_init+0x0/0x11 @ 1
initcall mcs_touchkey_driver_init+0x0/0x11 returned 0 after 26 usecs
calling  mpr_touchkey_driver_init+0x0/0x11 @ 1
initcall mpr_touchkey_driver_init+0x0/0x11 returned 0 after 26 usecs
calling  nkbd_drv_init+0x0/0x16 @ 1
initcall nkbd_drv_init+0x0/0x16 returned 0 after 36 usecs
calling  opencores_kbd_device_driver_init+0x0/0x11 @ 1
initcall opencores_kbd_device_driver_init+0x0/0x11 returned 0 after 31 usecs
calling  qt2160_driver_init+0x0/0x11 @ 1
initcall qt2160_driver_init+0x0/0x11 returned 0 after 26 usecs
calling  skbd_drv_init+0x0/0x16 @ 1
initcall skbd_drv_init+0x0/0x16 returned 0 after 28 usecs
calling  sunkbd_drv_init+0x0/0x16 @ 1
initcall sunkbd_drv_init+0x0/0x16 returned 0 after 27 usecs
calling  tc3589x_keypad_driver_init+0x0/0x11 @ 1
initcall tc3589x_keypad_driver_init+0x0/0x11 returned 0 after 45 usecs
calling  twl4030_kp_driver_init+0x0/0x11 @ 1
initcall twl4030_kp_driver_init+0x0/0x11 returned 0 after 31 usecs
calling  xtkbd_drv_init+0x0/0x16 @ 1
initcall xtkbd_drv_init+0x0/0x16 returned 0 after 36 usecs
calling  auo_pixcir_driver_init+0x0/0x11 @ 1
initcall auo_pixcir_driver_init+0x0/0x11 returned 0 after 27 usecs
calling  cy8ctmg110_driver_init+0x0/0x11 @ 1
initcall cy8ctmg110_driver_init+0x0/0x11 returned 0 after 94 usecs
calling  cyttsp_i2c_driver_init+0x0/0x11 @ 1
initcall cyttsp_i2c_driver_init+0x0/0x11 returned 0 after 49 usecs
calling  da9034_touch_driver_init+0x0/0x11 @ 1
initcall da9034_touch_driver_init+0x0/0x11 returned 0 after 31 usecs
calling  dynapro_drv_init+0x0/0x16 @ 1
initcall dynapro_drv_init+0x0/0x16 returned 0 after 27 usecs
calling  hampshire_drv_init+0x0/0x16 @ 1
initcall hampshire_drv_init+0x0/0x16 returned 0 after 27 usecs
calling  gunze_drv_init+0x0/0x16 @ 1
initcall gunze_drv_init+0x0/0x16 returned 0 after 27 usecs
calling  eeti_ts_driver_init+0x0/0x11 @ 1
initcall eeti_ts_driver_init+0x0/0x11 returned 0 after 32 usecs
calling  elo_drv_init+0x0/0x16 @ 1
initcall elo_drv_init+0x0/0x16 returned 0 after 27 usecs
calling  egalax_ts_driver_init+0x0/0x11 @ 1
initcall egalax_ts_driver_init+0x0/0x11 returned 0 after 26 usecs
calling  fujitsu_drv_init+0x0/0x16 @ 1
initcall fujitsu_drv_init+0x0/0x16 returned 0 after 27 usecs
calling  max11801_ts_driver_init+0x0/0x11 @ 1
initcall max11801_ts_driver_init+0x0/0x11 returned 0 after 25 usecs
calling  mcs5000_ts_driver_init+0x0/0x11 @ 1
initcall mcs5000_ts_driver_init+0x0/0x11 returned 0 after 25 usecs
calling  mms114_driver_init+0x0/0x11 @ 1
initcall mms114_driver_init+0x0/0x11 returned 0 after 25 usecs
calling  mtouch_drv_init+0x0/0x16 @ 1
initcall mtouch_drv_init+0x0/0x16 returned 0 after 27 usecs
calling  mk712_init+0x0/0x1c1 @ 1
mk712: device not present
initcall mk712_init+0x0/0x1c1 returned -19 after 683 usecs
calling  htcpen_isa_init+0x0/0xa @ 1
initcall htcpen_isa_init+0x0/0xa returned -19 after 4 usecs
calling  usbtouch_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver usbtouchscreen
initcall usbtouch_driver_init+0x0/0x16 returned 0 after 879 usecs
calling  ti_tsc_driver_init+0x0/0x11 @ 1
initcall ti_tsc_driver_init+0x0/0x11 returned 0 after 29 usecs
calling  touchit213_drv_init+0x0/0x16 @ 1
initcall touchit213_drv_init+0x0/0x16 returned 0 after 39 usecs
calling  tr_drv_init+0x0/0x16 @ 1
initcall tr_drv_init+0x0/0x16 returned 0 after 28 usecs
calling  tw_drv_init+0x0/0x16 @ 1
initcall tw_drv_init+0x0/0x16 returned 0 after 27 usecs
calling  tsc2007_driver_init+0x0/0x11 @ 1
initcall tsc2007_driver_init+0x0/0x11 returned 0 after 26 usecs
calling  w8001_drv_init+0x0/0x16 @ 1
initcall w8001_drv_init+0x0/0x16 returned 0 after 34 usecs
calling  wacom_i2c_driver_init+0x0/0x11 @ 1
initcall wacom_i2c_driver_init+0x0/0x11 returned 0 after 27 usecs
calling  wm831x_ts_driver_init+0x0/0x11 @ 1
initcall wm831x_ts_driver_init+0x0/0x11 returned 0 after 31 usecs
calling  tps6507x_ts_driver_init+0x0/0x11 @ 1
initcall tps6507x_ts_driver_init+0x0/0x11 returned 0 after 30 usecs
calling  pm860x_onkey_driver_init+0x0/0x11 @ 1
initcall pm860x_onkey_driver_init+0x0/0x11 returned 0 after 31 usecs
calling  bma150_driver_init+0x0/0x11 @ 1
initcall bma150_driver_init+0x0/0x11 returned 0 after 26 usecs
calling  gp2a_i2c_driver_init+0x0/0x11 @ 1
initcall gp2a_i2c_driver_init+0x0/0x11 returned 0 after 25 usecs
calling  gpio_tilt_polled_driver_init+0x0/0x11 @ 1
initcall gpio_tilt_polled_driver_init+0x0/0x11 returned 0 after 31 usecs
calling  keyspan_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver keyspan_remote
initcall keyspan_driver_init+0x0/0x16 returned 0 after 879 usecs
calling  mpu3050_i2c_driver_init+0x0/0x11 @ 1
initcall mpu3050_i2c_driver_init+0x0/0x11 returned 0 after 33 usecs
calling  pcf50633_input_driver_init+0x0/0x11 @ 1
initcall pcf50633_input_driver_init+0x0/0x11 returned 0 after 30 usecs
calling  pcf8574_kp_driver_init+0x0/0x11 @ 1
initcall pcf8574_kp_driver_init+0x0/0x11 returned 0 after 32 usecs
calling  powermate_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver powermate
initcall powermate_driver_init+0x0/0x16 returned 0 after 1008 usecs
calling  twl4030_pwrbutton_driver_init+0x0/0x14 @ 1
initcall twl4030_pwrbutton_driver_init+0x0/0x14 returned -19 after 49 usecs
calling  twl4030_vibra_driver_init+0x0/0x11 @ 1
initcall twl4030_vibra_driver_init+0x0/0x11 returned 0 after 30 usecs
calling  twl6040_vibra_driver_init+0x0/0x11 @ 1
initcall twl6040_vibra_driver_init+0x0/0x11 returned 0 after 31 usecs
calling  uinput_init+0x0/0xf @ 1
gameport gameport0: NS558 PnP Gameport is pnp00:10/gameport0, io 0x201, spe=
ed 903kHz
dummy_hcd dummy_hcd.0: port status 0x00010101 has changes
initcall uinput_init+0x0/0xf returned 0 after 17685 usecs
calling  wm831x_on_driver_init+0x0/0x11 @ 1
initcall wm831x_on_driver_init+0x0/0x11 returned 0 after 36 usecs
calling  slidebar_init+0x0/0xab @ 1
ideapad_slidebar: DMI does not match
initcall slidebar_init+0x0/0xab returned -19 after 591 usecs
calling  i2o_iop_init+0x0/0x45 @ 1
I2O subsystem v1.325
i2o: max drivers =3D 8
 sda: sda1 sda2 sda3 < sda5 sda6 sda7 sda8 sda9 sda10 >
initcall i2o_iop_init+0x0/0x45 returned 0 after 3704 usecs
calling  i2o_config_init+0x0/0x3f @ 1
I2O Configuration OSM v1.323
initcall i2o_config_init+0x0/0x3f returned 0 after 1217 usecs
calling  i2o_bus_init+0x0/0x3e @ 1
I2O Bus Adapter OSM v1.317
initcall i2o_bus_init+0x0/0x3e returned 0 after 858 usecs
calling  i2o_scsi_init+0x0/0x3e @ 1
I2O SCSI Peripheral OSM v1.316
initcall i2o_scsi_init+0x0/0x3e returned 0 after 1550 usecs
calling  i2o_proc_init+0x0/0x169 @ 1
I2O ProcFS OSM v1.316
initcall i2o_proc_init+0x0/0x169 returned 0 after 1018 usecs
calling  pm80x_rtc_driver_init+0x0/0x11 @ 1
initcall pm80x_rtc_driver_init+0x0/0x11 returned 0 after 35 usecs
calling  bq32k_driver_init+0x0/0x11 @ 1
initcall bq32k_driver_init+0x0/0x11 returned 0 after 31 usecs
calling  cmos_init+0x0/0x5e @ 1
rtc_cmos 00:03: rtc core: registered rtc_cmos as rtc0
rtc_cmos 00:03: alarms up to one day, 114 bytes nvram
initcall cmos_init+0x0/0x5e returned 0 after 2174 usecs
calling  ds1286_platform_driver_init+0x0/0x11 @ 1
initcall ds1286_platform_driver_init+0x0/0x11 returned 0 after 31 usecs
calling  ds1307_driver_init+0x0/0x11 @ 1
initcall ds1307_driver_init+0x0/0x11 returned 0 after 52 usecs
calling  ds1374_driver_init+0x0/0x11 @ 1
initcall ds1374_driver_init+0x0/0x11 returned 0 after 26 usecs
calling  ds1511_rtc_driver_init+0x0/0x11 @ 1
initcall ds1511_rtc_driver_init+0x0/0x11 returned 0 after 30 usecs
calling  ds1672_driver_init+0x0/0x11 @ 1
initcall ds1672_driver_init+0x0/0x11 returned 0 after 26 usecs
calling  ds1742_rtc_driver_init+0x0/0x11 @ 1
initcall ds1742_rtc_driver_init+0x0/0x11 returned 0 after 30 usecs
calling  ds3232_driver_init+0x0/0x11 @ 1
initcall ds3232_driver_init+0x0/0x11 returned 0 after 33 usecs
calling  em3027_driver_init+0x0/0x11 @ 1
initcall em3027_driver_init+0x0/0x11 returned 0 after 32 usecs
calling  fm3130_driver_init+0x0/0x11 @ 1
initcall fm3130_driver_init+0x0/0x11 returned 0 after 25 usecs
calling  hid_time_platform_driver_init+0x0/0x11 @ 1
initcall hid_time_platform_driver_init+0x0/0x11 returned 0 after 31 usecs
calling  isl1208_driver_init+0x0/0x11 @ 1
initcall isl1208_driver_init+0x0/0x11 returned 0 after 27 usecs
calling  isl12022_driver_init+0x0/0x11 @ 1
initcall isl12022_driver_init+0x0/0x11 returned 0 after 26 usecs
calling  lp8788_rtc_driver_init+0x0/0x11 @ 1
initcall lp8788_rtc_driver_init+0x0/0x11 returned 0 after 30 usecs
calling  m48t35_platform_driver_init+0x0/0x11 @ 1
initcall m48t35_platform_driver_init+0x0/0x11 returned 0 after 30 usecs
calling  m48t86_rtc_platform_driver_init+0x0/0x11 @ 1
initcall m48t86_rtc_platform_driver_init+0x0/0x11 returned 0 after 30 usecs
calling  max6900_driver_init+0x0/0x11 @ 1
initcall max6900_driver_init+0x0/0x11 returned 0 after 34 usecs
calling  msm6242_rtc_driver_init+0x0/0x14 @ 1
initcall msm6242_rtc_driver_init+0x0/0x14 returned -19 after 62 usecs
calling  pcf2127_driver_init+0x0/0x11 @ 1
initcall pcf2127_driver_init+0x0/0x11 returned 0 after 26 usecs
calling  pcf8523_driver_init+0x0/0x11 @ 1
initcall pcf8523_driver_init+0x0/0x11 returned 0 after 27 usecs
calling  pcf50633_rtc_driver_init+0x0/0x11 @ 1
initcall pcf50633_rtc_driver_init+0x0/0x11 returned 0 after 31 usecs
calling  rs5c372_driver_init+0x0/0x11 @ 1
initcall rs5c372_driver_init+0x0/0x11 returned 0 after 27 usecs
calling  rv3029c2_driver_init+0x0/0x11 @ 1
initcall rv3029c2_driver_init+0x0/0x11 returned 0 after 26 usecs
calling  rx8581_driver_init+0x0/0x11 @ 1
initcall rx8581_driver_init+0x0/0x11 returned 0 after 26 usecs
calling  snvs_rtc_driver_init+0x0/0x11 @ 1
initcall snvs_rtc_driver_init+0x0/0x11 returned 0 after 31 usecs
calling  test_init+0x0/0xa2 @ 1
rtc-test rtc-test.0: rtc core: registered test as rtc1
rtc-test rtc-test.1: rtc core: registered test as rtc2
initcall test_init+0x0/0xa2 returned 0 after 1551 usecs
calling  twl4030rtc_driver_init+0x0/0x11 @ 1
initcall twl4030rtc_driver_init+0x0/0x11 returned 0 after 31 usecs
calling  tps65910_rtc_driver_init+0x0/0x11 @ 1
initcall tps65910_rtc_driver_init+0x0/0x11 returned 0 after 31 usecs
calling  rtc_device_driver_init+0x0/0x11 @ 1
initcall rtc_device_driver_init+0x0/0x11 returned 0 after 31 usecs
calling  wm831x_rtc_driver_init+0x0/0x11 @ 1
initcall wm831x_rtc_driver_init+0x0/0x11 returned 0 after 37 usecs
calling  x1205_driver_init+0x0/0x11 @ 1
initcall x1205_driver_init+0x0/0x11 returned 0 after 27 usecs
calling  moxart_rtc_driver_init+0x0/0x11 @ 1
initcall moxart_rtc_driver_init+0x0/0x11 returned 0 after 31 usecs
calling  smbalert_driver_init+0x0/0x11 @ 1
initcall smbalert_driver_init+0x0/0x11 returned 0 after 27 usecs
calling  i2c_dev_init+0x0/0xb8 @ 1
i2c /dev entries driver
initcall i2c_dev_init+0x0/0xb8 returned 0 after 1356 usecs
calling  ali1535_driver_init+0x0/0x16 @ 1
initcall ali1535_driver_init+0x0/0x16 returned 0 after 47 usecs
calling  amd756_driver_init+0x0/0x16 @ 1
initcall amd756_driver_init+0x0/0x16 returned 0 after 45 usecs
calling  amd756_s4882_init+0x0/0x261 @ 1
initcall amd756_s4882_init+0x0/0x261 returned -19 after 4 usecs
calling  i2c_i801_init+0x0/0x16 @ 1
initcall i2c_i801_init+0x0/0x16 returned 0 after 55 usecs
calling  smbus_sch_driver_init+0x0/0x11 @ 1
initcall smbus_sch_driver_init+0x0/0x11 returned 0 after 38 usecs
calling  ismt_driver_init+0x0/0x16 @ 1
initcall ismt_driver_init+0x0/0x16 returned 0 after 38 usecs
calling  nforce2_driver_init+0x0/0x16 @ 1
sd 4:0:0:0: [sda] Attached SCSI disk
initcall 8_sd_probe_async+0x0/0x1ba returned 0 after 655420 usecs
i2c i2c-0: Transaction failed (0x10)!
i2c i2c-0: nForce2 SMBus adapter at 0x4c00
i2c i2c-1: Transaction failed (0x10)!
g_ncm gadget: resume
dummy_hcd dummy_hcd.0: port status 0x00100503 has changes
i2c i2c-1: Transaction failed (0x10)!
i2c i2c-1: nForce2 SMBus adapter at 0x4c40
initcall nforce2_driver_init+0x0/0x16 returned 0 after 54017 usecs
calling  nforce2_s4985_init+0x0/0x26d @ 1
i2c i2c-0: Transaction failed (0x10)!
i2c i2c-0: PCA9556 configuration failed
initcall nforce2_s4985_init+0x0/0x26d returned -5 after 4239 usecs
calling  piix4_driver_init+0x0/0x16 @ 1
initcall piix4_driver_init+0x0/0x16 returned 0 after 54 usecs
calling  i2c_sis5595_init+0x0/0x16 @ 1
initcall i2c_sis5595_init+0x0/0x16 returned 0 after 46 usecs
calling  sis630_driver_init+0x0/0x16 @ 1
initcall sis630_driver_init+0x0/0x16 returned 0 after 39 usecs
calling  vt586b_driver_init+0x0/0x16 @ 1
initcall vt586b_driver_init+0x0/0x16 returned 0 after 45 usecs
calling  i2c_vt596_init+0x0/0x16 @ 1
initcall i2c_vt596_init+0x0/0x16 returned 0 after 40 usecs
calling  dw_i2c_driver_init+0x0/0x16 @ 1
initcall dw_i2c_driver_init+0x0/0x16 returned 0 after 39 usecs
calling  pch_pcidriver_init+0x0/0x16 @ 1
initcall pch_pcidriver_init+0x0/0x16 returned 0 after 38 usecs
calling  kempld_i2c_driver_init+0x0/0x11 @ 1
initcall kempld_i2c_driver_init+0x0/0x11 returned 0 after 52 usecs
calling  i2c_pca_pf_driver_init+0x0/0x11 @ 1
initcall i2c_pca_pf_driver_init+0x0/0x11 returned 0 after 31 usecs
calling  simtec_i2c_driver_init+0x0/0x11 @ 1
initcall simtec_i2c_driver_init+0x0/0x11 returned 0 after 31 usecs
calling  xiic_i2c_driver_init+0x0/0x11 @ 1
initcall xiic_i2c_driver_init+0x0/0x11 returned 0 after 31 usecs
calling  diolan_u2c_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver i2c-diolan-u2c
initcall diolan_u2c_driver_init+0x0/0x16 returned 0 after 877 usecs
calling  i2c_parport_init+0x0/0x4a @ 1
i2c-parport: adapter type unspecified
initcall i2c_parport_init+0x0/0x4a returned -19 after 759 usecs
calling  i2c_parport_init+0x0/0x15d @ 1
i2c-parport-light: adapter type unspecified
initcall i2c_parport_init+0x0/0x15d returned -19 after 800 usecs
calling  taos_init+0x0/0x16 @ 1
initcall taos_init+0x0/0x16 returned 0 after 33 usecs
calling  i2c_tiny_usb_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver i2c-tiny-usb
initcall i2c_tiny_usb_driver_init+0x0/0x16 returned 0 after 1529 usecs
calling  scx200_acb_init+0x0/0x7b @ 1
scx200_acb: NatSemi SCx200 ACCESS.bus Driver
initcall scx200_acb_init+0x0/0x7b returned 0 after 1005 usecs
calling  msp_driver_init+0x0/0x11 @ 1
initcall msp_driver_init+0x0/0x11 returned 0 after 59 usecs
calling  tda7432_driver_init+0x0/0x11 @ 1
initcall tda7432_driver_init+0x0/0x11 returned 0 after 28 usecs
calling  tda9840_driver_init+0x0/0x11 @ 1
initcall tda9840_driver_init+0x0/0x11 returned 0 after 28 usecs
calling  tea6415c_driver_init+0x0/0x11 @ 1
initcall tea6415c_driver_init+0x0/0x11 returned 0 after 28 usecs
calling  saa711x_driver_init+0x0/0x11 @ 1
initcall saa711x_driver_init+0x0/0x11 returned 0 after 29 usecs
calling  saa717x_driver_init+0x0/0x11 @ 1
initcall saa717x_driver_init+0x0/0x11 returned 0 after 27 usecs
calling  saa7127_driver_init+0x0/0x11 @ 1
initcall saa7127_driver_init+0x0/0x11 returned 0 after 29 usecs
calling  saa7185_driver_init+0x0/0x11 @ 1
initcall saa7185_driver_init+0x0/0x11 returned 0 after 27 usecs
calling  saa7191_driver_init+0x0/0x11 @ 1
initcall saa7191_driver_init+0x0/0x11 returned 0 after 27 usecs
calling  adv7343_driver_init+0x0/0x11 @ 1
initcall adv7343_driver_init+0x0/0x11 returned 0 after 36 usecs
calling  adv7393_driver_init+0x0/0x11 @ 1
initcall adv7393_driver_init+0x0/0x11 returned 0 after 28 usecs
calling  vpx3220_driver_init+0x0/0x11 @ 1
initcall vpx3220_driver_init+0x0/0x11 returned 0 after 43 usecs
calling  bt819_driver_init+0x0/0x11 @ 1
initcall bt819_driver_init+0x0/0x11 returned 0 after 28 usecs
calling  ks0127_driver_init+0x0/0x11 @ 1
initcall ks0127_driver_init+0x0/0x11 returned 0 after 28 usecs
calling  ths7303_driver_init+0x0/0x11 @ 1
initcall ths7303_driver_init+0x0/0x11 returned 0 after 29 usecs
calling  ths8200_driver_init+0x0/0x11 @ 1
initcall ths8200_driver_init+0x0/0x11 returned 0 after 46 usecs
calling  tvp5150_driver_init+0x0/0x11 @ 1
initcall tvp5150_driver_init+0x0/0x11 returned 0 after 28 usecs
calling  tw2804_driver_init+0x0/0x11 @ 1
initcall tw2804_driver_init+0x0/0x11 returned 0 after 29 usecs
calling  tw9903_driver_init+0x0/0x11 @ 1
initcall tw9903_driver_init+0x0/0x11 returned 0 after 107 usecs
calling  tw9906_driver_init+0x0/0x11 @ 1
initcall tw9906_driver_init+0x0/0x11 returned 0 after 45 usecs
calling  cs53l32a_driver_init+0x0/0x11 @ 1
initcall cs53l32a_driver_init+0x0/0x11 returned 0 after 36 usecs
calling  m52790_driver_init+0x0/0x11 @ 1
initcall m52790_driver_init+0x0/0x11 returned 0 after 27 usecs
calling  tlv320aic23b_driver_init+0x0/0x11 @ 1
initcall tlv320aic23b_driver_init+0x0/0x11 returned 0 after 28 usecs
calling  uda1342_driver_init+0x0/0x11 @ 1
initcall uda1342_driver_init+0x0/0x11 returned 0 after 27 usecs
calling  wm8775_driver_init+0x0/0x11 @ 1
initcall wm8775_driver_init+0x0/0x11 returned 0 after 27 usecs
calling  wm8739_driver_init+0x0/0x11 @ 1
initcall wm8739_driver_init+0x0/0x11 returned 0 after 27 usecs
calling  vp27smpx_driver_init+0x0/0x11 @ 1
initcall vp27smpx_driver_init+0x0/0x11 returned 0 after 36 usecs
calling  upd64031a_driver_init+0x0/0x11 @ 1
initcall upd64031a_driver_init+0x0/0x11 returned 0 after 27 usecs
calling  upd64083_driver_init+0x0/0x11 @ 1
initcall upd64083_driver_init+0x0/0x11 returned 0 after 34 usecs
calling  ml86v7667_i2c_driver_init+0x0/0x11 @ 1
initcall ml86v7667_i2c_driver_init+0x0/0x11 returned 0 after 27 usecs
calling  au8522_driver_init+0x0/0x11 @ 1
initcall au8522_driver_init+0x0/0x11 returned 0 after 27 usecs
calling  flexcop_module_init+0x0/0x14 @ 1
b2c2-flexcop: B2C2 FlexcopII/II(b)/III digital TV receiver chip loaded succ=
essfully
initcall flexcop_module_init+0x0/0x14 returned 0 after 735 usecs
calling  saa7146_vv_init_module+0x0/0x7 @ 1
initcall saa7146_vv_init_module+0x0/0x7 returned 0 after 4 usecs
calling  smscore_module_init+0x0/0x6b @ 1
initcall smscore_module_init+0x0/0x6b returned 0 after 4 usecs
calling  smsdvb_module_init+0x0/0x5f @ 1
initcall smsdvb_module_init+0x0/0x5f returned 0 after 47 usecs
calling  budget_init+0x0/0xf @ 1
saa7146: register extension 'budget dvb'
initcall budget_init+0x0/0xf returned 0 after 329 usecs
calling  budget_av_init+0x0/0xf @ 1
saa7146: register extension 'budget_av'
initcall budget_av_init+0x0/0xf returned 0 after 1134 usecs
calling  av7110_init+0x0/0xf @ 1
saa7146: register extension 'av7110'
initcall av7110_init+0x0/0xf returned 0 after 1603 usecs
calling  flexcop_pci_driver_init+0x0/0x16 @ 1
initcall flexcop_pci_driver_init+0x0/0x16 returned 0 after 38 usecs
calling  pluto2_driver_init+0x0/0x16 @ 1
initcall pluto2_driver_init+0x0/0x16 returned 0 after 43 usecs
calling  pt1_driver_init+0x0/0x16 @ 1
initcall pt1_driver_init+0x0/0x16 returned 0 after 37 usecs
calling  module_init_ngene+0x0/0x23 @ 1
nGene PCIE bridge driver, Copyright (C) 2005-2007 Micronas
initcall module_init_ngene+0x0/0x23 returned 0 after 443 usecs
calling  module_init_ddbridge+0x0/0xa1 @ 1
Digital Devices PCIE bridge driver, Copyright (C) 2010-11 Digital Devices G=
mbH
initcall module_init_ddbridge+0x0/0xa1 returned 0 after 927 usecs
calling  cx25821_init+0x0/0x3d @ 1
cx25821: driver version 0.0.106 loaded
initcall cx25821_init+0x0/0x3d returned 0 after 963 usecs
calling  ttusb_dec_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver ttusb-dec
initcall ttusb_dec_driver_init+0x0/0x16 returned 0 after 1010 usecs
calling  ttusb_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver ttusb
initcall ttusb_driver_init+0x0/0x16 returned 0 after 331 usecs
calling  au0828_init+0x0/0xb5 @ 1
au0828 driver loaded
usbcore: registered new interface driver au0828
initcall au0828_init+0x0/0xb5 returned 0 after 2289 usecs
calling  smssdio_module_init+0x0/0x28 @ 1
smssdio: Siano SMS1xxx SDIO driver
smssdio: Copyright Pierre Ossman
initcall smssdio_module_init+0x0/0x28 returned 0 after 2140 usecs
calling  pps_ktimer_init+0x0/0x92 @ 1
usb 2-1: new high-speed USB device number 2 using dummy_hcd
pps pps0: new PPS source ktimer
pps pps0: ktimer PPS source registered
initcall pps_ktimer_init+0x0/0x92 returned 0 after 3272 usecs
calling  pps_tty_init+0x0/0x94 @ 1
pps_ldisc: PPS line discipline registered
initcall pps_tty_init+0x0/0x94 returned 0 after 460 usecs
calling  pps_gpio_driver_init+0x0/0x11 @ 1
initcall pps_gpio_driver_init+0x0/0x11 returned 0 after 63 usecs
calling  pda_power_pdrv_init+0x0/0x11 @ 1
initcall pda_power_pdrv_init+0x0/0x11 returned 0 after 38 usecs
calling  wm8350_power_driver_init+0x0/0x11 @ 1
initcall wm8350_power_driver_init+0x0/0x11 returned 0 after 31 usecs
calling  pm860x_battery_driver_init+0x0/0x11 @ 1
initcall pm860x_battery_driver_init+0x0/0x11 returned 0 after 31 usecs
calling  goldfish_battery_device_init+0x0/0x11 @ 1
initcall goldfish_battery_device_init+0x0/0x11 returned 0 after 31 usecs
calling  sbs_battery_driver_init+0x0/0x11 @ 1
initcall sbs_battery_driver_init+0x0/0x11 returned 0 after 34 usecs
calling  bq27x00_battery_init+0x0/0x7 @ 1
initcall bq27x00_battery_init+0x0/0x7 returned 0 after 4 usecs
calling  da903x_battery_driver_init+0x0/0x11 @ 1
initcall da903x_battery_driver_init+0x0/0x11 returned 0 after 31 usecs
calling  max17040_i2c_driver_init+0x0/0x11 @ 1
initcall max17040_i2c_driver_init+0x0/0x11 returned 0 after 45 usecs
calling  twl4030_madc_battery_driver_init+0x0/0x11 @ 1
initcall twl4030_madc_battery_driver_init+0x0/0x11 returned 0 after 31 usecs
calling  pm860x_charger_driver_init+0x0/0x11 @ 1
initcall pm860x_charger_driver_init+0x0/0x11 returned 0 after 31 usecs
calling  pcf50633_mbc_driver_init+0x0/0x11 @ 1
initcall pcf50633_mbc_driver_init+0x0/0x11 returned 0 after 38 usecs
calling  rx51_battery_driver_init+0x0/0x11 @ 1
initcall rx51_battery_driver_init+0x0/0x11 returned 0 after 31 usecs
calling  twl4030_bci_driver_init+0x0/0x14 @ 1
initcall twl4030_bci_driver_init+0x0/0x14 returned -19 after 49 usecs
calling  lp8727_driver_init+0x0/0x11 @ 1
initcall lp8727_driver_init+0x0/0x11 returned 0 after 29 usecs
calling  lp8788_charger_driver_init+0x0/0x11 @ 1
initcall lp8788_charger_driver_init+0x0/0x11 returned 0 after 31 usecs
calling  gpio_charger_driver_init+0x0/0x11 @ 1
initcall gpio_charger_driver_init+0x0/0x11 returned 0 after 46 usecs
calling  bq2415x_driver_init+0x0/0x11 @ 1
initcall bq2415x_driver_init+0x0/0x11 returned 0 after 29 usecs
calling  bq24190_driver_init+0x0/0x11 @ 1
initcall bq24190_driver_init+0x0/0x11 returned 0 after 28 usecs
calling  smb347_driver_init+0x0/0x11 @ 1
initcall smb347_driver_init+0x0/0x11 returned 0 after 28 usecs
calling  tps65090_charger_driver_init+0x0/0x11 @ 1
initcall tps65090_charger_driver_init+0x0/0x11 returned 0 after 31 usecs
calling  asb100_driver_init+0x0/0x11 @ 1
i2c i2c-0: Transaction failed (0x10)!
i2c i2c-1: Transaction failed (0x10)!
initcall asb100_driver_init+0x0/0x11 returned 0 after 6270 usecs
calling  sensors_w83627hf_init+0x0/0x12e @ 1
initcall sensors_w83627hf_init+0x0/0x12e returned -19 after 20 usecs
calling  w83793_driver_init+0x0/0x11 @ 1
i2c i2c-0: Transaction failed (0x10)!
i2c i2c-1: Transaction failed (0x10)!
initcall w83793_driver_init+0x0/0x11 returned 0 after 23535 usecs
calling  w83795_driver_init+0x0/0x11 @ 1
i2c i2c-0: Transaction failed (0x10)!
i2c i2c-1: Transaction failed (0x10)!
g_ncm gadget: resume
dummy_hcd dummy_hcd.0: port status 0x00100503 has changes
i2c i2c-1: Transaction failed (0x10)!
initcall w83795_driver_init+0x0/0x11 returned 0 after 23502 usecs
calling  w83791d_driver_init+0x0/0x11 @ 1
i2c i2c-0: Transaction failed (0x10)!
i2c i2c-1: Transaction failed (0x10)!
initcall w83791d_driver_init+0x0/0x11 returned 0 after 23331 usecs
calling  ad7418_driver_init+0x0/0x11 @ 1
initcall ad7418_driver_init+0x0/0x11 returned 0 after 30 usecs
calling  adm1021_driver_init+0x0/0x11 @ 1
i2c i2c-0: Transaction failed (0x10)!
dummy_udc dummy_udc.0: set_address =3D 2
i2c i2c-0: Transaction failed (0x10)!
i2c i2c-1: Transaction failed (0x10)!
g_ncm gadget: high-speed config #1: CDC Ethernet (NCM)
g_ncm gadget: init ncm ctrl 0
dummy_udc dummy_udc.0: enabled ep5in-int (ep5in-intr) maxpacket 16 stream d=
isabled
g_ncm gadget: notify speed 425984000
g_ncm gadget: notify connect false
i2c i2c-1: Transaction failed (0x10)!
g_ncm gadget: ncm reqa1.80 v0000 i0000 l28
g_ncm gadget: non-CRC mode selected
g_ncm gadget: ncm req21.8a v0000 i0000 l0
i2c i2c-1: Transaction failed (0x10)!
g_ncm gadget: NCM16 selected
g_ncm gadget: ncm req21.84 v0000 i0000 l0
g_ncm gadget: init ncm
g_ncm gadget: activate ncm
dummy_udc dummy_udc.0: enabled ep1in-bulk (ep1in-bulk) maxpacket 512 stream=
 disabled
dummy_udc dummy_udc.0: enabled ep2out-bulk (ep2out-bulk) maxpacket 512 stre=
am disabled
usb0: qlen 10
g_ncm gadget: ncm_close
i2c i2c-1: Transaction failed (0x10)!
usb 2-1: MAC-Address: aa:99:de:d4:76:38
cdc_ncm 2-1:1.0 usb1: register 'cdc_ncm' at usb-dummy_hcd.0-1, CDC NCM, aa:=
99:de:d4:76:38
i2c i2c-1: Transaction failed (0x10)!
initcall adm1021_driver_init+0x0/0x11 returned 0 after 58900 usecs
calling  adm1025_driver_init+0x0/0x11 @ 1
i2c i2c-0: Transaction failed (0x10)!
i2c i2c-1: Transaction failed (0x10)!
initcall adm1025_driver_init+0x0/0x11 returned 0 after 17304 usecs
calling  adm1026_driver_init+0x0/0x11 @ 1
i2c i2c-0: Transaction failed (0x10)!
i2c i2c-1: Transaction failed (0x10)!
initcall adm1026_driver_init+0x0/0x11 returned 0 after 17313 usecs
calling  adm1029_driver_init+0x0/0x11 @ 1
i2c i2c-0: Transaction failed (0x10)!
i2c i2c-1: Transaction failed (0x10)!
initcall adm1029_driver_init+0x0/0x11 returned 0 after 46601 usecs
calling  adm9240_driver_init+0x0/0x11 @ 1
i2c i2c-0: Transaction failed (0x10)!
i2c i2c-1: Transaction failed (0x10)!
initcall adm9240_driver_init+0x0/0x11 returned 0 after 23163 usecs
calling  ads1015_driver_init+0x0/0x11 @ 1
initcall ads1015_driver_init+0x0/0x11 returned 0 after 29 usecs
calling  ads7828_driver_init+0x0/0x11 @ 1
initcall ads7828_driver_init+0x0/0x11 returned 0 after 28 usecs
calling  adt7410_driver_init+0x0/0x11 @ 1
initcall adt7410_driver_init+0x0/0x11 returned 0 after 28 usecs
calling  adt7411_driver_init+0x0/0x11 @ 1
i2c i2c-0: Transaction failed (0x10)!
i2c i2c-1: Transaction failed (0x10)!
initcall adt7411_driver_init+0x0/0x11 returned 0 after 18023 usecs
calling  adt7462_driver_init+0x0/0x11 @ 1
i2c i2c-0: Transaction failed (0x10)!
i2c i2c-1: Transaction failed (0x10)!
initcall adt7462_driver_init+0x0/0x11 returned 0 after 11450 usecs
calling  adt7470_driver_init+0x0/0x11 @ 1
i2c i2c-0: Transaction failed (0x10)!
i2c i2c-1: Transaction failed (0x10)!
initcall adt7470_driver_init+0x0/0x11 returned 0 after 17303 usecs
calling  adt7475_driver_init+0x0/0x11 @ 1
i2c i2c-0: Transaction failed (0x10)!
i2c i2c-1: Transaction failed (0x10)!
initcall adt7475_driver_init+0x0/0x11 returned 0 after 17313 usecs
calling  applesmc_init+0x0/0x2d @ 1
applesmc: supported laptop not found!
applesmc: driver init failed (ret=3D-19)!
initcall applesmc_init+0x0/0x2d returned -19 after 1859 usecs
calling  sm_asc7621_init+0x0/0x73 @ 1
i2c i2c-0: Transaction failed (0x10)!
i2c i2c-1: Transaction failed (0x10)!
initcall sm_asc7621_init+0x0/0x73 returned 0 after 17720 usecs
calling  atxp1_driver_init+0x0/0x11 @ 1
i2c i2c-0: Transaction failed (0x10)!
i2c i2c-1: Transaction failed (0x10)!
initcall atxp1_driver_init+0x0/0x11 returned 0 after 11487 usecs
calling  coretemp_init+0x0/0x183 @ 1
initcall coretemp_init+0x0/0x183 returned -19 after 4 usecs
calling  dme1737_init+0x0/0x155 @ 1
i2c i2c-0: Transaction failed (0x10)!
i2c i2c-1: Transaction failed (0x10)!
initcall dme1737_init+0x0/0x155 returned 0 after 17503 usecs
calling  ds620_driver_init+0x0/0x11 @ 1
initcall ds620_driver_init+0x0/0x11 returned 0 after 29 usecs
calling  ds1621_driver_init+0x0/0x11 @ 1
initcall ds1621_driver_init+0x0/0x11 returned 0 after 29 usecs
calling  emc2103_driver_init+0x0/0x11 @ 1
i2c i2c-0: Transaction failed (0x10)!
i2c i2c-1: Transaction failed (0x10)!
initcall emc2103_driver_init+0x0/0x11 returned 0 after 6152 usecs
calling  f71882fg_init+0x0/0x114 @ 1
initcall f71882fg_init+0x0/0x114 returned -19 after 31 usecs
calling  f75375_driver_init+0x0/0x11 @ 1
i2c i2c-0: Transaction failed (0x10)!
i2c i2c-1: Transaction failed (0x10)!
initcall f75375_driver_init+0x0/0x11 returned 0 after 12401 usecs
calling  fam15h_power_driver_init+0x0/0x16 @ 1
initcall fam15h_power_driver_init+0x0/0x16 returned 0 after 61 usecs
calling  fschmd_driver_init+0x0/0x11 @ 1
i2c i2c-0: Transaction failed (0x10)!
i2c i2c-1: Transaction failed (0x10)!
initcall fschmd_driver_init+0x0/0x11 returned 0 after 6430 usecs
calling  g760a_driver_init+0x0/0x11 @ 1
initcall g760a_driver_init+0x0/0x11 returned 0 after 30 usecs
calling  gl520_driver_init+0x0/0x11 @ 1
i2c i2c-0: Transaction failed (0x10)!
i2c i2c-1: Transaction failed (0x10)!
initcall gl520_driver_init+0x0/0x11 returned 0 after 12063 usecs
calling  hih6130_driver_init+0x0/0x11 @ 1
initcall hih6130_driver_init+0x0/0x11 returned 0 after 30 usecs
calling  htu21_driver_init+0x0/0x11 @ 1
initcall htu21_driver_init+0x0/0x11 returned 0 after 28 usecs
calling  i5k_amb_init+0x0/0x56 @ 1
initcall i5k_amb_init+0x0/0x56 returned 0 after 201 usecs
calling  aem_init+0x0/0x43 @ 1
initcall aem_init+0x0/0x43 returned 0 after 32 usecs
calling  iio_hwmon_driver_init+0x0/0x11 @ 1
initcall iio_hwmon_driver_init+0x0/0x11 returned 0 after 32 usecs
calling  ina2xx_driver_init+0x0/0x11 @ 1
initcall ina2xx_driver_init+0x0/0x11 returned 0 after 37 usecs
calling  sm_it87_init+0x0/0x5ab @ 1
it87: Found IT8712F chip at 0x290, revision 7
it87: VID is disabled (pins used for GPIO)
it87 it87.656: Detected broken BIOS defaults, disabling PWM interface
initcall sm_it87_init+0x0/0x5ab returned 0 after 3399 usecs
calling  k10temp_driver_init+0x0/0x16 @ 1
initcall k10temp_driver_init+0x0/0x16 returned 0 after 47 usecs
calling  pem_driver_init+0x0/0x11 @ 1
initcall pem_driver_init+0x0/0x11 returned 0 after 31 usecs
calling  lm63_driver_init+0x0/0x11 @ 1
i2c i2c-0: Transaction failed (0x10)!
i2c i2c-1: Transaction failed (0x10)!
initcall lm63_driver_init+0x0/0x11 returned 0 after 17458 usecs
calling  lm73_driver_init+0x0/0x11 @ 1
i2c i2c-0: Transaction failed (0x10)!
i2c i2c-1: Transaction failed (0x10)!
initcall lm73_driver_init+0x0/0x11 returned 0 after 34924 usecs
calling  lm77_driver_init+0x0/0x11 @ 1
i2c i2c-0: Transaction failed (0x10)!
i2c i2c-1: Transaction failed (0x10)!
initcall lm77_driver_init+0x0/0x11 returned 0 after 23204 usecs
calling  sm_lm78_init+0x0/0x393 @ 1
i2c i2c-0: Transaction failed (0x10)!
i2c i2c-1: Transaction failed (0x10)!
initcall sm_lm78_init+0x0/0x393 returned 0 after 47151 usecs
calling  lm80_driver_init+0x0/0x11 @ 1
i2c i2c-0: Transaction failed (0x10)!
i2c i2c-1: Transaction failed (0x10)!
initcall lm80_driver_init+0x0/0x11 returned 0 after 47142 usecs
calling  lm95234_driver_init+0x0/0x11 @ 1
i2c i2c-0: Transaction failed (0x10)!
i2c i2c-1: Transaction failed (0x10)!
initcall lm95234_driver_init+0x0/0x11 returned 0 after 17820 usecs
calling  ltc4245_driver_init+0x0/0x11 @ 1
initcall ltc4245_driver_init+0x0/0x11 returned 0 after 30 usecs
calling  max16065_driver_init+0x0/0x11 @ 1
initcall max16065_driver_init+0x0/0x11 returned 0 after 30 usecs
calling  max1619_driver_init+0x0/0x11 @ 1
i2c i2c-0: Transaction failed (0x10)!
i2c i2c-1: Transaction failed (0x10)!
initcall max1619_driver_init+0x0/0x11 returned 0 after 52588 usecs
calling  max1668_driver_init+0x0/0x11 @ 1
i2c i2c-0: Transaction failed (0x10)!
i2c i2c-1: Transaction failed (0x10)!
initcall max1668_driver_init+0x0/0x11 returned 0 after 52461 usecs
calling  max197_driver_init+0x0/0x11 @ 1
initcall max197_driver_init+0x0/0x11 returned 0 after 36 usecs
calling  max6639_driver_init+0x0/0x11 @ 1
i2c i2c-0: Transaction failed (0x10)!
i2c i2c-1: Transaction failed (0x10)!
initcall max6639_driver_init+0x0/0x11 returned 0 after 17888 usecs
calling  max6642_driver_init+0x0/0x11 @ 1
i2c i2c-0: Transaction failed (0x10)!
i2c i2c-1: Transaction failed (0x10)!
initcall max6642_driver_init+0x0/0x11 returned 0 after 46603 usecs
calling  sensors_nct6775_init+0x0/0x323 @ 1
initcall sensors_nct6775_init+0x0/0x323 returned -19 after 90 usecs
calling  ntc_thermistor_driver_init+0x0/0x11 @ 1
initcall ntc_thermistor_driver_init+0x0/0x11 returned 0 after 32 usecs
calling  pc87360_init+0x0/0x16f @ 1
pc87360: PC8736x not detected, module not inserted
initcall pc87360_init+0x0/0x16f returned -19 after 1006 usecs
calling  pcf8591_init+0x0/0x38 @ 1
initcall pcf8591_init+0x0/0x38 returned 0 after 31 usecs
calling  sht15_driver_init+0x0/0x11 @ 1
initcall sht15_driver_init+0x0/0x11 returned 0 after 34 usecs
calling  sm_sis5595_init+0x0/0x16 @ 1
initcall sm_sis5595_init+0x0/0x16 returned 0 after 39 usecs
calling  smm665_driver_init+0x0/0x11 @ 1
initcall smm665_driver_init+0x0/0x11 returned 0 after 31 usecs
calling  smsc47b397_init+0x0/0x167 @ 1
initcall smsc47b397_init+0x0/0x167 returned -19 after 9 usecs
calling  sm_smsc47m1_init+0x0/0x244 @ 1
initcall sm_smsc47m1_init+0x0/0x244 returned -19 after 9 usecs
calling  thmc50_driver_init+0x0/0x11 @ 1
i2c i2c-0: Transaction failed (0x10)!
i2c i2c-1: Transaction failed (0x10)!
initcall thmc50_driver_init+0x0/0x11 returned 0 after 17778 usecs
calling  tmp102_driver_init+0x0/0x11 @ 1
initcall tmp102_driver_init+0x0/0x11 returned 0 after 37 usecs
calling  via_cputemp_init+0x0/0x12d @ 1
initcall via_cputemp_init+0x0/0x12d returned -19 after 4 usecs
calling  vt1211_init+0x0/0x155 @ 1
initcall vt1211_init+0x0/0x155 returned -19 after 20 usecs
calling  sm_vt8231_init+0x0/0x16 @ 1
initcall sm_vt8231_init+0x0/0x16 returned 0 after 38 usecs
calling  sensors_w83627ehf_init+0x0/0x130 @ 1
initcall sensors_w83627ehf_init+0x0/0x130 returned -19 after 34 usecs
calling  w83l785ts_driver_init+0x0/0x11 @ 1
i2c i2c-0: Transaction failed (0x10)!
i2c i2c-1: Transaction failed (0x10)!
initcall w83l785ts_driver_init+0x0/0x11 returned 0 after 5585 usecs
calling  w83l786ng_driver_init+0x0/0x11 @ 1
i2c i2c-0: Transaction failed (0x10)!
i2c i2c-1: Transaction failed (0x10)!
initcall w83l786ng_driver_init+0x0/0x11 returned 0 after 11919 usecs
calling  wm831x_hwmon_driver_init+0x0/0x11 @ 1
initcall wm831x_hwmon_driver_init+0x0/0x11 returned 0 after 41 usecs
calling  wm8350_hwmon_driver_init+0x0/0x11 @ 1
initcall wm8350_hwmon_driver_init+0x0/0x11 returned 0 after 32 usecs
calling  pmbus_driver_init+0x0/0x11 @ 1
initcall pmbus_driver_init+0x0/0x11 returned 0 after 31 usecs
calling  adm1275_driver_init+0x0/0x11 @ 1
initcall adm1275_driver_init+0x0/0x11 returned 0 after 30 usecs
calling  ltc2978_driver_init+0x0/0x11 @ 1
initcall ltc2978_driver_init+0x0/0x11 returned 0 after 31 usecs
calling  max16064_driver_init+0x0/0x11 @ 1
initcall max16064_driver_init+0x0/0x11 returned 0 after 36 usecs
calling  max34440_driver_init+0x0/0x11 @ 1
initcall max34440_driver_init+0x0/0x11 returned 0 after 30 usecs
calling  max8688_driver_init+0x0/0x11 @ 1
initcall max8688_driver_init+0x0/0x11 returned 0 after 29 usecs
calling  ucd9200_driver_init+0x0/0x11 @ 1
initcall ucd9200_driver_init+0x0/0x11 returned 0 after 29 usecs
calling  zl6100_driver_init+0x0/0x11 @ 1
initcall zl6100_driver_init+0x0/0x11 returned 0 after 30 usecs
calling  pkg_temp_thermal_init+0x0/0x4d6 @ 1
initcall pkg_temp_thermal_init+0x0/0x4d6 returned -19 after 4 usecs
calling  vhci_init+0x0/0x26 @ 1
Bluetooth: Virtual HCI driver ver 1.3
initcall vhci_init+0x0/0x26 returned 0 after 1846 usecs
calling  bfusb_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver bfusb
initcall bfusb_driver_init+0x0/0x16 returned 0 after 1308 usecs
calling  dtl1_driver_init+0x0/0xf @ 1
initcall dtl1_driver_init+0x0/0xf returned 0 after 38 usecs
calling  bt3c_driver_init+0x0/0xf @ 1
initcall bt3c_driver_init+0x0/0xf returned 0 after 26 usecs
calling  btuart_driver_init+0x0/0xf @ 1
initcall btuart_driver_init+0x0/0xf returned 0 after 26 usecs
calling  btsdio_init+0x0/0x26 @ 1
Bluetooth: Generic Bluetooth SDIO driver ver 0.1
initcall btsdio_init+0x0/0x26 returned 0 after 690 usecs
calling  btwilink_driver_init+0x0/0x11 @ 1
initcall btwilink_driver_init+0x0/0x11 returned 0 after 35 usecs
calling  mmc_blk_init+0x0/0x6d @ 1
initcall mmc_blk_init+0x0/0x6d returned 0 after 27 usecs
calling  mmc_test_init+0x0/0xf @ 1
initcall mmc_test_init+0x0/0xf returned 0 after 40 usecs
calling  sdio_uart_init+0x0/0xc9 @ 1
initcall sdio_uart_init+0x0/0xc9 returned 0 after 43 usecs
calling  sdhci_drv_init+0x0/0x20 @ 1
sdhci: Secure Digital Host Controller Interface driver
sdhci: Copyright(c) Pierre Ossman
initcall sdhci_drv_init+0x0/0x20 returned 0 after 1767 usecs
calling  sdhci_driver_init+0x0/0x16 @ 1
initcall sdhci_driver_init+0x0/0x16 returned 0 after 55 usecs
calling  goldfish_mmc_driver_init+0x0/0x11 @ 1
initcall goldfish_mmc_driver_init+0x0/0x11 returned 0 after 32 usecs
calling  sdricoh_driver_init+0x0/0xf @ 1
initcall sdricoh_driver_init+0x0/0xf returned 0 after 27 usecs
calling  ushc_driver_init+0x0/0x16 @ 1
usbcore: registered new interface driver ushc
initcall ushc_driver_init+0x0/0x16 returned 0 after 1138 usecs
calling  rtsx_pci_sdmmc_driver_init+0x0/0x11 @ 1
initcall rtsx_pci_sdmmc_driver_init+0x0/0x11 returned 0 after 31 usecs
calling  sdhci_pltfm_drv_init+0x0/0x14 @ 1
sdhci-pltfm: SDHCI platform and OF driver helper
initcall sdhci_pltfm_drv_init+0x0/0x14 returned 0 after 1645 usecs
calling  memstick_init+0x0/0x8c @ 1
initcall memstick_init+0x0/0x8c returned 0 after 141 usecs
calling  msb_init+0x0/0x66 @ 1
initcall msb_init+0x0/0x66 returned 0 after 25 usecs
calling  tifm_ms_init+0x0/0xf @ 1
initcall tifm_ms_init+0x0/0xf returned 0 after 25 usecs
calling  jmb38x_ms_driver_init+0x0/0x16 @ 1
initcall jmb38x_ms_driver_init+0x0/0x16 returned 0 after 46 usecs
calling  r852_pci_driver_init+0x0/0x16 @ 1
initcall r852_pci_driver_init+0x0/0x16 returned 0 after 45 usecs
calling  rtsx_pci_ms_driver_init+0x0/0x11 @ 1
initcall rtsx_pci_ms_driver_init+0x0/0x11 returned 0 after 33 usecs
calling  lm3533_led_driver_init+0x0/0x11 @ 1
initcall lm3533_led_driver_init+0x0/0x11 returned 0 after 31 usecs
calling  lm3642_i2c_driver_init+0x0/0x11 @ 1
initcall lm3642_i2c_driver_init+0x0/0x11 returned 0 after 33 usecs
calling  pca9532_driver_init+0x0/0x11 @ 1
initcall pca9532_driver_init+0x0/0x11 returned 0 after 31 usecs
calling  gpio_led_driver_init+0x0/0x11 @ 1
initcall gpio_led_driver_init+0x0/0x11 returned 0 after 32 usecs
calling  lp5523_driver_init+0x0/0x11 @ 1
initcall lp5523_driver_init+0x0/0x11 returned 0 after 30 usecs
calling  lp8501_driver_init+0x0/0x11 @ 1
initcall lp8501_driver_init+0x0/0x11 returned 0 after 36 usecs
calling  tca6507_driver_init+0x0/0x11 @ 1
initcall tca6507_driver_init+0x0/0x11 returned 0 after 30 usecs
calling  ot200_led_driver_init+0x0/0x11 @ 1
initcall ot200_led_driver_init+0x0/0x11 returned 0 after 32 usecs
calling  pca963x_driver_init+0x0/0x11 @ 1
initcall pca963x_driver_init+0x0/0x11 returned 0 after 31 usecs
calling  da903x_led_driver_init+0x0/0x11 @ 1
initcall da903x_led_driver_init+0x0/0x11 returned 0 after 33 usecs
calling  wm8350_led_driver_init+0x0/0x11 @ 1
initcall wm8350_led_driver_init+0x0/0x11 returned 0 after 33 usecs
calling  led_pwm_driver_init+0x0/0x11 @ 1
initcall led_pwm_driver_init+0x0/0x11 returned 0 after 31 usecs
calling  regulator_led_driver_init+0x0/0x11 @ 1
initcall regulator_led_driver_init+0x0/0x11 returned 0 after 91 usecs
calling  lt3593_led_driver_init+0x0/0x11 @ 1
initcall lt3593_led_driver_init+0x0/0x11 returned 0 after 50 usecs
calling  lm355x_i2c_driver_init+0x0/0x11 @ 1
initcall lm355x_i2c_driver_init+0x0/0x11 returned 0 after 46 usecs
calling  blinkm_driver_init+0x0/0x11 @ 1
i2c i2c-0: Transaction failed (0x10)!
i2c i2c-1: Transaction failed (0x10)!
initcall blinkm_driver_init+0x0/0x11 returned 0 after 5914 usecs
calling  timer_trig_init+0x0/0xf @ 1
initcall timer_trig_init+0x0/0xf returned 0 after 45 usecs
calling  heartbeat_trig_init+0x0/0x32 @ 1
initcall heartbeat_trig_init+0x0/0x32 returned 0 after 6 usecs
calling  bl_trig_init+0x0/0xf @ 1
initcall bl_trig_init+0x0/0xf returned 0 after 4 usecs
calling  gpio_trig_init+0x0/0xf @ 1
initcall gpio_trig_init+0x0/0xf returned 0 after 4 usecs
calling  ledtrig_cpu_init+0x0/0x53 @ 1
ledtrig-cpu: registered to indicate activity on CPUs
initcall ledtrig_cpu_init+0x0/0x53 returned 0 after 369 usecs
calling  transient_trig_init+0x0/0xf @ 1
initcall transient_trig_init+0x0/0xf returned 0 after 4 usecs
calling  ledtrig_camera_init+0x0/0x25 @ 1
initcall ledtrig_camera_init+0x0/0x25 returned 0 after 5 usecs
calling  ib_core_init+0x0/0xa8 @ 1
initcall ib_core_init+0x0/0xa8 returned 0 after 71 usecs
calling  ib_mad_init_module+0x0/0xca @ 1
initcall ib_mad_init_module+0x0/0xca returned 0 after 42 usecs
calling  ib_sa_init+0x0/0x59 @ 1
initcall ib_sa_init+0x0/0x59 returned 0 after 80 usecs
calling  ib_cm_init+0x0/0x152 @ 1
initcall ib_cm_init+0x0/0x152 returned 0 after 94 usecs
calling  iw_cm_init+0x0/0x49 @ 1
initcall iw_cm_init+0x0/0x49 returned 0 after 58 usecs
calling  addr_init+0x0/0x58 @ 1
initcall addr_init+0x0/0x58 returned 0 after 76 usecs
calling  cma_init+0x0/0xcf @ 1
initcall cma_init+0x0/0xcf returned 0 after 98 usecs
calling  mthca_init+0x0/0x15f @ 1
initcall mthca_init+0x0/0x15f returned 0 after 113 usecs
calling  c2_pci_driver_init+0x0/0x16 @ 1
initcall c2_pci_driver_init+0x0/0x16 returned 0 after 38 usecs
calling  mlx4_ib_init+0x0/0x7d @ 1
initcall mlx4_ib_init+0x0/0x7d returned 0 after 116 usecs
calling  mlx5_ib_init+0x0/0x16 @ 1
initcall mlx5_ib_init+0x0/0x16 returned 0 after 39 usecs
calling  nes_init_module+0x0/0x100 @ 1
initcall nes_init_module+0x0/0x100 returned 0 after 172 usecs
calling  ipoib_init_module+0x0/0x122 @ 1
initcall ipoib_init_module+0x0/0x122 returned 0 after 83 usecs
calling  srp_init_module+0x0/0x12b @ 1
initcall srp_init_module+0x0/0x12b returned 0 after 33 usecs
calling  isert_init+0x0/0xd4 @ 1
initcall isert_init+0x0/0xd4 returned 0 after 26 usecs
calling  dcdbas_init+0x0/0x57 @ 1
dcdbas dcdbas: Dell Systems Management Base Driver (version 5.6.0-3.2)
initcall dcdbas_init+0x0/0x57 returned 0 after 562 usecs
calling  cs5535_mfgpt_init+0x0/0x107 @ 1
cs5535-clockevt: Could not allocate MFGPT timer
initcall cs5535_mfgpt_init+0x0/0x107 returned -19 after 1488 usecs
calling  hid_init+0x0/0x43 @ 1
initcall hid_init+0x0/0x43 returned 0 after 56 usecs
calling  apple_driver_init+0x0/0x16 @ 1
initcall apple_driver_init+0x0/0x16 returned 0 after 32 usecs
calling  appleir_driver_init+0x0/0x16 @ 1
initcall appleir_driver_init+0x0/0x16 returned 0 after 24 usecs
calling  aureal_driver_init+0x0/0x16 @ 1
initcall aureal_driver_init+0x0/0x16 returned 0 after 24 usecs
calling  belkin_driver_init+0x0/0x16 @ 1
initcall belkin_driver_init+0x0/0x16 returned 0 after 24 usecs
calling  ch_driver_init+0x0/0x16 @ 1
initcall ch_driver_init+0x0/0x16 returned 0 after 37 usecs
calling  ch_driver_init+0x0/0x16 @ 1
initcall ch_driver_init+0x0/0x16 returned 0 after 31 usecs
calling  cp_driver_init+0x0/0x16 @ 1
initcall cp_driver_init+0x0/0x16 returned 0 after 24 usecs
calling  dr_driver_init+0x0/0x16 @ 1
initcall dr_driver_init+0x0/0x16 returned 0 after 31 usecs
calling  ems_driver_init+0x0/0x16 @ 1
initcall ems_driver_init+0x0/0x16 returned 0 after 24 usecs
calling  elecom_driver_init+0x0/0x16 @ 1
initcall elecom_driver_init+0x0/0x16 returned 0 after 33 usecs
calling  elo_driver_init+0x0/0x74 @ 1
initcall elo_driver_init+0x0/0x74 returned 0 after 85 usecs
calling  ez_driver_init+0x0/0x16 @ 1
initcall ez_driver_init+0x0/0x16 returned 0 after 24 usecs
calling  gyration_driver_init+0x0/0x16 @ 1
initcall gyration_driver_init+0x0/0x16 returned 0 after 24 usecs
calling  holtek_kbd_driver_init+0x0/0x16 @ 1
initcall holtek_kbd_driver_init+0x0/0x16 returned 0 after 24 usecs
calling  holtek_mouse_driver_init+0x0/0x16 @ 1
initcall holtek_mouse_driver_init+0x0/0x16 returned 0 after 26 usecs
calling  holtek_driver_init+0x0/0x16 @ 1
initcall holtek_driver_init+0x0/0x16 returned 0 after 31 usecs
calling  huion_driver_init+0x0/0x16 @ 1
initcall huion_driver_init+0x0/0x16 returned 0 after 24 usecs
calling  ks_driver_init+0x0/0x16 @ 1
initcall ks_driver_init+0x0/0x16 returned 0 after 24 usecs
calling  keytouch_driver_init+0x0/0x16 @ 1
initcall keytouch_driver_init+0x0/0x16 returned 0 after 25 usecs
calling  kye_driver_init+0x0/0x16 @ 1
initcall kye_driver_init+0x0/0x16 returned 0 after 24 usecs
calling  magicmouse_driver_init+0x0/0x16 @ 1
initcall magicmouse_driver_init+0x0/0x16 returned 0 after 24 usecs
calling  ms_driver_init+0x0/0x16 @ 1
initcall ms_driver_init+0x0/0x16 returned 0 after 25 usecs
calling  ntrig_driver_init+0x0/0x16 @ 1
initcall ntrig_driver_init+0x0/0x16 returned 0 after 48 usecs
calling  ortek_driver_init+0x0/0x16 @ 1
initcall ortek_driver_init+0x0/0x16 returned 0 after 24 usecs
calling  pl_driver_init+0x0/0x16 @ 1
initcall pl_driver_init+0x0/0x16 returned 0 after 24 usecs
calling  pl_driver_init+0x0/0x16 @ 1
initcall pl_driver_init+0x0/0x16 returned 0 after 25 usecs
calling  picolcd_driver_init+0x0/0x16 @ 1
initcall picolcd_driver_init+0x0/0x16 returned 0 after 25 usecs
calling  px_driver_init+0x0/0x16 @ 1
initcall px_driver_init+0x0/0x16 returned 0 after 24 usecs
calling  roccat_init+0x0/0x87 @ 1
initcall roccat_init+0x0/0x87 returned 0 after 7 usecs
calling  arvo_init+0x0/0x50 @ 1
initcall arvo_init+0x0/0x50 returned 0 after 47 usecs
calling  isku_init+0x0/0x50 @ 1
initcall isku_init+0x0/0x50 returned 0 after 53 usecs
calling  kone_init+0x0/0x50 @ 1
initcall kone_init+0x0/0x50 returned 0 after 45 usecs
calling  koneplus_init+0x0/0x50 @ 1
initcall koneplus_init+0x0/0x50 returned 0 after 53 usecs
calling  konepure_init+0x0/0x50 @ 1
initcall konepure_init+0x0/0x50 returned 0 after 46 usecs
calling  kovaplus_init+0x0/0x50 @ 1
initcall kovaplus_init+0x0/0x50 returned 0 after 46 usecs
calling  lua_driver_init+0x0/0x16 @ 1
initcall lua_driver_init+0x0/0x16 returned 0 after 24 usecs
calling  pyra_init+0x0/0x50 @ 1
initcall pyra_init+0x0/0x50 returned 0 after 59 usecs
calling  savu_init+0x0/0x50 @ 1
initcall savu_init+0x0/0x50 returned 0 after 45 usecs
calling  saitek_driver_init+0x0/0x16 @ 1
initcall saitek_driver_init+0x0/0x16 returned 0 after 24 usecs
calling  samsung_driver_init+0x0/0x16 @ 1
initcall samsung_driver_init+0x0/0x16 returned 0 after 25 usecs
calling  sony_driver_init+0x0/0x16 @ 1
initcall sony_driver_init+0x0/0x16 returned 0 after 24 usecs
calling  speedlink_driver_init+0x0/0x16 @ 1
initcall speedlink_driver_init+0x0/0x16 returned 0 after 24 usecs
calling  steelseries_srws1_driver_init+0x0/0x16 @ 1
initcall steelseries_srws1_driver_init+0x0/0x16 returned 0 after 25 usecs
calling  sp_driver_init+0x0/0x16 @ 1
initcall sp_driver_init+0x0/0x16 returned 0 after 25 usecs
calling  ga_driver_init+0x0/0x16 @ 1
initcall ga_driver_init+0x0/0x16 returned 0 after 31 usecs
calling  thingm_driver_init+0x0/0x16 @ 1
initcall thingm_driver_init+0x0/0x16 returned 0 after 24 usecs
calling  tm_driver_init+0x0/0x16 @ 1
initcall tm_driver_init+0x0/0x16 returned 0 after 25 usecs
calling  tivo_driver_init+0x0/0x16 @ 1
initcall tivo_driver_init+0x0/0x16 returned 0 after 25 usecs
calling  twinhan_driver_init+0x0/0x16 @ 1
initcall twinhan_driver_init+0x0/0x16 returned 0 after 24 usecs
calling  uclogic_driver_init+0x0/0x16 @ 1
initcall uclogic_driver_init+0x0/0x16 returned 0 after 24 usecs
calling  xinmo_driver_init+0x0/0x16 @ 1
initcall xinmo_driver_init+0x0/0x16 returned 0 after 25 usecs
calling  zp_driver_init+0x0/0x16 @ 1
initcall zp_driver_init+0x0/0x16 returned 0 after 40 usecs
calling  zc_driver_init+0x0/0x16 @ 1
initcall zc_driver_init+0x0/0x16 returned 0 after 26 usecs
calling  waltop_driver_init+0x0/0x16 @ 1
initcall waltop_driver_init+0x0/0x16 returned 0 after 24 usecs
calling  wiimote_hid_driver_init+0x0/0x16 @ 1
initcall wiimote_hid_driver_init+0x0/0x16 returned 0 after 25 usecs
calling  sensor_hub_driver_init+0x0/0x16 @ 1
initcall sensor_hub_driver_init+0x0/0x16 returned 0 after 25 usecs
calling  hid_init+0x0/0x45 @ 1
usbcore: registered new interface driver usbhid
usbhid: USB HID core driver
initcall hid_init+0x0/0x45 returned 0 after 1520 usecs
calling  vhost_net_init+0x0/0x20 @ 1
initcall vhost_net_init+0x0/0x20 returned 0 after 99 usecs
calling  vhost_init+0x0/0x7 @ 1
initcall vhost_init+0x0/0x7 returned 0 after 4 usecs
calling  hdaps_init+0x0/0x2d @ 1
hdaps: supported laptop not found!
hdaps: driver init failed (ret=3D-19)!
initcall hdaps_init+0x0/0x2d returned -19 after 2795 usecs
calling  goldfish_pdev_bus_driver_init+0x0/0x11 @ 1
goldfish_pdev_bus goldfish_pdev_bus: unable to reserve Goldfish MMIO.
goldfish_pdev_bus: probe of goldfish_pdev_bus failed with error -16
initcall goldfish_pdev_bus_driver_init+0x0/0x11 returned 0 after 2272 usecs
calling  hid_accel_3d_platform_driver_init+0x0/0x11 @ 1
initcall hid_accel_3d_platform_driver_init+0x0/0x11 returned 0 after 32 use=
cs
calling  st_accel_driver_init+0x0/0x11 @ 1
initcall st_accel_driver_init+0x0/0x11 returned 0 after 45 usecs
calling  exynos_adc_driver_init+0x0/0x11 @ 1
initcall exynos_adc_driver_init+0x0/0x11 returned 0 after 48 usecs
calling  lp8788_adc_driver_init+0x0/0x11 @ 1
initcall lp8788_adc_driver_init+0x0/0x11 returned 0 after 32 usecs
calling  max1363_driver_init+0x0/0x11 @ 1
initcall max1363_driver_init+0x0/0x11 returned 0 after 32 usecs
calling  tiadc_driver_init+0x0/0x11 @ 1
initcall tiadc_driver_init+0x0/0x11 returned 0 after 32 usecs
calling  twl6030_gpadc_driver_init+0x0/0x11 @ 1
initcall twl6030_gpadc_driver_init+0x0/0x11 returned 0 after 33 usecs
calling  vprbrd_adc_driver_init+0x0/0x11 @ 1
initcall vprbrd_adc_driver_init+0x0/0x11 returned 0 after 45 usecs
calling  ad5380_spi_init+0x0/0x11 @ 1
initcall ad5380_spi_init+0x0/0x11 returned 0 after 31 usecs
calling  ad5446_init+0x0/0x11 @ 1
initcall ad5446_init+0x0/0x11 returned 0 after 30 usecs
calling  mcp4725_driver_init+0x0/0x11 @ 1
initcall mcp4725_driver_init+0x0/0x11 returned 0 after 29 usecs
calling  hid_gyro_3d_platform_driver_init+0x0/0x11 @ 1
initcall hid_gyro_3d_platform_driver_init+0x0/0x11 returned 0 after 34 usecs
calling  itg3200_driver_init+0x0/0x11 @ 1
initcall itg3200_driver_init+0x0/0x11 returned 0 after 31 usecs
calling  st_gyro_driver_init+0x0/0x11 @ 1
initcall st_gyro_driver_init+0x0/0x11 returned 0 after 29 usecs
calling  inv_mpu_driver_init+0x0/0x11 @ 1
initcall inv_mpu_driver_init+0x0/0x11 returned 0 after 29 usecs
calling  adjd_s311_driver_init+0x0/0x11 @ 1
initcall adjd_s311_driver_init+0x0/0x11 returned 0 after 29 usecs
calling  apds9300_driver_init+0x0/0x11 @ 1
initcall apds9300_driver_init+0x0/0x11 returned 0 after 36 usecs
calling  hid_als_platform_driver_init+0x0/0x11 @ 1
initcall hid_als_platform_driver_init+0x0/0x11 returned 0 after 33 usecs
calling  vcnl4000_driver_init+0x0/0x11 @ 1
initcall vcnl4000_driver_init+0x0/0x11 returned 0 after 30 usecs
calling  hid_magn_3d_platform_driver_init+0x0/0x11 @ 1
initcall hid_magn_3d_platform_driver_init+0x0/0x11 returned 0 after 32 usecs
calling  st_magn_driver_init+0x0/0x11 @ 1
initcall st_magn_driver_init+0x0/0x11 returned 0 after 50 usecs
calling  st_press_driver_init+0x0/0x11 @ 1
initcall st_press_driver_init+0x0/0x11 returned 0 after 29 usecs
calling  iio_sysfs_trig_init+0x0/0x30 @ 1
initcall iio_sysfs_trig_init+0x0/0x30 returned 0 after 92 usecs
calling  vme_init+0x0/0xf @ 1
initcall vme_init+0x0/0xf returned 0 after 42 usecs
calling  ca91cx42_driver_init+0x0/0x16 @ 1
initcall ca91cx42_driver_init+0x0/0x16 returned 0 after 61 usecs
calling  tsi148_driver_init+0x0/0x16 @ 1
initcall tsi148_driver_init+0x0/0x16 returned 0 after 38 usecs
calling  ipack_init+0x0/0x19 @ 1
initcall ipack_init+0x0/0x19 returned 0 after 35 usecs
calling  tpci200_pci_drv_init+0x0/0x16 @ 1
initcall tpci200_pci_drv_init+0x0/0x16 returned 0 after 36 usecs
calling  fmc_init+0x0/0xf @ 1
initcall fmc_init+0x0/0xf returned 0 after 35 usecs
calling  t_init+0x0/0x12 @ 1
initcall t_init+0x0/0x12 returned 0 after 23 usecs
calling  fwe_init+0x0/0xf @ 1
initcall fwe_init+0x0/0xf returned 0 after 31 usecs
calling  fc_init+0x0/0xf @ 1
initcall fc_init+0x0/0xf returned 0 after 23 usecs
calling  sock_diag_init+0x0/0xf @ 1
initcall sock_diag_init+0x0/0xf returned 0 after 27 usecs
calling  flow_cache_init_global+0x0/0x10f @ 1
initcall flow_cache_init_global+0x0/0x10f returned 0 after 45 usecs
calling  llc_init+0x0/0x1b @ 1
initcall llc_init+0x0/0x1b returned 0 after 4 usecs
calling  llc2_init+0x0/0xbd @ 1
NET: Registered protocol family 26
initcall llc2_init+0x0/0xbd returned 0 after 1230 usecs
calling  snap_init+0x0/0x33 @ 1
initcall snap_init+0x0/0x33 returned 0 after 28 usecs
calling  netlink_diag_init+0x0/0xf @ 1
initcall netlink_diag_init+0x0/0xf returned 0 after 18 usecs
calling  nfnetlink_init+0x0/0x49 @ 1
Netfilter messages via NETLINK v0.30.
initcall nfnetlink_init+0x0/0x49 returned 0 after 779 usecs
calling  nfnl_acct_init+0x0/0x37 @ 1
nfnl_acct: registering with nfnetlink.
initcall nfnl_acct_init+0x0/0x37 returned 0 after 943 usecs
calling  nfnetlink_queue_init+0x0/0x7b @ 1
initcall nfnetlink_queue_init+0x0/0x7b returned 0 after 27 usecs
calling  nfnetlink_log_init+0x0/0x9c @ 1
initcall nfnetlink_log_init+0x0/0x9c returned 0 after 40 usecs
calling  nf_conntrack_standalone_init+0x0/0x6e @ 1
nf_conntrack version 0.5.0 (15637 buckets, 62548 max)
initcall nf_conntrack_standalone_init+0x0/0x6e returned 0 after 745 usecs
calling  nf_conntrack_proto_sctp_init+0x0/0x51 @ 1
initcall nf_conntrack_proto_sctp_init+0x0/0x51 returned 0 after 57 usecs
calling  ctnetlink_init+0x0/0x92 @ 1
ctnetlink v0.93: registering with nfnetlink.
initcall ctnetlink_init+0x0/0x92 returned 0 after 984 usecs
calling  nf_conntrack_amanda_init+0x0/0x90 @ 1
initcall nf_conntrack_amanda_init+0x0/0x90 returned 0 after 22 usecs
calling  nf_conntrack_ftp_init+0x0/0x1bc @ 1
initcall nf_conntrack_ftp_init+0x0/0x1bc returned 0 after 87 usecs
calling  nf_conntrack_h323_init+0x0/0xe0 @ 1
initcall nf_conntrack_h323_init+0x0/0xe0 returned 0 after 86 usecs
calling  nf_conntrack_irc_init+0x0/0x155 @ 1
initcall nf_conntrack_irc_init+0x0/0x155 returned 0 after 86 usecs
calling  nf_conntrack_snmp_init+0x0/0x19 @ 1
initcall nf_conntrack_snmp_init+0x0/0x19 returned 0 after 4 usecs
calling  nf_conntrack_sane_init+0x0/0x1b6 @ 1
initcall nf_conntrack_sane_init+0x0/0x1b6 returned 0 after 85 usecs
calling  nf_conntrack_sip_init+0x0/0x1e1 @ 1
initcall nf_conntrack_sip_init+0x0/0x1e1 returned 0 after 5 usecs
calling  synproxy_core_init+0x0/0x37 @ 1
initcall synproxy_core_init+0x0/0x37 returned 0 after 31 usecs
calling  xt_init+0x0/0x8d @ 1
initcall xt_init+0x0/0x8d returned 0 after 13 usecs
calling  tcpudp_mt_init+0x0/0x14 @ 1
initcall tcpudp_mt_init+0x0/0x14 returned 0 after 28 usecs
calling  mark_mt_init+0x0/0x37 @ 1
initcall mark_mt_init+0x0/0x37 returned 0 after 4 usecs
calling  connmark_mt_init+0x0/0x37 @ 1
initcall connmark_mt_init+0x0/0x37 returned 0 after 4 usecs
calling  audit_tg_init+0x0/0x14 @ 1
initcall audit_tg_init+0x0/0x14 returned 0 after 4 usecs
calling  checksum_tg_init+0x0/0xf @ 1
initcall checksum_tg_init+0x0/0xf returned 0 after 4 usecs
calling  classify_tg_init+0x0/0x14 @ 1
initcall classify_tg_init+0x0/0x14 returned 0 after 4 usecs
calling  xt_ct_tg_init+0x0/0x3c @ 1
initcall xt_ct_tg_init+0x0/0x3c returned 0 after 4 usecs
calling  dscp_tg_init+0x0/0x14 @ 1
initcall dscp_tg_init+0x0/0x14 returned 0 after 4 usecs
calling  hl_tg_init+0x0/0x14 @ 1
initcall hl_tg_init+0x0/0x14 returned 0 after 4 usecs
calling  hmark_tg_init+0x0/0x14 @ 1
initcall hmark_tg_init+0x0/0x14 returned 0 after 4 usecs
calling  led_tg_init+0x0/0xf @ 1
initcall led_tg_init+0x0/0xf returned 0 after 4 usecs
calling  log_tg_init+0x0/0x5a @ 1
initcall log_tg_init+0x0/0x5a returned 0 after 6 usecs
calling  nflog_tg_init+0x0/0xf @ 1
initcall nflog_tg_init+0x0/0xf returned 0 after 4 usecs
calling  nfqueue_tg_init+0x0/0x14 @ 1
initcall nfqueue_tg_init+0x0/0x14 returned 0 after 4 usecs
calling  xt_rateest_tg_init+0x0/0x22 @ 1
initcall xt_rateest_tg_init+0x0/0x22 returned 0 after 4 usecs
calling  secmark_tg_init+0x0/0xf @ 1
initcall secmark_tg_init+0x0/0xf returned 0 after 4 usecs
calling  tproxy_tg_init+0x0/0x1e @ 1
initcall tproxy_tg_init+0x0/0x1e returned 0 after 4 usecs
calling  tcpmss_tg_init+0x0/0x14 @ 1
initcall tcpmss_tg_init+0x0/0x14 returned 0 after 4 usecs
calling  tcpoptstrip_tg_init+0x0/0x14 @ 1
initcall tcpoptstrip_tg_init+0x0/0x14 returned 0 after 4 usecs
calling  tee_tg_init+0x0/0x14 @ 1
initcall tee_tg_init+0x0/0x14 returned 0 after 4 usecs
calling  trace_tg_init+0x0/0xf @ 1
initcall trace_tg_init+0x0/0xf returned 0 after 4 usecs
calling  idletimer_tg_init+0x0/0xfb @ 1
initcall idletimer_tg_init+0x0/0xfb returned 0 after 111 usecs
calling  xt_cluster_mt_init+0x0/0xf @ 1
initcall xt_cluster_mt_init+0x0/0xf returned 0 after 4 usecs
calling  connbytes_mt_init+0x0/0xf @ 1
initcall connbytes_mt_init+0x0/0xf returned 0 after 4 usecs
calling  connlabel_mt_init+0x0/0xf @ 1
initcall connlabel_mt_init+0x0/0xf returned 0 after 4 usecs
calling  connlimit_mt_init+0x0/0xf @ 1
initcall connlimit_mt_init+0x0/0xf returned 0 after 4 usecs
calling  conntrack_mt_init+0x0/0x14 @ 1
initcall conntrack_mt_init+0x0/0x14 returned 0 after 4 usecs
calling  ecn_mt_init+0x0/0x14 @ 1
initcall ecn_mt_init+0x0/0x14 returned 0 after 4 usecs
calling  hashlimit_mt_init+0x0/0x88 @ 1
initcall hashlimit_mt_init+0x0/0x88 returned 0 after 76 usecs
calling  helper_mt_init+0x0/0xf @ 1
initcall helper_mt_init+0x0/0xf returned 0 after 4 usecs
calling  hl_mt_init+0x0/0x14 @ 1
initcall hl_mt_init+0x0/0x14 returned 0 after 4 usecs
calling  iprange_mt_init+0x0/0x14 @ 1
initcall iprange_mt_init+0x0/0x14 returned 0 after 4 usecs
calling  ipvs_mt_init+0x0/0xf @ 1
initcall ipvs_mt_init+0x0/0xf returned 0 after 4 usecs
calling  limit_mt_init+0x0/0xf @ 1
initcall limit_mt_init+0x0/0xf returned 0 after 4 usecs
calling  multiport_mt_init+0x0/0x14 @ 1
initcall multiport_mt_init+0x0/0x14 returned 0 after 4 usecs
calling  nfacct_mt_init+0x0/0xf @ 1
initcall nfacct_mt_init+0x0/0xf returned 0 after 4 usecs
calling  owner_mt_init+0x0/0xf @ 1
initcall owner_mt_init+0x0/0xf returned 0 after 4 usecs
calling  pkttype_mt_init+0x0/0xf @ 1
initcall pkttype_mt_init+0x0/0xf returned 0 after 4 usecs
calling  quota_mt_init+0x0/0xf @ 1
initcall quota_mt_init+0x0/0xf returned 0 after 4 usecs
calling  xt_rateest_mt_init+0x0/0xf @ 1
initcall xt_rateest_mt_init+0x0/0xf returned 0 after 4 usecs
calling  realm_mt_init+0x0/0xf @ 1
initcall realm_mt_init+0x0/0xf returned 0 after 4 usecs
calling  string_mt_init+0x0/0xf @ 1
initcall string_mt_init+0x0/0xf returned 0 after 4 usecs
calling  tcpmss_mt_init+0x0/0x14 @ 1
initcall tcpmss_mt_init+0x0/0x14 returned 0 after 4 usecs
calling  time_mt_init+0x0/0x57 @ 1
xt_time: kernel timezone is -0000
initcall time_mt_init+0x0/0x57 returned 0 after 1059 usecs
calling  u32_mt_init+0x0/0xf @ 1
initcall u32_mt_init+0x0/0xf returned 0 after 4 usecs
calling  ip_vs_init+0x0/0xe4 @ 1
IPVS: Registered protocols ()
IPVS: Connection hash table configured (size=3D4096, memory=3D32Kbytes)
IPVS: Creating netns size=3D1100 id=3D0
IPVS: ipvs loaded.
initcall ip_vs_init+0x0/0xe4 returned 0 after 5198 usecs
calling  ip_vs_wrr_init+0x0/0xf @ 1
IPVS: [wrr] scheduler registered.
initcall ip_vs_wrr_init+0x0/0xf returned 0 after 83 usecs
calling  ip_vs_lc_init+0x0/0xf @ 1
IPVS: [lc] scheduler registered.
initcall ip_vs_lc_init+0x0/0xf returned 0 after 889 usecs
calling  ip_vs_lblc_init+0x0/0x33 @ 1
IPVS: [lblc] scheduler registered.
initcall ip_vs_lblc_init+0x0/0x33 returned 0 after 1230 usecs
calling  ip_vs_lblcr_init+0x0/0x33 @ 1
IPVS: [lblcr] scheduler registered.
initcall ip_vs_lblcr_init+0x0/0x33 returned 0 after 421 usecs
calling  ip_vs_dh_init+0x0/0xf @ 1
IPVS: [dh] scheduler registered.
initcall ip_vs_dh_init+0x0/0xf returned 0 after 889 usecs
calling  ip_vs_sh_init+0x0/0xf @ 1
IPVS: [sh] scheduler registered.
initcall ip_vs_sh_init+0x0/0xf returned 0 after 891 usecs
calling  ip_vs_sed_init+0x0/0xf @ 1
IPVS: [sed] scheduler registered.
initcall ip_vs_sed_init+0x0/0xf returned 0 after 1059 usecs
calling  ip_vs_nq_init+0x0/0xf @ 1
IPVS: [nq] scheduler registered.
initcall ip_vs_nq_init+0x0/0xf returned 0 after 890 usecs
calling  sysctl_ipv4_init+0x0/0x7a @ 1
initcall sysctl_ipv4_init+0x0/0x7a returned 0 after 64 usecs
calling  ipip_init+0x0/0x7e @ 1
ipip: IPv4 over IPv4 tunneling driver
initcall ipip_init+0x0/0x7e returned 0 after 1085 usecs
calling  gre_init+0x0/0x9b @ 1
gre: GRE over IPv4 demultiplexor driver
initcall gre_init+0x0/0x9b returned 0 after 1099 usecs
calling  vti_init+0x0/0x6f @ 1
IPv4 over IPSec tunneling driver
initcall vti_init+0x0/0x6f returned 0 after 1163 usecs
calling  init_syncookies+0x0/0x16 @ 1
initcall init_syncookies+0x0/0x16 returned 0 after 27 usecs
calling  ah4_init+0x0/0x75 @ 1
initcall ah4_init+0x0/0x75 returned 0 after 17 usecs
calling  esp4_init+0x0/0x75 @ 1
initcall esp4_init+0x0/0x75 returned 0 after 4 usecs
calling  xfrm4_beet_init+0x0/0x14 @ 1
initcall xfrm4_beet_init+0x0/0x14 returned 0 after 16 usecs
calling  tunnel4_init+0x0/0x6d @ 1
initcall tunnel4_init+0x0/0x6d returned 0 after 4 usecs
calling  xfrm4_transport_init+0x0/0x14 @ 1
initcall xfrm4_transport_init+0x0/0x14 returned 0 after 4 usecs
calling  xfrm4_mode_tunnel_init+0x0/0x14 @ 1
initcall xfrm4_mode_tunnel_init+0x0/0x14 returned 0 after 4 usecs
calling  ipv4_netfilter_init+0x0/0xf @ 1
initcall ipv4_netfilter_init+0x0/0xf returned 0 after 16 usecs
calling  nf_defrag_init+0x0/0x14 @ 1
initcall nf_defrag_init+0x0/0x14 returned 0 after 10 usecs
calling  ip_tables_init+0x0/0x8d @ 1
ip_tables: (C) 2000-2006 Netfilter Core Team
initcall ip_tables_init+0x0/0x8d returned 0 after 969 usecs
calling  iptable_filter_init+0x0/0x40 @ 1
initcall iptable_filter_init+0x0/0x40 returned 0 after 30 usecs
calling  iptable_mangle_init+0x0/0x40 @ 1
initcall iptable_mangle_init+0x0/0x40 returned 0 after 48 usecs
calling  iptable_raw_init+0x0/0x40 @ 1
initcall iptable_raw_init+0x0/0x40 returned 0 after 29 usecs
calling  iptable_security_init+0x0/0x40 @ 1
initcall iptable_security_init+0x0/0x40 returned 0 after 25 usecs
calling  ecn_tg_init+0x0/0xf @ 1
initcall ecn_tg_init+0x0/0xf returned 0 after 4 usecs
calling  synproxy_tg4_init+0x0/0x41 @ 1
initcall synproxy_tg4_init+0x0/0x41 returned 0 after 4 usecs
calling  ulog_tg_init+0x0/0x96 @ 1
initcall ulog_tg_init+0x0/0x96 returned 0 after 29 usecs
calling  inet_diag_init+0x0/0x6d @ 1
initcall inet_diag_init+0x0/0x6d returned 0 after 12 usecs
calling  tcp_diag_init+0x0/0xf @ 1
initcall tcp_diag_init+0x0/0xf returned 0 after 19 usecs
calling  cubictcp_register+0x0/0x78 @ 1
TCP: cubic registered
initcall cubictcp_register+0x0/0x78 returned 0 after 982 usecs
calling  xfrm_user_init+0x0/0x41 @ 1
Initializing XFRM netlink socket
initcall xfrm_user_init+0x0/0x41 returned 0 after 932 usecs
calling  unix_diag_init+0x0/0xf @ 1
initcall unix_diag_init+0x0/0xf returned 0 after 4 usecs
calling  inet6_init+0x0/0x2f3 @ 1
NET: Registered protocol family 10
initcall inet6_init+0x0/0x2f3 returned 0 after 2596 usecs
calling  ah6_init+0x0/0x75 @ 1
initcall ah6_init+0x0/0x75 returned 0 after 4 usecs
calling  esp6_init+0x0/0x75 @ 1
initcall esp6_init+0x0/0x75 returned 0 after 4 usecs
calling  tunnel6_init+0x0/0x75 @ 1
initcall tunnel6_init+0x0/0x75 returned 0 after 4 usecs
calling  xfrm6_transport_init+0x0/0x14 @ 1
initcall xfrm6_transport_init+0x0/0x14 returned 0 after 4 usecs
calling  xfrm6_mode_tunnel_init+0x0/0x14 @ 1
initcall xfrm6_mode_tunnel_init+0x0/0x14 returned 0 after 4 usecs
calling  xfrm6_ro_init+0x0/0x14 @ 1
initcall xfrm6_ro_init+0x0/0x14 returned 0 after 4 usecs
calling  xfrm6_beet_init+0x0/0x14 @ 1
initcall xfrm6_beet_init+0x0/0x14 returned 0 after 4 usecs
calling  ip6_tables_init+0x0/0x8d @ 1
ip6_tables: (C) 2000-2006 Netfilter Core Team
initcall ip6_tables_init+0x0/0x8d returned 0 after 1139 usecs
calling  ip6table_filter_init+0x0/0x40 @ 1
initcall ip6table_filter_init+0x0/0x40 returned 0 after 33 usecs
calling  ip6table_mangle_init+0x0/0x40 @ 1
initcall ip6table_mangle_init+0x0/0x40 returned 0 after 68 usecs
calling  ip6table_raw_init+0x0/0x40 @ 1
initcall ip6table_raw_init+0x0/0x40 returned 0 after 24 usecs
calling  nf_defrag_init+0x0/0x4a @ 1
initcall nf_defrag_init+0x0/0x4a returned 0 after 50 usecs
calling  ah_mt6_init+0x0/0xf @ 1
initcall ah_mt6_init+0x0/0xf returned 0 after 4 usecs
calling  eui64_mt6_init+0x0/0xf @ 1
initcall eui64_mt6_init+0x0/0xf returned 0 after 4 usecs
calling  frag_mt6_init+0x0/0xf @ 1
initcall frag_mt6_init+0x0/0xf returned 0 after 4 usecs
calling  ipv6header_mt6_init+0x0/0xf @ 1
initcall ipv6header_mt6_init+0x0/0xf returned 0 after 4 usecs
calling  mh_mt6_init+0x0/0xf @ 1
initcall mh_mt6_init+0x0/0xf returned 0 after 4 usecs
calling  rpfilter_mt_init+0x0/0xf @ 1
initcall rpfilter_mt_init+0x0/0xf returned 0 after 4 usecs
calling  synproxy_tg6_init+0x0/0x41 @ 1
initcall synproxy_tg6_init+0x0/0x41 returned 0 after 4 usecs
calling  sit_init+0x0/0xbc @ 1
sit: IPv6 over IPv4 tunneling driver
initcall sit_init+0x0/0xbc returned 0 after 1970 usecs
calling  ip6_tunnel_init+0x0/0xb4 @ 1
initcall ip6_tunnel_init+0x0/0xb4 returned 0 after 392 usecs
calling  ip6gre_init+0x0/0x98 @ 1
ip6_gre: GRE over IPv6 tunneling driver
initcall ip6gre_init+0x0/0x98 returned 0 after 1477 usecs
calling  packet_init+0x0/0x39 @ 1
NET: Registered protocol family 17
initcall packet_init+0x0/0x39 returned 0 after 1248 usecs
calling  packet_diag_init+0x0/0xf @ 1
initcall packet_diag_init+0x0/0xf returned 0 after 4 usecs
calling  ipsec_pfkey_init+0x0/0x69 @ 1
NET: Registered protocol family 15
initcall ipsec_pfkey_init+0x0/0x69 returned 0 after 253 usecs
calling  ipx_init+0x0/0xd6 @ 1
NET: Registered protocol family 4
initcall ipx_init+0x0/0xd6 returned 0 after 1149 usecs
calling  atalk_init+0x0/0x78 @ 1
NET: Registered protocol family 5
initcall atalk_init+0x0/0x78 returned 0 after 1121 usecs
calling  x25_init+0x0/0x81 @ 1
NET: Registered protocol family 9
X.25 for Linux Version 0.2
initcall x25_init+0x0/0x81 returned 0 after 1963 usecs
calling  lapb_init+0x0/0x7 @ 1
initcall lapb_init+0x0/0x7 returned 0 after 4 usecs
calling  nr_proto_init+0x0/0x261 @ 1
NET: Registered protocol family 6
initcall nr_proto_init+0x0/0x261 returned 0 after 2061 usecs
calling  rose_proto_init+0x0/0x28f @ 1
NET: Registered protocol family 11
initcall rose_proto_init+0x0/0x28f returned 0 after 3669 usecs
calling  ax25_init+0x0/0xae @ 1
NET: Registered protocol family 3
initcall ax25_init+0x0/0xae returned 0 after 1089 usecs
calling  can_init+0x0/0xe5 @ 1
can: controller area network core (rev 20120528 abi 9)
NET: Registered protocol family 29
initcall can_init+0x0/0xe5 returned 0 after 1942 usecs
calling  bcm_module_init+0x0/0x4c @ 1
can: broadcast manager protocol (rev 20120528 t)
initcall bcm_module_init+0x0/0x4c returned 0 after 697 usecs
calling  cgw_module_init+0x0/0x107 @ 1
can: netlink gateway (rev 20130117) max_hops=3D1
initcall cgw_module_init+0x0/0x107 returned 0 after 350 usecs
calling  irlan_init+0x0/0x255 @ 1
initcall irlan_init+0x0/0x255 returned 0 after 426 usecs
calling  rfcomm_init+0x0/0xe3 @ 1
Bluetooth: RFCOMM TTY layer initialized
Bluetooth: RFCOMM socket layer initialized
Bluetooth: RFCOMM ver 1.11
initcall rfcomm_init+0x0/0xe3 returned 0 after 2622 usecs
calling  hidp_init+0x0/0x21 @ 1
Bluetooth: HIDP (Human Interface Emulation) ver 1.2
Bluetooth: HIDP socket layer initialized
initcall hidp_init+0x0/0x21 returned 0 after 2445 usecs
calling  init_rpcsec_gss+0x0/0x54 @ 1
initcall init_rpcsec_gss+0x0/0x54 returned 0 after 123 usecs
calling  xprt_rdma_init+0x0/0xbc @ 1
RPC: Registered rdma transport module.
initcall xprt_rdma_init+0x0/0xbc returned 0 after 954 usecs
calling  svc_rdma_init+0x0/0x193 @ 1
initcall svc_rdma_init+0x0/0x193 returned 0 after 80 usecs
calling  af_rxrpc_init+0x0/0x1a0 @ 1
NET: Registered protocol family 33
Key type rxrpc registered
Key type rxrpc_s registered
initcall af_rxrpc_init+0x0/0x1a0 returned 0 after 2949 usecs
calling  rxkad_init+0x0/0x2f @ 1
RxRPC: Registered security type 2 'rxkad'
initcall rxkad_init+0x0/0x2f returned 0 after 1650 usecs
calling  atm_clip_init+0x0/0x9c @ 1
initcall atm_clip_init+0x0/0x9c returned 0 after 35 usecs
calling  br2684_init+0x0/0x4a @ 1
initcall br2684_init+0x0/0x4a returned 0 after 27 usecs
calling  lane_module_init+0x0/0x6b @ 1
lec:lane_module_init: lec.c: initialized
initcall lane_module_init+0x0/0x6b returned 0 after 1270 usecs
calling  atm_mpoa_init+0x0/0x45 @ 1
mpoa:atm_mpoa_init: mpc.c: initialized
initcall atm_mpoa_init+0x0/0x45 returned 0 after 930 usecs
calling  decnet_init+0x0/0x8a @ 1
NET4: DECnet for Linux: V.2.5.68s (C) 1995-2003 Linux DECnet Project Team
DECnet: Routing cache hash table of 1024 buckets, 36Kbytes
NET: Registered protocol family 12
initcall decnet_init+0x0/0x8a returned 0 after 2701 usecs
calling  dn_rtmsg_init+0x0/0x74 @ 1
initcall dn_rtmsg_init+0x0/0x74 returned 0 after 25 usecs
calling  phonet_init+0x0/0x71 @ 1
NET: Registered protocol family 35
initcall phonet_init+0x0/0x71 returned 0 after 1282 usecs
calling  pep_register+0x0/0x14 @ 1
initcall pep_register+0x0/0x14 returned 0 after 18 usecs
calling  vlan_proto_init+0x0/0x88 @ 1
8021q: 802.1Q VLAN Support v1.8
initcall vlan_proto_init+0x0/0x88 returned 0 after 788 usecs
calling  dccp_init+0x0/0x2ec @ 1
DCCP: Activated CCID 2 (TCP-like)
DCCP: Activated CCID 3 (TCP-Friendly Rate Control)
initcall dccp_init+0x0/0x2ec returned 0 after 5991 usecs
calling  dccp_v4_init+0x0/0x70 @ 1
initcall dccp_v4_init+0x0/0x70 returned 0 after 87 usecs
calling  dccp_v6_init+0x0/0x70 @ 1
initcall dccp_v6_init+0x0/0x70 returned 0 after 81 usecs
calling  dccp_diag_init+0x0/0xf @ 1
initcall dccp_diag_init+0x0/0xf returned 0 after 4 usecs
calling  sctp_init+0x0/0x495 @ 1
sctp: Hash tables configured (established 32768 bind 29127)
initcall sctp_init+0x0/0x495 returned 0 after 4239 usecs
calling  lib80211_init+0x0/0x1c @ 1
lib80211: common routines for IEEE802.11 drivers
lib80211_crypt: registered algorithm 'NULL'
initcall lib80211_init+0x0/0x1c returned 0 after 2444 usecs
calling  lib80211_crypto_wep_init+0x0/0xf @ 1
lib80211_crypt: registered algorithm 'WEP'
initcall lib80211_crypto_wep_init+0x0/0xf returned 0 after 629 usecs
calling  lib80211_crypto_ccmp_init+0x0/0xf @ 1
lib80211_crypt: registered algorithm 'CCMP'
initcall lib80211_crypto_ccmp_init+0x0/0xf returned 0 after 799 usecs
calling  lib80211_crypto_tkip_init+0x0/0xf @ 1
lib80211_crypt: registered algorithm 'TKIP'
initcall lib80211_crypto_tkip_init+0x0/0xf returned 0 after 1773 usecs
calling  tipc_init+0x0/0xee @ 1
tipc: Activated (version 2.0.0)
NET: Registered protocol family 30
tipc: Started in single node mode
initcall tipc_init+0x0/0xee returned 0 after 4563 usecs
calling  init_p9+0x0/0x1e @ 1
9pnet: Installing 9P2000 support
initcall init_p9+0x0/0x1e returned 0 after 1881 usecs
calling  p9_virtio_init+0x0/0x2d @ 1
initcall p9_virtio_init+0x0/0x2d returned 0 after 38 usecs
calling  p9_trans_rdma_init+0x0/0x11 @ 1
initcall p9_trans_rdma_init+0x0/0x11 returned 0 after 4 usecs
calling  dcbnl_init+0x0/0x5e @ 1
initcall dcbnl_init+0x0/0x5e returned 0 after 4 usecs
calling  af_ieee802154_init+0x0/0x63 @ 1
NET: Registered protocol family 36
initcall af_ieee802154_init+0x0/0x63 returned 0 after 1230 usecs
calling  lowpan_init_module+0x0/0x47 @ 1
initcall lowpan_init_module+0x0/0x47 returned 0 after 18 usecs
calling  wimax_subsys_init+0x0/0x231 @ 1
initcall wimax_subsys_init+0x0/0x231 returned 0 after 62 usecs
calling  init_dns_resolver+0x0/0xce @ 1
Key type dns_resolver registered
initcall init_dns_resolver+0x0/0xce returned 0 after 891 usecs
calling  init_ceph_lib+0x0/0x6d @ 1
Key type ceph registered
libceph: loaded (mon/osd proto 15/24)
initcall init_ceph_lib+0x0/0x6d returned 0 after 2249 usecs
calling  vmci_transport_init+0x0/0x121 @ 1
NET: Registered protocol family 40
initcall vmci_transport_init+0x0/0x121 returned 0 after 1296 usecs
calling  mpls_gso_init+0x0/0x28 @ 1
mpls_gso: MPLS GSO support
initcall mpls_gso_init+0x0/0x28 returned 0 after 852 usecs
calling  mcheck_init_device+0x0/0x20d @ 1
initcall mcheck_init_device+0x0/0x20d returned -5 after 4 usecs
calling  mcheck_debugfs_init+0x0/0x3e @ 1
initcall mcheck_debugfs_init+0x0/0x3e returned 0 after 45 usecs
calling  severities_debugfs_init+0x0/0x40 @ 1
initcall severities_debugfs_init+0x0/0x40 returned 0 after 23 usecs
calling  lapic_insert_resource+0x0/0x34 @ 1
initcall lapic_insert_resource+0x0/0x34 returned -1 after 4 usecs
calling  io_apic_bug_finalize+0x0/0x1a @ 1
initcall io_apic_bug_finalize+0x0/0x1a returned 0 after 4 usecs
calling  print_ICs+0x0/0x40d @ 1

printing PIC contents

printing PIC contents
=2E.. PIC  IMR: 3618
=2E.. PIC  IRR: 0001
=2E.. PIC  ISR: 0000
=2E.. PIC ELCR: 0828
printing local APIC contents on CPU#0/0:
=2E.. APIC ID:      00000000 (0)
=2E.. APIC VERSION: 00000000
=2E.. APIC TASKPRI: 00000000 (00)
=2E.. APIC RRR: 00000000
=2E.. APIC LDR: 00000000
=2E.. APIC DFR: 00000000
=2E.. APIC SPIV: 00000000
=2E.. APIC ISR field:
000000000000000000000000000000000000000000000000000000000000000000000000000=
00000000000000000000000000000000000000000000000000000

=2E.. APIC TMR field:
000000000000000000000000000000000000000000000000000000000000000000000000000=
00000000000000000000000000000000000000000000000000000

=2E.. APIC IRR field:
000000000000000000000000000000000000000000000000000000000000000000000000000=
00000000000000000000000000000000000000000000000000000

=2E.. APIC ICR: 00000000
=2E.. APIC ICR2: 00000000
=2E.. APIC LVTT: 00000000
=2E.. APIC LVT0: 00000000
=2E.. APIC LVT1: 00000000
=2E.. APIC TMICT: 00000000
=2E.. APIC TMCCT: 00000000
=2E.. APIC TDCR: 00000000

number of MP IRQ sources: 0.
testing the IO APIC.......................
IRQ to pin mappings:
=2E................................... done.
initcall print_ICs+0x0/0x40d returned 0 after 8887 usecs
calling  print_ipi_mode+0x0/0x2e @ 1
Using IPI Shortcut mode
initcall print_ipi_mode+0x0/0x2e returned 0 after 1320 usecs
calling  check_early_ioremap_leak+0x0/0x54 @ 1
initcall check_early_ioremap_leak+0x0/0x54 returned 0 after 4 usecs
calling  pat_memtype_list_init+0x0/0x3a @ 1
initcall pat_memtype_list_init+0x0/0x3a returned 0 after 16 usecs
calling  init_oops_id+0x0/0x3b @ 1
initcall init_oops_id+0x0/0x3b returned 0 after 4 usecs
calling  sched_init_debug+0x0/0x2a @ 1
initcall sched_init_debug+0x0/0x2a returned 0 after 14 usecs
calling  pm_qos_power_init+0x0/0x5b @ 1
initcall pm_qos_power_init+0x0/0x5b returned 0 after 216 usecs
calling  pm_debugfs_init+0x0/0x2a @ 1
initcall pm_debugfs_init+0x0/0x2a returned 0 after 15 usecs
calling  printk_late_init+0x0/0x4c @ 1
initcall printk_late_init+0x0/0x4c returned 0 after 4 usecs
calling  tk_debug_sleep_time_init+0x0/0x41 @ 1
initcall tk_debug_sleep_time_init+0x0/0x41 returned 0 after 14 usecs
calling  test_ringbuffer+0x0/0x448 @ 1
Running ring buffer tests...
finished
CPU 0:
              events:    5000
       dropped bytes:    0
       alloced bytes:    389428
       written bytes:    382036
       biggest event:    23
      smallest event:    0
         read events:   5000
         lost events:   0
        total events:   5000
  recorded len bytes:   389428
 recorded size bytes:   382036
Ring buffer PASSED!
initcall test_ringbuffer+0x0/0x448 returned 0 after 9780917 usecs
calling  clear_boot_tracer+0x0/0x30 @ 1
initcall clear_boot_tracer+0x0/0x30 returned 0 after 4 usecs
calling  set_recommended_min_free_kbytes+0x0/0x6d @ 1
initcall set_recommended_min_free_kbytes+0x0/0x6d returned 0 after 72 usecs
calling  afs_init+0x0/0x169 @ 1
kAFS: Red Hat AFS client v0.1 registering.
initcall afs_init+0x0/0x169 returned 0 after 2198 usecs
calling  init_trusted+0x0/0xa8 @ 1
Key type trusted registered
initcall init_trusted+0x0/0xa8 returned 0 after 1302 usecs
calling  init_encrypted+0x0/0xfa @ 1
Key type encrypted registered
initcall init_encrypted+0x0/0xfa returned 0 after 1961 usecs
calling  init_ima+0x0/0x18 @ 1
IMA: No TPM chip found, activating TPM-bypass!
initcall init_ima+0x0/0x18 returned 0 after 1403 usecs
calling  prandom_reseed+0x0/0x55 @ 1
initcall prandom_reseed+0x0/0x55 returned 0 after 9 usecs
calling  pci_resource_alignment_sysfs_init+0x0/0x19 @ 1
initcall pci_resource_alignment_sysfs_init+0x0/0x19 returned 0 after 17 use=
cs
calling  pci_sysfs_init+0x0/0x48 @ 1
initcall pci_sysfs_init+0x0/0x48 returned 0 after 237 usecs
calling  regulator_init_complete+0x0/0x14c @ 1
initcall regulator_init_complete+0x0/0x14c returned 0 after 4 usecs
calling  random_int_secret_init+0x0/0x16 @ 1
initcall random_int_secret_init+0x0/0x16 returned 0 after 16 usecs
calling  deferred_probe_initcall+0x0/0x73 @ 1
initcall deferred_probe_initcall+0x0/0x73 returned 0 after 99 usecs
calling  late_resume_init+0x0/0x1bb @ 1
  Magic number: 1:448:497
initcall late_resume_init+0x0/0x1bb returned 0 after 1923 usecs
calling  wl1273_core_init+0x0/0x29 @ 1
initcall wl1273_core_init+0x0/0x29 returned 0 after 59 usecs
calling  init_netconsole+0x0/0x1a3 @ 1
console [netcon0] enabled
netconsole: network logging started
initcall init_netconsole+0x0/0x1a3 returned 0 after 2078 usecs
calling  vxlan_init_module+0x0/0x8e @ 1
initcall vxlan_init_module+0x0/0x8e returned 0 after 38 usecs
calling  gpio_keys_init+0x0/0x11 @ 1
initcall gpio_keys_init+0x0/0x11 returned 0 after 77 usecs
calling  edd_init+0x0/0x2bd @ 1
BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
EDD information not available.
initcall edd_init+0x0/0x2bd returned -19 after 1897 usecs
calling  firmware_memmap_init+0x0/0x29 @ 1
initcall firmware_memmap_init+0x0/0x29 returned 0 after 56 usecs
calling  tcp_congestion_default+0x0/0xf @ 1
initcall tcp_congestion_default+0x0/0xf returned 0 after 4 usecs
calling  tcp_fastopen_init+0x0/0x40 @ 1
initcall tcp_fastopen_init+0x0/0x40 returned 0 after 37 usecs
calling  ip_auto_config+0x0/0xe11 @ 1
initcall ip_auto_config+0x0/0xe11 returned 0 after 24 usecs
calling  initialize_hashrnd+0x0/0x16 @ 1
initcall initialize_hashrnd+0x0/0x16 returned 0 after 6 usecs
async_waiting @ 1
async_continuing @ 1 after 4 usec
EXT3-fs (sda1): recovery required on readonly filesystem
EXT3-fs (sda1): write access will be enabled during recovery
kjournald starting.  Commit interval 5 seconds
EXT3-fs (sda1): recovery complete
EXT3-fs (sda1): mounted filesystem with writeback data mode
VFS: Mounted root (ext3 filesystem) readonly on device 8:1.
async_waiting @ 1
async_continuing @ 1 after 4 usec
debug: unmapping init [mem 0xb2d05000-0xb2dbbfff]
Write protecting the kernel text: 19924k
Testing CPA: Reverting b1000000-b2375000
Testing CPA: write protecting again
Write protecting the kernel read-only data: 8024k
Testing CPA: undo b2375000-b2b4b000
Testing CPA: write protecting again
Not activating Mandatory Access Control as /sbin/tomoyo-init does not exist.
INIT: version 2.86 booting
BUG: unable to handle kernel BUG: unable to handle kernel paging requestpag=
ing request at eaf10f40
 at eaf10f40
IP:IP: [<b103e0ef>] task_work_run+0x52/0x87
 [<b103e0ef>] task_work_run+0x52/0x87
*pde =3D 3fbf9067 *pde =3D 3fbf9067 *pte =3D 3af10060 *pte =3D 3af10060=20

Oops: 0000 [#1] Oops: 0000 [#1] DEBUG_PAGEALLOCDEBUG_PAGEALLOC

CPU: 0 PID: 171 Comm: hostname Tainted: G        W    3.12.0-rc4-01668-gfd7=
1a04-dirty #229484
task: eaf157a0 ti: eacf2000 task.ti: eacf2000
EIP: 0060:[<b103e0ef>] EFLAGS: 00010282 CPU: 0
EIP is at task_work_run+0x52/0x87
EAX: eaf10f40 EBX: eaf13f40 ECX: 00000000 EDX: eaf10f40
ESI: eaf15a38 EDI: eaf157a0 EBP: eacf3f3c ESP: eacf3f30
 DS: 007b ES: 007b FS: 0000 GS: 00e0 SS: 0068
CR0: 8005003b CR2: eaf10f40 CR3: 3acf6000 CR4: 00000690
Stack:
 eaf15a50 eaf15a50 eacf5dc0 eacf5dc0 eaf157a0 eaf157a0 eacf3f8c eacf3f8c b1=
029d1d b1029d1d 00000000 00000000 b01137a0 b01137a0 eaf157a0 eaf157a0

 eaf157a0 eaf157a0 eaf13f40 eaf13f40 00000001 00000001 00000007 00000007 ea=
cf3f88 eacf3f88 b10cdebb b10cdebb 00000001 00000001 eacf5e10 eacf5e10

 00000000 00000000 eaf13f48 eaf13f48 00000002 00000002 eaf13f40 eaf13f40 ea=
ce1d80 eace1d80 00000000 00000000 eaf157a0 eaf157a0 eacf3fa4 eacf3fa4

Call Trace:
 [<b1029d1d>] do_exit+0x291/0x753
 [<b10cdebb>] ? vfs_write+0x11f/0x15a
 [<b102a262>] do_group_exit+0x59/0x86
 [<b102a29f>] SyS_exit_group+0x10/0x10
 [<b237365b>] sysenter_do_call+0x12/0x2d
Code:Code: ed ed dc dc b2 b2 0f 0f 45 45 c8 c8 eb eb 02 02 31 31 c9 c9 89 8=
9 d0 d0 0f 0f b1 b1 0e 0e 39 39 c2 c2 75 75 d8 d8 85 85 d2 d2 74 74 41 41 f=
3 f3 90 90 8b 8b 87 87 d0 d0 02 02 00 00 00 00 85 85 c0 c0 74 74 f4 f4 31 3=
1 db db eb eb 04 04 89 89 d3 d3 89 89 c2 c2 <8b> <8b> 02 02 85 85 c0 c0 89 =
89 1a 1a 75 75 f4 f4 89 89 d0 d0 ff ff 52 52 04 04 31 31 c9 c9 ba ba 7d 7d =
00 00 00 00 00 00 b8 b8

EIP: [<b103e0ef>] EIP: [<b103e0ef>] task_work_run+0x52/0x87task_work_run+0x=
52/0x87 SS:ESP 0068:eacf3f30
 SS:ESP 0068:eacf3f30
CR2: 00000000eaf10f40
---[ end trace a7919e7f17c0a729 ]---
Fixing recursive fault but reboot is needed!
CPA self-test:
 4k 262128 large 0 gb 0 x 262128[b0000000-effef000] miss 0
ok.


--LZvS9be/3tNcYl/X--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
