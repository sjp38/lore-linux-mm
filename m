Date: Sun, 27 Mar 2005 13:26:39 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: OOM killer issue with 2.6.12-rc1
Message-ID: <20050327162639.GA26390@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, andrea@suse.de
List-ID: <linux-mm.kvack.org>

Hi, 

While running anon memory allocator (fillmem), I've witnessed
the OOM killer behave badly.

Linux xeon.cnet 2.6.12-rc1 #3 SMP Sun Mar 27 17:44:25 BRT 2005 i686 i686 i386 GNU/Linux

There was no swap free, but note that it killed the hog (fillmem) and 
an innocent bash right after that, while having huge amounts of 
free memory.

oom-killer: gfp_mask=0x1d2
DMA per-cpu:oom-killer: gfp_mask=0x1d2
DMA per-cpu:
cpu 0 hot: low 2, high 6, batch 1
cpu 0 cold: low 0, high 2, batch 1
cpu 1 hot: low 2, high 6, batch 1
cpu 1 cold: low 0, high 2, batch 1
cpu 2 hot: low 2, high 6, batch 1
cpu 2 cold: low 0, high 2, batch 1
cpu 3 hot: low 2, high 6, batch 1
cpu 3 cold: low 0, high 2, batch 1
Normal per-cpu:
cpu 0 hot: low 32, high 96, batch 16
cpu 0 cold: low 0, high 32, batch 16
cpu 1 hot: low 32, high 96, batch 16
cpu 1 cold: low 0, high 32, batch 16
cpu 2 hot: low 32, high 96, batch 16
cpu 2 cold: low 0, high 32, batch 16
cpu 3 hot: low 32, high 96, batch 16
cpu 3 cold: low 0, high 32, batch 16
HighMem per-cpu:
cpu 0 hot: low 32, high 96, batch 16
cpu 0 cold: low 0, high 32, batch 16
cpu 1 hot: low 32, high 96, batch 16
cpu 1 cold: low 0, high 32, batch 16
cpu 2 hot: low 32, high 96, batch 16
cpu 2 cold: low 0, high 32, batch 16
cpu 3 hot: low 32, high 96, batch 16
cpu 3 cold: low 0, high 32, batch 16
                                     
Free pages:       49272kB (452kB HighMem)
Active:223648 inactive:224345 dirty:0 writeback:0 unstable:0 free:12318 slab:2046 mapped:447979 pagetables:842
DMA free:8192kB min:68kB low:84kB high:100kB active:2208kB inactive:1660kB present:16384kB pages_scanned:3902 all_unreclaimable? yes
lowmem_reserve[]: 0 880 2031
Normal free:40628kB min:3756kB low:4692kB high:5632kB active:402344kB inactive:406860kB present:901120kB pages_scanned:713412 all_unreclaimable? no
lowmem_reserve[]: 0 0 9212
HighMem free:452kB min:512kB low:640kB high:768kB active:490040kB inactive:488736kB present:982528kB pages_scanned:2172790 all_unreclaimable? yes
lowmem_reserve[]: 0 0 0
DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 2*4096kB = 8192kB
Normal: 5*4kB 4*8kB 2*16kB 1*32kB 1*64kB 0*128kB 0*256kB 1*512kB 1*1024kB 1*2048kB 9*4096kB = 40628kB
HighMem: 1*4kB 0*8kB 0*16kB 0*32kB 1*64kB 1*128kB 1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 452kB
Swap cache: add 1002488, delete 1002492, find 251310/287809, race 0+0
Free swap  = 0kB
Total swap = 1020116kB
Out of Memory: Killed process 3172 (fillmem).
                                              
cpu 0 hot: low 2, high 6, batch 1
cpu 0 cold: low 0, high 2, batch 1
cpu 1 hot: low 2, high 6, batch 1
cpu 1 cold: low 0, high 2, batch 1
cpu 2 hot: low 2, high 6, batch 1
cpu 2 cold: low 0, high 2, batch 1
cpu 3 hot: low 2, high 6, batch 1
cpu 3 cold: low 0, high 2, batch 1
Normal per-cpu:
cpu 0 hot: low 32, high 96, batch 16
cpu 0 cold: low 0, high 32, batch 16
cpu 1 hot: low 32, high 96, batch 16
cpu 1 cold: low 0, high 32, batch 16
cpu 2 hot: low 32, high 96, batch 16
cpu 2 cold: low 0, high 32, batch 16
cpu 3 hot: low 32, high 96, batch 16
cpu 3 cold: low 0, high 32, batch 16
HighMem per-cpu:
cpu 0 hot: low 32, high 96, batch 16
cpu 0 cold: low 0, high 32, batch 16
cpu 1 hot: low 32, high 96, batch 16
cpu 1 cold: low 0, high 32, batch 16
cpu 2 hot: low 32, high 96, batch 16
cpu 2 cold: low 0, high 32, batch 16
cpu 3 hot: low 32, high 96, batch 16
cpu 3 cold: low 0, high 32, batch 16
                                     
Free pages:      265276kB (109508kB HighMem)
Active:201184 inactive:192704 dirty:0 writeback:0 unstable:0 free:122655 slab:2029 mapped:393562 pagetables:842
DMA free:12036kB min:68kB low:84kB high:100kB active:0kB inactive:0kB present:16384kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 880 2031
Normal free:849780kB min:3756kB low:4692kB high:5632kB active:84kB inactive:268kB present:901120kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 9212
HighMem free:976004kB min:512kB low:640kB high:768kB active:0kB inactive:4460kB present:982528kB pages_scanned:33 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 9*4kB 16*8kB 15*16kB 10*32kB 11*64kB 5*128kB 3*256kB 0*512kB 1*1024kB 0*2048kB 2*4096kB = 12052kB
Normal: 801*4kB 604*8kB 475*16kB 357*32kB 281*64kB 241*128kB 228*256kB 158*512kB 93*1024kB 44*2048kB 110*4096kB = 851060kB
HighMem: 383*4kB 347*8kB 327*16kB 268*32kB 253*64kB 209*128kB 180*256kB 139*512kB 95*1024kB 58*2048kB 142*4096kB = 976004kB
Swap cache: add 1003965, delete 1002918, find 251310/287809, race 0+0
Free swap  = 1008956kB
Total swap = 1020116kB
Out of Memory: Killed process 3013 (bash).
                                           

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
