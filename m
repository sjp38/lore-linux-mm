Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 593436B0035
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 04:08:01 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id et14so13969364pad.41
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 01:08:01 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id kp9si32391309pbc.11.2014.07.03.01.07.58
        for <linux-mm@kvack.org>;
        Thu, 03 Jul 2014 01:07:59 -0700 (PDT)
Date: Thu, 3 Jul 2014 16:08:32 +0800
From: Wanpeng Li <wanpeng.li@linux.intel.com>
Subject: Re: copy_huge_page: unable to handle kernel NULL pointer dereference
 at 0000000000000008
Message-ID: <20140703080832.GA2969@kernel>
Reply-To: Wanpeng Li <wanpeng.li@linux.intel.com>
References: <CAAiL-puUPeHTCBOEA-JrSv52J3QRm68d=HYQ9J7R=aY95Sjn2w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAiL-puUPeHTCBOEA-JrSv52J3QRm68d=HYQ9J7R=aY95Sjn2w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jipan yang <jipan.yang@gmail.com>
Cc: linux-mm@kvack.org, kvm@vger.kernel.org

You should also Cc mm ML
On Thu, Jul 03, 2014 at 12:57:04AM -0700, jipan yang wrote:
>Hi,
>
>I've seen the problem quite a few times.  Before spending more time on
>it, I'd like to have a quick check here to see if anyone ever saw the
>same problem?  Hope it is a relevant question with this mail list.
>
>
>Jul  2 11:08:21 arno-3 kernel: [ 2165.078623] BUG: unable to handle
>kernel NULL pointer dereference at 0000000000000008
>Jul  2 11:08:21 arno-3 kernel: [ 2165.078916] IP: [<ffffffff8118d0fa>]
>copy_huge_page+0x8a/0x2a0
>Jul  2 11:08:21 arno-3 kernel: [ 2165.079128] PGD 0
>Jul  2 11:08:21 arno-3 kernel: [ 2165.079198] Oops: 0000 [#1] SMP
>Jul  2 11:08:21 arno-3 kernel: [ 2165.079319] Modules linked in:
>ip6table_filter ip6_tables ebtable_nat ebtables ipt_MASQUERADE
>iptable_nat nf_nat_ipv4 nf_nat nf_conntrack_ipv4 nf_defrag_ipv4
>xt_state nf_conntrack ipt_REJECT xt_CHECKSUM iptable_mangle xt_tcpudp
>iptable_filter ip_tables x_tables kvm_intel kvm bridge stp llc ast ttm
>drm_kms_helper drm sysimgblt sysfillrect syscopyarea lp mei_me ioatdma
>ext2 parport mei shpchp dcdbas joydev mac_hid lpc_ich acpi_pad wmi
>hid_generic usbhid hid ixgbe igb dca i2c_algo_bit ahci ptp libahci
>mdio pps_core
>Jul  2 11:08:21 arno-3 kernel: [ 2165.081090] CPU: 19 PID: 3494 Comm:
>qemu-system-x86 Not tainted 3.11.0-15-generic #25~precise1-Ubuntu
>Jul  2 11:08:21 arno-3 kernel: [ 2165.081424] Hardware name: Dell Inc.
>PowerEdge C6220 II/09N44V, BIOS 2.0.3 07/03/2013
>Jul  2 11:08:21 arno-3 kernel: [ 2165.081705] task: ffff881026750000
>ti: ffff881026056000 task.ti: ffff881026056000
>Jul  2 11:08:21 arno-3 kernel: [ 2165.081973] RIP:
>0010:[<ffffffff8118d0fa>]  [<ffffffff8118d0fa>]
>copy_huge_page+0x8a/0x2a0
>Jul  2 11:08:21 arno-3 kernel: [ 2165.082267] RSP:
>0018:ffff881026057768  EFLAGS: 00010246
>Jul  2 11:08:21 arno-3 kernel: [ 2165.082455] RAX: 0000000000200000
>RBX: ffffffff81f9aa20 RCX: 0000000000000012
>Jul  2 11:08:21 arno-3 kernel: [ 2165.082710] RDX: ffffffff81f9aa20
>RSI: 0000000000001000 RDI: ffffea0077f28000
>Jul  2 11:08:21 arno-3 kernel: [ 2165.082963] RBP: ffff8810260577b8
>R08: 0000000000000000 R09: 00000000000001ff
>Jul  2 11:08:21 arno-3 kernel: [ 2165.083217] R10: ffffffffffffffff
>R11: 0000000000017960 R12: ffffea0077f28000
>Jul  2 11:08:21 arno-3 kernel: [ 2165.083471] R13: 0000000000000001
>R14: 020400000008407d R15: ffffea003a9b8000
>Jul  2 11:08:21 arno-3 kernel: [ 2165.083727] FS:
>00007f19d799a700(0000) GS:ffff88203ef20000(0000)
>knlGS:0000000000000000
>Jul  2 11:08:21 arno-3 kernel: [ 2165.084019] CS:  0010 DS: 0000 ES:
>0000 CR0: 0000000080050033
>Jul  2 11:08:21 arno-3 kernel: [ 2165.084222] CR2: 0000000000000008
>CR3: 0000002023b1c000 CR4: 00000000001427e0
>Jul  2 11:08:21 arno-3 kernel: [ 2165.084477] Stack:
>Jul  2 11:08:21 arno-3 kernel: [ 2165.084540]  ffff881026057788
>ffffffff81156460 ffff88207fff8000 ffffea0077f28000
>Jul  2 11:08:21 arno-3 kernel: [ 2165.084802]  ffff881026057798
>ffffea003a9b8000 ffffea0077f28000 0000000000000001
>Jul  2 11:08:21 arno-3 kernel: [ 2165.085064]  020400000008407d
>ffff881026f11260 ffff8810260577e8 ffffffff8119fee9
>Jul  2 11:08:21 arno-3 kernel: [ 2165.085326] Call Trace:
>Jul  2 11:08:21 arno-3 kernel: [ 2165.085418]  [<ffffffff81156460>] ?
>put_compound_page+0x40/0x70
>Jul  2 11:08:21 arno-3 kernel: [ 2165.085633]  [<ffffffff8119fee9>]
>migrate_page_copy+0x39/0x250
>Jul  2 11:08:21 arno-3 kernel: [ 2165.085844]  [<ffffffff811a171c>]
>migrate_misplaced_transhuge_page+0x16c/0x4d0
>Jul  2 11:08:21 arno-3 kernel: [ 2165.086106]  [<ffffffff811a4429>]
>do_huge_pmd_numa_page+0x169/0x2d0
>Jul  2 11:08:21 arno-3 kernel: [ 2165.086332]  [<ffffffff81174014>]
>handle_mm_fault+0x2c4/0x3e0
>Jul  2 11:08:21 arno-3 kernel: [ 2165.086539]  [<ffffffff81174378>]
>__get_user_pages+0x178/0x5c0
>Jul  2 11:08:21 arno-3 kernel: [ 2165.086756]  [<ffffffff8105a340>] ?
>gup_pmd_range+0xd0/0xf0
>Jul  2 11:08:21 arno-3 kernel: [ 2165.086972]  [<ffffffffa0228bee>]
>hva_to_pfn_slow+0x9e/0x150 [kvm]
>Jul  2 11:08:21 arno-3 kernel: [ 2165.087206]  [<ffffffffa022a8e5>]
>hva_to_pfn+0xd5/0x210 [kvm]
>Jul  2 11:08:21 arno-3 kernel: [ 2165.087423]  [<ffffffffa022a730>] ?
>kvm_release_pfn_clean+0x50/0x60 [kvm]
>Jul  2 11:08:21 arno-3 kernel: [ 2165.087686]  [<ffffffffa024b3c8>] ?
>mmu_set_spte+0x138/0x270 [kvm]
>Jul  2 11:08:21 arno-3 kernel: [ 2165.087920]  [<ffffffffa022aacd>]
>__gfn_to_pfn_memslot+0xad/0xb0 [kvm]
>Jul  2 11:08:21 arno-3 kernel: [ 2165.088166]  [<ffffffffa022ab47>]
>__gfn_to_pfn+0x57/0x70 [kvm]
>Jul  2 11:08:21 arno-3 kernel: [ 2165.088389]  [<ffffffffa022abba>]
>gfn_to_pfn_async+0x1a/0x20 [kvm]
>Jul  2 11:08:21 arno-3 kernel: [ 2165.088628]  [<ffffffffa024a53a>]
>try_async_pf+0x4a/0x90 [kvm]
>Jul  2 11:08:21 arno-3 kernel: [ 2165.088849]  [<ffffffffa022cbbb>] ?
>kvm_host_page_size+0x9b/0xb0 [kvm]
>Jul  2 11:08:21 arno-3 kernel: [ 2165.089098]  [<ffffffffa024cc9b>]
>tdp_page_fault+0x10b/0x220 [kvm]
>Jul  2 11:08:21 arno-3 kernel: [ 2165.089334]  [<ffffffffa0249861>]
>kvm_mmu_page_fault+0x31/0x70 [kvm]
>Jul  2 11:08:21 arno-3 kernel: [ 2165.098035]  [<ffffffffa02e03de>]
>handle_ept_violation+0x7e/0x150 [kvm_intel]
>Jul  2 11:08:21 arno-3 kernel: [ 2165.106835]  [<ffffffffa02e4277>]
>vmx_handle_exit+0xa7/0x270 [kvm_intel]
>Jul  2 11:08:21 arno-3 kernel: [ 2165.115677]  [<ffffffffa02421a7>]
>vcpu_enter_guest+0x447/0x770 [kvm]
>Jul  2 11:08:21 arno-3 kernel: [ 2165.124374]  [<ffffffff8107548f>] ?
>recalc_sigpending+0x1f/0x60
>Jul  2 11:08:21 arno-3 kernel: [ 2165.132901]  [<ffffffffa0242688>]
>__vcpu_run+0x1b8/0x2f0 [kvm]
>Jul  2 11:08:21 arno-3 kernel: [ 2165.141395]  [<ffffffffa024285d>]
>kvm_arch_vcpu_ioctl_run+0x9d/0x170 [kvm]
>Jul  2 11:08:21 arno-3 kernel: [ 2165.149999]  [<ffffffffa022b14b>]
>kvm_vcpu_ioctl+0x43b/0x600 [kvm]
>Jul  2 11:08:21 arno-3 kernel: [ 2165.158390]  [<ffffffff811c5f9c>]
>do_vfs_ioctl+0x7c/0x2f0
>Jul  2 11:08:21 arno-3 kernel: [ 2165.166509]  [<ffffffff811c62a1>]
>SyS_ioctl+0x91/0xb0
>Jul  2 11:08:21 arno-3 kernel: [ 2165.174332]  [<ffffffff81013dc5>] ?
>do_notify_resume+0x75/0xc0
>Jul  2 11:08:21 arno-3 kernel: [ 2165.181934]  [<ffffffff8175099d>]
>system_call_fastpath+0x1a/0x1f
>Jul  2 11:08:21 arno-3 kernel: [ 2165.189323] Code: f9 81 48 d3 e6 48
>39 c6 74 2a be 00 10 00 00 eb 0e 8b 4b 08 48 89 f7 48 d3 e7 48 39 c7
>74 15 48 81 c3 60 0b 00 00 48 39 d3 72 e6 <8b> 0c 25 08 00 00 00 31 db
>41 bc 01 00 00 00 44 89 e0 d3 e0 3d
>Jul  2 11:08:21 arno-3 kernel: [ 2165.204645] RIP
>[<ffffffff8118d0fa>] copy_huge_page+0x8a/0x2a0
>Jul  2 11:08:21 arno-3 kernel: [ 2165.212110]  RSP <ffff881026057768>
>Jul  2 11:08:21 arno-3 kernel: [ 2165.219402] CR2: 0000000000000008
>Jul  2 11:08:21 arno-3 kernel: [ 2165.289865] ---[ end trace
>f74046a6ced0c2fb ]---
>
>
>
>root@arno-3:~# modinfo kvm
>filename:       /lib/modules/3.11.0-15-generic/kernel/arch/x86/kvm/kvm.ko
>license:        GPL
>author:         Qumranet
>srcversion:     9A23EA37F64E5A410C92557
>depends:
>intree:         Y
>vermagic:       3.11.0-15-generic SMP mod_unload modversions
>parm:           min_timer_period_us:uint
>parm:           ignore_msrs:bool
>parm:           tsc_tolerance_ppm:uint
>parm:           allow_unsafe_assigned_interrupts:Enable device
>assignment on platforms without interrupt remapping support. (bool)
>
>
>root@arno-3:~# cat /proc/cmdline
>BOOT_IMAGE=/vmlinuz-3.11.0-15-generic
>root=/dev/mapper/arno--3--vg-root ro default_hugepagesz=1G
>hugepagesz=1G hugepages=8 isolcpus=0-15
>
>
>root@arno-3:~# cat /proc/cpuinfo
>processor : 0
>vendor_id : GenuineIntel
>cpu family : 6
>model : 62
>model name : Intel(R) Xeon(R) CPU E5-2660 v2 @ 2.20GHz
>stepping : 4
>microcode : 0x415
>cpu MHz : 1200.000
>cache size : 25600 KB
>physical id : 0
>siblings : 20
>core id : 0
>cpu cores : 10
>apicid : 0
>initial apicid : 0
>fpu : yes
>fpu_exception : yes
>cpuid level : 13
>wp : yes
>flags : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
>pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx
>pdpe1gb rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl
>xtopology nonstop_tsc aperfmperf eagerfpu pni pclmulqdq dtes64 monitor
>ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm pcid dca sse4_1 sse4_2
>x2apic popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm ida
>arat epb xsaveopt pln pts dtherm tpr_shadow vnmi flexpriority ept vpid
>fsgsbase smep erms
>bogomips : 4399.71
>clflush size : 64
>cache_alignment : 64
>address sizes : 46 bits physical, 48 bits virtual
>power management:
>....................................................................
>processor : 39
>vendor_id : GenuineIntel
>cpu family : 6
>model : 62
>model name : Intel(R) Xeon(R) CPU E5-2660 v2 @ 2.20GHz
>stepping : 4
>microcode : 0x415
>cpu MHz : 1200.000
>cache size : 25600 KB
>physical id : 1
>siblings : 20
>core id : 12
>cpu cores : 10
>apicid : 57
>initial apicid : 57
>fpu : yes
>fpu_exception : yes
>cpuid level : 13
>wp : yes
>flags : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
>pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx
>pdpe1gb rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl
>xtopology nonstop_tsc aperfmperf eagerfpu pni pclmulqdq dtes64 monitor
>ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm pcid dca sse4_1 sse4_2
>x2apic popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm ida
>arat epb xsaveopt pln pts dtherm tpr_shadow vnmi flexpriority ept vpid
>fsgsbase smep erms
>bogomips : 4401.16
>clflush size : 64
>cache_alignment : 64
>address sizes : 46 bits physical, 48 bits virtual
>power management:
>
>root@arno-3:~#
>
>
> qemu-system-x86_64 -cpu host -boot c -drive
>file=./dev_stack_ubuntu_12_04.img  -m 4092 -cpu host  -smp 2 -device
>e1000,netdev=net0,mac=DE:AD:BE:EF:03:EF -netdev
>tap,id=net0,script=qemu-ifup  --enable-kvm  -monitor
>telnet:127.0.0.1:1234,server,nowait  -nographic -serial stdio -vnc :66
>
>Thanks,
>Jipan
>--
>To unsubscribe from this list: send the line "unsubscribe kvm" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
