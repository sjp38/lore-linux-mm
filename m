Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 691D66B56B2
	for <linux-mm@kvack.org>; Fri, 31 Aug 2018 07:29:07 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id a37-v6so8341254wrc.5
        for <linux-mm@kvack.org>; Fri, 31 Aug 2018 04:29:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r7-v6sor6884877wrj.28.2018.08.31.04.29.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 31 Aug 2018 04:29:05 -0700 (PDT)
Subject: Re: [PATCH v1] mm: relax deferred struct page requirements
References: <20171117014601.31606-1-pasha.tatashin@oracle.com>
 <20171121072416.v77vu4osm2s4o5sq@dhcp22.suse.cz>
 <b16029f0-ada0-df25-071b-cd5dba0ab756@suse.cz>
 <CAGM2rea=_VJJ26tohWQWgfwcFVkp0gb6j1edH1kVLjtxfugf5Q@mail.gmail.com>
 <CAGM2reYcwyOcKrO=WhB3Cf0FNL3ZearC=KvxmTNUU6rkWviQOg@mail.gmail.com>
 <83d035f1-40b4-bed8-6113-f4c5a0c4d22f@suse.cz>
 <c4d46b63-5237-d002-faf5-4e0749d825d7@suse.cz>
 <7aee9274-9e8e-4a40-a9e5-3c9ef28511b7@microsoft.com>
 <87516e50-a17c-6c80-e9b5-ba68eda9ce33@microsoft.com>
 <597f3f35-6aad-6ca1-ba03-b93444b1cb5f@suse.cz>
From: Jiri Slaby <jslaby@suse.cz>
Message-ID: <0acf1c74-1bd3-e425-f92b-5d084ff954a4@suse.cz>
Date: Fri, 31 Aug 2018 13:29:03 +0200
MIME-Version: 1.0
In-Reply-To: <597f3f35-6aad-6ca1-ba03-b93444b1cb5f@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Cc: "mhocko@kernel.org" <mhocko@kernel.org>, Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, "benh@kernel.crashing.org" <benh@kernel.crashing.org>, "paulus@samba.org" <paulus@samba.org>, Andrew Morton <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, "schwidefsky@de.ibm.com" <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, Linux Memory Management List <linux-mm@kvack.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>

On 08/31/2018, 01:26 PM, Jiri Slaby wrote:
> On 08/30/2018, 05:45 PM, Pasha Tatashin wrote:
>> Hi Jiri,
>>
>> I believe this bug is fixed with this change:
>>
>> d39f8fb4b7776dcb09ec3bf7a321547083078ee3
>> mm: make DEFERRED_STRUCT_PAGE_INIT explicitly depend on SPARSEMEM
> 
> Hi,
> 
> it only shifted. Enabling only SPARSEMEM works fine, enabling also
> DEFERRED_STRUCT_PAGE_INIT doesn't even boot a?? immediately reboots
> (config attached).

Wow, earlyprintk is up at the moment of crash already:
[    0.000000] Linux version 4.19.0-rc1-pae (jslaby@kunlun) (gcc version
4.8.5 (SUSE Linux)) #4 SMP PREEMPT Fri Aug 31 13:18:33 CEST 2018
[    0.000000] x86/fpu: x87 FPU will use FXSAVE
[    0.000000] BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff]
reserved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff]
reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000007cfdffff] usable
[    0.000000] BIOS-e820: [mem 0x000000007cfe0000-0x000000007cffffff]
reserved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff]
reserved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff]
reserved
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.8 present.
[    0.000000] DMI: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
1.0.0-prebuilt.qemu-project.org 04/01/2014
[    0.000000] Hypervisor detected: KVM
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000002] kvm-clock: cpu 0, msr 1d12c001, primary cpu clock
[    0.000002] kvm-clock: using sched offset of 1597117996 cycles
[    0.001395] clocksource: kvm-clock: mask: 0xffffffffffffffff
max_cycles: 0x1cd42e4dffb, max_idle_ns: 881590591483 ns
[    0.006245] tsc: Detected 2808.000 MHz processor
[    0.010055] last_pfn = 0x7cfe0 max_arch_pfn = 0x1000000
[    0.011483] x86/PAT: PAT not supported by CPU.
[    0.012580] x86/PAT: Configuration [0-7]: WB  WT  UC- UC  WB  WT  UC-
UC
[    0.020644] found SMP MP-table at [mem 0x000f5d20-0x000f5d2f] mapped
at [(ptrval)]
[    0.023528] Scanning 1 areas for low memory corruption
[    0.025047] ACPI: Early table checksum verification disabled
[    0.026581] ACPI: RSDP 0x00000000000F5B40 000014 (v00 BOCHS )
[    0.028031] ACPI: RSDT 0x000000007CFE157C 000030 (v01 BOCHS  BXPCRSDT
00000001 BXPC 00000001)
[    0.029996] ACPI: FACP 0x000000007CFE1458 000074 (v01 BOCHS  BXPCFACP
00000001 BXPC 00000001)
[    0.032234] ACPI: DSDT 0x000000007CFE0040 001418 (v01 BOCHS  BXPCDSDT
00000001 BXPC 00000001)
[    0.034662] ACPI: FACS 0x000000007CFE0000 000040
[    0.036126] ACPI: APIC 0x000000007CFE14CC 000078 (v01 BOCHS  BXPCAPIC
00000001 BXPC 00000001)
[    0.038235] ACPI: HPET 0x000000007CFE1544 000038 (v01 BOCHS  BXPCHPET
00000001 BXPC 00000001)
[    0.040373] No NUMA configuration found
[    0.041407] Faking a node at [mem 0x0000000000000000-0x000000007cfdffff]
[    0.043306] NODE_DATA(0) allocated [mem 0x367fc000-0x367fcfff]
[    0.044958] 1127MB HIGHMEM available.
[    0.045940] 871MB LOWMEM available.
[    0.046978]   mapped low ram: 0 - 367fe000
[    0.048200]   low ram: 0 - 367fe000
[    0.050830] Zone ranges:
[    0.051625]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.053295]   Normal   [mem 0x0000000001000000-0x00000000367fdfff]
[    0.054921]   HighMem  [mem 0x00000000367fe000-0x000000007cfdffff]
[    0.056408] Movable zone start for each node
[    0.057452] Early memory node ranges
[    0.058377]   node   0: [mem 0x0000000000001000-0x000000000009efff]
[    0.059946]   node   0: [mem 0x0000000000100000-0x000000007cfdffff]
[    0.061825] Reserved but unavailable: 12418 pages
[    0.061828] Initmem setup node 0 [mem
0x0000000000001000-0x000000007cfdffff]
[    0.074252] Using APIC driver default
[    0.075615] ACPI: PM-Timer IO Port: 0x608
[    0.076574] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.077995] IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GSI
0-23
[    0.079610] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.081111] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.082786] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.084297] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.085933] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.087729] Using ACPI (MADT) for SMP configuration information
[    0.089119] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.090351] smpboot: Allowing 1 CPUs, 0 hotplug CPUs
[    0.091561] PM: Registered nosave memory: [mem 0x00000000-0x00000fff]
[    0.093361] PM: Registered nosave memory: [mem 0x0009f000-0x0009ffff]
[    0.096382] PM: Registered nosave memory: [mem 0x000a0000-0x000effff]
[    0.098130] PM: Registered nosave memory: [mem 0x000f0000-0x000fffff]
[    0.099729] [mem 0x7d000000-0xfeffbfff] available for PCI devices
[    0.101034] Booting paravirtualized kernel on KVM
[    0.102034] clocksource: refined-jiffies: mask: 0xffffffff
max_cycles: 0xffffffff, max_idle_ns: 7645519600211568 ns
[    0.104207] random: get_random_bytes called from
start_kernel+0x77/0x47c with crng_init=0
[    0.105913] setup_percpu: NR_CPUS:64 nr_cpumask_bits:64 nr_cpu_ids:1
nr_node_ids:1
[    0.107548] percpu: Embedded 31 pages/cpu @(ptrval) s94604 r0 d32372
u126976
[    0.109019] KVM setup async PF for cpu 0
[    0.109825] kvm-stealtime: cpu 0, msr 367e5300
[    0.110755] Built 1 zonelists, mobility grouping on.  Total pages: 509908
[    0.112113] Policy zone: HighMem
[    0.112755] Kernel command line: earlyprintk=serial
[    0.113773] Dentry cache hash table entries: 131072 (order: 7, 524288
bytes)
[    0.115788] Inode-cache hash table entries: 65536 (order: 6, 262144
bytes)
[    0.117465] Initializing CPU#0
[    0.118522] Initializing HighMem for node 0 (000367fe:0007cfe0)
[    0.161140] BUG: unable to handle kernel NULL pointer dereference at
00000028
[    0.162671] *pdpt = 0000000000000000 *pde = f000ff53f000ff53
[    0.163857] Oops: 0000 [#1] PREEMPT SMP PTI
[    0.164862] CPU: 0 PID: 0 Comm: swapper Not tainted 4.19.0-rc1-pae #4
openSUSE Tumbleweed (unreleased)
[    0.167041] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
BIOS 1.0.0-prebuilt.qemu-project.org 04/01/2014
[    0.169389] EIP: free_unref_page_prepare.part.75+0x26/0x50
[    0.170337] Code: 00 00 00 00 e8 e7 a4 e9 ff 89 d1 c1 ea 11 55 8b 14
d5 84 d2 1c dd c1 e9 07 89 e5 56 81 e1 fc 03 00 00 53 89 cb c1 eb 05 89
ce <8b> 14 9a 83 e6 1f b9 1d 00 00 00 29 f1 d3 ea 83 e2 07 89 50 10 b8
[    0.174205] EAX: f4cfa000 EBX: 0000000a ECX: 00000150 EDX: 00000000
[    0.175422] ESI: 00000150 EDI: 00d80000 EBP: dcf2be50 ESP: dcf2be48
[    0.176724] DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068 EFLAGS: 00210007
[    0.178075] CR0: 80050033 CR2: 00000028 CR3: 1d118000 CR4: 000006b0
[    0.179354] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
[    0.180629] DR6: fffe0ff0 DR7: 00000400
[    0.181400] Call Trace:
[    0.181907]  free_unref_page+0x3a/0x90
[    0.182642]  __free_pages+0x25/0x30
[    0.183748]  free_highmem_page+0x1e/0x50
[    0.184594]  add_highpages_with_active_regions+0x123/0x125
[    0.185813]  set_highmem_pages_init+0x83/0x8d
[    0.186847]  mem_init+0x26/0x240
[    0.187590]  ? vprintk_func+0x38/0xd0
[    0.188427]  ? idt_setup_from_table.constprop.1+0x45/0x70
[    0.189666]  ? set_intr_gate+0x39/0x40
[    0.190551]  ? general_protection+0xc/0xc
[    0.191818]  ? update_intr_gate+0x1e/0x20
[    0.192817]  ? kvm_apf_trap_init+0x17/0x19
[    0.193800]  ? trap_init+0x77/0x7d
[    0.194644]  start_kernel+0x203/0x47c
[    0.195491]  ? set_init_arg+0x57/0x57
[    0.196385]  i386_start_kernel+0x143/0x146
[    0.197351]  startup_32_smp+0x164/0x168
[    0.198232] Modules linked in:
[    0.199072] CR2: 0000000000000028
[    0.199983] ---[ end trace 69f4a864c8bd9bcd ]---
[    0.201198] EIP: free_unref_page_prepare.part.75+0x26/0x50
[    0.202610] Code: 00 00 00 00 e8 e7 a4 e9 ff 89 d1 c1 ea 11 55 8b 14
d5 84 d2 1c dd c1 e9 07 89 e5 56 81 e1 fc 03 00 00 53 89 cb c1 eb 05 89
ce <8b> 14 9a 83 e6 1f b9 1d 00 00 00 29 f1 d3 ea 83 e2 07 89 50 10 b8
[    0.206942] EAX: f4cfa000 EBX: 0000000a ECX: 00000150 EDX: 00000000
[    0.208177] ESI: 00000150 EDI: 00d80000 EBP: dcf2be50 ESP: dd11fefc
[    0.209438] DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068 EFLAGS: 00210007
[    0.210826] CR0: 80050033 CR2: 00000028 CR3: 1d118000 CR4: 000006b0
[    0.212155] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
[    0.213752] DR6: fffe0ff0 DR7: 00000400


> 
> thanks,
> 


-- 
js
suse labs
