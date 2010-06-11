Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 5CF066B0071
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 21:39:32 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5B1dTOG023315
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 11 Jun 2010 10:39:29 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 56F5A45DE50
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 10:39:29 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 36E6D45DE4D
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 10:39:29 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1B35A1DB8042
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 10:39:29 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B3F78E18007
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 10:39:28 +0900 (JST)
Date: Fri, 11 Jun 2010 10:35:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: 2.6.35-rc2 : OOPS with LTP memcg regression test run.
Message-Id: <20100611103509.520671b2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <201006102200.57617.maciej.rutecki@gmail.com>
References: <4C0BB98E.9030101@in.ibm.com>
	<201006102200.57617.maciej.rutecki@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: maciej.rutecki@gmail.com
Cc: Sachin Sant <sachinp@in.ibm.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux/PPC Development <linuxppc-dev@ozlabs.org>
List-ID: <linux-mm.kvack.org>

On Thu, 10 Jun 2010 22:00:57 +0200
Maciej Rutecki <maciej.rutecki@gmail.com> wrote:

> I created a Bugzilla entry at 
> https://bugzilla.kernel.org/show_bug.cgi?id=16178
> for your bug report, please add your address to the CC list in there, thanks!
> 

Hmm... It seems a panic in SLUB or SLAB.
Is .config available ?

-Kame


> On niedziela, 6 czerwca 2010 o 17:06:54 Sachin Sant wrote:
> > While executing LTP Controller tests(memcg regression) on
> > a POWER6 box came across this following OOPS.
> > 
> > Memory cgroup out of memory: kill process 9139 (memcg_test_1) score 3 or a
> >  child Killed process 9139 (memcg_test_1) vsz:3456kB, anon-rss:448kB,
> >  file-rss:1088kB Memory cgroup out of memory: kill process 9140
> >  (memcg_test_1) score 3 or a child Killed process 9140 (memcg_test_1)
> >  vsz:3456kB, anon-rss:448kB, file-rss:1088kB Unable to handle kernel paging
> >  request for data at address 0x720072007200720 Faulting instruction
> >  address: 0xc00000000015b778
> > Oops: Kernel access of bad area, sig: 11 [#2]
> > SMP NR_CPUS=1024 NUMA pSeries
> > last sysfs file: /sys/devices/system/cpu/cpu1/cache/index1/shared_cpu_map
> > Modules linked in: quota_v2 quota_tree ipv6 fuse loop dm_mod sr_mod cdrom
> >  sg sd_mod crc_t10dif ibmvscsic scsi_transport_srp scsi_tgt scsi_mod NIP:
> >  c00000000015b778 LR: c00000000015b740 CTR: 0000000000000000
> > REGS: c000000009812ff0 TRAP: 0300   Tainted: G      D     
> >  (2.6.35-rc2-autotest) MSR: 8000000000009032 <EE,ME,IR,DR>  CR: 44004424 
> >  XER: 00000001
> > DAR: 0720072007200720, DSISR: 0000000040000000
> > TASK = c000000005fb1100[9155] 'umount' THREAD: c000000009810000 CPU: 0
> > GPR00: 0000000000000000 c000000009813270 c000000000d3d7a0 0000000000000000
> > GPR04: 0000000000008050 0000000000160000 0000000000000027 c00000000f2c6870
> > GPR08: 00000000000006a5 c000000000b16870 c000000000cf0140 000000000e7b0000
> > GPR12: 0000000024004428 c000000007440000 0000000000008000 fffffffffffff000
> > GPR16: 0000000000000000 c0000000098138f0 000000000000002d 0000000000000027
> > GPR20: 0000000000000000 0000000000000027 0000000000000000 c000000007063138
> > GPR24: ffffffffffffffff 0000000000000000 c00000000019bafc c00000000e02e000
> > GPR28: 0000000000000001 0000000000008050 c000000000ca6b00 0720072007200720
> > NIP [c00000000015b778] .kmem_cache_alloc+0xb0/0x13c
> > LR [c00000000015b740] .kmem_cache_alloc+0x78/0x13c
> > Call Trace:
> > [c000000009813270] [c00000000015b740] .kmem_cache_alloc+0x78/0x13c
> >  (unreliable) [c000000009813310] [c00000000019bafc]
> >  .alloc_buffer_head+0x2c/0x78 [c000000009813390] [c00000000019c99c]
> >  .alloc_page_buffers+0x60/0x114 [c000000009813450] [c00000000019ca78]
> >  .create_empty_buffers+0x28/0x140 [c0000000098134e0] [c00000000019f2ec]
> >  .__block_prepare_write+0xe4/0x4f0 [c000000009813610] [c00000000019f94c]
> >  .block_write_begin_newtrunc+0xa8/0x120 [c0000000098136d0]
> >  [c00000000019fea0] .block_write_begin+0x34/0x8c [c000000009813770]
> >  [c00000000022b458] .ext3_write_begin+0x13c/0x298 [c000000009813880]
> >  [c000000000117500] .generic_file_buffered_write+0x13c/0x320
> >  [c0000000098139b0] [c000000000119c80]
> >  .__generic_file_aio_write+0x378/0x3dc [c000000009813ab0]
> >  [c000000000119d68] .generic_file_aio_write+0x84/0xfc [c000000009813b60]
> >  [c00000000016e460] .do_sync_write+0xac/0x10c
> > [c000000009813ce0] [c00000000016f204] .vfs_write+0xd0/0x1dc
> > [c000000009813d80] [c00000000016f418] .SyS_write+0x58/0xa0
> > [c000000009813e30] [c0000000000085b4] syscall_exit+0x0/0x40
> > Instruction dump:
> > 38600000 409e0090 38000000 8b8d0212 980d0212 e96d0040 e93b0000 7ce95a14
> > 7fe9582a 2fbf0000 419e0014 e81b001a <7c1f002a> 7c09592a 4800001c 7f46d378
> > ---[ end trace f24cb0cb5729d2bb ]---
> > 
> > And few more of these. Previous snapshot release
> >  2.6.35-rc1-git5(6c5de280b6...) was good.
> > 
> > Thanks
> > -Sachin
> > 
> 
> -- 
> Maciej Rutecki
> http://www.maciek.unixy.pl
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
