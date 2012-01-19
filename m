Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id B60E16B004F
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 22:25:17 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 997B23EE0C0
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 12:25:14 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4AA6245DE51
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 12:25:14 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3057C45DE50
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 12:25:14 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A5071DB802F
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 12:25:14 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id ACF6D1DB8037
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 12:25:13 +0900 (JST)
Date: Thu, 19 Jan 2012 12:23:54 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUG] kernel BUG at mm/memcontrol.c:1074!
Message-Id: <20120119122354.66eb9820.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1326949826.5016.5.camel@lappy>
References: <1326949826.5016.5.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: hannes <hannes@cmpxchg.org>, mhocko@suse.cz, bsingharora@gmail.com, Dave Jones <davej@redhat.com>, linux-kernel <linux-kernel@vger.kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org

On Thu, 19 Jan 2012 07:10:26 +0200
Sasha Levin <levinsasha928@gmail.com> wrote:

> Hi all,
> 
> During testing, I have triggered the OOM killer by mmap()ing a large block of memory. The OOM kicked in and tried to kill the process:
> 

two questions.

1. What is the kernel version  ?
2. are you using memcg moutned ?

Thanks,
-Kame

> [  526.657446] trinity invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0, oom_score_adj=0
> [  526.659083] trinity cpuset=/ mems_allowed=0
> [  526.659854] Pid: 2200, comm: trinity Not tainted 3.2.0-next-20120119-sasha #128
> [  526.661203] Call Trace:
> [  526.661703]  [<ffffffff82583260>] ? _raw_spin_unlock+0x30/0x60
> [  526.662839]  [<ffffffff8116aefe>] dump_header+0x7e/0x330
> [  526.663841]  [<ffffffff82583303>] ? _raw_spin_unlock_irqrestore+0x73/0xa0
> [  526.665104]  [<ffffffff81835b20>] ? ___ratelimit+0xd0/0x180
> [  526.666149]  [<ffffffff8116b5cd>] oom_kill_process+0x7d/0x2d0
> [  526.667224]  [<ffffffff8116bcc0>] out_of_memory+0x1d0/0x400
> [  526.668237]  [<ffffffff81171011>] __alloc_pages_nodemask+0x8f1/0x910
> [  526.669388]  [<ffffffff811a8870>] alloc_pages_current+0xa0/0x110
> [  526.670486]  [<ffffffff8116713f>] __page_cache_alloc+0x8f/0xa0
> [  526.671610]  [<ffffffff81167f3a>] filemap_fault+0x34a/0x4e0
> [  526.672666]  [<ffffffff8118779f>] __do_fault+0x7f/0x5c0
> [  526.673665]  [<ffffffff810de041>] ? get_parent_ip+0x11/0x50
> [  526.674744]  [<ffffffff81053900>] ? native_sched_clock+0x60/0x90
> [  526.675868]  [<ffffffff8118a6e1>] handle_pte_fault+0xa1/0xa20
> [  526.676941]  [<ffffffff81107cfe>] ? put_lock_stats.clone.18+0xe/0x40
> [  526.678118]  [<ffffffff81108012>] ? lock_release_holdtime+0xb2/0x160
> [  526.679300]  [<ffffffff8118c7ae>] handle_mm_fault+0x1ce/0x330
> [  526.680405]  [<ffffffff8107d94d>] do_page_fault+0x15d/0x4d0
> [  526.681464]  [<ffffffff810aaf53>] ? do_fork+0x73/0x340
> [  526.682440]  [<ffffffff811ebff5>] ? vfsmount_lock_local_unlock+0x55/0x80
> [  526.683645]  [<ffffffff811ec988>] ? mntput_no_expire+0x38/0x100
> [  526.684709]  [<ffffffff811ed46e>] ? mntput+0x1e/0x30
> [  526.685605]  [<ffffffff811ce463>] ? fput+0x1b3/0x2b0
> [  526.686514]  [<ffffffff81076d11>] do_async_page_fault+0x31/0x90
> [  526.687573]  [<ffffffff825843d5>] async_page_fault+0x25/0x30
> [  526.688585] Mem-Info:
> [  526.689000] Node 0 DMA per-cpu:
> [  526.689605] CPU    0: hi:    0, btch:   1 usd:   0
> [  526.690484] Node 0 DMA32 per-cpu:
> [  526.691171] CPU    0: hi:   90, btch:  15 usd:   0
> [  526.692085] active_anon:1218 inactive_anon:12 isolated_anon:0
> [  526.692087]  active_file:1 inactive_file:6 isolated_file:0
> [  526.692087]  immediate:0 unevictable:48358 dirty:6 writeback:0 unstable:0
> [  526.692088]  free:864 slab_reclaimable:1696 slab_unreclaimable:3992
> [  526.692089]  mapped:5 shmem:2 pagetables:141 bounce:0
> [  526.697504] Node 0 DMA free:1300kB min:108kB low:132kB high:160kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB immediate:0kB unevictable:14568kB isolated(anon):0kB isolated(file):0kB present:15656kB mlocked:14576kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:32kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
> [  526.704557] lowmem_reserve[]: 0 299 299 299
> [  526.705458] Node 0 DMA32 free:2156kB min:2156kB low:2692kB high:3232kB active_anon:4872kB inactive_anon:48kB active_file:4kB inactive_file:24kB immediate:0kB unevictable:178864kB isolated(anon):0kB isolated(file):0kB present:306432kB mlocked:178880kB dirty:24kB writeback:0kB mapped:20kB shmem:8kB slab_reclaimable:6784kB slab_unreclaimable:15968kB kernel_stack:1376kB pagetables:532kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:44 all_unreclaimable? yes
> [  526.712825] lowmem_reserve[]: 0 0 0 0
> [  526.713633] Node 0 DMA: 1*4kB 1*8kB 1*16kB 0*32kB 0*64kB 0*128kB 1*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 1308kB
> [  526.715878] Node 0 DMA32: 10*4kB 6*8kB 4*16kB 1*32kB 1*64kB 1*128kB 1*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 2168kB
> [  526.718169] 10 total pagecache pages
> [  526.718820] 0 pages in swap cache
> [  526.719449] Swap cache stats: add 0, delete 0, find 0/0
> [  526.720392] Free swap  = 0kB
> [  526.720947] Total swap = 0kB
> [  526.722927] 81904 pages RAM
> [  526.723470] 14810 pages reserved
> [  526.724094] 558 pages shared
> [  526.724611] 65388 pages non-shared
> [  526.725239] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
> [  526.726586] [ 2193]     0  2193     4505       92   0       0             0 sh
> [  526.727884] [ 2200]     0  2200     3959      560   0       0             0 trinity
> [  526.729301] [ 2201]     0  2201     3959      561   0       0             0 trinity
> [  526.730804] [13370]     0 13370   528247    48921   0       0             0 trinity
> [  526.732207] Out of memory: Kill process 13370 (trinity) score 700 or sacrifice child
> [  526.733624] Killed process 13370 (trinity) total-vm:2112988kB, anon-rss:195680kB, file-rss:4kB
> 
> So far, everything went on as expected.
> 
> The problem is, that it looks like this has triggered a BUG() in the memory cgroup code:
> 
> [  526.737227] ------------[ cut here ]------------
> [  526.738032] 
> [  526.738032] invalid opcode: 0000 [#1] PREEMPT SMP 
> [  526.738032] CPU 0 
> [  526.738032] Pid: 1091, comm: kswapd0 Not tainted 3.2.0-next-20120119-sasha #128  
> [  526.738032] RIP: 0010:[<ffffffff811c4b4a>]  [<ffffffff811c4b4a>] mem_cgroup_lru_del_list+0xca/0xd0
> [  526.738032] RSP: 0018:ffff8800127139a0  EFLAGS: 00010046
> [  526.738032] RAX: 0000000000000001 RBX: ffffea0000358300 RCX: 0000000000000000
> [  526.738032] RDX: ffff880012c0b800 RSI: 0000000000000000 RDI: 0000000000000000
> [  526.738032] RBP: ffff8800127139b0 R08: ffff880012713ad0 R09: 0000000000000001
> [  526.738032] R10: 0000000000000000 R11: 0000000000000001 R12: 0000000000000002
> [  526.738032] R13: ffffea0000358300 R14: ffffea0000358320 R15: 0000000000000001
> [  526.738032] FS:  0000000000000000(0000) GS:ffff880013a00000(0000) knlGS:0000000000000000
> [  526.738032] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  526.738032] CR2: 00007fea7fa42e66 CR3: 000000000c42a000 CR4: 00000000000406f0
> [  526.738032] DR0: ffffffff810aaee0 DR1: 0000000000000000 DR2: 0000000000000000
> [  526.738032] DR3: 0000000000000000 DR6: 00000000ffff4ff0 DR7: 0000000000000600
> [  526.738032] Process kswapd0 (pid: 1091, threadinfo ffff880012712000, task ffff880012f7d840)
> [  526.738032] Stack:
> [  526.738032]  ffff880012c0b968 ffff880012c0b968 ffff8800127139c0 ffffffff811c4f0a
> [  526.738032]  ffff880012713a70 ffffffff81178c63 ffff8800127139e0 ffffea00000cbba0
> [  526.738032]  ffff880012713a40 ffff880012713b08 0000000000000001 ffffffffffffffff
> [  526.738032] Call Trace:
> [  526.738032]  [<ffffffff811c4f0a>] mem_cgroup_lru_del+0x3a/0x40
> [  526.738032]  [<ffffffff81178c63>] isolate_lru_pages+0xe3/0x330
> [  526.738032]  [<ffffffff8117a11e>] ? shrink_inactive_list+0xce/0x480
> [  526.738032]  [<ffffffff8117a153>] shrink_inactive_list+0x103/0x480
> [  526.738032]  [<ffffffff811c2a46>] ? mem_cgroup_iter+0x176/0x310
> [  526.738032]  [<ffffffff810e2c55>] ? sched_clock_local+0x25/0x90
> [  526.738032]  [<ffffffff8117ac04>] shrink_mem_cgroup_zone+0x3f4/0x580
> [  526.738032]  [<ffffffff81107cfe>] ? put_lock_stats.clone.18+0xe/0x40
> [  526.738032]  [<ffffffff8117adfe>] shrink_zone+0x6e/0xa0
> [  526.738032]  [<ffffffff8117be65>] balance_pgdat+0x545/0x750
> [  526.738032]  [<ffffffff810de1ed>] ? sub_preempt_count+0x9d/0xd0
> [  526.738032]  [<ffffffff8117c233>] kswapd+0x1c3/0x320
> [  526.738032]  [<ffffffff810cee30>] ? abort_exclusive_wait+0xb0/0xb0
> [  526.738032]  [<ffffffff8117c070>] ? balance_pgdat+0x750/0x750
> [  526.738032]  [<ffffffff810ce06e>] kthread+0xbe/0xd0
> [  526.738032]  [<ffffffff82585df4>] kernel_thread_helper+0x4/0x10
> [  526.738032]  [<ffffffff810d8c88>] ? finish_task_switch+0x78/0x100
> [  526.738032]  [<ffffffff825840f8>] ? retint_restore_args+0x13/0x13
> [  526.738032]  [<ffffffff810cdfb0>] ? kthread_flush_work_fn+0x10/0x10
> [  526.738032]  [<ffffffff82585df0>] ? gs_change+0x13/0x13
> [  526.738032] Code: 8b 1c 24 4c 8b 64 24 08 c9 c3 0f 1f 80 00 00 00 00 8b 4b 68 eb ba 0f 1f 00 0f b6 4b 68 bb 01 00 00 00 d3 e3 48 63 cb eb c2 0f 0b <0f> 0b 0f 1f 40 00 55 48 89 e5 48 83 ec 60 48 89 5d d8 4c 89 65 
> [  526.738032] RIP  [<ffffffff811c4b4a>] mem_cgroup_lru_del_list+0xca/0xd0
> [  526.738032]  RSP <ffff8800127139a0>
> [  526.738032] ---[ end trace 866f4f6c624b8d58 ]---
> 
> -- 
> 
> Sasha.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
