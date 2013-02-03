Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 1C61A6B0002
	for <linux-mm@kvack.org>; Sun,  3 Feb 2013 04:19:10 -0500 (EST)
Message-ID: <1359883137.17676.3.camel@hakkenden.homenet>
Subject: Re: [Bug 53031] New: kswapd in uninterruptible sleep state
From: "Nikolay S." <nowhere@hakkenden.ath.cx>
Date: Sun, 03 Feb 2013 13:18:57 +0400
In-Reply-To: <1359707081.15084.1.camel@rybalov.eng.ttk.net>
References: <bug-53031-27@https.bugzilla.kernel.org/>
	 <20130131134220.e2fa401a.akpm@linux-foundation.org>
	 <1359707081.15084.1.camel@rybalov.eng.ttk.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

Small update. This is what happens with swap, when I add some write
load:

 0  0 236292 176816   5828 2536020   64   96  4852   236 13709 5592 28 13 52  7
 1  0 236816 231840   5760 2468724  192  556  9496 25784 14471 7791 18 25 40 17
 1  1 237000 244528   5748 2441664  256  228 10528   228 13538 6943 33 20 34 13
 1  0 237048 246392   5740 2432556  160   80  6792    80 13815 7412 13 17 57 13
 3  0 237516 305268   5740 2363156   96  488 10124   488 14266 8920 11 24 53 12
 3  0 237908 346188   5664 2311168  192  444  7692   476 14348 9397 14 23 57  7
 2  1 238124 361856   5652 2282708  128  260  8024 25048 13894 6326 15 19 40 26
 1  2 238368 356480   5656 2284672  128  260  9656   260 13961 6706 12 14 27 47
 0  2 238732 363268   5648 2264680   64  404 11288   404 13771 5943 32 18 17 32
procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
 1  0 239016 370372   5588 2246296  192  312 12864   312 14056 8288 15 20 40 24
 0  2 239336 379684   5596 2228056    0  336  7488   380 13875 8791  8 22 53 17
 1  1 239796 410928   5584 2190084   64  476 10300 16848 13721 7323  7 20 42 31
 1  1 240096 432072   5308 2159016   64  320  9888   364 13461 7787  8 18 39 35
 1  0 240332 445940   5304 2137936   96  264 10960   264 13609 6750 19 19 37 25
 1  1 240676 454244   5284 2116968   32  360 12304   368 13466 8864 11 22 42 25
 3  1 241156 468920   5276 2088800   32  504 11592   532 13346 6394 27 18 23 32
 0  2 241436 478448   5248 2066564  288  360 12248  1992 13701 6627 23 21 23 32
 1  1 241776 496704   5248 2038424  156  400  9632   424 13040 5904 29 15 28 28
 0  2 242460 521064   5220 2004936   32  700 12212   708 13476 6983 15 16 34 34
 1  1 242396 517360   5220 1996648  256  104 10304   104 13196 6571 16 18 23 43
 0  1 241716 532496   5220 1968204  736   68  7892    88 13260 6522 24 18 27 32
 1  1 242084 551444   5228 1934016  256  480  6104 99240 13365 5915 10 22 22 46
 1  2 242284 553736   5228 1915204  480  396  6116   396 11012 5594 11 20 33 36
 0  2 242740 553860   5468 1914344   64  468 11692   468 12931 3755 24 18 22 37
 0  1 242968 534332   5472 1926280    0  252 13272   308 13678 5930 13 15 26 46

$ grep [Aa]non /proc/meminfo 
Active(anon):     595096 kB
Inactive(anon):   152580 kB
AnonPages:        735052 kB
AnonHugePages:    180224 kB


D? D?N?., 01/02/2013 D2 12:24 +0400, Nikolay S. D?D,N?DuN?:
> D? D?N?., 31/01/2013 D2 13:42 -0800, Andrew Morton D?D,N?DuN?:
> > (switched to email.  Please respond via emailed reply-to-all, not via the
> > bugzilla web interface).
> > 
> > On Fri, 25 Jan 2013 17:56:25 +0000 (UTC)
> > bugzilla-daemon@bugzilla.kernel.org wrote:
> > 
> > > https://bugzilla.kernel.org/show_bug.cgi?id=53031
> > > 
> > >            Summary: kswapd in uninterruptible sleep state
> > >            Product: Memory Management
> > >            Version: 2.5
> > >     Kernel Version: 3.7.3,3.7.4
> > >           Platform: All
> > >         OS/Version: Linux
> > >               Tree: Mainline
> > >             Status: NEW
> > >           Severity: normal
> > >           Priority: P1
> > >          Component: Other
> > >         AssignedTo: akpm@linux-foundation.org
> > >         ReportedBy: dairinin@gmail.com
> > >         Regression: No
> > 
> > I'd say "Regression: yes"!
> > 
> > Can you please run sysrq-W (or "echo w > /proc/sysrq-trigger" when
> > kswapd is stuck so we can see where it is stuck?
> 
> Feb  1 12:23:03 heimdall kernel: SysRq : Show Blocked State
> Feb  1 12:23:03 heimdall kernel: task                        PC stack   pid father
> Feb  1 12:23:03 heimdall kernel: kswapd0         D ffff88011fc110c0     0   402      2 0x00000000
> Feb  1 12:23:03 heimdall kernel: ffff88011a86b000 0000000000000046 ffff88011b2adc28 ffffffff81613420
> Feb  1 12:23:03 heimdall kernel: ffff88011b2adfd8 ffff88011b2adfd8 ffff88011b2adfd8 ffff88011a86b000
> Feb  1 12:23:03 heimdall kernel: 0000000000000286 ffff88011b2adc98 ffffffff81746fc0 000000010043a0ff
> Feb  1 12:23:03 heimdall kernel: Call Trace:
> Feb  1 12:23:03 heimdall kernel: [<ffffffff813a5bc1>] ? schedule_timeout+0x141/0x1f0
> Feb  1 12:23:03 heimdall kernel: [<ffffffff8103fff0>] ? usleep_range+0x40/0x40
> Feb  1 12:23:03 heimdall kernel: [<ffffffff813a73b0>] ? io_schedule_timeout+0x60/0x90
> Feb  1 12:23:03 heimdall kernel: [<ffffffff810bb39a>] ? congestion_wait+0x7a/0xc0
> Feb  1 12:23:03 heimdall kernel: [<ffffffff81050cb0>] ? add_wait_queue+0x60/0x60
> Feb  1 12:23:03 heimdall kernel: [<ffffffff810b4cf4>] ? kswapd+0x844/0x9f0
> Feb  1 12:23:03 heimdall kernel: [<ffffffff81050cb0>] ? add_wait_queue+0x60/0x60
> Feb  1 12:23:03 heimdall kernel: [<ffffffff810b44b0>] ? shrink_lruvec+0x540/0x540
> Feb  1 12:23:03 heimdall kernel: [<ffffffff81050523>] ? kthread+0xb3/0xc0
> Feb  1 12:23:03 heimdall kernel: [<ffffffff81050470>] ? flush_kthread_work+0x110/0x110
> Feb  1 12:23:03 heimdall kernel: [<ffffffff813a866c>] ? ret_from_fork+0x7c/0xb0
> Feb  1 12:23:03 heimdall kernel: [<ffffffff81050470>] ? flush_kthread_work+0x110/0x110
> 
> > Also sysrq-m when it is in that state would be useful, thanks.
> 
> Feb  1 12:24:07 heimdall kernel: SysRq : Show Memory
> Feb  1 12:24:07 heimdall kernel: Mem-Info:
> Feb  1 12:24:07 heimdall kernel: DMA per-cpu:
> Feb  1 12:24:07 heimdall kernel: CPU    0: hi:    0, btch:   1 usd:   0
> Feb  1 12:24:07 heimdall kernel: CPU    1: hi:    0, btch:   1 usd:   0
> Feb  1 12:24:07 heimdall kernel: DMA32 per-cpu:
> Feb  1 12:24:07 heimdall kernel: CPU    0: hi:  186, btch:  31 usd:  16
> Feb  1 12:24:07 heimdall kernel: CPU    1: hi:  186, btch:  31 usd: 123
> Feb  1 12:24:07 heimdall kernel: Normal per-cpu:
> Feb  1 12:24:07 heimdall kernel: CPU    0: hi:  186, btch:  31 usd:  45
> Feb  1 12:24:07 heimdall kernel: CPU    1: hi:  186, btch:  31 usd: 164
> Feb  1 12:24:07 heimdall kernel: active_anon:168267 inactive_anon:55882 isolated_anon:0
> Feb  1 12:24:07 heimdall kernel: active_file:311587 inactive_file:312300 isolated_file:0
> Feb  1 12:24:07 heimdall kernel: unevictable:552 dirty:22 writeback:0 unstable:0
> Feb  1 12:24:07 heimdall kernel: free:38634 slab_reclaimable:20255 slab_unreclaimable:15014
> Feb  1 12:24:07 heimdall kernel: mapped:6615 shmem:337 pagetables:2304 bounce:0
> Feb  1 12:24:07 heimdall kernel: free_cma:0
> Feb  1 12:24:07 heimdall kernel: DMA free:15904kB min:256kB low:320kB high:384kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15648kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
> Feb  1 12:24:07 heimdall kernel: lowmem_reserve[]: 0 3503 4007 4007
> Feb  1 12:24:07 heimdall kernel: DMA32 free:126528kB min:58860kB low:73572kB high:88288kB active_anon:568560kB inactive_anon:116272kB active_file:1189340kB inactive_file:1191388kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3587840kB mlocked:0kB dirty:72kB writeback:0kB mapped:15024kB shmem:1336kB slab_reclaimable:68328kB slab_unreclaimable:31484kB kernel_stack:832kB pagetables:7028kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> Feb  1 12:24:07 heimdall kernel: lowmem_reserve[]: 0 0 504 504
> Feb  1 12:24:07 heimdall kernel: Normal free:12104kB min:8464kB low:10580kB high:12696kB active_anon:104508kB inactive_anon:107256kB active_file:57008kB inactive_file:57812kB unevictable:2208kB isolated(anon):0kB isolated(file):0kB present:516096kB mlocked:2208kB dirty:16kB writeback:0kB mapped:11436kB shmem:12kB slab_reclaimable:12692kB slab_unreclaimable:28572kB kernel_stack:968kB pagetables:2188kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> Feb  1 12:24:07 heimdall kernel: lowmem_reserve[]: 0 0 0 0
> Feb  1 12:24:07 heimdall kernel: DMA: 0*4kB 0*8kB 0*16kB 1*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 1*2048kB 3*4096kB = 15904kB
> Feb  1 12:24:07 heimdall kernel: DMA32: 25706*4kB 1119*8kB 304*16kB 223*32kB 37*64kB 3*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 126528kB
> Feb  1 12:24:07 heimdall kernel: Normal: 880*4kB 263*8kB 191*16kB 4*32kB 16*64kB 6*128kB 2*256kB 2*512kB 0*1024kB 0*2048kB 0*4096kB = 12136kB
> Feb  1 12:24:07 heimdall kernel: 625162 total pagecache pages
> Feb  1 12:24:07 heimdall kernel: 463 pages in swap cache
> Feb  1 12:24:07 heimdall kernel: Swap cache stats: add 5970, delete 5507, find 3004/3260
> Feb  1 12:24:07 heimdall kernel: Free swap  = 4184860kB
> Feb  1 12:24:07 heimdall kernel: Total swap = 4194300kB
> Feb  1 12:24:07 heimdall kernel: 1048560 pages RAM
> Feb  1 12:24:07 heimdall kernel: 36198 pages reserved
> Feb  1 12:24:07 heimdall kernel: 730743 pages shared
> Feb  1 12:24:07 heimdall kernel: 796007 pages non-shared
> 
> > [remainder retained for linux-mm to enjoy]
> > 
> > > 
> > > Created an attachment (id=91781)
> > >  --> (https://bugzilla.kernel.org/attachment.cgi?id=91781)
> > > Script do show what has changed in /proc/vmstat
> > > 
> > > I have recently upgraded from 3.2 to 3.7.3, and I am seeing, that the
> > > behavior of kswapd is strange at least.
> > > 
> > > The machine is core2duo e7200 with 4G RAM, running 3.7.3 kernel. It has
> > > compaction and THP (always) enabled.
> > > 
> > > The machine is serving files over the network, so it is constantly under
> > > memory pressure from page cache. The network is not very fast, and average disk
> > > read rate is between 2 and 8 megabytes per second.
> > > 
> > > In normal state, when page cache is filled, the free memory (according
> > > to free and vmstat) is fluctuating between 100 and 150 megabytes, with
> > > kswapd stepping in at 100M, quickly freeing to 150M and going to sleep
> > > again.
> > > 
> > > 1) On 3.7.3, after several hours after page cache is filled, kswapd enters
> > > permanent D-state, with free memory keeping around 150M (high watermark,
> > > I presume?). I have captured diffs for /proc/vmstat:
> > > 
> > > $ ./diffshow 5
> > > ----8<----
> > > nr_free_pages:____________________________________38327 -> 38467 (140)
> > > nr_active_anon:__________________________________110014 -> 110056 (42)
> > > nr_inactive_file:______________________________526153 -> 526297 (144)
> > > nr_active_file:__________________________________98802 -> 98864 (62)
> > > nr_anon_pages:____________________________________103475 -> 103512 (37)
> > > nr_file_pages:____________________________________627957 -> 628160 (203)
> > > nr_dirty:______________________________________________15 -> 17 (2)
> > > nr_page_table_pages:________________________2142 -> 2146 (4)
> > > nr_kernel_stack:________________________________251 -> 253 (2)
> > > nr_dirtied:__________________________________________1169312 -> 1169317 (5)
> > > nr_written:__________________________________________1211979 -> 1211982 (3)
> > > nr_dirty_threshold:__________________________159540 -> 159617 (77)
> > > nr_dirty_background_threshold:____79770 -> 79808 (38)
> > > pgpgin:__________________________________________________564650577 -> 564673241 (22664)
> > > pgpgout:________________________________________________5117612 -> 5117668 (56)
> > > pgalloc_dma32:____________________________________105487556 -> 105491067 (3511)
> > > pgalloc_normal:__________________________________84026173 -> 84029309 (3136)
> > > pgfree:__________________________________________________190134573 -> 190141394 (6821)
> > > pgactivate:__________________________________________2750244 -> 2750283 (39)
> > > pgfault:________________________________________________67214984 -> 67216222 (1238)
> > > pgsteal_kswapd_dma32:______________________45793109 -> 45795077 (1968)
> > > pgsteal_kswapd_normal:____________________61391466 -> 61394464 (2998)
> > > pgscan_kswapd_dma32:________________________45812628 -> 45814596 (1968)
> > > pgscan_kswapd_normal:______________________61465283 -> 61468281 (2998)
> > > slabs_scanned:____________________________________30783104 -> 30786432 (3328)
> > > pageoutrun:__________________________________________2936967 -> 2937033 (66)
> > > 
> > > vmstat:
> > > procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
> > > __r__ b____ swpd____ free____ buff__ cache____ si____ so______ bi______ bo____ in____ cs us sy id wa
> > > __1__ 1 296924 153064____ 6936 2479664______ 0______ 0__ 5408________ 0 11711 1350__ 1__ 2 44 53
> > > __0__ 1 296924 152448____ 6928 2480048______ 0______ 0__ 6760________ 0 9723 1127__ 1__ 4 47 48
> > > __0__ 1 296924 152948____ 6916 2479464______ 0______ 0__ 3512______ 16 10392 1231__ 1__ 2 48 49
> > > __0__ 1 296924 153616____ 6916 2478804______ 0______ 0__ 2724________ 0 10279 1078__ 0__ 2 48 49
> > > __0__ 1 296924 152972____ 6916 2480132______ 0______ 0__ 3584________ 0 11289 1252__ 1__ 3 49 48
> > > __0__ 1 296924 155348____ 6916 2478396______ 0______ 0__ 6472________ 0 11285 1132__ 1__ 2 45 53
> > > __0__ 1 296924 152988____ 6916 2481024______ 0______ 0__ 5112______ 20 10039 1257__ 0__ 2 46 52
> > > __0__ 1 296924 152968____ 6916 2481016______ 0______ 0__ 3244________ 0 9586 1127__ 1__ 3 46 51
> > > __0__ 1 296924 153500____ 6916 2481196______ 0______ 0__ 3516________ 0 10899 1127__ 1__ 1 48 49
> > > __0__ 1 296924 152860____ 6916 2481688______ 0______ 0__ 4240________ 0 10418 1245__ 1__ 3 47 49
> > > __0__ 2 296924 153016____ 6912 2478584______ 0______ 0__ 5632________ 0 12136 1516__ 2__ 3 46 49
> > > __0__ 2 296924 153292____ 6912 2480984______ 0______ 0__ 4668________ 0 10872 1248__ 1__ 2 49 48
> > > __0__ 1 296924 152420____ 6916 2481844______ 0______ 0__ 4764______ 56 11236 1402__ 1__ 3 45 51
> > > __0__ 1 296924 152652____ 6916 2481204______ 0______ 0__ 4628________ 0 9422 1208__ 0__ 3 46 51
> > > 
> > > buddyinfo:
> > > $ cat /proc/buddyinfo; sleep 1; cat /proc/buddyinfo 
> > > Node 0, zone__________ DMA__________ 0__________ 0__________ 0__________ 1__________ 2__________ 1__________ 1__________ 0____
> > > ____ 1__________ 1__________ 3 
> > > Node 0, zone______ DMA32______ 515______ 205______ 242______ 201____ 1384______ 116________ 21__________ 8____
> > > ____ 1__________ 0__________ 0 
> > > Node 0, zone____ Normal____ 1779__________ 0__________ 0________ 18________ 11__________ 3__________ 1__________ 3____
> > > ____ 0__________ 0__________ 0 
> > > Node 0, zone__________ DMA__________ 0__________ 0__________ 0__________ 1__________ 2__________ 1__________ 1__________ 0____
> > > ____ 1__________ 1__________ 3 
> > > Node 0, zone______ DMA32______ 480______ 197______ 227______ 176____ 1384______ 116________ 21__________ 8____
> > > ____ 1__________ 0__________ 0 
> > > Node 0, zone____ Normal____ 1792__________ 9__________ 0________ 18________ 11__________ 3__________ 1__________ 3____
> > > ____ 0__________ 0__________ 0
> > > 
> > > 2) Also from time to time situation switches, where free memory is fixed at
> > > some random point, fluctuating around this values at +-1 megabyte. 
> > > There is vmstat:
> > > procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
> > > __r__ b____ swpd____ free____ buff__ cache____ si____ so______ bi______ bo____ in____ cs us sy id wa
> > > __0__ 0 296480 381052____ 9732 2481324______ 1______ 2__ 2022______ 19____ 45____ 44__ 1__ 2 81 16
> > > __0__ 0 296480 382040____ 9732 2481180______ 0______ 0__ 2324________ 0 6505__ 825__ 1__ 2 96__ 1
> > > __0__ 0 296480 382500____ 9732 2481060______ 0______ 0__ 3824________ 0 5941 1046__ 1__ 2 96__ 1
> > > __0__ 0 296480 382092____ 9740 2480976______ 0______ 0__ 2048______ 16 7701__ 862__ 0__ 2 97__ 1
> > > __0__ 0 296480 382160____ 9740 2481896______ 0______ 0__ 5008________ 0 6443 1017__ 1__ 2 93__ 5
> > > __0__ 0 296480 382484____ 9740 2481668______ 0______ 0__ 2764________ 0 6972__ 799__ 0__ 2 97__ 1
> > > __0__ 0 296480 381912____ 9740 2481620______ 0______ 0__ 3780________ 0 7632 1036__ 1__ 2 96__ 1
> > > __0__ 0 296480 382240____ 9744 2481632______ 0______ 0__ 2796________ 0 7533__ 981__ 1__ 2 95__ 3
> > > __1__ 0 296480 382372____ 9748 2481756______ 0______ 0__ 2940________ 0 6565 1048__ 2__ 2 95__ 2
> > > __0__ 0 296480 383064____ 9748 2480320______ 0______ 0__ 5980________ 0 6352__ 979__ 0__ 3 92__ 5
> > > __0__ 0 296480 381380____ 9748 2481752______ 0______ 0__ 2732________ 0 6322__ 999__ 1__ 2 96__ 1
> > > __0__ 0 296480 381640____ 9748 2481992______ 0______ 0__ 2468________ 0 5640__ 849__ 0__ 2 97__ 2
> > > __0__ 0 296480 381684____ 9748 2481856______ 0______ 0__ 2760________ 0 7064__ 944__ 2__ 2 95__ 1
> > > __0__ 0 296480 381908____ 9748 2481664______ 0______ 0__ 2608________ 0 6797__ 952__ 0__ 2 94__ 4
> > > __0__ 0 296480 384024____ 9748 2479424______ 0______ 0__ 4804________ 0 6342 2767__ 1__ 2 94__ 4
> > > __0__ 0 296480 381948____ 9748 2481080______ 0______ 0__ 1868________ 0 6428__ 803__ 0__ 2 97__ 2
> > > __0__ 0 296480 382088____ 9748 2481524______ 0______ 0__ 3252________ 0 6464__ 990__ 1__ 1 98__ 1
> > > __0__ 0 296480 381884____ 9748 2481816______ 0______ 0__ 2892________ 0 7880__ 858__ 1__ 2 94__ 3
> > > __0__ 0 296480 382120____ 9748 2481848______ 0______ 0__ 2500________ 0 6207__ 905__ 1__ 1 96__ 2
> > > __0__ 1 296480 381976____ 9748 2479876______ 0______ 0__ 5188________ 0 6691__ 908__ 1__ 2 94__ 4
> > > __0__ 0 296480 381708____ 9748 2481584______ 0______ 0__ 2692________ 0 7904 1030__ 1__ 2 94__ 3
> > > __0__ 0 296480 382196____ 9748 2481704______ 0______ 0__ 2092________ 0 6715__ 722__ 1__ 1 97__ 1
> > > 
> > > 
> > > The /proc/vmstat diff is like this:
> > > 
> > > $ ./diffshow 5
> > > ----8<----
> > > nr_free_pages:____________________________________94999 -> 95630 (631)
> > > nr_inactive_anon:______________________________47076 -> 47196 (120)
> > > nr_inactive_file:______________________________347048 -> 347080 (32)
> > > nr_active_file:__________________________________270128 -> 270462 (334)
> > > nr_file_pages:____________________________________619886 -> 620314 (428)
> > > nr_dirty:______________________________________________10 -> 109 (99)
> > > nr_kernel_stack:________________________________248 -> 249 (1)
> > > nr_isolated_file:______________________________0 -> 10 (10)
> > > nr_dirtied:__________________________________________1147486 -> 1147659 (173)
> > > nr_written:__________________________________________1189947 -> 1190013 (66)
> > > nr_dirty_threshold:__________________________168770 -> 168974 (204)
> > > nr_dirty_background_threshold:____84385 -> 84487 (102)
> > > pgpgin:__________________________________________________528729753 -> 528750521 (20768)
> > > pgpgout:________________________________________________5013688 -> 5014216 (528)
> > > pswpin:__________________________________________________77715 -> 77827 (112)
> > > pgalloc_dma32:____________________________________95912002 -> 95912631 (629)
> > > pgalloc_normal:__________________________________82241808 -> 82247860 (6052)
> > > pgfree:__________________________________________________178827810 -> 178834939 (7129)
> > > pgactivate:__________________________________________2644761 -> 2645104 (343)
> > > pgfault:________________________________________________63365808 -> 63369261 (3453)
> > > pgmajfault:__________________________________________23571 -> 23591 (20)
> > > pgsteal_kswapd_normal:____________________60067802 -> 60072006 (4204)
> > > pgscan_kswapd_normal:______________________60141548 -> 60145753 (4205)
> > > slabs_scanned:____________________________________28914432 -> 28915456 (1024)
> > > kswapd_low_wmark_hit_quickly:______589343 -> 589376 (33)
> > > kswapd_high_wmark_hit_quickly:____763703 -> 763752 (49)
> > > pageoutrun:__________________________________________2852120 -> 2852305 (185)
> > > compact_blocks_moved:______________________10852682 -> 10852847 (165)
> > > compact_pagemigrate_failed:__________39862700 -> 39865324 (2624)
> > > 
> > > kswapd is stuck on normal zone!
> > > 
> > > Also there is raw vmstat:
> > > nr_free_pages 95343
> > > nr_inactive_anon 47196
> > > nr_active_anon 114110
> > > nr_inactive_file 348142
> > > nr_active_file 272638
> > > nr_unevictable 552
> > > nr_mlock 552
> > > nr_anon_pages 100386
> > > nr_mapped 6158
> > > nr_file_pages 623530
> > > nr_dirty 0
> > > nr_writeback 0
> > > nr_slab_reclaimable 21356
> > > nr_slab_unreclaimable 15570
> > > nr_page_table_pages 2045
> > > nr_kernel_stack 244
> > > nr_unstable 0
> > > nr_bounce 0
> > > nr_vmscan_write 149405
> > > nr_vmscan_immediate_reclaim 13896
> > > nr_writeback_temp 0
> > > nr_isolated_anon 0
> > > nr_isolated_file 4
> > > nr_shmem 48
> > > nr_dirtied 1147666
> > > nr_written 1190129
> > > nr_anon_transparent_hugepages 116
> > > nr_free_cma 0
> > > nr_dirty_threshold 169553
> > > nr_dirty_background_threshold 84776
> > > pgpgin 529292001
> > > pgpgout 5014788
> > > pswpin 77827
> > > pswpout 148890
> > > pgalloc_dma 0
> > > pgalloc_dma32 95940824
> > > pgalloc_normal 82395157
> > > pgalloc_movable 0
> > > pgfree 179010711
> > > pgactivate 2647284
> > > pgdeactivate 2513412
> > > pgfault 63427189
> > > pgmajfault 23606
> > > pgrefill_dma 0
> > > pgrefill_dma32 1915983
> > > pgrefill_normal 430939
> > > pgrefill_movable 0
> > > pgsteal_kswapd_dma 0
> > > pgsteal_kswapd_dma32 39927548
> > > pgsteal_kswapd_normal 60180622
> > > pgsteal_kswapd_movable 0
> > > pgsteal_direct_dma 0
> > > pgsteal_direct_dma32 14062458
> > > pgsteal_direct_normal 1894412
> > > pgsteal_direct_movable 0
> > > pgscan_kswapd_dma 0
> > > pgscan_kswapd_dma32 39946808
> > > pgscan_kswapd_normal 60254407
> > > pgscan_kswapd_movable 0
> > > pgscan_direct_dma 0
> > > pgscan_direct_dma32 14260652
> > > pgscan_direct_normal 1895350
> > > pgscan_direct_movable 0
> > > pgscan_direct_throttle 0
> > > pginodesteal 25301
> > > slabs_scanned 28931968
> > > kswapd_inodesteal 26119
> > > kswapd_low_wmark_hit_quickly 591050
> > > kswapd_high_wmark_hit_quickly 766006
> > > kswapd_skip_congestion_wait 15
> > > pageoutrun 2858733
> > > allocstall 156938
> > > pgrotated 161518
> > > compact_blocks_moved 10860505
> > > compact_pages_moved 411760
> > > compact_pagemigrate_failed 39987369
> > > compact_stall 29399
> > > compact_fail 23718
> > > compact_success 5681
> > > htlb_buddy_alloc_success 0
> > > htlb_buddy_alloc_fail 0
> > > unevictable_pgs_culled 6416
> > > unevictable_pgs_scanned 0
> > > unevictable_pgs_rescued 5337
> > > unevictable_pgs_mlocked 6672
> > > unevictable_pgs_munlocked 6120
> > > unevictable_pgs_cleared 0
> > > unevictable_pgs_stranded 0
> > > thp_fault_alloc 41
> > > thp_fault_fallback 302
> > > thp_collapse_alloc 507
> > > thp_collapse_alloc_failed 3704
> > > thp_split 111
> > > 
> > > Buddyinfo:
> > > $ cat /proc/buddyinfo; sleep 1; cat /proc/buddyinfo 
> > > Node 0, zone__________ DMA__________ 0__________ 0__________ 0__________ 1__________ 2__________ 1__________ 1__________ 0____
> > > ____ 1__________ 1__________ 3 
> > > Node 0, zone______ DMA32__ 29527__ 26916______ 489______ 221________ 40__________ 5__________ 0__________ 0____
> > > ____ 0__________ 0__________ 0 
> > > Node 0, zone____ Normal____ 3158__________ 0__________ 0__________ 2__________ 1__________ 1__________ 1__________ 1____
> > > ____ 0__________ 0__________ 0 
> > > Node 0, zone__________ DMA__________ 0__________ 0__________ 0__________ 1__________ 2__________ 1__________ 1__________ 0____
> > > ____ 1__________ 1__________ 3 
> > > Node 0, zone______ DMA32__ 29527__ 26909______ 489______ 211________ 41__________ 5__________ 0__________ 0____
> > > ____ 0__________ 0__________ 0 
> > > Node 0, zone____ Normal____ 2790________ 29__________ 0__________ 8__________ 1__________ 1__________ 1__________ 1____
> > > ____ 0__________ 0__________ 0 
> > > 
> > > Zoneinfo:
> > > $ cat /proc/zoneinfo 
> > > Node 0, zone__________ DMA
> > > __ pages free________ 3976
> > > ______________ min__________ 64
> > > ______________ low__________ 80
> > > ______________ high________ 96
> > > ______________ scanned__ 0
> > > ______________ spanned__ 4080
> > > ______________ present__ 3912
> > > ______ nr_free_pages 3976
> > > ______ nr_inactive_anon 0
> > > ______ nr_active_anon 0
> > > ______ nr_inactive_file 0
> > > ______ nr_active_file 0
> > > ______ nr_unevictable 0
> > > ______ nr_mlock________ 0
> > > ______ nr_anon_pages 0
> > > ______ nr_mapped______ 0
> > > ______ nr_file_pages 0
> > > ______ nr_dirty________ 0
> > > ______ nr_writeback 0
> > > ______ nr_slab_reclaimable 0
> > > ______ nr_slab_unreclaimable 0
> > > ______ nr_page_table_pages 0
> > > ______ nr_kernel_stack 0
> > > ______ nr_unstable__ 0
> > > ______ nr_bounce______ 0
> > > ______ nr_vmscan_write 0
> > > ______ nr_vmscan_immediate_reclaim 0
> > > ______ nr_writeback_temp 0
> > > ______ nr_isolated_anon 0
> > > ______ nr_isolated_file 0
> > > ______ nr_shmem________ 0
> > > ______ nr_dirtied____ 0
> > > ______ nr_written____ 0
> > > ______ nr_anon_transparent_hugepages 0
> > > ______ nr_free_cma__ 0
> > > ______________ protection: (0, 3503, 4007, 4007)
> > > __ pagesets
> > > ______ cpu: 0
> > > __________________________ count: 0
> > > __________________________ high:__ 0
> > > __________________________ batch: 1
> > > __ vm stats threshold: 8
> > > ______ cpu: 1
> > > __________________________ count: 0
> > > __________________________ high:__ 0
> > > __________________________ batch: 1
> > > __ vm stats threshold: 8
> > > __ all_unreclaimable: 1
> > > __ start_pfn:________________ 16
> > > __ inactive_ratio:______ 1
> > > Node 0, zone______ DMA32
> > > __ pages free________ 87395
> > > ______________ min__________ 14715
> > > ______________ low__________ 18393
> > > ______________ high________ 22072
> > > ______________ scanned__ 0
> > > ______________ spanned__ 1044480
> > > ______________ present__ 896960
> > > ______ nr_free_pages 87395
> > > ______ nr_inactive_anon 18907
> > > ______ nr_active_anon 92242
> > > ______ nr_inactive_file 325044
> > > ______ nr_active_file 267577
> > > ______ nr_unevictable 0
> > > ______ nr_mlock________ 0
> > > ______ nr_anon_pages 51703
> > > ______ nr_mapped______ 4369
> > > ______ nr_file_pages 593009
> > > ______ nr_dirty________ 17
> > > ______ nr_writeback 0
> > > ______ nr_slab_reclaimable 14988
> > > ______ nr_slab_unreclaimable 11515
> > > ______ nr_page_table_pages 1305
> > > ______ nr_kernel_stack 133
> > > ______ nr_unstable__ 0
> > > ______ nr_bounce______ 0
> > > ______ nr_vmscan_write 140220
> > > ______ nr_vmscan_immediate_reclaim 62
> > > ______ nr_writeback_temp 0
> > > ______ nr_isolated_anon 0
> > > ______ nr_isolated_file 0
> > > ______ nr_shmem________ 10
> > > ______ nr_dirtied____ 810741
> > > ______ nr_written____ 862763
> > > ______ nr_anon_transparent_hugepages 116
> > > ______ nr_free_cma__ 0
> > > ______________ protection: (0, 0, 504, 504)
> > > __ pagesets
> > > ______ cpu: 0
> > > __________________________ count: 123
> > > __________________________ high:__ 186
> > > __________________________ batch: 31
> > > __ vm stats threshold: 24
> > > ______ cpu: 1
> > > __________________________ count: 29
> > > __________________________ high:__ 186
> > > __________________________ batch: 31
> > > __ vm stats threshold: 24
> > > __ all_unreclaimable: 0
> > > __ start_pfn:________________ 4096
> > > __ inactive_ratio:______ 5
> > > Node 0, zone____ Normal
> > > __ pages free________ 3200
> > > ______________ min__________ 2116
> > > ______________ low__________ 2645
> > > ______________ high________ 3174
> > > ______________ scanned__ 0
> > > ______________ spanned__ 131072
> > > ______________ present__ 129024
> > > ______ nr_free_pages 3200
> > > ______ nr_inactive_anon 25943
> > > ______ nr_active_anon 24590
> > > ______ nr_inactive_file 23132
> > > ______ nr_active_file 10275
> > > ______ nr_unevictable 552
> > > ______ nr_mlock________ 552
> > > ______ nr_anon_pages 49050
> > > ______ nr_mapped______ 2088
> > > ______ nr_file_pages 35785
> > > ______ nr_dirty________ 3
> > > ______ nr_writeback 0
> > > ______ nr_slab_reclaimable 2340
> > > ______ nr_slab_unreclaimable 3926
> > > ______ nr_page_table_pages 786
> > > ______ nr_kernel_stack 114
> > > ______ nr_unstable__ 0
> > > ______ nr_bounce______ 0
> > > ______ nr_vmscan_write 9297
> > > ______ nr_vmscan_immediate_reclaim 13835
> > > ______ nr_writeback_temp 0
> > > ______ nr_isolated_anon 0
> > > ______ nr_isolated_file 10
> > > ______ nr_shmem________ 38
> > > ______ nr_dirtied____ 338110
> > > ______ nr_written____ 328638
> > > ______ nr_anon_transparent_hugepages 0
> > > ______ nr_free_cma__ 0
> > > ______________ protection: (0, 0, 0, 0)
> > > __ pagesets
> > > ______ cpu: 0
> > > __________________________ count: 152
> > > __________________________ high:__ 186
> > > __________________________ batch: 31
> > > __ vm stats threshold: 12
> > > ______ cpu: 1
> > > __________________________ count: 172
> > > __________________________ high:__ 186
> > > __________________________ batch: 31
> > > __ vm stats threshold: 12
> > > __ all_unreclaimable: 0
> > > __ start_pfn:________________ 1048576
> > > __ inactive_ratio:______ 1
> > > 
> > > I have tried disabling compaction (1000
> > > > /proc/sys/vm/extdefrag_threshold), and symptoms do change. There is no
> > > kswapd stuck in D, but instead page cache is almost cleaned from time to
> > > time 
> > > 
> > > Also I have a piece of code, which can reproduce the first problem with
> > > kswapd in D state on another amd64 system, which has normal zone
> > > artificially limited to the same ratio against dma32 zone. It needs a
> > > large file, which is at least twice as large as system RAM (the larger
> > > the better):
> > > dd if=/dev/zero of=tf bs=1M count=$((1024*8))
> > > 
> > > Then start smth like this:
> > > ./a.out tf 32
> > > and let it run for some time to fill the page cache.
> > > 
> > > The code will random read the file in fixed chunks at fixed rate in two
> > > "streams": one stream of 1/3 rate will be scattered across the whole
> > > file and mark pages with WILLNEED. Another stream at 2/3 rate is
> > > contained in 1/10 of a file and will not pass any hints.
> > > 
> > > 3) Now I am running 3.7.4, and atm I see the second problem again, i.e. kswapd
> > > is stuck on zone normal.
> > > 
> > > -- 
> > > Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
> > > ------- You are receiving this mail because: -------
> > > You are the assignee for the bug.
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
