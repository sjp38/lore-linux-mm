Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 5D9A46B01AD
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 14:39:45 -0400 (EDT)
Received: by wyb42 with SMTP id 42so162562wyb.14
        for <linux-mm@kvack.org>; Fri, 04 Jun 2010 11:39:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1006030833070.24954@router.home>
References: <AANLkTimEFy6VM3InWlqhVooQjKGSD3yBxlgeRbQC2r1L@mail.gmail.com>
	<20100531165528.35a323fb.rdunlap@xenotime.net>
	<4C047CF9.9000804@tmr.com>
	<AANLkTilLq-hn59CBcLnOsnT37ZizQR6MrZX6btKPhfpb@mail.gmail.com>
	<20100601123959.747228c6.rdunlap@xenotime.net>
	<alpine.DEB.2.00.1006011445100.9438@router.home>
	<AANLkTinxOJShwd7xUornVI89BmJnbX9-a7LVWaciNdr5@mail.gmail.com>
	<alpine.DEB.2.00.1006030833070.24954@router.home>
Date: Fri, 4 Jun 2010 20:39:38 +0200
Message-ID: <AANLkTimXxhVCu50GweoC7iF9tFEoSrWAbqQEXRroGnBk@mail.gmail.com>
Subject: Re: Possible bug in 2.6.34 slub
From: Giangiacomo Mariotti <gg.mariotti@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Randy Dunlap <rdunlap@xenotime.net>, Bill Davidsen <davidsen@tmr.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86 maintainers <x86@kernel.org>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 3, 2010 at 3:34 PM, Christoph Lameter
<cl@linux-foundation.org> wrote:
> On Thu, 3 Jun 2010, Pekka Enberg wrote:
>
>> On Tue, Jun 1, 2010 at 10:48 PM, Christoph Lameter
>> <cl@linux-foundation.org> wrote:
>> > On Tue, 1 Jun 2010, Randy Dunlap wrote:
>> >
>> >> > >>> My cpu is an I7 920, so it has 4 cores and there's hyperthreading
>> >> > >>> enabled, so there are 8 logical cpus. Is this a bug?
>> >
>> > Yes its a bug in the arch code or BIOS. The system configuration tells us
>> > that there are more possible cpus and therefore the system prepares for
>> > the additional cpus to be activated at some later time.
>>
>> I guess we should CC x86 maintainers then!
>
> Its also a know BIOS problem with Dell f.e. They often indicate more
> potential cpus even if this particular hw configuration cannot do cpu
> hotplug.
>
This is the whole dmesg output(2.6.34+all the patches in the stable
repository that applied without failing):

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 2.6.34-my005 (gcc version 4.4.4 (Debian
4.4.4-4) ) #1 SMP Fri Jun 4 19:32:49 CEST 2010
[    0.000000] Command line: BOOT_IMAGE=/boot/vmlinuz-2.6.34-my005
root=UUID=3e44f0be-6d81-4d5e-a6b4-7f090d536c1e ro quiet
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009dc00 (usable)
[    0.000000]  BIOS-e820: 000000000009f800 - 00000000000a0000 (reserved)
[    0.000000]  BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 00000000dfde0000 (usable)
[    0.000000]  BIOS-e820: 00000000dfde0000 - 00000000dfee0000 (reserved)
[    0.000000]  BIOS-e820: 00000000dfee0000 - 00000000dfee1000 (ACPI NVS)
[    0.000000]  BIOS-e820: 00000000dfee1000 - 00000000dfef0000 (ACPI data)
[    0.000000]  BIOS-e820: 00000000dfef0000 - 00000000dff00000 (reserved)
[    0.000000]  BIOS-e820: 00000000f4000000 - 00000000f8000000 (reserved)
[    0.000000]  BIOS-e820: 00000000fec00000 - 0000000100000000 (reserved)
[    0.000000]  BIOS-e820: 0000000100000000 - 0000000320000000 (usable)
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] DMI 2.4 present.
[    0.000000] e820 update range: 0000000000000000 - 0000000000001000
(usable) ==> (reserved)
[    0.000000] e820 remove range: 00000000000a0000 - 0000000000100000 (usable)
[    0.000000] No AGP bridge found
[    0.000000] last_pfn = 0x320000 max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-CEFFF write-protect
[    0.000000]   CF000-EFFFF uncachable
[    0.000000]   F0000-FFFFF write-through
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 000000000 mask F00000000 write-back
[    0.000000]   1 base 0E0000000 mask FE0000000 uncachable
[    0.000000]   2 base 100000000 mask F00000000 write-back
[    0.000000]   3 base 200000000 mask E00000000 write-back
[    0.000000]   4 base 300000000 mask FE0000000 write-back
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
[    0.000000] e820 update range: 00000000e0000000 - 0000000100000000
(usable) ==> (reserved)
[    0.000000] last_pfn = 0xdfde0 max_arch_pfn = 0x400000000
[    0.000000] initial memory mapped : 0 - 20000000
[    0.000000] found SMP MP-table at [ffff8800000f5ed0] f5ed0
[    0.000000] init_memory_mapping: 0000000000000000-00000000dfde0000
[    0.000000]  0000000000 - 00dfc00000 page 2M
[    0.000000]  00dfc00000 - 00dfde0000 page 4k
[    0.000000] kernel direct mapping tables up to dfde0000 @ 8000-e000
[    0.000000] init_memory_mapping: 0000000100000000-0000000320000000
[    0.000000]  0100000000 - 0320000000 page 2M
[    0.000000] kernel direct mapping tables up to 320000000 @ c000-1a000
[    0.000000] RAMDISK: 37660000 - 37ff0000
[    0.000000] ACPI: RSDP 00000000000f7890 00014 (v00 GBT   )
[    0.000000] ACPI: RSDT 00000000dfee1040 00040 (v01 GBT    GBTUACPI
42302E31 GBTU 01010101)
[    0.000000] ACPI: FACP 00000000dfee10c0 00074 (v01 GBT    GBTUACPI
42302E31 GBTU 01010101)
[    0.000000] ACPI: DSDT 00000000dfee1180 04991 (v01 GBT    GBTUACPI
00001000 MSFT 0100000C)
[    0.000000] ACPI: FACS 00000000dfee0000 00040
[    0.000000] ACPI: HPET 00000000dfee5d00 00038 (v01 GBT    GBTUACPI
42302E31 GBTU 00000098)
[    0.000000] ACPI: MCFG 00000000dfee5d80 0003C (v01 GBT    GBTUACPI
42302E31 GBTU 01010101)
[    0.000000] ACPI: EUDS 00000000dfee5dc0 00470 (v01 GBT
00000000      00000000)
[    0.000000] ACPI: TAMG 00000000dfee6230 00AE2 (v01 GBT    GBT   B0
5455312E BG?? 53450101)
[    0.000000] ACPI: APIC 00000000dfee5b80 0012C (v01 GBT    GBTUACPI
42302E31 GBTU 01010101)
[    0.000000] ACPI: SSDT 00000000dfee6d20 02804 (v01  INTEL PPM RCM
80000001 INTL 20061109)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at 0000000000000000-0000000320000000
[    0.000000] Initmem setup node 0 0000000000000000-0000000320000000
[    0.000000]   NODE_DATA [0000000100000000 - 0000000100004fff]
[    0.000000]  [ffffea0000000000-ffffea000affffff] PMD ->
[ffff880100200000-ffff88010abfffff] on node 0
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000001 -> 0x00001000
[    0.000000]   DMA32    0x00001000 -> 0x00100000
[    0.000000]   Normal   0x00100000 -> 0x00320000
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[3] active PFN ranges
[    0.000000]     0: 0x00000001 -> 0x0000009d
[    0.000000]     0: 0x00000100 -> 0x000dfde0
[    0.000000]     0: 0x00100000 -> 0x00320000
[    0.000000] On node 0 totalpages: 3145084
[    0.000000]   DMA zone: 56 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3940 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 14280 pages used for memmap
[    0.000000]   DMA32 zone: 898584 pages, LIFO batch:31
[    0.000000]   Normal zone: 30464 pages used for memmap
[    0.000000]   Normal zone: 2197760 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0x408
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x02] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x04] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x06] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x05] lapic_id[0x03] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x06] lapic_id[0x05] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x07] lapic_id[0x07] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x08] lapic_id[0x08] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x09] lapic_id[0x09] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0a] lapic_id[0x0a] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0b] lapic_id[0x0b] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0c] lapic_id[0x0c] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0d] lapic_id[0x0d] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0e] lapic_id[0x0e] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0f] lapic_id[0x0f] disabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] dfl dfl lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] dfl dfl lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x02] dfl dfl lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x03] dfl dfl lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x04] dfl dfl lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x05] dfl dfl lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x06] dfl dfl lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x07] dfl dfl lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x08] dfl dfl lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x09] dfl dfl lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0a] dfl dfl lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0b] dfl dfl lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0c] dfl dfl lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0d] dfl dfl lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0e] dfl dfl lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0f] dfl dfl lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 2, version 32, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] SMP: Allowing 16 CPUs, 8 hotplug CPUs
[    0.000000] nr_irqs_gsi: 24
[    0.000000] early_res array is doubled to 64 at [7000 - 77ff]
[    0.000000] PM: Registered nosave memory: 000000000009d000 - 00000000000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 00000000000f0000
[    0.000000] PM: Registered nosave memory: 00000000000f0000 - 0000000000100000
[    0.000000] PM: Registered nosave memory: 00000000dfde0000 - 00000000dfee0000
[    0.000000] PM: Registered nosave memory: 00000000dfee0000 - 00000000dfee1000
[    0.000000] PM: Registered nosave memory: 00000000dfee1000 - 00000000dfef0000
[    0.000000] PM: Registered nosave memory: 00000000dfef0000 - 00000000dff00000
[    0.000000] PM: Registered nosave memory: 00000000dff00000 - 00000000f4000000
[    0.000000] PM: Registered nosave memory: 00000000f4000000 - 00000000f8000000
[    0.000000] PM: Registered nosave memory: 00000000f8000000 - 00000000fec00000
[    0.000000] PM: Registered nosave memory: 00000000fec00000 - 0000000100000000
[    0.000000] Allocating PCI resources starting at dff00000 (gap:
dff00000:14100000)
[    0.000000] setup_percpu: NR_CPUS:512 nr_cpumask_bits:512
nr_cpu_ids:16 nr_node_ids:1
[    0.000000] early_res array is doubled to 128 at [15000 - 15fff]
[    0.000000] PERCPU: Embedded 28 pages/cpu @ffff880001a00000 s82088
r8192 d24408 u131072
[    0.000000] pcpu-alloc: s82088 r8192 d24408 u131072 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.
Total pages: 3100284
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line:
BOOT_IMAGE=/boot/vmlinuz-2.6.34-my005
root=UUID=3e44f0be-6d81-4d5e-a6b4-7f090d536c1e ro quiet
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Calgary: detecting Calgary via BIOS EBDA area
[    0.000000] Calgary: Unable to locate Rio Grande table in EBDA - bailing!
[    0.000000] Subtract (69 early reservations)
[    0.000000]   #1 [0001000000 - 00017d3924]   TEXT DATA BSS
[    0.000000]   #2 [0037660000 - 0037ff0000]         RAMDISK
[    0.000000]   #3 [00017d4000 - 00017d40f6]             BRK
[    0.000000]   #4 [00000f5ee0 - 0000100000]   BIOS reserved
[    0.000000]   #5 [00000f5ed0 - 00000f5ee0]    MP-table mpf
[    0.000000]   #6 [000009dc00 - 00000f0d00]   BIOS reserved
[    0.000000]   #7 [00000f0f14 - 00000f5ed0]   BIOS reserved
[    0.000000]   #8 [00000f0d00 - 00000f0f14]    MP-table mpc
[    0.000000]   #9 [0000001000 - 0000003000]      TRAMPOLINE
[    0.000000]   #10 [0000003000 - 0000007000]     ACPI WAKEUP
[    0.000000]   #11 [0000008000 - 000000c000]         PGTABLE
[    0.000000]   #12 [000000c000 - 0000015000]         PGTABLE
[    0.000000]   #13 [0100000000 - 0100005000]       NODE_DATA
[    0.000000]   #14 [00017d4100 - 00017d5100]         BOOTMEM
[    0.000000]   #15 [0100005000 - 0100005900]         BOOTMEM
[    0.000000]   #16 [0100006000 - 0100007000]         BOOTMEM
[    0.000000]   #17 [0100007000 - 0100008000]         BOOTMEM
[    0.000000]   #18 [0100200000 - 010ac00000]        MEMMAP 0
[    0.000000]   #19 [00017d5100 - 00017ed100]         BOOTMEM
[    0.000000]   #20 [00017ed100 - 0001805100]         BOOTMEM
[    0.000000]   #21 [0001805100 - 000181d100]         BOOTMEM
[    0.000000]   #22 [000181e000 - 000181f000]         BOOTMEM
[    0.000000]   #23 [00017d3940 - 00017d3981]         BOOTMEM
[    0.000000]   #24 [00017d39c0 - 00017d3a03]         BOOTMEM
[    0.000000]   #25 [00017d3a40 - 00017d3ce0]         BOOTMEM
[    0.000000]   #26 [00017d3d00 - 00017d3d68]         BOOTMEM
[    0.000000]   #27 [00017d3d80 - 00017d3de8]         BOOTMEM
[    0.000000]   #28 [00017d3e00 - 00017d3e68]         BOOTMEM
[    0.000000]   #29 [00017d3e80 - 00017d3ee8]         BOOTMEM
[    0.000000]   #30 [00017d3f00 - 00017d3f68]         BOOTMEM
[    0.000000]   #31 [00017d3f80 - 00017d3fe8]         BOOTMEM
[    0.000000]   #32 [000181d100 - 000181d168]         BOOTMEM
[    0.000000]   #33 [000181d180 - 000181d1e8]         BOOTMEM
[    0.000000]   #34 [000181d200 - 000181d268]         BOOTMEM
[    0.000000]   #35 [000181d280 - 000181d2e8]         BOOTMEM
[    0.000000]   #36 [000181d300 - 000181d368]         BOOTMEM
[    0.000000]   #37 [000181d380 - 000181d3a0]         BOOTMEM
[    0.000000]   #38 [000181d3c0 - 000181d3e0]         BOOTMEM
[    0.000000]   #39 [000181d400 - 000181d45e]         BOOTMEM
[    0.000000]   #40 [000181d480 - 000181d4de]         BOOTMEM
[    0.000000]   #41 [0001a00000 - 0001a1c000]         BOOTMEM
[    0.000000]   #42 [0001a20000 - 0001a3c000]         BOOTMEM
[    0.000000]   #43 [0001a40000 - 0001a5c000]         BOOTMEM
[    0.000000]   #44 [0001a60000 - 0001a7c000]         BOOTMEM
[    0.000000]   #45 [0001a80000 - 0001a9c000]         BOOTMEM
[    0.000000]   #46 [0001aa0000 - 0001abc000]         BOOTMEM
[    0.000000]   #47 [0001ac0000 - 0001adc000]         BOOTMEM
[    0.000000]   #48 [0001ae0000 - 0001afc000]         BOOTMEM
[    0.000000]   #49 [0001b00000 - 0001b1c000]         BOOTMEM
[    0.000000]   #50 [0001b20000 - 0001b3c000]         BOOTMEM
[    0.000000]   #51 [0001b40000 - 0001b5c000]         BOOTMEM
[    0.000000]   #52 [0001b60000 - 0001b7c000]         BOOTMEM
[    0.000000]   #53 [0001b80000 - 0001b9c000]         BOOTMEM
[    0.000000]   #54 [0001ba0000 - 0001bbc000]         BOOTMEM
[    0.000000]   #55 [0001bc0000 - 0001bdc000]         BOOTMEM
[    0.000000]   #56 [0001be0000 - 0001bfc000]         BOOTMEM
[    0.000000]   #57 [000181d500 - 000181d508]         BOOTMEM
[    0.000000]   #58 [000181d540 - 000181d548]         BOOTMEM
[    0.000000]   #59 [000181d580 - 000181d5c0]         BOOTMEM
[    0.000000]   #60 [000181d5c0 - 000181d640]         BOOTMEM
[    0.000000]   #61 [000181d640 - 000181d750]         BOOTMEM
[    0.000000]   #62 [000181d780 - 000181d7c8]         BOOTMEM
[    0.000000]   #63 [000181d800 - 000181d848]         BOOTMEM
[    0.000000]   #64 [000181f000 - 0001827000]         BOOTMEM
[    0.000000]   #65 [0001bfc000 - 0005bfc000]         BOOTMEM
[    0.000000]   #66 [0001827000 - 0001847000]         BOOTMEM
[    0.000000]   #67 [0001847000 - 0001887000]         BOOTMEM
[    0.000000]   #68 [0000016000 - 000001e000]         BOOTMEM
[    0.000000] Memory: 12320264k/13107200k available (2932k kernel
code, 526864k absent, 260072k reserved, 3741k data, 524k init)
[    0.000000] SLUB: Genslabs=14, HWalign=64, Order=0-3, MinObjects=0,
CPUs=16, Nodes=1
[    0.000000] Hierarchical RCU implementation.
[    0.000000] NR_IRQS:33024 nr_irqs:536
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] hpet clockevent registered
[    0.000000] Fast TSC calibration using PIT
[    0.004000] Detected 2698.752 MHz processor.
[    0.000003] Calibrating delay loop (skipped), value calculated
using timer frequency.. 5397.50 BogoMIPS (lpj=10795008)
[    0.000794] Dentry cache hash table entries: 2097152 (order: 12,
16777216 bytes)
[    0.005144] Inode-cache hash table entries: 1048576 (order: 11,
8388608 bytes)
[    0.007497] Mount-cache hash table entries: 256
[    0.007595] Initializing cgroup subsys ns
[    0.007597] Initializing cgroup subsys cpuacct
[    0.007601] Initializing cgroup subsys devices
[    0.007602] Initializing cgroup subsys freezer
[    0.007604] Initializing cgroup subsys net_cls
[    0.007619] CPU: Physical Processor ID: 0
[    0.007620] CPU: Processor Core ID: 0
[    0.007624] mce: CPU supports 9 MCE banks
[    0.007632] CPU0: Thermal monitoring enabled (TM1)
[    0.007637] using mwait in idle threads.
[    0.007638] Performance Events: Nehalem/Corei7 events, Intel PMU driver.
[    0.007642] ... version:                3
[    0.007643] ... bit width:              48
[    0.007643] ... generic registers:      4
[    0.007644] ... value mask:             0000ffffffffffff
[    0.007645] ... max period:             000000007fffffff
[    0.007646] ... fixed-purpose events:   3
[    0.007647] ... event mask:             000000070000000f
[    0.007671] ACPI: Core revision 20100121
[    0.013968] Setting APIC routing to physical flat
[    0.014285] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.053923] CPU0: Intel(R) Core(TM) i7 CPU         920  @ 2.67GHz stepping 04
[    0.161147] Booting Node   0, Processors  #1 #2 #3 #4 #5 #6 #7
[    0.916260] Brought up 8 CPUs
[    0.916263] Total of 8 processors activated (43178.76 BogoMIPS).
[    0.919099] devtmpfs: initialized
[    0.922368] regulator: core version 0.5
[    0.922401] NET: Registered protocol family 16
[    0.922469] ACPI: bus type pci registered
[    0.922523] PCI: MMCONFIG for domain 0000 [bus 00-3f] at [mem
0xf4000000-0xf7ffffff] (base 0xf4000000)
[    0.922526] PCI: MMCONFIG at [mem 0xf4000000-0xf7ffffff] reserved in E820
[    0.926240] PCI: Using configuration type 1 for base access
[    0.926772] bio: create slab <bio-0> at 0
[    0.927445] ACPI: EC: Look up EC in DSDT
[    0.932346] ACPI: Interpreter enabled
[    0.932349] ACPI: (supports S0 S3 S4 S5)
[    0.932364] ACPI: Using IOAPIC for interrupt routing
[    0.936091] ACPI Warning: Incorrect checksum in table [TAMG] - 60,
should be 5F (20100121/tbutils-314)
[    0.936176] ACPI: No dock devices found.
[    0.936178] PCI: Using host bridge windows from ACPI; if necessary,
use "pci=nocrs" and report a bug
[    0.936252] ACPI: PCI Root Bridge [PCI0] (0000:00)
[    0.936389] pci_root PNP0A03:00: host bridge window [io  0x0000-0x0cf7]
[    0.936391] pci_root PNP0A03:00: host bridge window [io  0x0d00-0xffff]
[    0.936393] pci_root PNP0A03:00: host bridge window [mem
0x000a0000-0x000bffff]
[    0.936395] pci_root PNP0A03:00: host bridge window [mem
0x000c0000-0x000dffff]
[    0.936396] pci_root PNP0A03:00: host bridge window [mem
0xdff00000-0xfebfffff]
[    0.936444] pci 0000:00:00.0: PME# supported from D0 D3hot D3cold
[    0.936447] pci 0000:00:00.0: PME# disabled
[    0.936497] pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
[    0.936499] pci 0000:00:01.0: PME# disabled
[    0.936549] pci 0000:00:03.0: PME# supported from D0 D3hot D3cold
[    0.936552] pci 0000:00:03.0: PME# disabled
[    0.936603] pci 0000:00:07.0: PME# supported from D0 D3hot D3cold
[    0.936606] pci 0000:00:07.0: PME# disabled
[    0.936655] pci 0000:00:09.0: PME# supported from D0 D3hot D3cold
[    0.936658] pci 0000:00:09.0: PME# disabled
[    0.936825] pci 0000:00:13.0: reg 10: [mem 0xfbfff000-0xfbffffff]
[    0.936851] pci 0000:00:13.0: PME# supported from D0 D3hot D3cold
[    0.936854] pci 0000:00:13.0: PME# disabled
[    0.937038] pci 0000:00:1a.0: reg 20: [io  0xff00-0xff1f]
[    0.937095] pci 0000:00:1a.1: reg 20: [io  0xfe00-0xfe1f]
[    0.937150] pci 0000:00:1a.2: reg 20: [io  0xfd00-0xfd1f]
[    0.937205] pci 0000:00:1a.7: reg 10: [mem 0xfbffe000-0xfbffe3ff]
[    0.937252] pci 0000:00:1a.7: PME# supported from D0 D3hot D3cold
[    0.937255] pci 0000:00:1a.7: PME# disabled
[    0.937284] pci 0000:00:1b.0: reg 10: [mem 0xfbff4000-0xfbff7fff 64bit]
[    0.937319] pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
[    0.937322] pci 0000:00:1b.0: PME# disabled
[    0.937378] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    0.937380] pci 0000:00:1c.0: PME# disabled
[    0.937438] pci 0000:00:1c.1: PME# supported from D0 D3hot D3cold
[    0.937440] pci 0000:00:1c.1: PME# disabled
[    0.937499] pci 0000:00:1c.4: PME# supported from D0 D3hot D3cold
[    0.937502] pci 0000:00:1c.4: PME# disabled
[    0.937558] pci 0000:00:1c.5: PME# supported from D0 D3hot D3cold
[    0.937561] pci 0000:00:1c.5: PME# disabled
[    0.937605] pci 0000:00:1d.0: reg 20: [io  0xfc00-0xfc1f]
[    0.937660] pci 0000:00:1d.1: reg 20: [io  0xfb00-0xfb1f]
[    0.937715] pci 0000:00:1d.2: reg 20: [io  0xfa00-0xfa1f]
[    0.937770] pci 0000:00:1d.7: reg 10: [mem 0xfbffd000-0xfbffd3ff]
[    0.937817] pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
[    0.937821] pci 0000:00:1d.7: PME# disabled
[    0.937920] pci 0000:00:1f.0: quirk: [io  0x0400-0x047f] claimed by
ICH6 ACPI/GPIO/TCO
[    0.937923] pci 0000:00:1f.0: quirk: [io  0x0480-0x04bf] claimed by ICH6 GPIO
[    0.937926] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 1 PIO at
0800 (mask 000f)
[    0.937928] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 2 PIO at
0290 (mask 000f)
[    0.937976] pci 0000:00:1f.2: reg 10: [io  0xf900-0xf907]
[    0.937980] pci 0000:00:1f.2: reg 14: [io  0xf800-0xf803]
[    0.937985] pci 0000:00:1f.2: reg 18: [io  0xf700-0xf707]
[    0.937989] pci 0000:00:1f.2: reg 1c: [io  0xf600-0xf603]
[    0.937993] pci 0000:00:1f.2: reg 20: [io  0xf500-0xf51f]
[    0.937998] pci 0000:00:1f.2: reg 24: [mem 0xfbffc000-0xfbffc7ff]
[    0.938024] pci 0000:00:1f.2: PME# supported from D3hot
[    0.938027] pci 0000:00:1f.2: PME# disabled
[    0.938050] pci 0000:00:1f.3: reg 10: [mem 0xfbffb000-0xfbffb0ff 64bit]
[    0.938061] pci 0000:00:1f.3: reg 20: [io  0x0500-0x051f]
[    0.938107] pci 0000:00:01.0: PCI bridge to [bus 01-01]
[    0.938109] pci 0000:00:01.0:   bridge window [io  0xf000-0x0000] (disabled)
[    0.938112] pci 0000:00:01.0:   bridge window [mem
0xfff00000-0x000fffff] (disabled)
[    0.938116] pci 0000:00:01.0:   bridge window [mem
0xfff00000-0x000fffff pref] (disabled)
[    0.938163] pci 0000:02:00.0: reg 10: [mem 0xe0000000-0xefffffff 64bit pref]
[    0.938170] pci 0000:02:00.0: reg 18: [mem 0xfbbe0000-0xfbbeffff 64bit]
[    0.938174] pci 0000:02:00.0: reg 20: [io  0xbe00-0xbeff]
[    0.938181] pci 0000:02:00.0: reg 30: [mem 0x00000000-0x0001ffff pref]
[    0.938197] pci 0000:02:00.0: supports D1 D2
[    0.938221] pci 0000:02:00.1: reg 10: [mem 0xfbbfc000-0xfbbfffff 64bit]
[    0.938251] pci 0000:02:00.1: supports D1 D2
[    0.944279] pci 0000:00:03.0: PCI bridge to [bus 02-02]
[    0.944283] pci 0000:00:03.0:   bridge window [io  0xb000-0xbfff]
[    0.944287] pci 0000:00:03.0:   bridge window [mem 0xfbb00000-0xfbbfffff]
[    0.944293] pci 0000:00:03.0:   bridge window [mem
0xe0000000-0xefffffff 64bit pref]
[    0.944329] pci 0000:00:07.0: PCI bridge to [bus 03-03]
[    0.944331] pci 0000:00:07.0:   bridge window [io  0xf000-0x0000] (disabled)
[    0.944334] pci 0000:00:07.0:   bridge window [mem
0xfff00000-0x000fffff] (disabled)
[    0.944338] pci 0000:00:07.0:   bridge window [mem
0xfff00000-0x000fffff pref] (disabled)
[    0.944368] pci 0000:00:09.0: PCI bridge to [bus 04-04]
[    0.944371] pci 0000:00:09.0:   bridge window [io  0xf000-0x0000] (disabled)
[    0.944374] pci 0000:00:09.0:   bridge window [mem
0xfff00000-0x000fffff] (disabled)
[    0.944377] pci 0000:00:09.0:   bridge window [mem
0xfff00000-0x000fffff pref] (disabled)
[    0.944412] pci 0000:00:1c.0: PCI bridge to [bus 05-05]
[    0.944415] pci 0000:00:1c.0:   bridge window [io  0xf000-0x0000] (disabled)
[    0.944418] pci 0000:00:1c.0:   bridge window [mem
0xfff00000-0x000fffff] (disabled)
[    0.944423] pci 0000:00:1c.0:   bridge window [mem
0xfff00000-0x000fffff pref] (disabled)
[    0.944524] pci 0000:06:00.0: reg 24: [mem 0xfb9fe000-0xfb9fffff]
[    0.944561] pci 0000:06:00.0: PME# supported from D3hot
[    0.944565] pci 0000:06:00.0: PME# disabled
[    0.944608] pci 0000:06:00.1: reg 10: [io  0xef00-0xef07]
[    0.944615] pci 0000:06:00.1: reg 14: [io  0xee00-0xee03]
[    0.944623] pci 0000:06:00.1: reg 18: [io  0xed00-0xed07]
[    0.944630] pci 0000:06:00.1: reg 1c: [io  0xec00-0xec03]
[    0.944638] pci 0000:06:00.1: reg 20: [io  0xeb00-0xeb0f]
[    0.944693] pci 0000:06:00.0: disabling ASPM on pre-1.1 PCIe
device.  You can enable it with 'pcie_aspm=force'
[    0.944705] pci 0000:00:1c.1: PCI bridge to [bus 06-06]
[    0.944708] pci 0000:00:1c.1:   bridge window [io  0xe000-0xefff]
[    0.944711] pci 0000:00:1c.1:   bridge window [mem 0xfb900000-0xfb9fffff]
[    0.944715] pci 0000:00:1c.1:   bridge window [mem
0xfff00000-0x000fffff pref] (disabled)
[    0.944774] pci 0000:07:00.0: reg 10: [io  0xde00-0xdeff]
[    0.944792] pci 0000:07:00.0: reg 18: [mem 0xfbeff000-0xfbefffff 64bit pref]
[    0.944804] pci 0000:07:00.0: reg 20: [mem 0xfbef8000-0xfbefbfff 64bit pref]
[    0.944811] pci 0000:07:00.0: reg 30: [mem 0x00000000-0x0001ffff pref]
[    0.944847] pci 0000:07:00.0: supports D1 D2
[    0.944848] pci 0000:07:00.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.944852] pci 0000:07:00.0: PME# disabled
[    0.952275] pci 0000:00:1c.4: PCI bridge to [bus 07-07]
[    0.952280] pci 0000:00:1c.4:   bridge window [io  0xd000-0xdfff]
[    0.952284] pci 0000:00:1c.4:   bridge window [mem 0xfb800000-0xfb8fffff]
[    0.952290] pci 0000:00:1c.4:   bridge window [mem
0xfbe00000-0xfbefffff 64bit pref]
[    0.952361] pci 0000:08:00.0: reg 10: [io  0xce00-0xceff]
[    0.952379] pci 0000:08:00.0: reg 18: [mem 0xfbcff000-0xfbcfffff 64bit pref]
[    0.952391] pci 0000:08:00.0: reg 20: [mem 0xfbcf8000-0xfbcfbfff 64bit pref]
[    0.952398] pci 0000:08:00.0: reg 30: [mem 0x00000000-0x0001ffff pref]
[    0.952434] pci 0000:08:00.0: supports D1 D2
[    0.952435] pci 0000:08:00.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.952439] pci 0000:08:00.0: PME# disabled
[    0.960269] pci 0000:00:1c.5: PCI bridge to [bus 08-08]
[    0.960274] pci 0000:00:1c.5:   bridge window [io  0xc000-0xcfff]
[    0.960278] pci 0000:00:1c.5:   bridge window [mem 0xfbd00000-0xfbdfffff]
[    0.960284] pci 0000:00:1c.5:   bridge window [mem
0xfbc00000-0xfbcfffff 64bit pref]
[    0.960338] pci 0000:09:06.0: reg 10: [mem 0xfbaff000-0xfbaff7ff]
[    0.960344] pci 0000:09:06.0: reg 14: [mem 0xfbaf8000-0xfbafbfff]
[    0.960382] pci 0000:09:06.0: supports D1 D2
[    0.960383] pci 0000:09:06.0: PME# supported from D0 D1 D2 D3hot
[    0.960387] pci 0000:09:06.0: PME# disabled
[    0.960420] pci 0000:00:1e.0: PCI bridge to [bus 09-09] (subtractive decode)
[    0.960423] pci 0000:00:1e.0:   bridge window [io  0xf000-0x0000] (disabled)
[    0.960426] pci 0000:00:1e.0:   bridge window [mem 0xfba00000-0xfbafffff]
[    0.960430] pci 0000:00:1e.0:   bridge window [mem
0xfff00000-0x000fffff pref] (disabled)
[    0.960432] pci 0000:00:1e.0:   bridge window [io  0x0000-0x0cf7]
(subtractive decode)
[    0.960433] pci 0000:00:1e.0:   bridge window [io  0x0d00-0xffff]
(subtractive decode)
[    0.960435] pci 0000:00:1e.0:   bridge window [mem
0x000a0000-0x000bffff] (subtractive decode)
[    0.960437] pci 0000:00:1e.0:   bridge window [mem
0x000c0000-0x000dffff] (subtractive decode)
[    0.960438] pci 0000:00:1e.0:   bridge window [mem
0xdff00000-0xfebfffff] (subtractive decode)
[    0.960468] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    0.960636] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX0._PRT]
[    0.960676] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX1._PRT]
[    0.960728] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX4._PRT]
[    0.960767] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX5._PRT]
[    0.960807] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.HUB0._PRT]
[    0.981325] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 9 10 11
12 *14 15)
[    0.981396] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 9 *10
11 12 14 15)
[    0.981466] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 9 10
*11 12 14 15)
[    0.981536] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 9 10 11
*12 14 15)
[    0.981608] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 9 10 11
12 14 15) *0, disabled.
[    0.981679] ACPI: PCI Interrupt Link [LNKF] (IRQs *3 4 5 6 7 9 10
11 12 14 15)
[    0.981749] ACPI: PCI Interrupt Link [LNK0] (IRQs 3 4 *5 6 7 9 10
11 12 14 15)
[    0.981818] ACPI: PCI Interrupt Link [LNK1] (IRQs 3 4 5 6 *7 9 10
11 12 14 15)
[    0.981894] vgaarb: device added:
PCI:0000:02:00.0,decodes=io+mem,owns=io+mem,locks=none
[    0.981897] vgaarb: loaded
[    0.981931] PCI: Using ACPI for IRQ routing
[    0.981932] PCI: pci_cache_line_size set to 64 bytes
[    0.982027] reserve RAM buffer: 000000000009dc00 - 000000000009ffff
[    0.982029] reserve RAM buffer: 00000000dfde0000 - 00000000dfffffff
[    0.982089] HPET: 4 timers in total, 0 timers will be used for per-cpu timer
[    0.982094] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0
[    0.982096] hpet0: 4 comparators, 64-bit 14.318180 MHz counter
[    1.012187] Switching to clocksource tsc
[    1.013142] pnp: PnP ACPI init
[    1.013152] ACPI: bus type pnp registered
[    1.014609] pnp: PnP ACPI: found 13 devices
[    1.014611] ACPI: ACPI bus type pnp unregistered
[    1.014616] system 00:01: [io  0x04d0-0x04d1] has been reserved
[    1.014618] system 00:01: [io  0x0290-0x029f] has been reserved
[    1.014620] system 00:01: [io  0x0800-0x087f] has been reserved
[    1.014622] system 00:01: [io  0x0290-0x0294] has been reserved
[    1.014623] system 00:01: [io  0x0880-0x088f] has been reserved
[    1.014628] system 00:09: [io  0x0400-0x04cf] could not be reserved
[    1.014629] system 00:09: [io  0x04d2-0x04ff] has been reserved
[    1.014633] system 00:0a: [mem 0xf4000000-0xf7ffffff] has been reserved
[    1.014636] system 00:0b: [mem 0x000d6000-0x000d7fff] has been reserved
[    1.014638] system 00:0b: [mem 0x000f0000-0x000f7fff] could not be reserved
[    1.014640] system 00:0b: [mem 0x000f8000-0x000fbfff] could not be reserved
[    1.014641] system 00:0b: [mem 0x000fc000-0x000fffff] could not be reserved
[    1.014643] system 00:0b: [mem 0xdfee0000-0xdfefffff] could not be reserved
[    1.014645] system 00:0b: [mem 0x00000000-0x0009ffff] could not be reserved
[    1.014647] system 00:0b: [mem 0x00100000-0xdfedffff] could not be reserved
[    1.014649] system 00:0b: [mem 0xfec00000-0xfec00fff] could not be reserved
[    1.014650] system 00:0b: [mem 0xfed10000-0xfed1dfff] has been reserved
[    1.014652] system 00:0b: [mem 0xfed20000-0xfed8ffff] has been reserved
[    1.014654] system 00:0b: [mem 0xfee00000-0xfee00fff] has been reserved
[    1.014656] system 00:0b: [mem 0xffb00000-0xffb7ffff] has been reserved
[    1.014657] system 00:0b: [mem 0xfff00000-0xffffffff] has been reserved
[    1.014659] system 00:0b: [mem 0x000e0000-0x000effff] has been reserved
[    1.019366] pci 0000:00:1c.0: BAR 14: assigned [mem 0xf0000000-0xf01fffff]
[    1.019369] pci 0000:00:1c.0: BAR 15: assigned [mem
0xf0200000-0xf03fffff 64bit pref]
[    1.019371] pci 0000:00:1c.1: BAR 15: assigned [mem
0xf0400000-0xf05fffff 64bit pref]
[    1.019373] pci 0000:00:1c.0: BAR 13: assigned [io  0x1000-0x1fff]
[    1.019375] pci 0000:00:01.0: PCI bridge to [bus 01-01]
[    1.019376] pci 0000:00:01.0:   bridge window [io  disabled]
[    1.019379] pci 0000:00:01.0:   bridge window [mem disabled]
[    1.019381] pci 0000:00:01.0:   bridge window [mem pref disabled]
[    1.019386] pci 0000:02:00.0: BAR 6: assigned [mem
0xfbb00000-0xfbb1ffff pref]
[    1.019387] pci 0000:00:03.0: PCI bridge to [bus 02-02]
[    1.019389] pci 0000:00:03.0:   bridge window [io  0xb000-0xbfff]
[    1.019393] pci 0000:00:03.0:   bridge window [mem 0xfbb00000-0xfbbfffff]
[    1.019395] pci 0000:00:03.0:   bridge window [mem
0xe0000000-0xefffffff 64bit pref]
[    1.019399] pci 0000:00:07.0: PCI bridge to [bus 03-03]
[    1.019400] pci 0000:00:07.0:   bridge window [io  disabled]
[    1.019403] pci 0000:00:07.0:   bridge window [mem disabled]
[    1.019405] pci 0000:00:07.0:   bridge window [mem pref disabled]
[    1.019409] pci 0000:00:09.0: PCI bridge to [bus 04-04]
[    1.019410] pci 0000:00:09.0:   bridge window [io  disabled]
[    1.019413] pci 0000:00:09.0:   bridge window [mem disabled]
[    1.019415] pci 0000:00:09.0:   bridge window [mem pref disabled]
[    1.019419] pci 0000:00:1c.0: PCI bridge to [bus 05-05]
[    1.019421] pci 0000:00:1c.0:   bridge window [io  0x1000-0x1fff]
[    1.019425] pci 0000:00:1c.0:   bridge window [mem 0xf0000000-0xf01fffff]
[    1.019428] pci 0000:00:1c.0:   bridge window [mem
0xf0200000-0xf03fffff 64bit pref]
[    1.019433] pci 0000:00:1c.1: PCI bridge to [bus 06-06]
[    1.019435] pci 0000:00:1c.1:   bridge window [io  0xe000-0xefff]
[    1.019438] pci 0000:00:1c.1:   bridge window [mem 0xfb900000-0xfb9fffff]
[    1.019441] pci 0000:00:1c.1:   bridge window [mem
0xf0400000-0xf05fffff 64bit pref]
[    1.019446] pci 0000:07:00.0: BAR 6: assigned [mem
0xfbe00000-0xfbe1ffff pref]
[    1.019448] pci 0000:00:1c.4: PCI bridge to [bus 07-07]
[    1.019450] pci 0000:00:1c.4:   bridge window [io  0xd000-0xdfff]
[    1.019453] pci 0000:00:1c.4:   bridge window [mem 0xfb800000-0xfb8fffff]
[    1.019456] pci 0000:00:1c.4:   bridge window [mem
0xfbe00000-0xfbefffff 64bit pref]
[    1.019461] pci 0000:08:00.0: BAR 6: assigned [mem
0xfbc00000-0xfbc1ffff pref]
[    1.019462] pci 0000:00:1c.5: PCI bridge to [bus 08-08]
[    1.019464] pci 0000:00:1c.5:   bridge window [io  0xc000-0xcfff]
[    1.019468] pci 0000:00:1c.5:   bridge window [mem 0xfbd00000-0xfbdfffff]
[    1.019471] pci 0000:00:1c.5:   bridge window [mem
0xfbc00000-0xfbcfffff 64bit pref]
[    1.019476] pci 0000:00:1e.0: PCI bridge to [bus 09-09]
[    1.019477] pci 0000:00:1e.0:   bridge window [io  disabled]
[    1.019480] pci 0000:00:1e.0:   bridge window [mem 0xfba00000-0xfbafffff]
[    1.019483] pci 0000:00:1e.0:   bridge window [mem pref disabled]
[    1.019491]   alloc irq_desc for 16 on node -1
[    1.019493]   alloc kstat_irqs on node -1
[    1.019497] pci 0000:00:01.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    1.019501] pci 0000:00:01.0: setting latency timer to 64
[    1.019506] pci 0000:00:03.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    1.019508] pci 0000:00:03.0: setting latency timer to 64
[    1.019513] pci 0000:00:07.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    1.019516] pci 0000:00:07.0: setting latency timer to 64
[    1.019521] pci 0000:00:09.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    1.019524] pci 0000:00:09.0: setting latency timer to 64
[    1.019530] pci 0000:00:1c.0: enabling device (0000 -> 0003)
[    1.019533] pci 0000:00:1c.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    1.019536] pci 0000:00:1c.0: setting latency timer to 64
[    1.019542]   alloc irq_desc for 17 on node -1
[    1.019543]   alloc kstat_irqs on node -1
[    1.019546] pci 0000:00:1c.1: PCI INT B -> GSI 17 (level, low) -> IRQ 17
[    1.019549] pci 0000:00:1c.1: setting latency timer to 64
[    1.019554] pci 0000:00:1c.4: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    1.019557] pci 0000:00:1c.4: setting latency timer to 64
[    1.019563] pci 0000:00:1c.5: PCI INT B -> GSI 17 (level, low) -> IRQ 17
[    1.019566] pci 0000:00:1c.5: setting latency timer to 64
[    1.019570] pci 0000:00:1e.0: setting latency timer to 64
[    1.019573] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    1.019574] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    1.019576] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    1.019577] pci_bus 0000:00: resource 7 [mem 0x000c0000-0x000dffff]
[    1.019578] pci_bus 0000:00: resource 8 [mem 0xdff00000-0xfebfffff]
[    1.019580] pci_bus 0000:02: resource 0 [io  0xb000-0xbfff]
[    1.019581] pci_bus 0000:02: resource 1 [mem 0xfbb00000-0xfbbfffff]
[    1.019583] pci_bus 0000:02: resource 2 [mem 0xe0000000-0xefffffff
64bit pref]
[    1.019585] pci_bus 0000:05: resource 0 [io  0x1000-0x1fff]
[    1.019586] pci_bus 0000:05: resource 1 [mem 0xf0000000-0xf01fffff]
[    1.019587] pci_bus 0000:05: resource 2 [mem 0xf0200000-0xf03fffff
64bit pref]
[    1.019589] pci_bus 0000:06: resource 0 [io  0xe000-0xefff]
[    1.019590] pci_bus 0000:06: resource 1 [mem 0xfb900000-0xfb9fffff]
[    1.019592] pci_bus 0000:06: resource 2 [mem 0xf0400000-0xf05fffff
64bit pref]
[    1.019593] pci_bus 0000:07: resource 0 [io  0xd000-0xdfff]
[    1.019594] pci_bus 0000:07: resource 1 [mem 0xfb800000-0xfb8fffff]
[    1.019596] pci_bus 0000:07: resource 2 [mem 0xfbe00000-0xfbefffff
64bit pref]
[    1.019597] pci_bus 0000:08: resource 0 [io  0xc000-0xcfff]
[    1.019599] pci_bus 0000:08: resource 1 [mem 0xfbd00000-0xfbdfffff]
[    1.019600] pci_bus 0000:08: resource 2 [mem 0xfbc00000-0xfbcfffff
64bit pref]
[    1.019602] pci_bus 0000:09: resource 1 [mem 0xfba00000-0xfbafffff]
[    1.019603] pci_bus 0000:09: resource 4 [io  0x0000-0x0cf7]
[    1.019604] pci_bus 0000:09: resource 5 [io  0x0d00-0xffff]
[    1.019606] pci_bus 0000:09: resource 6 [mem 0x000a0000-0x000bffff]
[    1.019607] pci_bus 0000:09: resource 7 [mem 0x000c0000-0x000dffff]
[    1.019608] pci_bus 0000:09: resource 8 [mem 0xdff00000-0xfebfffff]
[    1.019626] NET: Registered protocol family 2
[    1.019860] IP route cache hash table entries: 524288 (order: 10,
4194304 bytes)
[    1.020703] TCP established hash table entries: 524288 (order: 11,
8388608 bytes)
[    1.022946] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[    1.023258] TCP: Hash tables configured (established 524288 bind 65536)
[    1.023260] TCP reno registered
[    1.023276] UDP hash table entries: 8192 (order: 6, 262144 bytes)
[    1.023370] UDP-Lite hash table entries: 8192 (order: 6, 262144 bytes)
[    1.023535] NET: Registered protocol family 1
[    1.052163] pci 0000:02:00.0: Boot video device
[    1.052183] PCI: CLS 64 bytes, default 64
[    1.052224] Unpacking initramfs...
[    1.217363] Freeing initrd memory: 9792k freed
[    1.218618] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[    1.218622] Placing 64MB software IO TLB between ffff880001bfc000 -
ffff880005bfc000
[    1.218623] software IO TLB at phys 0x1bfc000 - 0x5bfc000
[    1.219063] audit: initializing netlink socket (disabled)
[    1.219070] type=2000 audit(1275682503.003:1): initialized
[    1.219586] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    1.220560] VFS: Disk quotas dquot_6.5.2
[    1.220590] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    1.220647] msgmni has been set to 24082
[    1.220831] alg: No test for stdrng (krng)
[    1.220861] Block layer SCSI generic (bsg) driver version 0.4
loaded (major 253)
[    1.220863] io scheduler noop registered
[    1.220864] io scheduler deadline registered
[    1.220904] io scheduler cfq registered (default)
[    1.220974] pcieport 0000:00:01.0: setting latency timer to 64
[    1.220997]   alloc irq_desc for 24 on node -1
[    1.220999]   alloc kstat_irqs on node -1
[    1.221006] pcieport 0000:00:01.0: irq 24 for MSI/MSI-X
[    1.221055] pcieport 0000:00:03.0: setting latency timer to 64
[    1.221077]   alloc irq_desc for 25 on node -1
[    1.221078]   alloc kstat_irqs on node -1
[    1.221083] pcieport 0000:00:03.0: irq 25 for MSI/MSI-X
[    1.221127] pcieport 0000:00:07.0: setting latency timer to 64
[    1.221149]   alloc irq_desc for 26 on node -1
[    1.221150]   alloc kstat_irqs on node -1
[    1.221155] pcieport 0000:00:07.0: irq 26 for MSI/MSI-X
[    1.221199] pcieport 0000:00:09.0: setting latency timer to 64
[    1.221221]   alloc irq_desc for 27 on node -1
[    1.221222]   alloc kstat_irqs on node -1
[    1.221227] pcieport 0000:00:09.0: irq 27 for MSI/MSI-X
[    1.221273] pcieport 0000:00:1c.0: setting latency timer to 64
[    1.221298]   alloc irq_desc for 28 on node -1
[    1.221299]   alloc kstat_irqs on node -1
[    1.221304] pcieport 0000:00:1c.0: irq 28 for MSI/MSI-X
[    1.221358] pcieport 0000:00:1c.1: setting latency timer to 64
[    1.221383]   alloc irq_desc for 29 on node -1
[    1.221384]   alloc kstat_irqs on node -1
[    1.221389] pcieport 0000:00:1c.1: irq 29 for MSI/MSI-X
[    1.221445] pcieport 0000:00:1c.4: setting latency timer to 64
[    1.221470]   alloc irq_desc for 30 on node -1
[    1.221471]   alloc kstat_irqs on node -1
[    1.221476] pcieport 0000:00:1c.4: irq 30 for MSI/MSI-X
[    1.221532] pcieport 0000:00:1c.5: setting latency timer to 64
[    1.221558]   alloc irq_desc for 31 on node -1
[    1.221559]   alloc kstat_irqs on node -1
[    1.221564] pcieport 0000:00:1c.5: irq 31 for MSI/MSI-X
[    1.221625] aer 0000:00:01.0:pcie02: AER service couldn't init
device: no _OSC support
[    1.221630] aer 0000:00:03.0:pcie02: AER service couldn't init
device: no _OSC support
[    1.221633] aer 0000:00:07.0:pcie02: AER service couldn't init
device: no _OSC support
[    1.221636] aer 0000:00:09.0:pcie02: AER service couldn't init
device: no _OSC support
[    1.221643] pcieport 0000:00:01.0: Requesting control of PCIe PME
from ACPI BIOS
[    1.221645] pcieport 0000:00:01.0: Failed to receive control of
PCIe PME service: no _OSC support
[    1.221647] pcie_pme: probe of 0000:00:01.0:pcie01 failed with error -13
[    1.221649] pcieport 0000:00:03.0: Requesting control of PCIe PME
from ACPI BIOS
[    1.221651] pcieport 0000:00:03.0: Failed to receive control of
PCIe PME service: no _OSC support
[    1.221653] pcie_pme: probe of 0000:00:03.0:pcie01 failed with error -13
[    1.221655] pcieport 0000:00:07.0: Requesting control of PCIe PME
from ACPI BIOS
[    1.221657] pcieport 0000:00:07.0: Failed to receive control of
PCIe PME service: no _OSC support
[    1.221659] pcie_pme: probe of 0000:00:07.0:pcie01 failed with error -13
[    1.221661] pcieport 0000:00:09.0: Requesting control of PCIe PME
from ACPI BIOS
[    1.221663] pcieport 0000:00:09.0: Failed to receive control of
PCIe PME service: no _OSC support
[    1.221665] pcie_pme: probe of 0000:00:09.0:pcie01 failed with error -13
[    1.221667] pcieport 0000:00:1c.0: Requesting control of PCIe PME
from ACPI BIOS
[    1.221669] pcieport 0000:00:1c.0: Failed to receive control of
PCIe PME service: no _OSC support
[    1.221671] pcie_pme: probe of 0000:00:1c.0:pcie01 failed with error -13
[    1.221673] pcieport 0000:00:1c.1: Requesting control of PCIe PME
from ACPI BIOS
[    1.221675] pcieport 0000:00:1c.1: Failed to receive control of
PCIe PME service: no _OSC support
[    1.221676] pcie_pme: probe of 0000:00:1c.1:pcie01 failed with error -13
[    1.221679] pcieport 0000:00:1c.4: Requesting control of PCIe PME
from ACPI BIOS
[    1.221680] pcieport 0000:00:1c.4: Failed to receive control of
PCIe PME service: no _OSC support
[    1.221682] pcie_pme: probe of 0000:00:1c.4:pcie01 failed with error -13
[    1.221684] pcieport 0000:00:1c.5: Requesting control of PCIe PME
from ACPI BIOS
[    1.221686] pcieport 0000:00:1c.5: Failed to receive control of
PCIe PME service: no _OSC support
[    1.221688] pcie_pme: probe of 0000:00:1c.5:pcie01 failed with error -13
[    1.222523] Linux agpgart interface v0.103
[    1.222570] [drm] Initialized drm 1.1.0 20060810
[    1.222572] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    1.222817] PNP: PS/2 Controller [PNP0303:PS2K] at 0x60,0x64 irq 1
[    1.222818] PNP: PS/2 appears to have AUX port disabled, if this is
incorrect please boot with i8042.nopnp
[    1.222923] serio: i8042 KBD port at 0x60,0x64 irq 1
[    1.222954] mice: PS/2 mouse device common for all mice
[    1.222979] rtc_cmos 00:04: RTC can wake from S4
[    1.222999] rtc_cmos 00:04: rtc core: registered rtc_cmos as rtc0
[    1.223021] rtc0: alarms up to one month, 242 bytes nvram, hpet irqs
[    1.223027] cpuidle: using governor ladder
[    1.223028] cpuidle: using governor menu
[    1.223030] No iBFT detected.
[    1.223185] TCP cubic registered
[    1.223256] NET: Registered protocol family 10
[    1.223514] lo: Disabled Privacy Extensions
[    1.223634] Mobile IPv6
[    1.223636] NET: Registered protocol family 17
[    1.223678] PM: Resume from disk failed.
[    1.223681] registered taskstats version 1
[    1.224068] rtc_cmos 00:04: setting system clock to 2010-06-04
20:15:03 UTC (1275682503)
[    1.224087] Initalizing network drop monitor service
[    1.224122] Freeing unused kernel memory: 524k freed
[    1.224192] Write protecting the kernel read-only data: 6144k
[    1.224313] Freeing unused kernel memory: 1144k freed
[    1.224509] Freeing unused kernel memory: 956k freed
[    1.248128] input: AT Translated Set 2 keyboard as
/devices/platform/i8042/serio0/input/input0
[    1.273192] udev: starting version 154
[    1.300762] usbcore: registered new interface driver usbfs
[    1.300789] usbcore: registered new interface driver hub
[    1.300876] usbcore: registered new device driver usb
[    1.313719] SCSI subsystem initialized
[    1.314740] Floppy drive(s): fd0 is 1.44M
[    1.315981] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    1.316008]   alloc irq_desc for 18 on node -1
[    1.316010]   alloc kstat_irqs on node -1
[    1.316016] ehci_hcd 0000:00:1a.7: PCI INT C -> GSI 18 (level, low) -> IRQ 18
[    1.316041] ehci_hcd 0000:00:1a.7: setting latency timer to 64
[    1.316044] ehci_hcd 0000:00:1a.7: EHCI Host Controller
[    1.316059] ehci_hcd 0000:00:1a.7: new USB bus registered, assigned
bus number 1
[    1.316084] ehci_hcd 0000:00:1a.7: debug port 1
[    1.319965] ehci_hcd 0000:00:1a.7: cache line size of 64 is not supported
[    1.319975] ehci_hcd 0000:00:1a.7: irq 18, io mem 0xfbffe000
[    1.327038] libata version 3.00 loaded.
[    1.331825] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    1.331841] r8169 0000:07:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    1.331879] r8169 0000:07:00.0: setting latency timer to 64
[    1.331920]   alloc irq_desc for 32 on node -1
[    1.331922]   alloc kstat_irqs on node -1
[    1.331934] r8169 0000:07:00.0: irq 32 for MSI/MSI-X
[    1.332254] r8169 0000:07:00.0: eth0: RTL8168d/8111d at
0xffffc90001878000, 00:1f:d0:ae:41:0e, XID 081000c0 IRQ 32
[    1.335808] FDC 0 is a post-1991 82077
[    1.336195] firewire_ohci 0000:09:06.0: PCI INT A -> GSI 18 (level,
low) -> IRQ 18
[    1.336200] ehci_hcd 0000:00:1a.7: USB 2.0 started, EHCI 1.00
[    1.336218] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[    1.336220] usb usb1: New USB device strings: Mfr=3, Product=2,
SerialNumber=1
[    1.336223] usb usb1: Product: EHCI Host Controller
[    1.336224] usb usb1: Manufacturer: Linux 2.6.34-my005 ehci_hcd
[    1.336225] usb usb1: SerialNumber: 0000:00:1a.7
[    1.336887] hub 1-0:1.0: USB hub found
[    1.336890] hub 1-0:1.0: 6 ports detected
[    1.337085] pata_jmicron 0000:06:00.1: PCI INT B -> GSI 18 (level,
low) -> IRQ 18
[    1.337104] pata_jmicron 0000:06:00.1: setting latency timer to 64
[    1.337145] scsi0 : pata_jmicron
[    1.337149] ahci 0000:00:1f.2: version 3.0
[    1.337157]   alloc irq_desc for 19 on node -1
[    1.337158]   alloc kstat_irqs on node -1
[    1.337163] ahci 0000:00:1f.2: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[    1.337189]   alloc irq_desc for 33 on node -1
[    1.337191]   alloc kstat_irqs on node -1
[    1.337197] ahci 0000:00:1f.2: irq 33 for MSI/MSI-X
[    1.337200] scsi1 : pata_jmicron
[    1.337222] ahci: SSS flag set, parallel bus scan disabled
[    1.337256] ahci 0000:00:1f.2: AHCI 0001.0200 32 slots 6 ports 3
Gbps 0x3f impl SATA mode
[    1.337259] ahci 0000:00:1f.2: flags: 64bit ncq sntf stag pm led
clo pmp pio slum part ccc ems
[    1.337262] ahci 0000:00:1f.2: setting latency timer to 64
[    1.337785] ata1: PATA max UDMA/100 cmd 0xef00 ctl 0xee00 bmdma 0xeb00 irq 18
[    1.337788] ata2: PATA max UDMA/100 cmd 0xed00 ctl 0xec00 bmdma 0xeb08 irq 18
[    1.338174] uhci_hcd: USB Universal Host Controller Interface driver
[    1.374836] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    1.374848] r8169 0000:08:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[    1.374878] r8169 0000:08:00.0: setting latency timer to 64
[    1.374916]   alloc irq_desc for 34 on node -1
[    1.374917]   alloc kstat_irqs on node -1
[    1.374927] r8169 0000:08:00.0: irq 34 for MSI/MSI-X
[    1.375243] r8169 0000:08:00.0: eth1: RTL8168d/8111d at
0xffffc90001856000, 00:1f:d0:ae:41:10, XID 081000c0 IRQ 34
[    1.376529] scsi2 : ahci
[    1.376577] scsi3 : ahci
[    1.376623] scsi4 : ahci
[    1.376666] scsi5 : ahci
[    1.376712] scsi6 : ahci
[    1.376756] scsi7 : ahci
[    1.376866] ata3: SATA max UDMA/133 abar m2048@0xfbffc000 port
0xfbffc100 irq 33
[    1.376868] ata4: SATA max UDMA/133 abar m2048@0xfbffc000 port
0xfbffc180 irq 33
[    1.376870] ata5: SATA max UDMA/133 abar m2048@0xfbffc000 port
0xfbffc200 irq 33
[    1.376873] ata6: SATA max UDMA/133 abar m2048@0xfbffc000 port
0xfbffc280 irq 33
[    1.376875] ata7: SATA max UDMA/133 abar m2048@0xfbffc000 port
0xfbffc300 irq 33
[    1.376877] ata8: SATA max UDMA/133 abar m2048@0xfbffc000 port
0xfbffc380 irq 33
[    1.376907]   alloc irq_desc for 23 on node -1
[    1.376908]   alloc kstat_irqs on node -1
[    1.376913] ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 23 (level, low) -> IRQ 23
[    1.376923] ehci_hcd 0000:00:1d.7: setting latency timer to 64
[    1.376926] ehci_hcd 0000:00:1d.7: EHCI Host Controller
[    1.376930] ahci 0000:06:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[    1.376932] ehci_hcd 0000:00:1d.7: new USB bus registered, assigned
bus number 2
[    1.376954] ehci_hcd 0000:00:1d.7: debug port 1
[    1.380841] ehci_hcd 0000:00:1d.7: cache line size of 64 is not supported
[    1.380851] ehci_hcd 0000:00:1d.7: irq 23, io mem 0xfbffd000
[    1.392512] ahci 0000:06:00.0: AHCI 0001.0000 32 slots 2 ports 3
Gbps 0x3 impl SATA mode
[    1.392514] ahci 0000:06:00.0: flags: 64bit ncq pm led clo pmp pio slum part
[    1.392519] ahci 0000:06:00.0: setting latency timer to 64
[    1.392602] scsi8 : ahci
[    1.392649] scsi9 : ahci
[    1.392714] ata9: SATA max UDMA/133 abar m8192@0xfb9fe000 port
0xfb9fe100 irq 17
[    1.392718] ata10: SATA max UDMA/133 abar m8192@0xfb9fe000 port
0xfb9fe180 irq 17
[    1.396354] ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00
[    1.396367] usb usb2: New USB device found, idVendor=1d6b, idProduct=0002
[    1.396369] usb usb2: New USB device strings: Mfr=3, Product=2,
SerialNumber=1
[    1.396370] usb usb2: Product: EHCI Host Controller
[    1.396371] usb usb2: Manufacturer: Linux 2.6.34-my005 ehci_hcd
[    1.396372] usb usb2: SerialNumber: 0000:00:1d.7
[    1.396426] hub 2-0:1.0: USB hub found
[    1.396429] hub 2-0:1.0: 6 ports detected
[    1.396481] uhci_hcd 0000:00:1a.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    1.396487] uhci_hcd 0000:00:1a.0: setting latency timer to 64
[    1.396489] uhci_hcd 0000:00:1a.0: UHCI Host Controller
[    1.396494] uhci_hcd 0000:00:1a.0: new USB bus registered, assigned
bus number 3
[    1.396521] uhci_hcd 0000:00:1a.0: irq 16, io base 0x0000ff00
[    1.396545] usb usb3: New USB device found, idVendor=1d6b, idProduct=0001
[    1.396546] usb usb3: New USB device strings: Mfr=3, Product=2,
SerialNumber=1
[    1.396548] usb usb3: Product: UHCI Host Controller
[    1.396549] usb usb3: Manufacturer: Linux 2.6.34-my005 uhci_hcd
[    1.396550] usb usb3: SerialNumber: 0000:00:1a.0
[    1.396601] hub 3-0:1.0: USB hub found
[    1.396603] hub 3-0:1.0: 2 ports detected
[    1.396644]   alloc irq_desc for 21 on node -1
[    1.396645]   alloc kstat_irqs on node -1
[    1.396649] uhci_hcd 0000:00:1a.1: PCI INT B -> GSI 21 (level, low) -> IRQ 21
[    1.396653] uhci_hcd 0000:00:1a.1: setting latency timer to 64
[    1.396655] uhci_hcd 0000:00:1a.1: UHCI Host Controller
[    1.396660] uhci_hcd 0000:00:1a.1: new USB bus registered, assigned
bus number 4
[    1.396685] uhci_hcd 0000:00:1a.1: irq 21, io base 0x0000fe00
[    1.396705] usb usb4: New USB device found, idVendor=1d6b, idProduct=0001
[    1.396707] usb usb4: New USB device strings: Mfr=3, Product=2,
SerialNumber=1
[    1.396708] usb usb4: Product: UHCI Host Controller
[    1.396709] usb usb4: Manufacturer: Linux 2.6.34-my005 uhci_hcd
[    1.396711] usb usb4: SerialNumber: 0000:00:1a.1
[    1.396760] hub 4-0:1.0: USB hub found
[    1.396763] hub 4-0:1.0: 2 ports detected
[    1.396803] uhci_hcd 0000:00:1a.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
[    1.396807] uhci_hcd 0000:00:1a.2: setting latency timer to 64
[    1.396809] uhci_hcd 0000:00:1a.2: UHCI Host Controller
[    1.396813] uhci_hcd 0000:00:1a.2: new USB bus registered, assigned
bus number 5
[    1.396833] uhci_hcd 0000:00:1a.2: irq 18, io base 0x0000fd00
[    1.396854] usb usb5: New USB device found, idVendor=1d6b, idProduct=0001
[    1.396856] usb usb5: New USB device strings: Mfr=3, Product=2,
SerialNumber=1
[    1.396857] usb usb5: Product: UHCI Host Controller
[    1.396858] usb usb5: Manufacturer: Linux 2.6.34-my005 uhci_hcd
[    1.396860] usb usb5: SerialNumber: 0000:00:1a.2
[    1.396913] hub 5-0:1.0: USB hub found
[    1.396916] hub 5-0:1.0: 2 ports detected
[    1.396956] uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 23 (level, low) -> IRQ 23
[    1.396960] uhci_hcd 0000:00:1d.0: setting latency timer to 64
[    1.396962] uhci_hcd 0000:00:1d.0: UHCI Host Controller
[    1.396967] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned
bus number 6
[    1.396987] uhci_hcd 0000:00:1d.0: irq 23, io base 0x0000fc00
[    1.397007] usb usb6: New USB device found, idVendor=1d6b, idProduct=0001
[    1.397008] usb usb6: New USB device strings: Mfr=3, Product=2,
SerialNumber=1
[    1.397010] usb usb6: Product: UHCI Host Controller
[    1.397011] usb usb6: Manufacturer: Linux 2.6.34-my005 uhci_hcd
[    1.397012] usb usb6: SerialNumber: 0000:00:1d.0
[    1.397063] hub 6-0:1.0: USB hub found
[    1.397066] hub 6-0:1.0: 2 ports detected
[    1.397106] uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[    1.397110] uhci_hcd 0000:00:1d.1: setting latency timer to 64
[    1.397112] uhci_hcd 0000:00:1d.1: UHCI Host Controller
[    1.397117] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned
bus number 7
[    1.397142] uhci_hcd 0000:00:1d.1: irq 19, io base 0x0000fb00
[    1.397163] usb usb7: New USB device found, idVendor=1d6b, idProduct=0001
[    1.397164] usb usb7: New USB device strings: Mfr=3, Product=2,
SerialNumber=1
[    1.397166] usb usb7: Product: UHCI Host Controller
[    1.397167] usb usb7: Manufacturer: Linux 2.6.34-my005 uhci_hcd
[    1.397168] usb usb7: SerialNumber: 0000:00:1d.1
[    1.397217] hub 7-0:1.0: USB hub found
[    1.397219] hub 7-0:1.0: 2 ports detected
[    1.397258] uhci_hcd 0000:00:1d.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
[    1.397262] uhci_hcd 0000:00:1d.2: setting latency timer to 64
[    1.397265] uhci_hcd 0000:00:1d.2: UHCI Host Controller
[    1.397268] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned
bus number 8
[    1.397290] uhci_hcd 0000:00:1d.2: irq 18, io base 0x0000fa00
[    1.397310] usb usb8: New USB device found, idVendor=1d6b, idProduct=0001
[    1.397311] usb usb8: New USB device strings: Mfr=3, Product=2,
SerialNumber=1
[    1.397313] usb usb8: Product: UHCI Host Controller
[    1.397314] usb usb8: Manufacturer: Linux 2.6.34-my005 uhci_hcd
[    1.397315] usb usb8: SerialNumber: 0000:00:1d.2
[    1.397364] hub 8-0:1.0: USB hub found
[    1.397366] hub 8-0:1.0: 2 ports detected
[    1.407842] firewire_ohci: Added fw-ohci device 0000:09:06.0, OHCI
v1.10, 4 IR + 8 IT contexts, quirks 0x2
[    1.501147] ata1.00: ATAPI: HL-DT-ST DVD-ROM GDR-H30N, 1.00, max UDMA/33
[    1.516268] ata1.00: configured for UDMA/33
[    1.517328] scsi 0:0:0:0: CD-ROM            HL-DT-ST DVD-ROM
GDR-H30N 1.00 PQ: 0 ANSI: 5
[    1.647578] usb 1-1: new high speed USB device using ehci_hcd and address 2
[    1.695525] ata3: SATA link down (SStatus 0 SControl 300)
[    1.719512] ata9: SATA link down (SStatus 0 SControl 300)
[    1.719518] ata10: SATA link down (SStatus 0 SControl 300)
[    1.781005] usb 1-1: New USB device found, idVendor=093b, idProduct=0048
[    1.781008] usb 1-1: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[    1.781011] usb 1-1: Product: DVDR   PX-755A
[    1.781012] usb 1-1: Manufacturer: PLEXTOR
[    1.781014] usb 1-1: SerialNumber: 00D0A905301116905
[    1.785404] Initializing USB Mass Storage driver...
[    1.785466] scsi10 : usb-storage 1-1:1.0
[    1.785508] usbcore: registered new interface driver usb-storage
[    1.785510] USB Mass Storage support registered.
[    1.907318] firewire_core: created device fw0: GUID 00ab819900001fd0, S400
[    2.059103] usb 1-6: new high speed USB device using ehci_hcd and address 5
[    2.191909] usb 1-6: New USB device found, idVendor=0d49, idProduct=7450
[    2.191912] usb 1-6: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[    2.191915] usb 1-6: Product: Basics Portable
[    2.191917] usb 1-6: Manufacturer: Maxtor
[    2.191919] usb 1-6: SerialNumber: 2HB1TX0D
[    2.192163] scsi11 : usb-storage 1-6:1.0
[    2.195824] ata4: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[    2.197351] ata4.00: HPA detected: current 1953523055, native 1953525168
[    2.197357] ata4.00: ATA-8: ST31000340AS, SD15, max UDMA/133
[    2.197360] ata4.00: 1953523055 sectors, multi 0: LBA48 NCQ (depth 31/32)
[    2.199275] ata4.00: configured for UDMA/133
[    2.215000] scsi 3:0:0:0: Direct-Access     ATA      ST31000340AS
  SD15 PQ: 0 ANSI: 5
[    2.310811] usb 2-2: new high speed USB device using ehci_hcd and address 2
[    2.459922] usb 2-2: New USB device found, idVendor=148f, idProduct=2870
[    2.459925] usb 2-2: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[    2.459927] usb 2-2: Product: 802.11 n WLAN
[    2.459929] usb 2-2: Manufacturer: Ralink
[    2.459931] usb 2-2: SerialNumber: 1.0
[    2.534561] ata5: SATA link down (SStatus 0 SControl 300)
[    2.570512] usb 2-6: new high speed USB device using ehci_hcd and address 3
[    2.707388] usb 2-6: New USB device found, idVendor=13fd, idProduct=1340
[    2.707392] usb 2-6: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[    2.707394] usb 2-6: Product: External
[    2.707396] usb 2-6: Manufacturer: Generic
[    2.707398] usb 2-6: SerialNumber: 35564D314552474E20202020
[    2.707658] scsi12 : usb-storage 2-6:1.0
[    2.783626] scsi 10:0:0:0: CD-ROM            PLEXTOR  DVDR
PX-755A   1.08 PQ: 0 ANSI: 0
[    2.946080] usb 3-2: new low speed USB device using uhci_hcd and address 2
[    3.130565] usb 3-2: New USB device found, idVendor=046d, idProduct=c03e
[    3.130568] usb 3-2: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    3.130571] usb 3-2: Product: USB-PS/2 Optical Mouse
[    3.130573] usb 3-2: Manufacturer: Logitech
[    3.190285] scsi 11:0:0:0: Direct-Access     Maxtor   Basics
Portable  0122 PQ: 0 ANSI: 4
[    3.193717] sd 3:0:0:0: [sda] 1953523055 512-byte logical blocks:
(1.00 TB/931 GiB)
[    3.193751] sd 3:0:0:0: [sda] Write Protect is off
[    3.193753] sd 3:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    3.193769] sd 3:0:0:0: [sda] Write cache: enabled, read cache:
enabled, doesn't support DPO or FUA
[    3.193853]  sda:
[    3.194271] sd 11:0:0:0: [sdb] 488397168 512-byte logical blocks:
(250 GB/232 GiB)
[    3.194893] sd 11:0:0:0: [sdb] Write Protect is off
[    3.194896] sd 11:0:0:0: [sdb] Mode Sense: 2d 08 00 00
[    3.194898] sd 11:0:0:0: [sdb] Assuming drive cache: write through
[    3.196139] sd 11:0:0:0: [sdb] Assuming drive cache: write through
[    3.196182]  sdb: sda1 sda2 sda3 sda4 < sda5 sda6 sda7 >
[    3.261117] sd 3:0:0:0: [sda] Attached SCSI disk
[    3.337485]  sdb1 sdb2 sdb3 sdb4 < sdb5
[    3.369597] usb 5-1: new full speed USB device using uhci_hcd and address 2
[    3.370815]  sdb6 >
[    3.372064] sd 11:0:0:0: [sdb] Assuming drive cache: write through
[    3.372106] sd 11:0:0:0: [sdb] Attached SCSI disk
[    3.437526] ata6: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[    3.440570] ata6.00: ATA-8: WDC WD15EADS-00P8B0, 01.00A01, max UDMA/133
[    3.440574] ata6.00: 2930277168 sectors, multi 0: LBA48 NCQ (depth 31/32), AA
[    3.444584] ata6.00: configured for UDMA/133
[    3.457560] scsi 5:0:0:0: Direct-Access     ATA      WDC
WD15EADS-00P 01.0 PQ: 0 ANSI: 5
[    3.457644] sd 5:0:0:0: [sdc] 2930277168 512-byte logical blocks:
(1.50 TB/1.36 TiB)
[    3.457671] sd 5:0:0:0: [sdc] Write Protect is off
[    3.457673] sd 5:0:0:0: [sdc] Mode Sense: 00 3a 00 00
[    3.457690] sd 5:0:0:0: [sdc] Write cache: enabled, read cache:
enabled, doesn't support DPO or FUA
[    3.457761]  sdc: sdc1 sdc2 sdc3 sdc4 < sdc5 sdc6 sdc7 sdc8 sdc9
sdc10 sdc11 sdc12 >
[    3.571183] sd 5:0:0:0: [sdc] Attached SCSI disk
[    3.576367] usb 5-1: New USB device found, idVendor=03f0, idProduct=c102
[    3.576369] usb 5-1: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[    3.576371] usb 5-1: Product: Photosmart 8000 series
[    3.576372] usb 5-1: Manufacturer: HP
[    3.576373] usb 5-1: SerialNumber: MY578141KD0497
[    3.579532] scsi13 : usb-storage 5-1:1.2
[    3.705766] scsi 12:0:0:0: Direct-Access     Generic  External
   2.12 PQ: 0 ANSI: 4
[    3.706623] sd 12:0:0:0: [sdd] 976773168 512-byte logical blocks:
(500 GB/465 GiB)
[    3.707134] sd 12:0:0:0: [sdd] Write Protect is off
[    3.707137] sd 12:0:0:0: [sdd] Mode Sense: 23 00 00 00
[    3.707140] sd 12:0:0:0: [sdd] Assuming drive cache: write through
[    3.708248] sd 12:0:0:0: [sdd] Assuming drive cache: write through
[    3.708290]  sdd: sdd1
[    3.709992] sd 12:0:0:0: [sdd] Assuming drive cache: write through
[    3.710030] sd 12:0:0:0: [sdd] Attached SCSI disk
[    3.778014] ata7: SATA link down (SStatus 0 SControl 300)
[    4.112752] ata8: SATA link down (SStatus 0 SControl 300)
[    4.139497] usbcore: registered new interface driver hiddev
[    4.141038] sr0: scsi3-mmc drive: 4x/52x cd/rw xa/form2 cdda tray
[    4.141040] Uniform CD-ROM driver Revision: 3.20
[    4.141107] sr 0:0:0:0: Attached scsi CD-ROM sr0
[    4.141929] sr 0:0:0:0: Attached scsi generic sg0 type 5
[    4.141961] sd 3:0:0:0: Attached scsi generic sg1 type 0
[    4.141990] sr 10:0:0:0: Attached scsi generic sg2 type 5
[    4.142020] sd 11:0:0:0: Attached scsi generic sg3 type 0
[    4.142052] sd 5:0:0:0: Attached scsi generic sg4 type 0
[    4.142086] sd 12:0:0:0: Attached scsi generic sg5 type 0
[    4.152512] input: Logitech USB-PS/2 Optical Mouse as
/devices/pci0000:00/0000:00:1a.0/usb3/3-2/3-2:1.0/input/input1
[    4.152559] generic-usb 0003:046D:C03E.0001: input,hidraw0: USB HID
v1.10 Mouse [Logitech USB-PS/2 Optical Mouse] on
usb-0000:00:1a.0-2/input0
[    4.152584] usbcore: registered new interface driver usbhid
[    4.152586] usbhid: USB HID core driver
[    4.154673] sr1: scsi3-mmc drive: 40x/40x writer cd/rw xa/form2 cdda tray
[    4.154762] sr 10:0:0:0: Attached scsi CD-ROM sr1
[    4.581239] scsi 13:0:0:0: Direct-Access     HP       Photosmart
8000  1.00 PQ: 0 ANSI: 2
[    4.581534] sd 13:0:0:0: Attached scsi generic sg6 type 0
[    4.591212] sd 13:0:0:0: [sde] Attached SCSI removable disk
[    5.130974] Btrfs loaded
[    5.160338] device fsid 484ba5d56744673f-f791b0ee91f14699 devid 1
transid 56783 /dev/sdd1
[    5.231048] device fsid 7444eab87ea44d4d-26f2bd9739872398 devid 1
transid 2573 /dev/sdc12
[    5.243930] device fsid b54dacbe4947f9c5-744a8cf12ee08b9b devid 1
transid 2129 /dev/sdc11
[    5.272132] device fsid 348ba5d125b5737-10907b38c5b55e85 devid 1
transid 2167 /dev/sdc10
[    5.288199] device fsid fc423457edfbc2dc-7112bb1eb56d68a devid 1
transid 2070 /dev/sdc9
[    5.316316] device fsid 4b4d967d6a9cc7e3-64d7623f4a8a608d devid 1
transid 2380 /dev/sdc8
[    5.330488] device fsid 9640ef905c1133d5-ebb4cc7c38f97a94 devid 1
transid 2278 /dev/sdc7
[    5.342910] device fsid 25403a55018d33c6-d02a5e2eccc62089 devid 1
transid 4001 /dev/sdc6
[    5.360649] device fsid d945f39b246e1a8d-465a384b7dbb039d devid 1
transid 3643 /dev/sdc5
[    5.373170] device fsid d444d230a3dc1898-1ac24fc8a025409e devid 1
transid 3611 /dev/sdc3
[    5.462177] device fsid 9f4383db36d71b8c-29e40fb9ad2b008b devid 1
transid 2182 /dev/sdb6
[    5.472556] device fsid 3f4c30d990ea3e04-4af3569089e64ea3 devid 1
transid 2107 /dev/sdb5
[    5.487274] device fsid f6405d8c15f43b54-c8ed47139c13fe86 devid 1
transid 2446 /dev/sdb3
[    5.510871] device fsid 7d49527cfeeacf2e-a3d16e4cf233a2ad devid 1
transid 2394 /dev/sdb2
[    5.528868] device fsid 854519ce428afb68-f37804b53514fe9c devid 1
transid 3967 /dev/sdb1
[    5.557676] device fsid 714842af37fceb78-f04149c589169485 devid 1
transid 2622 /dev/sda7
[    5.591076] device fsid be40cd55e458de3b-30a8fb9519ce9cb0 devid 1
transid 2368 /dev/sda5
[   18.181323] end_request: I/O error, dev fd0, sector 0
[   18.182732] PM: Starting manual resume from disk
[   18.182734] PM: Resume from partition 8:1
[   18.182735] PM: Checking hibernation image.
[   18.183066] PM: Error -22 checking image file
[   18.183069] PM: Resume from disk failed.
[   18.185550] PM: Marking nosave pages: 000000000009d000 - 0000000000100000
[   18.185553] PM: Marking nosave pages: 00000000dfde0000 - 0000000100000000
[   18.186023] PM: Basic memory bitmaps created
[   18.223920] PM: Basic memory bitmaps freed
[   18.275134] kjournald starting.  Commit interval 5 seconds
[   18.275139] EXT3-fs (sda3): mounted filesystem with ordered data mode
[   19.342758] udev: starting version 154
[   19.531368] input: Power Button as
/devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0C:00/input/input2
[   19.531373] ACPI: Power Button [PWRB]
[   19.531431] input: Power Button as
/devices/LNXSYSTM:00/LNXPWRBN:00/input/input3
[   19.531435] ACPI: Power Button [PWRF]
[   19.640097] input: PC Speaker as /devices/platform/pcspkr/input/input4
[   19.672022] ACPI: WMI: Mapper loaded
[   19.699089] i801_smbus 0000:00:1f.3: PCI INT C -> GSI 18 (level,
low) -> IRQ 18
[   19.950667] [drm] radeon kernel modesetting enabled.
[   19.950729] radeon 0000:02:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[   19.950733] radeon 0000:02:00.0: setting latency timer to 64
[   19.951696] [drm] initializing kernel modesetting (RV770 0x1002:0x9442).
[   19.951849] [drm] register mmio base: 0xFBBE0000
[   19.951850] [drm] register mmio size: 65536
[   19.952090] ATOM BIOS: Wekiva
[   19.952098] [drm] Clocks initialized !
[   19.952099] [drm] Internal thermal controller with fan control
[   19.952101] [drm] 4 Power State(s)
[   19.952102] [drm] State 0 Default (default)
[   19.952103] [drm] 	16 PCIE Lanes
[   19.952104] [drm] 	3 Clock Mode(s)
[   19.952105] [drm] 		0 engine/memory: 625000/993000
[   19.952106] [drm] 		1 engine/memory: 625000/993000
[   19.952108] [drm] 		2 engine/memory: 625000/993000
[   19.952109] [drm] State 1 Performance
[   19.952110] [drm] 	16 PCIE Lanes
[   19.952110] [drm] 	3 Clock Mode(s)
[   19.952111] [drm] 		0 engine/memory: 500000/993000
[   19.952113] [drm] 		1 engine/memory: 500000/993000
[   19.952114] [drm] 		2 engine/memory: 625000/993000
[   19.952115] [drm] State 2 Default
[   19.952116] [drm] 	16 PCIE Lanes
[   19.952116] [drm] 	3 Clock Mode(s)
[   19.952117] [drm] 		0 engine/memory: 625000/993000
[   19.952119] [drm] 		1 engine/memory: 625000/993000
[   19.952120] [drm] 		2 engine/memory: 625000/993000
[   19.952121] [drm] State 3 Performance
[   19.952122] [drm] 	16 PCIE Lanes
[   19.952123] [drm] 	3 Clock Mode(s)
[   19.952124] [drm] 		0 engine/memory: 625000/993000
[   19.952125] [drm] 		1 engine/memory: 625000/993000
[   19.952126] [drm] 		2 engine/memory: 625000/993000
[   19.952130] [drm] radeon: power management initialized
[   19.952137] radeon 0000:02:00.0: VRAM: 256M 0x00000000 - 0x0FFFFFFF
(256M used)
[   19.952139] radeon 0000:02:00.0: GTT: 512M 0x10000000 - 0x2FFFFFFF
[   19.952153] mtrr: type mismatch for e0000000,10000000 old:
write-back new: write-combining
[   19.952154] [drm] Detected VRAM RAM=256M, BAR=256M
[   19.952155] [drm] RAM width 256bits DDR
[   19.952183] [TTM] Zone  kernel: Available graphics memory: 6166340 kiB.
[   19.952185] [TTM] Zone   dma32: Available graphics memory: 2097152 kiB.
[   19.952194] [drm] radeon: 256M of VRAM memory ready
[   19.952195] [drm] radeon: 512M of GTT memory ready.
[   19.952222]   alloc irq_desc for 35 on node -1
[   19.952224]   alloc kstat_irqs on node -1
[   19.952231] radeon 0000:02:00.0: irq 35 for MSI/MSI-X
[   19.952235] [drm] radeon: using MSI.
[   19.952260] [drm] radeon: irq initialized.
[   19.952262] [drm] GART: num cpu pages 131072, num gpu pages 131072
[   19.952683] [drm] Loading RV770 Microcode
[   19.952686] platform radeon_cp.0: firmware: requesting radeon/RV770_pfp.bin
[   20.173450] usblp0: USB Bidirectional printer dev 2 if 0 alt 0
proto 2 vid 0x03F0 pid 0xC102
[   20.173466] usbcore: registered new interface driver usblp
[   20.273181] rt2870sta: module is from the staging directory, the
quality is unknown, you have been warned.
[   20.275920] rtusb init --->
[   20.275990] === pAd = ffffc90006750000, size = 502256 ===
[   20.275991] <-- RTMPAllocAdapterBlock, Status=0
[   20.276565] usbcore: registered new interface driver rt2870
[   20.489936] platform radeon_cp.0: firmware: requesting radeon/RV770_me.bin
[   20.514570] platform radeon_cp.0: firmware: requesting radeon/R700_rlc.bin
[   20.624360] [drm] ring test succeeded in 1 usecs
[   20.624419] [drm] radeon: ib pool ready.
[   20.624464] [drm] ib test succeeded in 0 usecs
[   20.624466] [drm] Enabling audio support
[   20.624524] [drm] Default TV standard: PAL
[   20.624528] [drm] Default TV standard: PAL
[   20.624548] [drm] Default TV standard: PAL
[   20.624591] [drm] Radeon Display Connectors
[   20.624593] [drm] Connector 0:
[   20.624594] [drm]   DVI-I
[   20.624595] [drm]   HPD1
[   20.624597] [drm]   DDC: 0x7e60 0x7e60 0x7e64 0x7e64 0x7e68 0x7e68
0x7e6c 0x7e6c
[   20.624599] [drm]   Encoders:
[   20.624601] [drm]     DFP1: INTERNAL_UNIPHY
[   20.624602] [drm]     CRT2: INTERNAL_KLDSCP_DAC2
[   20.624604] [drm] Connector 1:
[   20.624605] [drm]   DIN
[   20.624606] [drm]   Encoders:
[   20.624607] [drm]     TV1: INTERNAL_KLDSCP_DAC2
[   20.624608] [drm] Connector 2:
[   20.624610] [drm]   DVI-I
[   20.624611] [drm]   HPD2
[   20.624613] [drm]   DDC: 0x7e20 0x7e20 0x7e24 0x7e24 0x7e28 0x7e28
0x7e2c 0x7e2c
[   20.624614] [drm]   Encoders:
[   20.624615] [drm]     CRT1: INTERNAL_KLDSCP_DAC1
[   20.624617] [drm]     DFP2: INTERNAL_KLDSCP_LVTMA
[   20.677737]   alloc irq_desc for 22 on node -1
[   20.677739]   alloc kstat_irqs on node -1
[   20.677745] HDA Intel 0000:00:1b.0: PCI INT A -> GSI 22 (level,
low) -> IRQ 22
[   20.677784]   alloc irq_desc for 36 on node -1
[   20.677785]   alloc kstat_irqs on node -1
[   20.677793] HDA Intel 0000:00:1b.0: irq 36 for MSI/MSI-X
[   20.677812] HDA Intel 0000:00:1b.0: setting latency timer to 64
[   20.759267] hda_codec: ALC889A: BIOS auto-probing.
[   20.760551] input: HDA Digital PCBeep as
/devices/pci0000:00/0000:00:1b.0/input/input5
[   20.761132] [drm] fb mappable at 0xE0141000
[   20.761133] [drm] vram apper at 0xE0000000
[   20.761134] [drm] size 5242880
[   20.761135] [drm] fb depth is 24
[   20.761136] [drm]    pitch is 5120
[   20.776577] Console: switching to colour frame buffer device 160x64
[   20.779250] fb0: radeondrmfb frame buffer device
[   20.779251] registered panic notifier
[   20.779254] [drm] Initialized radeon 2.3.0 20080528 for
0000:02:00.0 on minor 0
[   20.779275] HDA Intel 0000:02:00.1: PCI INT B -> GSI 17 (level,
low) -> IRQ 17
[   20.779316]   alloc irq_desc for 37 on node -1
[   20.779319]   alloc kstat_irqs on node -1
[   20.779327] HDA Intel 0000:02:00.1: irq 37 for MSI/MSI-X
[   20.779345] HDA Intel 0000:02:00.1: setting latency timer to 64
[   22.949224] Adding 48828412k swap on /dev/sda1.  Priority:-1
extents:1 across:48828412k
[   23.443893] EXT3-fs (sda3): using internal journal
[   23.520076] loop: module loaded
[   23.536648] coretemp coretemp.0: Unable to access MSR 0xEE, for
Tjmax, left at default
[   23.536691] coretemp coretemp.1: Unable to access MSR 0xEE, for
Tjmax, left at default
[   23.536728] coretemp coretemp.2: Unable to access MSR 0xEE, for
Tjmax, left at default
[   23.536769] coretemp coretemp.3: Unable to access MSR 0xEE, for
Tjmax, left at default
[   23.536806] coretemp coretemp.4: Unable to access MSR 0xEE, for
Tjmax, left at default
[   23.536842] coretemp coretemp.5: Unable to access MSR 0xEE, for
Tjmax, left at default
[   23.536879] coretemp coretemp.6: Unable to access MSR 0xEE, for
Tjmax, left at default
[   23.536915] coretemp coretemp.7: Unable to access MSR 0xEE, for
Tjmax, left at default
[   23.544342] it87: Found IT8720F chip at 0x290, revision 5
[   23.544350] it87: VID is disabled (pins used for GPIO)
[   23.544356] it87: in3 is VCC (+5V)
[   23.544360] it87: Beeping is supported
[   24.808828] fuse init (API version 7.13)
[   25.132898] microcode: CPU0 sig=0x106a4, pf=0x2, revision=0xa
[   25.132902] platform microcode: firmware: requesting intel-ucode/06-1a-04
[   25.153751] microcode: CPU1 sig=0x106a4, pf=0x2, revision=0xa
[   25.153755] platform microcode: firmware: requesting intel-ucode/06-1a-04
[   25.154789] microcode: CPU2 sig=0x106a4, pf=0x2, revision=0xa
[   25.154792] platform microcode: firmware: requesting intel-ucode/06-1a-04
[   25.155789] microcode: CPU3 sig=0x106a4, pf=0x2, revision=0xa
[   25.155793] platform microcode: firmware: requesting intel-ucode/06-1a-04
[   25.156800] microcode: CPU4 sig=0x106a4, pf=0x2, revision=0xa
[   25.156803] platform microcode: firmware: requesting intel-ucode/06-1a-04
[   25.157830] microcode: CPU5 sig=0x106a4, pf=0x2, revision=0xa
[   25.157833] platform microcode: firmware: requesting intel-ucode/06-1a-04
[   25.158888] microcode: CPU6 sig=0x106a4, pf=0x2, revision=0xa
[   25.158892] platform microcode: firmware: requesting intel-ucode/06-1a-04
[   25.159937] microcode: CPU7 sig=0x106a4, pf=0x2, revision=0xa
[   25.159940] platform microcode: firmware: requesting intel-ucode/06-1a-04
[   25.161052] microcode: Microcode Update Driver: v2.00
<tigran@aivazian.fsnet.co.uk>, Peter Oruba
[   25.311727] microcode: CPU0 updated to revision 0x11, date = 2009-04-21
[   25.312868] microcode: CPU1 updated to revision 0x11, date = 2009-04-21
[   25.314236] microcode: CPU2 updated to revision 0x11, date = 2009-04-21
[   25.315831] microcode: CPU3 updated to revision 0x11, date = 2009-04-21
[   25.317734] microcode: CPU4 updated to revision 0x11, date = 2009-04-21
[   25.319956] microcode: CPU5 updated to revision 0x11, date = 2009-04-21
[   25.322521] microcode: CPU6 updated to revision 0x11, date = 2009-04-21
[   25.325573] microcode: CPU7 updated to revision 0x11, date = 2009-04-21
[   27.589604] lp: driver loaded but no devices found
[   27.636343] ppdev: user-space parallel port driver
[   31.730582] r8169 0000:07:00.0: eth0: link down
[   31.732322] ADDRCONF(NETDEV_UP): eth0: link is not ready
[   31.769157] usb 2-2: firmware: requesting rt2870.bin
[   32.141654] <-- RTMPAllocTxRxRingMemory, Status=0
[   32.143094] -->RTUSBVenderReset
[   32.143219] <--RTUSBVenderReset
[   32.423901] 1. Phy Mode = 0
[   32.423903] 2. Phy Mode = 0
[   32.451619] 3. Phy Mode = 0
[   32.456863] RTMPSetPhyMode: channel is out of range, use first channel=1
[   32.456867] MCS Set = 00 00 00 00 00
[   32.465852] <==== rt28xx_init, Status=0
[   32.467350] 0x1300 = 000a4200
[   38.270150] ===>rt_ioctl_giwscan. 3(3) BSS returned, data->length = 553
[   43.407683] wlan0: no IPv6 routers present
[   58.666521] ===>rt_ioctl_giwscan. 2(2) BSS returned, data->length = 361
[   73.378154] end_request: I/O error, dev fd0, sector 0
[   85.540697] end_request: I/O error, dev fd0, sector 0

-- 
Giangiacomo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
