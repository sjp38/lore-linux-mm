Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f51.google.com (mail-la0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4E5FB6B0038
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 09:40:32 -0500 (EST)
Received: by lamq1 with SMTP id q1so6465659lam.5
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 06:40:31 -0800 (PST)
Received: from forward-corp1g.mail.yandex.net (forward-corp1g.mail.yandex.net. [95.108.253.251])
        by mx.google.com with ESMTPS id bl1si10742238lbc.11.2015.02.20.06.40.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Feb 2015 06:40:30 -0800 (PST)
Message-ID: <54E7475C.8070203@yandex-team.ru>
Date: Fri, 20 Feb 2015 17:40:28 +0300
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: hide per-cpu lists in output of show_mem()
References: <20150220143942.19568.4548.stgit@buzz>
In-Reply-To: <20150220143942.19568.4548.stgit@buzz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org

On 20.02.2015 17:39, Konstantin Khlebnikov wrote:
> This makes show_mem() much less verbose at huge machines. Instead of
> huge and almost useless dump of counters for each per-zone per-cpu
> lists this patch prints sum of these counters for each zone (free_pcp)
> and size of per-cpu list for current cpu (local_pcp).


Before:

[   14.569103] sysrq: SysRq : Show Memory
[   14.569599] Mem-Info:
[   14.569870] Node 0 DMA per-cpu:
[   14.570375] CPU    0: hi:    0, btch:   1 usd:   0
[   14.570913] CPU    1: hi:    0, btch:   1 usd:   0
[   14.571449] CPU    2: hi:    0, btch:   1 usd:   0
[   14.571978] CPU    3: hi:    0, btch:   1 usd:   0
[   14.572507] CPU    4: hi:    0, btch:   1 usd:   0
[   14.573090] CPU    5: hi:    0, btch:   1 usd:   0
[   14.573914] CPU    6: hi:    0, btch:   1 usd:   0
[   14.574869] CPU    7: hi:    0, btch:   1 usd:   0
[   14.575413] CPU    8: hi:    0, btch:   1 usd:   0
[   14.576233] CPU    9: hi:    0, btch:   1 usd:   0
[   14.577054] CPU   10: hi:    0, btch:   1 usd:   0
[   14.577869] CPU   11: hi:    0, btch:   1 usd:   0
[   14.578690] CPU   12: hi:    0, btch:   1 usd:   0
[   14.579510] CPU   13: hi:    0, btch:   1 usd:   0
[   14.580346] CPU   14: hi:    0, btch:   1 usd:   0
[   14.581165] CPU   15: hi:    0, btch:   1 usd:   0
[   14.582044] CPU   16: hi:    0, btch:   1 usd:   0
[   14.582903] CPU   17: hi:    0, btch:   1 usd:   0
[   14.583727] CPU   18: hi:    0, btch:   1 usd:   0
[   14.584544] CPU   19: hi:    0, btch:   1 usd:   0
[   14.585362] CPU   20: hi:    0, btch:   1 usd:   0
[   14.586178] CPU   21: hi:    0, btch:   1 usd:   0
[   14.587103] CPU   22: hi:    0, btch:   1 usd:   0
[   14.588099] CPU   23: hi:    0, btch:   1 usd:   0
[   14.588914] CPU   24: hi:    0, btch:   1 usd:   0
[   14.589735] CPU   25: hi:    0, btch:   1 usd:   0
[   14.590553] CPU   26: hi:    0, btch:   1 usd:   0
[   14.591401] CPU   27: hi:    0, btch:   1 usd:   0
[   14.592215] CPU   28: hi:    0, btch:   1 usd:   0
[   14.604465] CPU   29: hi:    0, btch:   1 usd:   0
[   14.605291] CPU   30: hi:    0, btch:   1 usd:   0
[   14.606113] CPU   31: hi:    0, btch:   1 usd:   0
[   14.606931] Node 0 DMA32 per-cpu:
[   14.607718] CPU    0: hi:  186, btch:  31 usd:  84
[   14.608945] CPU    1: hi:  186, btch:  31 usd: 119
[   14.610359] CPU    2: hi:  186, btch:  31 usd: 158
[   14.611785] CPU    3: hi:  186, btch:  31 usd:  35
[   14.612615] CPU    4: hi:  186, btch:  31 usd: 121
[   14.613463] CPU    5: hi:  186, btch:  31 usd: 155
[   14.614291] CPU    6: hi:  186, btch:  31 usd: 130
[   14.615128] CPU    7: hi:  186, btch:  31 usd:  77
[   14.615944] CPU    8: hi:  186, btch:  31 usd: 159
[   14.616921] CPU    9: hi:  186, btch:  31 usd: 119
[   14.617756] CPU   10: hi:  186, btch:  31 usd: 100
[   14.618649] CPU   11: hi:  186, btch:  31 usd:  37
[   14.619483] CPU   12: hi:  186, btch:  31 usd:  66
[   14.620309] CPU   13: hi:  186, btch:  31 usd:  69
[   14.621345] CPU   14: hi:  186, btch:  31 usd: 182
[   14.622295] CPU   15: hi:  186, btch:  31 usd: 127
[   14.623196] CPU   16: hi:  186, btch:  31 usd: 106
[   14.624029] CPU   17: hi:  186, btch:  31 usd:  90
[   14.624848] CPU   18: hi:  186, btch:  31 usd: 161
[   14.625677] CPU   19: hi:  186, btch:  31 usd:  71
[   14.626503] CPU   20: hi:  186, btch:  31 usd:  86
[   14.627328] CPU   21: hi:  186, btch:  31 usd: 159
[   14.628176] CPU   22: hi:  186, btch:  31 usd:  74
[   14.633389] CPU   23: hi:  186, btch:  31 usd: 111
[   14.635477] CPU   24: hi:  186, btch:  31 usd: 156
[   14.636926] CPU   25: hi:  186, btch:  31 usd: 144
[   14.638054] CPU   26: hi:  186, btch:  31 usd:  87
[   14.638903] CPU   27: hi:  186, btch:  31 usd:  50
[   14.639826] CPU   28: hi:  186, btch:  31 usd:  82
[   14.640694] CPU   29: hi:  186, btch:  31 usd: 166
[   14.641607] CPU   30: hi:  186, btch:  31 usd:  85
[   14.642862] CPU   31: hi:  186, btch:  31 usd:   0
[   14.644891] Node 1 DMA32 per-cpu:
[   14.646254] CPU    0: hi:  186, btch:  31 usd: 126
[   14.647110] CPU    1: hi:  186, btch:  31 usd: 107
[   14.647942] CPU    2: hi:  186, btch:  31 usd: 125
[   14.648788] CPU    3: hi:  186, btch:  31 usd:  42
[   14.649696] CPU    4: hi:  186, btch:  31 usd:   0
[   14.650522] CPU    5: hi:  186, btch:  31 usd:  90
[   14.651351] CPU    6: hi:  186, btch:  31 usd: 132
[   14.652173] CPU    7: hi:  186, btch:  31 usd: 103
[   14.653000] CPU    8: hi:  186, btch:  31 usd: 106
[   14.654050] CPU    9: hi:  186, btch:  31 usd: 133
[   14.655265] CPU   10: hi:  186, btch:  31 usd:  86
[   14.656131] CPU   11: hi:  186, btch:  31 usd: 100
[   14.657017] CPU   12: hi:  186, btch:  31 usd: 131
[   14.657841] CPU   13: hi:  186, btch:  31 usd: 106
[   14.659426] CPU   14: hi:  186, btch:  31 usd: 158
[   14.660518] CPU   15: hi:  186, btch:  31 usd: 172
[   14.662480] CPU   16: hi:  186, btch:  31 usd:  70
[   14.663907] CPU   17: hi:  186, btch:  31 usd: 125
[   14.665075] CPU   18: hi:  186, btch:  31 usd:  99
[   14.666047] CPU   19: hi:  186, btch:  31 usd: 163
[   14.667067] CPU   20: hi:  186, btch:  31 usd:  69
[   14.668054] CPU   21: hi:  186, btch:  31 usd:  96
[   14.668959] CPU   22: hi:  186, btch:  31 usd:  57
[   14.669810] CPU   23: hi:  186, btch:  31 usd:  93
[   14.670675] CPU   24: hi:  186, btch:  31 usd:   0
[   14.671563] CPU   25: hi:  186, btch:  31 usd:  78
[   14.672405] CPU   26: hi:  186, btch:  31 usd:  19
[   14.673262] CPU   27: hi:  186, btch:  31 usd: 112
[   14.674107] CPU   28: hi:  186, btch:  31 usd:  26
[   14.675232] CPU   29: hi:  186, btch:  31 usd: 172
[   14.676856] CPU   30: hi:  186, btch:  31 usd: 143
[   14.678591] CPU   31: hi:  186, btch:  31 usd:  52
[   14.679443] Node 2 DMA32 per-cpu:
[   14.680194] CPU    0: hi:  186, btch:  31 usd:  33
[   14.681016] CPU    1: hi:  186, btch:  31 usd:   9
[   14.681826] CPU    2: hi:  186, btch:  31 usd:  94
[   14.682651] CPU    3: hi:  186, btch:  31 usd: 103
[   14.683526] CPU    4: hi:  186, btch:  31 usd: 119
[   14.684350] CPU    5: hi:  186, btch:  31 usd: 178
[   14.685392] CPU    6: hi:  186, btch:  31 usd: 113
[   14.686369] CPU    7: hi:  186, btch:  31 usd:  73
[   14.687497] CPU    8: hi:  186, btch:  31 usd: 111
[   14.688450] CPU    9: hi:  186, btch:  31 usd:  71
[   14.690070] CPU   10: hi:  186, btch:  31 usd: 138
[   14.693257] CPU   11: hi:  186, btch:  31 usd:  54
[   14.694500] CPU   12: hi:  186, btch:  31 usd: 127
[   14.695718] CPU   13: hi:  186, btch:  31 usd:  19
[   14.696564] CPU   14: hi:  186, btch:  31 usd:  74
[   14.697522] CPU   15: hi:  186, btch:  31 usd: 175
[   14.698350] CPU   16: hi:  186, btch:  31 usd: 174
[   14.699191] CPU   17: hi:  186, btch:  31 usd: 183
[   14.700033] CPU   18: hi:  186, btch:  31 usd: 112
[   14.700846] CPU   19: hi:  186, btch:  31 usd: 167
[   14.701674] CPU   20: hi:  186, btch:  31 usd: 104
[   14.702502] CPU   21: hi:  186, btch:  31 usd: 173
[   14.703345] CPU   22: hi:  186, btch:  31 usd: 142
[   14.704179] CPU   23: hi:  186, btch:  31 usd: 102
[   14.704993] CPU   24: hi:  186, btch:  31 usd:  68
[   14.705828] CPU   25: hi:  186, btch:  31 usd:  43
[   14.706703] CPU   26: hi:  186, btch:  31 usd:  37
[   14.707559] CPU   27: hi:  186, btch:  31 usd:  85
[   14.708720] CPU   28: hi:  186, btch:  31 usd: 109
[   14.710113] CPU   29: hi:  186, btch:  31 usd: 166
[   14.711511] CPU   30: hi:  186, btch:  31 usd: 126
[   14.712356] CPU   31: hi:  186, btch:  31 usd:   0
[   14.713184] Node 3 DMA32 per-cpu:
[   14.713936] CPU    0: hi:  186, btch:  31 usd:  13
[   14.714769] CPU    1: hi:  186, btch:  31 usd: 119
[   14.715628] CPU    2: hi:  186, btch:  31 usd:   7
[   14.716636] CPU    3: hi:  186, btch:  31 usd: 119
[   14.717458] CPU    4: hi:  186, btch:  31 usd:  86
[   14.718311] CPU    5: hi:  186, btch:  31 usd: 176
[   14.719445] CPU    6: hi:  186, btch:  31 usd: 149
[   14.720859] CPU    7: hi:  186, btch:  31 usd: 144
[   14.724217] CPU    8: hi:  186, btch:  31 usd: 130
[   14.726105] CPU    9: hi:  186, btch:  31 usd:  68
[   14.727386] CPU   10: hi:  186, btch:  31 usd:  73
[   14.729419] CPU   11: hi:  186, btch:  31 usd: 120
[   14.730988] CPU   12: hi:  186, btch:  31 usd:  88
[   14.731891] CPU   13: hi:  186, btch:  31 usd:  41
[   14.732736] CPU   14: hi:  186, btch:  31 usd: 183
[   14.733562] CPU   15: hi:  186, btch:  31 usd:  63
[   14.734388] CPU   16: hi:  186, btch:  31 usd: 181
[   14.735216] CPU   17: hi:  186, btch:  31 usd: 170
[   14.736182] CPU   18: hi:  186, btch:  31 usd:  35
[   14.737543] CPU   19: hi:  186, btch:  31 usd:  48
[   14.739037] CPU   20: hi:  186, btch:  31 usd:  85
[   14.740433] CPU   21: hi:  186, btch:  31 usd: 172
[   14.741478] CPU   22: hi:  186, btch:  31 usd:  31
[   14.742444] CPU   23: hi:  186, btch:  31 usd:  76
[   14.743292] CPU   24: hi:  186, btch:  31 usd:   0
[   14.744147] CPU   25: hi:  186, btch:  31 usd:  80
[   14.745051] CPU   26: hi:  186, btch:  31 usd:  47
[   14.745863] CPU   27: hi:  186, btch:  31 usd:  54
[   14.746688] CPU   28: hi:  186, btch:  31 usd:  99
[   14.747647] CPU   29: hi:  186, btch:  31 usd: 176
[   14.748558] CPU   30: hi:  186, btch:  31 usd:   0
[   14.749754] CPU   31: hi:  186, btch:  31 usd: 152
[   14.750863] active_anon:2243 inactive_anon:35 isolated_anon:0
[   14.750863]  active_file:4482 inactive_file:4606 isolated_file:0
[   14.750863]  unevictable:0 dirty:139 writeback:0 unstable:0
[   14.750863]  free:455653 slab_reclaimable:3463 slab_unreclaimable:7535
[   14.750863]  mapped:2080 shmem:44 pagetables:285 bounce:0
[   14.750863]  free_cma:0
[   14.759589] Node 0 DMA free:14568kB min:44kB low:52kB high:64kB 
active_anon:124kB inactive_anon:0kB active_file:436kB 
inactive_file:264kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:15992kB managed:15908kB mlocked:0kB dirty:4kB 
writeback:0kB mapped:208kB shmem:0kB slab_reclaimable:152kB 
slab_unreclaimable:328kB kernel_stack:16kB pagetables:8kB unstable:0kB 
bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 
all_unreclaimable? no
[   14.766300] lowmem_reserve[]: 0 470 470 470
[   14.767506] Node 0 DMA32 free:442488kB min:1368kB low:1708kB 
high:2052kB active_anon:2400kB inactive_anon:12kB active_file:7224kB 
inactive_file:3812kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:507904kB managed:485120kB mlocked:0kB 
dirty:152kB writeback:0kB mapped:4584kB shmem:12kB 
slab_reclaimable:3924kB slab_unreclaimable:7668kB kernel_stack:1600kB 
pagetables:228kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB 
pages_scanned:0 all_unreclaimable? no
[   14.774390] lowmem_reserve[]: 0 0 0 0
[   14.775481] Node 1 DMA32 free:416704kB min:1276kB low:1592kB 
high:1912kB active_anon:916kB inactive_anon:68kB active_file:3224kB 
inactive_file:2088kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:524288kB managed:449572kB mlocked:0kB 
dirty:244kB writeback:0kB mapped:1572kB shmem:76kB 
slab_reclaimable:1920kB slab_unreclaimable:6360kB kernel_stack:1024kB 
pagetables:284kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB 
pages_scanned:0 all_unreclaimable? no
[   14.784695] lowmem_reserve[]: 0 0 0 0
[   14.786414] Node 2 DMA32 free:464496kB min:1464kB low:1828kB 
high:2196kB active_anon:3712kB inactive_anon:32kB active_file:5172kB 
inactive_file:10548kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:524288kB managed:515108kB mlocked:0kB 
dirty:152kB writeback:0kB mapped:1000kB shmem:44kB 
slab_reclaimable:6064kB slab_unreclaimable:8672kB kernel_stack:816kB 
pagetables:188kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB 
pages_scanned:0 all_unreclaimable? no
[   14.794710] lowmem_reserve[]: 0 0 0 0
[   14.796172] Node 3 DMA32 free:484356kB min:1464kB low:1828kB 
high:2196kB active_anon:1820kB inactive_anon:28kB active_file:1872kB 
inactive_file:1712kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:524156kB managed:514928kB mlocked:0kB 
dirty:4kB writeback:0kB mapped:956kB shmem:44kB slab_reclaimable:1792kB 
slab_unreclaimable:7112kB kernel_stack:912kB pagetables:432kB 
unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 
all_unreclaimable? no
[   14.802398] lowmem_reserve[]: 0 0 0 0
[   14.803438] Node 0 DMA: 22*4kB (UM) 14*8kB (UEM) 8*16kB (UM) 3*32kB 
(UEM) 1*64kB (E) 2*128kB (UM) 2*256kB (UE) 2*512kB (UE) 2*1024kB (EM) 
3*2048kB (EMR) 1*4096kB (M) = 14568kB
[   14.819021] Node 0 DMA32: 345*4kB (UEM) 302*8kB (UM) 211*16kB (UEM) 
83*32kB (UM) 34*64kB (UM) 8*128kB (UEM) 2*256kB (UE) 1*512kB (U) 
1*1024kB (E) 3*2048kB (UER) 103*4096kB (M) = 443108kB
[   14.823019] Node 1 DMA32: 366*4kB (UEM) 244*8kB (UEM) 135*16kB (UEM) 
59*32kB (UEM) 22*64kB (UEM) 12*128kB (UM) 6*256kB (UEM) 0*512kB 2*1024kB 
(UE) 1*2048kB (U) 98*4096kB (MR) = 417448kB
[   14.828587] Node 2 DMA32: 350*4kB (UM) 143*8kB (UEM) 79*16kB (UEM) 
56*32kB (UEM) 72*64kB (UEM) 7*128kB (EM) 5*256kB (EM) 0*512kB 2*1024kB 
(UE) 2*2048kB (UM) 109*4096kB (MR) = 464992kB
[   14.832611] Node 3 DMA32: 473*4kB (UEM) 249*8kB (UEM) 110*16kB (UEM) 
43*32kB (UM) 12*64kB (UEM) 5*128kB (UEM) 4*256kB (UEM) 1*512kB (M) 
2*1024kB (EM) 1*2048kB (M) 115*4096kB (MR) = 485100kB
[   14.836563] Node 0 hugepages_total=0 hugepages_free=0 
hugepages_surp=0 hugepages_size=2048kB
[   14.838380] Node 1 hugepages_total=0 hugepages_free=0 
hugepages_surp=0 hugepages_size=2048kB
[   14.840264] Node 2 hugepages_total=0 hugepages_free=0 
hugepages_surp=0 hugepages_size=2048kB
[   14.845649] Node 3 hugepages_total=0 hugepages_free=0 
hugepages_surp=0 hugepages_size=2048kB
[   14.849683] 9131 total pagecache pages
[   14.850427] 0 pages in swap cache
[   14.851238] Swap cache stats: add 0, delete 0, find 0/0
[   14.852112] Free swap  = 999420kB
[   14.852791] Total swap = 999420kB
[   14.853479] 524157 pages RAM
[   14.854122] 0 pages HighMem/MovableOnly
[   14.854842] 28998 pages reserved




After:


[   44.452524] sysrq: SysRq : Show Memory
[   44.452955] Mem-Info:
[   44.453233] active_anon:2307 inactive_anon:36 isolated_anon:0
[   44.453233]  active_file:4120 inactive_file:4623 isolated_file:0
[   44.453233]  unevictable:0 dirty:6 writeback:0 unstable:0
[   44.453233]  slab_reclaimable:3500 slab_unreclaimable:7441
[   44.453233]  mapped:2113 shmem:45 pagetables:292 bounce:0
[   44.453233]  free:456891 free_pcp:12179 free_cma:0
[   44.456275] Node 0 DMA free:14756kB min:44kB low:52kB high:64kB 
active_anon:184kB inactive_anon:4kB active_file:256kB inactive_file:72kB 
unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15992kB 
managed:15908kB mlocked:0kB dirty:0kB writeback:0kB mapped:64kB 
shmem:4kB slab_reclaimable:100kB slab_unreclaimable:452kB 
kernel_stack:16kB pagetables:44kB unstable:0kB bounce:0kB free_pcp:0kB 
local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 
all_unreclaimable? no
[   44.460873] lowmem_reserve[]: 0 470 470 470
[   44.461576] Node 0 DMA32 free:451052kB min:1368kB low:1708kB 
high:2052kB active_anon:2100kB inactive_anon:28kB active_file:4640kB 
inactive_file:1292kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:507904kB managed:485120kB mlocked:0kB 
dirty:12kB writeback:0kB mapped:2584kB shmem:40kB 
slab_reclaimable:2440kB slab_unreclaimable:8080kB kernel_stack:1712kB 
pagetables:296kB unstable:0kB bounce:0kB free_pcp:11164kB 
local_pcp:280kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 
all_unreclaimable? no
[   44.468488] lowmem_reserve[]: 0 0 0 0
[   44.469319] Node 1 DMA32 free:414628kB min:1276kB low:1592kB 
high:1912kB active_anon:1664kB inactive_anon:12kB active_file:4172kB 
inactive_file:2104kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:524288kB managed:449572kB mlocked:0kB 
dirty:4kB writeback:0kB mapped:1136kB shmem:20kB slab_reclaimable:3024kB 
slab_unreclaimable:6836kB kernel_stack:1184kB pagetables:372kB 
unstable:0kB bounce:0kB free_pcp:11512kB local_pcp:0kB free_cma:0kB 
writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[   44.479676] lowmem_reserve[]: 0 0 0 0
[   44.482369] Node 2 DMA32 free:473636kB min:1464kB low:1828kB 
high:2196kB active_anon:4556kB inactive_anon:68kB active_file:3740kB 
inactive_file:4632kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:524288kB managed:515108kB mlocked:0kB 
dirty:0kB writeback:0kB mapped:2972kB shmem:80kB slab_reclaimable:4832kB 
slab_unreclaimable:7432kB kernel_stack:736kB pagetables:320kB 
unstable:0kB bounce:0kB free_pcp:12928kB local_pcp:0kB free_cma:0kB 
writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[   44.495909] lowmem_reserve[]: 0 0 0 0
[   44.499130] Node 3 DMA32 free:473492kB min:1464kB low:1828kB 
high:2196kB active_anon:724kB inactive_anon:32kB active_file:3672kB 
inactive_file:10392kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:524156kB managed:514928kB mlocked:0kB 
dirty:8kB writeback:0kB mapped:1696kB shmem:36kB slab_reclaimable:3604kB 
slab_unreclaimable:6964kB kernel_stack:720kB pagetables:136kB 
unstable:0kB bounce:0kB free_pcp:13112kB local_pcp:0kB free_cma:0kB 
writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[   44.511069] lowmem_reserve[]: 0 0 0 0
[   44.513516] Node 0 DMA: 3*4kB (UE) 5*8kB (UEM) 7*16kB (UEM) 2*32kB 
(UM) 1*64kB (M) 3*128kB (UEM) 3*256kB (UEM) 2*512kB (UE) 2*1024kB (EM) 
3*2048kB (EMR) 1*4096kB (M) = 14756kB
[   44.519682] Node 0 DMA32: 279*4kB (UEM) 156*8kB (UM) 91*16kB (UEM) 
46*32kB (UEM) 21*64kB (UEM) 4*128kB (UEM) 4*256kB (EM) 3*512kB (UEM) 
1*1024kB (M) 3*2048kB (UMR) 106*4096kB (M) = 451052kB
[   44.527741] Node 1 DMA32: 373*4kB (UM) 342*8kB (UM) 212*16kB (UEM) 
107*32kB (UM) 24*64kB (UM) 7*128kB (UEM) 5*256kB (UM) 3*512kB (UEM) 
1*1024kB (U) 0*2048kB 97*4096kB (MR) = 414628kB
[   44.532389] Node 2 DMA32: 261*4kB (UEM) 84*8kB (UM) 71*16kB (UM) 
30*32kB (UM) 19*64kB (UEM) 9*128kB (UM) 6*256kB (UEM) 2*512kB (EM) 
2*1024kB (UM) 2*2048kB (UE) 112*4096kB (MR) = 473636kB
[   44.537268] Node 3 DMA32: 319*4kB (UEM) 243*8kB (UEM) 180*16kB (UM) 
96*32kB (UEM) 81*64kB (UEM) 9*128kB (EM) 5*256kB (M) 4*512kB (UEM) 
2*1024kB (EM) 1*2048kB (E) 110*4096kB (MR) = 473492kB
[   44.542344] Node 0 hugepages_total=0 hugepages_free=0 
hugepages_surp=0 hugepages_size=2048kB
[   44.545064] Node 1 hugepages_total=0 hugepages_free=0 
hugepages_surp=0 hugepages_size=2048kB
[   44.547613] Node 2 hugepages_total=0 hugepages_free=0 
hugepages_surp=0 hugepages_size=2048kB
[   44.552028] Node 3 hugepages_total=0 hugepages_free=0 
hugepages_surp=0 hugepages_size=2048kB
[   44.559441] 8793 total pagecache pages
[   44.561298] 0 pages in swap cache
[   44.562973] Swap cache stats: add 0, delete 0, find 0/0
[   44.564722] Free swap  = 999420kB
[   44.566151] Total swap = 999420kB
[   44.567440] 524157 pages RAM
[   44.569286] 0 pages HighMem/MovableOnly
[   44.570702] 28998 pages reserved


>
> Flag SHOW_MEM_PERCPU_LISTS reverts old verbose mode.
>
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> ---
>   include/linux/mm.h |    1 +
>   mm/page_alloc.c    |   32 +++++++++++++++++++++++++-------
>   2 files changed, 26 insertions(+), 7 deletions(-)
>
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 028565a..0538de0 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1126,6 +1126,7 @@ extern void pagefault_out_of_memory(void);
>    * various contexts.
>    */
>   #define SHOW_MEM_FILTER_NODES		(0x0001u)	/* disallowed nodes */
> +#define SHOW_MEM_PERCPU_LISTS		(0x0002u)	/* per-zone per-cpu */
>
>   extern void show_free_areas(unsigned int flags);
>   extern bool skip_free_areas_node(unsigned int flags, int nid);
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index a47f0b2..e591f3b 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3198,20 +3198,29 @@ static void show_migration_types(unsigned char type)
>    */
>   void show_free_areas(unsigned int filter)
>   {
> +	unsigned long free_pcp = 0;
>   	int cpu;
>   	struct zone *zone;
>
>   	for_each_populated_zone(zone) {
>   		if (skip_free_areas_node(filter, zone_to_nid(zone)))
>   			continue;
> -		show_node(zone);
> -		printk("%s per-cpu:\n", zone->name);
> +
> +		if (filter & SHOW_MEM_PERCPU_LISTS) {
> +			show_node(zone);
> +			printk("%s per-cpu:\n", zone->name);
> +		}
>
>   		for_each_online_cpu(cpu) {
>   			struct per_cpu_pageset *pageset;
>
>   			pageset = per_cpu_ptr(zone->pageset, cpu);
>
> +			free_pcp += pageset->pcp.count;
> +
> +			if (!(filter & SHOW_MEM_PERCPU_LISTS))
> +				continue;
> +
>   			printk("CPU %4d: hi:%5d, btch:%4d usd:%4d\n",
>   			       cpu, pageset->pcp.high,
>   			       pageset->pcp.batch, pageset->pcp.count);
> @@ -3220,11 +3229,10 @@ void show_free_areas(unsigned int filter)
>
>   	printk("active_anon:%lu inactive_anon:%lu isolated_anon:%lu\n"
>   		" active_file:%lu inactive_file:%lu isolated_file:%lu\n"
> -		" unevictable:%lu"
> -		" dirty:%lu writeback:%lu unstable:%lu\n"
> -		" free:%lu slab_reclaimable:%lu slab_unreclaimable:%lu\n"
> +		" unevictable:%lu dirty:%lu writeback:%lu unstable:%lu\n"
> +		" slab_reclaimable:%lu slab_unreclaimable:%lu\n"
>   		" mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n"
> -		" free_cma:%lu\n",
> +		" free:%lu free_pcp:%lu free_cma:%lu\n",
>   		global_page_state(NR_ACTIVE_ANON),
>   		global_page_state(NR_INACTIVE_ANON),
>   		global_page_state(NR_ISOLATED_ANON),
> @@ -3235,13 +3243,14 @@ void show_free_areas(unsigned int filter)
>   		global_page_state(NR_FILE_DIRTY),
>   		global_page_state(NR_WRITEBACK),
>   		global_page_state(NR_UNSTABLE_NFS),
> -		global_page_state(NR_FREE_PAGES),
>   		global_page_state(NR_SLAB_RECLAIMABLE),
>   		global_page_state(NR_SLAB_UNRECLAIMABLE),
>   		global_page_state(NR_FILE_MAPPED),
>   		global_page_state(NR_SHMEM),
>   		global_page_state(NR_PAGETABLE),
>   		global_page_state(NR_BOUNCE),
> +		global_page_state(NR_FREE_PAGES),
> +		free_pcp,
>   		global_page_state(NR_FREE_CMA_PAGES));
>
>   	for_each_populated_zone(zone) {
> @@ -3249,6 +3258,11 @@ void show_free_areas(unsigned int filter)
>
>   		if (skip_free_areas_node(filter, zone_to_nid(zone)))
>   			continue;
> +
> +		free_pcp = 0;
> +		for_each_online_cpu(cpu)
> +			free_pcp += per_cpu_ptr(zone->pageset, cpu)->pcp.count;
> +
>   		show_node(zone);
>   		printk("%s"
>   			" free:%lukB"
> @@ -3275,6 +3289,8 @@ void show_free_areas(unsigned int filter)
>   			" pagetables:%lukB"
>   			" unstable:%lukB"
>   			" bounce:%lukB"
> +			" free_pcp:%lukB"
> +			" local_pcp:%ukB"
>   			" free_cma:%lukB"
>   			" writeback_tmp:%lukB"
>   			" pages_scanned:%lu"
> @@ -3306,6 +3322,8 @@ void show_free_areas(unsigned int filter)
>   			K(zone_page_state(zone, NR_PAGETABLE)),
>   			K(zone_page_state(zone, NR_UNSTABLE_NFS)),
>   			K(zone_page_state(zone, NR_BOUNCE)),
> +			K(free_pcp),
> +			K(this_cpu_read(zone->pageset->pcp.count)),
>   			K(zone_page_state(zone, NR_FREE_CMA_PAGES)),
>   			K(zone_page_state(zone, NR_WRITEBACK_TEMP)),
>   			K(zone_page_state(zone, NR_PAGES_SCANNED)),
>


-- 
Konstantin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
