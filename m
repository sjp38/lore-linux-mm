Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id 6489682F64
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 14:49:52 -0400 (EDT)
Received: by obbwb3 with SMTP id wb3so71419053obb.0
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 11:49:52 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id xy5si6159146oeb.105.2015.10.16.11.49.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 16 Oct 2015 11:49:51 -0700 (PDT)
Subject: Re: Silent hang up caused by pages being not scanned?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201510132121.GDE13044.FOSHLJOMFOtQVF@I-love.SAKURA.ne.jp>
	<CA+55aFxwg=vS2nrXsQhAUzPQDGb8aQpZi0M7UUh21ftBo-z46Q@mail.gmail.com>
	<20151015131409.GD2978@dhcp22.suse.cz>
	<20151016155716.GF19597@dhcp22.suse.cz>
	<CA+55aFynmzy=3f5ae6iAYC7o_27C1UkNzn9x4OFjrW6j6bV9rw@mail.gmail.com>
In-Reply-To: <CA+55aFynmzy=3f5ae6iAYC7o_27C1UkNzn9x4OFjrW6j6bV9rw@mail.gmail.com>
Message-Id: <201510170349.FFE52187.OOSJFMOVHQFtLF@I-love.SAKURA.ne.jp>
Date: Sat, 17 Oct 2015 03:49:39 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org, mhocko@kernel.org
Cc: rientjes@google.com, oleg@redhat.com, kwalker@redhat.com, cl@linux.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

Linus Torvalds wrote:
> Tetsuo, mind trying it out and maybe tweaking it a bit for the load
> you have? Does it seem to improve on your situation?

Yes, I already tried it and just replied to Michal.

I tested for one hour using various memory stressing programs.
As far as I tested, I did not hit silent hang up (

 MemAlloc-Info: X stalling task, 0 dying task, 0 victim task.

where X > 0).

----------------------------------------
[  134.510993] Mem-Info:
[  134.511940] active_anon:408777 inactive_anon:2088 isolated_anon:24
[  134.511940]  active_file:15 inactive_file:24 isolated_file:0
[  134.511940]  unevictable:0 dirty:4 writeback:1 unstable:0
[  134.511940]  slab_reclaimable:3109 slab_unreclaimable:5594
[  134.511940]  mapped:679 shmem:2156 pagetables:2077 bounce:0
[  134.511940]  free:12911 free_pcp:31 free_cma:0
[  134.521256] Node 0 DMA free:7256kB min:400kB low:500kB high:600kB active_anon:6560kB inactive_anon:180kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:0kB writeback:0kB mapped:80kB shmem:184kB slab_reclaimable:236kB slab_unreclaimable:296kB kernel_stack:48kB pagetables:556kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[  134.532779] lowmem_reserve[]: 0 1714 1714 1714
[  134.534455] Node 0 DMA32 free:44388kB min:44652kB low:55812kB high:66976kB active_anon:1628548kB inactive_anon:8172kB active_file:60kB inactive_file:96kB unevictable:0kB isolated(anon):96kB isolated(file):0kB present:2080640kB managed:1759252kB mlocked:0kB dirty:16kB writeback:4kB mapped:2636kB shmem:8440kB slab_reclaimable:12200kB slab_unreclaimable:22080kB kernel_stack:3584kB pagetables:7752kB unstable:0kB bounce:0kB free_pcp:240kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:1016 all_unreclaimable? yes
[  134.545830] lowmem_reserve[]: 0 0 0 0
[  134.547404] Node 0 DMA: 16*4kB (UME) 16*8kB (UME) 10*16kB (UME) 6*32kB (UME) 1*64kB (M) 2*128kB (UE) 1*256kB (M) 2*512kB (UE) 3*1024kB (UME) 1*2048kB (U) 0*4096kB = 7264kB
[  134.552766] Node 0 DMA32: 1158*4kB (UME) 638*8kB (UE) 244*16kB (UME) 163*32kB (UE) 73*64kB (UE) 34*128kB (UME) 17*256kB (UME) 10*512kB (UME) 7*1024kB (UM) 0*2048kB 0*4096kB = 44520kB
[  134.558111] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  134.560358] 2195 total pagecache pages
[  134.562043] 0 pages in swap cache
[  134.563604] Swap cache stats: add 0, delete 0, find 0/0
[  134.565441] Free swap  = 0kB
[  134.567015] Total swap = 0kB
[  134.568628] 524157 pages RAM
[  134.570034] 0 pages HighMem/MovableOnly
[  134.571681] 80368 pages reserved
[  134.573467] 0 pages hwpoisoned
----------------------------------------

Only problem I felt is that the ratio of inactive_file/writeback
(shown below) was high (compared to shown above) when I did

  $ cat < /dev/zero > /tmp/file1 & cat < /dev/zero > /tmp/file2 & cat < /dev/zero > /tmp/file3 & sleep 10; ./a.out; killall cat

but I think this patch is better than current code.

----------------------------------------
[ 1135.909600] Mem-Info:
[ 1135.910686] active_anon:321011 inactive_anon:4664 isolated_anon:0
[ 1135.910686]  active_file:3170 inactive_file:78035 isolated_file:512
[ 1135.910686]  unevictable:0 dirty:0 writeback:78618 unstable:0
[ 1135.910686]  slab_reclaimable:5739 slab_unreclaimable:6170
[ 1135.910686]  mapped:4666 shmem:8300 pagetables:1966 bounce:0
[ 1135.910686]  free:12938 free_pcp:0 free_cma:0
[ 1135.925255] Node 0 DMA free:7232kB min:400kB low:500kB high:600kB active_anon:5852kB inactive_anon:196kB active_file:120kB inactive_file:980kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:0kB writeback:968kB mapped:248kB shmem:388kB slab_reclaimable:316kB slab_unreclaimable:272kB kernel_stack:64kB pagetables:100kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:7444 all_unreclaimable? yes
[ 1135.936728] lowmem_reserve[]: 0 1714 1714 1714
[ 1135.938486] Node 0 DMA32 free:44520kB min:44652kB low:55812kB high:66976kB active_anon:1278192kB inactive_anon:18460kB active_file:12560kB inactive_file:313176kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2080640kB managed:1759252kB mlocked:0kB dirty:0kB writeback:313504kB mapped:18416kB shmem:32812kB slab_reclaimable:22640kB slab_unreclaimable:24408kB kernel_stack:4240kB pagetables:7764kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:2957668 all_unreclaimable? yes
[ 1135.950355] lowmem_reserve[]: 0 0 0 0
[ 1135.952011] Node 0 DMA: 7*4kB (U) 14*8kB (UM) 13*16kB (UM) 6*32kB (UME) 1*64kB (M) 4*128kB (UME) 2*256kB (UM) 3*512kB (UME) 2*1024kB (UE) 1*2048kB (M) 0*4096kB = 7260kB
[ 1135.957169] Node 0 DMA32: 241*4kB (UE) 929*8kB (UE) 496*16kB (UME) 277*32kB (UE) 135*64kB (UME) 17*128kB (UME) 3*256kB (E) 16*512kB (ME) 0*1024kB 0*2048kB 0*4096kB = 44972kB
[ 1135.963047] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[ 1135.965472] 90009 total pagecache pages
[ 1135.967078] 0 pages in swap cache
[ 1135.968581] Swap cache stats: add 0, delete 0, find 0/0
[ 1135.970424] Free swap  = 0kB
[ 1135.971828] Total swap = 0kB
[ 1135.973248] 524157 pages RAM
[ 1135.974655] 0 pages HighMem/MovableOnly
[ 1135.976230] 80368 pages reserved
[ 1135.977745] 0 pages hwpoisoned
----------------------------------------

I can still hit OOM livelock (

 MemAlloc-Info: X stalling task, Y dying task, Z victim task.

where X > 0 && Y > 0).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
