Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id D107B6B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 19:24:21 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id r140so12685928iod.12
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 16:24:21 -0800 (PST)
Received: from wolff.to (wolff.to. [98.103.208.27])
        by mx.google.com with SMTP id h77si11062053ioe.132.2017.12.19.16.24.17
        for <linux-mm@kvack.org>;
        Tue, 19 Dec 2017 16:24:20 -0800 (PST)
Date: Tue, 19 Dec 2017 18:20:20 -0600
From: Bruno Wolff III <bruno@wolff.to>
Subject: Re: Regression with a0747a859ef6 ("bdi: add error handle for
 bdi_debug_register")
Message-ID: <20171220002020.GA30561@wolff.to>
References: <CAA70yB6yofLz8pfhxXfq29sYqcGmBYLOvSruXi9XS_HM6mUrxg@mail.gmail.com>
 <20171215014417.GA17757@wolff.to>
 <CAA70yB6spi5c38kFVidRsJVaYc3W9tvpZz6wy+28rK7oeefQfw@mail.gmail.com>
 <20171215111050.GA30737@wolff.to>
 <CAA70yB66ekUGAvusQbqo7BLV+uBJtNz72cr+tZitsfjuVRWuXA@mail.gmail.com>
 <20171215195122.GA27126@wolff.to>
 <20171216163226.GA1796@wolff.to>
 <CAA70yB7wL_Wq5S8XQ9zHuLPDdwepv7dYdKALL8Sg0q6CNdAz5g@mail.gmail.com>
 <20171219161743.GA6960@wolff.to>
 <20171219182452.vpmqpi3yb4g2ecad@kernel.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="zYM0uCDKw75PZbzx"
Content-Disposition: inline
In-Reply-To: <20171219182452.vpmqpi3yb4g2ecad@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: weiping zhang <zwp10758@gmail.com>, Laura Abbott <labbott@redhat.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, regressions@leemhuis.info, linux-block@vger.kernel.org


--zYM0uCDKw75PZbzx
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline

On Tue, Dec 19, 2017 at 10:24:52 -0800,
  Shaohua Li <shli@kernel.org> wrote:
>
>Not sure if this is MD related, but could you please check if this debug patch
>changes anything?

The system still had cpu hangs. I've attached dmesg output saved by systemd 
and retrieved after booting with a pre-rc2 kernel.

--zYM0uCDKw75PZbzx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="boot11.log"

-- Logs begin at Sun 2017-10-15 17:28:43 CDT, end at Tue 2017-12-19 16:44:19 CST. --
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: microcode: microcode updated early to revision 0x3a, date = 2017-01-30
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: Linux version 4.15.0-rc4+ (bruno@cerberus.csd.uwm.edu) (gcc version 7.2.1 20170915 (Red Hat 7.2.1-4) (GCC)) #20 SMP Tue Dec 19 16:11:36 CST 2017
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: Command line: BOOT_IMAGE=/vmlinuz-4.15.0-rc4+ root=/dev/mapper/luks-f5e2d09b-f8a3-487d-9517-abe4fb0eada3 ro rd.md.uuid=7f4fcca0:13b1445f:a91ff455:6bb1ab48 rd.luks.uuid=luks-cc6ee93c-e729-4f78-9baf-0cc5cc8a9ff1 rd.md.uuid=ef18531c:760102fb:7797cbdb:5cf9516f rd.md.uuid=42efe386:0c315f28:f7c61920:ea098f81 rd.luks.uuid=luks-f5e2d09b-f8a3-487d-9517-abe4fb0eada3 LANG=en_US.UTF-8
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: x86/fpu: Supporting XSAVE feature 0x001: 'x87 floating point registers'
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: x86/fpu: Supporting XSAVE feature 0x002: 'SSE registers'
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: x86/fpu: Supporting XSAVE feature 0x004: 'AVX registers'
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: x86/fpu: xstate_offset[2]:  576, xstate_sizes[2]:  256
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: x86/fpu: Enabled xstate features 0x7, context size is 832 bytes, using 'standard' format.
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: e820: BIOS-provided physical RAM map:
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: BIOS-e820: [mem 0x0000000000000000-0x000000000009e7ff] usable
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: BIOS-e820: [mem 0x000000000009e800-0x000000000009ffff] reserved
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] reserved
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: BIOS-e820: [mem 0x0000000000100000-0x00000000998f1fff] usable
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: BIOS-e820: [mem 0x00000000998f2000-0x000000009a29dfff] reserved
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: BIOS-e820: [mem 0x000000009a29e000-0x000000009a2e6fff] ACPI data
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: BIOS-e820: [mem 0x000000009a2e7000-0x000000009af43fff] ACPI NVS
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: BIOS-e820: [mem 0x000000009af44000-0x000000009b40afff] reserved
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: BIOS-e820: [mem 0x000000009b40b000-0x000000009b40bfff] usable
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: BIOS-e820: [mem 0x000000009b40c000-0x000000009b419fff] reserved
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: BIOS-e820: [mem 0x000000009b41a000-0x000000009cffffff] usable
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: BIOS-e820: [mem 0x00000000a0000000-0x00000000afffffff] reserved
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: BIOS-e820: [mem 0x00000000fed1c000-0x00000000fed1ffff] reserved
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: BIOS-e820: [mem 0x00000000ff000000-0x00000000ffffffff] reserved
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: BIOS-e820: [mem 0x0000000100000000-0x000000085fffffff] usable
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: NX (Execute Disable) protection: active
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: random: fast init done
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: SMBIOS 2.8 present.
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: DMI: Dell Inc. Precision Tower 5810/0WR1RF, BIOS A07 04/14/2015
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: e820: remove [mem 0x000a0000-0x000fffff] usable
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: e820: last_pfn = 0x860000 max_arch_pfn = 0x400000000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: MTRR default type: write-back
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: MTRR fixed ranges enabled:
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel:   00000-9FFFF write-back
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel:   A0000-BFFFF uncachable
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel:   C0000-E3FFF write-through
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel:   E4000-FFFFF write-protect
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: MTRR variable ranges enabled:
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel:   0 base 0000C0000000 mask 3FFFC0000000 uncachable
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel:   1 base 0000A0000000 mask 3FFFE0000000 uncachable
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel:   2 base 030000000000 mask 3FC000000000 uncachable
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel:   3 base 00009E000000 mask 3FFFFE000000 uncachable
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel:   4 base 0000E0000000 mask 3FFFF0000000 write-through
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel:   5 disabled
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel:   6 disabled
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel:   7 disabled
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel:   8 disabled
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel:   9 disabled
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WP  UC- WT  
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: e820: last_pfn = 0x9d000 max_arch_pfn = 0x400000000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: found SMP MP-table at [mem 0x000fdb30-0x000fdb3f] mapped at [        (ptrval)]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: Scanning 1 areas for low memory corruption
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: Base memory trampoline at [        (ptrval)] 98000 size 24576
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: Using GB pages for direct mapping
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: BRK [0x515bd9000, 0x515bd9fff] PGTABLE
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: BRK [0x515bda000, 0x515bdafff] PGTABLE
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: BRK [0x515bdb000, 0x515bdbfff] PGTABLE
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: BRK [0x515bdc000, 0x515bdcfff] PGTABLE
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: BRK [0x515bdd000, 0x515bddfff] PGTABLE
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: BRK [0x515bde000, 0x515bdefff] PGTABLE
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: BRK [0x515bdf000, 0x515bdffff] PGTABLE
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: BRK [0x515be0000, 0x515be0fff] PGTABLE
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: RAMDISK: [mem 0x2eac0000-0x33557fff]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI: Early table checksum verification disabled
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI: RSDP 0x00000000000F0540 000024 (v02 DELL  )
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI: XSDT 0x000000009A2AC088 00008C (v01 DELL   CBX3     01072009 AMI  00010013)
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI: FACP 0x000000009A2D86E8 00010C (v05 DELL   CBX3     01072009 AMI  00010013)
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI: DSDT 0x000000009A2AC1A0 02C544 (v02 DELL   CBX3     01072009 INTL 20091013)
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI: FACS 0x000000009AF42F80 000040
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI: APIC 0x000000009A2D87F8 000090 (v03 DELL   CBX3     01072009 AMI  00010013)
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI: FPDT 0x000000009A2D8888 000044 (v01 DELL   CBX3     01072009 AMI  00010013)
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI: FIDT 0x000000009A2D88D0 00009C (v01 DELL   CBX3     01072009 AMI  00010013)
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI: MCFG 0x000000009A2D8970 00003C (v01 DELL   CBX3     01072009 MSFT 00000097)
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI: UEFI 0x000000009A2D89B0 000042 (v01 INTEL  EDK2     00000002      01000013)
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI: BDAT 0x000000009A2D89F8 000030 (v01 DELL   CBX3     00000000 INTL 20091013)
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI: HPET 0x000000009A2D8A28 000038 (v01 DELL   CBX3     00000001 INTL 20091013)
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI: PMCT 0x000000009A2D8A60 000064 (v01 DELL   CBX3     00000000 INTL 20091013)
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI: WDDT 0x000000009A2D8AC8 000040 (v01 DELL   CBX3     00000000 INTL 20091013)
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI: SSDT 0x000000009A2D8B08 00D647 (v01 DELL   PmMgt    00000001 INTL 20120913)
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI: DMAR 0x000000009A2E6150 0000F4 (v01 DELL   CBX3     00000001 INTL 20091013)
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI: ASF! 0x000000009A2E6248 0000A0 (v32 INTEL   HCG     00000001 TFSM 000F4240)
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI: Local APIC address 0xfee00000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: No NUMA configuration found
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: Faking a node at [mem 0x0000000000000000-0x000000085fffffff]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: NODE_DATA(0) allocated [mem 0x85ffd5000-0x85fffffff]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: tsc: Fast TSC calibration using PIT
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: Zone ranges:
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel:   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel:   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel:   Normal   [mem 0x0000000100000000-0x000000085fffffff]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel:   Device   empty
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: Movable zone start for each node
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: Early memory node ranges
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel:   node   0: [mem 0x0000000000001000-0x000000000009dfff]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel:   node   0: [mem 0x0000000000100000-0x00000000998f1fff]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel:   node   0: [mem 0x000000009b40b000-0x000000009b40bfff]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel:   node   0: [mem 0x000000009b41a000-0x000000009cffffff]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel:   node   0: [mem 0x0000000100000000-0x000000085fffffff]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: Initmem setup node 0 [mem 0x0000000000001000-0x000000085fffffff]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: On node 0 totalpages: 8369270
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel:   DMA zone: 64 pages used for memmap
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel:   DMA zone: 21 pages reserved
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel:   DMA zone: 3997 pages, LIFO batch:0
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel:   DMA32 zone: 9876 pages used for memmap
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel:   DMA32 zone: 632025 pages, LIFO batch:31
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel:   Normal zone: 120832 pages used for memmap
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel:   Normal zone: 7733248 pages, LIFO batch:31
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: Reserved but unavailable: 99 pages
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI: PM-Timer IO Port: 0x408
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI: Local APIC address 0xfee00000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI: LAPIC_NMI (acpi_id[0x02] high edge lint[0x1])
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI: LAPIC_NMI (acpi_id[0x04] high edge lint[0x1])
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI: LAPIC_NMI (acpi_id[0x06] high edge lint[0x1])
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: IOAPIC[0]: apic_id 8, version 32, address 0xfec00000, GSI 0-23
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: IOAPIC[1]: apic_id 9, version 32, address 0xfec01000, GSI 24-47
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI: IRQ0 used by override.
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI: IRQ9 used by override.
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: Using ACPI (MADT) for SMP configuration information
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI: HPET id: 0x8086a701 base: 0xfed00000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: smpboot: Allowing 4 CPUs, 0 hotplug CPUs
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: PM: Registered nosave memory: [mem 0x00000000-0x00000fff]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: PM: Registered nosave memory: [mem 0x0009e000-0x0009efff]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: PM: Registered nosave memory: [mem 0x0009f000-0x0009ffff]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: PM: Registered nosave memory: [mem 0x000a0000-0x000dffff]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: PM: Registered nosave memory: [mem 0x000e0000-0x000fffff]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: PM: Registered nosave memory: [mem 0x998f2000-0x9a29dfff]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: PM: Registered nosave memory: [mem 0x9a29e000-0x9a2e6fff]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: PM: Registered nosave memory: [mem 0x9a2e7000-0x9af43fff]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: PM: Registered nosave memory: [mem 0x9af44000-0x9b40afff]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: PM: Registered nosave memory: [mem 0x9b40c000-0x9b419fff]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: PM: Registered nosave memory: [mem 0x9d000000-0x9fffffff]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: PM: Registered nosave memory: [mem 0xa0000000-0xafffffff]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: PM: Registered nosave memory: [mem 0xb0000000-0xfed1bfff]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: PM: Registered nosave memory: [mem 0xfed1c000-0xfed1ffff]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: PM: Registered nosave memory: [mem 0xfed20000-0xfeffffff]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: PM: Registered nosave memory: [mem 0xff000000-0xffffffff]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: e820: [mem 0xb0000000-0xfed1bfff] available for PCI devices
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: Booting paravirtualized kernel on bare hardware
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 1910969940391419 ns
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: setup_percpu: NR_CPUS:8192 nr_cpumask_bits:4 nr_cpu_ids:4 nr_node_ids:1
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: percpu: Embedded 487 pages/cpu @        (ptrval) s1957888 r8192 d28672 u2097152
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pcpu-alloc: s1957888 r8192 d28672 u2097152 alloc=1*2097152
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pcpu-alloc: [0] 0 [0] 1 [0] 2 [0] 3 
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: Built 1 zonelists, mobility grouping on.  Total pages: 8238477
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: Policy zone: Normal
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: Kernel command line: BOOT_IMAGE=/vmlinuz-4.15.0-rc4+ root=/dev/mapper/luks-f5e2d09b-f8a3-487d-9517-abe4fb0eada3 ro rd.md.uuid=7f4fcca0:13b1445f:a91ff455:6bb1ab48 rd.luks.uuid=luks-cc6ee93c-e729-4f78-9baf-0cc5cc8a9ff1 rd.md.uuid=ef18531c:760102fb:7797cbdb:5cf9516f rd.md.uuid=42efe386:0c315f28:f7c61920:ea098f81 rd.luks.uuid=luks-f5e2d09b-f8a3-487d-9517-abe4fb0eada3 LANG=en_US.UTF-8
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: Memory: 32757384K/33477080K available (9920K kernel code, 3529K rwdata, 4124K rodata, 4724K init, 16632K bss, 719696K reserved, 0K cma-reserved)
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=4, Nodes=1
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ftrace: allocating 36227 entries in 142 pages
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: Running RCU self tests
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: Hierarchical RCU implementation.
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel:         RCU lockdep checking is enabled.
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel:         RCU restricting CPUs from NR_CPUS=8192 to nr_cpu_ids=4.
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel:         RCU callback double-/use-after-free debug enabled.
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel:         Tasks RCU enabled.
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: RCU: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=4
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: NR_IRQS: 524544, nr_irqs: 864, preallocated irqs: 16
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel:         Offload RCU callbacks from CPUs: .
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: Console: colour VGA+ 80x25
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: console [tty0] enabled
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ... MAX_LOCKDEP_SUBCLASSES:  8
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ... MAX_LOCK_DEPTH:          48
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ... MAX_LOCKDEP_KEYS:        8191
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ... CLASSHASH_SIZE:          4096
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ... MAX_LOCKDEP_ENTRIES:     32768
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ... MAX_LOCKDEP_CHAINS:      65536
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ... CHAINHASH_SIZE:          32768
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel:  memory used by lock dependency info: 7903 kB
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel:  per task-struct memory footprint: 2688 bytes
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: kmemleak: Kernel memory leak detector disabled
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI: Core revision 20170831
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI: 2 ACPI AML tables successfully acquired and loaded
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: clocksource: hpet: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 133484882848 ns
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: hpet clockevent registered
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: APIC: Switch to symmetric I/O mode setup
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: DMAR: Host address width 46
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: DMAR: DRHD base: 0x000000fbffd000 flags: 0x0
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: DMAR: dmar0: reg_base_addr fbffd000 ver 1:0 cap d2008c10ef0466 ecap f0205b
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: DMAR: DRHD base: 0x000000fbffc000 flags: 0x1
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: DMAR: dmar1: reg_base_addr fbffc000 ver 1:0 cap d2078c106f0466 ecap f020df
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: DMAR: RMRR base: 0x0000009b280000 end: 0x0000009b28efff
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: DMAR: ATSR flags: 0x0
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: DMAR: RHSA base: 0x000000fbffc000 proximity domain: 0x0
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: DMAR-IR: IOAPIC id 8 under DRHD base  0xfbffc000 IOMMU 1
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: DMAR-IR: IOAPIC id 9 under DRHD base  0xfbffc000 IOMMU 1
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: DMAR-IR: HPET id 0 under DRHD base 0xfbffc000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: DMAR-IR: x2apic is disabled because BIOS sets x2apic opt out bit.
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: DMAR-IR: Use 'intremap=no_x2apic_optout' to override the BIOS setting.
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: DMAR-IR: Enabled IRQ remapping in xapic mode
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: x2apic: IRQ remapping doesn't support X2APIC mode
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: tsc: Fast TSC calibration using PIT
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: tsc: Detected 2793.748 MHz processor
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: [Firmware Bug]: TSC ADJUST: CPU0: -67606545005758 force to 0
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: Calibrating delay loop (skipped), value calculated using timer frequency.. 5587.49 BogoMIPS (lpj=2793748)
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pid_max: default: 32768 minimum: 301
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: Security Framework initialized
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: Yama: becoming mindful.
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: SELinux:  Initializing.
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: SELinux:  Starting in permissive mode
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: Dentry cache hash table entries: 4194304 (order: 13, 33554432 bytes)
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: Inode-cache hash table entries: 2097152 (order: 12, 16777216 bytes)
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: Mount-cache hash table entries: 65536 (order: 7, 524288 bytes)
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: Mountpoint-cache hash table entries: 65536 (order: 7, 524288 bytes)
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: CPU: Physical Processor ID: 0
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: CPU: Processor Core ID: 0
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: mce: CPU supports 22 MCE banks
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: CPU0: Thermal monitoring enabled (TM1)
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: process: using mwait in idle threads
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: Last level iTLB entries: 4KB 1024, 2MB 1024, 4MB 1024
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: Last level dTLB entries: 4KB 1024, 2MB 1024, 4MB 1024, 1GB 4
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: Freeing SMP alternatives memory: 28K
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: TSC deadline timer enabled
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: smpboot: CPU0: Intel(R) Xeon(R) CPU E5-1603 v3 @ 2.80GHz (family: 0x6, model: 0x3f, stepping: 0x2)
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: Performance Events: PEBS fmt2+, Haswell events, 16-deep LBR, full-width counters, Intel PMU driver.
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ... version:                3
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ... bit width:              48
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ... generic registers:      8
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ... value mask:             0000ffffffffffff
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ... max period:             00007fffffffffff
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ... fixed-purpose events:   3
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ... event mask:             00000007000000ff
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: Hierarchical SRCU implementation.
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: NMI watchdog: Enabled. Permanently consumes one hw-PMU counter.
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: smp: Bringing up secondary CPUs ...
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: x86: Booting SMP configuration:
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: .... node  #0, CPUs:      #1
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: [Firmware Bug]: TSC ADJUST differs within socket(s), fixing all errors
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel:  #2 #3
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: smp: Brought up 1 node, 4 CPUs
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: smpboot: Max logical packages: 1
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: smpboot: Total of 4 processors activated (22349.98 BogoMIPS)
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: devtmpfs: initialized
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: x86/mm: Memory block size: 128MB
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: PM: Registering ACPI NVS region [mem 0x9a2e7000-0x9af43fff] (12963840 bytes)
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 1911260446275000 ns
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: futex hash table entries: 1024 (order: 5, 131072 bytes)
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pinctrl core: initialized pinctrl subsystem
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: RTC time: 22:35:03, date: 12/19/17
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: NET: Registered protocol family 16
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: audit: initializing netlink subsys (disabled)
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: audit: type=2000 audit(1513722903.054:1): state=initialized audit_enabled=0 res=1
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: cpuidle: using governor menu
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI FADT declares the system doesn't support PCIe ASPM, so disable it
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI: bus type PCI registered
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0xa0000000-0xafffffff] (base 0xa0000000)
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: PCI: MMCONFIG at [mem 0xa0000000-0xafffffff] reserved in E820
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: PCI: Using configuration type 1 for base access
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: core: PMU erratum BJ122, BV98, HSD29 workaround disabled, HT off
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: HugeTLB registered 1.00 GiB page size, pre-allocated 0 pages
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: HugeTLB registered 2.00 MiB page size, pre-allocated 0 pages
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI: Added _OSI(Module Device)
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI: Added _OSI(Processor Device)
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI: Added _OSI(3.0 _SCP Extensions)
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI: Added _OSI(Processor Aggregator Device)
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI: [Firmware Bug]: BIOS _OSI(Linux) query ignored
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI: Interpreter enabled
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI: (supports S0 S4 S5)
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI: Using IOAPIC for interrupt routing
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI: Enabled 5 GPEs in block 00 to 3F
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI: PCI Root Bridge [UNC0] (domain 0000 [bus ff])
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: acpi PNP0A03:03: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: acpi PNP0A03:03: _OSC: OS now controls [PCIeHotplug PME AER PCIeCapability]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: acpi PNP0A03:03: FADT indicates ASPM is unsupported, using BIOS configuration
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: PCI host bridge to bus 0000:ff
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci_bus 0000:ff: root bus resource [bus ff]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:0b.0: [8086:2f81] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:0b.1: [8086:2f36] type 00 class 0x110100
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:0b.2: [8086:2f37] type 00 class 0x110100
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:0c.0: [8086:2fe0] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:0c.1: [8086:2fe1] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:0c.2: [8086:2fe2] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:0c.3: [8086:2fe3] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:0f.0: [8086:2ff8] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:0f.1: [8086:2ff9] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:0f.4: [8086:2ffc] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:0f.5: [8086:2ffd] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:0f.6: [8086:2ffe] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:10.0: [8086:2f1d] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:10.1: [8086:2f34] type 00 class 0x110100
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:10.5: [8086:2f1e] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:10.6: [8086:2f7d] type 00 class 0x110100
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:10.7: [8086:2f1f] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:12.0: [8086:2fa0] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:12.1: [8086:2f30] type 00 class 0x110100
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:13.0: [8086:2fa8] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:13.1: [8086:2f71] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:13.2: [8086:2faa] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:13.3: [8086:2fab] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:13.4: [8086:2fac] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:13.5: [8086:2fad] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:13.6: [8086:2fae] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:13.7: [8086:2faf] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:14.0: [8086:2fb0] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:14.1: [8086:2fb1] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:14.2: [8086:2fb2] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:14.3: [8086:2fb3] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:14.6: [8086:2fbe] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:14.7: [8086:2fbf] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:15.0: [8086:2fb4] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:15.1: [8086:2fb5] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:15.2: [8086:2fb6] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:15.3: [8086:2fb7] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:16.0: [8086:2f68] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:16.6: [8086:2f6e] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:16.7: [8086:2f6f] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:17.0: [8086:2fd0] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:17.4: [8086:2fb8] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:17.5: [8086:2fb9] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:17.6: [8086:2fba] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:17.7: [8086:2fbb] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:1e.0: [8086:2f98] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:1e.1: [8086:2f99] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:1e.2: [8086:2f9a] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:1e.3: [8086:2fc0] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:1e.4: [8086:2f9c] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:1f.0: [8086:2f88] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:ff:1f.2: [8086:2f8a] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-fe])
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: acpi PNP0A08:00: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: acpi PNP0A08:00: _OSC: platform does not support [PCIeHotplug PME AER PCIeCapability]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: acpi PNP0A08:00: _OSC: not requesting control; platform does not support [PCIeCapability]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: acpi PNP0A08:00: _OSC: OS requested [PCIeHotplug PME AER PCIeCapability]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: acpi PNP0A08:00: _OSC: platform willing to grant []
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: acpi PNP0A08:00: _OSC failed (AE_SUPPORT); disabling ASPM
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: PCI host bridge to bus 0000:00
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci_bus 0000:00: root bus resource [io  0x0000-0x03af window]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci_bus 0000:00: root bus resource [io  0x03e0-0x0cf7 window]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci_bus 0000:00: root bus resource [io  0x03b0-0x03df window]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci_bus 0000:00: root bus resource [io  0x1000-0xffff window]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff window]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci_bus 0000:00: root bus resource [mem 0xb0000000-0xfbffbfff window]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci_bus 0000:00: root bus resource [mem 0x30000000000-0x33fffffffff window]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci_bus 0000:00: root bus resource [bus 00-fe]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:00.0: [8086:2f00] type 00 class 0x060000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:01.0: [8086:2f02] type 01 class 0x060400
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:01.1: [8086:2f03] type 01 class 0x060400
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:01.1: PME# supported from D0 D3hot D3cold
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:02.0: [8086:2f04] type 01 class 0x060400
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:02.0: PME# supported from D0 D3hot D3cold
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:03.0: [8086:2f08] type 01 class 0x060400
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:03.0: PME# supported from D0 D3hot D3cold
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:03.1: [8086:2f09] type 01 class 0x060400
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:03.1: PME# supported from D0 D3hot D3cold
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:03.2: [8086:2f0a] type 01 class 0x060400
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:03.2: PME# supported from D0 D3hot D3cold
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:03.3: [8086:2f0b] type 01 class 0x060400
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:03.3: PME# supported from D0 D3hot D3cold
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:05.0: [8086:2f28] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:05.1: [8086:2f29] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:05.2: [8086:2f2a] type 00 class 0x088000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:05.4: [8086:2f2c] type 00 class 0x080020
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:05.4: reg 0x10: [mem 0xfbf36000-0xfbf36fff]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:11.0: [8086:8d7c] type 00 class 0xff0000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:11.4: [8086:8d62] type 00 class 0x010601
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:11.4: reg 0x10: [io  0xf130-0xf137]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:11.4: reg 0x14: [io  0xf120-0xf123]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:11.4: reg 0x18: [io  0xf110-0xf117]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:11.4: reg 0x1c: [io  0xf100-0xf103]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:11.4: reg 0x20: [io  0xf040-0xf05f]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:11.4: reg 0x24: [mem 0xfbf35000-0xfbf357ff]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:11.4: PME# supported from D3hot
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:14.0: [8086:8d31] type 00 class 0x0c0330
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:14.0: reg 0x10: [mem 0xfbf20000-0xfbf2ffff 64bit]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:14.0: PME# supported from D3hot D3cold
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:16.0: [8086:8d3a] type 00 class 0x078000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:16.0: reg 0x10: [mem 0x33ffff07000-0x33ffff0700f 64bit]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:16.0: PME# supported from D0 D3hot D3cold
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:19.0: [8086:153a] type 00 class 0x020000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:19.0: reg 0x10: [mem 0xfbf00000-0xfbf1ffff]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:19.0: reg 0x14: [mem 0xfbf33000-0xfbf33fff]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:19.0: reg 0x18: [io  0xf020-0xf03f]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:19.0: PME# supported from D0 D3hot D3cold
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:1a.0: [8086:8d2d] type 00 class 0x0c0320
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:1a.0: reg 0x10: [mem 0xfbf32000-0xfbf323ff]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:1a.0: PME# supported from D0 D3hot D3cold
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:1b.0: [8086:8d20] type 00 class 0x040300
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:1b.0: reg 0x10: [mem 0x33ffff00000-0x33ffff03fff 64bit]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:1c.0: [8086:8d10] type 01 class 0x060400
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:1c.1: [8086:8d12] type 01 class 0x060400
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:1c.1: PME# supported from D0 D3hot D3cold
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:1d.0: [8086:8d26] type 00 class 0x0c0320
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:1d.0: reg 0x10: [mem 0xfbf31000-0xfbf313ff]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:1d.0: PME# supported from D0 D3hot D3cold
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:1f.0: [8086:8d44] type 00 class 0x060100
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:1f.2: [8086:8d02] type 00 class 0x010601
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:1f.2: reg 0x10: [io  0xf090-0xf097]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:1f.2: reg 0x14: [io  0xf080-0xf083]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:1f.2: reg 0x18: [io  0xf070-0xf077]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:1f.2: reg 0x1c: [io  0xf060-0xf063]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:1f.2: reg 0x20: [io  0xf000-0xf01f]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:1f.2: reg 0x24: [mem 0xfbf30000-0xfbf307ff]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:1f.2: PME# supported from D3hot
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:1f.3: [8086:8d22] type 00 class 0x0c0500
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:1f.3: reg 0x10: [mem 0x33ffff05000-0x33ffff050ff 64bit]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:1f.3: reg 0x20: [io  0x0580-0x059f]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:01.0: PCI bridge to [bus 01]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:01.1: PCI bridge to [bus 02]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:03:00.0: [1002:6608] type 00 class 0x030000
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:03:00.0: reg 0x10: [mem 0xe0000000-0xefffffff 64bit pref]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:03:00.0: reg 0x18: [mem 0xfbe00000-0xfbe3ffff 64bit]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:03:00.0: reg 0x20: [io  0xe000-0xe0ff]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:03:00.0: reg 0x30: [mem 0xfbe40000-0xfbe5ffff pref]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:03:00.0: enabling Extended Tags
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:03:00.0: supports D1 D2
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:03:00.0: PME# supported from D1 D2 D3hot
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:03:00.1: [1002:aab0] type 00 class 0x040300
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:03:00.1: reg 0x10: [mem 0xfbe60000-0xfbe63fff 64bit]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:03:00.1: enabling Extended Tags
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:03:00.1: supports D1 D2
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:02.0: PCI bridge to [bus 03]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:02.0:   bridge window [io  0xe000-0xefff]
Dec 19 16:35:05 cerberus.csd.uwm.edu kernel: pci 0000:00:02.0:   bridge window [mem 0xfbe00000-0xfbefffff]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci 0000:00:02.0:   bridge window [mem 0xe0000000-0xefffffff 64bit pref]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci 0000:00:03.0: PCI bridge to [bus 04]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci 0000:00:03.1: PCI bridge to [bus 05]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci 0000:00:03.2: PCI bridge to [bus 06]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci 0000:00:03.3: PCI bridge to [bus 07]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci 0000:00:1c.0: PCI bridge to [bus 08]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci 0000:09:00.0: [104c:8240] type 01 class 0x060400
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci 0000:09:00.0: supports D1 D2
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci 0000:00:1c.1: PCI bridge to [bus 09-0a]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci 0000:09:00.0: PCI bridge to [bus 0a]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci_bus 0000:00: on NUMA node 0
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 10 *11 12 14 15)
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 *10 11 12 14 15)
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 10 *11 12 14 15)
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 *5 6 10 11 12 14 15)
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ACPI: PCI Interrupt Link [LNKE] (IRQs *3 4 5 6 7 10 11 12 14 15)
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 *7 10 11 12 14 15)
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci 0000:03:00.0: vgaarb: setting as boot VGA device
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci 0000:03:00.0: vgaarb: VGA device added: decodes=io+mem,owns=io+mem,locks=none
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci 0000:03:00.0: vgaarb: bridge control possible
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: vgaarb: loaded
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: SCSI subsystem initialized
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: libata version 3.00 loaded.
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ACPI: bus type USB registered
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usbcore: registered new interface driver usbfs
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usbcore: registered new interface driver hub
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usbcore: registered new device driver usb
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: EDAC MC: Ver: 3.0.0
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: PCI: Using ACPI for IRQ routing
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: PCI: pci_cache_line_size set to 64 bytes
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: e820: reserve RAM buffer [mem 0x0009e800-0x0009ffff]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: e820: reserve RAM buffer [mem 0x998f2000-0x9bffffff]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: e820: reserve RAM buffer [mem 0x9b40c000-0x9bffffff]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: e820: reserve RAM buffer [mem 0x9d000000-0x9fffffff]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: NetLabel: Initializing
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: NetLabel:  domain hash size = 128
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: NetLabel:  protocols = UNLABELED CIPSOv4 CALIPSO
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: NetLabel:  unlabeled traffic allowed by default
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0, 0, 0, 0, 0
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: hpet0: 8 comparators, 64-bit 14.318180 MHz counter
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: clocksource: Switched to clocksource hpet
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: VFS: Disk quotas dquot_6.6.0
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: VFS: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pnp: PnP ACPI init
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: system 00:01: [io  0x0500-0x057f] has been reserved
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: system 00:01: [io  0x0400-0x047f] has been reserved
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: system 00:01: [io  0x0580-0x059f] has been reserved
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: system 00:01: [io  0x0600-0x061f] has been reserved
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: system 00:01: [io  0x0880-0x0883] has been reserved
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: system 00:01: [io  0x0800-0x081f] has been reserved
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: system 00:01: [mem 0xfed1c000-0xfed3ffff] could not be reserved
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: system 00:01: [mem 0xfed45000-0xfed8bfff] has been reserved
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: system 00:01: [mem 0xff000000-0xffffffff] has been reserved
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: system 00:01: [mem 0xfee00000-0xfeefffff] has been reserved
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: system 00:01: [mem 0xfed12000-0xfed1200f] has been reserved
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: system 00:01: [mem 0xfed12010-0xfed1201f] has been reserved
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: system 00:01: [mem 0xfed1b000-0xfed1bfff] has been reserved
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: system 00:01: Plug and Play ACPI device, IDs PNP0c02 (active)
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: system 00:02: [io  0x0a00-0x0a3f] has been reserved
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: system 00:02: Plug and Play ACPI device, IDs PNP0c02 (active)
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pnp 00:03: [dma 0 disabled]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pnp 00:03: Plug and Play ACPI device, IDs PNP0501 (active)
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pnp: PnP ACPI: found 4 devices
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, max_idle_ns: 2085701024 ns
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci 0000:00:1c.0: bridge window [io  0x1000-0x0fff] to [bus 08] add_size 1000
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci 0000:00:1c.0: bridge window [mem 0x00100000-0x000fffff 64bit pref] to [bus 08] add_size 200000 add_align 100000
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci 0000:00:1c.0: bridge window [mem 0x00100000-0x000fffff] to [bus 08] add_size 200000 add_align 100000
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci 0000:00:1c.0: BAR 14: assigned [mem 0xb0000000-0xb01fffff]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci 0000:00:1c.0: BAR 15: assigned [mem 0x30000000000-0x300001fffff 64bit pref]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci 0000:00:1c.0: BAR 13: assigned [io  0x1000-0x1fff]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci 0000:00:01.0: PCI bridge to [bus 01]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci 0000:00:01.1: PCI bridge to [bus 02]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci 0000:00:02.0: PCI bridge to [bus 03]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci 0000:00:02.0:   bridge window [io  0xe000-0xefff]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci 0000:00:02.0:   bridge window [mem 0xfbe00000-0xfbefffff]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci 0000:00:02.0:   bridge window [mem 0xe0000000-0xefffffff 64bit pref]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci 0000:00:03.0: PCI bridge to [bus 04]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci 0000:00:03.1: PCI bridge to [bus 05]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci 0000:00:03.2: PCI bridge to [bus 06]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci 0000:00:03.3: PCI bridge to [bus 07]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci 0000:00:1c.0: PCI bridge to [bus 08]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci 0000:00:1c.0:   bridge window [io  0x1000-0x1fff]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci 0000:00:1c.0:   bridge window [mem 0xb0000000-0xb01fffff]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci 0000:00:1c.0:   bridge window [mem 0x30000000000-0x300001fffff 64bit pref]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci 0000:09:00.0: PCI bridge to [bus 0a]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci 0000:00:1c.1: PCI bridge to [bus 09-0a]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci_bus 0000:00: resource 4 [io  0x0000-0x03af window]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci_bus 0000:00: resource 5 [io  0x03e0-0x0cf7 window]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci_bus 0000:00: resource 6 [io  0x03b0-0x03df window]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci_bus 0000:00: resource 7 [io  0x1000-0xffff window]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci_bus 0000:00: resource 8 [mem 0x000a0000-0x000bffff window]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci_bus 0000:00: resource 9 [mem 0xb0000000-0xfbffbfff window]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci_bus 0000:00: resource 10 [mem 0x30000000000-0x33fffffffff window]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci_bus 0000:03: resource 0 [io  0xe000-0xefff]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci_bus 0000:03: resource 1 [mem 0xfbe00000-0xfbefffff]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci_bus 0000:03: resource 2 [mem 0xe0000000-0xefffffff 64bit pref]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci_bus 0000:08: resource 0 [io  0x1000-0x1fff]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci_bus 0000:08: resource 1 [mem 0xb0000000-0xb01fffff]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci_bus 0000:08: resource 2 [mem 0x30000000000-0x300001fffff 64bit pref]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: NET: Registered protocol family 2
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: TCP established hash table entries: 262144 (order: 9, 2097152 bytes)
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: TCP bind hash table entries: 65536 (order: 10, 5242880 bytes)
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: TCP: Hash tables configured (established 262144 bind 65536)
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: UDP hash table entries: 16384 (order: 9, 3145728 bytes)
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: UDP-Lite hash table entries: 16384 (order: 9, 3145728 bytes)
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: NET: Registered protocol family 1
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: pci 0000:03:00.0: Video device with shadowed ROM at [mem 0x000c0000-0x000dffff]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: PCI: CLS 32 bytes, default 64
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: Unpacking initramfs...
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: Freeing initrd memory: 76384K
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: DMA-API: preallocated 65536 debug entries
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: DMA-API: debugging enabled by kernel config
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: software IO TLB [mem 0x958f2000-0x998f2000] (64MB) mapped at [00000000312df4b0-000000008bb8e263]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: Scanning for low memory corruption every 60 seconds
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: cryptomgr_test (53) used greatest stack depth: 14824 bytes left
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: Initialise system trusted keyrings
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: Key type blacklist registered
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: workingset: timestamp_bits=36 max_order=23 bucket_order=0
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: zbud: loaded
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: SELinux:  Registering netfilter hooks
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: cryptomgr_test (55) used greatest stack depth: 13960 bytes left
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: cryptomgr_test (56) used greatest stack depth: 13832 bytes left
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: cryptomgr_test (75) used greatest stack depth: 13752 bytes left
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: cryptomgr_test (70) used greatest stack depth: 13600 bytes left
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: NET: Registered protocol family 38
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: Key type asymmetric registered
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: Asymmetric key parser 'x509' registered
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: Block layer SCSI generic (bsg) driver version 0.4 loaded (major 247)
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: io scheduler noop registered
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: io scheduler deadline registered
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: io scheduler cfq registered (default)
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: io scheduler mq-deadline registered
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: atomic64_test: passed for x86-64 platform with CX8 and with SSE
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: intel_idle: MWAIT substates: 0x2120
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: intel_idle: v0.4.1 model 0x3F
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: intel_idle: lapic_timer_reliable_states 0xffffffff
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: input: Power Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0C:00/input/input0
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ACPI: Power Button [PWRB]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ACPI: Power Button [PWRF]
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: Serial: 8250/16550 driver, 32 ports, IRQ sharing enabled
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: 00:03: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: Non-volatile memory driver v1.3
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: Linux agpgart interface v0.103
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: lkdtm: No crash points registered, enable through debugfs
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ahci 0000:00:11.4: version 3.0
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ahci 0000:00:11.4: AHCI 0001.0300 32 slots 4 ports 6 Gbps 0x1 impl SATA mode
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ahci 0000:00:11.4: flags: 64bit ncq pm led clo pio slum part ems apst 
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: scsi host0: ahci
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: scsi host1: ahci
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: scsi host2: ahci
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: scsi host3: ahci
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ata1: SATA max UDMA/133 abar m2048@0xfbf35000 port 0xfbf35100 irq 27
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ata2: DUMMY
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ata3: DUMMY
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ata4: DUMMY
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ahci 0000:00:1f.2: AHCI 0001.0300 32 slots 4 ports 6 Gbps 0x3 impl SATA mode
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ahci 0000:00:1f.2: flags: 64bit ncq pm led clo pio slum part ems apst 
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: scsi host4: ahci
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: scsi host5: ahci
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: scsi host6: ahci
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: scsi host7: ahci
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ata5: SATA max UDMA/133 abar m2048@0xfbf30000 port 0xfbf30100 irq 28
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ata6: SATA max UDMA/133 abar m2048@0xfbf30000 port 0xfbf30180 irq 28
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ata7: DUMMY
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ata8: DUMMY
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: libphy: Fixed MDIO Bus: probed
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ehci-pci: EHCI PCI platform driver
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ehci-pci 0000:00:1a.0: EHCI Host Controller
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ehci-pci 0000:00:1a.0: new USB bus registered, assigned bus number 1
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ehci-pci 0000:00:1a.0: debug port 2
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ehci-pci 0000:00:1a.0: cache line size of 32 is not supported
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ehci-pci 0000:00:1a.0: irq 18, io mem 0xfbf32000
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ehci-pci 0000:00:1a.0: USB 2.0 started, EHCI 1.00
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb usb1: Product: EHCI Host Controller
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb usb1: Manufacturer: Linux 4.15.0-rc4+ ehci_hcd
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb usb1: SerialNumber: 0000:00:1a.0
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: hub 1-0:1.0: USB hub found
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: hub 1-0:1.0: 2 ports detected
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ehci-pci 0000:00:1d.0: EHCI Host Controller
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ehci-pci 0000:00:1d.0: new USB bus registered, assigned bus number 2
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ehci-pci 0000:00:1d.0: debug port 2
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ehci-pci 0000:00:1d.0: cache line size of 32 is not supported
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ehci-pci 0000:00:1d.0: irq 18, io mem 0xfbf31000
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ehci-pci 0000:00:1d.0: USB 2.0 started, EHCI 1.00
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb usb2: New USB device found, idVendor=1d6b, idProduct=0002
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb usb2: Product: EHCI Host Controller
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb usb2: Manufacturer: Linux 4.15.0-rc4+ ehci_hcd
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb usb2: SerialNumber: 0000:00:1d.0
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: hub 2-0:1.0: USB hub found
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: hub 2-0:1.0: 2 ports detected
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ohci-pci: OHCI PCI platform driver
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: uhci_hcd: USB Universal Host Controller Interface driver
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: xhci_hcd 0000:00:14.0: xHCI Host Controller
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: xhci_hcd 0000:00:14.0: new USB bus registered, assigned bus number 3
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: xhci_hcd 0000:00:14.0: hcc params 0x200077c1 hci version 0x100 quirks 0x00009810
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: xhci_hcd 0000:00:14.0: cache line size of 32 is not supported
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb usb3: New USB device found, idVendor=1d6b, idProduct=0002
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb usb3: Product: xHCI Host Controller
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb usb3: Manufacturer: Linux 4.15.0-rc4+ xhci-hcd
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb usb3: SerialNumber: 0000:00:14.0
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: hub 3-0:1.0: USB hub found
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: hub 3-0:1.0: 15 ports detected
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: xhci_hcd 0000:00:14.0: xHCI Host Controller
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: xhci_hcd 0000:00:14.0: new USB bus registered, assigned bus number 4
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb usb4: New USB device found, idVendor=1d6b, idProduct=0003
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb usb4: Product: xHCI Host Controller
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb usb4: Manufacturer: Linux 4.15.0-rc4+ xhci-hcd
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb usb4: SerialNumber: 0000:00:14.0
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: hub 4-0:1.0: USB hub found
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: hub 4-0:1.0: 6 ports detected
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usbcore: registered new interface driver usbserial_generic
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usbserial: USB Serial support registered for generic
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: i8042: PNP: No PS/2 controller found.
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: mousedev: PS/2 mouse device common for all mice
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: rtc_cmos 00:00: RTC can wake from S4
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: rtc_cmos 00:00: rtc core: registered rtc_cmos as rtc0
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: rtc_cmos 00:00: alarms up to one month, y3k, 114 bytes nvram, hpet irqs
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: device-mapper: uevent: version 1.0.3
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: device-mapper: ioctl: 4.37.0-ioctl (2017-09-20) initialised: dm-devel@redhat.com
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: intel_pstate: Intel P-state driver initializing
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: hidraw: raw HID events driver (C) Jiri Kosina
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usbcore: registered new interface driver usbhid
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usbhid: USB HID core driver
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: drop_monitor: Initializing network drop monitor service
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ip_tables: (C) 2000-2006 Netfilter Core Team
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: Initializing XFRM netlink socket
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: NET: Registered protocol family 10
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: Segment Routing with IPv6
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: mip6: Mobile IPv6
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: NET: Registered protocol family 17
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: start plist test
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: end plist test
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: intel_rdt: Intel RDT L3 monitoring detected
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: RAS: Correctable Errors collector initialized.
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: microcode: sig=0x306f2, pf=0x1, revision=0x3a
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: microcode: Microcode Update Driver: v2.2.
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: AVX2 version of gcm_enc/dec engaged.
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: AES CTR mode by8 optimization enabled
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: sched_clock: Marking stable (2178689381, 0)->(2187141432, -8452051)
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: registered taskstats version 1
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: Loading compiled-in X.509 certificates
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: Loaded X.509 cert 'Build time autogenerated kernel key: a0edb3ecf58ff4072b22990fa0a188a3a906b7a7'
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: zswap: loaded using pool lzo/zbud
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: Key type big_key registered
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: Key type encrypted registered
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel:   Magic number: 13:828:603
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: acpi device:173: hash matches
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: rtc_cmos 00:00: setting system clock to 2017-12-19 22:35:05 UTC (1513722905)
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ata1: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ata1.00: ATAPI: HL-DT-ST DVD+/-RW GTA0N, A1B0, max UDMA/100
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ata1.00: configured for UDMA/100
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ata6: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ata5: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ata5.00: ATA-9: ST2000DM001-1ER164, CC25, max UDMA/133
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ata5.00: 3907029168 sectors, multi 16: LBA48 NCQ (depth 31/32), AA
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ata5.00: configured for UDMA/133
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: scsi 0:0:0:0: CD-ROM            HL-DT-ST DVD+-RW GTA0N    A1B0 PQ: 0 ANSI: 5
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ata6.00: ATA-9: ST2000DM001-1ER164, CC25, max UDMA/133
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ata6.00: 3907029168 sectors, multi 16: LBA48 NCQ (depth 31/32), AA
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: ata6.00: configured for UDMA/133
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb 1-1: new high-speed USB device number 2 using ehci-pci
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: sr 0:0:0:0: [sr0] scsi3-mmc drive: 24x/24x writer dvd-ram cd/rw xa/form2 cdda tray
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: cdrom: Uniform CD-ROM driver Revision: 3.20
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: sr 0:0:0:0: Attached scsi CD-ROM sr0
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: sr 0:0:0:0: Attached scsi generic sg0 type 5
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: scsi 4:0:0:0: Direct-Access     ATA      ST2000DM001-1ER1 CC25 PQ: 0 ANSI: 5
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: sd 4:0:0:0: Attached scsi generic sg1 type 0
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: sd 4:0:0:0: [sda] 3907029168 512-byte logical blocks: (2.00 TB/1.82 TiB)
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: sd 4:0:0:0: [sda] 4096-byte physical blocks
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: sd 4:0:0:0: [sda] Write Protect is off
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: scsi 5:0:0:0: Direct-Access     ATA      ST2000DM001-1ER1 CC25 PQ: 0 ANSI: 5
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: sd 4:0:0:0: [sda] Mode Sense: 00 3a 00 00
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: sd 4:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: sd 5:0:0:0: Attached scsi generic sg2 type 0
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: sd 5:0:0:0: [sdb] 3907029168 512-byte logical blocks: (2.00 TB/1.82 TiB)
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: sd 5:0:0:0: [sdb] 4096-byte physical blocks
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: sd 5:0:0:0: [sdb] Write Protect is off
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: sd 5:0:0:0: [sdb] Mode Sense: 00 3a 00 00
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: sd 5:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb 2-1: new high-speed USB device number 2 using ehci-pci
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb 3-6: new low-speed USB device number 2 using xhci_hcd
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel:  sda: sda1 sda2 sda3 sda4 < sda5 >
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: sd 4:0:0:0: [sda] Attached SCSI disk
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel:  sdb: sdb1 sdb2 sdb3 sdb4 < sdb5 >
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: sd 5:0:0:0: [sdb] Attached SCSI disk
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: Freeing unused kernel memory: 4724K
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: Write protecting the kernel read-only data: 16384k
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: Freeing unused kernel memory: 308K
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: Freeing unused kernel memory: 2020K
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: x86/mm: Checked W+X mappings: passed, no W+X pages found.
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: rodata_test: all tests were successful
Dec 19 16:35:06 cerberus.csd.uwm.edu systemd[1]: systemd 236 running in system mode. (+PAM +AUDIT +SELINUX +IMA -APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT +GNUTLS +ACL +XZ +LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD +IDN2 -IDN default-hierarchy=hybrid)
Dec 19 16:35:06 cerberus.csd.uwm.edu systemd[1]: Detected architecture x86-64.
Dec 19 16:35:06 cerberus.csd.uwm.edu systemd[1]: Running in initial RAM disk.
Dec 19 16:35:06 cerberus.csd.uwm.edu systemd[1]: Set hostname to <cerberus.csd.uwm.edu>.
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb 1-1: New USB device found, idVendor=8087, idProduct=800a
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb 1-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: hub 1-1:1.0: USB hub found
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: hub 1-1:1.0: 6 ports detected
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb 2-1: New USB device found, idVendor=8087, idProduct=8002
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb 2-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: hub 2-1:1.0: USB hub found
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: hub 2-1:1.0: 8 ports detected
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb 3-6: New USB device found, idVendor=413c, idProduct=2107
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb 3-6: New USB device strings: Mfr=1, Product=2, SerialNumber=0
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb 3-6: Product: Dell USB Entry Keyboard
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb 3-6: Manufacturer: Dell
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: input: Dell Dell USB Entry Keyboard as /devices/pci0000:00/0000:00:14.0/usb3/3-6/3-6:1.0/0003:413C:2107.0001/input/input2
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: dracut-rootfs-g (191) used greatest stack depth: 13416 bytes left
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: hid-generic 0003:413C:2107.0001: input,hidraw0: USB HID v1.10 Keyboard [Dell Dell USB Entry Keyboard] on usb-0000:00:14.0-6/input0
Dec 19 16:35:06 cerberus.csd.uwm.edu systemd[1]: Reached target Swap.
Dec 19 16:35:06 cerberus.csd.uwm.edu systemd[1]: Reached target Local File Systems.
Dec 19 16:35:06 cerberus.csd.uwm.edu systemd[1]: Created slice System Slice.
Dec 19 16:35:06 cerberus.csd.uwm.edu systemd[1]: Listening on Journal Socket.
Dec 19 16:35:06 cerberus.csd.uwm.edu systemd[1]: Listening on udev Control Socket.
Dec 19 16:35:06 cerberus.csd.uwm.edu systemd[1]: Listening on udev Kernel Socket.
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: audit: type=1130 audit(1513722905.946:2): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-tmpfiles-setup comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: audit: type=1130 audit(1513722905.955:3): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-tmpfiles-setup-dev comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: systemd-modules (221) used greatest stack depth: 13384 bytes left
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb 3-7: new low-speed USB device number 3 using xhci_hcd
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: audit: type=1130 audit(1513722905.997:4): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-modules-load comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=failed'
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: audit: type=1130 audit(1513722906.011:5): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-sysctl comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: audit: type=1130 audit(1513722906.059:6): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-vconsole-setup comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: audit: type=1131 audit(1513722906.059:7): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-vconsole-setup comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: audit: type=1130 audit(1513722906.062:8): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-journald comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: tsc: Refined TSC clocksource calibration: 2793.530 MHz
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x284460f1a18, max_idle_ns: 440795261562 ns
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb 3-7: New USB device found, idVendor=046d, idProduct=c077
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb 3-7: New USB device strings: Mfr=1, Product=2, SerialNumber=0
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb 3-7: Product: USB Optical Mouse
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb 3-7: Manufacturer: Logitech
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: input: Logitech USB Optical Mouse as /devices/pci0000:00/0000:00:14.0/usb3/3-7/3-7:1.0/0003:046D:C077.0002/input/input3
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: hid-generic 0003:046D:C077.0002: input,hidraw1: USB HID v1.11 Mouse [Logitech USB Optical Mouse] on usb-0000:00:14.0-7/input0
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: audit: type=1130 audit(1513722906.235:9): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=dracut-cmdline comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb 3-8: new low-speed USB device number 4 using xhci_hcd
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: audit: type=1130 audit(1513722906.326:10): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=dracut-pre-udev comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb 3-8: New USB device found, idVendor=051d, idProduct=0002
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb 3-8: New USB device strings: Mfr=3, Product=1, SerialNumber=2
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb 3-8: Product: Back-UPS ES 550G FW:843.K4 .D USB FW:K4 
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb 3-8: Manufacturer: APC
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb 3-8: SerialNumber: 4B1210P35391  
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: hid-generic 0003:051D:0002.0003: hiddev96,hidraw2: USB HID v1.10 Device [APC Back-UPS ES 550G FW:843.K4 .D USB FW:K4 ] on usb-0000:00:14.0-8/input0
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb 3-11: new high-speed USB device number 5 using xhci_hcd
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb 3-11: New USB device found, idVendor=0424, idProduct=2514
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: usb 3-11: New USB device strings: Mfr=0, Product=0, SerialNumber=0
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: hub 3-11:1.0: USB hub found
Dec 19 16:35:06 cerberus.csd.uwm.edu kernel: hub 3-11:1.0: 4 ports detected
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: usb 3-11.1: new full-speed USB device number 6 using xhci_hcd
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: clocksource: Switched to clocksource tsc
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: pps_core: LinuxPPS API ver. 1 registered
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: PTP clock support registered
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: e1000e: Intel(R) PRO/1000 Network Driver - 3.2.6-k
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: e1000e: Copyright(c) 1999 - 2015 Intel Corporation.
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: e1000e 0000:00:19.0: Interrupt Throttling Rate (ints/sec) set to dynamic conservative mode
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: ata_id (487) used greatest stack depth: 13072 bytes left
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: usb 3-11.1: New USB device found, idVendor=413c, idProduct=a503
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: usb 3-11.1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: usb 3-11.1: Product: Dell AC511 USB SoundBar
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: usb 3-11.1: Manufacturer: Dell
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: input: Dell Dell AC511 USB SoundBar as /devices/pci0000:00/0000:00:14.0/usb3/3-11/3-11.1/3-11.1:1.3/0003:413C:A503.0004/input/input4
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: e1000e 0000:00:19.0 0000:00:19.0 (uninitialized): registered PHC clock
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: hid-generic 0003:413C:A503.0004: input,hidraw3: USB HID v1.00 Device [Dell Dell AC511 USB SoundBar] on usb-0000:00:14.0-11.1/input3
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: mdadm (537) used greatest stack depth: 12968 bytes left
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: e1000e 0000:00:19.0 eth0: (PCI Express:2.5GT/s:Width x1) 98:90:96:a0:02:93
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: e1000e 0000:00:19.0 eth0: Intel(R) PRO/1000 Network Connection
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: e1000e 0000:00:19.0 eth0: MAC: 11, PHY: 12, PBA No: FFFFFF-0FF
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: e1000e 0000:00:19.0 enp0s25: renamed from eth0
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: random: crng init done
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: mdadm (575) used greatest stack depth: 12560 bytes left
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: md/raid1:md127: active with 2 out of 2 mirrors
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: md/raid1:md125: active with 2 out of 2 mirrors
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: md125: detected capacity change from 0 to 68721573888
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: md127: detected capacity change from 0 to 1074724864
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: md/raid1:md126: active with 2 out of 2 mirrors
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: md126: detected capacity change from 0 to 274880004096
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: [drm] radeon kernel modesetting enabled.
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: [drm] initializing kernel modesetting (OLAND 0x1002:0x6608 0x1028:0x2120 0x00).
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: radeon 0000:03:00.0: Invalid PCI ROM header signature: expecting 0xaa55, got 0xffff
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: ATOM BIOS: Hadron
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: radeon 0000:03:00.0: VRAM: 2048M 0x0000000000000000 - 0x000000007FFFFFFF (2048M used)
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: radeon 0000:03:00.0: GTT: 2048M 0x0000000080000000 - 0x00000000FFFFFFFF
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: [drm] Detected VRAM RAM=2048M, BAR=256M
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: [drm] RAM width 128bits DDR
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: [TTM] Zone  kernel: Available graphics memory: 16420424 kiB
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: [TTM] Zone   dma32: Available graphics memory: 2097152 kiB
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: [TTM] Initializing pool allocator
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: [TTM] Initializing DMA pool allocator
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: [drm] radeon: 2048M of VRAM memory ready
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: [drm] radeon: 2048M of GTT memory ready.
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: [drm] Loading oland Microcode
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: [drm] Internal thermal controller with fan control
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: [drm] probing gen 2 caps for device 8086:2f04 = 37a3903/e
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: [drm] radeon: dpm initialized
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: [drm] Found VCE firmware/feedback version 50.0.1 / 17!
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: [drm] GART: num cpu pages 524288, num gpu pages 524288
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: [drm] probing gen 2 caps for device 8086:2f04 = 37a3903/e
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: [drm] PCIE gen 3 link speeds already enabled
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: [drm] PCIE GART of 2048M enabled (table at 0x00000000001D6000).
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: radeon 0000:03:00.0: WB enabled
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: radeon 0000:03:00.0: fence driver on ring 0 use gpu addr 0x0000000080000c00 and cpu addr 0x00000000c3142f0d
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: radeon 0000:03:00.0: fence driver on ring 1 use gpu addr 0x0000000080000c04 and cpu addr 0x00000000804bcfa7
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: radeon 0000:03:00.0: fence driver on ring 2 use gpu addr 0x0000000080000c08 and cpu addr 0x0000000027104f39
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: radeon 0000:03:00.0: fence driver on ring 3 use gpu addr 0x0000000080000c0c and cpu addr 0x0000000046405bf3
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: radeon 0000:03:00.0: fence driver on ring 4 use gpu addr 0x0000000080000c10 and cpu addr 0x00000000a2fe01a4
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: radeon 0000:03:00.0: fence driver on ring 5 use gpu addr 0x0000000000075a18 and cpu addr 0x0000000095f07667
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: radeon 0000:03:00.0: failed VCE resume (-110).
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: [drm] Supports vblank timestamp caching Rev 2 (21.10.2013).
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: [drm] Driver supports precise vblank timestamp query.
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: radeon 0000:03:00.0: radeon: MSI limited to 32-bit
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: radeon 0000:03:00.0: radeon: using MSI.
Dec 19 16:35:07 cerberus.csd.uwm.edu kernel: [drm] radeon: irq initialized.
Dec 19 16:35:08 cerberus.csd.uwm.edu kernel: [drm] ring test on 0 succeeded in 1 usecs
Dec 19 16:35:08 cerberus.csd.uwm.edu kernel: [drm] ring test on 1 succeeded in 1 usecs
Dec 19 16:35:08 cerberus.csd.uwm.edu kernel: [drm] ring test on 2 succeeded in 1 usecs
Dec 19 16:35:08 cerberus.csd.uwm.edu kernel: [drm] ring test on 3 succeeded in 3 usecs
Dec 19 16:35:08 cerberus.csd.uwm.edu kernel: [drm] ring test on 4 succeeded in 3 usecs
Dec 19 16:35:08 cerberus.csd.uwm.edu kernel: [drm] ring test on 5 succeeded in 1 usecs
Dec 19 16:35:08 cerberus.csd.uwm.edu kernel: [drm] UVD initialized successfully.
Dec 19 16:35:08 cerberus.csd.uwm.edu kernel: [drm] ib test on ring 0 succeeded in 0 usecs
Dec 19 16:35:08 cerberus.csd.uwm.edu kernel: [drm] ib test on ring 1 succeeded in 0 usecs
Dec 19 16:35:08 cerberus.csd.uwm.edu kernel: [drm] ib test on ring 2 succeeded in 0 usecs
Dec 19 16:35:08 cerberus.csd.uwm.edu kernel: [drm] ib test on ring 3 succeeded in 0 usecs
Dec 19 16:35:08 cerberus.csd.uwm.edu kernel: [drm] ib test on ring 4 succeeded in 0 usecs
Dec 19 16:35:08 cerberus.csd.uwm.edu kernel: mdadm (619) used greatest stack depth: 12176 bytes left
Dec 19 16:35:08 cerberus.csd.uwm.edu kernel: kauditd_printk_skb: 7 callbacks suppressed
Dec 19 16:35:08 cerberus.csd.uwm.edu kernel: audit: type=1130 audit(1513722908.454:18): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-vconsole-setup comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 19 16:35:08 cerberus.csd.uwm.edu kernel: audit: type=1131 audit(1513722908.454:19): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-vconsole-setup comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 19 16:35:08 cerberus.csd.uwm.edu kernel: [drm] ib test on ring 5 succeeded
Dec 19 16:35:08 cerberus.csd.uwm.edu kernel: [drm] Radeon Display Connectors
Dec 19 16:35:08 cerberus.csd.uwm.edu kernel: [drm] Connector 0:
Dec 19 16:35:08 cerberus.csd.uwm.edu kernel: [drm]   DP-1
Dec 19 16:35:08 cerberus.csd.uwm.edu kernel: [drm]   HPD1
Dec 19 16:35:08 cerberus.csd.uwm.edu kernel: [drm]   DDC: 0x6540 0x6540 0x6544 0x6544 0x6548 0x6548 0x654c 0x654c
Dec 19 16:35:08 cerberus.csd.uwm.edu kernel: [drm]   Encoders:
Dec 19 16:35:08 cerberus.csd.uwm.edu kernel: [drm]     DFP1: INTERNAL_UNIPHY
Dec 19 16:35:08 cerberus.csd.uwm.edu kernel: [drm] Connector 1:
Dec 19 16:35:08 cerberus.csd.uwm.edu kernel: [drm]   DP-2
Dec 19 16:35:08 cerberus.csd.uwm.edu kernel: [drm]   HPD2
Dec 19 16:35:08 cerberus.csd.uwm.edu kernel: [drm]   DDC: 0x6530 0x6530 0x6534 0x6534 0x6538 0x6538 0x653c 0x653c
Dec 19 16:35:08 cerberus.csd.uwm.edu kernel: [drm]   Encoders:
Dec 19 16:35:08 cerberus.csd.uwm.edu kernel: [drm]     DFP2: INTERNAL_UNIPHY
Dec 19 16:35:08 cerberus.csd.uwm.edu kernel: [drm] fb mappable at 0xE05D8000
Dec 19 16:35:08 cerberus.csd.uwm.edu kernel: [drm] vram apper at 0xE0000000
Dec 19 16:35:08 cerberus.csd.uwm.edu kernel: [drm] size 8294400
Dec 19 16:35:08 cerberus.csd.uwm.edu kernel: [drm] fb depth is 24
Dec 19 16:35:08 cerberus.csd.uwm.edu kernel: [drm]    pitch is 7680
Dec 19 16:35:09 cerberus.csd.uwm.edu kernel: fbcon: radeondrmfb (fb0) is primary device
Dec 19 16:35:09 cerberus.csd.uwm.edu kernel: Console: switching to colour frame buffer device 240x67
Dec 19 16:35:09 cerberus.csd.uwm.edu kernel: radeon 0000:03:00.0: fb0: radeondrmfb frame buffer device
Dec 19 16:35:09 cerberus.csd.uwm.edu kernel: [drm] Initialized radeon 2.50.0 20080528 for 0000:03:00.0 on minor 0
Dec 19 16:35:22 cerberus.csd.uwm.edu kernel: audit: type=1130 audit(1513722922.869:20): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-cryptsetup@luks\x2dcc6ee93c\x2de729\x2d4f78\x2d9baf\x2d0cc5cc8a9ff1 comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 19 16:35:22 cerberus.csd.uwm.edu kernel: audit: type=1130 audit(1513722922.884:21): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-cryptsetup@luks\x2df5e2d09b\x2df8a3\x2d487d\x2d9517\x2dabe4fb0eada3 comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 19 16:35:23 cerberus.csd.uwm.edu kernel: audit: type=1130 audit(1513722923.008:22): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=dracut-initqueue comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 19 16:35:23 cerberus.csd.uwm.edu kernel: audit: type=1130 audit(1513722923.039:23): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=dracut-pre-mount comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 19 16:35:23 cerberus.csd.uwm.edu kernel: audit: type=1130 audit(1513722923.340:24): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-fsck-root comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 19 16:35:23 cerberus.csd.uwm.edu kernel: EXT4-fs (dm-0): mounted filesystem with ordered data mode. Opts: (null)
Dec 19 16:35:23 cerberus.csd.uwm.edu kernel: audit: type=1130 audit(1513722923.599:25): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=initrd-parse-etc comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 19 16:35:23 cerberus.csd.uwm.edu kernel: audit: type=1131 audit(1513722923.599:26): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=initrd-parse-etc comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 19 16:35:23 cerberus.csd.uwm.edu kernel: audit: type=1130 audit(1513722923.804:27): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=dracut-pre-pivot comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 19 16:35:23 cerberus.csd.uwm.edu kernel: audit: type=1131 audit(1513722923.836:28): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=dracut-pre-pivot comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 19 16:35:23 cerberus.csd.uwm.edu kernel: audit: type=1130 audit(1513722923.845:29): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=dracut-pre-mount comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 19 16:35:29 cerberus.csd.uwm.edu systemd-journald[223]: Received SIGTERM from PID 1 (systemd).
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: systemd: 23 output lines suppressed due to ratelimiting
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: SELinux: 32768 avtab hash slots, 109803 rules.
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: SELinux: 32768 avtab hash slots, 109803 rules.
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: SELinux:  8 users, 14 roles, 5125 types, 317 bools, 1 sens, 1024 cats
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: SELinux:  97 classes, 109803 rules
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: SELinux:  Permission getrlimit in class process not defined in policy.
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: SELinux:  Class sctp_socket not defined in policy.
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: SELinux:  Class icmp_socket not defined in policy.
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: SELinux:  Class ax25_socket not defined in policy.
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: SELinux:  Class ipx_socket not defined in policy.
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: SELinux:  Class netrom_socket not defined in policy.
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: SELinux:  Class atmpvc_socket not defined in policy.
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: SELinux:  Class x25_socket not defined in policy.
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: SELinux:  Class rose_socket not defined in policy.
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: SELinux:  Class decnet_socket not defined in policy.
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: SELinux:  Class atmsvc_socket not defined in policy.
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: SELinux:  Class rds_socket not defined in policy.
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: SELinux:  Class irda_socket not defined in policy.
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: SELinux:  Class pppox_socket not defined in policy.
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: SELinux:  Class llc_socket not defined in policy.
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: SELinux:  Class can_socket not defined in policy.
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: SELinux:  Class tipc_socket not defined in policy.
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: SELinux:  Class bluetooth_socket not defined in policy.
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: SELinux:  Class iucv_socket not defined in policy.
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: SELinux:  Class rxrpc_socket not defined in policy.
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: SELinux:  Class isdn_socket not defined in policy.
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: SELinux:  Class phonet_socket not defined in policy.
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: SELinux:  Class ieee802154_socket not defined in policy.
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: SELinux:  Class caif_socket not defined in policy.
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: SELinux:  Class alg_socket not defined in policy.
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: SELinux:  Class nfc_socket not defined in policy.
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: SELinux:  Class vsock_socket not defined in policy.
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: SELinux:  Class kcm_socket not defined in policy.
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: SELinux:  Class qipcrtr_socket not defined in policy.
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: SELinux:  Class smc_socket not defined in policy.
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: SELinux:  Class bpf not defined in policy.
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: SELinux: the above unknown classes and permissions will be allowed
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: SELinux:  policy capability network_peer_controls=1
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: SELinux:  policy capability open_perms=1
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: SELinux:  policy capability extended_socket_class=0
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: SELinux:  policy capability always_check_network=0
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: SELinux:  policy capability cgroup_seclabel=1
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: SELinux:  policy capability nnp_nosuid_transition=1
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: SELinux:  Completing initialization.
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: SELinux:  Setting up existing superblocks.
Dec 19 16:35:29 cerberus.csd.uwm.edu systemd[1]: Successfully loaded SELinux policy in 718.166ms.
Dec 19 16:35:29 cerberus.csd.uwm.edu systemd[1]: Unable to fix SELinux security context of /run/systemd/units/invocation:initrd-switch-root.service: Permission denied
Dec 19 16:35:29 cerberus.csd.uwm.edu systemd[1]: Unable to fix SELinux security context of /run/systemd/units/invocation:sysroot.mount: Permission denied
Dec 19 16:35:29 cerberus.csd.uwm.edu systemd[1]: Unable to fix SELinux security context of /run/systemd/units/invocation:systemd-fsck-root.service: Permission denied
Dec 19 16:35:29 cerberus.csd.uwm.edu systemd[1]: Unable to fix SELinux security context of /run/systemd/units/invocation:systemd-cryptsetup@luks\x2df5e2d09b\x2df8a3\x2d487d\x2d9517\x2dabe4fb0eada3.service: Permission denied
Dec 19 16:35:29 cerberus.csd.uwm.edu systemd[1]: Unable to fix SELinux security context of /run/systemd/units/invocation:systemd-cryptsetup@luks\x2dcc6ee93c\x2de729\x2d4f78\x2d9baf\x2d0cc5cc8a9ff1.service: Permission denied
Dec 19 16:35:29 cerberus.csd.uwm.edu systemd[1]: Unable to fix SELinux security context of /run/systemd/units/invocation:plymouth-start.service: Permission denied
Dec 19 16:35:29 cerberus.csd.uwm.edu systemd[1]: Unable to fix SELinux security context of /run/systemd/units/invocation:sys-kernel-config.mount: Permission denied
Dec 19 16:35:29 cerberus.csd.uwm.edu systemd[1]: Unable to fix SELinux security context of /run/systemd/units/invocation:systemd-journald.service: Permission denied
Dec 19 16:35:29 cerberus.csd.uwm.edu systemd[1]: Relabelled /dev, /run and /sys/fs/cgroup in 52.699ms.
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: kauditd_printk_skb: 41 callbacks suppressed
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: audit: type=1130 audit(1513722929.633:71): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=systemd-journald comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: audit: type=1131 audit(1513722929.633:72): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=systemd-journald comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: audit: type=1130 audit(1513722929.639:73): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=initrd-switch-root comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: audit: type=1131 audit(1513722929.639:74): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=initrd-switch-root comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: audit: type=1130 audit(1513722929.659:75): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=systemd-journald comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: audit: type=1131 audit(1513722929.659:76): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=systemd-journald comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: audit: type=1305 audit(1513722929.740:77): audit_enabled=1 old=1 auid=4294967295 ses=4294967295 subj=system_u:system_r:syslogd_t:s0 res=1
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: audit: type=1400 audit(1513722929.740:78): avc:  denied  { read } for  pid=940 comm="systemd-journal" name="invocation:systemd-journald.service" dev="tmpfs" ino=18510 scontext=system_u:system_r:syslogd_t:s0 tcontext=system_u:object_r:init_var_run_t:s0 tclass=lnk_file permissive=0
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: audit: type=1300 audit(1513722929.740:78): arch=c000003e syscall=267 success=no exit=-13 a0=ffffff9c a1=7ffe5fcf4320 a2=55f87d34f090 a3=63 items=0 ppid=1 pid=940 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="systemd-journal" exe="/usr/lib/systemd/systemd-journald" subj=system_u:system_r:syslogd_t:s0 key=(null)
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: audit: type=1327 audit(1513722929.740:78): proctitle="/usr/lib/systemd/systemd-journald"
Dec 19 16:35:29 cerberus.csd.uwm.edu kernel: EXT4-fs (dm-0): re-mounted. Opts: (null)
Dec 19 16:35:30 cerberus.csd.uwm.edu kernel: gzip (962) used greatest stack depth: 12168 bytes left
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: floppy0: no floppy controllers found
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: work still pending
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: i801_smbus 0000:00:1f.3: SMBus using PCI interrupt
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: input: PC Speaker as /devices/platform/pcspkr/input/input5
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: snd_hda_intel 0000:03:00.1: Handle vga_switcheroo audio client
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: snd_hda_intel 0000:03:00.1: Force to non-snoop mode
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: input: HDA ATI HDMI HDMI/DP,pcm=3 as /devices/pci0000:00/0000:00:02.0/0000:03:00.1/sound/card1/input6
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: input: HDA ATI HDMI HDMI/DP,pcm=7 as /devices/pci0000:00/0000:00:02.0/0000:03:00.1/sound/card1/input7
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: dcdbas dcdbas: Dell Systems Management Base Driver (version 5.6.0-3.2)
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: e1000e 0000:00:19.0 em1: renamed from enp0s25
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: Rounding down aligned max_sectors from 4294967295 to 4294967288
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: RAPL PMU: API unit is 2^-32 Joules, 4 fixed counters, 655360 ms ovfl timer
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: RAPL PMU: hw unit of domain pp0-core 2^-14 Joules
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: RAPL PMU: hw unit of domain package 2^-14 Joules
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: RAPL PMU: hw unit of domain dram 2^-14 Joules
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: RAPL PMU: hw unit of domain pp1-gpu 2^-14 Joules
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: snd_hda_codec_realtek hdaudioC0D0: autoconfig for ALC3220: line_outs=1 (0x1b/0x0/0x0/0x0/0x0) type:line
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: snd_hda_codec_realtek hdaudioC0D0:    speaker_outs=1 (0x14/0x0/0x0/0x0/0x0)
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: snd_hda_codec_realtek hdaudioC0D0:    hp_outs=1 (0x15/0x0/0x0/0x0/0x0)
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: snd_hda_codec_realtek hdaudioC0D0:    mono: mono_out=0x0
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: snd_hda_codec_realtek hdaudioC0D0:    inputs:
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: snd_hda_codec_realtek hdaudioC0D0:      Front Mic=0x1a
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: snd_hda_codec_realtek hdaudioC0D0:      Rear Mic=0x18
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: input: HDA Intel PCH Front Mic as /devices/pci0000:00/0000:00:1b.0/sound/card0/input8
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: input: HDA Intel PCH Rear Mic as /devices/pci0000:00/0000:00:1b.0/sound/card0/input9
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: input: HDA Intel PCH Line Out as /devices/pci0000:00/0000:00:1b.0/sound/card0/input10
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: input: HDA Intel PCH Front Headphone as /devices/pci0000:00/0000:00:1b.0/sound/card0/input11
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: kauditd_printk_skb: 12 callbacks suppressed
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: audit: type=1130 audit(1513722935.037:91): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=systemd-sysctl comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: WARNING: CPU: 3 PID: 1129 at block/genhd.c:680 device_add_disk+0x430/0x4b0
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: Modules linked in: snd_seq_device irqbypass floppy(+) intel_cstate intel_uncore snd_hda_codec_realtek intel_rapl_perf target_core_mod dcdbas snd_hda_codec_generic dell_smm_hwmon snd_hda_codec_hdmi mei_me snd_hda_intel mei lpc_ich pcspkr i2c_i801 snd_hda_codec snd_hda_core snd_hwdep shpchp wmi snd_pcm_oss snd_mixer_oss binfmt_misc dm_crypt radeon raid1 i2c_algo_bit drm_kms_helper crct10dif_pclmul ttm crc32_pclmul crc32c_intel drm e1000e ghash_clmulni_intel ptp pps_core snd_pcm snd_timer snd soundcore analog gameport joydev
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: CPU: 3 PID: 1129 Comm: mdadm Not tainted 4.15.0-rc4+ #20
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: Hardware name: Dell Inc. Precision Tower 5810/0WR1RF, BIOS A07 04/14/2015
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: RIP: 0010:device_add_disk+0x430/0x4b0
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: RSP: 0018:ffffacac84f77b80 EFLAGS: 00010282
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: RAX: 00000000fffffff4 RBX: ffff8de6abfbe000 RCX: 0000000000000000
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: RDX: 00000001820001d7 RSI: fffff2f920a6ba80 RDI: 0000000040000000
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: RBP: ffff8de6abfbe0a0 R08: ffff8de6a9aeaec0 R09: 00000001820001d6
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: R10: ffffacac84f77bd0 R11: 0000000000000000 R12: 0000000000000000
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: R13: ffff8de6abfbe00c R14: 0000000000000009 R15: ffff8de6abfbe000
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: FS:  00007f143016c740(0000) GS:ffff8de6bf400000(0000) knlGS:0000000000000000
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: CR2: 00007f142fa9fef0 CR3: 00000008274a7004 CR4: 00000000001606e0
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: Call Trace:
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel:  md_alloc+0x1ca/0x390
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel:  md_probe+0x15/0x20
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel:  kobj_lookup+0x102/0x160
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel:  ? md_alloc+0x390/0x390
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel:  get_gendisk+0x29/0x110
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel:  blkdev_get+0x74/0x380
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel:  ? bd_acquire+0xc0/0xc0
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel:  ? _raw_spin_unlock+0x24/0x30
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel:  ? bd_acquire+0xc0/0xc0
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel:  do_dentry_open+0x1c6/0x2f0
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel:  ? security_inode_permission+0x3c/0x50
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel:  path_openat+0x57e/0xc80
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel:  do_filp_open+0x9b/0x110
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel:  ? __alloc_fd+0xe5/0x1f0
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel:  ? _raw_spin_unlock+0x24/0x30
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel:  ? do_sys_open+0x1bd/0x250
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel:  do_sys_open+0x1bd/0x250
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel:  do_syscall_64+0x66/0x210
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel:  entry_SYSCALL64_slow_path+0x25/0x25
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: RIP: 0033:0x7f142fb1da4e
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: RSP: 002b:00007ffdccc383b0 EFLAGS: 00000246 ORIG_RAX: 0000000000000101
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: RAX: ffffffffffffffda RBX: 0000000000004082 RCX: 00007f142fb1da4e
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: RDX: 0000000000004082 RSI: 00007ffdccc38440 RDI: 00000000ffffff9c
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: RBP: 00007ffdccc38440 R08: 00007ffdccc38440 R09: 0000000000000000
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000009
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: R13: 000000000000007c R14: 00007ffdccc384a0 R15: 00007ffdccc38528
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: Code: 48 83 c6 10 e8 62 60 ee ff 85 c0 0f 84 e0 fd ff ff 0f ff e9 d9 fd ff ff 80 a3 ec 00 00 00 ef e9 cd fd ff ff 0f ff e9 e2 fd ff ff <0f> ff e9 c6 fe ff ff 31 f6 48 89 df e8 8f f8 ff ff 48 85 c0 48 
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: ---[ end trace bb5b420d8ab6fa89 ]---
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: BUG: unable to handle kernel NULL pointer dereference at 0000000000000040
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: IP: sysfs_do_create_link_sd.isra.2+0x33/0xc0
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: PGD 0 P4D 0 
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: Oops: 0000 [#1] SMP
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: Modules linked in: snd_seq_device irqbypass floppy(+) intel_cstate intel_uncore snd_hda_codec_realtek intel_rapl_perf target_core_mod dcdbas snd_hda_codec_generic dell_smm_hwmon snd_hda_codec_hdmi mei_me snd_hda_intel mei lpc_ich pcspkr i2c_i801 snd_hda_codec snd_hda_core snd_hwdep shpchp wmi snd_pcm_oss snd_mixer_oss binfmt_misc dm_crypt radeon raid1 i2c_algo_bit drm_kms_helper crct10dif_pclmul ttm crc32_pclmul crc32c_intel drm e1000e ghash_clmulni_intel ptp pps_core snd_pcm snd_timer snd soundcore analog gameport joydev
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: CPU: 3 PID: 1129 Comm: mdadm Tainted: G        W        4.15.0-rc4+ #20
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: Hardware name: Dell Inc. Precision Tower 5810/0WR1RF, BIOS A07 04/14/2015
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: RIP: 0010:sysfs_do_create_link_sd.isra.2+0x33/0xc0
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: RSP: 0018:ffffacac84f77b50 EFLAGS: 00010286
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: RAX: 0000000000000000 RBX: 0000000000000040 RCX: 8f5c28f5c28f5c29
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: RDX: ffff8de6bf40e3e0 RSI: ffffffffa1224f78 RDI: 0000000000000246
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: RBP: ffffffffa0cd9807 R08: 0000000000000000 R09: 0000000000000001
Dec 19 16:35:40 cerberus.csd.uwm.edu kernel: R10: ffffacac84f77ac8 R11: c88ccc29f79ae15e R12: 0000000000000001
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel: R13: ffff8de6a61962e0 R14: 0000000000000009 R15: ffff8de6abfbe000
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel: FS:  00007f143016c740(0000) GS:ffff8de6bf400000(0000) knlGS:0000000000000000
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel: CR2: 0000000000000040 CR3: 00000008274a7004 CR4: 00000000001606e0
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel: Call Trace:
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel:  device_add_disk+0x40e/0x4b0
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel:  md_alloc+0x1ca/0x390
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel:  md_probe+0x15/0x20
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel:  kobj_lookup+0x102/0x160
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel:  ? md_alloc+0x390/0x390
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel:  get_gendisk+0x29/0x110
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel:  blkdev_get+0x74/0x380
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel:  ? bd_acquire+0xc0/0xc0
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel:  ? _raw_spin_unlock+0x24/0x30
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel:  ? bd_acquire+0xc0/0xc0
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel:  do_dentry_open+0x1c6/0x2f0
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel:  ? security_inode_permission+0x3c/0x50
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel:  path_openat+0x57e/0xc80
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel:  do_filp_open+0x9b/0x110
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel:  ? __alloc_fd+0xe5/0x1f0
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel:  ? _raw_spin_unlock+0x24/0x30
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel:  ? do_sys_open+0x1bd/0x250
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel:  do_sys_open+0x1bd/0x250
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel:  do_syscall_64+0x66/0x210
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel:  entry_SYSCALL64_slow_path+0x25/0x25
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel: RIP: 0033:0x7f142fb1da4e
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel: RSP: 002b:00007ffdccc383b0 EFLAGS: 00000246 ORIG_RAX: 0000000000000101
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel: RAX: ffffffffffffffda RBX: 0000000000004082 RCX: 00007f142fb1da4e
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel: RDX: 0000000000004082 RSI: 00007ffdccc38440 RDI: 00000000ffffff9c
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel: RBP: 00007ffdccc38440 R08: 00007ffdccc38440 R09: 0000000000000000
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel: R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000009
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel: R13: 000000000000007c R14: 00007ffdccc384a0 R15: 00007ffdccc38528
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel: Code: 41 56 41 55 41 54 55 53 0f 84 80 00 00 00 48 85 ff 74 7b 48 89 f3 49 89 fd 48 c7 c7 60 4f 22 a1 41 89 cc 48 89 d5 e8 5d c5 62 00 <48> 8b 1b 48 85 db 74 41 48 89 df e8 8d c0 ff ff 48 c7 c7 60 4f 
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel: RIP: sysfs_do_create_link_sd.isra.2+0x33/0xc0 RSP: ffffacac84f77b50
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel: CR2: 0000000000000040
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel: ---[ end trace bb5b420d8ab6fa8a ]---
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel: BUG: sleeping function called from invalid context at ./include/linux/percpu-rwsem.h:34
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel: in_atomic(): 1, irqs_disabled(): 1, pid: 1129, name: mdadm
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel: INFO: lockdep is turned off.
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel: irq event stamp: 9044
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel: hardirqs last  enabled at (9043): [<000000002fa24a8d>] _raw_spin_unlock_irqrestore+0x32/0x60
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel: hardirqs last disabled at (9044): [<0000000020f652aa>] error_entry+0x73/0xd0
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel: softirqs last  enabled at (9024): [<00000000bb061b2d>] peernet2id+0x51/0x80
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel: softirqs last disabled at (9022): [<000000000a93bf30>] peernet2id+0x32/0x80
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel: CPU: 3 PID: 1129 Comm: mdadm Tainted: G      D W        4.15.0-rc4+ #20
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel: Hardware name: Dell Inc. Precision Tower 5810/0WR1RF, BIOS A07 04/14/2015
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel: Call Trace:
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel:  dump_stack+0x85/0xbf
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel:  ___might_sleep+0x15b/0x240
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel:  exit_signals+0x30/0x240
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel:  do_exit+0xb8/0xd70
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel:  rewind_stack_do_exit+0x17/0x20
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel: note: mdadm[1129] exited with preempt_count 1
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel: Adding 67108860k swap on /dev/mapper/luks-cc6ee93c-e729-4f78-9baf-0cc5cc8a9ff1.  Priority:-2 extents:1 across:67108860k FS
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel: floppy0: no floppy controllers found
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel: audit: type=1130 audit(1513722940.386:92): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=systemd-journal-flush comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel: audit: type=1400 audit(1513722941.086:93): avc:  denied  { read } for  pid=940 comm="systemd-journal" name="invocation:fedora-readonly.service" dev="tmpfs" ino=18210 scontext=system_u:system_r:syslogd_t:s0 tcontext=system_u:object_r:init_var_run_t:s0 tclass=lnk_file permissive=0
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel: audit: type=1300 audit(1513722941.086:93): arch=c000003e syscall=267 success=no exit=-13 a0=ffffff9c a1=7ffe5fcf4070 a2=55f87d34fa40 a3=63 items=0 ppid=1 pid=940 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="systemd-journal" exe="/usr/lib/systemd/systemd-journald" subj=system_u:system_r:syslogd_t:s0 key=(null)
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel: audit: type=1327 audit(1513722941.086:93): proctitle="/usr/lib/systemd/systemd-journald"
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel: audit: type=1400 audit(1513722941.091:94): avc:  denied  { read } for  pid=940 comm="systemd-journal" name="invocation:systemd-udevd.service" dev="tmpfs" ino=18752 scontext=system_u:system_r:syslogd_t:s0 tcontext=system_u:object_r:init_var_run_t:s0 tclass=lnk_file permissive=0
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel: audit: type=1300 audit(1513722941.091:94): arch=c000003e syscall=267 success=no exit=-13 a0=ffffff9c a1=7ffe5fcf3d90 a2=55f87d35e1b0 a3=63 items=0 ppid=1 pid=940 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="systemd-journal" exe="/usr/lib/systemd/systemd-journald" subj=system_u:system_r:syslogd_t:s0 key=(null)
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel: audit: type=1327 audit(1513722941.091:94): proctitle="/usr/lib/systemd/systemd-journald"
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel: audit: type=1400 audit(1513722941.122:95): avc:  denied  { read } for  pid=940 comm="systemd-journal" name="invocation:systemd-udevd.service" dev="tmpfs" ino=18752 scontext=system_u:system_r:syslogd_t:s0 tcontext=system_u:object_r:init_var_run_t:s0 tclass=lnk_file permissive=0
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel: audit: type=1300 audit(1513722941.122:95): arch=c000003e syscall=267 success=no exit=-13 a0=ffffff9c a1=7ffe5fcf3d90 a2=55f87d361300 a3=63 items=0 ppid=1 pid=940 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="systemd-journal" exe="/usr/lib/systemd/systemd-journald" subj=system_u:system_r:syslogd_t:s0 key=(null)
Dec 19 16:35:41 cerberus.csd.uwm.edu kernel: audit: type=1327 audit(1513722941.122:95): proctitle="/usr/lib/systemd/systemd-journald"
Dec 19 16:36:03 cerberus.csd.uwm.edu kernel: watchdog: BUG: soft lockup - CPU#1 stuck for 22s! [systemd-udevd:976]
Dec 19 16:36:03 cerberus.csd.uwm.edu kernel: Modules linked in: mei_wdt(+) snd_seq_device irqbypass floppy(+) intel_cstate intel_uncore snd_hda_codec_realtek intel_rapl_perf target_core_mod dcdbas snd_hda_codec_generic dell_smm_hwmon snd_hda_codec_hdmi mei_me snd_hda_intel mei lpc_ich pcspkr i2c_i801 snd_hda_codec snd_hda_core snd_hwdep shpchp wmi snd_pcm_oss snd_mixer_oss binfmt_misc dm_crypt radeon raid1 i2c_algo_bit drm_kms_helper crct10dif_pclmul ttm crc32_pclmul crc32c_intel drm e1000e ghash_clmulni_intel ptp pps_core snd_pcm snd_timer snd soundcore analog gameport joydev
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: watchdog: BUG: soft lockup - CPU#3 stuck for 22s! [systemd-modules:1072]
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: Modules linked in: mei_wdt(+) snd_seq_device irqbypass floppy(+) intel_cstate intel_uncore snd_hda_codec_realtek intel_rapl_perf target_core_mod dcdbas snd_hda_codec_generic dell_smm_hwmon snd_hda_codec_hdmi mei_me snd_hda_intel mei lpc_ich pcspkr i2c_i801 snd_hda_codec snd_hda_core snd_hwdep shpchp wmi snd_pcm_oss snd_mixer_oss binfmt_misc dm_crypt radeon raid1 i2c_algo_bit drm_kms_helper crct10dif_pclmul ttm crc32_pclmul crc32c_intel drm e1000e ghash_clmulni_intel ptp pps_core snd_pcm snd_timer snd soundcore analog gameport joydev
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: irq event stamp: 29756
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: hardirqs last  enabled at (29755): [<000000002fa24a8d>] _raw_spin_unlock_irqrestore+0x32/0x60
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: hardirqs last disabled at (29756): [<00000000ef2b1a64>] __schedule+0xc4/0xb90
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: softirqs last  enabled at (29726): [<00000000f7e5639c>] __do_softirq+0x392/0x502
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: softirqs last disabled at (29707): [<00000000f92018d2>] irq_exit+0x102/0x110
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: CPU: 3 PID: 1072 Comm: systemd-modules Tainted: G      D W        4.15.0-rc4+ #20
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: Hardware name: Dell Inc. Precision Tower 5810/0WR1RF, BIOS A07 04/14/2015
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: RIP: 0010:queued_spin_lock_slowpath+0x111/0x1a0
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: RSP: 0000:ffffacac8440bb68 EFLAGS: 00000202 ORIG_RAX: ffffffffffffff11
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: RAX: 0000000000000000 RBX: ffffffffa1224f60 RCX: ffff8de6bf5dc200
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: RDX: 0000000000100101 RSI: 0000000000000101 RDI: ffffffffa1224f60
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: RBP: ffffffffa1224f60 R08: 0000000000100000 R09: 0000000000000000
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: R10: ffffacac8440bb10 R11: 0000000000000000 R12: ffff8de6adc09700
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: R13: ffffffffc0878660 R14: ffffffffc0879130 R15: 0000000000000000
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: FS:  00007f088a3abdc0(0000) GS:ffff8de6bf400000(0000) knlGS:0000000000000000
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: CR2: 00007f6fab0519f8 CR3: 0000000827431002 CR4: 00000000001606e0
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: Call Trace:
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel:  do_raw_spin_lock+0xad/0xb0
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel:  _raw_spin_lock+0x52/0x70
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel:  sysfs_remove_dir+0x1a/0x60
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel:  kobject_del.part.3+0xe/0x40
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel:  kobject_put+0x67/0x1b0
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel:  bus_remove_driver+0x69/0xd0
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel:  floppy_module_init+0xdc6/0xee0 [floppy]
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel:  ? set_cmos+0x63/0x63 [floppy]
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel:  do_one_initcall+0x4b/0x18c
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel:  ? do_init_module+0x22/0x203
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel:  ? rcu_read_lock_sched_held+0x6b/0x80
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel:  ? kmem_cache_alloc_trace+0x28c/0x2f0
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel:  ? do_init_module+0x22/0x203
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel:  do_init_module+0x5b/0x203
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel:  load_module+0x2716/0x2c90
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel:  ? vfs_read+0x127/0x150
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel:  ? SYSC_finit_module+0xe9/0x110
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel:  SYSC_finit_module+0xe9/0x110
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel:  do_syscall_64+0x66/0x210
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel:  entry_SYSCALL64_slow_path+0x25/0x25
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: RIP: 0033:0x7f0889f75339
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: RSP: 002b:00007ffce996f9e8 EFLAGS: 00000246 ORIG_RAX: 0000000000000139
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: RAX: ffffffffffffffda RBX: 00005632df3f4bc0 RCX: 00007f0889f75339
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: RDX: 0000000000000000 RSI: 00007f088982dda5 RDI: 0000000000000005
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: RBP: 00007f088982dda5 R08: 0000000000000000 R09: 00005632df091264
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: R10: 0000000000000005 R11: 0000000000000246 R12: 0000000000000000
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: R13: 00005632df3f4b80 R14: 0000000000020000 R15: 00005632df3f47b0
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: Code: 20 54 d9 a0 48 89 08 8b 41 08 85 c0 75 09 f3 90 8b 41 08 85 c0 74 f7 4c 8b 09 4d 85 c9 0f 84 8c 00 00 00 41 0f 18 09 eb 02 f3 90 <8b> 17 66 85 d2 75 f7 be 01 00 00 00 eb 0c 89 d0 f0 0f b1 37 39 
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: irq event stamp: 297225
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: hardirqs last  enabled at (297225): [<000000006e6934b1>] _raw_spin_unlock_irq+0x29/0x40
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: hardirqs last disabled at (297224): [<000000005cc10b51>] _raw_spin_lock_irq+0x16/0x70
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: softirqs last  enabled at (296338): [<00000000f7e5639c>] __do_softirq+0x392/0x502
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: softirqs last disabled at (296329): [<00000000f92018d2>] irq_exit+0x102/0x110
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: CPU: 1 PID: 976 Comm: systemd-udevd Tainted: G      D W    L   4.15.0-rc4+ #20
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: Hardware name: Dell Inc. Precision Tower 5810/0WR1RF, BIOS A07 04/14/2015
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: RIP: 0010:queued_spin_lock_slowpath+0x15f/0x1a0
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: RSP: 0018:ffffacac84203cd0 EFLAGS: 00000202 ORIG_RAX: ffffffffffffff11
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: RAX: 0000000000100101 RBX: ffffffffa1224f60 RCX: 0000000000000001
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: RDX: 0000000000000101 RSI: 0000000000000001 RDI: ffffffffa1224f60
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: RBP: ffffffffa1224f60 R08: 0000000000000101 R09: 0000000000000000
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: R10: ffffacac84203c78 R11: 0000000000000000 R12: 0000000000000001
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: R13: ffff8de6a4775c38 R14: 0000000000000000 R15: ffffacac84203e98
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: FS:  00007fa849974dc0(0000) GS:ffff8de6bf000000(0000) knlGS:0000000000000000
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: CR2: 00005588ea479388 CR3: 0000000827c24005 CR4: 00000000001606e0
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: Call Trace:
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel:  do_raw_spin_lock+0xad/0xb0
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel:  _raw_spin_lock+0x52/0x70
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel:  sysfs_do_create_link_sd.isra.2+0x33/0xc0
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel:  load_module+0x2678/0x2c90
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel:  ? vfs_read+0x127/0x150
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel:  ? SYSC_finit_module+0xe9/0x110
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel:  SYSC_finit_module+0xe9/0x110
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel:  do_syscall_64+0x66/0x210
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel:  entry_SYSCALL64_slow_path+0x25/0x25
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: RIP: 0033:0x7fa84931f339
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: RSP: 002b:00007ffda5a85968 EFLAGS: 00000246 ORIG_RAX: 0000000000000139
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: RAX: ffffffffffffffda RBX: 000055813a541d50 RCX: 00007fa84931f339
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: RDX: 0000000000000000 RSI: 00007fa848bd7da5 RDI: 0000000000000007
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: RBP: 00007fa848bd7da5 R08: 0000000000000000 R09: 00007ffda5a85a90
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: R10: 0000000000000007 R11: 0000000000000246 R12: 0000000000000000
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: R13: 000055813a528800 R14: 0000000000020000 R15: 0000558138cf278c
Dec 19 16:36:04 cerberus.csd.uwm.edu kernel: Code: ea 4d 85 c9 c6 07 01 74 4e 41 c7 41 08 01 00 00 00 eb 3a f3 90 8b 37 81 fe 00 01 00 00 74 f4 e9 d7 fe ff ff 83 fa 01 75 04 f3 c3 <f3> 90 8b 07 84 c0 75 f8 b8 01 00 00 00 66 89 07 c3 ba 01 00 00 
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: watchdog: BUG: soft lockup - CPU#1 stuck for 22s! [systemd-udevd:976]
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: Modules linked in: mei_wdt(+) snd_seq_device irqbypass floppy(+) intel_cstate intel_uncore snd_hda_codec_realtek intel_rapl_perf target_core_mod dcdbas snd_hda_codec_generic dell_smm_hwmon snd_hda_codec_hdmi mei_me snd_hda_intel mei lpc_ich pcspkr i2c_i801 snd_hda_codec snd_hda_core snd_hwdep shpchp wmi snd_pcm_oss snd_mixer_oss binfmt_misc dm_crypt radeon raid1 i2c_algo_bit drm_kms_helper crct10dif_pclmul ttm crc32_pclmul crc32c_intel drm e1000e ghash_clmulni_intel ptp pps_core snd_pcm snd_timer snd soundcore analog gameport joydev
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: irq event stamp: 297225
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: hardirqs last  enabled at (297225): [<000000006e6934b1>] _raw_spin_unlock_irq+0x29/0x40
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: watchdog: BUG: soft lockup - CPU#3 stuck for 22s! [systemd-modules:1072]
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: Modules linked in: mei_wdt(+) snd_seq_device irqbypass floppy(+) intel_cstate intel_uncore snd_hda_codec_realtek intel_rapl_perf target_core_mod dcdbas snd_hda_codec_generic dell_smm_hwmon snd_hda_codec_hdmi mei_me snd_hda_intel mei lpc_ich pcspkr i2c_i801 snd_hda_codec snd_hda_core snd_hwdep shpchp wmi snd_pcm_oss snd_mixer_oss binfmt_misc dm_crypt radeon raid1 i2c_algo_bit drm_kms_helper crct10dif_pclmul ttm crc32_pclmul crc32c_intel drm e1000e ghash_clmulni_intel ptp pps_core snd_pcm snd_timer snd soundcore analog gameport joydev
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: irq event stamp: 29756
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: hardirqs last  enabled at (29755): [<000000002fa24a8d>] _raw_spin_unlock_irqrestore+0x32/0x60
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: hardirqs last disabled at (29756): [<00000000ef2b1a64>] __schedule+0xc4/0xb90
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: softirqs last  enabled at (29726): [<00000000f7e5639c>] __do_softirq+0x392/0x502
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: softirqs last disabled at (29707): [<00000000f92018d2>] irq_exit+0x102/0x110
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: CPU: 3 PID: 1072 Comm: systemd-modules Tainted: G      D W    L   4.15.0-rc4+ #20
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: Hardware name: Dell Inc. Precision Tower 5810/0WR1RF, BIOS A07 04/14/2015
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: RIP: 0010:queued_spin_lock_slowpath+0x113/0x1a0
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: RSP: 0000:ffffacac8440bb68 EFLAGS: 00000202 ORIG_RAX: ffffffffffffff11
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: RAX: 0000000000000000 RBX: ffffffffa1224f60 RCX: ffff8de6bf5dc200
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: RDX: 0000000000100101 RSI: 0000000000000101 RDI: ffffffffa1224f60
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: RBP: ffffffffa1224f60 R08: 0000000000100000 R09: 0000000000000000
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: R10: ffffacac8440bb10 R11: 0000000000000000 R12: ffff8de6adc09700
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: R13: ffffffffc0878660 R14: ffffffffc0879130 R15: 0000000000000000
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: FS:  00007f088a3abdc0(0000) GS:ffff8de6bf400000(0000) knlGS:0000000000000000
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: CR2: 00007f6fab0519f8 CR3: 0000000827431002 CR4: 00000000001606e0
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: Call Trace:
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel:  do_raw_spin_lock+0xad/0xb0
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel:  _raw_spin_lock+0x52/0x70
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel:  sysfs_remove_dir+0x1a/0x60
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel:  kobject_del.part.3+0xe/0x40
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel:  kobject_put+0x67/0x1b0
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel:  bus_remove_driver+0x69/0xd0
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel:  floppy_module_init+0xdc6/0xee0 [floppy]
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel:  ? set_cmos+0x63/0x63 [floppy]
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel:  do_one_initcall+0x4b/0x18c
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel:  ? do_init_module+0x22/0x203
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel:  ? rcu_read_lock_sched_held+0x6b/0x80
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel:  ? kmem_cache_alloc_trace+0x28c/0x2f0
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel:  ? do_init_module+0x22/0x203
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel:  do_init_module+0x5b/0x203
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel:  load_module+0x2716/0x2c90
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel:  ? vfs_read+0x127/0x150
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel:  ? SYSC_finit_module+0xe9/0x110
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel:  SYSC_finit_module+0xe9/0x110
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel:  do_syscall_64+0x66/0x210
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel:  entry_SYSCALL64_slow_path+0x25/0x25
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: RIP: 0033:0x7f0889f75339
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: RSP: 002b:00007ffce996f9e8 EFLAGS: 00000246 ORIG_RAX: 0000000000000139
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: RAX: ffffffffffffffda RBX: 00005632df3f4bc0 RCX: 00007f0889f75339
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: RDX: 0000000000000000 RSI: 00007f088982dda5 RDI: 0000000000000005
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: RBP: 00007f088982dda5 R08: 0000000000000000 R09: 00005632df091264
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: R10: 0000000000000005 R11: 0000000000000246 R12: 0000000000000000
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: R13: 00005632df3f4b80 R14: 0000000000020000 R15: 00005632df3f47b0
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: Code: d9 a0 48 89 08 8b 41 08 85 c0 75 09 f3 90 8b 41 08 85 c0 74 f7 4c 8b 09 4d 85 c9 0f 84 8c 00 00 00 41 0f 18 09 eb 02 f3 90 8b 17 <66> 85 d2 75 f7 be 01 00 00 00 eb 0c 89 d0 f0 0f b1 37 39 c2 74 
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: hardirqs last disabled at (297224): [<000000005cc10b51>] _raw_spin_lock_irq+0x16/0x70
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: softirqs last  enabled at (296338): [<00000000f7e5639c>] __do_softirq+0x392/0x502
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: softirqs last disabled at (296329): [<00000000f92018d2>] irq_exit+0x102/0x110
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: CPU: 1 PID: 976 Comm: systemd-udevd Tainted: G      D W    L   4.15.0-rc4+ #20
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: Hardware name: Dell Inc. Precision Tower 5810/0WR1RF, BIOS A07 04/14/2015
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: RIP: 0010:queued_spin_lock_slowpath+0x163/0x1a0
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: RSP: 0018:ffffacac84203cd0 EFLAGS: 00000202 ORIG_RAX: ffffffffffffff11
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: RAX: 0000000000100101 RBX: ffffffffa1224f60 RCX: 0000000000000001
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: RDX: 0000000000000101 RSI: 0000000000000001 RDI: ffffffffa1224f60
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: RBP: ffffffffa1224f60 R08: 0000000000000101 R09: 0000000000000000
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: R10: ffffacac84203c78 R11: 0000000000000000 R12: 0000000000000001
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: R13: ffff8de6a4775c38 R14: 0000000000000000 R15: ffffacac84203e98
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: FS:  00007fa849974dc0(0000) GS:ffff8de6bf000000(0000) knlGS:0000000000000000
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: CR2: 00005588ea479388 CR3: 0000000827c24005 CR4: 00000000001606e0
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: Call Trace:
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel:  do_raw_spin_lock+0xad/0xb0
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel:  _raw_spin_lock+0x52/0x70
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel:  sysfs_do_create_link_sd.isra.2+0x33/0xc0
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel:  load_module+0x2678/0x2c90
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel:  ? vfs_read+0x127/0x150
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel:  ? SYSC_finit_module+0xe9/0x110
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel:  SYSC_finit_module+0xe9/0x110
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel:  do_syscall_64+0x66/0x210
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel:  entry_SYSCALL64_slow_path+0x25/0x25
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: RIP: 0033:0x7fa84931f339
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: RSP: 002b:00007ffda5a85968 EFLAGS: 00000246 ORIG_RAX: 0000000000000139
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: RAX: ffffffffffffffda RBX: 000055813a541d50 RCX: 00007fa84931f339
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: RDX: 0000000000000000 RSI: 00007fa848bd7da5 RDI: 0000000000000007
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: RBP: 00007fa848bd7da5 R08: 0000000000000000 R09: 00007ffda5a85a90
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: R10: 0000000000000007 R11: 0000000000000246 R12: 0000000000000000
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: R13: 000055813a528800 R14: 0000000000020000 R15: 0000558138cf278c
Dec 19 16:36:31 cerberus.csd.uwm.edu kernel: Code: c6 07 01 74 4e 41 c7 41 08 01 00 00 00 eb 3a f3 90 8b 37 81 fe 00 01 00 00 74 f4 e9 d7 fe ff ff 83 fa 01 75 04 f3 c3 f3 90 8b 07 <84> c0 75 f8 b8 01 00 00 00 66 89 07 c3 ba 01 00 00 00 f0 0f b1 
Dec 19 16:36:34 cerberus.csd.uwm.edu kernel: kauditd_printk_skb: 12 callbacks suppressed
Dec 19 16:36:34 cerberus.csd.uwm.edu kernel: audit: type=1400 audit(1513722994.739:100): avc:  denied  { read } for  pid=940 comm="systemd-journal" name="invocation:systemd-udevd.service" dev="tmpfs" ino=18752 scontext=system_u:system_r:syslogd_t:s0 tcontext=system_u:object_r:init_var_run_t:s0 tclass=lnk_file permissive=0
Dec 19 16:36:34 cerberus.csd.uwm.edu kernel: audit: type=1300 audit(1513722994.739:100): arch=c000003e syscall=267 success=no exit=-13 a0=ffffff9c a1=7ffe5fcf3d40 a2=55f87d34f090 a3=63 items=0 ppid=1 pid=940 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="systemd-journal" exe="/usr/lib/systemd/systemd-journald" subj=system_u:system_r:syslogd_t:s0 key=(null)
Dec 19 16:36:34 cerberus.csd.uwm.edu kernel: audit: type=1327 audit(1513722994.739:100): proctitle="/usr/lib/systemd/systemd-journald"
Dec 19 16:36:35 cerberus.csd.uwm.edu kernel: audit: type=1400 audit(1513722995.739:101): avc:  denied  { read } for  pid=940 comm="systemd-journal" name="invocation:systemd-udevd.service" dev="tmpfs" ino=18752 scontext=system_u:system_r:syslogd_t:s0 tcontext=system_u:object_r:init_var_run_t:s0 tclass=lnk_file permissive=0
Dec 19 16:36:35 cerberus.csd.uwm.edu kernel: audit: type=1300 audit(1513722995.739:101): arch=c000003e syscall=267 success=no exit=-13 a0=ffffff9c a1=7ffe5fcf3d40 a2=55f87d3502f0 a3=63 items=0 ppid=1 pid=940 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="systemd-journal" exe="/usr/lib/systemd/systemd-journald" subj=system_u:system_r:syslogd_t:s0 key=(null)
Dec 19 16:36:35 cerberus.csd.uwm.edu kernel: audit: type=1327 audit(1513722995.739:101): proctitle="/usr/lib/systemd/systemd-journald"
Dec 19 16:36:36 cerberus.csd.uwm.edu kernel: audit: type=1400 audit(1513722996.739:102): avc:  denied  { read } for  pid=940 comm="systemd-journal" name="invocation:systemd-udevd.service" dev="tmpfs" ino=18752 scontext=system_u:system_r:syslogd_t:s0 tcontext=system_u:object_r:init_var_run_t:s0 tclass=lnk_file permissive=0
Dec 19 16:36:36 cerberus.csd.uwm.edu kernel: audit: type=1300 audit(1513722996.739:102): arch=c000003e syscall=267 success=no exit=-13 a0=ffffff9c a1=7ffe5fcf3d40 a2=55f87d34f090 a3=63 items=0 ppid=1 pid=940 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="systemd-journal" exe="/usr/lib/systemd/systemd-journald" subj=system_u:system_r:syslogd_t:s0 key=(null)
Dec 19 16:36:36 cerberus.csd.uwm.edu kernel: audit: type=1327 audit(1513722996.739:102): proctitle="/usr/lib/systemd/systemd-journald"
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: INFO: rcu_sched self-detected stall on CPU
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: INFO: rcu_sched detected stalls on CPUs/tasks:
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:         1-....: (64778 ticks this GP) idle=93e/140000000000001/0 softirq=9720/9729 fqs=15883 
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:         (detected by 2, t=65002 jiffies, g=3429, c=3428, q=15885)
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: Sending NMI from CPU 2 to CPUs 1:
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: NMI backtrace for cpu 1
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: CPU: 1 PID: 976 Comm: systemd-udevd Tainted: G      D W    L   4.15.0-rc4+ #20
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: Hardware name: Dell Inc. Precision Tower 5810/0WR1RF, BIOS A07 04/14/2015
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: RIP: 0010:cfb_imageblit+0x474/0x4e0
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: RSP: 0018:ffff8de6bf003a10 EFLAGS: 00000046
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: RAX: 0000000000000000 RBX: ffffffffa0a9c980 RCX: 0000000000000007
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: RDX: ffffacac85ebb660 RSI: ffff8de6a6292682 RDI: 0000000000000000
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: RBP: ffffacac85ebb664 R08: 0000000000000001 R09: 0000000000aaaaaa
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: R10: 0000000000000001 R11: 0000000000000000 R12: ffffacac85ebb920
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: R13: 0000000000000720 R14: ffffacac85ebb200 R15: ffff8de6a629265f
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: FS:  00007fa849974dc0(0000) GS:ffff8de6bf000000(0000) knlGS:0000000000000000
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: CR2: 00005588ea479388 CR3: 0000000827c24005 CR4: 00000000001606e0
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: Call Trace:
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  <IRQ>
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  drm_fb_helper_cfb_imageblit+0x12/0x30 [drm_kms_helper]
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  bit_putcs+0x2ba/0x4c0
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  ? bit_clear+0x110/0x110
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  fbcon_putcs+0xf8/0x130
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  fbcon_redraw.isra.20+0xe0/0x1c0
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  fbcon_scroll+0x480/0xca0
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  con_scroll+0x6f/0xf0
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  lf+0x9e/0xb0
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  vt_console_print+0x315/0x420
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  console_unlock+0x366/0x570
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  vprintk_emit+0x244/0x380
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  printk+0x52/0x6e
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  rcu_check_callbacks+0x5a9/0xad0
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  ? tick_sched_do_timer+0x60/0x60
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  update_process_times+0x28/0x50
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  tick_sched_handle+0x22/0x70
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  tick_sched_timer+0x34/0x70
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  __hrtimer_run_queues+0xf1/0x4a0
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  hrtimer_interrupt+0xbd/0x230
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  smp_apic_timer_interrupt+0x6d/0x290
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  apic_timer_interrupt+0xa0/0xb0
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  </IRQ>
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: RIP: 0010:queued_spin_lock_slowpath+0x163/0x1a0
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: RSP: 0018:ffffacac84203cd0 EFLAGS: 00000202 ORIG_RAX: ffffffffffffff11
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: RAX: 0000000000100101 RBX: ffffffffa1224f60 RCX: 0000000000000001
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: RDX: 0000000000000101 RSI: 0000000000000001 RDI: ffffffffa1224f60
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: RBP: ffffffffa1224f60 R08: 0000000000000101 R09: 0000000000000000
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: R10: ffffacac84203c78 R11: 0000000000000000 R12: 0000000000000001
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: R13: ffff8de6a4775c38 R14: 0000000000000000 R15: ffffacac84203e98
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  do_raw_spin_lock+0xad/0xb0
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  _raw_spin_lock+0x52/0x70
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  sysfs_do_create_link_sd.isra.2+0x33/0xc0
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  load_module+0x2678/0x2c90
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  ? vfs_read+0x127/0x150
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  ? SYSC_finit_module+0xe9/0x110
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  SYSC_finit_module+0xe9/0x110
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  do_syscall_64+0x66/0x210
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  entry_SYSCALL64_slow_path+0x25/0x25
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: RIP: 0033:0x7fa84931f339
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: RSP: 002b:00007ffda5a85968 EFLAGS: 00000246 ORIG_RAX: 0000000000000139
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: RAX: ffffffffffffffda RBX: 000055813a541d50 RCX: 00007fa84931f339
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: RDX: 0000000000000000 RSI: 00007fa848bd7da5 RDI: 0000000000000007
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: RBP: 00007fa848bd7da5 R08: 0000000000000000 R09: 00007ffda5a85a90
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: R10: 0000000000000007 R11: 0000000000000246 R12: 0000000000000000
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: R13: 000055813a528800 R14: 0000000000020000 R15: 0000558138cf278c
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: Code: 4f 8d 24 2e 4c 89 f2 4c 89 fe b9 08 00 00 00 44 89 1c 24 eb 2d 0f be 06 44 29 c1 48 8d 6a 04 d3 f8 44 21 d0 44 8b 1c 83 45 21 cb <44> 89 d8 31 f8 89 02 85 c9 75 09 48 83 c6 01 b9 08 00 00 00 48 
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:         1-....: (64778 ticks this GP) idle=93e/140000000000001/0 softirq=9720/9729 fqs=15904 
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:          (t=65090 jiffies g=3429 c=3428 q=15885)
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: NMI backtrace for cpu 1
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: CPU: 1 PID: 976 Comm: systemd-udevd Tainted: G      D W    L   4.15.0-rc4+ #20
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: Hardware name: Dell Inc. Precision Tower 5810/0WR1RF, BIOS A07 04/14/2015
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: Call Trace:
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  <IRQ>
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  dump_stack+0x85/0xbf
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  nmi_cpu_backtrace+0xb3/0xc0
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  ? lapic_can_unplug_cpu+0xa0/0xa0
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  nmi_trigger_cpumask_backtrace+0xe7/0x120
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  rcu_dump_cpu_stacks+0xa7/0xe4
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  rcu_check_callbacks+0x877/0xad0
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  ? tick_sched_do_timer+0x60/0x60
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  update_process_times+0x28/0x50
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  tick_sched_handle+0x22/0x70
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  tick_sched_timer+0x34/0x70
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  __hrtimer_run_queues+0xf1/0x4a0
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  hrtimer_interrupt+0xbd/0x230
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  smp_apic_timer_interrupt+0x6d/0x290
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  apic_timer_interrupt+0xa0/0xb0
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  </IRQ>
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: RIP: 0010:queued_spin_lock_slowpath+0x163/0x1a0
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: RSP: 0018:ffffacac84203cd0 EFLAGS: 00000202 ORIG_RAX: ffffffffffffff11
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: RAX: 0000000000100101 RBX: ffffffffa1224f60 RCX: 0000000000000001
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: RDX: 0000000000000101 RSI: 0000000000000001 RDI: ffffffffa1224f60
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: RBP: ffffffffa1224f60 R08: 0000000000000101 R09: 0000000000000000
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: R10: ffffacac84203c78 R11: 0000000000000000 R12: 0000000000000001
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: R13: ffff8de6a4775c38 R14: 0000000000000000 R15: ffffacac84203e98
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  do_raw_spin_lock+0xad/0xb0
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  _raw_spin_lock+0x52/0x70
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  sysfs_do_create_link_sd.isra.2+0x33/0xc0
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  load_module+0x2678/0x2c90
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  ? vfs_read+0x127/0x150
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  ? SYSC_finit_module+0xe9/0x110
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  SYSC_finit_module+0xe9/0x110
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  do_syscall_64+0x66/0x210
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel:  entry_SYSCALL64_slow_path+0x25/0x25
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: RIP: 0033:0x7fa84931f339
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: RSP: 002b:00007ffda5a85968 EFLAGS: 00000246 ORIG_RAX: 0000000000000139
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: RAX: ffffffffffffffda RBX: 000055813a541d50 RCX: 00007fa84931f339
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: RDX: 0000000000000000 RSI: 00007fa848bd7da5 RDI: 0000000000000007
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: RBP: 00007fa848bd7da5 R08: 0000000000000000 R09: 00007ffda5a85a90
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: R10: 0000000000000007 R11: 0000000000000246 R12: 0000000000000000
Dec 19 16:36:40 cerberus.csd.uwm.edu kernel: R13: 000055813a528800 R14: 0000000000020000 R15: 0000558138cf278c
Dec 19 16:36:59 cerberus.csd.uwm.edu kernel: watchdog: BUG: soft lockup - CPU#3 stuck for 23s! [systemd-modules:1072]

--zYM0uCDKw75PZbzx--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
