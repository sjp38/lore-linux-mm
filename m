Received: from localhost (localhost.localdomain [127.0.0.1])
	by mx.iplabs.de (Postfix) with ESMTP id 21C8E240537A
	for <linux-mm@kvack.org>; Mon, 25 Aug 2008 18:18:43 +0200 (CEST)
Received: from mx.iplabs.de ([127.0.0.1])
	by localhost (osiris.iplabs.de [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id v9vD2hrqMJDM for <linux-mm@kvack.org>;
	Mon, 25 Aug 2008 18:18:33 +0200 (CEST)
Received: from [192.168.178.32] (p5088A64A.dip0.t-ipconnect.de [80.136.166.74])
	by mx.iplabs.de (Postfix) with ESMTP id 5F3252405379
	for <linux-mm@kvack.org>; Mon, 25 Aug 2008 18:18:33 +0200 (CEST)
Message-ID: <48B2DB58.2010304@iplabs.de>
Date: Mon, 25 Aug 2008 18:18:32 +0200
From: Marco Nietz <m.nietz-mm@iplabs.de>
MIME-Version: 1.0
Subject: Re: oom-killer why ?
References: <48B296C3.6030706@iplabs.de> <48B2D615.4060509@linux-foundation.org>
In-Reply-To: <48B2D615.4060509@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

here's meminfo

MemTotal:     16629224 kB
MemFree:        384516 kB
Buffers:           936 kB
Cached:       14711232 kB
SwapCached:         60 kB
Active:        3154296 kB
Inactive:     12669472 kB
HighTotal:    15854912 kB
HighFree:        20872 kB
LowTotal:       774312 kB
LowFree:        363644 kB
SwapTotal:     7815612 kB
SwapFree:      7811560 kB
Dirty:           64208 kB
Writeback:           0 kB
AnonPages:     1111428 kB
Mapped:         303440 kB
Slab:           157620 kB
PageTables:     238648 kB
NFS_Unstable:        0 kB
Bounce:              0 kB
CommitLimit:  16130224 kB
Committed_AS:  2329552 kB
VmallocTotal:   118776 kB
VmallocUsed:      8596 kB
VmallocChunk:   110060 kB

and here vmstat

nr_anon_pages 282519
nr_mapped 75910
nr_file_pages 3673378
nr_slab 39474
nr_page_table_pages 61177
nr_dirty 4911
nr_writeback 0
nr_unstable 0
nr_bounce 0
pgpgin 1878625233
pgpgout 594256837
pswpin 111708
pswpout 112242
pgalloc_dma 6685603
pgalloc_dma32 0
pgalloc_normal 1137887133
pgalloc_high 3076312085
pgfree 4220981603
pgactivate 3168847062
pgdeactivate 1804783249
pgfault 2209247031
pgmajfault 109378
pgrefill_dma 2202
pgrefill_dma32 0
pgrefill_normal 7741916
pgrefill_high 2086015597
pgsteal_dma 0
pgsteal_dma32 0
pgsteal_normal 0
pgsteal_high 0
pgscan_kswapd_dma 7857
pgscan_kswapd_dma32 0
pgscan_kswapd_normal 31078435
pgscan_kswapd_high 1109005504
pgscan_direct_dma 3
pgscan_direct_dma32 0
pgscan_direct_normal 25210
pgscan_direct_high 2507040
pginodesteal 0
slabs_scanned 363079168
kswapd_steal 1135004729
kswapd_inodesteal 15276762
pageoutrun 8748970
allocstall 2976
pgrotated 410023



Christoph Lameter schrieb:
> Marco Nietz wrote:
> 
>> DMA32: empty
>> Normal: 0*4kB 0*8kB 1*16kB 0*32kB 1*64kB 0*128kB 0*256kB 1*512kB
>> 1*1024kB 1*2048kB 0*4096kB = 3664kB
> 
> If the flags are for a regular allocation then you have had a something that
> leaks kernel memory (device driver?). Can you get us the output of
> /proc/meminfo and /proc/vmstat?
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
