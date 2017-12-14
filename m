Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id A467B6B025F
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 10:44:40 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id h200so9150838itb.3
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 07:44:40 -0800 (PST)
Received: from wolff.to (wolff.to. [98.103.208.27])
        by mx.google.com with SMTP id y81si3372935ita.90.2017.12.14.07.44.38
        for <linux-mm@kvack.org>;
        Thu, 14 Dec 2017 07:44:39 -0800 (PST)
Date: Thu, 14 Dec 2017 09:41:36 -0600
From: Bruno Wolff III <bruno@wolff.to>
Subject: Re: Regression with a0747a859ef6 ("bdi: add error handle for
 bdi_debug_register")
Message-ID: <20171214154136.GA12936@wolff.to>
References: <b1415a6d-fccd-31d0-ffa2-9b54fa699692@redhat.com>
 <20171214082452.GA16698@wolff.to>
 <20171214100927.GA26167@localhost.didichuxing.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="fdj2RfSjLxBAspz7"
Content-Disposition: inline
In-Reply-To: <20171214100927.GA26167@localhost.didichuxing.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, regressions@leemhuis.info, linux-block@vger.kernel.org


--fdj2RfSjLxBAspz7
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline

On Thu, Dec 14, 2017 at 18:09:27 +0800,
  weiping zhang <zhangweiping@didichuxing.com> wrote:
>
>It seems something wrong with bdi debugfs register, could you help
>test the forllowing debug patch, I add some debug log, no function
>change, thanks.

I applied your patch to d39a01eff9af1045f6e30ff9db40310517c4b45f and there 
were some new debug messages in the dmesg output. Hopefully this helps. I 
also added the patch and output to the Fedora bug for people following there.

--fdj2RfSjLxBAspz7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="boot1.log"

-- Logs begin at Thu 2017-09-28 16:17:29 CDT, end at Thu 2017-12-14 09:36:50 CST. --
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: microcode: microcode updated early to revision 0x3a, date = 2017-01-30
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Linux version 4.15.0-rc3+ (bruno@cerberus.csd.uwm.edu) (gcc version 7.2.1 20170915 (Red Hat 7.2.1-4) (GCC)) #15 SMP Thu Dec 14 09:07:46 CST 2017
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Command line: BOOT_IMAGE=/vmlinuz-4.15.0-rc3+ root=/dev/mapper/luks-f5e2d09b-f8a3-487d-9517-abe4fb0eada3 ro rd.md.uuid=7f4fcca0:13b1445f:a91ff455:6bb1ab48 rd.luks.uuid=luks-cc6ee93c-e729-4f78-9baf-0cc5cc8a9ff1 rd.md.uuid=ef18531c:760102fb:7797cbdb:5cf9516f rd.md.uuid=42efe386:0c315f28:f7c61920:ea098f81 rd.luks.uuid=luks-f5e2d09b-f8a3-487d-9517-abe4fb0eada3 LANG=en_US.UTF-8
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: x86/fpu: Supporting XSAVE feature 0x001: 'x87 floating point registers'
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: x86/fpu: Supporting XSAVE feature 0x002: 'SSE registers'
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: x86/fpu: Supporting XSAVE feature 0x004: 'AVX registers'
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: x86/fpu: xstate_offset[2]:  576, xstate_sizes[2]:  256
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: x86/fpu: Enabled xstate features 0x7, context size is 832 bytes, using 'standard' format.
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: e820: BIOS-provided physical RAM map:
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: BIOS-e820: [mem 0x0000000000000000-0x000000000009e7ff] usable
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: BIOS-e820: [mem 0x000000000009e800-0x000000000009ffff] reserved
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] reserved
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: BIOS-e820: [mem 0x0000000000100000-0x00000000998f1fff] usable
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: BIOS-e820: [mem 0x00000000998f2000-0x000000009a29dfff] reserved
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: BIOS-e820: [mem 0x000000009a29e000-0x000000009a2e6fff] ACPI data
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: BIOS-e820: [mem 0x000000009a2e7000-0x000000009af43fff] ACPI NVS
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: BIOS-e820: [mem 0x000000009af44000-0x000000009b40afff] reserved
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: BIOS-e820: [mem 0x000000009b40b000-0x000000009b40bfff] usable
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: BIOS-e820: [mem 0x000000009b40c000-0x000000009b419fff] reserved
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: BIOS-e820: [mem 0x000000009b41a000-0x000000009cffffff] usable
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: BIOS-e820: [mem 0x00000000a0000000-0x00000000afffffff] reserved
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: BIOS-e820: [mem 0x00000000fed1c000-0x00000000fed1ffff] reserved
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: BIOS-e820: [mem 0x00000000ff000000-0x00000000ffffffff] reserved
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: BIOS-e820: [mem 0x0000000100000000-0x000000085fffffff] usable
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: NX (Execute Disable) protection: active
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: random: fast init done
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: SMBIOS 2.8 present.
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: DMI: Dell Inc. Precision Tower 5810/0WR1RF, BIOS A07 04/14/2015
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: e820: remove [mem 0x000a0000-0x000fffff] usable
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: e820: last_pfn = 0x860000 max_arch_pfn = 0x400000000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: MTRR default type: write-back
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: MTRR fixed ranges enabled:
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel:   00000-9FFFF write-back
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel:   A0000-BFFFF uncachable
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel:   C0000-E3FFF write-through
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel:   E4000-FFFFF write-protect
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: MTRR variable ranges enabled:
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel:   0 base 0000C0000000 mask 3FFFC0000000 uncachable
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel:   1 base 0000A0000000 mask 3FFFE0000000 uncachable
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel:   2 base 030000000000 mask 3FC000000000 uncachable
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel:   3 base 00009E000000 mask 3FFFFE000000 uncachable
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel:   4 base 0000E0000000 mask 3FFFF0000000 write-through
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel:   5 disabled
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel:   6 disabled
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel:   7 disabled
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel:   8 disabled
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel:   9 disabled
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WP  UC- WT  
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: e820: last_pfn = 0x9d000 max_arch_pfn = 0x400000000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: found SMP MP-table at [mem 0x000fdb30-0x000fdb3f] mapped at [        (ptrval)]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Base memory trampoline at [        (ptrval)] 98000 size 24576
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Using GB pages for direct mapping
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: BRK [0x12c613000, 0x12c613fff] PGTABLE
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: BRK [0x12c614000, 0x12c614fff] PGTABLE
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: BRK [0x12c615000, 0x12c615fff] PGTABLE
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: BRK [0x12c616000, 0x12c616fff] PGTABLE
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: BRK [0x12c617000, 0x12c617fff] PGTABLE
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: BRK [0x12c618000, 0x12c618fff] PGTABLE
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: BRK [0x12c619000, 0x12c619fff] PGTABLE
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: BRK [0x12c61a000, 0x12c61afff] PGTABLE
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: BRK [0x12c61b000, 0x12c61bfff] PGTABLE
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: RAMDISK: [mem 0x2ed96000-0x336c2fff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: Early table checksum verification disabled
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: RSDP 0x00000000000F0540 000024 (v02 DELL  )
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: XSDT 0x000000009A2AC088 00008C (v01 DELL   CBX3     01072009 AMI  00010013)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: FACP 0x000000009A2D86E8 00010C (v05 DELL   CBX3     01072009 AMI  00010013)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: DSDT 0x000000009A2AC1A0 02C544 (v02 DELL   CBX3     01072009 INTL 20091013)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: FACS 0x000000009AF42F80 000040
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: APIC 0x000000009A2D87F8 000090 (v03 DELL   CBX3     01072009 AMI  00010013)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: FPDT 0x000000009A2D8888 000044 (v01 DELL   CBX3     01072009 AMI  00010013)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: FIDT 0x000000009A2D88D0 00009C (v01 DELL   CBX3     01072009 AMI  00010013)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: MCFG 0x000000009A2D8970 00003C (v01 DELL   CBX3     01072009 MSFT 00000097)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: UEFI 0x000000009A2D89B0 000042 (v01 INTEL  EDK2     00000002      01000013)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: BDAT 0x000000009A2D89F8 000030 (v01 DELL   CBX3     00000000 INTL 20091013)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: HPET 0x000000009A2D8A28 000038 (v01 DELL   CBX3     00000001 INTL 20091013)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: PMCT 0x000000009A2D8A60 000064 (v01 DELL   CBX3     00000000 INTL 20091013)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: WDDT 0x000000009A2D8AC8 000040 (v01 DELL   CBX3     00000000 INTL 20091013)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: SSDT 0x000000009A2D8B08 00D647 (v01 DELL   PmMgt    00000001 INTL 20120913)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: DMAR 0x000000009A2E6150 0000F4 (v01 DELL   CBX3     00000001 INTL 20091013)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: ASF! 0x000000009A2E6248 0000A0 (v32 INTEL   HCG     00000001 TFSM 000F4240)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: Local APIC address 0xfee00000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: No NUMA configuration found
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Faking a node at [mem 0x0000000000000000-0x000000085fffffff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: NODE_DATA(0) allocated [mem 0x85ffd5000-0x85fffffff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: tsc: Fast TSC calibration using PIT
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Zone ranges:
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel:   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel:   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel:   Normal   [mem 0x0000000100000000-0x000000085fffffff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel:   Device   empty
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Movable zone start for each node
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Early memory node ranges
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel:   node   0: [mem 0x0000000000001000-0x000000000009dfff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel:   node   0: [mem 0x0000000000100000-0x00000000998f1fff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel:   node   0: [mem 0x000000009b40b000-0x000000009b40bfff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel:   node   0: [mem 0x000000009b41a000-0x000000009cffffff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel:   node   0: [mem 0x0000000100000000-0x000000085fffffff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Initmem setup node 0 [mem 0x0000000000001000-0x000000085fffffff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: On node 0 totalpages: 8369270
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel:   DMA zone: 64 pages used for memmap
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel:   DMA zone: 21 pages reserved
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel:   DMA zone: 3997 pages, LIFO batch:0
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel:   DMA32 zone: 9876 pages used for memmap
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel:   DMA32 zone: 632025 pages, LIFO batch:31
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel:   Normal zone: 120832 pages used for memmap
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel:   Normal zone: 7733248 pages, LIFO batch:31
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Reserved but unavailable: 99 pages
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: PM-Timer IO Port: 0x408
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: Local APIC address 0xfee00000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: LAPIC_NMI (acpi_id[0x02] high edge lint[0x1])
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: LAPIC_NMI (acpi_id[0x04] high edge lint[0x1])
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: LAPIC_NMI (acpi_id[0x06] high edge lint[0x1])
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: IOAPIC[0]: apic_id 8, version 32, address 0xfec00000, GSI 0-23
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: IOAPIC[1]: apic_id 9, version 32, address 0xfec01000, GSI 24-47
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: IRQ0 used by override.
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: IRQ9 used by override.
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Using ACPI (MADT) for SMP configuration information
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: HPET id: 0x8086a701 base: 0xfed00000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: smpboot: Allowing 4 CPUs, 0 hotplug CPUs
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: PM: Registered nosave memory: [mem 0x00000000-0x00000fff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: PM: Registered nosave memory: [mem 0x0009e000-0x0009efff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: PM: Registered nosave memory: [mem 0x0009f000-0x0009ffff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: PM: Registered nosave memory: [mem 0x000a0000-0x000dffff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: PM: Registered nosave memory: [mem 0x000e0000-0x000fffff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: PM: Registered nosave memory: [mem 0x998f2000-0x9a29dfff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: PM: Registered nosave memory: [mem 0x9a29e000-0x9a2e6fff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: PM: Registered nosave memory: [mem 0x9a2e7000-0x9af43fff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: PM: Registered nosave memory: [mem 0x9af44000-0x9b40afff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: PM: Registered nosave memory: [mem 0x9b40c000-0x9b419fff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: PM: Registered nosave memory: [mem 0x9d000000-0x9fffffff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: PM: Registered nosave memory: [mem 0xa0000000-0xafffffff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: PM: Registered nosave memory: [mem 0xb0000000-0xfed1bfff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: PM: Registered nosave memory: [mem 0xfed1c000-0xfed1ffff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: PM: Registered nosave memory: [mem 0xfed20000-0xfeffffff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: PM: Registered nosave memory: [mem 0xff000000-0xffffffff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: e820: [mem 0xb0000000-0xfed1bfff] available for PCI devices
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Booting paravirtualized kernel on bare hardware
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 1910969940391419 ns
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: setup_percpu: NR_CPUS:64 nr_cpumask_bits:64 nr_cpu_ids:4 nr_node_ids:1
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: percpu: Embedded 38 pages/cpu @        (ptrval) s118784 r8192 d28672 u524288
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pcpu-alloc: s118784 r8192 d28672 u524288 alloc=1*2097152
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pcpu-alloc: [0] 0 1 2 3 
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Built 1 zonelists, mobility grouping on.  Total pages: 8238477
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Policy zone: Normal
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Kernel command line: BOOT_IMAGE=/vmlinuz-4.15.0-rc3+ root=/dev/mapper/luks-f5e2d09b-f8a3-487d-9517-abe4fb0eada3 ro rd.md.uuid=7f4fcca0:13b1445f:a91ff455:6bb1ab48 rd.luks.uuid=luks-cc6ee93c-e729-4f78-9baf-0cc5cc8a9ff1 rd.md.uuid=ef18531c:760102fb:7797cbdb:5cf9516f rd.md.uuid=42efe386:0c315f28:f7c61920:ea098f81 rd.luks.uuid=luks-f5e2d09b-f8a3-487d-9517-abe4fb0eada3 LANG=en_US.UTF-8
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Memory: 32788320K/33477080K available (8766K kernel code, 1438K rwdata, 3740K rodata, 2032K init, 1288K bss, 688760K reserved, 0K cma-reserved)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=4, Nodes=1
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ftrace: allocating 35741 entries in 140 pages
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Hierarchical RCU implementation.
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel:         RCU restricting CPUs from NR_CPUS=64 to nr_cpu_ids=4.
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel:         Tasks RCU enabled.
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: RCU: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=4
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: NR_IRQS: 4352, nr_irqs: 864, preallocated irqs: 16
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel:         Offload RCU callbacks from CPUs: .
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Console: colour VGA+ 80x25
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: console [tty0] enabled
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: Core revision 20170831
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: 2 ACPI AML tables successfully acquired and loaded
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: clocksource: hpet: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 133484882848 ns
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: hpet clockevent registered
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: APIC: Switch to symmetric I/O mode setup
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: DMAR: Host address width 46
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: DMAR: DRHD base: 0x000000fbffd000 flags: 0x0
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: DMAR: dmar0: reg_base_addr fbffd000 ver 1:0 cap d2008c10ef0466 ecap f0205b
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: DMAR: DRHD base: 0x000000fbffc000 flags: 0x1
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: DMAR: dmar1: reg_base_addr fbffc000 ver 1:0 cap d2078c106f0466 ecap f020df
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: DMAR: RMRR base: 0x0000009b280000 end: 0x0000009b28efff
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: DMAR: ATSR flags: 0x0
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: DMAR: RHSA base: 0x000000fbffc000 proximity domain: 0x0
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: DMAR-IR: IOAPIC id 8 under DRHD base  0xfbffc000 IOMMU 1
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: DMAR-IR: IOAPIC id 9 under DRHD base  0xfbffc000 IOMMU 1
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: DMAR-IR: HPET id 0 under DRHD base 0xfbffc000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: DMAR-IR: x2apic is disabled because BIOS sets x2apic opt out bit.
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: DMAR-IR: Use 'intremap=no_x2apic_optout' to override the BIOS setting.
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: DMAR-IR: Enabled IRQ remapping in xapic mode
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: x2apic: IRQ remapping doesn't support X2APIC mode
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: tsc: Fast TSC calibration using PIT
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: tsc: Detected 2793.479 MHz processor
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: [Firmware Bug]: TSC ADJUST: CPU0: -175217120142316 force to 0
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Calibrating delay loop (skipped), value calculated using timer frequency.. 5586.95 BogoMIPS (lpj=2793479)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pid_max: default: 32768 minimum: 301
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Security Framework initialized
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Yama: becoming mindful.
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: SELinux:  Initializing.
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: SELinux:  Starting in permissive mode
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Dentry cache hash table entries: 4194304 (order: 13, 33554432 bytes)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Inode-cache hash table entries: 2097152 (order: 12, 16777216 bytes)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Mount-cache hash table entries: 65536 (order: 7, 524288 bytes)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Mountpoint-cache hash table entries: 65536 (order: 7, 524288 bytes)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: CPU: Physical Processor ID: 0
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: CPU: Processor Core ID: 0
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: mce: CPU supports 22 MCE banks
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: CPU0: Thermal monitoring enabled (TM1)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: process: using mwait in idle threads
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Last level iTLB entries: 4KB 1024, 2MB 1024, 4MB 1024
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Last level dTLB entries: 4KB 1024, 2MB 1024, 4MB 1024, 1GB 4
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Freeing SMP alternatives memory: 36K
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: TSC deadline timer enabled
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: smpboot: CPU0: Intel(R) Xeon(R) CPU E5-1603 v3 @ 2.80GHz (family: 0x6, model: 0x3f, stepping: 0x2)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Performance Events: PEBS fmt2+, Haswell events, 16-deep LBR, full-width counters, Intel PMU driver.
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ... version:                3
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ... bit width:              48
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ... generic registers:      8
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ... value mask:             0000ffffffffffff
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ... max period:             00007fffffffffff
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ... fixed-purpose events:   3
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ... event mask:             00000007000000ff
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Hierarchical SRCU implementation.
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: NMI watchdog: Enabled. Permanently consumes one hw-PMU counter.
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: smp: Bringing up secondary CPUs ...
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: x86: Booting SMP configuration:
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: .... node  #0, CPUs:      #1
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: [Firmware Bug]: TSC ADJUST differs within socket(s), fixing all errors
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel:  #2 #3
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: smp: Brought up 1 node, 4 CPUs
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: smpboot: Max logical packages: 1
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: smpboot: Total of 4 processors activated (22347.83 BogoMIPS)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: devtmpfs: initialized
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: x86/mm: Memory block size: 128MB
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: PM: Registering ACPI NVS region [mem 0x9a2e7000-0x9af43fff] (12963840 bytes)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 1911260446275000 ns
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: futex hash table entries: 1024 (order: 4, 65536 bytes)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pinctrl core: initialized pinctrl subsystem
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: RTC time: 15:17:41, date: 12/14/17
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: NET: Registered protocol family 16
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: audit: initializing netlink subsys (disabled)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: audit: type=2000 audit(1513264661.033:1): state=initialized audit_enabled=0 res=1
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: DEBUG:bdi_debug_root success
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: cpuidle: using governor menu
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI FADT declares the system doesn't support PCIe ASPM, so disable it
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: bus type PCI registered
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0xa0000000-0xafffffff] (base 0xa0000000)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: PCI: MMCONFIG at [mem 0xa0000000-0xafffffff] reserved in E820
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: PCI: Using configuration type 1 for base access
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: core: PMU erratum BJ122, BV98, HSD29 workaround disabled, HT off
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: HugeTLB registered 1.00 GiB page size, pre-allocated 0 pages
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: HugeTLB registered 2.00 MiB page size, pre-allocated 0 pages
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: Added _OSI(Module Device)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: Added _OSI(Processor Device)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: Added _OSI(3.0 _SCP Extensions)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: Added _OSI(Processor Aggregator Device)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: [Firmware Bug]: BIOS _OSI(Linux) query ignored
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: Interpreter enabled
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: (supports S0 S4 S5)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: Using IOAPIC for interrupt routing
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: Enabled 5 GPEs in block 00 to 3F
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: PCI Root Bridge [UNC0] (domain 0000 [bus ff])
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: acpi PNP0A03:03: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: acpi PNP0A03:03: _OSC: OS now controls [PCIeHotplug PME AER PCIeCapability]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: acpi PNP0A03:03: FADT indicates ASPM is unsupported, using BIOS configuration
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: PCI host bridge to bus 0000:ff
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci_bus 0000:ff: root bus resource [bus ff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:0b.0: [8086:2f81] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:0b.1: [8086:2f36] type 00 class 0x110100
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:0b.2: [8086:2f37] type 00 class 0x110100
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:0c.0: [8086:2fe0] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:0c.1: [8086:2fe1] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:0c.2: [8086:2fe2] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:0c.3: [8086:2fe3] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:0f.0: [8086:2ff8] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:0f.1: [8086:2ff9] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:0f.4: [8086:2ffc] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:0f.5: [8086:2ffd] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:0f.6: [8086:2ffe] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:10.0: [8086:2f1d] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:10.1: [8086:2f34] type 00 class 0x110100
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:10.5: [8086:2f1e] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:10.6: [8086:2f7d] type 00 class 0x110100
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:10.7: [8086:2f1f] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:12.0: [8086:2fa0] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:12.1: [8086:2f30] type 00 class 0x110100
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:13.0: [8086:2fa8] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:13.1: [8086:2f71] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:13.2: [8086:2faa] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:13.3: [8086:2fab] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:13.4: [8086:2fac] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:13.5: [8086:2fad] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:13.6: [8086:2fae] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:13.7: [8086:2faf] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:14.0: [8086:2fb0] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:14.1: [8086:2fb1] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:14.2: [8086:2fb2] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:14.3: [8086:2fb3] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:14.6: [8086:2fbe] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:14.7: [8086:2fbf] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:15.0: [8086:2fb4] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:15.1: [8086:2fb5] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:15.2: [8086:2fb6] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:15.3: [8086:2fb7] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:16.0: [8086:2f68] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:16.6: [8086:2f6e] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:16.7: [8086:2f6f] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:17.0: [8086:2fd0] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:17.4: [8086:2fb8] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:17.5: [8086:2fb9] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:17.6: [8086:2fba] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:17.7: [8086:2fbb] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:1e.0: [8086:2f98] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:1e.1: [8086:2f99] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:1e.2: [8086:2f9a] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:1e.3: [8086:2fc0] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:1e.4: [8086:2f9c] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:1f.0: [8086:2f88] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:ff:1f.2: [8086:2f8a] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-fe])
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: acpi PNP0A08:00: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: acpi PNP0A08:00: _OSC: platform does not support [PCIeHotplug PME AER PCIeCapability]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: acpi PNP0A08:00: _OSC: not requesting control; platform does not support [PCIeCapability]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: acpi PNP0A08:00: _OSC: OS requested [PCIeHotplug PME AER PCIeCapability]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: acpi PNP0A08:00: _OSC: platform willing to grant []
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: acpi PNP0A08:00: _OSC failed (AE_SUPPORT); disabling ASPM
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: PCI host bridge to bus 0000:00
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci_bus 0000:00: root bus resource [io  0x0000-0x03af window]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci_bus 0000:00: root bus resource [io  0x03e0-0x0cf7 window]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci_bus 0000:00: root bus resource [io  0x03b0-0x03df window]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci_bus 0000:00: root bus resource [io  0x1000-0xffff window]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff window]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci_bus 0000:00: root bus resource [mem 0xb0000000-0xfbffbfff window]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci_bus 0000:00: root bus resource [mem 0x30000000000-0x33fffffffff window]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci_bus 0000:00: root bus resource [bus 00-fe]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:00.0: [8086:2f00] type 00 class 0x060000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:01.0: [8086:2f02] type 01 class 0x060400
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:01.1: [8086:2f03] type 01 class 0x060400
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:01.1: PME# supported from D0 D3hot D3cold
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:02.0: [8086:2f04] type 01 class 0x060400
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:02.0: PME# supported from D0 D3hot D3cold
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:03.0: [8086:2f08] type 01 class 0x060400
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:03.0: PME# supported from D0 D3hot D3cold
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:03.1: [8086:2f09] type 01 class 0x060400
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:03.1: PME# supported from D0 D3hot D3cold
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:03.2: [8086:2f0a] type 01 class 0x060400
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:03.2: PME# supported from D0 D3hot D3cold
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:03.3: [8086:2f0b] type 01 class 0x060400
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:03.3: PME# supported from D0 D3hot D3cold
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:05.0: [8086:2f28] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:05.1: [8086:2f29] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:05.2: [8086:2f2a] type 00 class 0x088000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:05.4: [8086:2f2c] type 00 class 0x080020
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:05.4: reg 0x10: [mem 0xfbf36000-0xfbf36fff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:11.0: [8086:8d7c] type 00 class 0xff0000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:11.4: [8086:8d62] type 00 class 0x010601
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:11.4: reg 0x10: [io  0xf130-0xf137]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:11.4: reg 0x14: [io  0xf120-0xf123]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:11.4: reg 0x18: [io  0xf110-0xf117]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:11.4: reg 0x1c: [io  0xf100-0xf103]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:11.4: reg 0x20: [io  0xf040-0xf05f]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:11.4: reg 0x24: [mem 0xfbf35000-0xfbf357ff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:11.4: PME# supported from D3hot
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:14.0: [8086:8d31] type 00 class 0x0c0330
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:14.0: reg 0x10: [mem 0xfbf20000-0xfbf2ffff 64bit]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:14.0: PME# supported from D3hot D3cold
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:16.0: [8086:8d3a] type 00 class 0x078000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:16.0: reg 0x10: [mem 0x33ffff07000-0x33ffff0700f 64bit]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:16.0: PME# supported from D0 D3hot D3cold
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:19.0: [8086:153a] type 00 class 0x020000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:19.0: reg 0x10: [mem 0xfbf00000-0xfbf1ffff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:19.0: reg 0x14: [mem 0xfbf33000-0xfbf33fff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:19.0: reg 0x18: [io  0xf020-0xf03f]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:19.0: PME# supported from D0 D3hot D3cold
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:1a.0: [8086:8d2d] type 00 class 0x0c0320
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:1a.0: reg 0x10: [mem 0xfbf32000-0xfbf323ff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:1a.0: PME# supported from D0 D3hot D3cold
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:1b.0: [8086:8d20] type 00 class 0x040300
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:1b.0: reg 0x10: [mem 0x33ffff00000-0x33ffff03fff 64bit]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:1c.0: [8086:8d10] type 01 class 0x060400
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:1c.1: [8086:8d12] type 01 class 0x060400
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:1c.1: PME# supported from D0 D3hot D3cold
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:1d.0: [8086:8d26] type 00 class 0x0c0320
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:1d.0: reg 0x10: [mem 0xfbf31000-0xfbf313ff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:1d.0: PME# supported from D0 D3hot D3cold
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:1f.0: [8086:8d44] type 00 class 0x060100
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:1f.2: [8086:8d02] type 00 class 0x010601
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:1f.2: reg 0x10: [io  0xf090-0xf097]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:1f.2: reg 0x14: [io  0xf080-0xf083]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:1f.2: reg 0x18: [io  0xf070-0xf077]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:1f.2: reg 0x1c: [io  0xf060-0xf063]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:1f.2: reg 0x20: [io  0xf000-0xf01f]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:1f.2: reg 0x24: [mem 0xfbf30000-0xfbf307ff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:1f.2: PME# supported from D3hot
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:1f.3: [8086:8d22] type 00 class 0x0c0500
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:1f.3: reg 0x10: [mem 0x33ffff05000-0x33ffff050ff 64bit]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:1f.3: reg 0x20: [io  0x0580-0x059f]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:01.0: PCI bridge to [bus 01]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:01.1: PCI bridge to [bus 02]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:03:00.0: [1002:6608] type 00 class 0x030000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:03:00.0: reg 0x10: [mem 0xe0000000-0xefffffff 64bit pref]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:03:00.0: reg 0x18: [mem 0xfbe00000-0xfbe3ffff 64bit]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:03:00.0: reg 0x20: [io  0xe000-0xe0ff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:03:00.0: reg 0x30: [mem 0xfbe40000-0xfbe5ffff pref]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:03:00.0: enabling Extended Tags
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:03:00.0: supports D1 D2
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:03:00.0: PME# supported from D1 D2 D3hot
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:03:00.1: [1002:aab0] type 00 class 0x040300
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:03:00.1: reg 0x10: [mem 0xfbe60000-0xfbe63fff 64bit]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:03:00.1: enabling Extended Tags
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:03:00.1: supports D1 D2
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:02.0: PCI bridge to [bus 03]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:02.0:   bridge window [io  0xe000-0xefff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:02.0:   bridge window [mem 0xfbe00000-0xfbefffff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:02.0:   bridge window [mem 0xe0000000-0xefffffff 64bit pref]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:03.0: PCI bridge to [bus 04]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:03.1: PCI bridge to [bus 05]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:03.2: PCI bridge to [bus 06]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:03.3: PCI bridge to [bus 07]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:1c.0: PCI bridge to [bus 08]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:09:00.0: [104c:8240] type 01 class 0x060400
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:09:00.0: supports D1 D2
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:1c.1: PCI bridge to [bus 09-0a]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:09:00.0: PCI bridge to [bus 0a]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci_bus 0000:00: on NUMA node 0
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 10 *11 12 14 15)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 *10 11 12 14 15)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 10 *11 12 14 15)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 *5 6 10 11 12 14 15)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: PCI Interrupt Link [LNKE] (IRQs *3 4 5 6 7 10 11 12 14 15)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 *7 10 11 12 14 15)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:03:00.0: vgaarb: setting as boot VGA device
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:03:00.0: vgaarb: VGA device added: decodes=io+mem,owns=io+mem,locks=none
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:03:00.0: vgaarb: bridge control possible
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: vgaarb: loaded
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: SCSI subsystem initialized
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: libata version 3.00 loaded.
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: bus type USB registered
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: usbcore: registered new interface driver usbfs
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: usbcore: registered new interface driver hub
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: usbcore: registered new device driver usb
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: EDAC MC: Ver: 3.0.0
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: PCI: Using ACPI for IRQ routing
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: PCI: pci_cache_line_size set to 64 bytes
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: e820: reserve RAM buffer [mem 0x0009e800-0x0009ffff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: e820: reserve RAM buffer [mem 0x998f2000-0x9bffffff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: e820: reserve RAM buffer [mem 0x9b40c000-0x9bffffff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: e820: reserve RAM buffer [mem 0x9d000000-0x9fffffff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: NetLabel: Initializing
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: NetLabel:  domain hash size = 128
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: NetLabel:  protocols = UNLABELED CIPSOv4 CALIPSO
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: NetLabel:  unlabeled traffic allowed by default
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0, 0, 0, 0, 0
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: hpet0: 8 comparators, 64-bit 14.318180 MHz counter
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: clocksource: Switched to clocksource hpet
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: VFS: Disk quotas dquot_6.6.0
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: VFS: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pnp: PnP ACPI init
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: system 00:01: [io  0x0500-0x057f] has been reserved
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: system 00:01: [io  0x0400-0x047f] has been reserved
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: system 00:01: [io  0x0580-0x059f] has been reserved
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: system 00:01: [io  0x0600-0x061f] has been reserved
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: system 00:01: [io  0x0880-0x0883] has been reserved
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: system 00:01: [io  0x0800-0x081f] has been reserved
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: system 00:01: [mem 0xfed1c000-0xfed3ffff] could not be reserved
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: system 00:01: [mem 0xfed45000-0xfed8bfff] has been reserved
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: system 00:01: [mem 0xff000000-0xffffffff] has been reserved
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: system 00:01: [mem 0xfee00000-0xfeefffff] has been reserved
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: system 00:01: [mem 0xfed12000-0xfed1200f] has been reserved
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: system 00:01: [mem 0xfed12010-0xfed1201f] has been reserved
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: system 00:01: [mem 0xfed1b000-0xfed1bfff] has been reserved
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: system 00:01: Plug and Play ACPI device, IDs PNP0c02 (active)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: system 00:02: [io  0x0a00-0x0a3f] has been reserved
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: system 00:02: Plug and Play ACPI device, IDs PNP0c02 (active)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pnp 00:03: [dma 0 disabled]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pnp 00:03: Plug and Play ACPI device, IDs PNP0501 (active)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pnp: PnP ACPI: found 4 devices
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, max_idle_ns: 2085701024 ns
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:1c.0: bridge window [io  0x1000-0x0fff] to [bus 08] add_size 1000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:1c.0: bridge window [mem 0x00100000-0x000fffff 64bit pref] to [bus 08] add_size 200000 add_align 100000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:1c.0: bridge window [mem 0x00100000-0x000fffff] to [bus 08] add_size 200000 add_align 100000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:1c.0: BAR 14: assigned [mem 0xb0000000-0xb01fffff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:1c.0: BAR 15: assigned [mem 0x30000000000-0x300001fffff 64bit pref]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:1c.0: BAR 13: assigned [io  0x1000-0x1fff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:01.0: PCI bridge to [bus 01]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:01.1: PCI bridge to [bus 02]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:02.0: PCI bridge to [bus 03]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:02.0:   bridge window [io  0xe000-0xefff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:02.0:   bridge window [mem 0xfbe00000-0xfbefffff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:02.0:   bridge window [mem 0xe0000000-0xefffffff 64bit pref]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:03.0: PCI bridge to [bus 04]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:03.1: PCI bridge to [bus 05]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:03.2: PCI bridge to [bus 06]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:03.3: PCI bridge to [bus 07]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:1c.0: PCI bridge to [bus 08]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:1c.0:   bridge window [io  0x1000-0x1fff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:1c.0:   bridge window [mem 0xb0000000-0xb01fffff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:1c.0:   bridge window [mem 0x30000000000-0x300001fffff 64bit pref]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:09:00.0: PCI bridge to [bus 0a]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:00:1c.1: PCI bridge to [bus 09-0a]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci_bus 0000:00: resource 4 [io  0x0000-0x03af window]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci_bus 0000:00: resource 5 [io  0x03e0-0x0cf7 window]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci_bus 0000:00: resource 6 [io  0x03b0-0x03df window]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci_bus 0000:00: resource 7 [io  0x1000-0xffff window]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci_bus 0000:00: resource 8 [mem 0x000a0000-0x000bffff window]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci_bus 0000:00: resource 9 [mem 0xb0000000-0xfbffbfff window]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci_bus 0000:00: resource 10 [mem 0x30000000000-0x33fffffffff window]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci_bus 0000:03: resource 0 [io  0xe000-0xefff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci_bus 0000:03: resource 1 [mem 0xfbe00000-0xfbefffff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci_bus 0000:03: resource 2 [mem 0xe0000000-0xefffffff 64bit pref]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci_bus 0000:08: resource 0 [io  0x1000-0x1fff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci_bus 0000:08: resource 1 [mem 0xb0000000-0xb01fffff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci_bus 0000:08: resource 2 [mem 0x30000000000-0x300001fffff 64bit pref]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: NET: Registered protocol family 2
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: TCP established hash table entries: 262144 (order: 9, 2097152 bytes)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: TCP: Hash tables configured (established 262144 bind 65536)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: UDP hash table entries: 16384 (order: 7, 524288 bytes)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: UDP-Lite hash table entries: 16384 (order: 7, 524288 bytes)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: NET: Registered protocol family 1
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: pci 0000:03:00.0: Video device with shadowed ROM at [mem 0x000c0000-0x000dffff]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: PCI: CLS 32 bytes, default 64
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Unpacking initramfs...
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Freeing initrd memory: 74932K
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: software IO TLB [mem 0x958f2000-0x998f2000] (64MB) mapped at [00000000b5ed5d44-00000000dc6123f9]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Initialise system trusted keyrings
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Key type blacklist registered
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: workingset: timestamp_bits=36 max_order=23 bucket_order=0
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: zbud: loaded
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: SELinux:  Registering netfilter hooks
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: NET: Registered protocol family 38
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Key type asymmetric registered
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Asymmetric key parser 'x509' registered
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Block layer SCSI generic (bsg) driver version 0.4 loaded (major 247)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: io scheduler noop registered
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: io scheduler deadline registered
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: io scheduler cfq registered (default)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: io scheduler mq-deadline registered
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: atomic64_test: passed for x86-64 platform with CX8 and with SSE
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: intel_idle: MWAIT substates: 0x2120
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: intel_idle: v0.4.1 model 0x3F
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: intel_idle: lapic_timer_reliable_states 0xffffffff
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: input: Power Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0C:00/input/input0
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: Power Button [PWRB]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ACPI: Power Button [PWRF]
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Serial: 8250/16550 driver, 32 ports, IRQ sharing enabled
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: 00:03: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Non-volatile memory driver v1.3
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Linux agpgart interface v0.103
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ahci 0000:00:11.4: version 3.0
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ahci 0000:00:11.4: AHCI 0001.0300 32 slots 4 ports 6 Gbps 0x1 impl SATA mode
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ahci 0000:00:11.4: flags: 64bit ncq pm led clo pio slum part ems apst 
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: scsi host0: ahci
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: scsi host1: ahci
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: scsi host2: ahci
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: scsi host3: ahci
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ata1: SATA max UDMA/133 abar m2048@0xfbf35000 port 0xfbf35100 irq 27
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ata2: DUMMY
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ata3: DUMMY
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ata4: DUMMY
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ahci 0000:00:1f.2: AHCI 0001.0300 32 slots 4 ports 6 Gbps 0x3 impl SATA mode
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ahci 0000:00:1f.2: flags: 64bit ncq pm led clo pio slum part ems apst 
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: scsi host4: ahci
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: scsi host5: ahci
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: scsi host6: ahci
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: scsi host7: ahci
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ata5: SATA max UDMA/133 abar m2048@0xfbf30000 port 0xfbf30100 irq 28
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ata6: SATA max UDMA/133 abar m2048@0xfbf30000 port 0xfbf30180 irq 28
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ata7: DUMMY
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ata8: DUMMY
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: libphy: Fixed MDIO Bus: probed
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ehci-pci: EHCI PCI platform driver
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ehci-pci 0000:00:1a.0: EHCI Host Controller
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ehci-pci 0000:00:1a.0: new USB bus registered, assigned bus number 1
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ehci-pci 0000:00:1a.0: debug port 2
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ehci-pci 0000:00:1a.0: cache line size of 32 is not supported
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ehci-pci 0000:00:1a.0: irq 18, io mem 0xfbf32000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ehci-pci 0000:00:1a.0: USB 2.0 started, EHCI 1.00
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: usb usb1: Product: EHCI Host Controller
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: usb usb1: Manufacturer: Linux 4.15.0-rc3+ ehci_hcd
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: usb usb1: SerialNumber: 0000:00:1a.0
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: hub 1-0:1.0: USB hub found
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: hub 1-0:1.0: 2 ports detected
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ehci-pci 0000:00:1d.0: EHCI Host Controller
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ehci-pci 0000:00:1d.0: new USB bus registered, assigned bus number 2
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ehci-pci 0000:00:1d.0: debug port 2
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ehci-pci 0000:00:1d.0: cache line size of 32 is not supported
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ehci-pci 0000:00:1d.0: irq 18, io mem 0xfbf31000
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ehci-pci 0000:00:1d.0: USB 2.0 started, EHCI 1.00
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: usb usb2: New USB device found, idVendor=1d6b, idProduct=0002
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: usb usb2: Product: EHCI Host Controller
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: usb usb2: Manufacturer: Linux 4.15.0-rc3+ ehci_hcd
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: usb usb2: SerialNumber: 0000:00:1d.0
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: hub 2-0:1.0: USB hub found
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: hub 2-0:1.0: 2 ports detected
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ohci-pci: OHCI PCI platform driver
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: uhci_hcd: USB Universal Host Controller Interface driver
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: xhci_hcd 0000:00:14.0: xHCI Host Controller
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: xhci_hcd 0000:00:14.0: new USB bus registered, assigned bus number 3
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: xhci_hcd 0000:00:14.0: hcc params 0x200077c1 hci version 0x100 quirks 0x00009810
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: xhci_hcd 0000:00:14.0: cache line size of 32 is not supported
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: usb usb3: New USB device found, idVendor=1d6b, idProduct=0002
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: usb usb3: Product: xHCI Host Controller
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: usb usb3: Manufacturer: Linux 4.15.0-rc3+ xhci-hcd
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: usb usb3: SerialNumber: 0000:00:14.0
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: hub 3-0:1.0: USB hub found
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: hub 3-0:1.0: 15 ports detected
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: xhci_hcd 0000:00:14.0: xHCI Host Controller
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: xhci_hcd 0000:00:14.0: new USB bus registered, assigned bus number 4
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: usb usb4: New USB device found, idVendor=1d6b, idProduct=0003
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: usb usb4: Product: xHCI Host Controller
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: usb usb4: Manufacturer: Linux 4.15.0-rc3+ xhci-hcd
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: usb usb4: SerialNumber: 0000:00:14.0
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: hub 4-0:1.0: USB hub found
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: hub 4-0:1.0: 6 ports detected
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: usbcore: registered new interface driver usbserial_generic
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: usbserial: USB Serial support registered for generic
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: i8042: PNP: No PS/2 controller found.
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: mousedev: PS/2 mouse device common for all mice
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: rtc_cmos 00:00: RTC can wake from S4
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: rtc_cmos 00:00: rtc core: registered rtc_cmos as rtc0
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: rtc_cmos 00:00: alarms up to one month, y3k, 114 bytes nvram, hpet irqs
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: device-mapper: uevent: version 1.0.3
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: device-mapper: ioctl: 4.37.0-ioctl (2017-09-20) initialised: dm-devel@redhat.com
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: intel_pstate: Intel P-state driver initializing
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: hidraw: raw HID events driver (C) Jiri Kosina
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: usbcore: registered new interface driver usbhid
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: usbhid: USB HID core driver
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: drop_monitor: Initializing network drop monitor service
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ip_tables: (C) 2000-2006 Netfilter Core Team
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Initializing XFRM netlink socket
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: NET: Registered protocol family 10
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Segment Routing with IPv6
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: mip6: Mobile IPv6
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: NET: Registered protocol family 17
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: intel_rdt: Intel RDT L3 monitoring detected
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: RAS: Correctable Errors collector initialized.
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: microcode: sig=0x306f2, pf=0x1, revision=0x3a
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: microcode: Microcode Update Driver: v2.2.
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: AVX2 version of gcm_enc/dec engaged.
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: AES CTR mode by8 optimization enabled
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: sched_clock: Marking stable (1490247982, 0)->(1499006865, -8758883)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: registered taskstats version 1
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Loading compiled-in X.509 certificates
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Loaded X.509 cert 'Build time autogenerated kernel key: a0edb3ecf58ff4072b22990fa0a188a3a906b7a7'
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: zswap: loaded using pool lzo/zbud
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Key type big_key registered
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Key type encrypted registered
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel:   Magic number: 13:399:285
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: platform PNP0C04:00: hash matches
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: acpi device:1eb: hash matches
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: acpi PNP0C04:00: hash matches
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: rtc_cmos 00:00: setting system clock to 2017-12-14 15:17:43 UTC (1513264663)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ata1: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ata1.00: ATAPI: HL-DT-ST DVD+/-RW GTA0N, A1B0, max UDMA/100
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ata1.00: configured for UDMA/100
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ata6: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ata5: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ata6.00: ATA-9: ST2000DM001-1ER164, CC25, max UDMA/133
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ata6.00: 3907029168 sectors, multi 16: LBA48 NCQ (depth 31/32), AA
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ata5.00: ATA-9: ST2000DM001-1ER164, CC25, max UDMA/133
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ata5.00: 3907029168 sectors, multi 16: LBA48 NCQ (depth 31/32), AA
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ata6.00: configured for UDMA/133
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: ata5.00: configured for UDMA/133
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: scsi 0:0:0:0: CD-ROM            HL-DT-ST DVD+-RW GTA0N    A1B0 PQ: 0 ANSI: 5
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: usb 1-1: new high-speed USB device number 2 using ehci-pci
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: sr 0:0:0:0: [sr0] scsi3-mmc drive: 24x/24x writer dvd-ram cd/rw xa/form2 cdda tray
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: cdrom: Uniform CD-ROM driver Revision: 3.20
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: DEBUG: bdi(0x0000000006007fbc) device_create_vargs sucess
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: DEBUG:dev:11:0, bdi_debug_root success
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: DEBUG:dev:11:0, debug_dir success
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: DEBUG:dev:11:0, debug_stats success
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: DEBUG: dev:11:0, bdi(0x0000000006007fbc) bdi_debug_register success
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: usb 2-1: new high-speed USB device number 2 using ehci-pci
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: sr 0:0:0:0: Attached scsi CD-ROM sr0
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: sr 0:0:0:0: Attached scsi generic sg0 type 5
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: scsi 4:0:0:0: Direct-Access     ATA      ST2000DM001-1ER1 CC25 PQ: 0 ANSI: 5
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: sd 4:0:0:0: Attached scsi generic sg1 type 0
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: sd 4:0:0:0: [sda] 3907029168 512-byte logical blocks: (2.00 TB/1.82 TiB)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: sd 4:0:0:0: [sda] 4096-byte physical blocks
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: sd 4:0:0:0: [sda] Write Protect is off
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: sd 4:0:0:0: [sda] Mode Sense: 00 3a 00 00
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: sd 4:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: DEBUG: bdi(0x00000000412e3d3c) device_create_vargs sucess
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: DEBUG:dev:8:0, bdi_debug_root success
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: DEBUG:dev:8:0, debug_dir success
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: DEBUG:dev:8:0, debug_stats success
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: DEBUG: dev:8:0, bdi(0x00000000412e3d3c) bdi_debug_register success
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: scsi 5:0:0:0: Direct-Access     ATA      ST2000DM001-1ER1 CC25 PQ: 0 ANSI: 5
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: sd 5:0:0:0: Attached scsi generic sg2 type 0
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: sd 5:0:0:0: [sdb] 3907029168 512-byte logical blocks: (2.00 TB/1.82 TiB)
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: sd 5:0:0:0: [sdb] 4096-byte physical blocks
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: sd 5:0:0:0: [sdb] Write Protect is off
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: sd 5:0:0:0: [sdb] Mode Sense: 00 3a 00 00
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: sd 5:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: DEBUG: bdi(0x000000002c532388) device_create_vargs sucess
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: DEBUG:dev:8:16, bdi_debug_root success
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: DEBUG:dev:8:16, debug_dir success
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: DEBUG:dev:8:16, debug_stats success
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: DEBUG: dev:8:16, bdi(0x000000002c532388) bdi_debug_register success
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: usb 3-6: new low-speed USB device number 2 using xhci_hcd
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel:  sda: sda1 sda2 sda3 sda4 < sda5 >
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: sd 4:0:0:0: [sda] Attached SCSI disk
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel:  sdb: sdb1 sdb2 sdb3 sdb4 < sdb5 >
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: sd 5:0:0:0: [sdb] Attached SCSI disk
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Freeing unused kernel memory: 2032K
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Write protecting the kernel read-only data: 14336k
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Freeing unused kernel memory: 1452K
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: Freeing unused kernel memory: 356K
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: x86/mm: Checked W+X mappings: passed, no W+X pages found.
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: rodata_test: all tests were successful
Dec 14 09:17:43 cerberus.csd.uwm.edu systemd[1]: systemd 235 running in system mode. (+PAM +AUDIT +SELINUX +IMA -APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT +GNUTLS +ACL +XZ +LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD -IDN2 +IDN default-hierarchy=hybrid)
Dec 14 09:17:43 cerberus.csd.uwm.edu systemd[1]: Detected architecture x86-64.
Dec 14 09:17:43 cerberus.csd.uwm.edu systemd[1]: Running in initial RAM disk.
Dec 14 09:17:43 cerberus.csd.uwm.edu systemd[1]: Set hostname to <cerberus.csd.uwm.edu>.
Dec 14 09:17:43 cerberus.csd.uwm.edu systemd[1]: Reached target Timers.
Dec 14 09:17:43 cerberus.csd.uwm.edu systemd[1]: Reached target Swap.
Dec 14 09:17:43 cerberus.csd.uwm.edu systemd[1]: Reached target Local File Systems.
Dec 14 09:17:43 cerberus.csd.uwm.edu systemd[1]: Created slice System Slice.
Dec 14 09:17:43 cerberus.csd.uwm.edu systemd[1]: Listening on udev Kernel Socket.
Dec 14 09:17:43 cerberus.csd.uwm.edu systemd[1]: Reached target Slices.
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: usb 1-1: New USB device found, idVendor=8087, idProduct=800a
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: usb 1-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: hub 1-1:1.0: USB hub found
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: hub 1-1:1.0: 6 ports detected
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: audit: type=1130 audit(1513264663.871:2): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-tmpfiles-setup-dev comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: audit: type=1130 audit(1513264663.873:3): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-tmpfiles-setup comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: usb 2-1: New USB device found, idVendor=8087, idProduct=8002
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: usb 2-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: hub 2-1:1.0: USB hub found
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: hub 2-1:1.0: 8 ports detected
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: audit: type=1130 audit(1513264663.910:4): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-journald comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: usb 3-6: New USB device found, idVendor=413c, idProduct=2107
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: usb 3-6: New USB device strings: Mfr=1, Product=2, SerialNumber=0
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: usb 3-6: Product: Dell USB Entry Keyboard
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: usb 3-6: Manufacturer: Dell
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: input: Dell Dell USB Entry Keyboard as /devices/pci0000:00/0000:00:14.0/usb3/3-6/3-6:1.0/0003:413C:2107.0001/input/input2
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: audit: type=1130 audit(1513264663.930:5): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-modules-load comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=failed'
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: audit: type=1130 audit(1513264663.946:6): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-vconsole-setup comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: audit: type=1131 audit(1513264663.946:7): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-vconsole-setup comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: hid-generic 0003:413C:2107.0001: input,hidraw0: USB HID v1.10 Keyboard [Dell Dell USB Entry Keyboard] on usb-0000:00:14.0-6/input0
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: audit: type=1130 audit(1513264663.971:8): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-sysctl comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 14 09:17:43 cerberus.csd.uwm.edu kernel: audit: type=1130 audit(1513264663.980:9): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=dracut-cmdline comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: audit: type=1130 audit(1513264664.019:10): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=dracut-pre-udev comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: usb 3-7: new low-speed USB device number 3 using xhci_hcd
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: usb 3-7: New USB device found, idVendor=046d, idProduct=c077
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: usb 3-7: New USB device strings: Mfr=1, Product=2, SerialNumber=0
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: usb 3-7: Product: USB Optical Mouse
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: usb 3-7: Manufacturer: Logitech
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: input: Logitech USB Optical Mouse as /devices/pci0000:00/0000:00:14.0/usb3/3-7/3-7:1.0/0003:046D:C077.0002/input/input3
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: hid-generic 0003:046D:C077.0002: input,hidraw1: USB HID v1.11 Mouse [Logitech USB Optical Mouse] on usb-0000:00:14.0-7/input0
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: tsc: Refined TSC clocksource calibration: 2793.530 MHz
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x284460f1a18, max_idle_ns: 440795261562 ns
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: usb 3-8: new low-speed USB device number 4 using xhci_hcd
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: pps_core: LinuxPPS API ver. 1 registered
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: PTP clock support registered
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: e1000e: Intel(R) PRO/1000 Network Driver - 3.2.6-k
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: e1000e: Copyright(c) 1999 - 2015 Intel Corporation.
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: e1000e 0000:00:19.0: Interrupt Throttling Rate (ints/sec) set to dynamic conservative mode
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: e1000e 0000:00:19.0 0000:00:19.0 (uninitialized): registered PHC clock
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: usb 3-8: New USB device found, idVendor=051d, idProduct=0002
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: usb 3-8: New USB device strings: Mfr=3, Product=1, SerialNumber=2
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: usb 3-8: Product: Back-UPS ES 550G FW:843.K4 .D USB FW:K4 
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: usb 3-8: Manufacturer: APC
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: usb 3-8: SerialNumber: 4B1210P35391  
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: e1000e 0000:00:19.0 eth0: (PCI Express:2.5GT/s:Width x1) 98:90:96:a0:02:93
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: e1000e 0000:00:19.0 eth0: Intel(R) PRO/1000 Network Connection
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: e1000e 0000:00:19.0 eth0: MAC: 11, PHY: 12, PBA No: FFFFFF-0FF
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: e1000e 0000:00:19.0 enp0s25: renamed from eth0
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: hid-generic 0003:051D:0002.0003: hiddev96,hidraw2: USB HID v1.10 Device [APC Back-UPS ES 550G FW:843.K4 .D USB FW:K4 ] on usb-0000:00:14.0-8/input0
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: DEBUG: bdi(0x00000000862bdd55) device_create_vargs sucess
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: DEBUG:dev:9:127, bdi_debug_root success
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: DEBUG:dev:9:127, debug_dir success
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: DEBUG:dev:9:127, debug_stats success
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: DEBUG: dev:9:127, bdi(0x00000000862bdd55) bdi_debug_register success
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: DEBUG: bdi(0x000000002ecee5f5) device_create_vargs sucess
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: DEBUG:dev:9:126, bdi_debug_root success
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: DEBUG:dev:9:126, debug_dir success
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: DEBUG:dev:9:126, debug_stats success
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: DEBUG: dev:9:126, bdi(0x000000002ecee5f5) bdi_debug_register success
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: DEBUG: bdi(0x000000007da59f05) device_create_vargs sucess
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: DEBUG:dev:9:125, bdi_debug_root success
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: DEBUG:dev:9:125, debug_dir success
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: DEBUG:dev:9:125, debug_stats success
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: DEBUG: dev:9:125, bdi(0x000000007da59f05) bdi_debug_register success
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: usb 3-11: new high-speed USB device number 5 using xhci_hcd
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: [drm] radeon kernel modesetting enabled.
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: [drm] initializing kernel modesetting (OLAND 0x1002:0x6608 0x1028:0x2120 0x00).
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: radeon 0000:03:00.0: Invalid PCI ROM header signature: expecting 0xaa55, got 0xffff
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: ATOM BIOS: Hadron
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: radeon 0000:03:00.0: VRAM: 2048M 0x0000000000000000 - 0x000000007FFFFFFF (2048M used)
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: radeon 0000:03:00.0: GTT: 2048M 0x0000000080000000 - 0x00000000FFFFFFFF
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: [drm] Detected VRAM RAM=2048M, BAR=256M
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: [drm] RAM width 128bits DDR
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: [TTM] Zone  kernel: Available graphics memory: 16433564 kiB
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: [TTM] Zone   dma32: Available graphics memory: 2097152 kiB
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: [TTM] Initializing pool allocator
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: [TTM] Initializing DMA pool allocator
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: [drm] radeon: 2048M of VRAM memory ready
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: [drm] radeon: 2048M of GTT memory ready.
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: [drm] Loading oland Microcode
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: [drm] Internal thermal controller with fan control
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: [drm] probing gen 2 caps for device 8086:2f04 = 37a3903/e
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: [drm] radeon: dpm initialized
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: [drm] Found VCE firmware/feedback version 50.0.1 / 17!
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: [drm] GART: num cpu pages 524288, num gpu pages 524288
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: [drm] probing gen 2 caps for device 8086:2f04 = 37a3903/e
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: [drm] PCIE gen 3 link speeds already enabled
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: md/raid1:md127: active with 2 out of 2 mirrors
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: random: crng init done
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: md/raid1:md125: active with 2 out of 2 mirrors
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: [drm] PCIE GART of 2048M enabled (table at 0x00000000001D6000).
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: radeon 0000:03:00.0: WB enabled
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: radeon 0000:03:00.0: fence driver on ring 0 use gpu addr 0x0000000080000c00 and cpu addr 0x0000000022363cfc
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: radeon 0000:03:00.0: fence driver on ring 1 use gpu addr 0x0000000080000c04 and cpu addr 0x00000000e47acc77
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: radeon 0000:03:00.0: fence driver on ring 2 use gpu addr 0x0000000080000c08 and cpu addr 0x000000006ee4fa5e
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: radeon 0000:03:00.0: fence driver on ring 3 use gpu addr 0x0000000080000c0c and cpu addr 0x00000000fbab55fa
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: radeon 0000:03:00.0: fence driver on ring 4 use gpu addr 0x0000000080000c10 and cpu addr 0x00000000e5c05ebb
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: radeon 0000:03:00.0: fence driver on ring 5 use gpu addr 0x0000000000075a18 and cpu addr 0x0000000065e5b889
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: md125: detected capacity change from 0 to 1074724864
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: md127: detected capacity change from 0 to 274880004096
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: radeon 0000:03:00.0: failed VCE resume (-110).
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: [drm] Supports vblank timestamp caching Rev 2 (21.10.2013).
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: [drm] Driver supports precise vblank timestamp query.
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: radeon 0000:03:00.0: radeon: MSI limited to 32-bit
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: usb 3-11: New USB device found, idVendor=0424, idProduct=2514
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: usb 3-11: New USB device strings: Mfr=0, Product=0, SerialNumber=0
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: radeon 0000:03:00.0: radeon: using MSI.
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: [drm] radeon: irq initialized.
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: hub 3-11:1.0: USB hub found
Dec 14 09:17:44 cerberus.csd.uwm.edu kernel: hub 3-11:1.0: 4 ports detected
Dec 14 09:17:45 cerberus.csd.uwm.edu kernel: [drm] ring test on 0 succeeded in 2 usecs
Dec 14 09:17:45 cerberus.csd.uwm.edu kernel: [drm] ring test on 1 succeeded in 1 usecs
Dec 14 09:17:45 cerberus.csd.uwm.edu kernel: [drm] ring test on 2 succeeded in 1 usecs
Dec 14 09:17:45 cerberus.csd.uwm.edu kernel: [drm] ring test on 3 succeeded in 3 usecs
Dec 14 09:17:45 cerberus.csd.uwm.edu kernel: [drm] ring test on 4 succeeded in 3 usecs
Dec 14 09:17:45 cerberus.csd.uwm.edu kernel: clocksource: Switched to clocksource tsc
Dec 14 09:17:45 cerberus.csd.uwm.edu kernel: [drm] ring test on 5 succeeded in 2 usecs
Dec 14 09:17:45 cerberus.csd.uwm.edu kernel: [drm] UVD initialized successfully.
Dec 14 09:17:45 cerberus.csd.uwm.edu kernel: [drm] ib test on ring 0 succeeded in 0 usecs
Dec 14 09:17:45 cerberus.csd.uwm.edu kernel: [drm] ib test on ring 1 succeeded in 0 usecs
Dec 14 09:17:45 cerberus.csd.uwm.edu kernel: [drm] ib test on ring 2 succeeded in 0 usecs
Dec 14 09:17:45 cerberus.csd.uwm.edu kernel: [drm] ib test on ring 3 succeeded in 0 usecs
Dec 14 09:17:45 cerberus.csd.uwm.edu kernel: [drm] ib test on ring 4 succeeded in 0 usecs
Dec 14 09:17:45 cerberus.csd.uwm.edu kernel: md/raid1:md126: active with 2 out of 2 mirrors
Dec 14 09:17:45 cerberus.csd.uwm.edu kernel: md126: detected capacity change from 0 to 68721573888
Dec 14 09:17:45 cerberus.csd.uwm.edu kernel: usb 3-11.1: new full-speed USB device number 6 using xhci_hcd
Dec 14 09:17:45 cerberus.csd.uwm.edu kernel: [drm] ib test on ring 5 succeeded
Dec 14 09:17:45 cerberus.csd.uwm.edu kernel: [drm] Radeon Display Connectors
Dec 14 09:17:45 cerberus.csd.uwm.edu kernel: [drm] Connector 0:
Dec 14 09:17:45 cerberus.csd.uwm.edu kernel: [drm]   DP-1
Dec 14 09:17:45 cerberus.csd.uwm.edu kernel: [drm]   HPD1
Dec 14 09:17:45 cerberus.csd.uwm.edu kernel: [drm]   DDC: 0x6540 0x6540 0x6544 0x6544 0x6548 0x6548 0x654c 0x654c
Dec 14 09:17:45 cerberus.csd.uwm.edu kernel: [drm]   Encoders:
Dec 14 09:17:45 cerberus.csd.uwm.edu kernel: [drm]     DFP1: INTERNAL_UNIPHY
Dec 14 09:17:45 cerberus.csd.uwm.edu kernel: [drm] Connector 1:
Dec 14 09:17:45 cerberus.csd.uwm.edu kernel: [drm]   DP-2
Dec 14 09:17:45 cerberus.csd.uwm.edu kernel: [drm]   HPD2
Dec 14 09:17:45 cerberus.csd.uwm.edu kernel: [drm]   DDC: 0x6530 0x6530 0x6534 0x6534 0x6538 0x6538 0x653c 0x653c
Dec 14 09:17:45 cerberus.csd.uwm.edu kernel: [drm]   Encoders:
Dec 14 09:17:45 cerberus.csd.uwm.edu kernel: [drm]     DFP2: INTERNAL_UNIPHY
Dec 14 09:17:45 cerberus.csd.uwm.edu kernel: usb 3-11.1: New USB device found, idVendor=413c, idProduct=a503
Dec 14 09:17:45 cerberus.csd.uwm.edu kernel: usb 3-11.1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
Dec 14 09:17:45 cerberus.csd.uwm.edu kernel: usb 3-11.1: Product: Dell AC511 USB SoundBar
Dec 14 09:17:45 cerberus.csd.uwm.edu kernel: usb 3-11.1: Manufacturer: Dell
Dec 14 09:17:45 cerberus.csd.uwm.edu kernel: input: Dell Dell AC511 USB SoundBar as /devices/pci0000:00/0000:00:14.0/usb3/3-11/3-11.1/3-11.1:1.3/0003:413C:A503.0004/input/input4
Dec 14 09:17:46 cerberus.csd.uwm.edu kernel: [drm] fb mappable at 0xE05D8000
Dec 14 09:17:46 cerberus.csd.uwm.edu kernel: [drm] vram apper at 0xE0000000
Dec 14 09:17:46 cerberus.csd.uwm.edu kernel: [drm] size 8294400
Dec 14 09:17:46 cerberus.csd.uwm.edu kernel: [drm] fb depth is 24
Dec 14 09:17:46 cerberus.csd.uwm.edu kernel: [drm]    pitch is 7680
Dec 14 09:17:46 cerberus.csd.uwm.edu kernel: fbcon: radeondrmfb (fb0) is primary device
Dec 14 09:17:46 cerberus.csd.uwm.edu kernel: hid-generic 0003:413C:A503.0004: input,hidraw3: USB HID v1.00 Device [Dell Dell AC511 USB SoundBar] on usb-0000:00:14.0-11.1/input3
Dec 14 09:17:46 cerberus.csd.uwm.edu kernel: Console: switching to colour frame buffer device 240x67
Dec 14 09:17:46 cerberus.csd.uwm.edu kernel: radeon 0000:03:00.0: fb0: radeondrmfb frame buffer device
Dec 14 09:17:46 cerberus.csd.uwm.edu kernel: [drm] Initialized radeon 2.50.0 20080528 for 0000:03:00.0 on minor 0
Dec 14 09:18:00 cerberus.csd.uwm.edu kernel: DEBUG: bdi(0x00000000a2201ebb) device_create_vargs sucess
Dec 14 09:18:00 cerberus.csd.uwm.edu kernel: DEBUG:dev:253:0, bdi_debug_root success
Dec 14 09:18:00 cerberus.csd.uwm.edu kernel: DEBUG:dev:253:0, debug_dir success
Dec 14 09:18:00 cerberus.csd.uwm.edu kernel: DEBUG:dev:253:0, debug_stats success
Dec 14 09:18:00 cerberus.csd.uwm.edu kernel: DEBUG: dev:253:0, bdi(0x00000000a2201ebb) bdi_debug_register success
Dec 14 09:18:00 cerberus.csd.uwm.edu kernel: DEBUG: bdi(0x0000000020d39bbd) device_create_vargs sucess
Dec 14 09:18:00 cerberus.csd.uwm.edu kernel: DEBUG:dev:253:1, bdi_debug_root success
Dec 14 09:18:00 cerberus.csd.uwm.edu kernel: DEBUG:dev:253:1, debug_dir success
Dec 14 09:18:00 cerberus.csd.uwm.edu kernel: DEBUG:dev:253:1, debug_stats success
Dec 14 09:18:00 cerberus.csd.uwm.edu kernel: DEBUG: dev:253:1, bdi(0x0000000020d39bbd) bdi_debug_register success
Dec 14 09:18:00 cerberus.csd.uwm.edu kernel: kauditd_printk_skb: 7 callbacks suppressed
Dec 14 09:18:00 cerberus.csd.uwm.edu kernel: audit: type=1130 audit(1513264680.869:18): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-cryptsetup@luks\x2df5e2d09b\x2df8a3\x2d487d\x2d9517\x2dabe4fb0eada3 comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 14 09:18:00 cerberus.csd.uwm.edu kernel: audit: type=1130 audit(1513264680.884:19): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-cryptsetup@luks\x2dcc6ee93c\x2de729\x2d4f78\x2d9baf\x2d0cc5cc8a9ff1 comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 14 09:18:00 cerberus.csd.uwm.edu kernel: audit: type=1130 audit(1513264680.992:20): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=dracut-initqueue comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 14 09:18:01 cerberus.csd.uwm.edu kernel: audit: type=1130 audit(1513264681.007:21): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=dracut-pre-mount comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 14 09:18:01 cerberus.csd.uwm.edu kernel: audit: type=1130 audit(1513264681.212:22): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=systemd-fsck-root comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 14 09:18:01 cerberus.csd.uwm.edu kernel: EXT4-fs (dm-0): mounted filesystem with ordered data mode. Opts: (null)
Dec 14 09:18:01 cerberus.csd.uwm.edu kernel: audit: type=1130 audit(1513264681.365:23): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=initrd-parse-etc comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 14 09:18:01 cerberus.csd.uwm.edu kernel: audit: type=1131 audit(1513264681.365:24): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=initrd-parse-etc comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 14 09:18:01 cerberus.csd.uwm.edu kernel: audit: type=1130 audit(1513264681.524:25): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=dracut-pre-pivot comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 14 09:18:01 cerberus.csd.uwm.edu kernel: audit: type=1131 audit(1513264681.540:26): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=dracut-pre-pivot comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 14 09:18:01 cerberus.csd.uwm.edu kernel: audit: type=1130 audit(1513264681.551:27): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel msg='unit=dracut-pre-mount comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 14 09:18:06 cerberus.csd.uwm.edu systemd-journald[222]: Received SIGTERM from PID 1 (systemd).
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: systemd: 17 output lines suppressed due to ratelimiting
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: SELinux: 32768 avtab hash slots, 109865 rules.
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: SELinux: 32768 avtab hash slots, 109865 rules.
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: SELinux:  8 users, 14 roles, 5130 types, 318 bools, 1 sens, 1024 cats
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: SELinux:  97 classes, 109865 rules
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: SELinux:  Permission getrlimit in class process not defined in policy.
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: SELinux:  Class sctp_socket not defined in policy.
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: SELinux:  Class icmp_socket not defined in policy.
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: SELinux:  Class ax25_socket not defined in policy.
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: SELinux:  Class ipx_socket not defined in policy.
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: SELinux:  Class netrom_socket not defined in policy.
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: SELinux:  Class atmpvc_socket not defined in policy.
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: SELinux:  Class x25_socket not defined in policy.
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: SELinux:  Class rose_socket not defined in policy.
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: SELinux:  Class decnet_socket not defined in policy.
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: SELinux:  Class atmsvc_socket not defined in policy.
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: SELinux:  Class rds_socket not defined in policy.
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: SELinux:  Class irda_socket not defined in policy.
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: SELinux:  Class pppox_socket not defined in policy.
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: SELinux:  Class llc_socket not defined in policy.
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: SELinux:  Class can_socket not defined in policy.
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: SELinux:  Class tipc_socket not defined in policy.
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: SELinux:  Class bluetooth_socket not defined in policy.
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: SELinux:  Class iucv_socket not defined in policy.
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: SELinux:  Class rxrpc_socket not defined in policy.
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: SELinux:  Class isdn_socket not defined in policy.
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: SELinux:  Class phonet_socket not defined in policy.
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: SELinux:  Class ieee802154_socket not defined in policy.
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: SELinux:  Class caif_socket not defined in policy.
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: SELinux:  Class alg_socket not defined in policy.
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: SELinux:  Class nfc_socket not defined in policy.
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: SELinux:  Class vsock_socket not defined in policy.
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: SELinux:  Class kcm_socket not defined in policy.
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: SELinux:  Class qipcrtr_socket not defined in policy.
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: SELinux:  Class smc_socket not defined in policy.
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: SELinux:  Class bpf not defined in policy.
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: SELinux: the above unknown classes and permissions will be allowed
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: SELinux:  policy capability network_peer_controls=1
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: SELinux:  policy capability open_perms=1
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: SELinux:  policy capability extended_socket_class=0
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: SELinux:  policy capability always_check_network=0
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: SELinux:  policy capability cgroup_seclabel=1
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: SELinux:  policy capability nnp_nosuid_transition=1
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: SELinux:  Completing initialization.
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: SELinux:  Setting up existing superblocks.
Dec 14 09:18:06 cerberus.csd.uwm.edu systemd[1]: Successfully loaded SELinux policy in 319.906ms.
Dec 14 09:18:06 cerberus.csd.uwm.edu systemd[1]: Relabelled /dev and /run in 37.664ms.
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: kauditd_printk_skb: 33 callbacks suppressed
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: audit: type=1130 audit(1513264686.425:61): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=systemd-journald comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: audit: type=1131 audit(1513264686.425:62): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=systemd-journald comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: audit: type=1130 audit(1513264686.434:63): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=initrd-switch-root comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: audit: type=1131 audit(1513264686.434:64): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=initrd-switch-root comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: audit: type=1130 audit(1513264686.481:65): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=systemd-journald comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: audit: type=1131 audit(1513264686.481:66): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=systemd-journald comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: audit: type=1305 audit(1513264686.526:67): audit_enabled=1 old=1 auid=4294967295 ses=4294967295 subj=system_u:system_r:syslogd_t:s0 res=1
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: EXT4-fs (dm-0): re-mounted. Opts: (null)
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: audit: type=1130 audit(1513264686.884:68): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=systemd-journald comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: audit: type=1130 audit(1513264686.892:69): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=kmod-static-nodes comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
Dec 14 09:18:06 cerberus.csd.uwm.edu kernel: audit: type=1130 audit(1513264686.900:70): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=systemd-remount-fs comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'

--fdj2RfSjLxBAspz7--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
