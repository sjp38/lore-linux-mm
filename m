Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id A7A87280283
	for <linux-mm@kvack.org>; Sat,  6 Jan 2018 01:49:40 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id 60so3436900otc.8
        for <linux-mm@kvack.org>; Fri, 05 Jan 2018 22:49:40 -0800 (PST)
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id d9si1463367otc.296.2018.01.05.22.49.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jan 2018 22:49:39 -0800 (PST)
Message-ID: <5A50708A.9010902@huawei.com>
Date: Sat, 6 Jan 2018 14:45:30 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC] boot failed when enable KAISER/KPTI
References: <5A4F09B7.8010402@huawei.com> <alpine.LRH.2.00.1801051930370.27010@gjva.wvxbf.pm>
In-Reply-To: <alpine.LRH.2.00.1801051930370.27010@gjva.wvxbf.pm>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jikos@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, dave.hansen@linux.intel.com
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Yisheng Xie <xieyisheng1@huawei.com>, "Wangkefeng (Maro)" <wangkefeng.wang@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Zhao
 Hongjiang <zhaohongjiang@huawei.com>

On 2018/1/6 2:33, Jiri Kosina wrote:

> On Fri, 5 Jan 2018, Xishi Qiu wrote:
> 
>> I run the latest RHEL 7.2 with the KAISER/KPTI patch, and boot failed.
>>
>> ...
>> [    0.000000] PM: Registered nosave memory: [mem 0x81000000000-0x8ffffffffff]
>> [    0.000000] PM: Registered nosave memory: [mem 0x91000000000-0xfffffffffff]
>> [    0.000000] PM: Registered nosave memory: [mem 0x101000000000-0x10ffffffffff]
>> [    0.000000] PM: Registered nosave memory: [mem 0x111000000000-0x17ffffffffff]
>> [    0.000000] PM: Regitered nosave memory: [mem 0x181000000000-0x18ffffffffff]
>> [    0.000000] e820: [mem 0x90000000-0xfed1bfff] available for PCI devices
>> [    0.000000] Booting paravirtualized kernel on bare hardware
>> [    0.000000] setup_percpu: NR_CPUS:5120 nr_cpumask_bits:1536 nr_cpu_ids:1536 nr_node_ids:8
>> [    0.000000] PERCPU: max_distance=0x180ffe240000 too large for vmalloc space 0x1fffffffffff
>> [    0.000000] setup_percpu: auto allocator failed (-22), falling back to page size
>> [    0.000000] PERCPU: 32 4K pages/cpu @ffffc90000000000 s107200 r8192 d15680
>> [    0.000000] Built 8 zonelists in Zone order, mobility grouping on.  Total pages: 132001804
>> [    0.000000] Policy zone: Normal
>> iosdevname=0 8250.nr_uarts=8 efi=old_map rdloaddriver=usb_storage rdloaddriver=sd_mod udev.event-timeout=600 softlockup_panic=0 rcupdate.rcu_cpu_stall_timeout=300
>> [    0.000000] Intel-IOMMU: enabled
>> [    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
>> [    0.000000] x86/fpu: xstate_offset[2]: 0240, xstate_sizes[2]: 0100
>> [    0.000000] xsave: enabled xstate_bv 0x7, cntxt size 0x340
>> [    0.000000] AGP: Checking aperture...
>> [    0.000000] AGP: No AGP bridge found
>> [    0.000000] Memory: 526901612k/26910638080k available (6528k kernel code, 26374249692k absent, 9486776k reserved, 4302k data, 1676k init)
>> [    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=1536, Nodes=8
>> [    0.000000] x86/pti: Unmapping kernel while in userspace
>> [    0.000000] Hierarchical RCU implementation.
>> [    0.000000] 	RCU restricting CPUs from NR_CPUS=5120 to nr_cpu_ids=1536.
>> [    0.000000] 	Offload RCU callbacks from all CPUs
>> [    0.000000] 	Offload RCU callbacks from CPUs: 0-1535.
>> [    0.000000] NR_IRQS:327936 nr_irqs:15976 0
>> [    0.000000] Console: colour dummy device 80x25
>> [    0.000000] console [tty0] enabled
>> [    0.000000] console [ttyS0] enabled
>> [    0.000000] allocated 2145910784 bytes of page_cgroup
>> [    0.000000] please try 'cgroup_disable=memory' option if you don't want memory cgroups
>> [    0.000000] Enabling automatic NUMA balancing. Configure with numa_balancing= or the kernel.numa_balancing sysctl
>> [    0.000000] tsc: Fast TSC calibration using PIT
>> [    0.000000] tsc: Detected 2799.999 MHz processor
>> [    0.001803] Calibrating delay loop (skipped), value calculated using timer frequency.. 5599.99 BogoMIPS (lpj=2799999)
>> [    0.012408] pid_max: default: 1572864 minimum: 12288
>> [    0.017987] init_memory_mapping: [mem 0x5947f000-0x5b47efff]
>> [    0.023701] init_memory_mapping: [mem 0x5b47f000-0x5b87efff]
>> [    0.029369] init_memory_mapping: [mem 0x6d368000-0x6d3edfff]
>> [    0.039130] BUG: unable to handle kernel paging request at 000000005b835f90
>> [    0.046101] IP: [<000000005b835f90>] 0x5b835f8f
>> [    0.050637] PGD 8000000001f61067 PUD 190ffefff067 PMD 190ffeffd067 PTE 5b835063
>> [    0.057989] Oops: 0011 [#1] SMP 
>> [    0.061241] Modules linked in:
>> [    0.064304] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.10.0-327.59.59.46.h42.x86_64 #1
>> [    0.072280] Hardware name: Huawei FusionServer9032/IT91SMUB, BIOS BLXSV316 11/14/2017
>> [    0.080082] task: ffffffff8196e440 ti: ffffffff81958000 task.ti: ffffffff81958000
>> [    0.087539] RIP: 0010:[<000000005b835f90>]  [<000000005b835f90>] 0x5b835f8f
>> [    0.094494] RSP: 0000:ffffffff8195be28  EFLAGS: 00010046
>> [    0.099788] RAX: 0000000080050033 RBX: ffff910fbc802000 RCX: 00000000000002d0
>> [    0.106897] RDX: 0000000000000030 RSI: 00000000000002d0 RDI: 000000005b835f90
>> [    0.114006] RBP: ffffffff8195bf38 R08: 0000000000000001 R09: 0000090fbc802000
>> [    0.121116] R10: ffff88ffbcc07340 R11: 0000000000000001 R12: 0000000000000001
>> [    0.128225] R13: 0000090fbc802000 R14: 00000000000002d0 R15: 0000000000000001
>> [    0.135336] FS:  0000000000000000(0000) GS:ffffc90000000000(0000) knlGS:0000000000000000
>> [    0.143398] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [    0.149124] CR2: 000000005b835f90 CR3: 0000000001966000 CR4: 00000000000606b0
>> [    0.156234] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>> [    0.163344] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
>> [    0.170454] Call Trace:
>> [    0.172899]  [<ffffffff8107512c>] ? efi_call4+0x6c/0xf0
> 
> EFI old memmap have NX bit set. Immediate workaround is remove that 
> cmdline parameter. I have also submitted proposed fix here:
> 
> 	http://lkml.kernel.org/r/alpine.LRH.2.00.1801051909160.27010@gjva.wvxbf.pm
> 

Hi Jiri,

Your patch fix the boot problem from efi, thanks.

I have another problem during reboot, it seems the same cause(NX flag).

How about this fix patch? I tested and it works.

diff --git a/arch/x86/kernel/tboot.c b/arch/x86/kernel/tboot.c
index 088681d..f6c32f5 100644
--- a/arch/x86/kernel/tboot.c
+++ b/arch/x86/kernel/tboot.c
@@ -131,6 +131,8 @@ static int map_tboot_page(unsigned long vaddr, unsigned long pfn,
 	pud = pud_alloc(&tboot_mm, pgd, vaddr);
 	if (!pud)
 		return -1;
+	if (__supported_pte_mask & _PAGE_NX)
+		pgd->pgd &= ~_PAGE_NX;
 	pmd = pmd_alloc(&tboot_mm, pud, vaddr);
 	if (!pmd)
 		return -1;

Here is the failed log.
...
[ 1911.622675] BUG: unable to handle kernel paging request at 00000000008041c0
[ 1911.629880] IP: [<00000000008041c0>] 0x8041bf
[ 1911.634389] PGD 80000010272cb067 PUD 2025178067 PMD 10272d8067 PTE 804063
[ 1911.641472] Oops: 0011 [#1] SMP 
[ 1911.644847] oom or die happens after reboot! last event=0x24, last cpu=0.
[ 1911.651833] event maps(bit5-bit0): die-oom-intermit-reboot-emerge-panic
[ 1911.660868] collected_len = 100273, LOG_BUF_LEN_LOCAL = 1048576
[ 1911.698656] kbox: notify die begin
[ 1911.702156] kbox: no notify die func register. no need to notify
[ 1911.708336] do nothing after die!
[ 1911.711748] Modules linked in: bum(O) ip_set nfnetlink prio(O) nat(O) vport_vxlan(O) openvswitch(O) nf_defrag_ipv6 gre kboxdriver(O) kbox(O) signo_catch(O) vfat fat tg3 intel_powerclamp coretemp intel_rapl crc32_pclmul crc32c_intel ghash_clmulni_intel aesni_intel i2c_i801 kvm_intel(O) ptp lrw gf128mul i2c_core glue_helper ablk_helper pps_core kvm(O) cryptd iTCO_wdt iTCO_vendor_support sg pcspkr lpc_ich mfd_core sb_edac mei_me edac_core mei shpchp acpi_power_meter acpi_pad remote_trigger(O) nf_conntrack_ipv4 nf_defrag_ipv4 vhost_net(O) tun(O) vhost(O) macvtap macvlan vfio_pci irqbypass vfio_iommu_type1 vfio xt_sctp nf_conntrack_proto_sctp nf_nat_proto_sctp nf_nat nf_conntrack sctp libcrc32c ip_tables ext3 mbcache jbd sr_mod sd_mod cdrom lpfc crc_t10dif ahci crct10dif_generic crct10dif_pclmul libahci scsi_transport_fc scsi_tgt crct10dif_common libata usb_storage megaraid_sas dm_mod [last unloaded: dev_connlimit]
[ 1911.796711] CPU: 0 PID: 12033 Comm: reboot Tainted: G           OE  ---- -------   3.10.0-327.61.59.66_22.x86_64 #1
[ 1911.807449] Hardware name: Huawei RH2288H V3/BC11HGSA0, BIOS 3.79 11/07/2017
[ 1911.814702] task: ffff881025a91700 ti: ffff8810267fc000 task.ti: ffff8810267fc000
[ 1911.822401] RIP: 0010:[<00000000008041c0>]  [<00000000008041c0>] 0x8041bf
[ 1911.829407] RSP: 0018:ffff8810267ffd50  EFLAGS: 00010086
[ 1911.834877] RAX: 00000000008041c0 RBX: 0000000000000000 RCX: ffffffffff425000
[ 1911.842220] RDX: ffff8820a4e40000 RSI: 000000000000c000 RDI: 0000002024e40000
[ 1911.849563] RBP: ffff8810267ffd60 R08: ffff882024e40000 R09: 0000000000000000
[ 1911.856908] R10: ffffffff81a8f300 R11: ffff8810267ffaae R12: 0000000028121969
[ 1911.864250] R13: ffffffff819aa8a0 R14: 0000000000000cf9 R15: 0000000000000000
[ 1911.871596] FS:  00007f89d6143880(0000) GS:ffff881040400000(0000) knlGS:0000000000000000
[ 1911.879921] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1911.885836] CR2: 00000000008041c0 CR3: 0000002024e40000 CR4: 00000000001607f0
[ 1911.893180] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1911.900522] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 1911.907863] Call Trace:
[ 1911.910384]  [<ffffffff810241ab>] ? tboot_shutdown+0x5b/0x140
[ 1911.916298]  [<ffffffff8104723c>] native_machine_emergency_restart+0x4c/0x250
[ 1911.923641]  [<ffffffff8104c102>] ? disconnect_bsp_APIC+0x82/0xc0
[ 1911.929913]  [<ffffffff81046e17>] native_machine_restart+0x37/0x40
[ 1911.936273]  [<ffffffff810470ef>] machine_restart+0xf/0x20
[ 1911.941923]  [<ffffffff8109af95>] kernel_restart+0x45/0x60
[ 1911.947570]  [<ffffffff8109b1d9>] SYSC_reboot+0x229/0x260
[ 1911.953132]  [<ffffffff811ef665>] ? vfs_writev+0x35/0x60
[ 1911.958603]  [<ffffffff8109b27e>] SyS_reboot+0xe/0x10
[ 1911.963806]  [<ffffffff8165e43d>] system_call_fastpath+0x16/0x1b
[ 1911.969987] Code:  Bad RIP value.
[ 1911.973448] RIP  [<00000000008041c0>] 0x8041bf
[ 1911.978044]  RSP <ffff8810267ffd50>
[ 1911.990106] CR2: 00000000008041c0
[ 1912.001889] ---[ end trace e8475aee26ff7d9f ]---
[ 1912.408111] Kernel panic - not syncing: Fatal exception


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
