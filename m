Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mA82OfU9024731
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 8 Nov 2008 11:24:42 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 680A52AEA83
	for <linux-mm@kvack.org>; Sat,  8 Nov 2008 11:24:41 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 08B321EF085
	for <linux-mm@kvack.org>; Sat,  8 Nov 2008 11:24:41 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id BC29F1DB8045
	for <linux-mm@kvack.org>; Sat,  8 Nov 2008 11:24:40 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 623801DB803E
	for <linux-mm@kvack.org>; Sat,  8 Nov 2008 11:24:40 +0900 (JST)
Message-ID: <31630.10.75.179.62.1226111079.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <1226096940.8805.4.camel@badari-desktop>
References: <1226096940.8805.4.camel@badari-desktop>
Date: Sat, 8 Nov 2008 11:24:39 +0900 (JST)
Subject: Re: 2.6.28-rc3 mem_cgroup panic
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=us-ascii
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Balbir Singh <balbir@in.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Badari Pulavarty said:
> Hi Balbir,
>
> I was running memory remove/add tests in a continuous loop.
> I get following panic in mem_cgroup migration code.
>
> Is this a known issue ?
>
No, this is new one. We don't see panic in cpuset based migration..so..
Maybe related to page_cgroup allocation/free code in memory hotplug
notifier.

Thank you for report. I'll try this.

Regards,
-Kame


> Thanks,
> Badari
>
>
> Unable to handle kernel paging request for data at address 0x027d7d80
> Faulting instruction address: 0xc000000000105334
> Oops: Kernel access of bad area, sig: 11 [#1]
> SMP NR_CPUS=32 NUMA pSeries
> Modules linked in:
> NIP: c000000000105334 LR: c000000000105314 CTR: c0000000000bf6d0
> REGS: c0000000e446b410 TRAP: 0300   Not tainted  (2.6.28-rc3)
> MSR: 8000000000009032 <EE,ME,IR,DR>  CR: 24000448  XER: 00000020
> DAR: 00000000027d7d80, DSISR: 0000000040000000
> TASK = c0000000e4526cc0[4823] 'drmgr' THREAD: c0000000e4468000 CPU: 0
> GPR00: 0000000000000001 c0000000e446b690 c000000000b33f10 00000000027d7d80
> GPR04: c000000000105314 c0000000000bf6d0 c0000000eafded40 0000000000000000
> GPR08: c000000000bd7fc0 0000000000000008 00000000027d7d80 c000000000bd7000
> GPR12: 0000000000004000 c000000000b58300 00000000200957bc 0000000000000000
> GPR16: 0000000000000000 c0000000e446b8f8 0000000000000000 c000000000adba20
> GPR20: 0000000000000000 0000000000000000 c0000000e4937cb8 00000000000ff000
> GPR24: 0000000000000000 00000000000000f2 fffffffffffffff4 c0000000ea10d748
> GPR28: c0000000e4937c80 c0000000e4937c80 c000000000aa9bc0 c0000000e446b690
> NIP [c000000000105334] .mem_cgroup_prepare_migration+0x70/0x160
> LR [c000000000105314] .mem_cgroup_prepare_migration+0x50/0x160
> Call Trace:
> [c0000000e446b690] [c000000000105314]
> .mem_cgroup_prepare_migration+0x50/0x160 (unreliable)
> [c0000000e446b730] [c000000000102770] .migrate_pages+0x12c/0x62c
> [c0000000e446b880] [c000000000100558] .offline_pages+0x398/0x5ac
> [c0000000e446b990] [c0000000001007b0] .remove_memory+0x44/0x60
> [c0000000e446ba20] [c0000000003fdb90]
> .memory_block_change_state+0x198/0x230
> [c0000000e446bad0] [c0000000003fe2b0] .store_mem_state+0xcc/0x144
> [c0000000e446bb70] [c0000000003f0eb8] .sysdev_store+0x74/0xa4
> [c0000000e446bc10] [c000000000172d54] .sysfs_write_file+0x128/0x1a4
> [c0000000e446bcd0] [c000000000109330] .vfs_write+0xf0/0x1c4
> [c0000000e446bd80] [c000000000109ccc] .sys_write+0x6c/0xb8
> [c0000000e446be30] [c00000000000852c] syscall_exit+0x0/0x40
> Instruction dump:
> 2f800000 409e00f0 7f83e378 48000871 60000000 48000018 7c210b78 7c421378
> e8030000 780907e1 4082fff0 38000001 <7d6018a8> 7d690378 7d2019ad 40a2fff4
> ---[ end trace 719565d8677c8ae0 ]---
> Unable to handle kernel paging request for data at address 0x027d7dd0
> Faulting instruction address: 0xc0000000001040f0
> Oops: Kernel access of bad area, sig: 11 [#2]
> SMP NR_CPUS=32 NUMA pSeries
> Modules linked in:
> NIP: c0000000001040f0 LR: c0000000001040e4 CTR: c0000000000bf6d0
> REGS: c0000000e446aa10 TRAP: 0300   Tainted: G      D     (2.6.28-rc3)
> MSR: 8000000000009032 <EE,ME,IR,DR>  CR: 48000428  XER: 00000006
> DAR: 00000000027d7dd0, DSISR: 0000000040000000
> TASK = c0000000e4526cc0[4823] 'drmgr' THREAD: c0000000e4468000 CPU: 0
> GPR00: c0000000001040e4 c0000000e446ac90 c000000000b33f10 00000000027d7dd0
> GPR04: c0000000001040e4 c0000000000bf6d0 0000001fdfe40797 0000000000000000
> GPR08: c000000000bd7fc0 0000000000000008 00000000027d7dd0 c000000000bd7000
> GPR12: c0000000e446ace0 c000000000b58300 c0000000e4382800 00000000100d0000
> GPR16: 00000000100d0000 fffffffffffffffb 0000000000000000 00000000100d0000
> GPR20: 000000000035eee6 c0000000e7c67b88 c000000000bf2f68 0000000000000000
> GPR24: 0000001fdfe40797 c0000000e42ab400 000000001002f000 0000000000000001
> GPR28: c0000000e4937cf0 00000000027d7dd0 c000000000aa9bc0 c0000000e446ac90
> NIP [c0000000001040f0] .__mem_cgroup_uncharge_common+0x60/0x20c
> LR [c0000000001040e4] .__mem_cgroup_uncharge_common+0x54/0x20c
> Call Trace:
> [c0000000e446ac90] [c0000000001040e4]
> .__mem_cgroup_uncharge_common+0x54/0x20c (unreliable)
> [c0000000e446ad30] [c0000000001045a0] .mem_cgroup_uncharge_page+0x50/0x68
> [c0000000e446adc0] [c0000000000e50f0] .page_remove_rmap+0x190/0x1d4
> [c0000000e446ae50] [c0000000000da8c8] .unmap_vmas+0x528/0x8f4
> [c0000000e446af90] [c0000000000e0890] .exit_mmap+0xf0/0x1cc
> [c0000000e446b040] [c0000000000640b0] .mmput+0x78/0x164
> [c0000000e446b0e0] [c00000000006983c] .exit_mm+0x1a8/0x1d0
> [c0000000e446b190] [c00000000006b6c8] .do_exit+0x22c/0x880
> [c0000000e446b260] [c0000000000294d0] .die+0x1d0/0x1d4
> [c0000000e446b310] [c0000000000312d8] .bad_page_fault+0xc8/0xe8
> [c0000000e446b3a0] [c000000000005198] handle_page_fault+0x3c/0x5c
> --- Exception: 300 at .mem_cgroup_prepare_migration+0x70/0x160
>     LR = .mem_cgroup_prepare_migration+0x50/0x160
> [c0000000e446b730] [c000000000102770] .migrate_pages+0x12c/0x62c
> [c0000000e446b880] [c000000000100558] .offline_pages+0x398/0x5ac
> [c0000000e446b990] [c0000000001007b0] .remove_memory+0x44/0x60
> [c0000000e446ba20] [c0000000003fdb90]
> .memory_block_change_state+0x198/0x230
> [c0000000e446bad0] [c0000000003fe2b0] .store_mem_state+0xcc/0x144
> [c0000000e446bb70] [c0000000003f0eb8] .sysdev_store+0x74/0xa4
> [c0000000e446bc10] [c000000000172d54] .sysfs_write_file+0x128/0x1a4
> [c0000000e446bcd0] [c000000000109330] .vfs_write+0xf0/0x1c4
> [c0000000e446bd80] [c000000000109ccc] .sys_write+0x6c/0xb8
> [c0000000e446be30] [c00000000000852c] syscall_exit+0x0/0x40
> Instruction dump:
> 7c9b2378 4bf04d99 60000000 e93e8018 80090060 2f800000 409e019c 7f83e378
> 48001aa1 60000000 7c7d1b79 41820188 <e81d0000> 7809f7e3 40a2001c 48000178
> ---[ end trace 719565d8677c8ae0 ]---
> Fixing recursive fault but reboot is needed!
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
