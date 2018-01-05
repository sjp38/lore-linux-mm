Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id E83486B02BF
	for <linux-mm@kvack.org>; Fri,  5 Jan 2018 13:33:13 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id q4so3025041wre.14
        for <linux-mm@kvack.org>; Fri, 05 Jan 2018 10:33:13 -0800 (PST)
Received: from twin.jikos.cz (twin.jikos.cz. [91.219.245.39])
        by mx.google.com with ESMTPS id i5si4583834wrh.542.2018.01.05.10.33.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 05 Jan 2018 10:33:12 -0800 (PST)
Date: Fri, 5 Jan 2018 19:33:00 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [RFC] boot failed when enable KAISER/KPTI
In-Reply-To: <5A4F09B7.8010402@huawei.com>
Message-ID: <alpine.LRH.2.00.1801051930370.27010@gjva.wvxbf.pm>
References: <5A4F09B7.8010402@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Yisheng Xie <xieyisheng1@huawei.com>, "Wangkefeng (Maro)" <wangkefeng.wang@huawei.com>, Hanjun Guo <guohanjun@huawei.com>

On Fri, 5 Jan 2018, Xishi Qiu wrote:

> I run the latest RHEL 7.2 with the KAISER/KPTI patch, and boot failed.
> 
> ...
> [    0.000000] PM: Registered nosave memory: [mem 0x81000000000-0x8ffffffffff]
> [    0.000000] PM: Registered nosave memory: [mem 0x91000000000-0xfffffffffff]
> [    0.000000] PM: Registered nosave memory: [mem 0x101000000000-0x10ffffffffff]
> [    0.000000] PM: Registered nosave memory: [mem 0x111000000000-0x17ffffffffff]
> [    0.000000] PM: Regitered nosave memory: [mem 0x181000000000-0x18ffffffffff]
> [    0.000000] e820: [mem 0x90000000-0xfed1bfff] available for PCI devices
> [    0.000000] Booting paravirtualized kernel on bare hardware
> [    0.000000] setup_percpu: NR_CPUS:5120 nr_cpumask_bits:1536 nr_cpu_ids:1536 nr_node_ids:8
> [    0.000000] PERCPU: max_distance=0x180ffe240000 too large for vmalloc space 0x1fffffffffff
> [    0.000000] setup_percpu: auto allocator failed (-22), falling back to page size
> [    0.000000] PERCPU: 32 4K pages/cpu @ffffc90000000000 s107200 r8192 d15680
> [    0.000000] Built 8 zonelists in Zone order, mobility grouping on.  Total pages: 132001804
> [    0.000000] Policy zone: Normal
> iosdevname=0 8250.nr_uarts=8 efi=old_map rdloaddriver=usb_storage rdloaddriver=sd_mod udev.event-timeout=600 softlockup_panic=0 rcupdate.rcu_cpu_stall_timeout=300
> [    0.000000] Intel-IOMMU: enabled
> [    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
> [    0.000000] x86/fpu: xstate_offset[2]: 0240, xstate_sizes[2]: 0100
> [    0.000000] xsave: enabled xstate_bv 0x7, cntxt size 0x340
> [    0.000000] AGP: Checking aperture...
> [    0.000000] AGP: No AGP bridge found
> [    0.000000] Memory: 526901612k/26910638080k available (6528k kernel code, 26374249692k absent, 9486776k reserved, 4302k data, 1676k init)
> [    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=1536, Nodes=8
> [    0.000000] x86/pti: Unmapping kernel while in userspace
> [    0.000000] Hierarchical RCU implementation.
> [    0.000000] 	RCU restricting CPUs from NR_CPUS=5120 to nr_cpu_ids=1536.
> [    0.000000] 	Offload RCU callbacks from all CPUs
> [    0.000000] 	Offload RCU callbacks from CPUs: 0-1535.
> [    0.000000] NR_IRQS:327936 nr_irqs:15976 0
> [    0.000000] Console: colour dummy device 80x25
> [    0.000000] console [tty0] enabled
> [    0.000000] console [ttyS0] enabled
> [    0.000000] allocated 2145910784 bytes of page_cgroup
> [    0.000000] please try 'cgroup_disable=memory' option if you don't want memory cgroups
> [    0.000000] Enabling automatic NUMA balancing. Configure with numa_balancing= or the kernel.numa_balancing sysctl
> [    0.000000] tsc: Fast TSC calibration using PIT
> [    0.000000] tsc: Detected 2799.999 MHz processor
> [    0.001803] Calibrating delay loop (skipped), value calculated using timer frequency.. 5599.99 BogoMIPS (lpj=2799999)
> [    0.012408] pid_max: default: 1572864 minimum: 12288
> [    0.017987] init_memory_mapping: [mem 0x5947f000-0x5b47efff]
> [    0.023701] init_memory_mapping: [mem 0x5b47f000-0x5b87efff]
> [    0.029369] init_memory_mapping: [mem 0x6d368000-0x6d3edfff]
> [    0.039130] BUG: unable to handle kernel paging request at 000000005b835f90
> [    0.046101] IP: [<000000005b835f90>] 0x5b835f8f
> [    0.050637] PGD 8000000001f61067 PUD 190ffefff067 PMD 190ffeffd067 PTE 5b835063
> [    0.057989] Oops: 0011 [#1] SMP 
> [    0.061241] Modules linked in:
> [    0.064304] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.10.0-327.59.59.46.h42.x86_64 #1
> [    0.072280] Hardware name: Huawei FusionServer9032/IT91SMUB, BIOS BLXSV316 11/14/2017
> [    0.080082] task: ffffffff8196e440 ti: ffffffff81958000 task.ti: ffffffff81958000
> [    0.087539] RIP: 0010:[<000000005b835f90>]  [<000000005b835f90>] 0x5b835f8f
> [    0.094494] RSP: 0000:ffffffff8195be28  EFLAGS: 00010046
> [    0.099788] RAX: 0000000080050033 RBX: ffff910fbc802000 RCX: 00000000000002d0
> [    0.106897] RDX: 0000000000000030 RSI: 00000000000002d0 RDI: 000000005b835f90
> [    0.114006] RBP: ffffffff8195bf38 R08: 0000000000000001 R09: 0000090fbc802000
> [    0.121116] R10: ffff88ffbcc07340 R11: 0000000000000001 R12: 0000000000000001
> [    0.128225] R13: 0000090fbc802000 R14: 00000000000002d0 R15: 0000000000000001
> [    0.135336] FS:  0000000000000000(0000) GS:ffffc90000000000(0000) knlGS:0000000000000000
> [    0.143398] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [    0.149124] CR2: 000000005b835f90 CR3: 0000000001966000 CR4: 00000000000606b0
> [    0.156234] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [    0.163344] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> [    0.170454] Call Trace:
> [    0.172899]  [<ffffffff8107512c>] ? efi_call4+0x6c/0xf0

EFI old memmap have NX bit set. Immediate workaround is remove that 
cmdline parameter. I have also submitted proposed fix here:

	http://lkml.kernel.org/r/alpine.LRH.2.00.1801051909160.27010@gjva.wvxbf.pm

-- 
Jiri Kosina
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
