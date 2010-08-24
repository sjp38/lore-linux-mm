Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9F32660080F
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 01:02:42 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7O52Wuv027403
	for <linux-mm@kvack.org> (envelope-from iram.shahzad@jp.fujitsu.com);
	Tue, 24 Aug 2010 14:02:32 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B50145DE55
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 14:02:32 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4935945DE51
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 14:02:32 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D19E1DB803F
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 14:02:32 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D3FD41DB803B
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 14:02:31 +0900 (JST)
Message-ID: <8E31CE28A1354C43BBAD0BDEFA10494E@rainbow>
From: "Iram Shahzad" <iram.shahzad@jp.fujitsu.com>
References: <20100818154130.GC9431@localhost> <565A4EE71DAC4B1A820B2748F56ABF73@rainbow> <20100819160006.GG6805@barrios-desktop> <AA3F2D89535A431DB91FE3032EDCB9EA@rainbow> <20100820053447.GA13406@localhost> <20100820093558.GG19797@csn.ul.ie> <AANLkTimVmoomDjGMCfKvNrS+v-mMnfeq6JDZzx7fjZi+@mail.gmail.com> <20100822153121.GA29389@barrios-desktop> <20100822232316.GA339@localhost> <20100823171416.GA2216@barrios-desktop> <20100824002753.GB6568@localhost>
Subject: Re: compaction: trying to understand the code
Date: Tue, 24 Aug 2010 14:07:02 +0900
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_NextPart_000_008E_01CB4395.9FD537D0"
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.

------=_NextPart_000_008E_01CB4395.9FD537D0
Content-Type: text/plain;
	format=flowed;
	charset="ISO-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit

> One question is, why kswapd won't proceed after isolating all the pages?
> If it has done with the isolated pages, we'll see growing inactive_anon
> numbers.
> 
> /proc/vmstat should give more clues on any possible page reclaim
> activities. Iram, would you help post it?

I am not sure which point of time are you interested in, so I am
attaching /proc/vmstat log of 3 points.

too_many_isolated_vmstat_before_frag.txt
   This one is taken before I ran my test app which attempts
   to make fragmentation
too_many_isolated_vmstat_before_compaction.txt
   This one is taken after running the test app and before
   running compaction.
too_many_isolated_vmstat_during_compaction.txt
   This one is taken a few minutes after running compaction.
   To take this I ran compaction in background.

Thanks
Iram

------=_NextPart_000_008E_01CB4395.9FD537D0
Content-Type: text/plain;
	format=flowed;
	name="too_many_isolated_vmstat_before_frag.txt";
	reply-type=original
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="too_many_isolated_vmstat_before_frag.txt"

nr_free_pages 79896
nr_inactive_anon 0
nr_active_anon 14688
nr_inactive_file 10444
nr_active_file 2718
nr_unevictable 0
nr_mlock 0
nr_anon_pages 12341
nr_mapped 9430
nr_file_pages 15511
nr_dirty 0
nr_writeback 0
nr_slab_reclaimable 528
nr_slab_unreclaimable 1073
nr_page_table_pages 1479
nr_kernel_stack 235
nr_unstable 0
nr_bounce 0
nr_vmscan_write 0
nr_writeback_temp 0
nr_isolated_anon 0
nr_isolated_file 0
nr_shmem 2349
pgpgin 4
pgpgout 0
pswpin 0
pswpout 0
pgalloc_normal 54208
pgalloc_high 0
pgalloc_movable 0
pgfree 134220
pgactivate 2718
pgdeactivate 0
pgfault 88952
pgmajfault 555
pgrefill_normal 0
pgrefill_high 0
pgrefill_movable 0
pgsteal_normal 0
pgsteal_high 0
pgsteal_movable 0
pgscan_kswapd_normal 0
pgscan_kswapd_high 0
pgscan_kswapd_movable 0
pgscan_direct_normal 0
pgscan_direct_high 0
pgscan_direct_movable 0
pginodesteal 0
slabs_scanned 0
kswapd_steal 0
kswapd_inodesteal 0
pageoutrun 0
allocstall 0
pgrotated 0
compact_blocks_moved 0
compact_pages_moved 0
compact_pagemigrate_failed 0
compact_stall 0
compact_fail 0
compact_success 0
unevictable_pgs_culled 0
unevictable_pgs_scanned 0
unevictable_pgs_rescued 0
unevictable_pgs_mlocked 0
unevictable_pgs_munlocked 0
unevictable_pgs_cleared 0
unevictable_pgs_stranded 0
unevictable_pgs_mlockfreed 0

------=_NextPart_000_008E_01CB4395.9FD537D0
Content-Type: text/plain;
	format=flowed;
	name="too_many_isolated_vmstat_before_compaction.txt";
	reply-type=original
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="too_many_isolated_vmstat_before_compaction.txt"

nr_free_pages 54098
nr_inactive_anon 0
nr_active_anon 40354
nr_inactive_file 10433
nr_active_file 2729
nr_unevictable 0
nr_mlock 0
nr_anon_pages 38007
nr_mapped 9469
nr_file_pages 15511
nr_dirty 0
nr_writeback 0
nr_slab_reclaimable 528
nr_slab_unreclaimable 1070
nr_page_table_pages 1582
nr_kernel_stack 236
nr_unstable 0
nr_bounce 0
nr_vmscan_write 0
nr_writeback_temp 0
nr_isolated_anon 0
nr_isolated_file 0
nr_shmem 2349
pgpgin 4
pgpgout 0
pswpin 0
pswpout 0
pgalloc_normal 105927
pgalloc_high 0
pgalloc_movable 0
pgfree 160167
pgactivate 2729
pgdeactivate 0
pgfault 141220
pgmajfault 555
pgrefill_normal 0
pgrefill_high 0
pgrefill_movable 0
pgsteal_normal 0
pgsteal_high 0
pgsteal_movable 0
pgscan_kswapd_normal 0
pgscan_kswapd_high 0
pgscan_kswapd_movable 0
pgscan_direct_normal 0
pgscan_direct_high 0
pgscan_direct_movable 0
pginodesteal 0
slabs_scanned 0
kswapd_steal 0
kswapd_inodesteal 0
pageoutrun 0
allocstall 0
pgrotated 0
compact_blocks_moved 0
compact_pages_moved 0
compact_pagemigrate_failed 0
compact_stall 0
compact_fail 0
compact_success 0
unevictable_pgs_culled 0
unevictable_pgs_scanned 0
unevictable_pgs_rescued 0
unevictable_pgs_mlocked 0
unevictable_pgs_munlocked 0
unevictable_pgs_cleared 0
unevictable_pgs_stranded 0
unevictable_pgs_mlockfreed 0

------=_NextPart_000_008E_01CB4395.9FD537D0
Content-Type: text/plain;
	format=flowed;
	name="too_many_isolated_vmstat_during_compaction.txt";
	reply-type=original
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="too_many_isolated_vmstat_during_compaction.txt"

nr_free_pages 53673
nr_inactive_anon 0
nr_active_anon 40498
nr_inactive_file 10427
nr_active_file 2735
nr_unevictable 0
nr_mlock 0
nr_anon_pages 38151
nr_mapped 9469
nr_file_pages 15511
nr_dirty 0
nr_writeback 0
nr_slab_reclaimable 536
nr_slab_unreclaimable 1070
nr_page_table_pages 1588
nr_kernel_stack 237
nr_unstable 0
nr_bounce 0
nr_vmscan_write 0
nr_writeback_temp 0
nr_isolated_anon 8592
nr_isolated_file 1862
nr_shmem 2349
pgpgin 4
pgpgout 0
pswpin 0
pswpout 0
pgalloc_normal 117872
pgalloc_high 0
pgalloc_movable 0
pgfree 182402
pgactivate 2735
pgdeactivate 0
pgfault 182499
pgmajfault 555
pgrefill_normal 0
pgrefill_high 0
pgrefill_movable 0
pgsteal_normal 0
pgsteal_high 0
pgsteal_movable 0
pgscan_kswapd_normal 0
pgscan_kswapd_high 0
pgscan_kswapd_movable 0
pgscan_direct_normal 0
pgscan_direct_high 0
pgscan_direct_movable 0
pginodesteal 0
slabs_scanned 0
kswapd_steal 0
kswapd_inodesteal 0
pageoutrun 0
allocstall 0
pgrotated 0
compact_blocks_moved 327
compact_pages_moved 10454
compact_pagemigrate_failed 0
compact_stall 0
compact_fail 0
compact_success 0
unevictable_pgs_culled 0
unevictable_pgs_scanned 0
unevictable_pgs_rescued 0
unevictable_pgs_mlocked 0
unevictable_pgs_munlocked 0
unevictable_pgs_cleared 0
unevictable_pgs_stranded 0
unevictable_pgs_mlockfreed 0

------=_NextPart_000_008E_01CB4395.9FD537D0--


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
