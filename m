Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kvack.org (Postfix) with ESMTP id B5B816B0074
	for <linux-mm@kvack.org>; Mon, 15 Dec 2008 04:51:35 -0500 (EST)
Date: Mon, 15 Dec 2008 10:53:11 +0100
From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Subject: Re: 2.6.28-rc8 big regression in VM
Message-ID: <20081215095311.GB4422@ics.muni.cz>
References: <20081213095815.GA7143@ics.muni.cz> <20081215011645.GA9707@localhost> <20081215110231.00DF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="9amGYk9869ThD9tj"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20081215110231.00DF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Dec 15, 2008 at 11:05:24AM +0900, KOSAKI Motohiro wrote:
> I also don't reproduce your problem.
> Could you get output of "cat /proc/meminfo", not only free command?

attached meminfo and vmstat after dropping caches.

-- 
Lukas Hejtmanek

MemTotal:        2016688 kB
MemFree:         1528748 kB
Buffers:             424 kB
Cached:           140060 kB
SwapCached:            0 kB
Active:           353252 kB
Inactive:          47332 kB
Active(anon):     329884 kB
Inactive(anon):        4 kB
Active(file):      23368 kB
Inactive(file):    47328 kB
Unevictable:           0 kB
Mlocked:               0 kB
SwapTotal:       1542232 kB
SwapFree:        1542232 kB
Dirty:                64 kB
Writeback:             0 kB
AnonPages:        260100 kB
Mapped:            85036 kB
Slab:              24708 kB
SReclaimable:       8532 kB
SUnreclaim:        16176 kB
PageTables:        10324 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:     2550576 kB
Committed_AS:     576152 kB
VmallocTotal:   34359738367 kB
VmallocUsed:      332160 kB
VmallocChunk:   34359404539 kB
DirectMap4k:       45760 kB
DirectMap2M:     2009088 kB

nr_free_pages 382094
nr_inactive_anon 1
nr_active_anon 82469
nr_inactive_file 11835
nr_active_file 5905
nr_unevictable 0
nr_mlock 0
nr_anon_pages 65025
nr_mapped 21228
nr_file_pages 35187
nr_dirty 17
nr_writeback 0
nr_slab_reclaimable 2133
nr_slab_unreclaimable 4043
nr_page_table_pages 2581
nr_unstable 0
nr_bounce 0
nr_vmscan_write 0
nr_writeback_temp 0
pgpgin 271982
pgpgout 10689
pswpin 0
pswpout 0
pgalloc_dma 120
pgalloc_dma32 593606
pgalloc_normal 0
pgalloc_movable 0
pgfree 976064
pgactivate 13699
pgdeactivate 0
pgfault 947747
pgmajfault 1688
pgrefill_dma 0
pgrefill_dma32 0
pgrefill_normal 0
pgrefill_movable 0
pgsteal_dma 0
pgsteal_dma32 0
pgsteal_normal 0
pgsteal_movable 0
pgscan_kswapd_dma 0
pgscan_kswapd_dma32 0
pgscan_kswapd_normal 0
pgscan_kswapd_movable 0
pgscan_direct_dma 0
pgscan_direct_dma32 0
pgscan_direct_normal 0
pgscan_direct_movable 0
pginodesteal 0
slabs_scanned 30080
kswapd_steal 0
kswapd_inodesteal 0
pageoutrun 0
allocstall 0
pgrotated 0
unevictable_pgs_culled 1
unevictable_pgs_scanned 0
unevictable_pgs_rescued 9
unevictable_pgs_mlocked 9
unevictable_pgs_munlocked 9
unevictable_pgs_cleared 0
unevictable_pgs_stranded 0
unevictable_pgs_mlockfreed 0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
