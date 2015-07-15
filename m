Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 8A77D280245
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 20:09:48 -0400 (EDT)
Received: by igcqs7 with SMTP id qs7so94667674igc.0
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 17:09:48 -0700 (PDT)
Received: from mail-ig0-x229.google.com (mail-ig0-x229.google.com. [2607:f8b0:4001:c05::229])
        by mx.google.com with ESMTPS id y5si2678162ict.78.2015.07.14.17.09.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jul 2015 17:09:47 -0700 (PDT)
Received: by igbij6 with SMTP id ij6so59114157igb.1
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 17:09:47 -0700 (PDT)
Date: Tue, 14 Jul 2015 17:09:45 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [BUG REPORT] OOM Killer is invoked while the system still has
 much memory
In-Reply-To: <6D317A699782EA4DB9A0E6266C9219696CA2B3BC@SZXEMA501-MBX.china.huawei.com>
Message-ID: <alpine.DEB.2.10.1507141701290.16182@chino.kir.corp.google.com>
References: <6D317A699782EA4DB9A0E6266C9219696CA2B3BC@SZXEMA501-MBX.china.huawei.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="397176738-1518709417-1436918986=:16182"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xuzhichuang <xuzhichuang@huawei.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Songjiangtao (mygirlsjt)" <songjiangtao.song@huawei.com>, "Zhangwei (FF)" <zw.zhang@huawei.com>, Qiuxishi <qiuxishi@huawei.com>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--397176738-1518709417-1436918986=:16182
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Tue, 14 Jul 2015, Xuzhichuang wrote:

> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138764] iostat invoked oom-killer: gfp_mask=0xd0, order=2, oom_adj=0, oom_score_adj=0
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138769] iostat cpuset=/ mems_allowed=0
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138773] Pid: 18117, comm: iostat Tainted: P        W  NX 3.0.58-0.6.6-xen #1
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138775] Call Trace:
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138800]  [<ffffffff800088be>] dump_trace+0x6e/0x1a0
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138810]  [<ffffffff803f773d>] dump_stack+0x69/0x6f
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138821]  [<ffffffff800dbced>] dump_header+0x9d/0x120
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138826]  [<ffffffff800dc505>] oom_kill_process+0x95/0x1a0
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138830]  [<ffffffff800dc746>] out_of_memory+0x136/0x220
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138834]  [<ffffffff800e0fda>] __alloc_pages_slowpath+0x7ba/0x810
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138838]  [<ffffffff800e1219>] __alloc_pages_nodemask+0x1e9/0x200
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138845]  [<ffffffff8011ae38>] cache_grow+0x348/0x450
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138850]  [<ffffffff8011b243>] cache_alloc_refill+0x303/0x4d0
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138854]  [<ffffffff8011ba70>] __kmalloc+0x1b0/0x290
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138862]  [<ffffffff8014c1da>] seq_read+0x13a/0x3b0
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138869]  [<ffffffff8018a762>] proc_reg_read+0x92/0xe0
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138877]  [<ffffffff80129877>] vfs_read+0xc7/0x130
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138881]  [<ffffffff801299e3>] sys_read+0x53/0xa0
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138887]  [<ffffffff80402d73>] system_call_fastpath+0x16/0x1b
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138922]  [<00007f935f57f4c0>] 0x7f935f57f4bf
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138923] Mem-Info:
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138925] DMA per-cpu:
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138927] CPU    0: hi:    0, btch:   1 usd:   0
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138929] CPU    1: hi:    0, btch:   1 usd:   0
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138930] DMA32 per-cpu:
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138932] CPU    0: hi:  155, btch:  38 usd:  11
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138933] CPU    1: hi:  155, btch:  38 usd:   0
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138936] active_anon:227111 inactive_anon:10382 isolated_anon:0
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138937]  active_file:203 inactive_file:189 isolated_file:47
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138938]  unevictable:95395 dirty:0 writeback:0 unstable:0
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138939]  free:247834 slab_reclaimable:18187 slab_unreclaimable:53853
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138940]  mapped:11485 shmem:11167 pagetables:0 bounce:0
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138945] DMA free:984kB min:36kB low:44kB high:52kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:16160kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138949] lowmem_reserve[]: 0 3014 3014 3014
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138955] DMA32 free:990352kB min:7004kB low:8752kB high:10504kB active_anon:908444kB inactive_anon:41528kB active_file:812kB inactive_file:756kB unevictable:381580kB isolated(anon):0kB isolated(file):188kB present:3025264kB mlocked:381580kB dirty:0kB writeback:0kB mapped:45940kB shmem:44668kB slab_reclaimable:72748kB slab_unreclaimable:215412kB kernel_stack:12456kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:192 all_unreclaimable? no
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138960] lowmem_reserve[]: 0 0 0 0
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138962] DMA: 2*4kB 4*8kB 3*16kB 4*32kB 2*64kB 1*128kB 2*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 984kB
> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138968] DMA32: 188513*4kB 29459*8kB 2*16kB 2*32kB 1*64kB 0*128kB 0*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 990396kB

The problem is most of your memory for ZONE_DMA32 is available only in 
sizes of order-0 and order-1 and the slab allocator is trying to allocate 
order-2 memory with no possibility of fallback to a smaller order.

You're running on a 3.0.58 kernel, but the watermark calculation should be 
the same in recent kernels.  

If you follow the logic of __zone_watermark_ok(), which uses the same 
watermarks as printed above, the min watermark for this zone is 1751 pages 
and the total zone free pages is 247588.  Discounting order-0 memory, 
there are only 59075 pages free with a min watermark of 875 pages.  
Discounting order-1 memory, there are 157 pages free with a min watermark 
of 437 pages.  This is where your allocation fails.  Even though the zone 
has 672KB of memory available, the per-order watermark fails.

The only option you have to avoid this other than changing your workload 
is to alter lowmem_reserve_ratio, see Documentation/sysctl/vm.txt.  You 
have 916KB of memory in ZONE_DMA that could be used for this allocation if 
it wasn't reserved for DMA allocations.
--397176738-1518709417-1436918986=:16182--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
