Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 489166B00E8
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 17:37:29 -0500 (EST)
Date: Mon, 10 Jan 2011 23:37:07 +0100
From: Matthias Merz <linux@merz-ka.de>
Subject: Re: Regression in linux 2.6.37: failure to boot, caused by commit
	37d57443d5 (mm/slub.c)
Message-ID: <20110110223707.GA10326@merz.inka.de>
References: <20110110223154.GA9739@merz.inka.de>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="pWyiEgJYm5f9v55/"
Content-Disposition: inline
In-Reply-To: <20110110223154.GA9739@merz.inka.de>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, Tero Roponen <tero.roponen@gmail.com>
List-ID: <linux-mm.kvack.org>


--pWyiEgJYm5f9v55/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello together,

[sorry for being a fool and forgetting the promised attachment -
including my original message as a full quote *as well as* the
attachment]

I hope, I've got the right list of people from scripts/get_maintainer.pl
and the commit-log, just omitting LKML as Rcpt.

This morning I tried vanilla 2.6.37 on my Desktop system, which failed
to boot but continued displaying Debug-Messages too fast to read. Using
netconsole I was then able to capture them (see attached file). I was
able to trigger this bug even with init=/bin/bash by a simple call of
"mount -o remount,rw /" with my / being an ext4 filesystem.

Using git bisect I could identify commit 37d57443d5 as "the culprit" -
once I reverted that bugfix locally, my system booted happily. This ist
surely not a fix, but a local workaround for me - I would appreciate, if
someone with knowledge of the code could find a real fix.

The attached dmesg-output was "anonymized" wrt. MAC-Addresses, but is
complete otherwise.


Please let me know, if I can help any further,
thanks in advance,
Yours
Matthias Merz

--
Q: How many mutt users does it take to change a lightbulb?
A: One. But you have to set the option auto-change-illumination
   in your .muttrc file.

--pWyiEgJYm5f9v55/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="regression_2.6.37_submit"

Linux version 2.6.37-matthias (matthias@matthias) (gcc version 4.4.5 (Debian 4.4.5-8) ) #28 Sun Jan 9 22:47:21 CET 2011
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
 BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 000000007fffc000 (usable)
 BIOS-e820: 000000007fffc000 - 000000007ffff000 (ACPI data)
 BIOS-e820: 000000007ffff000 - 0000000080000000 (ACPI NVS)
 BIOS-e820: 00000000fec00000 - 00000000fec01000 (reserved)
 BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
 BIOS-e820: 00000000ffff0000 - 0000000100000000 (reserved)
Notice: NX (Execute Disable) protection missing in CPU or disabled in BIOS!
DMI 2.3 present.
DMI: A7V8X/System Name, BIOS ASUS A7V8X ACPI BIOS Revision 1015 Beta 003 09/10/2004
e820 update range: 0000000000000000 - 0000000000010000 (usable) ==> (reserved)
e820 remove range: 00000000000a0000 - 0000000000100000 (usable)
last_pfn = 0x7fffc max_arch_pfn = 0x100000
MTRR default type: uncachable
MTRR fixed ranges enabled:
  00000-9FFFF write-back
  A0000-EFFFF uncachable
  F0000-FFFFF write-protect
MTRR variable ranges enabled:
  0 base 000000000 mask F80000000 write-back
  1 disabled
  2 disabled
  3 disabled
  4 disabled
  5 disabled
  6 disabled
  7 base 0E0000000 mask FF0000000 write-combining
x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
initial memory mapped : 0 - 01c00000
init_memory_mapping: 0000000000000000-00000000377fe000
 0000000000 - 0000400000 page 4k
 0000400000 - 0037400000 page 2M
 0037400000 - 00377fe000 page 4k
kernel direct mapping tables up to 377fe000 @ 1bfb000-1c00000
ACPI: RSDP 000f6000 00014 (v00 ASUS  )
ACPI: RSDT 7fffc000 00030 (v01 ASUS   A7V8X    42302E31 MSFT 31313031)
ACPI: FACP 7fffc0b2 00074 (v01 ASUS   A7V8X    42302E31 MSFT 31313031)
ACPI: DSDT 7fffc126 0283E (v01   ASUS A7V8X    00001000 MSFT 0100000B)
ACPI: FACS 7ffff000 00040
ACPI: BOOT 7fffc030 00028 (v01 ASUS   A7V8X    42302E31 MSFT 31313031)
ACPI: APIC 7fffc058 0005A (v01 ASUS   A7V8X    42302E31 MSFT 31313031)
1159MB HIGHMEM available.
887MB LOWMEM available.
  mapped low ram: 0 - 377fe000
  low ram: 0 - 377fe000
Zone PFN ranges:
  DMA      0x00000010 -> 0x00001000
  Normal   0x00001000 -> 0x000377fe
  HighMem  0x000377fe -> 0x0007fffc
Movable zone start PFN for each node
early_node_map[2] active PFN ranges
    0: 0x00000010 -> 0x0000009f
    0: 0x00000100 -> 0x0007fffc
On node 0 totalpages: 524171
free_area_init_node: node 0, pgdat c156b360, node_mem_map f67fd200
  DMA zone: 32 pages used for memmap
  DMA zone: 0 pages reserved
  DMA zone: 3951 pages, LIFO batch:0
  Normal zone: 1744 pages used for memmap
  Normal zone: 221486 pages, LIFO batch:31
  HighMem zone: 2320 pages used for memmap
  HighMem zone: 294638 pages, LIFO batch:31
ACPI: PM-Timer IO Port: 0xe408
PM: Registered nosave memory: 000000000009f000 - 00000000000a0000
PM: Registered nosave memory: 00000000000a0000 - 00000000000f0000
PM: Registered nosave memory: 00000000000f0000 - 0000000000100000
Allocating PCI resources starting at 80000000 (gap: 80000000:7ec00000)
pcpu-alloc: s0 r0 d32768 u32768 alloc=1*32768
pcpu-alloc: [0] 0 
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 520075
Kernel command line: BOOT_IMAGE=/boot/vmlinuz-2.6.37-matthias root=/dev/hdb1 ro debug init=/bin/bash netconsole=<hidden>
PID hash table entries: 4096 (order: 2, 16384 bytes)
Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
Initializing CPU#0
Initializing HighMem for node 0 (000377fe:0007fffc)
Memory: 2073224k/2097136k available (4035k kernel code, 23460k reserved, 1528k data, 320k init, 1187832k highmem)
virtual kernel memory layout:
    fixmap  : 0xfffe4000 - 0xfffff000   ( 108 kB)
    pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
    vmalloc : 0xf7ffe000 - 0xff7fe000   ( 120 MB)
    lowmem  : 0xc0000000 - 0xf77fe000   ( 887 MB)
      .init : 0xc1570000 - 0xc15c0000   ( 320 kB)
      .data : 0xc13f0d98 - 0xc156f16c   (1528 kB)
      .text : 0xc1000000 - 0xc13f0d98   (4035 kB)
Checking if this processor honours the WP bit even in supervisor mode...Ok.
NR_IRQS:16
CPU 0 irqstacks, hard=f6004000 soft=f6006000
Console: colour VGA+ 80x25
console [tty0] enabled
Fast TSC calibration using PIT
Detected 2070.923 MHz processor.
Calibrating delay loop (skipped), value calculated using timer frequency.. 4141.84 BogoMIPS (lpj=2070923)
pid_max: default: 32768 minimum: 301
Mount-cache hash table entries: 512
mce: CPU supports 4 MCE banks
Performance Events: AMD PMU driver.
... version:                0
... bit width:              48
... generic registers:      4
... value mask:             0000ffffffffffff
... max period:             00007fffffffffff
... fixed-purpose events:   0
... event mask:             000000000000000f
CPU: AMD Athlon(TM) XP 2800+ stepping 00
ACPI: Core revision 20101013
ACPI: setting ELCR to 0200 (from 0e00)
NET: Registered protocol family 16
ACPI: bus type pci registered
PCI: PCI BIOS revision 2.10 entry at 0xf1a90, last bus=1
PCI: Using configuration type 1 for base access
bio: create slab <bio-0> at 0
ACPI: EC: Look up EC in DSDT
ACPI: Interpreter enabled
ACPI: (supports S0 S1 S4 S5)
ACPI: Using PIC for interrupt routing
ACPI Exception: AE_NOT_FOUND, Evaluating _PRW (20101013/scan-723)
ACPI Exception: AE_NOT_FOUND, Evaluating _PRW (20101013/scan-723)
ACPI Exception: AE_NOT_FOUND, Evaluating _PRW (20101013/scan-723)
ACPI Exception: AE_NOT_FOUND, Evaluating _PRW (20101013/scan-723)
ACPI Exception: AE_NOT_FOUND, Evaluating _PRW (20101013/scan-723)
ACPI Exception: AE_NOT_FOUND, Evaluating _PRW (20101013/scan-723)
ACPI: No dock devices found.
PCI: Ignoring host bridge windows from ACPI; if necessary, use "pci=use_crs" and report a bug
ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
pci_root PNP0A03:00: host bridge window [io  0x0000-0x0cf7] (ignored)
pci_root PNP0A03:00: host bridge window [io  0x0d00-0xffff] (ignored)
pci_root PNP0A03:00: host bridge window [mem 0x000a0000-0x000bffff] (ignored)
pci_root PNP0A03:00: host bridge window [mem 0x000c8000-0x000dffff] (ignored)
pci_root PNP0A03:00: host bridge window [mem 0x80000000-0xfebfffff] (ignored)
pci 0000:00:00.0: [1106:3189] type 0 class 0x000600
pci 0000:00:00.0: reg 10: [mem 0xe0000000-0xefffffff pref]
pci 0000:00:01.0: [1106:b168] type 1 class 0x000604
pci 0000:00:01.0: supports D1
pci 0000:00:07.0: [1106:3044] type 0 class 0x000c00
pci 0000:00:07.0: reg 10: [mem 0xcd800000-0xcd8007ff]
pci 0000:00:07.0: reg 14: [io  0xb800-0xb87f]
pci 0000:00:07.0: supports D2
pci 0000:00:07.0: PME# supported from D2 D3hot D3cold
pci 0000:00:07.0: PME# disabled
pci 0000:00:08.0: [105a:3376] type 0 class 0x000104
pci 0000:00:08.0: reg 10: [io  0xb400-0xb43f]
pci 0000:00:08.0: reg 14: [io  0xb000-0xb00f]
pci 0000:00:08.0: reg 18: [io  0xa800-0xa87f]
pci 0000:00:08.0: reg 1c: [mem 0xcd000000-0xcd000fff]
pci 0000:00:08.0: reg 20: [mem 0xcc800000-0xcc81ffff]
pci 0000:00:08.0: supports D1
pci 0000:00:09.0: [14e4:4401] type 0 class 0x000200
pci 0000:00:09.0: reg 10: [mem 0xcc000000-0xcc001fff]
pci 0000:00:09.0: reg 30: [mem 0xcfef0000-0xcfef3fff pref]
pci 0000:00:09.0: supports D1 D2
pci 0000:00:09.0: PME# supported from D0 D1 D2 D3hot D3cold
pci 0000:00:09.0: PME# disabled
pci 0000:00:0b.0: [1274:5880] type 0 class 0x000401
pci 0000:00:0b.0: reg 10: [io  0xa400-0xa43f]
pci 0000:00:0b.0: supports D2
pci 0000:00:0d.0: [1095:3512] type 0 class 0x000104
pci 0000:00:0d.0: reg 10: [io  0xa000-0xa007]
pci 0000:00:0d.0: reg 14: [io  0x9800-0x9803]
pci 0000:00:0d.0: reg 18: [io  0x9400-0x9407]
pci 0000:00:0d.0: reg 1c: [io  0x9000-0x9003]
pci 0000:00:0d.0: reg 20: [io  0x8800-0x880f]
pci 0000:00:0d.0: reg 24: [mem 0xcb800000-0xcb8001ff]
pci 0000:00:0d.0: reg 30: [mem 0x00000000-0x0007ffff pref]
pci 0000:00:0d.0: supports D1 D2
pci 0000:00:0e.0: [1022:2020] type 0 class 0x000100
pci 0000:00:0e.0: reg 10: [io  0x8400-0x847f]
pci 0000:00:0e.0: reg 30: [mem 0x00000000-0x0000ffff pref]
pci 0000:00:0f.0: [109e:036e] type 0 class 0x000400
pci 0000:00:0f.0: reg 10: [mem 0xcf000000-0xcf000fff pref]
pci 0000:00:0f.1: [109e:0878] type 0 class 0x000480
pci 0000:00:0f.1: reg 10: [mem 0xce800000-0xce800fff pref]
pci 0000:00:10.0: [1106:3038] type 0 class 0x000c03
pci 0000:00:10.0: reg 20: [io  0x8000-0x801f]
pci 0000:00:10.0: supports D1 D2
pci 0000:00:10.0: PME# supported from D0 D1 D2 D3hot D3cold
pci 0000:00:10.0: PME# disabled
pci 0000:00:10.1: [1106:3038] type 0 class 0x000c03
pci 0000:00:10.1: reg 20: [io  0x7800-0x781f]
pci 0000:00:10.1: supports D1 D2
pci 0000:00:10.1: PME# supported from D0 D1 D2 D3hot D3cold
pci 0000:00:10.1: PME# disabled
pci 0000:00:10.2: [1106:3038] type 0 class 0x000c03
pci 0000:00:10.2: reg 20: [io  0x7400-0x741f]
pci 0000:00:10.2: supports D1 D2
pci 0000:00:10.2: PME# supported from D0 D1 D2 D3hot D3cold
pci 0000:00:10.2: PME# disabled
pci 0000:00:10.3: [1106:3104] type 0 class 0x000c03
pci 0000:00:10.3: reg 10: [mem 0xcb000000-0xcb0000ff]
pci 0000:00:10.3: supports D1 D2
pci 0000:00:10.3: PME# supported from D0 D1 D2 D3hot D3cold
pci 0000:00:10.3: PME# disabled
pci 0000:00:11.0: [1106:3177] type 0 class 0x000601
HPET not enabled in BIOS. You might try hpet=force boot option
pci 0000:00:11.0: quirk: [io  0xe400-0xe47f] claimed by vt8235 PM
pci 0000:00:11.0: quirk: [io  0xe800-0xe80f] claimed by vt8235 SMB
pci 0000:00:11.1: [1106:0571] type 0 class 0x000101
pci 0000:00:11.1: reg 20: [io  0x7000-0x700f]
pci 0000:00:11.5: [1106:3059] type 0 class 0x000401
pci 0000:00:11.5: reg 10: [io  0xe000-0xe0ff]
pci 0000:00:11.5: supports D1 D2
pci 0000:01:00.0: [1002:9586] type 0 class 0x000300
pci 0000:01:00.0: reg 10: [mem 0xd0000000-0xdfffffff pref]
pci 0000:01:00.0: reg 14: [io  0xd800-0xd8ff]
pci 0000:01:00.0: reg 18: [mem 0xce000000-0xce00ffff]
pci 0000:01:00.0: reg 30: [mem 0xcffe0000-0xcfffffff pref]
pci 0000:01:00.0: supports D1 D2
pci 0000:00:01.0: PCI bridge to [bus 01-01]
pci 0000:00:01.0:   bridge window [io  0xd000-0xdfff]
pci 0000:00:01.0:   bridge window [mem 0xce000000-0xce7fffff]
pci 0000:00:01.0:   bridge window [mem 0xcff00000-0xdfffffff pref]
pci_bus 0000:00: on NUMA node 0
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PCI1._PRT]
ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 9 10 *11 12)
ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 9 *10 11 12)
ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 *9 10 11 12)
ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 9 10 11 12) *0, disabled.
ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 9 *10 11 12)
ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 *9 10 11 12)
HEST: Table is not found!
vgaarb: device added: PCI:0000:01:00.0,decodes=io+mem,owns=io+mem,locks=none
vgaarb: loaded
SCSI subsystem initialized
libata version 3.00 loaded.
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
wmi: Mapper loaded
PCI: Using ACPI for IRQ routing
PCI: pci_cache_line_size set to 32 bytes
reserve RAM buffer: 000000000009fc00 - 000000000009ffff 
reserve RAM buffer: 000000007fffc000 - 000000007fffffff 
Switching to clocksource tsc
pnp: PnP ACPI init
ACPI: bus type pnp registered
pnp 00:00: [mem 0x00000000-0x0009ffff]
pnp 00:00: [mem 0x000f0000-0x000fffff]
pnp 00:00: [mem 0x00100000-0x7fffffff]
pnp 00:00: [mem 0xfec00000-0xfec000ff]
pnp 00:00: [mem 0xfee00000-0xfee00fff]
pnp 00:00: Plug and Play ACPI device, IDs PNP0c01 (active)
pnp 00:01: [bus 00-ff]
pnp 00:01: [io  0x0cf8-0x0cff]
pnp 00:01: [io  0x0000-0x0cf7 window]
pnp 00:01: [io  0x0d00-0xffff window]
pnp 00:01: [mem 0x000a0000-0x000bffff window]
pnp 00:01: [mem 0x000c8000-0x000dffff window]
pnp 00:01: [mem 0x80000000-0xfebfffff window]
pnp 00:01: Plug and Play ACPI device, IDs PNP0a03 (active)
pnp 00:02: [io  0xe400-0xe47f]
pnp 00:02: [io  0xe800-0xe81f]
pnp 00:02: [mem 0xfff80000-0xffffffff]
pnp 00:02: [mem 0xffb80000-0xffbfffff]
pnp 00:02: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp 00:03: [io  0x0010-0x001f]
pnp 00:03: [io  0x0022-0x002d]
pnp 00:03: [io  0x0030-0x003f]
pnp 00:03: [io  0x0044-0x005f]
pnp 00:03: [io  0x0062-0x0063]
pnp 00:03: [io  0x0065-0x006f]
pnp 00:03: [io  0x0074-0x007f]
pnp 00:03: [io  0x0091-0x0093]
pnp 00:03: [io  0x00a2-0x00bf]
pnp 00:03: [io  0x00e0-0x00ef]
pnp 00:03: [io  0x04d0-0x04d1]
pnp 00:03: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp 00:04: [dma 4]
pnp 00:04: [io  0x0000-0x000f]
pnp 00:04: [io  0x0080-0x0090]
pnp 00:04: [io  0x0094-0x009f]
pnp 00:04: [io  0x00c0-0x00df]
pnp 00:04: Plug and Play ACPI device, IDs PNP0200 (active)
pnp 00:05: [io  0x0070-0x0073]
pnp 00:05: [irq 8]
pnp 00:05: Plug and Play ACPI device, IDs PNP0b00 (active)
pnp 00:06: [io  0x0061]
pnp 00:06: Plug and Play ACPI device, IDs PNP0800 (active)
pnp 00:07: [io  0x00f0-0x00ff]
pnp 00:07: [irq 13]
pnp 00:07: Plug and Play ACPI device, IDs PNP0c04 (active)
pnp 00:08: [io  0x03f2-0x03f5]
pnp 00:08: [io  0x03f7]
pnp 00:08: [irq 6]
pnp 00:08: [dma 2]
pnp 00:08: Plug and Play ACPI device, IDs PNP0700 (active)
pnp 00:09: [io  0x0378-0x037f]
pnp 00:09: [io  0x0778-0x077b]
pnp 00:09: [irq 7]
pnp 00:09: [dma 3]
pnp 00:09: Plug and Play ACPI device, IDs PNP0401 (active)
pnp 00:0a: [io  0x03f8-0x03ff]
pnp 00:0a: [irq 4]
pnp 00:0a: Plug and Play ACPI device, IDs PNP0501 (active)
pnp 00:0b: [io  0x02f8-0x02ff]
pnp 00:0b: [irq 3]
pnp 00:0b: Plug and Play ACPI device, IDs PNP0501 (active)
pnp 00:0c: [io  0x0060]
pnp 00:0c: [io  0x0064]
pnp 00:0c: [irq 1]
pnp 00:0c: Plug and Play ACPI device, IDs PNP0303 PNP030b (active)
pnp 00:0d: [irq 12]
pnp 00:0d: Plug and Play ACPI device, IDs PNP0f03 PNP0f13 (active)
pnp 00:0e: [io  0x002e-0x002f]
pnp 00:0e: [io  0x0290-0x0291]
pnp 00:0e: [io  0x0370-0x0372]
pnp 00:0e: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp: PnP ACPI: found 15 devices
ACPI: ACPI bus type pnp unregistered
system 00:00: [mem 0x00000000-0x0009ffff] could not be reserved
system 00:00: [mem 0x000f0000-0x000fffff] could not be reserved
system 00:00: [mem 0x00100000-0x7fffffff] could not be reserved
system 00:00: [mem 0xfec00000-0xfec000ff] has been reserved
system 00:00: [mem 0xfee00000-0xfee00fff] has been reserved
system 00:02: [io  0xe400-0xe47f] has been reserved
system 00:02: [io  0xe800-0xe81f] could not be reserved
system 00:02: [mem 0xfff80000-0xffffffff] could not be reserved
system 00:02: [mem 0xffb80000-0xffbfffff] has been reserved
system 00:03: [io  0x04d0-0x04d1] has been reserved
system 00:0e: [io  0x0290-0x0291] has been reserved
system 00:0e: [io  0x0370-0x0372] has been reserved
pci 0000:00:0d.0: BAR 6: assigned [mem 0x80000000-0x8007ffff pref]
pci 0000:00:0e.0: BAR 6: assigned [mem 0x80080000-0x8008ffff pref]
pci 0000:00:01.0: PCI bridge to [bus 01-01]
pci 0000:00:01.0:   bridge window [io  0xd000-0xdfff]
pci 0000:00:01.0:   bridge window [mem 0xce000000-0xce7fffff]
pci 0000:00:01.0:   bridge window [mem 0xcff00000-0xdfffffff pref]
pci 0000:00:01.0: setting latency timer to 64
pci_bus 0000:00: resource 0 [io  0x0000-0xffff]
pci_bus 0000:00: resource 1 [mem 0x00000000-0xffffffff]
pci_bus 0000:01: resource 0 [io  0xd000-0xdfff]
pci_bus 0000:01: resource 1 [mem 0xce000000-0xce7fffff]
pci_bus 0000:01: resource 2 [mem 0xcff00000-0xdfffffff pref]
NET: Registered protocol family 2
IP route cache hash table entries: 32768 (order: 5, 131072 bytes)
TCP established hash table entries: 131072 (order: 8, 1048576 bytes)
TCP bind hash table entries: 65536 (order: 6, 262144 bytes)
TCP: Hash tables configured (established 131072 bind 65536)
TCP reno registered
UDP hash table entries: 512 (order: 1, 8192 bytes)
UDP-Lite hash table entries: 512 (order: 1, 8192 bytes)
NET: Registered protocol family 1
pci 0000:00:01.0: disabling DAC on VIA PCI bridge
pci 0000:01:00.0: Boot video device
PCI: CLS 32 bytes, default 32
Simple Boot Flag at 0x3a set to 0x1
microcode: microcode: CPU0: AMD CPU family 0x6 not supported
microcode: Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
highmem bounce pool size: 64 pages
SGI XFS with ACLs, security attributes, large block/inode numbers, no debug enabled
SGI XFS Quota Management subsystem
msgmni has been set to 1729
io scheduler noop registered
io scheduler deadline registered
io scheduler cfq registered (default)
input: Power Button as /devices/LNXSYSTM:00/device:00/PNP0C0C:00/input/input0
ACPI: Power Button [PWRB]
input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
ACPI: Power Button [PWRF]
ACPI: acpi_idle registered with cpuidle
ERST: Table is not found!
GHES: HEST is not enabled!
Linux agpgart interface v0.103
agpgart: Detected VIA KT400/KT400A/KT600 chipset
agpgart-via 0000:00:00.0: AGP aperture is 256M @ 0xe0000000
[drm] Initialized drm 1.1.0 20060810
[drm] radeon defaulting to kernel modesetting.
[drm] radeon kernel modesetting enabled.
ACPI: PCI Interrupt Link [LNKA] enabled at IRQ 11
PCI: setting IRQ 11 as level-triggered
radeon 0000:01:00.0: PCI INT A -> Link[LNKA] -> GSI 11 (level, low) -> IRQ 11
[drm] initializing kernel modesetting (RV630 0x1002:0x9586).
[drm] register mmio base: 0xCE000000
[drm] register mmio size: 65536
ATOM BIOS: 113
agpgart-via 0000:00:00.0: AGP 3.5 bridge
agpgart-via 0000:00:00.0: putting AGP V3 device into 8x mode
radeon 0000:01:00.0: putting AGP V3 device into 8x mode
radeon 0000:01:00.0: GTT: 256M 0xE0000000 - 0xEFFFFFFF
radeon 0000:01:00.0: VRAM: 256M 0xD0000000 - 0xDFFFFFFF (256M used)
[drm] Detected VRAM RAM=256M, BAR=256M
[drm] RAM width 128bits DDR
[TTM] Zone  kernel: Available graphics memory: 442696 kiB.
[TTM] Zone highmem: Available graphics memory: 1036612 kiB.
[TTM] Initializing pool allocator.
[drm] radeon: 256M of VRAM memory ready
[drm] radeon: 256M of GTT memory ready.
[drm] radeon: irq initialized.
[drm] GART: num cpu pages 65536, num gpu pages 65536
[drm] Loading RV630 Microcode
radeon 0000:01:00.0: WB disabled
[drm] ring test succeeded in 0 usecs
[drm] radeon: ib pool ready.
[drm] ib test succeeded in 0 usecs
[drm] Enabling audio support
failed to evaluate ATIF got AE_BAD_PARAMETER
[drm] Radeon Display Connectors
[drm] Connector 0:
[drm]   DIN
[drm]   Encoders:
[drm]     TV1: INTERNAL_KLDSCP_DAC2
[drm] Connector 1:
[drm]   DVI-I
[drm]   HPD1
[drm]   DDC: 0x7e50 0x7e50 0x7e54 0x7e54 0x7e58 0x7e58 0x7e5c 0x7e5c
[drm]   Encoders:
[drm]     CRT2: INTERNAL_KLDSCP_DAC2
[drm]     DFP1: INTERNAL_KLDSCP_TMDS1
[drm] Connector 2:
[drm]   VGA
[drm]   DDC: 0x7e40 0x7e40 0x7e44 0x7e44 0x7e48 0x7e48 0x7e4c 0x7e4c
[drm]   Encoders:
[drm]     CRT1: INTERNAL_KLDSCP_DAC1
[drm] Internal thermal controller with fan control
[drm] radeon: power management initialized
[drm] fb mappable at 0xD00C1000
[drm] vram apper at 0xD0000000
[drm] size 5242880
[drm] fb depth is 24
[drm]    pitch is 5120
Console: switching to colour frame buffer device 160x64
fb0: radeondrmfb frame buffer device
drm: registered panic notifier
[drm] Initialized radeon 2.7.0 20080528 for 0000:01:00.0 on minor 0
Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
serial8250: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
00:0a: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
00:0b: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
Floppy drive(s): fd0 is 1.44M
FDC 0 is a post-1991 82077
Uniform Multi-Platform E-IDE driver
via82cxxx 0000:00:11.1: VIA vt8235 (rev 00) IDE UDMA133
via82cxxx 0000:00:11.1: IDE controller (0x1106:0x0571 rev 0x06)
VIA_IDE 0000:00:11.1: can't derive routing for PCI INT A
via82cxxx 0000:00:11.1: not 100% native mode: will probe irqs later
    ide0: BM-DMA at 0x7000-0x7007
    ide1: BM-DMA at 0x7008-0x700f
Probing IDE interface ide0...
hda: SAMSUNG SP1614N, ATA DISK drive
hdb: ST3320620A, ATA DISK drive
hda: host max PIO5 wanted PIO255(auto-tune) selected PIO4
hda: UDMA/133 mode selected
hdb: host max PIO5 wanted PIO255(auto-tune) selected PIO4
hdb: UDMA/100 mode selected
Probing IDE interface ide1...
hdc: LG DVD-ROM DRD-8160B, ATAPI CD/DVD-ROM drive
hdd: BENQ DVD DD DW1640, ATAPI CD/DVD-ROM drive
hdc: host max PIO5 wanted PIO255(auto-tune) selected PIO4
hdc: UDMA/33 mode selected
hdd: host max PIO5 wanted PIO255(auto-tune) selected PIO4
hdd: UDMA/33 mode selected
ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
ide1 at 0x170-0x177,0x376 on irq 15
ide_generic: please use "probe_mask=0x3f" module parameter for probing all legacy ISA IDE ports
ide-gd driver 1.18
hda: max request size: 512KiB
hda: 312581808 sectors (160041 MB) w/8192KiB Cache, CHS=19457/255/63
hda: cache flushes supported
 hda: hda1 hda2 < hda5 hda6 hda7 >
hdb: max request size: 512KiB
hdb: 625142448 sectors (320072 MB) w/16384KiB Cache, CHS=38913/255/63
hdb: cache flushes supported
 hdb: hdb1 hdb2 < hdb5 hdb6 hdb7 hdb8 >
ide-cd driver 5.00
ide-cd: hdc: ATAPI 48X DVD-ROM drive, 512kB Cache
cdrom: Uniform CD-ROM driver Revision: 3.20
ide-cd: hdd: ATAPI 48X DVD-ROM DVD-R CD-R/RW drive, 2048kB Cache
ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 9
PCI: setting IRQ 9 as level-triggered
b44 0000:00:09.0: PCI INT A -> Link[LNKC] -> GSI 9 (level, low) -> IRQ 9
ssb: Core 0 found: Fast Ethernet (cc 0x806, rev 0x04, vendor 0x4243)
ssb: Core 1 found: V90 (cc 0x807, rev 0x01, vendor 0x4243)
ssb: Core 2 found: PCI (cc 0x804, rev 0x02, vendor 0x4243)
ssb: Sonics Silicon Backplane found on PCI device 0000:00:09.0
b44: b44.c:v2.0
b44 ssb0:0: eth0: Broadcom 44xx/47xx 10/100BaseT Ethernet <MAC hidden>
netconsole: local port 6665
netconsole: local IP <hidden>
netconsole: interface 'eth0'
netconsole: remote port 6666
netconsole: remote IP <hidden>
netconsole: remote ethernet address ff:ff:ff:ff:ff:ff
netconsole: device eth0 not up yet, forcing it
b44 ssb0:0: eth0: Link is up at 100 Mbps, full duplex
b44 ssb0:0: eth0: Flow control is off for TX and off for RX
console [netcon0] enabled
netconsole: network logging started
PNP: PS/2 Controller [PNP0303:PS2K,PNP0f03:PS2M] at 0x60,0x64 irq 1,12
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
mice: PS/2 mouse device common for all mice
input: PC Speaker as /devices/platform/pcspkr/input/input2
rtc_cmos 00:05: RTC can wake from S4
rtc_cmos 00:05: rtc core: registered rtc_cmos as rtc0
rtc0: alarms up to one month, 242 bytes nvram
EDAC MC: Ver: 2.1.0 Jan  9 2011
cpuidle: using governor ladder
cpuidle: using governor menu
TCP cubic registered
NET: Registered protocol family 17
input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input3
NET: Registered protocol family 15
registered taskstats version 1
rtc_cmos 00:05: setting system clock to 2011-01-10 13:23:52 UTC (1294665832)
input: PS2++ Logitech Wheel Mouse as /devices/platform/i8042/serio1/input/input4
EXT3-fs (hdb1): error: couldn't mount because of unsupported optional features (240)
EXT4-fs (hdb1): INFO: recovery required on readonly filesystem
EXT4-fs (hdb1): write access will be enabled during recovery
EXT4-fs (hdb1): recovery complete
EXT4-fs (hdb1): mounted filesystem with ordered data mode. Opts: (null)
VFS: Mounted root (ext4 filesystem) readonly on device 3:65.
Freeing unused kernel memory: 320k freed
e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
e100: Copyright(c) 1999-2006 Intel Corporation
ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
ACPI: PCI Interrupt Link [LNKE] enabled at IRQ 10
PCI: setting IRQ 10 as level-triggered
ehci_hcd 0000:00:10.3: PCI INT D -> Link[LNKE] -> GSI 10 (level, low) -> IRQ 10
ehci_hcd 0000:00:10.3: EHCI Host Controller
ehci_hcd 0000:00:10.3: new USB bus registered, assigned bus number 1
ehci_hcd 0000:00:10.3: irq 10, io mem 0xcb000000
ehci_hcd 0000:00:10.3: USB 2.0 started, EHCI 1.00
usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb1: Product: EHCI Host Controller
usb usb1: Manufacturer: Linux 2.6.37-matthias ehci_hcd
usb usb1: SerialNumber: 0000:00:10.3
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 6 ports detected
usb 1-4: new high speed USB device using ehci_hcd and address 3
usb 1-4: New USB device found, idVendor=2001, idProduct=f103
usb 1-4: New USB device strings: Mfr=0, Product=0, SerialNumber=0
hub 1-4:1.0: USB hub found
hub 1-4:1.0: 7 ports detected
uhci_hcd: USB Universal Host Controller Interface driver
uhci_hcd 0000:00:10.0: PCI INT A -> Link[LNKE] -> GSI 10 (level, low) -> IRQ 10
uhci_hcd 0000:00:10.0: UHCI Host Controller
uhci_hcd 0000:00:10.0: new USB bus registered, assigned bus number 2
uhci_hcd 0000:00:10.0: irq 10, io base 0x00008000
usb usb2: New USB device found, idVendor=1d6b, idProduct=0001
usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb2: Product: UHCI Host Controller
usb usb2: Manufacturer: Linux 2.6.37-matthias uhci_hcd
usb usb2: SerialNumber: 0000:00:10.0
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 2 ports detected
uhci_hcd 0000:00:10.1: PCI INT B -> Link[LNKE] -> GSI 10 (level, low) -> IRQ 10
uhci_hcd 0000:00:10.1: UHCI Host Controller
uhci_hcd 0000:00:10.1: new USB bus registered, assigned bus number 3
uhci_hcd 0000:00:10.1: irq 10, io base 0x00007800
usb usb3: New USB device found, idVendor=1d6b, idProduct=0001
usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb3: Product: UHCI Host Controller
usb usb3: Manufacturer: Linux 2.6.37-matthias uhci_hcd
usb usb3: SerialNumber: 0000:00:10.1
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 2 ports detected
uhci_hcd 0000:00:10.2: PCI INT C -> Link[LNKE] -> GSI 10 (level, low) -> IRQ 10
uhci_hcd 0000:00:10.2: UHCI Host Controller
uhci_hcd 0000:00:10.2: new USB bus registered, assigned bus number 4
uhci_hcd 0000:00:10.2: irq 10, io base 0x00007400
usb usb4: New USB device found, idVendor=1d6b, idProduct=0001
usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb4: Product: UHCI Host Controller
usb usb4: Manufacturer: Linux 2.6.37-matthias uhci_hcd
usb usb4: SerialNumber: 0000:00:10.2
hub 4-0:1.0: USB hub found
hub 4-0:1.0: 2 ports detected
usb 3-1: new low speed USB device using uhci_hcd and address 2
usb 3-1: New USB device found, idVendor=0419, idProduct=8002
usb 3-1: New USB device strings: Mfr=1, Product=2, SerialNumber=3
usb 3-1: Product: Sam Sung Electronics
usb 3-1: Manufacturer: Samsung Electronics
usb 3-1: SerialNumber: 1234
Linux video capture interface: v2.00
IR NEC protocol handler initialized
IR RC5(x) protocol handler initialized
IR RC6 protocol handler initialized
IR JVC protocol handler initialized
bttv: driver version 0.9.18 loaded
bttv: using 8 buffers with 2080k (520 pages) each for capture
bttv: Bt8xx card found (0).
IR Sony protocol handler initialized
bttv 0000:00:0f.0: enabling device (0004 -> 0006)
bttv 0000:00:0f.0: PCI INT A -> Link[LNKC] -> GSI 9 (level, low) -> IRQ 9
bttv0: Bt878 (rev 17) at 0000:00:0f.0, irq: 9, latency: 32, mmio: 0xcf000000
lirc_dev: IR Remote Control driver registered, major 253 
bttv0: detected: Hauppauge WinTV [card=10], PCI subsystem ID is 0070:13eb
bttv0: using: Hauppauge (bt878) [card=10,autodetected]
bttv0: gpio: en=00000000, out=00000000 in=00ffffdb [init]
bttv0: Hauppauge/Voodoo msp34xx: reset line init [5]
IR LIRC bridge handler initialized
tveeprom 5-0050: Hauppauge model 44354, rev B121, serial# 2155401
tveeprom 5-0050: tuner model is Philips FM1216 (idx 21, type 5)
tveeprom 5-0050: TV standards PAL(B/G) (eeprom 0x04)
tveeprom 5-0050: audio processor is MSP3415 (idx 6)
tveeprom 5-0050: has radio
bttv0: Hauppauge eeprom indicates model#44354
bttv0: tuner type=5
msp3400 5-0040: MSP3415D-B3 found @ 0x80 (bt878 #0 [sw])
msp3400 5-0040: msp3400 supports nicam, mode is autodetect
tuner 5-0061: chip found @ 0xc2 (bt878 #0 [sw])
tuner-simple 5-0061: creating new instance
tuner-simple 5-0061: type set to 5 (Philips PAL_BG (FI1216 and compatibles))
bttv0: registered device video0
bttv0: registered device vbi0
bttv0: registered device radio0
bttv0: PLL: 28636363 => 35468950 .. ok
irda_init()
NET: Registered protocol family 23
irda_register_dongle : registering dongle "Actisys ACT-220L" (2).
irda_register_dongle : registering dongle "Actisys ACT-220L+" (3).
ENS1371 0000:00:0b.0: enabling device (0004 -> 0005)
ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 11
ENS1371 0000:00:0b.0: PCI INT A -> Link[LNKD] -> GSI 11 (level, low) -> IRQ 11
gameport gameport0: ES137x is pci0000:00:0b.0/gameport0, io 0x200, speed 978kHz
Bt87x 0000:00:0f.1: enabling device (0004 -> 0006)
DC390: clustering now enabled by default. If you get problems load
       with "disable_clustering=1" and report to maintainers
parport_pc 00:09: reported by Plug and Play ACPI
Bt87x 0000:00:0f.1: PCI INT A -> Link[LNKC] -> GSI 9 (level, low) -> IRQ 9
parport0: PC-style at 0x378 (0x778), irq 7, dma 3 [PCSPP,TRISTATE,COMPAT,ECP,DMA]
ALSA sound/pci/bt87x.c:937: bt87x0: Using board 1, analog, digital (rate 32000 Hz)
sata_sil 0000:00:0d.0: version 2.4
sata_sil 0000:00:0d.0: PCI INT A -> Link[LNKA] -> GSI 11 (level, low) -> IRQ 11
scsi0 : sata_sil
scsi1 : sata_sil
ata1: SATA max UDMA/100 mmio m512@0xcb800000 tf 0xcb800080 irq 11
ata2: SATA max UDMA/100 mmio m512@0xcb800000 tf 0xcb8000c0 irq 11
sata_promise 0000:00:08.0: version 2.12
ACPI: PCI Interrupt Link [LNKB] enabled at IRQ 10
sata_promise 0000:00:08.0: PCI INT A -> Link[LNKB] -> GSI 10 (level, low) -> IRQ 10
scsi2 : sata_promise
scsi3 : sata_promise
scsi4 : sata_promise
ata3: SATA max UDMA/133 mmio m4096@0xcd000000 ata 0xcd000200 irq 10
ata4: SATA max UDMA/133 mmio m4096@0xcd000000 ata 0xcd000280 irq 10
ata5: PATA max UDMA/133 mmio m4096@0xcd000000 ata 0xcd000300 irq 10
tmscsim 0000:00:0e.0: PCI INT A -> Link[LNKB] -> GSI 10 (level, low) -> IRQ 10
DC390_init: No EEPROM found! Trying default settings ...
DC390: Used defaults: AdaptID=7, SpeedIdx=0 (10.0 MHz), DevMode=0x1f, AdaptMode=0x2f, TaggedCmnds=3 (16), DelayReset=1s
ata1: SATA link down (SStatus 0 SControl 310)
scsi5 : Tekram DC390/AM53C974 V2.1d 2004-05-27
ACPI: PCI Interrupt Link [LNKF] enabled at IRQ 9
VIA 82xx Audio 0000:00:11.5: PCI INT C -> Link[LNKF] -> GSI 9 (level, low) -> IRQ 9
VIA 82xx Audio 0000:00:11.5: setting latency timer to 64
ata3: SATA link down (SStatus 0 SControl 300)
ata2: SATA link down (SStatus 0 SControl 310)
generic-usb 0003:0419:8002.0001: hiddev0: USB HID v1.10 Device [Samsung Electronics Sam Sung Electronics] on usb-0000:00:10.1-1/input0
usbcore: registered new interface driver usbhid
usbhid: USB HID core driver
ata4: SATA link down (SStatus 0 SControl 300)
Adding 2939856k swap on /dev/hdb5.  Priority:-1 extents:1 across:2939856k 
EXT4-fs (hdb1): re-mounted. Opts: (null)
EXT4-fs (hdb1): re-mounted. Opts: errors=remount-ro
BUG: scheduling while atomic: swapper/0/0x10010000
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100

Pid: 0, comm: swapper Not tainted 2.6.37-matthias #28 A7V8X/System Name
EIP: 0060:[<c10088ba>] EFLAGS: 00000246 CPU: 0
EIP is at default_idle+0x2a/0x40
EAX: 00000000 EBX: c1596140 ECX: 00000000 EDX: 00000000
ESI: 0008d800 EDI: c153d000 EBP: c153bfbc ESP: c153bfbc
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=f6004000 task=c1541300 task.ti=c153a000)
Stack:
 c153bfc4 c1001c7c c153bfcc c13e72a2 c153bfe4 c15706cd 000000a0 c15702b9
 c1596140 00000000 c153bff8 c157006b 01606d60 00000000 c14b0e88 01827003
 00000000
Call Trace:
 [<c1001c7c>] ? cpu_idle+0x2c/0x50
 [<c13e72a2>] ? rest_init+0x52/0x60
 [<c15706cd>] ? start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] ? i386_start_kernel+0x6b/0x6d
Code: 00 55 8b 0d 18 67 5c c1 89 e5 85 c9 75 2b 80 3d 05 d5 56 c1 00 74 22 89 e0 25 00 e0 ff ff 83 60 0c fb 8b 40 08 a8 08 75 15 fb f4 <89> e0 25 00 e0 ff ff 83 48 0c 04 c9 c3 90 fb f3 90 c9 c3 fb eb 
Call Trace:
 [<c1001c7c>] cpu_idle+0x2c/0x50
 [<c13e72a2>] rest_init+0x52/0x60
 [<c15706cd>] start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] i386_start_kernel+0x6b/0x6d
BUG: scheduling while atomic: swapper/0/0x10010000
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100

Pid: 0, comm: swapper Not tainted 2.6.37-matthias #28 A7V8X/System Name
EIP: 0060:[<c10088ba>] EFLAGS: 00000246 CPU: 0
EIP is at default_idle+0x2a/0x40
EAX: 00000000 EBX: c1596140 ECX: 00000000 EDX: 00000000
ESI: 0008d800 EDI: c153d000 EBP: c153bfbc ESP: c153bfbc
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=f6004000 task=c1541300 task.ti=c153a000)
Stack:
 c153bfc4 c1001c7c c153bfcc c13e72a2 c153bfe4 c15706cd 000000a0 c15702b9
 c1596140 00000000 c153bff8 c157006b 01606d60 00000000 c14b0e88 01827003
 00000000
Call Trace:
 [<c1001c7c>] ? cpu_idle+0x2c/0x50
 [<c13e72a2>] ? rest_init+0x52/0x60
 [<c15706cd>] ? start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] ? i386_start_kernel+0x6b/0x6d
Code: 00 55 8b 0d 18 67 5c c1 89 e5 85 c9 75 2b 80 3d 05 d5 56 c1 00 74 22 89 e0 25 00 e0 ff ff 83 60 0c fb 8b 40 08 a8 08 75 15 fb f4 <89> e0 25 00 e0 ff ff 83 48 0c 04 c9 c3 90 fb f3 90 c9 c3 fb eb 
Call Trace:
 [<c1001c7c>] cpu_idle+0x2c/0x50
 [<c13e72a2>] rest_init+0x52/0x60
 [<c15706cd>] start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] i386_start_kernel+0x6b/0x6d
BUG: scheduling while atomic: swapper/0/0x10010000
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100

Pid: 0, comm: swapper Not tainted 2.6.37-matthias #28 A7V8X/System Name
EIP: 0060:[<c10088ba>] EFLAGS: 00000246 CPU: 0
EIP is at default_idle+0x2a/0x40
EAX: 00000000 EBX: c1596140 ECX: 00000000 EDX: 00000000
ESI: 0008d800 EDI: c153d000 EBP: c153bfbc ESP: c153bfbc
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=f6004000 task=c1541300 task.ti=c153a000)
Stack:
 c153bfc4 c1001c7c c153bfcc c13e72a2 c153bfe4 c15706cd 000000a0 c15702b9
 c1596140 00000000 c153bff8 c157006b 01606d60 00000000 c14b0e88 01827003
 00000000
Call Trace:
 [<c1001c7c>] ? cpu_idle+0x2c/0x50
 [<c13e72a2>] ? rest_init+0x52/0x60
 [<c15706cd>] ? start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] ? i386_start_kernel+0x6b/0x6d
Code: 00 55 8b 0d 18 67 5c c1 89 e5 85 c9 75 2b 80 3d 05 d5 56 c1 00 74 22 89 e0 25 00 e0 ff ff 83 60 0c fb 8b 40 08 a8 08 75 15 fb f4 <89> e0 25 00 e0 ff ff 83 48 0c 04 c9 c3 90 fb f3 90 c9 c3 fb eb 
Call Trace:
 [<c1001c7c>] cpu_idle+0x2c/0x50
 [<c13e72a2>] rest_init+0x52/0x60
 [<c15706cd>] start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] i386_start_kernel+0x6b/0x6d
BUG: scheduling while atomic: swapper/0/0x10010000
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100

Pid: 0, comm: swapper Not tainted 2.6.37-matthias #28 A7V8X/System Name
EIP: 0060:[<c10088ba>] EFLAGS: 00000246 CPU: 0
EIP is at default_idle+0x2a/0x40
EAX: 00000000 EBX: c1596140 ECX: 00000000 EDX: 00000000
ESI: 0008d800 EDI: c153d000 EBP: c153bfbc ESP: c153bfbc
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=f6004000 task=c1541300 task.ti=c153a000)
Stack:
 c153bfc4 c1001c7c c153bfcc c13e72a2 c153bfe4 c15706cd 000000a0 c15702b9
 c1596140 00000000 c153bff8 c157006b 01606d60 00000000 c14b0e88 01827003
 00000000
Call Trace:
 [<c1001c7c>] ? cpu_idle+0x2c/0x50
 [<c13e72a2>] ? rest_init+0x52/0x60
 [<c15706cd>] ? start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] ? i386_start_kernel+0x6b/0x6d
Code: 00 55 8b 0d 18 67 5c c1 89 e5 85 c9 75 2b 80 3d 05 d5 56 c1 00 74 22 89 e0 25 00 e0 ff ff 83 60 0c fb 8b 40 08 a8 08 75 15 fb f4 <89> e0 25 00 e0 ff ff 83 48 0c 04 c9 c3 90 fb f3 90 c9 c3 fb eb 
Call Trace:
 [<c1001c7c>] cpu_idle+0x2c/0x50
 [<c13e72a2>] rest_init+0x52/0x60
 [<c15706cd>] start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] i386_start_kernel+0x6b/0x6d
BUG: scheduling while atomic: swapper/0/0x10010000
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100

Pid: 0, comm: swapper Not tainted 2.6.37-matthias #28 A7V8X/System Name
EIP: 0060:[<c10088ba>] EFLAGS: 00000246 CPU: 0
EIP is at default_idle+0x2a/0x40
EAX: 00000000 EBX: c1596140 ECX: 00000000 EDX: 00000000
ESI: 0008d800 EDI: c153d000 EBP: c153bfbc ESP: c153bfbc
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=f6004000 task=c1541300 task.ti=c153a000)
Stack:
 c153bfc4 c1001c7c c153bfcc c13e72a2 c153bfe4 c15706cd 000000a0 c15702b9
 c1596140 00000000 c153bff8 c157006b 01606d60 00000000 c14b0e88 01827003
 00000000
Call Trace:
 [<c1001c7c>] ? cpu_idle+0x2c/0x50
 [<c13e72a2>] ? rest_init+0x52/0x60
 [<c15706cd>] ? start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] ? i386_start_kernel+0x6b/0x6d
Code: 00 55 8b 0d 18 67 5c c1 89 e5 85 c9 75 2b 80 3d 05 d5 56 c1 00 74 22 89 e0 25 00 e0 ff ff 83 60 0c fb 8b 40 08 a8 08 75 15 fb f4 <89> e0 25 00 e0 ff ff 83 48 0c 04 c9 c3 90 fb f3 90 c9 c3 fb eb 
Call Trace:
 [<c1001c7c>] cpu_idle+0x2c/0x50
 [<c13e72a2>] rest_init+0x52/0x60
 [<c15706cd>] start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] i386_start_kernel+0x6b/0x6d
BUG: scheduling while atomic: swapper/0/0x10010000
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100

Pid: 0, comm: swapper Not tainted 2.6.37-matthias #28 A7V8X/System Name
EIP: 0060:[<c10088ba>] EFLAGS: 00000246 CPU: 0
EIP is at default_idle+0x2a/0x40
EAX: 00000000 EBX: c1596140 ECX: 00000000 EDX: 00000000
ESI: 0008d800 EDI: c153d000 EBP: c153bfbc ESP: c153bfbc
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=f6004000 task=c1541300 task.ti=c153a000)
Stack:
 c153bfc4 c1001c7c c153bfcc c13e72a2 c153bfe4 c15706cd 000000a0 c15702b9
 c1596140 00000000 c153bff8 c157006b 01606d60 00000000 c14b0e88 01827003
 00000000
Call Trace:
 [<c1001c7c>] ? cpu_idle+0x2c/0x50
 [<c13e72a2>] ? rest_init+0x52/0x60
 [<c15706cd>] ? start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] ? i386_start_kernel+0x6b/0x6d
Code: 00 55 8b 0d 18 67 5c c1 89 e5 85 c9 75 2b 80 3d 05 d5 56 c1 00 74 22 89 e0 25 00 e0 ff ff 83 60 0c fb 8b 40 08 a8 08 75 15 fb f4 <89> e0 25 00 e0 ff ff 83 48 0c 04 c9 c3 90 fb f3 90 c9 c3 fb eb 
Call Trace:
 [<c1001c7c>] cpu_idle+0x2c/0x50
 [<c13e72a2>] rest_init+0x52/0x60
 [<c15706cd>] start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] i386_start_kernel+0x6b/0x6d
BUG: scheduling while atomic: swapper/0/0x10010000
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100

Pid: 0, comm: swapper Not tainted 2.6.37-matthias #28 A7V8X/System Name
EIP: 0060:[<c10088ba>] EFLAGS: 00000246 CPU: 0
EIP is at default_idle+0x2a/0x40
EAX: 00000000 EBX: c1596140 ECX: 00000000 EDX: 00000000
ESI: 0008d800 EDI: c153d000 EBP: c153bfbc ESP: c153bfbc
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=f6004000 task=c1541300 task.ti=c153a000)
Stack:
 c153bfc4 c1001c7c c153bfcc c13e72a2 c153bfe4 c15706cd 000000a0 c15702b9
 c1596140 00000000 c153bff8 c157006b 01606d60 00000000 c14b0e88 01827003
 00000000
Call Trace:
 [<c1001c7c>] ? cpu_idle+0x2c/0x50
 [<c13e72a2>] ? rest_init+0x52/0x60
 [<c15706cd>] ? start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] ? i386_start_kernel+0x6b/0x6d
Code: 00 55 8b 0d 18 67 5c c1 89 e5 85 c9 75 2b 80 3d 05 d5 56 c1 00 74 22 89 e0 25 00 e0 ff ff 83 60 0c fb 8b 40 08 a8 08 75 15 fb f4 <89> e0 25 00 e0 ff ff 83 48 0c 04 c9 c3 90 fb f3 90 c9 c3 fb eb 
Call Trace:
 [<c1001c7c>] cpu_idle+0x2c/0x50
 [<c13e72a2>] rest_init+0x52/0x60
 [<c15706cd>] start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] i386_start_kernel+0x6b/0x6d
BUG: scheduling while atomic: swapper/0/0x10010000
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100

Pid: 0, comm: swapper Not tainted 2.6.37-matthias #28 A7V8X/System Name
EIP: 0060:[<c10088ba>] EFLAGS: 00000246 CPU: 0
EIP is at default_idle+0x2a/0x40
EAX: 00000000 EBX: c1596140 ECX: 00000000 EDX: 00000000
ESI: 0008d800 EDI: c153d000 EBP: c153bfbc ESP: c153bfbc
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=f6004000 task=c1541300 task.ti=c153a000)
Stack:
 c153bfc4 c1001c7c c153bfcc c13e72a2 c153bfe4 c15706cd 000000a0 c15702b9
 c1596140 00000000 c153bff8 c157006b 01606d60 00000000 c14b0e88 01827003
 00000000
Call Trace:
 [<c1001c7c>] ? cpu_idle+0x2c/0x50
 [<c13e72a2>] ? rest_init+0x52/0x60
 [<c15706cd>] ? start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] ? i386_start_kernel+0x6b/0x6d
Code: 00 55 8b 0d 18 67 5c c1 89 e5 85 c9 75 2b 80 3d 05 d5 56 c1 00 74 22 89 e0 25 00 e0 ff ff 83 60 0c fb 8b 40 08 a8 08 75 15 fb f4 <89> e0 25 00 e0 ff ff 83 48 0c 04 c9 c3 90 fb f3 90 c9 c3 fb eb 
Call Trace:
 [<c1001c7c>] cpu_idle+0x2c/0x50
 [<c13e72a2>] rest_init+0x52/0x60
 [<c15706cd>] start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] i386_start_kernel+0x6b/0x6d
BUG: scheduling while atomic: swapper/0/0x10010000
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100

Pid: 0, comm: swapper Not tainted 2.6.37-matthias #28 A7V8X/System Name
EIP: 0060:[<c10088ba>] EFLAGS: 00000246 CPU: 0
EIP is at default_idle+0x2a/0x40
EAX: 00000000 EBX: c1596140 ECX: 00000000 EDX: 00000000
ESI: 0008d800 EDI: c153d000 EBP: c153bfbc ESP: c153bfbc
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=f6004000 task=c1541300 task.ti=c153a000)
Stack:
 c153bfc4 c1001c7c c153bfcc c13e72a2 c153bfe4 c15706cd 000000a0 c15702b9
 c1596140 00000000 c153bff8 c157006b 01606d60 00000000 c14b0e88 01827003
 00000000
Call Trace:
 [<c1001c7c>] ? cpu_idle+0x2c/0x50
 [<c13e72a2>] ? rest_init+0x52/0x60
 [<c15706cd>] ? start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] ? i386_start_kernel+0x6b/0x6d
Code: 00 55 8b 0d 18 67 5c c1 89 e5 85 c9 75 2b 80 3d 05 d5 56 c1 00 74 22 89 e0 25 00 e0 ff ff 83 60 0c fb 8b 40 08 a8 08 75 15 fb f4 <89> e0 25 00 e0 ff ff 83 48 0c 04 c9 c3 90 fb f3 90 c9 c3 fb eb 
Call Trace:
 [<c1001c7c>] cpu_idle+0x2c/0x50
 [<c13e72a2>] rest_init+0x52/0x60
 [<c15706cd>] start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] i386_start_kernel+0x6b/0x6d
BUG: scheduling while atomic: swapper/0/0x10010000
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100

Pid: 0, comm: swapper Not tainted 2.6.37-matthias #28 A7V8X/System Name
EIP: 0060:[<c10088ba>] EFLAGS: 00000246 CPU: 0
EIP is at default_idle+0x2a/0x40
EAX: 00000000 EBX: c1596140 ECX: 00000000 EDX: 00000000
ESI: 0008d800 EDI: c153d000 EBP: c153bfbc ESP: c153bfbc
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=f6004000 task=c1541300 task.ti=c153a000)
Stack:
 c153bfc4 c1001c7c c153bfcc c13e72a2 c153bfe4 c15706cd 000000a0 c15702b9
 c1596140 00000000 c153bff8 c157006b 01606d60 00000000 c14b0e88 01827003
 00000000
Call Trace:
 [<c1001c7c>] ? cpu_idle+0x2c/0x50
 [<c13e72a2>] ? rest_init+0x52/0x60
 [<c15706cd>] ? start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] ? i386_start_kernel+0x6b/0x6d
Code: 00 55 8b 0d 18 67 5c c1 89 e5 85 c9 75 2b 80 3d 05 d5 56 c1 00 74 22 89 e0 25 00 e0 ff ff 83 60 0c fb 8b 40 08 a8 08 75 15 fb f4 <89> e0 25 00 e0 ff ff 83 48 0c 04 c9 c3 90 fb f3 90 c9 c3 fb eb 
Call Trace:
 [<c1001c7c>] cpu_idle+0x2c/0x50
 [<c13e72a2>] rest_init+0x52/0x60
 [<c15706cd>] start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] i386_start_kernel+0x6b/0x6d
BUG: scheduling while atomic: swapper/0/0x10010000
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100

Pid: 0, comm: swapper Not tainted 2.6.37-matthias #28 A7V8X/System Name
EIP: 0060:[<c10088ba>] EFLAGS: 00000246 CPU: 0
EIP is at default_idle+0x2a/0x40
EAX: 00000000 EBX: c1596140 ECX: 00000000 EDX: 00000000
ESI: 0008d800 EDI: c153d000 EBP: c153bfbc ESP: c153bfbc
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=f6004000 task=c1541300 task.ti=c153a000)
Stack:
 c153bfc4 c1001c7c c153bfcc c13e72a2 c153bfe4 c15706cd 000000a0 c15702b9
 c1596140 00000000 c153bff8 c157006b 01606d60 00000000 c14b0e88 01827003
 00000000
Call Trace:
 [<c1001c7c>] ? cpu_idle+0x2c/0x50
 [<c13e72a2>] ? rest_init+0x52/0x60
 [<c15706cd>] ? start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] ? i386_start_kernel+0x6b/0x6d
Code: 00 55 8b 0d 18 67 5c c1 89 e5 85 c9 75 2b 80 3d 05 d5 56 c1 00 74 22 89 e0 25 00 e0 ff ff 83 60 0c fb 8b 40 08 a8 08 75 15 fb f4 <89> e0 25 00 e0 ff ff 83 48 0c 04 c9 c3 90 fb f3 90 c9 c3 fb eb 
Call Trace:
 [<c1001c7c>] cpu_idle+0x2c/0x50
 [<c13e72a2>] rest_init+0x52/0x60
 [<c15706cd>] start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] i386_start_kernel+0x6b/0x6d
BUG: scheduling while atomic: swapper/0/0x10010000
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100

Pid: 0, comm: swapper Not tainted 2.6.37-matthias #28 A7V8X/System Name
EIP: 0060:[<c10088ba>] EFLAGS: 00000246 CPU: 0
EIP is at default_idle+0x2a/0x40
EAX: 00000000 EBX: c1596140 ECX: 00000000 EDX: 00000000
ESI: 0008d800 EDI: c153d000 EBP: c153bfbc ESP: c153bfbc
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=f6004000 task=c1541300 task.ti=c153a000)
Stack:
 c153bfc4 c1001c7c c153bfcc c13e72a2 c153bfe4 c15706cd 000000a0 c15702b9
 c1596140 00000000 c153bff8 c157006b 01606d60 00000000 c14b0e88 01827003
 00000000
Call Trace:
 [<c1001c7c>] ? cpu_idle+0x2c/0x50
 [<c13e72a2>] ? rest_init+0x52/0x60
 [<c15706cd>] ? start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] ? i386_start_kernel+0x6b/0x6d
Code: 00 55 8b 0d 18 67 5c c1 89 e5 85 c9 75 2b 80 3d 05 d5 56 c1 00 74 22 89 e0 25 00 e0 ff ff 83 60 0c fb 8b 40 08 a8 08 75 15 fb f4 <89> e0 25 00 e0 ff ff 83 48 0c 04 c9 c3 90 fb f3 90 c9 c3 fb eb 
Call Trace:
 [<c1001c7c>] cpu_idle+0x2c/0x50
 [<c13e72a2>] rest_init+0x52/0x60
 [<c15706cd>] start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] i386_start_kernel+0x6b/0x6d
BUG: scheduling while atomic: swapper/0/0x10010000
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100

Pid: 0, comm: swapper Not tainted 2.6.37-matthias #28 A7V8X/System Name
EIP: 0060:[<c10088ba>] EFLAGS: 00000246 CPU: 0
EIP is at default_idle+0x2a/0x40
EAX: 00000000 EBX: c1596140 ECX: 00000000 EDX: 00000000
ESI: 0008d800 EDI: c153d000 EBP: c153bfbc ESP: c153bfbc
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=f6004000 task=c1541300 task.ti=c153a000)
Stack:
 c153bfc4 c1001c7c c153bfcc c13e72a2 c153bfe4 c15706cd 000000a0 c15702b9
 c1596140 00000000 c153bff8 c157006b 01606d60 00000000 c14b0e88 01827003
 00000000
Call Trace:
 [<c1001c7c>] ? cpu_idle+0x2c/0x50
 [<c13e72a2>] ? rest_init+0x52/0x60
 [<c15706cd>] ? start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] ? i386_start_kernel+0x6b/0x6d
Code: 00 55 8b 0d 18 67 5c c1 89 e5 85 c9 75 2b 80 3d 05 d5 56 c1 00 74 22 89 e0 25 00 e0 ff ff 83 60 0c fb 8b 40 08 a8 08 75 15 fb f4 <89> e0 25 00 e0 ff ff 83 48 0c 04 c9 c3 90 fb f3 90 c9 c3 fb eb 
Call Trace:
 [<c1001c7c>] cpu_idle+0x2c/0x50
 [<c13e72a2>] rest_init+0x52/0x60
 [<c15706cd>] start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] i386_start_kernel+0x6b/0x6d
BUG: scheduling while atomic: swapper/0/0x10010000
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100

Pid: 0, comm: swapper Not tainted 2.6.37-matthias #28 A7V8X/System Name
EIP: 0060:[<c10088ba>] EFLAGS: 00000246 CPU: 0
EIP is at default_idle+0x2a/0x40
EAX: 00000000 EBX: c1596140 ECX: 00000000 EDX: 00000000
ESI: 0008d800 EDI: c153d000 EBP: c153bfbc ESP: c153bfbc
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=f6004000 task=c1541300 task.ti=c153a000)
Stack:
 c153bfc4 c1001c7c c153bfcc c13e72a2 c153bfe4 c15706cd 000000a0 c15702b9
 c1596140 00000000 c153bff8 c157006b 01606d60 00000000 c14b0e88 01827003
 00000000
Call Trace:
 [<c1001c7c>] ? cpu_idle+0x2c/0x50
 [<c13e72a2>] ? rest_init+0x52/0x60
 [<c15706cd>] ? start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] ? i386_start_kernel+0x6b/0x6d
Code: 00 55 8b 0d 18 67 5c c1 89 e5 85 c9 75 2b 80 3d 05 d5 56 c1 00 74 22 89 e0 25 00 e0 ff ff 83 60 0c fb 8b 40 08 a8 08 75 15 fb f4 <89> e0 25 00 e0 ff ff 83 48 0c 04 c9 c3 90 fb f3 90 c9 c3 fb eb 
Call Trace:
 [<c1001c7c>] cpu_idle+0x2c/0x50
 [<c13e72a2>] rest_init+0x52/0x60
 [<c15706cd>] start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] i386_start_kernel+0x6b/0x6d
BUG: scheduling while atomic: swapper/0/0x10010000
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100

Pid: 0, comm: swapper Not tainted 2.6.37-matthias #28 A7V8X/System Name
EIP: 0060:[<c10088ba>] EFLAGS: 00000246 CPU: 0
EIP is at default_idle+0x2a/0x40
EAX: 00000000 EBX: c1596140 ECX: 00000000 EDX: 00000000
ESI: 0008d800 EDI: c153d000 EBP: c153bfbc ESP: c153bfbc
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=f6004000 task=c1541300 task.ti=c153a000)
Stack:
 c153bfc4 c1001c7c c153bfcc c13e72a2 c153bfe4 c15706cd 000000a0 c15702b9
 c1596140 00000000 c153bff8 c157006b 01606d60 00000000 c14b0e88 01827003
 00000000
Call Trace:
 [<c1001c7c>] ? cpu_idle+0x2c/0x50
 [<c13e72a2>] ? rest_init+0x52/0x60
 [<c15706cd>] ? start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] ? i386_start_kernel+0x6b/0x6d
Code: 00 55 8b 0d 18 67 5c c1 89 e5 85 c9 75 2b 80 3d 05 d5 56 c1 00 74 22 89 e0 25 00 e0 ff ff 83 60 0c fb 8b 40 08 a8 08 75 15 fb f4 <89> e0 25 00 e0 ff ff 83 48 0c 04 c9 c3 90 fb f3 90 c9 c3 fb eb 
Call Trace:
 [<c1001c7c>] cpu_idle+0x2c/0x50
 [<c13e72a2>] rest_init+0x52/0x60
 [<c15706cd>] start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] i386_start_kernel+0x6b/0x6d
BUG: scheduling while atomic: swapper/0/0x10010000
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100

Pid: 0, comm: swapper Not tainted 2.6.37-matthias #28 A7V8X/System Name
EIP: 0060:[<c10088ba>] EFLAGS: 00000246 CPU: 0
EIP is at default_idle+0x2a/0x40
EAX: 00000000 EBX: c1596140 ECX: 00000000 EDX: 00000000
ESI: 0008d800 EDI: c153d000 EBP: c153bfbc ESP: c153bfbc
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=f6004000 task=c1541300 task.ti=c153a000)
Stack:
 c153bfc4 c1001c7c c153bfcc c13e72a2 c153bfe4 c15706cd 000000a0 c15702b9
 c1596140 00000000 c153bff8 c157006b 01606d60 00000000 c14b0e88 01827003
 00000000
Call Trace:
 [<c1001c7c>] ? cpu_idle+0x2c/0x50
 [<c13e72a2>] ? rest_init+0x52/0x60
 [<c15706cd>] ? start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] ? i386_start_kernel+0x6b/0x6d
Code: 00 55 8b 0d 18 67 5c c1 89 e5 85 c9 75 2b 80 3d 05 d5 56 c1 00 74 22 89 e0 25 00 e0 ff ff 83 60 0c fb 8b 40 08 a8 08 75 15 fb f4 <89> e0 25 00 e0 ff ff 83 48 0c 04 c9 c3 90 fb f3 90 c9 c3 fb eb 
Call Trace:
 [<c1001c7c>] cpu_idle+0x2c/0x50
 [<c13e72a2>] rest_init+0x52/0x60
 [<c15706cd>] start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] i386_start_kernel+0x6b/0x6d
BUG: scheduling while atomic: swapper/0/0x10010000
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100

Pid: 0, comm: swapper Not tainted 2.6.37-matthias #28 A7V8X/System Name
EIP: 0060:[<c10088ba>] EFLAGS: 00000246 CPU: 0
EIP is at default_idle+0x2a/0x40
EAX: 00000000 EBX: c1596140 ECX: 00000000 EDX: 00000000
ESI: 0008d800 EDI: c153d000 EBP: c153bfbc ESP: c153bfbc
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=f6004000 task=c1541300 task.ti=c153a000)
Stack:
 c153bfc4 c1001c7c c153bfcc c13e72a2 c153bfe4 c15706cd 000000a0 c15702b9
 c1596140 00000000 c153bff8 c157006b 01606d60 00000000 c14b0e88 01827003
 00000000
Call Trace:
 [<c1001c7c>] ? cpu_idle+0x2c/0x50
 [<c13e72a2>] ? rest_init+0x52/0x60
 [<c15706cd>] ? start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] ? i386_start_kernel+0x6b/0x6d
Code: 00 55 8b 0d 18 67 5c c1 89 e5 85 c9 75 2b 80 3d 05 d5 56 c1 00 74 22 89 e0 25 00 e0 ff ff 83 60 0c fb 8b 40 08 a8 08 75 15 fb f4 <89> e0 25 00 e0 ff ff 83 48 0c 04 c9 c3 90 fb f3 90 c9 c3 fb eb 
Call Trace:
 [<c1001c7c>] cpu_idle+0x2c/0x50
 [<c13e72a2>] rest_init+0x52/0x60
 [<c15706cd>] start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] i386_start_kernel+0x6b/0x6d
BUG: scheduling while atomic: swapper/0/0x10010000
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100

Pid: 0, comm: swapper Not tainted 2.6.37-matthias #28 A7V8X/System Name
EIP: 0060:[<c10088ba>] EFLAGS: 00000246 CPU: 0
EIP is at default_idle+0x2a/0x40
EAX: 00000000 EBX: c1596140 ECX: 00000000 EDX: 00000000
ESI: 0008d800 EDI: c153d000 EBP: c153bfbc ESP: c153bfbc
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=f6004000 task=c1541300 task.ti=c153a000)
Stack:
 c153bfc4 c1001c7c c153bfcc c13e72a2 c153bfe4 c15706cd 000000a0 c15702b9
 c1596140 00000000 c153bff8 c157006b 01606d60 00000000 c14b0e88 01827003
 00000000
Call Trace:
 [<c1001c7c>] ? cpu_idle+0x2c/0x50
 [<c13e72a2>] ? rest_init+0x52/0x60
 [<c15706cd>] ? start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] ? i386_start_kernel+0x6b/0x6d
Code: 00 55 8b 0d 18 67 5c c1 89 e5 85 c9 75 2b 80 3d 05 d5 56 c1 00 74 22 89 e0 25 00 e0 ff ff 83 60 0c fb 8b 40 08 a8 08 75 15 fb f4 <89> e0 25 00 e0 ff ff 83 48 0c 04 c9 c3 90 fb f3 90 c9 c3 fb eb 
Call Trace:
 [<c1001c7c>] cpu_idle+0x2c/0x50
 [<c13e72a2>] rest_init+0x52/0x60
 [<c15706cd>] start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] i386_start_kernel+0x6b/0x6d
BUG: scheduling while atomic: swapper/0/0x10010000
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100

Pid: 0, comm: swapper Not tainted 2.6.37-matthias #28 A7V8X/System Name
EIP: 0060:[<c10088ba>] EFLAGS: 00000246 CPU: 0
EIP is at default_idle+0x2a/0x40
EAX: 00000000 EBX: c1596140 ECX: 00000000 EDX: 00000000
ESI: 0008d800 EDI: c153d000 EBP: c153bfbc ESP: c153bfbc
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=f6004000 task=c1541300 task.ti=c153a000)
Stack:
 c153bfc4 c1001c7c c153bfcc c13e72a2 c153bfe4 c15706cd 000000a0 c15702b9
 c1596140 00000000 c153bff8 c157006b 01606d60 00000000 c14b0e88 01827003
 00000000
Call Trace:
 [<c1001c7c>] ? cpu_idle+0x2c/0x50
 [<c13e72a2>] ? rest_init+0x52/0x60
 [<c15706cd>] ? start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] ? i386_start_kernel+0x6b/0x6d
Code: 00 55 8b 0d 18 67 5c c1 89 e5 85 c9 75 2b 80 3d 05 d5 56 c1 00 74 22 89 e0 25 00 e0 ff ff 83 60 0c fb 8b 40 08 a8 08 75 15 fb f4 <89> e0 25 00 e0 ff ff 83 48 0c 04 c9 c3 90 fb f3 90 c9 c3 fb eb 
Call Trace:
 [<c1001c7c>] cpu_idle+0x2c/0x50
 [<c13e72a2>] rest_init+0x52/0x60
 [<c15706cd>] start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] i386_start_kernel+0x6b/0x6d
BUG: scheduling while atomic: swapper/0/0x10010000
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100

Pid: 0, comm: swapper Not tainted 2.6.37-matthias #28 A7V8X/System Name
EIP: 0060:[<c10088ba>] EFLAGS: 00000246 CPU: 0
EIP is at default_idle+0x2a/0x40
EAX: 00000000 EBX: c1596140 ECX: 00000000 EDX: 00000000
ESI: 0008d800 EDI: c153d000 EBP: c153bfbc ESP: c153bfbc
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=f6004000 task=c1541300 task.ti=c153a000)
Stack:
 c153bfc4 c1001c7c c153bfcc c13e72a2 c153bfe4 c15706cd 000000a0 c15702b9
 c1596140 00000000 c153bff8 c157006b 01606d60 00000000 c14b0e88 01827003
 00000000
Call Trace:
 [<c1001c7c>] ? cpu_idle+0x2c/0x50
 [<c13e72a2>] ? rest_init+0x52/0x60
 [<c15706cd>] ? start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] ? i386_start_kernel+0x6b/0x6d
Code: 00 55 8b 0d 18 67 5c c1 89 e5 85 c9 75 2b 80 3d 05 d5 56 c1 00 74 22 89 e0 25 00 e0 ff ff 83 60 0c fb 8b 40 08 a8 08 75 15 fb f4 <89> e0 25 00 e0 ff ff 83 48 0c 04 c9 c3 90 fb f3 90 c9 c3 fb eb 
Call Trace:
 [<c1001c7c>] cpu_idle+0x2c/0x50
 [<c13e72a2>] rest_init+0x52/0x60
 [<c15706cd>] start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] i386_start_kernel+0x6b/0x6d
BUG: scheduling while atomic: swapper/0/0x10010000
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100

Pid: 0, comm: swapper Not tainted 2.6.37-matthias #28 A7V8X/System Name
EIP: 0060:[<c10088ba>] EFLAGS: 00000246 CPU: 0
EIP is at default_idle+0x2a/0x40
EAX: 00000000 EBX: c1596140 ECX: 00000000 EDX: 00000000
ESI: 0008d800 EDI: c153d000 EBP: c153bfbc ESP: c153bfbc
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=f6004000 task=c1541300 task.ti=c153a000)
Stack:
 c153bfc4 c1001c7c c153bfcc c13e72a2 c153bfe4 c15706cd 000000a0 c15702b9
 c1596140 00000000 c153bff8 c157006b 01606d60 00000000 c14b0e88 01827003
 00000000
Call Trace:
 [<c1001c7c>] ? cpu_idle+0x2c/0x50
 [<c13e72a2>] ? rest_init+0x52/0x60
 [<c15706cd>] ? start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] ? i386_start_kernel+0x6b/0x6d
Code: 00 55 8b 0d 18 67 5c c1 89 e5 85 c9 75 2b 80 3d 05 d5 56 c1 00 74 22 89 e0 25 00 e0 ff ff 83 60 0c fb 8b 40 08 a8 08 75 15 fb f4 <89> e0 25 00 e0 ff ff 83 48 0c 04 c9 c3 90 fb f3 90 c9 c3 fb eb 
Call Trace:
 [<c1001c7c>] cpu_idle+0x2c/0x50
 [<c13e72a2>] rest_init+0x52/0x60
 [<c15706cd>] start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] i386_start_kernel+0x6b/0x6d
BUG: scheduling while atomic: swapper/0/0x10010000
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100

Pid: 0, comm: swapper Not tainted 2.6.37-matthias #28 A7V8X/System Name
EIP: 0060:[<c10088ba>] EFLAGS: 00000246 CPU: 0
EIP is at default_idle+0x2a/0x40
EAX: 00000000 EBX: c1596140 ECX: 00000000 EDX: 00000000
ESI: 0008d800 EDI: c153d000 EBP: c153bfbc ESP: c153bfbc
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=f6004000 task=c1541300 task.ti=c153a000)
Stack:
 c153bfc4 c1001c7c c153bfcc c13e72a2 c153bfe4 c15706cd 000000a0 c15702b9
 c1596140 00000000 c153bff8 c157006b 01606d60 00000000 c14b0e88 01827003
 00000000
Call Trace:
 [<c1001c7c>] ? cpu_idle+0x2c/0x50
 [<c13e72a2>] ? rest_init+0x52/0x60
 [<c15706cd>] ? start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] ? i386_start_kernel+0x6b/0x6d
Code: 00 55 8b 0d 18 67 5c c1 89 e5 85 c9 75 2b 80 3d 05 d5 56 c1 00 74 22 89 e0 25 00 e0 ff ff 83 60 0c fb 8b 40 08 a8 08 75 15 fb f4 <89> e0 25 00 e0 ff ff 83 48 0c 04 c9 c3 90 fb f3 90 c9 c3 fb eb 
Call Trace:
 [<c1001c7c>] cpu_idle+0x2c/0x50
 [<c13e72a2>] rest_init+0x52/0x60
 [<c15706cd>] start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] i386_start_kernel+0x6b/0x6d
BUG: scheduling while atomic: swapper/0/0x10010000
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100

Pid: 0, comm: swapper Not tainted 2.6.37-matthias #28 A7V8X/System Name
EIP: 0060:[<c10088ba>] EFLAGS: 00000246 CPU: 0
EIP is at default_idle+0x2a/0x40
EAX: 00000000 EBX: c1596140 ECX: 00000000 EDX: 00000000
ESI: 0008d800 EDI: c153d000 EBP: c153bfbc ESP: c153bfbc
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=f6004000 task=c1541300 task.ti=c153a000)
Stack:
 c153bfc4 c1001c7c c153bfcc c13e72a2 c153bfe4 c15706cd 000000a0 c15702b9
 c1596140 00000000 c153bff8 c157006b 01606d60 00000000 c14b0e88 01827003
 00000000
Call Trace:
 [<c1001c7c>] ? cpu_idle+0x2c/0x50
 [<c13e72a2>] ? rest_init+0x52/0x60
 [<c15706cd>] ? start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] ? i386_start_kernel+0x6b/0x6d
Code: 00 55 8b 0d 18 67 5c c1 89 e5 85 c9 75 2b 80 3d 05 d5 56 c1 00 74 22 89 e0 25 00 e0 ff ff 83 60 0c fb 8b 40 08 a8 08 75 15 fb f4 <89> e0 25 00 e0 ff ff 83 48 0c 04 c9 c3 90 fb f3 90 c9 c3 fb eb 
Call Trace:
 [<c1001c7c>] cpu_idle+0x2c/0x50
 [<c13e72a2>] rest_init+0x52/0x60
 [<c15706cd>] start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] i386_start_kernel+0x6b/0x6d
BUG: scheduling while atomic: swapper/0/0x10010000
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100

Pid: 0, comm: swapper Not tainted 2.6.37-matthias #28 A7V8X/System Name
EIP: 0060:[<c10088ba>] EFLAGS: 00000246 CPU: 0
EIP is at default_idle+0x2a/0x40
EAX: 00000000 EBX: c1596140 ECX: 00000000 EDX: 00000000
ESI: 0008d800 EDI: c153d000 EBP: c153bfbc ESP: c153bfbc
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=f6004000 task=c1541300 task.ti=c153a000)
Stack:
 c153bfc4 c1001c7c c153bfcc c13e72a2 c153bfe4 c15706cd 000000a0 c15702b9
 c1596140 00000000 c153bff8 c157006b 01606d60 00000000 c14b0e88 01827003
 00000000
Call Trace:
 [<c1001c7c>] ? cpu_idle+0x2c/0x50
 [<c13e72a2>] ? rest_init+0x52/0x60
 [<c15706cd>] ? start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] ? i386_start_kernel+0x6b/0x6d
Code: 00 55 8b 0d 18 67 5c c1 89 e5 85 c9 75 2b 80 3d 05 d5 56 c1 00 74 22 89 e0 25 00 e0 ff ff 83 60 0c fb 8b 40 08 a8 08 75 15 fb f4 <89> e0 25 00 e0 ff ff 83 48 0c 04 c9 c3 90 fb f3 90 c9 c3 fb eb 
Call Trace:
 [<c1001c7c>] cpu_idle+0x2c/0x50
 [<c13e72a2>] rest_init+0x52/0x60
 [<c15706cd>] start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] i386_start_kernel+0x6b/0x6d
BUG: scheduling while atomic: swapper/0/0x10010000
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100

Pid: 0, comm: swapper Not tainted 2.6.37-matthias #28 A7V8X/System Name
EIP: 0060:[<c10088ba>] EFLAGS: 00000246 CPU: 0
EIP is at default_idle+0x2a/0x40
EAX: 00000000 EBX: c1596140 ECX: 00000000 EDX: 00000000
ESI: 0008d800 EDI: c153d000 EBP: c153bfbc ESP: c153bfbc
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=f6004000 task=c1541300 task.ti=c153a000)
Stack:
 c153bfc4 c1001c7c c153bfcc c13e72a2 c153bfe4 c15706cd 000000a0 c15702b9
 c1596140 00000000 c153bff8 c157006b 01606d60 00000000 c14b0e88 01827003
 00000000
Call Trace:
 [<c1001c7c>] ? cpu_idle+0x2c/0x50
 [<c13e72a2>] ? rest_init+0x52/0x60
 [<c15706cd>] ? start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] ? i386_start_kernel+0x6b/0x6d
Code: 00 55 8b 0d 18 67 5c c1 89 e5 85 c9 75 2b 80 3d 05 d5 56 c1 00 74 22 89 e0 25 00 e0 ff ff 83 60 0c fb 8b 40 08 a8 08 75 15 fb f4 <89> e0 25 00 e0 ff ff 83 48 0c 04 c9 c3 90 fb f3 90 c9 c3 fb eb 
Call Trace:
 [<c1001c7c>] cpu_idle+0x2c/0x50
 [<c13e72a2>] rest_init+0x52/0x60
 [<c15706cd>] start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] i386_start_kernel+0x6b/0x6d
BUG: scheduling while atomic: swapper/0/0x10010000
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100

Pid: 0, comm: swapper Not tainted 2.6.37-matthias #28 A7V8X/System Name
EIP: 0060:[<c10088ba>] EFLAGS: 00000246 CPU: 0
EIP is at default_idle+0x2a/0x40
EAX: 00000000 EBX: c1596140 ECX: 00000000 EDX: 00000000
ESI: 0008d800 EDI: c153d000 EBP: c153bfbc ESP: c153bfbc
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=f6004000 task=c1541300 task.ti=c153a000)
Stack:
 c153bfc4 c1001c7c c153bfcc c13e72a2 c153bfe4 c15706cd 000000a0 c15702b9
 c1596140 00000000 c153bff8 c157006b 01606d60 00000000 c14b0e88 01827003
 00000000
Call Trace:
 [<c1001c7c>] ? cpu_idle+0x2c/0x50
 [<c13e72a2>] ? rest_init+0x52/0x60
 [<c15706cd>] ? start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] ? i386_start_kernel+0x6b/0x6d
Code: 00 55 8b 0d 18 67 5c c1 89 e5 85 c9 75 2b 80 3d 05 d5 56 c1 00 74 22 89 e0 25 00 e0 ff ff 83 60 0c fb 8b 40 08 a8 08 75 15 fb f4 <89> e0 25 00 e0 ff ff 83 48 0c 04 c9 c3 90 fb f3 90 c9 c3 fb eb 
Call Trace:
 [<c1001c7c>] cpu_idle+0x2c/0x50
 [<c13e72a2>] rest_init+0x52/0x60
 [<c15706cd>] start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] i386_start_kernel+0x6b/0x6d
BUG: scheduling while atomic: swapper/0/0x10010000
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100

Pid: 0, comm: swapper Not tainted 2.6.37-matthias #28 A7V8X/System Name
EIP: 0060:[<c10088ba>] EFLAGS: 00000246 CPU: 0
EIP is at default_idle+0x2a/0x40
EAX: 00000000 EBX: c1596140 ECX: 00000000 EDX: 00000000
ESI: 0008d800 EDI: c153d000 EBP: c153bfbc ESP: c153bfbc
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=f6004000 task=c1541300 task.ti=c153a000)
Stack:
 c153bfc4 c1001c7c c153bfcc c13e72a2 c153bfe4 c15706cd 000000a0 c15702b9
 c1596140 00000000 c153bff8 c157006b 01606d60 00000000 c14b0e88 01827003
 00000000
Call Trace:
 [<c1001c7c>] ? cpu_idle+0x2c/0x50
 [<c13e72a2>] ? rest_init+0x52/0x60
 [<c15706cd>] ? start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] ? i386_start_kernel+0x6b/0x6d
Code: 00 55 8b 0d 18 67 5c c1 89 e5 85 c9 75 2b 80 3d 05 d5 56 c1 00 74 22 89 e0 25 00 e0 ff ff 83 60 0c fb 8b 40 08 a8 08 75 15 fb f4 <89> e0 25 00 e0 ff ff 83 48 0c 04 c9 c3 90 fb f3 90 c9 c3 fb eb 
Call Trace:
 [<c1001c7c>] cpu_idle+0x2c/0x50
 [<c13e72a2>] rest_init+0x52/0x60
 [<c15706cd>] start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] i386_start_kernel+0x6b/0x6d
BUG: scheduling while atomic: swapper/0/0x10010000
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100

Pid: 0, comm: swapper Not tainted 2.6.37-matthias #28 A7V8X/System Name
EIP: 0060:[<c10088ba>] EFLAGS: 00000246 CPU: 0
EIP is at default_idle+0x2a/0x40
EAX: 00000000 EBX: c1596140 ECX: 00000000 EDX: 00000000
ESI: 0008d800 EDI: c153d000 EBP: c153bfbc ESP: c153bfbc
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=f6004000 task=c1541300 task.ti=c153a000)
Stack:
 c153bfc4 c1001c7c c153bfcc c13e72a2 c153bfe4 c15706cd 000000a0 c15702b9
 c1596140 00000000 c153bff8 c157006b 01606d60 00000000 c14b0e88 01827003
 00000000
Call Trace:
 [<c1001c7c>] ? cpu_idle+0x2c/0x50
 [<c13e72a2>] ? rest_init+0x52/0x60
 [<c15706cd>] ? start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] ? i386_start_kernel+0x6b/0x6d
Code: 00 55 8b 0d 18 67 5c c1 89 e5 85 c9 75 2b 80 3d 05 d5 56 c1 00 74 22 89 e0 25 00 e0 ff ff 83 60 0c fb 8b 40 08 a8 08 75 15 fb f4 <89> e0 25 00 e0 ff ff 83 48 0c 04 c9 c3 90 fb f3 90 c9 c3 fb eb 
Call Trace:
 [<c1001c7c>] cpu_idle+0x2c/0x50
 [<c13e72a2>] rest_init+0x52/0x60
 [<c15706cd>] start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] i386_start_kernel+0x6b/0x6d
BUG: scheduling while atomic: swapper/0/0x10010000
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100

Pid: 0, comm: swapper Not tainted 2.6.37-matthias #28 A7V8X/System Name
EIP: 0060:[<c10088ba>] EFLAGS: 00000246 CPU: 0
EIP is at default_idle+0x2a/0x40
EAX: 00000000 EBX: c1596140 ECX: 00000000 EDX: 00000000
ESI: 0008d800 EDI: c153d000 EBP: c153bfbc ESP: c153bfbc
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=f6004000 task=c1541300 task.ti=c153a000)
Stack:
 c153bfc4 c1001c7c c153bfcc c13e72a2 c153bfe4 c15706cd 000000a0 c15702b9
 c1596140 00000000 c153bff8 c157006b 01606d60 00000000 c14b0e88 01827003
 00000000
Call Trace:
 [<c1001c7c>] ? cpu_idle+0x2c/0x50
 [<c13e72a2>] ? rest_init+0x52/0x60
 [<c15706cd>] ? start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] ? i386_start_kernel+0x6b/0x6d
Code: 00 55 8b 0d 18 67 5c c1 89 e5 85 c9 75 2b 80 3d 05 d5 56 c1 00 74 22 89 e0 25 00 e0 ff ff 83 60 0c fb 8b 40 08 a8 08 75 15 fb f4 <89> e0 25 00 e0 ff ff 83 48 0c 04 c9 c3 90 fb f3 90 c9 c3 fb eb 
Call Trace:
 [<c1001c7c>] cpu_idle+0x2c/0x50
 [<c13e72a2>] rest_init+0x52/0x60
 [<c15706cd>] start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] i386_start_kernel+0x6b/0x6d
BUG: scheduling while atomic: swapper/0/0x10010000
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100

Pid: 0, comm: swapper Not tainted 2.6.37-matthias #28 A7V8X/System Name
EIP: 0060:[<c10088ba>] EFLAGS: 00000246 CPU: 0
EIP is at default_idle+0x2a/0x40
EAX: 00000000 EBX: c1596140 ECX: 00000000 EDX: 00000000
ESI: 0008d800 EDI: c153d000 EBP: c153bfbc ESP: c153bfbc
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=f6004000 task=c1541300 task.ti=c153a000)
Stack:
 c153bfc4 c1001c7c c153bfcc c13e72a2 c153bfe4 c15706cd 000000a0 c15702b9
 c1596140 00000000 c153bff8 c157006b 01606d60 00000000 c14b0e88 01827003
 00000000
Call Trace:
 [<c1001c7c>] ? cpu_idle+0x2c/0x50
 [<c13e72a2>] ? rest_init+0x52/0x60
 [<c15706cd>] ? start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] ? i386_start_kernel+0x6b/0x6d
Code: 00 55 8b 0d 18 67 5c c1 89 e5 85 c9 75 2b 80 3d 05 d5 56 c1 00 74 22 89 e0 25 00 e0 ff ff 83 60 0c fb 8b 40 08 a8 08 75 15 fb f4 <89> e0 25 00 e0 ff ff 83 48 0c 04 c9 c3 90 fb f3 90 c9 c3 fb eb 
Call Trace:
 [<c1001c7c>] cpu_idle+0x2c/0x50
 [<c13e72a2>] rest_init+0x52/0x60
 [<c15706cd>] start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] i386_start_kernel+0x6b/0x6d
BUG: scheduling while atomic: swapper/0/0x10010000
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100

Pid: 0, comm: swapper Not tainted 2.6.37-matthias #28 A7V8X/System Name
EIP: 0060:[<c10088ba>] EFLAGS: 00000246 CPU: 0
EIP is at default_idle+0x2a/0x40
EAX: 00000000 EBX: c1596140 ECX: 00000000 EDX: 00000000
ESI: 0008d800 EDI: c153d000 EBP: c153bfbc ESP: c153bfbc
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=f6004000 task=c1541300 task.ti=c153a000)
Stack:
 c153bfc4 c1001c7c c153bfcc c13e72a2 c153bfe4 c15706cd 000000a0 c15702b9
 c1596140 00000000 c153bff8 c157006b 01606d60 00000000 c14b0e88 01827003
 00000000
Call Trace:
 [<c1001c7c>] ? cpu_idle+0x2c/0x50
 [<c13e72a2>] ? rest_init+0x52/0x60
 [<c15706cd>] ? start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] ? i386_start_kernel+0x6b/0x6d
Code: 00 55 8b 0d 18 67 5c c1 89 e5 85 c9 75 2b 80 3d 05 d5 56 c1 00 74 22 89 e0 25 00 e0 ff ff 83 60 0c fb 8b 40 08 a8 08 75 15 fb f4 <89> e0 25 00 e0 ff ff 83 48 0c 04 c9 c3 90 fb f3 90 c9 c3 fb eb 
Call Trace:
 [<c1001c7c>] cpu_idle+0x2c/0x50
 [<c13e72a2>] rest_init+0x52/0x60
 [<c15706cd>] start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] i386_start_kernel+0x6b/0x6d
BUG: scheduling while atomic: swapper/0/0x10010000
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100

Pid: 0, comm: swapper Not tainted 2.6.37-matthias #28 A7V8X/System Name
EIP: 0060:[<c10088ba>] EFLAGS: 00000246 CPU: 0
EIP is at default_idle+0x2a/0x40
EAX: 00000000 EBX: c1596140 ECX: 00000000 EDX: 00000000
ESI: 0008d800 EDI: c153d000 EBP: c153bfbc ESP: c153bfbc
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=f6004000 task=c1541300 task.ti=c153a000)
Stack:
 c153bfc4 c1001c7c c153bfcc c13e72a2 c153bfe4 c15706cd 000000a0 c15702b9
 c1596140 00000000 c153bff8 c157006b 01606d60 00000000 c14b0e88 01827003
 00000000
Call Trace:
 [<c1001c7c>] ? cpu_idle+0x2c/0x50
 [<c13e72a2>] ? rest_init+0x52/0x60
 [<c15706cd>] ? start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] ? i386_start_kernel+0x6b/0x6d
Code: 00 55 8b 0d 18 67 5c c1 89 e5 85 c9 75 2b 80 3d 05 d5 56 c1 00 74 22 89 e0 25 00 e0 ff ff 83 60 0c fb 8b 40 08 a8 08 75 15 fb f4 <89> e0 25 00 e0 ff ff 83 48 0c 04 c9 c3 90 fb f3 90 c9 c3 fb eb 
Call Trace:
 [<c1001c7c>] cpu_idle+0x2c/0x50
 [<c13e72a2>] rest_init+0x52/0x60
 [<c15706cd>] start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] i386_start_kernel+0x6b/0x6d
BUG: scheduling while atomic: swapper/0/0x10010000
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100

Pid: 0, comm: swapper Not tainted 2.6.37-matthias #28 A7V8X/System Name
EIP: 0060:[<c10088ba>] EFLAGS: 00000246 CPU: 0
EIP is at default_idle+0x2a/0x40
EAX: 00000000 EBX: c1596140 ECX: 00000000 EDX: 00000000
ESI: 0008d800 EDI: c153d000 EBP: c153bfbc ESP: c153bfbc
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=f6004000 task=c1541300 task.ti=c153a000)
Stack:
 c153bfc4 c1001c7c c153bfcc c13e72a2 c153bfe4 c15706cd 000000a0 c15702b9
 c1596140 00000000 c153bff8 c157006b 01606d60 00000000 c14b0e88 01827003
 00000000
Call Trace:
 [<c1001c7c>] ? cpu_idle+0x2c/0x50
 [<c13e72a2>] ? rest_init+0x52/0x60
 [<c15706cd>] ? start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] ? i386_start_kernel+0x6b/0x6d
Code: 00 55 8b 0d 18 67 5c c1 89 e5 85 c9 75 2b 80 3d 05 d5 56 c1 00 74 22 89 e0 25 00 e0 ff ff 83 60 0c fb 8b 40 08 a8 08 75 15 fb f4 <89> e0 25 00 e0 ff ff 83 48 0c 04 c9 c3 90 fb f3 90 c9 c3 fb eb 
Call Trace:
 [<c1001c7c>] cpu_idle+0x2c/0x50
 [<c13e72a2>] rest_init+0x52/0x60
 [<c15706cd>] start_kernel+0x242/0x248
 [<c15702b9>] ? unknown_bootoption+0x0/0x19c
 [<c157006b>] i386_start_kernel+0x6b/0x6d
BUG: scheduling while atomic: swapper/0/0x10010000
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder videobuf_dma_sg videobuf_core ir_rc5_decoder btcx_risc ir_nec_decoder ir_common ir_core tveeprom tuner v4l2_common videodev v4l1_compat analog gameport uhci_hcd ehci_hcd e100
Modules linked in: i2c_viapro usbhid snd_via82xx via_ircc snd_mpu401_uart parport_pc sata_promise sata_sil tmscsim evdev snd_bt87x tda9887 snd_seq_dummy snd_seq_oss snd_seq_midi snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec ac97_bus snd_pcm snd_timer snd snd_page_alloc parport irtty_sir actisys_sir sir_dev irda crc_ccitt tuner_simple tuner_types msp3400 ir_lirc_codec lirc_dev ir_sony_decoder bttv ir_jvc_decoder ir_rc6_decoder
SysRq : Resetting

--pWyiEgJYm5f9v55/--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
