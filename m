Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 2236E6B0071
	for <linux-mm@kvack.org>; Mon,  7 Jun 2010 18:39:02 -0400 (EDT)
Date: Mon, 7 Jun 2010 17:35:27 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: Possible bug in 2.6.34 slub
In-Reply-To: <AANLkTimXxhVCu50GweoC7iF9tFEoSrWAbqQEXRroGnBk@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1006071730460.12520@router.home>
References: <AANLkTimEFy6VM3InWlqhVooQjKGSD3yBxlgeRbQC2r1L@mail.gmail.com> <20100531165528.35a323fb.rdunlap@xenotime.net> <4C047CF9.9000804@tmr.com> <AANLkTilLq-hn59CBcLnOsnT37ZizQR6MrZX6btKPhfpb@mail.gmail.com> <20100601123959.747228c6.rdunlap@xenotime.net>
 <alpine.DEB.2.00.1006011445100.9438@router.home> <AANLkTinxOJShwd7xUornVI89BmJnbX9-a7LVWaciNdr5@mail.gmail.com> <alpine.DEB.2.00.1006030833070.24954@router.home> <AANLkTimXxhVCu50GweoC7iF9tFEoSrWAbqQEXRroGnBk@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Giangiacomo Mariotti <gg.mariotti@gmail.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Randy Dunlap <rdunlap@xenotime.net>, Bill Davidsen <davidsen@tmr.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86 maintainers <x86@kernel.org>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

On Fri, 4 Jun 2010, Giangiacomo Mariotti wrote:

> [    0.000000] found SMP MP-table at [ffff8800000f5ed0] f5ed0

SMP table is important.

> [    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x02] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x04] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x06] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x01] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x05] lapic_id[0x03] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x06] lapic_id[0x05] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x07] lapic_id[0x07] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x08] lapic_id[0x08] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x09] lapic_id[0x09] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x0a] lapic_id[0x0a] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x0b] lapic_id[0x0b] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x0c] lapic_id[0x0c] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x0d] lapic_id[0x0d] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x0e] lapic_id[0x0e] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x0f] lapic_id[0x0f] disabled)
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] dfl dfl lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] dfl dfl lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x02] dfl dfl lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x03] dfl dfl lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x04] dfl dfl lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x05] dfl dfl lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x06] dfl dfl lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x07] dfl dfl lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x08] dfl dfl lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x09] dfl dfl lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0a] dfl dfl lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0b] dfl dfl lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0c] dfl dfl lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0d] dfl dfl lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0e] dfl dfl lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0f] dfl dfl lint[0x1])
> [    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
> [    0.000000] IOAPIC[0]: apic_id 2, version 32, address 0xfec00000, GSI 0-23
> [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
> [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
> [    0.000000] ACPI: IRQ0 used by override.
> [    0.000000] ACPI: IRQ2 used by override.
> [    0.000000] ACPI: IRQ9 used by override.
> [    0.000000] Using ACPI (MADT) for SMP configuration information
> [    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
> [    0.000000] SMP: Allowing 16 CPUs, 8 hotplug CPUs

ok so 24 cpus. 8 hotplug which should not work.

> dff00000:14100000)
> [    0.000000] setup_percpu: NR_CPUS:512 nr_cpumask_bits:512
> nr_cpu_ids:16 nr_node_ids:1

And it only has 16 now.

> [    0.000000] SLUB: Genslabs=14, HWalign=64, Order=0-3, MinObjects=0,
> CPUs=16, Nodes=1

And slub displays nr_cpu_ids again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
