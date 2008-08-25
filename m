Received: from localhost (localhost.localdomain [127.0.0.1])
	by mx.iplabs.de (Postfix) with ESMTP id 66C4D240537A
	for <linux-mm@kvack.org>; Mon, 25 Aug 2008 13:26:05 +0200 (CEST)
Received: from mx.iplabs.de ([127.0.0.1])
	by localhost (osiris.iplabs.de [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id wB1CIPmhAlqi for <linux-mm@kvack.org>;
	Mon, 25 Aug 2008 13:25:55 +0200 (CEST)
Received: from [172.16.1.1] (mnietz.client.iplabs.de [172.16.1.1])
	by mx.iplabs.de (Postfix) with ESMTP id 7034B2405379
	for <linux-mm@kvack.org>; Mon, 25 Aug 2008 13:25:55 +0200 (CEST)
Message-ID: <48B296C3.6030706@iplabs.de>
Date: Mon, 25 Aug 2008 13:25:55 +0200
From: Marco Nietz <m.nietz-mm@iplabs.de>
MIME-Version: 1.0
Subject: oom-killer why ?
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Today, i've meet the oom-killer the first time, but i could not
understand why this happens.

Swap and Highmem is ok, Could this be a Problem of lowmem and the bigmen
 (pae) Kernel ?

It's a Machine with 2x4 Xeon Cores and 16GB of physical Memory running
Debian Etch with Kernel 2.6.18-6-686-bigmem.

Hier the dmesg-Output

oom-killer: gfp_mask=0x84d0, order=0
 [<c014290b>] out_of_memory+0x25/0x13a
 [<c0143d74>] __alloc_pages+0x1f5/0x275
 [<c014a439>] __pte_alloc+0x11/0x9e
 [<c014b864>] copy_page_range+0x155/0x3da
 [<c01ba1d8>] vsnprintf+0x419/0x457
 [<c011c184>] copy_process+0xa73/0x10a9
 [<c011ca1f>] do_fork+0x91/0x17a
 [<c0124d67>] do_gettimeofday+0x31/0xce
 [<c01012c2>] sys_clone+0x28/0x2d
 [<c0102c0d>] sysenter_past_esp+0x56/0x79
Mem-info:
DMA per-cpu:
cpu 0 hot: high 0, batch 1 used:0
cpu 0 cold: high 0, batch 1 used:0
cpu 1 hot: high 0, batch 1 used:0
cpu 1 cold: high 0, batch 1 used:0
cpu 2 hot: high 0, batch 1 used:0
cpu 2 cold: high 0, batch 1 used:0
cpu 3 hot: high 0, batch 1 used:0
cpu 3 cold: high 0, batch 1 used:0
cpu 4 hot: high 0, batch 1 used:0
cpu 4 cold: high 0, batch 1 used:0
cpu 5 hot: high 0, batch 1 used:0
cpu 5 cold: high 0, batch 1 used:0
cpu 6 hot: high 0, batch 1 used:0
cpu 6 cold: high 0, batch 1 used:0
cpu 7 hot: high 0, batch 1 used:0
cpu 7 cold: high 0, batch 1 used:0
DMA32 per-cpu: empty
Normal per-cpu:
cpu 0 hot: high 186, batch 31 used:128
cpu 0 cold: high 62, batch 15 used:48
cpu 1 hot: high 186, batch 31 used:30
cpu 1 cold: high 62, batch 15 used:47
cpu 2 hot: high 186, batch 31 used:35
cpu 2 cold: high 62, batch 15 used:59
cpu 3 hot: high 186, batch 31 used:79
cpu 3 cold: high 62, batch 15 used:55
cpu 4 hot: high 186, batch 31 used:8
cpu 4 cold: high 62, batch 15 used:53
cpu 5 hot: high 186, batch 31 used:162
cpu 5 cold: high 62, batch 15 used:52
cpu 6 hot: high 186, batch 31 used:181
cpu 6 cold: high 62, batch 15 used:57
cpu 7 hot: high 186, batch 31 used:9
cpu 7 cold: high 62, batch 15 used:58
HighMem per-cpu:
cpu 0 hot: high 186, batch 31 used:18
cpu 0 cold: high 62, batch 15 used:9
cpu 1 hot: high 186, batch 31 used:47
cpu 1 cold: high 62, batch 15 used:1
cpu 2 hot: high 186, batch 31 used:102
cpu 2 cold: high 62, batch 15 used:7
cpu 3 hot: high 186, batch 31 used:171
cpu 3 cold: high 62, batch 15 used:7
cpu 4 hot: high 186, batch 31 used:172
cpu 4 cold: high 62, batch 15 used:14
cpu 5 hot: high 186, batch 31 used:26
cpu 5 cold: high 62, batch 15 used:14
cpu 6 hot: high 186, batch 31 used:29
cpu 6 cold: high 62, batch 15 used:2
cpu 7 hot: high 186, batch 31 used:99
cpu 7 cold: high 62, batch 15 used:3
Free pages:     5949076kB (5941820kB HighMem)
Active:1102100 inactive:1373666 dirty:4831 writeback:0 unstable:0
free:1487269 slab:35543 mapped:139487 pagetables:152485
DMA free:3592kB min:68kB low:84kB high:100kB active:24kB inactive:16kB
present:16384kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 880 17392
DMA32 free:0kB min:0kB low:0kB high:0kB active:0kB inactive:0kB
present:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 880 17392
Normal free:3664kB min:3756kB low:4692kB high:5632kB active:280kB
inactive:244kB present:901120kB pages_scanned:593 all_unreclaimable? yes
lowmem_reserve[]: 0 0 0 132096
HighMem free:5941820kB min:512kB low:18148kB high:35784kB
active:4408096kB inactive:5494404kB present:16908288kB pages_scanned:0
all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
DMA: 2*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 1*512kB 1*1024kB
1*2048kB 0*4096kB = 3592kB
DMA32: empty
Normal: 0*4kB 0*8kB 1*16kB 0*32kB 1*64kB 0*128kB 0*256kB 1*512kB
1*1024kB 1*2048kB 0*4096kB = 3664kB
HighMem: 331931*4kB 303446*8kB 105186*16kB 14856*32kB 432*64kB 2*128kB
1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 5941820kB
Swap cache: add 216611, delete 216611, find 112681/129891, race 0+3
Free swap  = 7815516kB
Total swap = 7815612kB
Free swap:       7815516kB
4456448 pages of RAM
4227072 pages of HIGHMEM
299142 reserved pages
7012372 pages shared
0 pages swap cached
4831 pages dirty
0 pages writeback
139487 pages mapped
35576 pages slab
142180 pages pagetables
4456448 pages of RAM
4227072 pages of HIGHMEM
299142 reserved pages
6977702 pages shared
0 pages swap cached
4831 pages dirty
0 pages writeback
139487 pages mapped
35609 pages slab
138447 pages pagetables
4456448 pages of RAM
4227072 pages of HIGHMEM
299142 reserved pages
6901408 pages shared
0 pages swap cached
4831 pages dirty
0 pages writeback
139487 pages mapped
35576 pages slab
134910 pages pagetables


Thanks in Advance
Marco



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
