Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 881036B00F3
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 11:58:10 -0400 (EDT)
Received: by mail-we0-f180.google.com with SMTP id x43so548487wey.25
        for <linux-mm@kvack.org>; Tue, 30 Apr 2013 08:58:09 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 30 Apr 2013 08:58:08 -0700
Message-ID: <CAA25o9RoGkNUY_HvVHX3chYwULyGE87ZPkgQcysXe5M6VgkXNg@mail.gmail.com>
Subject: what does it mean, to be Out Of Memory?
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Greetings,

we've noticed situations in which the OOM killer is triggered when
there appears to be plenty of swap space.  See log below.  This is on
a device with 4 GB RAM and kernel 3.4.

The swap device is /dev/zram0.  The compression ratio is usually 2.5
to 3 and this load is no different from our typical load.

So what may be causing this?

Thanks!
Luigi

[15254.881681] CPU1: Package power limit normal
[15419.884126] sed invoked oom-killer: gfp_mask=0x201da, order=0,
oom_adj=-17, oom_score_adj=-1000
[15419.884136] Pid: 21596, comm: sed Tainted: G         C   3.4.0 #1
[15419.884141] Call Trace:
[15419.884151]  [<ffffffff81464d61>] dump_header.isra.11+0x6f/0x17e
[15419.884159]  [<ffffffff811d9077>] ? ___ratelimit+0xb7/0xd4
[15419.884166]  [<ffffffff81464ebc>]
oom_kill_process.part.14.constprop.17+0x4c/0x248
[15419.884174]  [<ffffffff8146ab78>] ? _raw_spin_unlock+0xe/0x10
[15419.884181]  [<ffffffff810a42ad>] ? task_unlock+0x10/0x12
[15419.884187]  [<ffffffff810a4a20>] out_of_memory+0x2a0/0x330

etc. etc.

[15419.884513] lowmem_reserve[]: 0 0 0 0
[15419.884519] DMA: 1*4kB 1*8kB 0*16kB 1*32kB 2*64kB 1*128kB 1*256kB
0*512kB 2*1024kB 2*2048kB 2*4096kB = 14892kB
[15419.884536] DMA32: 1376*4kB 17*8kB 29*16kB 28*32kB 15*64kB 6*128kB
1*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 10520kB
[15419.884554] Normal: 634*4kB 4*8kB 0*16kB 3*32kB 0*64kB 0*128kB
0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 2664kB
[15419.884570] 305503 total pagecache pages
[15419.884574] 14641 pages in swap cache
[15419.884578] Swap cache stats: add 9201068, delete 9186427, find
1841483/2678044
[15419.884583] Free swap  = 4032196kB
[15419.884586] Total swap = 5832764kB
[15419.901586] 1046000 pages RAM

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
