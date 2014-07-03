Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id D3CB06B0035
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 04:14:47 -0400 (EDT)
Received: by mail-ig0-f179.google.com with SMTP id uq10so1201468igb.0
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 01:14:47 -0700 (PDT)
Received: from mail-ig0-x22f.google.com (mail-ig0-x22f.google.com [2607:f8b0:4001:c05::22f])
        by mx.google.com with ESMTPS id z8si23918048igl.40.2014.07.03.01.14.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 03 Jul 2014 01:14:46 -0700 (PDT)
Received: by mail-ig0-f175.google.com with SMTP id h3so7619326igd.8
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 01:14:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140703080832.GA2969@kernel>
References: <CAAiL-puUPeHTCBOEA-JrSv52J3QRm68d=HYQ9J7R=aY95Sjn2w@mail.gmail.com>
	<20140703080832.GA2969@kernel>
Date: Thu, 3 Jul 2014 01:14:46 -0700
Message-ID: <CAAiL-puVFPT=m24r=w9DCpcH5dM0w5gWPDgUrBscZdttwj7udg@mail.gmail.com>
Subject: Re: copy_huge_page: unable to handle kernel NULL pointer dereference
 at 0000000000000008
From: jipan yang <jipan.yang@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <wanpeng.li@linux.intel.com>
Cc: linux-mm@kvack.org, kvm@vger.kernel.org

cc linux-mm as suggested by Wanpeng.

[ 2423.567961] BUG: unable to handle kernel NULL pointer dereference
at 0000000000000008
[ 2423.568252] IP: [<ffffffff8118d0fa>] copy_huge_page+0x8a/0x2a0
[ 2423.568465] PGD 0
[ 2423.568535] Oops: 0000 [#1] SMP
[ 2423.568658] Modules linked in: ip6table_filter ip6_tables
ebtable_nat ebtables ipt_MASQUERADE iptable_nat nf_nat_ipv4 nf_nat
nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT
xt_CHECKSUM iptable_mangle xt_tcpudp iptable_filter ip_tables x_tables
kvm_intel kvm bridge stp ast ttm drm_kms_helper drm llc sysimgblt
sysfillrect syscopyarea ioatdma shpchp joydev dcdbas mei_me mei
mac_hid lpc_ich acpi_pad wmi lp ext2 parport hid_generic usbhid hid
ixgbe igb ahci dca i2c_algo_bit libahci ptp pps_core mdio
[ 2423.570426] CPU: 16 PID: 2869 Comm: qemu-system-x86 Not tainted
3.11.0-15-generic #25~precise1-Ubuntu
[ 2423.570763] Hardware name: Dell Inc. PowerEdge C6220 II/09N44V,
BIOS 2.0.3 07/03/2013
[ 2423.571046] task: ffff88101de89770 ti: ffff88101df22000 task.ti:
ffff88101df22000
[ 2423.571314] RIP: 0010:[<ffffffff8118d0fa>]  [<ffffffff8118d0fa>]
copy_huge_page+0x8a/0x2a0
[ 2423.571609] RSP: 0018:ffff88101df23768  EFLAGS: 00010246
[ 2423.571797] RAX: 0000000000200000 RBX: ffffffff81f9aa20 RCX: 0000000000000012
[ 2423.572052] RDX: ffffffff81f9aa20 RSI: 0000000000001000 RDI: ffffea007bf20000
[ 2423.572307] RBP: ffff88101df237b8 R08: 0000000000000000 R09: 0000000000000200
[ 2423.572562] R10: 0000000000000000 R11: 0000000000017960 R12: ffffea007bf20000
[ 2423.572816] R13: 0000000000000001 R14: 020400000008407d R15: ffffea0040438000
[ 2423.573074] FS:  00007f40cffff700(0000) GS:ffff88203eec0000(0000)
knlGS:0000000000000000
[ 2423.573366] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 2423.573570] CR2: 0000000000000008 CR3: 0000002024247000 CR4: 00000000001427e0
[ 2423.573825] Stack:
[ 2423.573889]  ffff88101df23788 ffffffff81156460 ffff88207fff8000
ffffea007bf20000
[ 2423.574151]  ffff88101df23798 ffffea0040438000 ffffea007bf20000
0000000000000001
[ 2423.574414]  020400000008407d ffff88101b341250 ffff88101df237e8
ffffffff8119fee9
[ 2423.574675] Call Trace:
[ 2423.574765]  [<ffffffff81156460>] ? put_compound_page+0x40/0x70
[ 2423.574980]  [<ffffffff8119fee9>] migrate_page_copy+0x39/0x250
[ 2423.575190]  [<ffffffff811a171c>]
migrate_misplaced_transhuge_page+0x16c/0x4d0
[ 2423.575454]  [<ffffffff811a4429>] do_huge_pmd_numa_page+0x169/0x2d0
[ 2423.575682]  [<ffffffff8115b92b>] ? putback_lru_page+0x5b/0xc0
[ 2423.575894]  [<ffffffff81174014>] handle_mm_fault+0x2c4/0x3e0
[ 2423.576103]  [<ffffffff8105a31a>] ? gup_pmd_range+0xaa/0xf0
[ 2423.576303]  [<ffffffff81174378>] __get_user_pages+0x178/0x5c0
[ 2423.576516]  [<ffffffff8105a340>] ? gup_pmd_range+0xd0/0xf0
[ 2423.576737]  [<ffffffffa0223bee>] hva_to_pfn_slow+0x9e/0x150 [kvm]
[ 2423.576971]  [<ffffffffa02258e5>] hva_to_pfn+0xd5/0x210 [kvm]
[ 2423.577188]  [<ffffffffa0225730>] ? kvm_release_pfn_clean+0x50/0x60 [kvm]
[ 2423.577452]  [<ffffffffa02463c8>] ? mmu_set_spte+0x138/0x270 [kvm]
[ 2423.577685]  [<ffffffffa0225acd>] __gfn_to_pfn_memslot+0xad/0xb0 [kvm]
[ 2423.577930]  [<ffffffffa0225b47>] __gfn_to_pfn+0x57/0x70 [kvm]
[ 2423.578149]  [<ffffffffa0225bba>] gfn_to_pfn_async+0x1a/0x20 [kvm]
[ 2423.578387]  [<ffffffffa024553a>] try_async_pf+0x4a/0x90 [kvm]
[ 2423.578607]  [<ffffffffa0227bbb>] ? kvm_host_page_size+0x9b/0xb0 [kvm]
[ 2423.587202]  [<ffffffffa0247c9b>] tdp_page_fault+0x10b/0x220 [kvm]
[ 2423.595850]  [<ffffffffa0244861>] kvm_mmu_page_fault+0x31/0x70 [kvm]
[ 2423.604557]  [<ffffffffa02b83de>] handle_ept_violation+0x7e/0x150 [kvm_intel]
[ 2423.613164]  [<ffffffffa02bc277>] vmx_handle_exit+0xa7/0x270 [kvm_intel]
[ 2423.621586]  [<ffffffffa023d1a7>] vcpu_enter_guest+0x447/0x770 [kvm]
[ 2423.629990]  [<ffffffffa02559c9>] ? kvm_apic_local_deliver+0x69/0x70 [kvm]
[ 2423.638546]  [<ffffffffa023d688>] __vcpu_run+0x1b8/0x2f0 [kvm]
[ 2423.646872]  [<ffffffffa023d85d>] kvm_arch_vcpu_ioctl_run+0x9d/0x170 [kvm]
[ 2423.654980]  [<ffffffffa022614b>] kvm_vcpu_ioctl+0x43b/0x600 [kvm]
[ 2423.662816]  [<ffffffff811c5f9c>] do_vfs_ioctl+0x7c/0x2f0
[ 2423.670388]  [<ffffffff811c62a1>] SyS_ioctl+0x91/0xb0
[ 2423.677695]  [<ffffffff8175099d>] system_call_fastpath+0x1a/0x1f
[ 2423.684854] Code: f9 81 48 d3 e6 48 39 c6 74 2a be 00 10 00 00 eb
0e 8b 4b 08 48 89 f7 48 d3 e7 48 39 c7 74 15 48 81 c3 60 0b 00 00 48
39 d3 72 e6 <8b> 0c 25 08 00 00 00 31 db 41 bc 01 00 00 00 44 89 e0 d3
e0 3d
[ 2423.699824] RIP  [<ffffffff8118d0fa>] copy_huge_page+0x8a/0x2a0
[ 2423.707111]  RSP <ffff88101df23768>
[ 2423.714230] CR2: 0000000000000008
[ 2423.784650] ---[ end trace f686f7a0c554a317 ]---
[ 2423.792015] BUG: unable to handle kernel NULL pointer dereference
at 0000000000000008
[ 2423.799305] IP: [<ffffffff8118d0fa>] copy_huge_page+0x8a/0x2a0
[ 2423.806618] PGD 0
[ 2423.813866] Oops: 0000 [#2] SMP
[ 2423.821032] Modules linked in: ip6table_filter ip6_tables
ebtable_nat ebtables ipt_MASQUERADE iptable_nat nf_nat_ipv4 nf_nat
nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT
xt_CHECKSUM iptable_mangle xt_tcpudp iptable_filter ip_tables x_tables
kvm_intel kvm bridge stp ast ttm drm_kms_helper drm llc sysimgblt
sysfillrect syscopyarea ioatdma shpchp joydev dcdbas mei_me mei
mac_hid lpc_ich acpi_pad wmi lp ext2 parport hid_generic usbhid hid
ixgbe igb ahci dca i2c_algo_bit libahci ptp pps_core mdio
[ 2423.860767] CPU: 30 PID: 2868 Comm: qemu-system-x86 Tainted: G
D      3.11.0-15-generic #25~precise1-Ubuntu
[ 2423.869230] Hardware name: Dell Inc. PowerEdge C6220 II/09N44V,
BIOS 2.0.3 07/03/2013
[ 2423.877709] task: ffff88101de8c650 ti: ffff88101dcf6000 task.ti:
ffff88101dcf6000
[ 2423.886219] RIP: 0010:[<ffffffff8118d0fa>]  [<ffffffff8118d0fa>]
copy_huge_page+0x8a/0x2a0
[ 2423.894870] RSP: 0018:ffff88101dcf7768  EFLAGS: 00010246
[ 2423.903508] RAX: 0000000000200000 RBX: ffffffff81f9aa20 RCX: 0000000000000012
[ 2423.912224] RDX: ffffffff81f9aa20 RSI: 0000000000001000 RDI: ffffea007bf28000
[ 2423.920978] RBP: ffff88101dcf77b8 R08: 0000000000000000 R09: 0000000000000200
[ 2423.929723] R10: 0000000000000000 R11: 0000000000017960 R12: ffffea007bf28000
[ 2423.938533] R13: 0000000000000001 R14: 020400000008407d R15: ffffea0040430000
[ 2423.947276] FS:  00007f40d4a14700(0000) GS:ffff88203ef40000(0000)
knlGS:0000000000000000
[ 2423.956170] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 2423.965049] CR2: 0000000000000008 CR3: 0000002024247000 CR4: 00000000001427e0
[ 2423.974071] Stack:
[ 2423.982952]  ffff88101dcf7788 ffffffff81156460 ffff88207fff8000
ffffea007bf28000
[ 2423.992109]  ffff88101dcf7798 ffffea0040430000 ffffea007bf28000
0000000000000001
[ 2424.001262]  020400000008407d ffff88101b341248 ffff88101dcf77e8
ffffffff8119fee9
[ 2424.010524] Call Trace:
[ 2424.019660]  [<ffffffff81156460>] ? put_compound_page+0x40/0x70
[ 2424.028987]  [<ffffffff8119fee9>] migrate_page_copy+0x39/0x250
[ 2424.038322]  [<ffffffff811a171c>]
migrate_misplaced_transhuge_page+0x16c/0x4d0
[ 2424.047705]  [<ffffffff811a4429>] do_huge_pmd_numa_page+0x169/0x2d0
[ 2424.057070]  [<ffffffff8116e441>] ? pte_offset_kernel+0x1/0x40
[ 2424.066392]  [<ffffffff81174014>] handle_mm_fault+0x2c4/0x3e0
[ 2424.075687]  [<ffffffff8105a31a>] ? gup_pmd_range+0xaa/0xf0
[ 2424.084969]  [<ffffffff81174378>] __get_user_pages+0x178/0x5c0
[ 2424.094200]  [<ffffffff8105a340>] ? gup_pmd_range+0xd0/0xf0
[ 2424.103406]  [<ffffffffa0223bee>] hva_to_pfn_slow+0x9e/0x150 [kvm]
[ 2424.112654]  [<ffffffffa02258e5>] hva_to_pfn+0xd5/0x210 [kvm]
[ 2424.121835]  [<ffffffffa0225730>] ? kvm_release_pfn_clean+0x50/0x60 [kvm]
[ 2424.131042]  [<ffffffffa02463c8>] ? mmu_set_spte+0x138/0x270 [kvm]
[ 2424.140272]  [<ffffffffa0225acd>] __gfn_to_pfn_memslot+0xad/0xb0 [kvm]
[ 2424.149499]  [<ffffffffa0225b47>] __gfn_to_pfn+0x57/0x70 [kvm]
[ 2424.158500]  [<ffffffffa0225bba>] gfn_to_pfn_async+0x1a/0x20 [kvm]
[ 2424.167356]  [<ffffffffa024553a>] try_async_pf+0x4a/0x90 [kvm]
[ 2424.176108]  [<ffffffffa0227bbb>] ? kvm_host_page_size+0x9b/0xb0 [kvm]
[ 2424.184821]  [<ffffffffa0247c9b>] tdp_page_fault+0x10b/0x220 [kvm]
[ 2424.193567]  [<ffffffffa0244861>] kvm_mmu_page_fault+0x31/0x70 [kvm]
[ 2424.202318]  [<ffffffffa02b83de>] handle_ept_violation+0x7e/0x150 [kvm_intel]
[ 2424.211047]  [<ffffffffa02bc277>] vmx_handle_exit+0xa7/0x270 [kvm_intel]
[ 2424.219700]  [<ffffffffa023d1a7>] vcpu_enter_guest+0x447/0x770 [kvm]
[ 2424.228314]  [<ffffffffa023d688>] __vcpu_run+0x1b8/0x2f0 [kvm]
[ 2424.237033]  [<ffffffffa023d85d>] kvm_arch_vcpu_ioctl_run+0x9d/0x170 [kvm]
[ 2424.245528]  [<ffffffffa022614b>] kvm_vcpu_ioctl+0x43b/0x600 [kvm]
[ 2424.253757]  [<ffffffff811c5f9c>] do_vfs_ioctl+0x7c/0x2f0
[ 2424.261712]  [<ffffffff811c62a1>] SyS_ioctl+0x91/0xb0
[ 2424.269378]  [<ffffffff81013dc5>] ? do_notify_resume+0x75/0xc0
[ 2424.276860]  [<ffffffff8175099d>] system_call_fastpath+0x1a/0x1f
[ 2424.284189] Code: f9 81 48 d3 e6 48 39 c6 74 2a be 00 10 00 00 eb
0e 8b 4b 08 48 89 f7 48 d3 e7 48 39 c7 74 15 48 81 c3 60 0b 00 00 48
39 d3 72 e6 <8b> 0c 25 08 00 00 00 31 db 41 bc 01 00 00 00 44 89 e0 d3
e0 3d
[ 2424.299626] RIP  [<ffffffff8118d0fa>] copy_huge_page+0x8a/0x2a0
[ 2424.306994]  RSP <ffff88101dcf7768>
[ 2424.314209] CR2: 0000000000000008
[ 2424.321342] ---[ end trace f686f7a0c554a318 ]---




root@arno-3:~# modinfo kvm
filename:       /lib/modules/3.11.0-15-generic/kernel/arch/x86/kvm/kvm.ko
license:        GPL
author:         Qumranet
srcversion:     9A23EA37F64E5A410C92557
depends:
intree:         Y
vermagic:       3.11.0-15-generic SMP mod_unload modversions
parm:           min_timer_period_us:uint
parm:           ignore_msrs:bool
parm:           tsc_tolerance_ppm:uint
parm:           allow_unsafe_assigned_interrupts:Enable device
assignment on platforms without interrupt remapping support. (bool)


root@arno-3:~# cat /proc/cmdline
BOOT_IMAGE=/vmlinuz-3.11.0-15-generic
root=/dev/mapper/arno--3--vg-root ro default_hugepagesz=1G
hugepagesz=1G hugepages=8 isolcpus=0-15


On Thu, Jul 3, 2014 at 1:08 AM, Wanpeng Li <wanpeng.li@linux.intel.com> wrote:
> You should also Cc mm ML
> On Thu, Jul 03, 2014 at 12:57:04AM -0700, jipan yang wrote:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
