Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 573F0C10F05
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 17:50:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C008F206DF
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 17:50:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C008F206DF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.ee
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 223D76B0007; Tue, 26 Mar 2019 13:50:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1AA026B0008; Tue, 26 Mar 2019 13:50:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 024606B000A; Tue, 26 Mar 2019 13:50:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5FBA46B0007
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 13:50:47 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id i27so4092152ljb.3
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 10:50:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=YbQutiMpzdym0szi1LXuqkzrYmFpYndcJfjCc4395XI=;
        b=KUlWH0tmqQijAddMvpyLahMxsv9ZY10BNMhZj1UE56nilxYY49KVm6AVd0lXV2Zasg
         +FQ8i5WwFy5f7XlM5Lmcal80pv0xS/4QNPe4dt7xKb0AwCRLbPPG4oEjMlwh6OpTYgxo
         DfKXYLrLqne5ldA+8ET7iDdjFOvWAjwO2KGUL9TNLGs9drwd9k5UsY6H9/4bdBrMmVWL
         4ZcTDCddNXPO9uYUEaQIUFhY9tUlsxMIKryal2Ydqc6ShdgFcyJELVp0GfY1maYNsbPD
         RGUzRQIaPTzNE889tVeZN5HPt5C9MFa8oMcDdGpRecMVsspdYRCm1h1TD/stRl8kFh6t
         uw1A==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 193.40.6.72 is neither permitted nor denied by best guess record for domain of mroos@linux.ee) smtp.mailfrom=mroos@linux.ee
X-Gm-Message-State: APjAAAWyYPlM7UVJH4mZ/NBNx7JtKSSB6iu+SuxAzE9ZK1DPU6oGIWDx
	26shgpKf2ZSeNdF1mfNvzkqHI7stw6w6WTg5l1qlceNt/v0HWs+hRdCx9jZ9EKhd0gHeWgCMkzT
	pNiEs2wZjXWO7t4G3Kf6ru/1CV29EzYWG8u6+oTZV0mj8pXGa//roFTOjGZLB/D0=
X-Received: by 2002:a2e:9010:: with SMTP id h16mr8525104ljg.16.1553622646445;
        Tue, 26 Mar 2019 10:50:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz4AxWyZHLVhlZPRnVDq5RA14iduEwdNM3glzkfyrIWvXelllPAJZUzlnhgNjhEyFIdbFRx
X-Received: by 2002:a2e:9010:: with SMTP id h16mr8524960ljg.16.1553622642877;
        Tue, 26 Mar 2019 10:50:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553622642; cv=none;
        d=google.com; s=arc-20160816;
        b=aBFAUGx86ei+JzcOgJ7WyJAXanIM/At8/HL7aG2xmcVRnKDTWYG4oS+a33yS0T7Z95
         BOjsEwmujh/481aWOFBJmgKieC3aN6eqBD9I/yxMIy9mvSn3lcaG1z+uLWvvAvEix7mI
         AivhGUqVzS3oi8vqBdpK1uddSR4oez+4CXEEtPBNhuxnSwDn8EL5ClgNvzpL1uWsZO2U
         zQ6w30cmGK1IyED5xvUp4uGYpFkA8H551I5MCMrUi0kqhtC58llYhguJ6VYJESzSTxK6
         OrJQ8zZastKTm2nZHE441Med/ePzfvzpN8uAJBbxkY5kUey1NmgzXelxss6cTYfNLB3F
         3HjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=YbQutiMpzdym0szi1LXuqkzrYmFpYndcJfjCc4395XI=;
        b=DYQNd6F79WC5Vopu7tfZtrD4lj8rI3Igp5adUv9QtyJEhVga1hUbS2bwQElHYFbopy
         ZvaYeRjpK41T68jA5ECPLWJRC4dW9R5Iv8THPH69gaGvS8AzqE0AKqK1dEzVUf7hN7O8
         ZObdlgvGvMMlMB+tldiop4C3HBftSCx1BsYWeMtrMyTRg1UvTssVqdZVQcgK5NFvkUAc
         b9b/N1OviIpP/odjpjFghPhiIx1SoHve/RBulFl/T10mYZSQqyFcQkXAz/bgRjB7u9um
         ygonUoTRMSOomF97L6YqtxXaDskRwhFxjeA/KE31HEPCy+jffC/Xd0GMrCluPQq8q4hA
         5EGA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 193.40.6.72 is neither permitted nor denied by best guess record for domain of mroos@linux.ee) smtp.mailfrom=mroos@linux.ee
Received: from mx2.cyber.ee (mx2.cyber.ee. [193.40.6.72])
        by mx.google.com with ESMTPS id l15si12983420lfk.96.2019.03.26.10.50.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 10:50:42 -0700 (PDT)
Received-SPF: neutral (google.com: 193.40.6.72 is neither permitted nor denied by best guess record for domain of mroos@linux.ee) client-ip=193.40.6.72;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 193.40.6.72 is neither permitted nor denied by best guess record for domain of mroos@linux.ee) smtp.mailfrom=mroos@linux.ee
Subject: Re: CONFIG_DEBUG_VIRTUAL breaks boot on x86-32
To: William Kucharski <william.kucharski@oracle.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
References: <4d5ee3b0-6d47-a8df-a6b3-54b0fba66ed7@linux.ee>
 <A1B7F481-4BF6-4441-8019-AE088F8A8939@oracle.com>
From: Meelis Roos <mroos@linux.ee>
Message-ID: <6a5762e0-abba-696c-c6cf-4c0e9c80e2cc@linux.ee>
Date: Tue, 26 Mar 2019 19:50:40 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <A1B7F481-4BF6-4441-8019-AE088F8A8939@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: et-EE
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> Does this still happen on 5.1-rc2?

Yes. 4.20 and 5.0 and anything after that up to 5.1-rc2.

> Do you have idea as to what max_low_pfn() gets set to on your system at boot time?
> 
>  From the screen shot I'm guessing it MIGHT be 0x373fe, but it's hard to know for sure.


 From dmesg of 5.1-rc2 without the problematic config option:

[    0.007076] 1163MB HIGHMEM available.
[    0.007081] 883MB LOWMEM available.
[    0.007083]   mapped low ram: 0 - 373fe000
[    0.007084]   low ram: 0 - 373fe000
[    0.007087] BRK [0x17c7d000, 0x17c7dfff] PGTABLE
[    0.008172] Zone ranges:
[    0.008176]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.008181]   Normal   [mem 0x0000000001000000-0x00000000373fdfff]
[    0.008183]   HighMem  [mem 0x00000000373fe000-0x000000007ffeffff]
[    0.008186] Movable zone start for each node
[    0.008188] Early memory node ranges
[    0.008190]   node   0: [mem 0x0000000000001000-0x000000000009efff]
[    0.008192]   node   0: [mem 0x0000000000100000-0x000000007ffeffff]


Full dmesg:

[    0.000000] Linux version 5.1.0-rc2 (mroos@kt600) (gcc version 8.3.0 (Debian 8.3.0-3)) #15 Mon Mar 25 14:06:22 EET 2019
[    0.000000] x86/fpu: x87 FPU will use FXSAVE
[    0.000000] BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000ce000-0x00000000000d3fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000007ffeffff] usable
[    0.000000] BIOS-e820: [mem 0x000000007fff0000-0x000000007fff7fff] ACPI data
[    0.000000] BIOS-e820: [mem 0x000000007fff8000-0x000000007fffffff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x00000000fec00000-0x00000000fec00fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fee00000-0x00000000fee00fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fff80000-0x00000000ffffffff] reserved
[    0.000000] Notice: NX (Execute Disable) protection missing in CPU!
[    0.000000] Legacy DMI 2.3 present.
[    0.000000] DMI:  K7VT6-C /K7VT6-C , BIOS P1.50 06/15/2006
[    0.000000] tsc: Fast TSC calibration using PIT
[    0.000000] tsc: Detected 1798.230 MHz processor
[    0.006130] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
[    0.006134] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.006144] last_pfn = 0x7fff0 max_arch_pfn = 0x100000
[    0.006153] MTRR default type: uncachable
[    0.006154] MTRR fixed ranges enabled:
[    0.006156]   00000-9FFFF write-back
[    0.006158]   A0000-BFFFF uncachable
[    0.006159]   C0000-C7FFF write-protect
[    0.006160]   C8000-EFFFF uncachable
[    0.006162]   F0000-FFFFF write-protect
[    0.006163] MTRR variable ranges enabled:
[    0.006166]   0 base 000000000 mask F80000000 write-back
[    0.006166]   1 disabled
[    0.006167]   2 disabled
[    0.006168]   3 disabled
[    0.006168]   4 disabled
[    0.006170]   5 base 0E0000000 mask FF0000000 write-combining
[    0.006171]   6 disabled
[    0.006171]   7 disabled
[    0.006526] x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WP  UC- WT
[    0.006886] check: Scanning 1 areas for low memory corruption
[    0.006895] initial memory mapped: [mem 0x00000000-0x17ffffff]
[    0.006903] Base memory trampoline at [(ptrval)] 9b000 size 16384
[    0.006952] BRK [0x17c7c000, 0x17c7cfff] PGTABLE
[    0.006986] ACPI: Early table checksum verification disabled
[    0.007003] ACPI: RSDP 0x00000000000FA920 000014 (v00 AMI   )
[    0.007011] ACPI: RSDT 0x000000007FFF0000 00002C (v01 AMIINT VIA_K7   00000010 MSFT 00000097)
[    0.007024] ACPI: FACP 0x000000007FFF0030 000081 (v01 AMIINT VIA_K7   00000011 MSFT 00000097)
[    0.007041] ACPI: DSDT 0x000000007FFF0120 00324C (v01 VIA    K7VT4    00001000 INTL 02002024)
[    0.007047] ACPI: FACS 0x000000007FFF8000 000040
[    0.007052] ACPI: APIC 0x000000007FFF00C0 000054 (v01 AMIINT VIA_K7   00000009 MSFT 00000097)
[    0.007069] ACPI: Local APIC address 0xfee00000
[    0.007076] 1163MB HIGHMEM available.
[    0.007081] 883MB LOWMEM available.
[    0.007083]   mapped low ram: 0 - 373fe000
[    0.007084]   low ram: 0 - 373fe000
[    0.007087] BRK [0x17c7d000, 0x17c7dfff] PGTABLE
[    0.008172] Zone ranges:
[    0.008176]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.008181]   Normal   [mem 0x0000000001000000-0x00000000373fdfff]
[    0.008183]   HighMem  [mem 0x00000000373fe000-0x000000007ffeffff]
[    0.008186] Movable zone start for each node
[    0.008188] Early memory node ranges
[    0.008190]   node   0: [mem 0x0000000000001000-0x000000000009efff]
[    0.008192]   node   0: [mem 0x0000000000100000-0x000000007ffeffff]
[    0.008205] Zeroed struct page in unavailable ranges: 98 pages
[    0.008208] Initmem setup node 0 [mem 0x0000000000001000-0x000000007ffeffff]
[    0.008214] On node 0 totalpages: 524174
[    0.008217]   DMA zone: 32 pages used for memmap
[    0.008218]   DMA zone: 0 pages reserved
[    0.008220]   DMA zone: 3998 pages, LIFO batch:0
[    0.008552]   Normal zone: 1736 pages used for memmap
[    0.008553]   Normal zone: 222206 pages, LIFO batch:63
[    0.029717]   HighMem zone: 297970 pages, LIFO batch:63
[    0.057927] Using APIC driver default
[    0.058035] ACPI: PM-Timer IO Port: 0x808
[    0.058040] ACPI: Local APIC address 0xfee00000
[    0.058083] IOAPIC[0]: apic_id 2, version 3, address 0xfec00000, GSI 0-23
[    0.058088] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.058094] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 low level)
[    0.058097] ACPI: IRQ0 used by override.
[    0.058099] ACPI: IRQ9 used by override.
[    0.058103] Using ACPI (MADT) for SMP configuration information
[    0.058133] [mem 0x80000000-0xfebfffff] available for PCI devices
[    0.058143] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645519600211568 ns
[    0.058167] random: get_random_bytes called from start_kernel+0x78/0x352 with crng_init=0
[    0.058271] pcpu-alloc: s0 r0 d32768 u32768 alloc=1*32768
[    0.058273] pcpu-alloc: [0] 0
[    0.058295] Built 1 zonelists, mobility grouping on.  Total pages: 522406
[    0.058299] Kernel command line: BOOT_IMAGE=/boot/vmlinuz-5.1.0-rc2 root=/dev/sda1 ro hpet=force
[    0.059533] Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
[    0.060106] Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
[    0.060123] Initializing CPU#0
[    0.060133] Initializing HighMem for node 0 (000373fe:0007fff0)
[    0.131738] Initializing Movable for node 0 (00000000:00000000)
[    0.147463] Memory: 2066608K/2096696K available (5424K kernel code, 693K rwdata, 1348K rodata, 408K init, 4444K bss, 30088K reserved, 0K cma-reserved, 1191880K highmem)
[    0.147476] virtual kernel memory layout:
                    fixmap  : 0xfff8f000 - 0xfffff000   ( 448 kB)
                  cpu_entry : 0xffc00000 - 0xffc27000   ( 156 kB)
                    pkmap   : 0xff400000 - 0xff800000   (4096 kB)
                    vmalloc : 0xf7bfe000 - 0xff3fe000   ( 120 MB)
                    lowmem  : 0xc0000000 - 0xf73fe000   ( 883 MB)
                      .init : 0xd775e000 - 0xd77c4000   ( 408 kB)
                      .data : 0xd754c2bd - 0xd7751440   (2068 kB)
                      .text : 0xd7000000 - 0xd754c2bd   (5424 kB)
[    0.147480] Checking if this processor honours the WP bit even in supervisor mode...Ok.
[    0.147990] SLUB: HWalign=32, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
[    0.148269] NR_IRQS: 2304, nr_irqs: 256, preallocated irqs: 16
[    0.148695] CPU 0 irqstacks, hard=(ptrval) soft=(ptrval)
[    0.148949] Console: colour dummy device 80x25
[    0.149221] printk: console [tty0] enabled
[    0.149247] ACPI: Core revision 20190215
[    0.149563] APIC: Switch to symmetric I/O mode setup
[    0.149571] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.151063] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.169562] clocksource: tsc-early: mask: 0xffffffffffffffff max_cycles: 0x19eba186703, max_idle_ns: 440795249950 ns
[    0.169592] Calibrating delay loop (skipped), value calculated using timer frequency.. 3596.46 BogoMIPS (lpj=7192920)
[    0.169604] pid_max: default: 32768 minimum: 301
[    0.169744] LSM: Security Framework initializing
[    0.170026] AppArmor: AppArmor initialized
[    0.170113] Mount-cache hash table entries: 2048 (order: 1, 8192 bytes)
[    0.170125] Mountpoint-cache hash table entries: 2048 (order: 1, 8192 bytes)
[    0.170953] mce: CPU supports 4 MCE banks
[    0.171046] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.171053] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.171058] CPU: AMD Athlon(tm) XP 2200+ (family: 0x6, model: 0x8, stepping: 0x0)
[    0.171070] Spectre V2 : Spectre mitigation: kernel not compiled with retpoline; no mitigation available!
[    0.171072] Speculative Store Bypass: Vulnerable
[    0.172101] mce: [Hardware Error]: Machine check events logged
[    0.172112] mce: [Hardware Error]: CPU 0: Machine Check: 0 Bank 3: fe0000000000ffff
[    0.172118] mce: [Hardware Error]: TSC 0 ADDR dff7b7ffc
[    0.172127] mce: [Hardware Error]: PROCESSOR 2:680 TIME 1553614807 SOCKET 0 APIC 0 microcode 0
[    0.172231] Performance Events: AMD PMU driver.
[    0.172248] ... version:                0
[    0.172253] ... bit width:              48
[    0.172257] ... generic registers:      4
[    0.172262] ... value mask:             0000ffffffffffff
[    0.172267] ... max period:             00007fffffffffff
[    0.172271] ... fixed-purpose events:   0
[    0.172275] ... event mask:             000000000000000f
[    0.172633] NMI watchdog: Enabled. Permanently consumes one hw-PMU counter.
[    0.173575] devtmpfs: initialized
[    0.173575] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645041785100000 ns
[    0.173575] futex hash table entries: 256 (order: -1, 3072 bytes)
[    0.173575] NET: Registered protocol family 16
[    0.173575] audit: initializing netlink subsys (disabled)
[    0.173575] cpuidle: using governor menu
[    0.173575] ACPI: bus type PCI registered
[    0.194993] PCI: PCI BIOS revision 2.10 entry at 0xfdae1, last bus=1
[    0.195001] PCI: Using configuration type 1 for base access
[    0.202176] audit: type=2000 audit(1553614807.020:1): state=initialized audit_enabled=0 res=1
[    0.202618] HugeTLB registered 4.00 MiB page size, pre-allocated 0 pages
[    0.203378] fbcon: Taking over console
[    0.203448] ACPI: Added _OSI(Module Device)
[    0.203454] ACPI: Added _OSI(Processor Device)
[    0.203459] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.203464] ACPI: Added _OSI(Processor Aggregator Device)
[    0.203474] ACPI: Added _OSI(Linux-Dell-Video)
[    0.203484] ACPI: Added _OSI(Linux-Lenovo-NV-HDMI-Audio)
[    0.203494] ACPI: Added _OSI(Linux-HPI-Hybrid-Graphics)
[    0.238495] ACPI: 1 ACPI AML tables successfully acquired and loaded
[    0.254393] ACPI: Interpreter enabled
[    0.254432] ACPI: (supports S0 S5)
[    0.254439] ACPI: Using IOAPIC for interrupt routing
[    0.254675] PCI: Ignoring host bridge windows from ACPI; if necessary, use "pci=use_crs" and report a bug
[    0.255743] ACPI: Enabled 7 GPEs in block 00 to 0F
[    0.264529] ACPI: Power Resource [URP1] (off)
[    0.279123] ACPI: Power Resource [URP2] (off)
[    0.279440] ACPI: Power Resource [FDDP] (off)
[    0.279769] ACPI: Power Resource [LPTP] (off)
[    0.300239] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.300284] acpi PNP0A03:00: _OSC: OS supports [Segments MSI]
[    0.300353] acpi PNP0A03:00: fail to add MMCONFIG information, can't access extended PCI configuration space under this bridge.
[    0.300894] acpi PNP0A03:00: host bridge window expanded to [mem 0x80000000-0xffdfffff window]; [mem 0xfee01000-0xffdfffff window] ignored
[    0.300910] acpi PNP0A03:00: host bridge window [io  0x0cf8-0x0cff] (ignored)
[    0.300915] acpi PNP0A03:00: host bridge window [io  0x0000-0x0cf7 window] (ignored)
[    0.300920] acpi PNP0A03:00: host bridge window [io  0x0d00-0xffff window] (ignored)
[    0.300925] acpi PNP0A03:00: host bridge window [mem 0x000a0000-0x000bffff window] (ignored)
[    0.300930] acpi PNP0A03:00: host bridge window [mem 0x000c0000-0x000dffff window] (ignored)
[    0.300936] acpi PNP0A03:00: host bridge window [mem 0x80000000-0xffdfffff window] (ignored)
[    0.300940] PCI: root bus 00: using default resources
[    0.301165] PCI host bridge to bus 0000:00
[    0.301177] pci_bus 0000:00: root bus resource [io  0x0000-0xffff]
[    0.301187] pci_bus 0000:00: root bus resource [mem 0x00000000-0xffffffff]
[    0.301197] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.301240] pci 0000:00:00.0: [1106:3189] type 00 class 0x060000
[    0.301263] pci 0000:00:00.0: reg 0x10: [mem 0xe0000000-0xefffffff pref]
[    0.301831] pci 0000:00:01.0: [1106:b198] type 01 class 0x060400
[    0.301909] pci 0000:00:01.0: supports D1
[    0.302368] pci 0000:00:0a.0: [14f1:8800] type 00 class 0x040000
[    0.302389] pci 0000:00:0a.0: reg 0x10: [mem 0xde000000-0xdeffffff]
[    0.302920] pci 0000:00:0a.2: [14f1:8802] type 00 class 0x048000
[    0.302940] pci 0000:00:0a.2: reg 0x10: [mem 0xdf000000-0xdfffffff]
[    0.303490] pci 0000:00:10.0: [1106:3038] type 00 class 0x0c0300
[    0.303536] pci 0000:00:10.0: reg 0x20: [io  0xe400-0xe41f]
[    0.303599] pci 0000:00:10.0: supports D1 D2
[    0.303602] pci 0000:00:10.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.304111] pci 0000:00:10.1: [1106:3038] type 00 class 0x0c0300
[    0.304157] pci 0000:00:10.1: reg 0x20: [io  0xe800-0xe81f]
[    0.304220] pci 0000:00:10.1: supports D1 D2
[    0.304222] pci 0000:00:10.1: PME# supported from D0 D1 D2 D3hot D3cold
[    0.304729] pci 0000:00:10.2: [1106:3038] type 00 class 0x0c0300
[    0.304776] pci 0000:00:10.2: reg 0x20: [io  0xec00-0xec1f]
[    0.304839] pci 0000:00:10.2: supports D1 D2
[    0.304841] pci 0000:00:10.2: PME# supported from D0 D1 D2 D3hot D3cold
[    0.305340] pci 0000:00:10.3: [1106:3104] type 00 class 0x0c0320
[    0.305361] pci 0000:00:10.3: reg 0x10: [mem 0xddffff00-0xddffffff]
[    0.305450] pci 0000:00:10.3: supports D1 D2
[    0.305452] pci 0000:00:10.3: PME# supported from D0 D1 D2 D3hot D3cold
[    0.305978] pci 0000:00:11.0: [1106:3177] type 00 class 0x060100
[    0.306069] pci 0000:00:11.0: Force enabled HPET at 0xfed00000
[    0.306078] pci 0000:00:11.0: quirk: [io  0x0800-0x087f] claimed by vt8235 PM
[    0.306091] pci 0000:00:11.0: quirk: [io  0x0400-0x040f] claimed by vt8235 SMB
[    0.306639] pci 0000:00:11.1: [1106:0571] type 00 class 0x01018a
[    0.306689] pci 0000:00:11.1: reg 0x20: [io  0xfc00-0xfc0f]
[    0.306709] pci 0000:00:11.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x01f7]
[    0.306717] pci 0000:00:11.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
[    0.306724] pci 0000:00:11.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x0177]
[    0.306731] pci 0000:00:11.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
[    0.307320] pci 0000:00:11.5: [1106:3059] type 00 class 0x040100
[    0.307341] pci 0000:00:11.5: reg 0x10: [io  0xe000-0xe0ff]
[    0.307434] pci 0000:00:11.5: supports D1 D2
[    0.307936] pci 0000:00:12.0: [1106:3065] type 00 class 0x020000
[    0.307957] pci 0000:00:12.0: reg 0x10: [io  0xdc00-0xdcff]
[    0.307967] pci 0000:00:12.0: reg 0x14: [mem 0xddfffe00-0xddfffeff]
[    0.308051] pci 0000:00:12.0: supports D1 D2
[    0.308053] pci 0000:00:12.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.308581] pci_bus 0000:01: extended config space not accessible
[    0.308700] pci 0000:01:00.0: [1002:4152] type 00 class 0x030000
[    0.308715] pci 0000:01:00.0: reg 0x10: [mem 0xc0000000-0xcfffffff pref]
[    0.308724] pci 0000:01:00.0: reg 0x14: [io  0xc800-0xc8ff]
[    0.308732] pci 0000:01:00.0: reg 0x18: [mem 0xdbef0000-0xdbefffff]
[    0.308756] pci 0000:01:00.0: reg 0x30: [mem 0xdbec0000-0xdbedffff pref]
[    0.308806] pci 0000:01:00.0: supports D1 D2
[    0.309072] pci 0000:01:00.1: [1002:4172] type 00 class 0x038000
[    0.309087] pci 0000:01:00.1: reg 0x10: [mem 0xb0000000-0xbfffffff pref]
[    0.309095] pci 0000:01:00.1: reg 0x14: [mem 0xdbee0000-0xdbeeffff]
[    0.309165] pci 0000:01:00.1: supports D1 D2
[    0.309347] pci 0000:00:01.0: PCI bridge to [bus 01]
[    0.309358] pci 0000:00:01.0:   bridge window [io  0xc000-0xcfff]
[    0.309362] pci 0000:00:01.0:   bridge window [mem 0xdbe00000-0xdbefffff]
[    0.309367] pci 0000:00:01.0:   bridge window [mem 0x9bd00000-0xdbcfffff pref]
[    0.309376] pci_bus 0000:00: on NUMA node 0
[    0.316242] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 7 10 *11 12 14 15)
[    0.316959] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 7 *10 11 12 14 15)
[    0.317674] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 7 *10 11 12 14 15)
[    0.318383] ACPI: PCI Interrupt Link [LNKD] (IRQs *3 4 5 7 10 11 12 14 15)
[    0.319474] pci 0000:01:00.0: vgaarb: setting as boot VGA device
[    0.319491] pci 0000:01:00.0: vgaarb: VGA device added: decodes=io+mem,owns=io+mem,locks=none
[    0.319500] pci 0000:01:00.0: vgaarb: bridge control possible
[    0.319507] vgaarb: loaded
[    0.320158] SCSI subsystem initialized
[    0.320455] libata version 3.00 loaded.
[    0.320477] ACPI: bus type USB registered
[    0.320618] usbcore: registered new interface driver usbfs
[    0.320686] usbcore: registered new interface driver hub
[    0.320735] usbcore: registered new device driver usb
[    0.321008] PCI: Using ACPI for IRQ routing
[    0.321020] PCI: pci_cache_line_size set to 32 bytes
[    0.321070] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    0.321079] e820: reserve RAM buffer [mem 0x7fff0000-0x7fffffff]
[    0.322122] clocksource: hpet: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 133484882848 ns
[    0.322146] hpet clockevent registered
[    0.322176] HPET: 3 timers in total, 0 timers will be used for per-cpu timer
[    0.322190] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    0.322200] hpet0: 3 comparators, 32-bit 14.318180 MHz counter
[    0.324251] clocksource: Switched to clocksource tsc-early
[    0.325124] AppArmor: AppArmor Filesystem Enabled
[    0.325275] pnp: PnP ACPI init
[    0.325275] pnp 00:00: [dma 2]
[    0.325275] pnp 00:00: Plug and Play ACPI device, IDs PNP0700 (active)
[    0.326338] pnp 00:01: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.330265] pnp 00:02: [dma 0]
[    0.330633] pnp 00:02: Plug and Play ACPI device, IDs PNP0401 (active)
[    0.332421] pnp 00:03: Plug and Play ACPI device, IDs PNPb02f (active)
[    0.334348] pnp 00:04: Plug and Play ACPI device, IDs PNPb006 (active)
[    0.334877] system 00:05: [io  0x0295-0x0296] has been reserved
[    0.334909] system 00:05: [io  0x03f0-0x03f1] has been reserved
[    0.334922] system 00:05: [io  0x04d0-0x04d1] has been reserved
[    0.334934] system 00:05: [io  0x0400-0x040f] has been reserved
[    0.334946] system 00:05: [io  0x0800-0x087f] has been reserved
[    0.334965] system 00:05: [mem 0xfec00000-0xfec00fff] could not be reserved
[    0.334978] system 00:05: [mem 0xfee00000-0xfee00fff] has been reserved
[    0.335010] system 00:05: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.335308] pnp 00:06: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.335831] pnp 00:07: Plug and Play ACPI device, IDs PNP0303 PNP030b (active)
[    0.337093] pnp: PnP ACPI: found 8 devices
[    0.381530] clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, max_idle_ns: 2085701024 ns
[    0.381603] pci 0000:00:01.0: PCI bridge to [bus 01]
[    0.381616] pci 0000:00:01.0:   bridge window [io  0xc000-0xcfff]
[    0.381629] pci 0000:00:01.0:   bridge window [mem 0xdbe00000-0xdbefffff]
[    0.381638] pci 0000:00:01.0:   bridge window [mem 0x9bd00000-0xdbcfffff pref]
[    0.381652] pci_bus 0000:00: resource 4 [io  0x0000-0xffff]
[    0.381655] pci_bus 0000:00: resource 5 [mem 0x00000000-0xffffffff]
[    0.381659] pci_bus 0000:01: resource 0 [io  0xc000-0xcfff]
[    0.381661] pci_bus 0000:01: resource 1 [mem 0xdbe00000-0xdbefffff]
[    0.381664] pci_bus 0000:01: resource 2 [mem 0x9bd00000-0xdbcfffff pref]
[    0.382098] NET: Registered protocol family 2
[    0.382948] tcp_listen_portaddr_hash hash table entries: 512 (order: 0, 4096 bytes)
[    0.382989] TCP established hash table entries: 8192 (order: 3, 32768 bytes)
[    0.383059] TCP bind hash table entries: 8192 (order: 3, 32768 bytes)
[    0.383131] TCP: Hash tables configured (established 8192 bind 8192)
[    0.383281] UDP hash table entries: 512 (order: 1, 8192 bytes)
[    0.383306] UDP-Lite hash table entries: 512 (order: 1, 8192 bytes)
[    0.383477] NET: Registered protocol family 1
[    0.383530] pci 0000:00:01.0: disabling DAC on VIA PCI bridge
[    0.390088] pci 0000:01:00.0: Video device with shadowed ROM at [mem 0x000c0000-0x000dffff]
[    0.390103] PCI: CLS 32 bytes, default 32
[    0.390980] check: Scanning for low memory corruption every 60 seconds
[    0.391516] kworker/u2:0 (20) used greatest stack depth: 6936 bytes left
[    0.392996] workingset: timestamp_bits=30 max_order=19 bucket_order=0
[    0.413341] bounce: pool size: 64 pages
[    0.413520] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 252)
[    0.413531] io scheduler mq-deadline registered
[    0.414794] vesafb: mode is 1280x1024x32, linelength=5120, pages=0
[    0.414804] vesafb: scrolling: redraw
[    0.414811] vesafb: Truecolor: size=0:8:8:8, shift=0:16:8:0
[    0.414872] vesafb: framebuffer at 0xc0000000, mapped to 0x(ptrval), using 5120k, total 5120k
[    0.415702] Console: switching to colour frame buffer device 160x64
[    0.488695] fb0: VESA VGA frame buffer device
[    0.489416] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    0.510341] 00:01: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
[    0.512969] pata_via 0000:00:11.1: version 0.3.4
[    0.513858] pata_via 0000:00:11.1: can't derive routing for PCI INT A
[    0.526483] scsi host0: pata_via
[    0.527429] scsi host1: pata_via
[    0.527935] ata1: PATA max UDMA/133 cmd 0x1f0 ctl 0x3f6 bmdma 0xfc00 irq 14
[    0.528513] ata2: PATA max UDMA/133 cmd 0x170 ctl 0x376 bmdma 0xfc08 irq 15
[    0.529266] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    0.529807] ehci-pci: EHCI PCI platform driver
[    0.531260] ehci-pci 0000:00:10.3: EHCI Host Controller
[    0.531742] ehci-pci 0000:00:10.3: new USB bus registered, assigned bus number 1
[    0.532500] ehci-pci 0000:00:10.3: irq 21, io mem 0xddffff00
[    0.546900] ehci-pci 0000:00:10.3: USB 2.0 started, EHCI 1.00
[    0.547654] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002, bcdDevice= 5.01
[    0.548336] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    0.548931] usb usb1: Product: EHCI Host Controller
[    0.549335] usb usb1: Manufacturer: Linux 5.1.0-rc2 ehci_hcd
[    0.549801] usb usb1: SerialNumber: 0000:00:10.3
[    0.550822] hub 1-0:1.0: USB hub found
[    0.551181] hub 1-0:1.0: 6 ports detected
[    0.552433] uhci_hcd: USB Universal Host Controller Interface driver
[    0.554088] uhci_hcd 0000:00:10.0: UHCI Host Controller
[    0.554545] uhci_hcd 0000:00:10.0: new USB bus registered, assigned bus number 2
[    0.555272] uhci_hcd 0000:00:10.0: irq 21, io base 0x0000e400
[    0.556067] usb usb2: New USB device found, idVendor=1d6b, idProduct=0001, bcdDevice= 5.01
[    0.556751] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    0.557347] usb usb2: Product: UHCI Host Controller
[    0.557750] usb usb2: Manufacturer: Linux 5.1.0-rc2 uhci_hcd
[    0.558216] usb usb2: SerialNumber: 0000:00:10.0
[    0.559221] hub 2-0:1.0: USB hub found
[    0.559586] hub 2-0:1.0: 2 ports detected
[    0.561351] uhci_hcd 0000:00:10.1: UHCI Host Controller
[    0.561811] uhci_hcd 0000:00:10.1: new USB bus registered, assigned bus number 3
[    0.562469] uhci_hcd 0000:00:10.1: irq 21, io base 0x0000e800
[    0.563311] usb usb3: New USB device found, idVendor=1d6b, idProduct=0001, bcdDevice= 5.01
[    0.563994] usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    0.564588] usb usb3: Product: UHCI Host Controller
[    0.564992] usb usb3: Manufacturer: Linux 5.1.0-rc2 uhci_hcd
[    0.589715] usb usb3: SerialNumber: 0000:00:10.1
[    0.614758] hub 3-0:1.0: USB hub found
[    0.638962] hub 3-0:1.0: 2 ports detected
[    0.664237] uhci_hcd 0000:00:10.2: UHCI Host Controller
[    0.688116] uhci_hcd 0000:00:10.2: new USB bus registered, assigned bus number 4
[    0.712099] uhci_hcd 0000:00:10.2: irq 21, io base 0x0000ec00
[    0.736151] usb usb4: New USB device found, idVendor=1d6b, idProduct=0001, bcdDevice= 5.01
[    0.760302] usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    0.784375] usb usb4: Product: UHCI Host Controller
[    0.808333] usb usb4: Manufacturer: Linux 5.1.0-rc2 uhci_hcd
[    0.832281] usb usb4: SerialNumber: 0000:00:10.2
[    0.856538] hub 4-0:1.0: USB hub found
[    0.879979] hub 4-0:1.0: 2 ports detected
[    0.903802] usbcore: registered new interface driver usb-storage
[    0.927172] i8042: PNP: PS/2 Controller [PNP0303:PS2K] at 0x60,0x64 irq 1
[    0.950483] i8042: PNP: PS/2 appears to have AUX port disabled, if this is incorrect please boot with i8042.nopnp
[    0.974523] serio: i8042 KBD port at 0x60,0x64 irq 1
[    0.998555] mousedev: PS/2 mouse device common for all mice
[    1.022226] rtc_cmos 00:06: RTC can wake from S4
[    1.046115] rtc_cmos 00:06: registered as rtc0
[    1.069521] rtc_cmos 00:06: alarms up to one year, y3k, 114 bytes nvram, hpet irqs
[    1.093334] hidraw: raw HID events driver (C) Jiri Kosina
[    1.117054] usbcore: registered new interface driver usbhid
[    1.140456] usbhid: USB HID core driver
[    1.164937] NET: Registered protocol family 10
[    1.189902] Segment Routing with IPv6
[    1.212885] mip6: Mobile IPv6
[    1.235418] NET: Registered protocol family 17
[    1.258420] Using IPI Shortcut mode
[    1.280718] sched_clock: Marking stable (1279812884, 841216)->(1391362095, -110707995)
[    1.304867] page_owner is disabled
[    1.327763] AppArmor: AppArmor sha1 policy hashing enabled
[    1.352375] printk: console [netcon0] enabled
[    1.375518] netconsole: network logging started
[    1.398593] rtc_cmos 00:06: setting system clock to 2019-03-26T15:40:08 UTC (1553614808)
[    1.422502] ata1.00: ATA-6: WDC WD2000JB-00DUA3, 75.13B75, max UDMA/100
[    1.446173] ata1.00: 390625000 sectors, multi 16: LBA48
[    1.475010] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input0
[    1.504844] scsi 0:0:0:0: Direct-Access     ATA      WDC WD2000JB-00D 3B75 PQ: 0 ANSI: 5
[    1.530592] sd 0:0:0:0: [sda] 390625000 512-byte logical blocks: (200 GB/186 GiB)
[    1.555052] sd 0:0:0:0: [sda] Write Protect is off
[    1.579167] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    1.579217] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    1.603890] sd 0:0:0:0: [sda] Optimal transfer size 0 bytes < PAGE_SIZE (4096 bytes)
[    1.667521]  sda: sda1 sda2 < sda5 >
[    1.693856] sd 0:0:0:0: [sda] Attached SCSI disk
[    1.815320] ata2.00: ATAPI: HL-DT-ST GCE-8520B, 1.02, max UDMA/33
[    1.847955] scsi 1:0:0:0: CD-ROM            HL-DT-ST CD-RW GCE-8520B  1.02 PQ: 0 ANSI: 5
[    1.896593] sr 1:0:0:0: [sr0] scsi3-mmc drive: 40x/40x writer cd/rw xa/form2 cdda tray
[    1.922116] cdrom: Uniform CD-ROM driver Revision: 3.20
[    1.948549] sr 1:0:0:0: Attached scsi CD-ROM sr0
[    2.026777] EXT4-fs (sda1): mounted filesystem with ordered data mode. Opts: (null)
[    2.052598] VFS: Mounted root (ext4 filesystem) readonly on device 8:1.
[    2.112863] devtmpfs: mounted
[    2.139141] Freeing unused kernel image memory: 408K
[    2.164804] Write protecting kernel text and read-only data: 6800k
[    2.190540] Run /sbin/init as init process
[    2.315068] tsc: Refined TSC clocksource calibration: 1798.233 MHz
[    2.341376] clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x19eba47a4ac, max_idle_ns: 440795272906 ns
[    2.368198] clocksource: Switched to clocksource tsc
[    3.784329] random: fast init done
[    3.859323] systemd[1]: Inserted module 'autofs4'
[    4.026305] systemd[1]: systemd 241 running in system mode. (+PAM +AUDIT +SELINUX +IMA +APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT +GNUTLS +ACL +XZ +LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD -IDN2 +IDN -PCRE2 default-hierarchy=hybrid)
[    4.082404] systemd[1]: Detected architecture x86.
[    4.217198] systemd[1]: Set hostname to <kt600>.
[    4.621286] systemd-cryptse (46) used greatest stack depth: 6152 bytes left
[    5.103497] systemd-sysv-ge (55) used greatest stack depth: 5820 bytes left
[    5.358675] random: crng init done
[    5.793767] systemd[1]: Started Forward Password Requests to Wall Directory Watch.
[    5.851325] systemd[1]: Listening on udev Kernel Socket.
[    5.909195] systemd[1]: Listening on Journal Socket (/dev/log).
[    5.967766] systemd[1]: Listening on Syslog Socket.
[    6.026892] systemd[1]: Set up automount Arbitrary Executable File Formats File System Automount Point.
[    6.087023] systemd[1]: Created slice system-getty.slice.
[    6.145951] systemd[1]: Reached target Remote File Systems.
[    6.499138] w83627hf: w83627hf: Found W83697HF chip at 0x290
[    6.499983] w83627hf w83627hf.656: hwmon_device_register() is deprecated. Please convert the driver to use hwmon_device_register_with_info().
[    8.033018] EXT4-fs (sda1): re-mounted. Opts: errors=remount-ro
[    8.571157] systemd-journald[60]: Received request to flush runtime journal from PID 1
[    9.867712] input: Power Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0C:00/input/input1
[    9.891988] ACPI: Power Button [PWRB]
[    9.916093] input: Sleep Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0E:00/input/input2
[    9.940454] ACPI: Sleep Button [SLPB]
[    9.964845] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input3
[    9.989382] ACPI: Power Button [PWRF]
[   10.354509] Floppy drive(s): fd0 is 1.44M
[   10.394063] Linux agpgart interface v0.103
[   10.421057] audit: type=1400 audit(1553614817.517:2): apparmor="STATUS" operation="profile_load" profile="unconfined" name="nvidia_modprobe" pid=116 comm="apparmor_parser"
[   10.472329] audit: type=1400 audit(1553614817.517:3): apparmor="STATUS" operation="profile_load" profile="unconfined" name="nvidia_modprobe//kmod" pid=116 comm="apparmor_parser"
[   10.664191] gameport gameport0: NS558 PnP Gameport is pnp00:03/gameport0, io 0x200, speed 832kHz
[   10.673584] FDC 0 is a post-1991 82077
[   10.710426] media: Linux media interface: v0.10
[   10.716360] agpgart: Detected VIA KT400/KT400A/KT600 chipset
[   10.735131] input: PC Speaker as /devices/platform/pcspkr/input/input4
[   10.736746] sd 0:0:0:0: Attached scsi generic sg0 type 0
[   10.737174] sr 1:0:0:0: Attached scsi generic sg1 type 5
[   10.750587] videodev: Linux video capture interface: v2.00
[   10.755643] parport_pc 00:02: reported by Plug and Play ACPI
[   10.755897] parport0: PC-style at 0x378 (0x778), irq 7, dma 0 [PCSPP,TRISTATE,COMPAT,EPP,ECP,DMA]
[   10.772428] via_rhine: v1.10-LK1.5.1 2010-10-09 Written by Donald Becker
[   10.774408] via-rhine 0000:00:12.0 eth0: VIA Rhine II at 0cf59573, 00:0b:6a:d1:75:e9, IRQ 23
[   10.775169] via-rhine 0000:00:12.0 eth0: MII PHY found at address 1, status 0x7869 advertising 05e1 Link 41e1
[   10.903843] agpgart-via 0000:00:00.0: AGP aperture is 256M @ 0xe0000000
[   11.170843] cx88xx: subsystem: 107d:663c, board: Leadtek PVR 2000 [card=9,autodetected], frontend(s): 0
[   11.517463] TUNER: Unable to find symbol tea5767_autodetection()
[   11.517473] tuner: 1-0060: Tuner -1 found with type(s) Radio TV.
[   11.540027] audit: type=1400 audit(1553614817.685:4): apparmor="STATUS" operation="profile_load" profile="unconfined" name="/usr/bin/man" pid=118 comm="apparmor_parser"
[   11.540062] audit: type=1400 audit(1553614817.685:5): apparmor="STATUS" operation="profile_load" profile="unconfined" name="man_filter" pid=118 comm="apparmor_parser"
[   11.540089] audit: type=1400 audit(1553614817.685:6): apparmor="STATUS" operation="profile_load" profile="unconfined" name="man_groff" pid=118 comm="apparmor_parser"
[   11.585406] snd_via82xx 0000:00:11.5: Using DXS as PCM Playback
[   11.605631] [drm] radeon kernel modesetting enabled.
[   11.605763] checking generic (c0000000 500000) vs hw (c0000000 10000000)
[   11.605765] fb0: switching to radeondrmfb from VESA VGA
[   11.845410] via-rhine 0000:00:12.0 enp0s18: renamed from eth0
[   11.884527] tda9887 1-0043: creating new instance
[   11.884530] tda9887 1-0043: tda988[5/6/7] found
[   11.885110] tuner: 1-0043: Tuner 74 found with type(s) Radio TV.
[   11.945387] cx88xx: Leadtek Winfast 2000XP Expert config: tuner=38, eeprom[0]=0x04
[   12.547831] tuner-simple 1-0060: creating new instance
[   12.547837] tuner-simple 1-0060: type set to 38 (Philips PAL/SECAM multi (FM1216ME MK3))
[   12.550534] cx8802: cx2388x 8802 Driver Manager
[   12.551442] cx8802: found at 0000:00:0a.2, rev: 5, irq: 18, latency: 32, mmio: 0xdf000000
[   12.552684] cx8800: found at 0000:00:0a.0, rev: 5, irq: 18, latency: 32, mmio: 0xde000000
[   12.560448] cx8800: registered device video0 [v4l2]
[   12.560962] cx8800: registered device vbi0
[   12.561302] cx8800: registered device radio0
[   13.080633] Console: switching to colour dummy device 80x25
[   13.083031] radeon 0000:01:00.0: vgaarb: deactivate vga console
[   13.083575] setfont (138) used greatest stack depth: 5696 bytes left
[   13.090035] [drm] initializing kernel modesetting (RV350 0x1002:0x4152 0x174B:0x7C29 0x00).
[   13.091133] agpgart-via 0000:00:00.0: AGP 3.5 bridge
[   13.091154] agpgart-via 0000:00:00.0: putting AGP V3 device into 8x mode
[   13.091205] radeon 0000:01:00.0: putting AGP V3 device into 8x mode
[   13.091216] radeon 0000:01:00.0: GTT: 256M 0xE0000000 - 0xEFFFFFFF
[   13.091223] [drm] Generation 2 PCI interface, using max accessible memory
[   13.091232] radeon 0000:01:00.0: VRAM: 256M 0x00000000C0000000 - 0x00000000CFFFFFFF (256M used)
[   13.091288] [drm] Detected VRAM RAM=256M, BAR=256M
[   13.091294] [drm] RAM width 128bits DDR
[   13.104302] [TTM] Zone  kernel: Available graphics memory: 437568 kiB
[   13.104327] [TTM] Zone highmem: Available graphics memory: 1033508 kiB
[   13.104333] [TTM] Initializing pool allocator
[   13.104480] [drm] radeon: 256M of VRAM memory ready
[   13.104493] [drm] radeon: 256M of GTT memory ready.
[   13.104639] [drm] radeon: 1 quad pipes, 1 Z pipes initialized
[   13.105883] radeon 0000:01:00.0: WB disabled
[   13.105921] radeon 0000:01:00.0: fence driver on ring 0 use gpu addr 0x00000000e0000000 and cpu addr 0xc1c2fb20
[   13.105942] [drm] Supports vblank timestamp caching Rev 2 (21.10.2013).
[   13.105948] [drm] Driver supports precise vblank timestamp query.
[   13.106006] [drm] radeon: irq initialized.
[   13.106061] [drm] Loading R300 Microcode
[   13.145700] Registered IR keymap rc-hauppauge
[   13.146003] rc rc0: Hauppauge as /devices/pci0000:00/0000:00:0a.2/i2c-1/1-0018/rc/rc0
[   13.146230] input: Hauppauge as /devices/pci0000:00/0000:00:0a.2/i2c-1/1-0018/rc/rc0/input6
[   13.152323] rc rc0: lirc_dev: driver ir_kbd_i2c registered at minor = 0, scancode receiver, no transmitter
[   13.205146] cx88_blackbird: cx2388x blackbird driver version 1.0.0 loaded
[   13.205174] cx8802: registering cx8802 driver, type: blackbird access: shared
[   13.205183] cx8802: subsystem: 107d:663c, board: Leadtek PVR 2000 [card=9]
[   13.205538] cx88_blackbird: cx23416 based mpeg encoder (blackbird reference design)
[   13.205767] cx88_blackbird: blackbird_mbox_func: blackbird:Firmware and/or mailbox pointer not initialized or corrupted
[   15.612593] cx88_blackbird: blackbird_load_firmware: blackbird:Firmware upload successful.
[   15.630492] [drm] radeon: ring at 0x00000000E0001000
[   15.630545] [drm] ring test succeeded in 0 usecs
[   15.630875] [drm] ib test succeeded in 0 usecs
[   15.632854] [drm] Radeon Display Connectors
[   15.632867] [drm] Connector 0:
[   15.632872] [drm]   VGA-1
[   15.632877] [drm]   DDC: 0x60 0x60 0x60 0x60 0x60 0x60 0x60 0x60
[   15.632883] [drm]   Encoders:
[   15.632887] [drm]     CRT1: INTERNAL_DAC1
[   15.632892] [drm] Connector 1:
[   15.632896] [drm]   DVI-I-1
[   15.632900] [drm]   HPD1
[   15.632905] [drm]   DDC: 0x64 0x64 0x64 0x64 0x64 0x64 0x64 0x64
[   15.632910] [drm]   Encoders:
[   15.632913] [drm]     CRT2: INTERNAL_DAC2
[   15.632918] [drm]     DFP1: INTERNAL_TMDS1
[   15.632922] [drm] Connector 2:
[   15.632925] [drm]   SVIDEO-1
[   15.632929] [drm]   Encoders:
[   15.632933] [drm]     TV1: INTERNAL_DAC2
[   15.749890] [drm] fb mappable at 0xC0040000
[   15.749914] [drm] vram apper at 0xC0000000
[   15.749919] [drm] size 5242880
[   15.749923] [drm] fb depth is 24
[   15.749927] [drm]    pitch is 5120
[   15.752277] fbcon: radeondrmfb (fb0) is primary device
[   15.803402] Console: switching to colour frame buffer device 160x64
[   15.930197] radeon 0000:01:00.0: fb0: radeondrmfb frame buffer device
[   15.930273] [drm] Initialized radeon 2.50.0 20080528 for 0000:01:00.0 on minor 0
[   16.272511] cx88_blackbird: blackbird_initialize_codec: blackbird:Firmware version is 0x02060039
[   16.284001] cx88_blackbird: registered device video1 [mpeg]
[   16.287894] modprobe (155) used greatest stack depth: 5496 bytes left
[   16.803253] Adding 2096124k swap on /dev/sda5.  Priority:-2 extents:1 across:2096124k
[   20.717229] IPv6: ADDRCONF(NETDEV_CHANGE): enp0s18: link becomes ready
[   21.027559] systemd-udevd (100) used greatest stack depth: 4416 bytes left

-- 
Meelis Roos

