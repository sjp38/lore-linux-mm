Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id EE7196B0037
	for <linux-mm@kvack.org>; Sun, 22 Dec 2013 06:10:21 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id jt11so4341582pbb.0
        for <linux-mm@kvack.org>; Sun, 22 Dec 2013 03:10:21 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id eb3si9790140pbc.116.2013.12.22.03.10.18
        for <linux-mm@kvack.org>;
        Sun, 22 Dec 2013 03:10:19 -0800 (PST)
Date: Sun, 22 Dec 2013 19:10:13 +0800
From: fengguang.wu@intel.com
Subject: fff4068cba48: +82.0% vm-scalability.throughput
Message-ID: <20131222111013.GA13077@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>

Johannes,

I'm glad to report that the below commit results in large increase of
performance in our vm-scalability/1T-anon-w-seq testcase.

commit fff4068cba484e6b0abe334ed6b15d5a215a3b25
Author: Johannes Weiner <hannes@cmpxchg.org>
Date:   Fri Dec 20 14:54:12 2013 +0000

    mm: page_alloc: revert NUMA aspect of fair allocation policy
    
    Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
    Reviewed-by: Michal Hocko <mhocko@suse.cz>
    Signed-off-by: Mel Gorman <mgorman@suse.de>
    Cc: <stable@kernel.org> # 3.12
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

The detailed numbers are

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
  27965631 ~ 0%     +82.0%   50892168 ~ 0%  brickland2/micro/vm-scalability/1T-anon-w-seq
  27965631          +82.0%   50892168       TOTAL vm-scalability.throughput

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
  24936524 ~ 0%     -99.8%      58291 ~37%  brickland2/micro/vm-scalability/1T-anon-w-seq
  24936524          -99.8%      58291       TOTAL numa-vmstat.node3.numa_other

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      4186 ~ 9%     -99.8%          9 ~35%  brickland2/micro/vm-scalability/1T-anon-w-seq
      4186          -99.8%          9       TOTAL numa-vmstat.node3.nr_inactive_anon

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
  49623735 ~ 0%    -100.0%          0 ~200%  brickland2/micro/vm-scalability/1T-anon-w-seq
  49623735         -100.0%          0       TOTAL numa-numastat.node3.other_node

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
  25510007 ~ 0%     -99.8%      44126 ~49%  brickland2/micro/vm-scalability/1T-anon-w-seq
  25510007          -99.8%      44126       TOTAL numa-vmstat.node2.numa_other

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      4543 ~ 4%     -98.2%         80 ~43%  brickland2/micro/vm-scalability/1T-anon-w-seq
      4543          -98.2%         80       TOTAL numa-vmstat.node2.nr_shmem

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      4428 ~ 1%     -99.2%         35 ~100%  brickland2/micro/vm-scalability/1T-anon-w-seq
      4428          -99.2%         35       TOTAL numa-vmstat.node2.nr_inactive_anon

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
  50735073 ~ 0%    -100.0%          0 ~133%  brickland2/micro/vm-scalability/1T-anon-w-seq
  50735073         -100.0%          0       TOTAL numa-numastat.node2.other_node

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
  25892047 ~ 0%     -99.7%      69142 ~ 0%  brickland2/micro/vm-scalability/1T-anon-w-seq
  25892047          -99.7%      69142       TOTAL numa-vmstat.node1.numa_other

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      4244 ~ 9%     -99.6%         16 ~25%  brickland2/micro/vm-scalability/1T-anon-w-seq
      4244          -99.6%         16       TOTAL numa-vmstat.node3.nr_shmem

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
  32472773 ~ 0%     -99.9%      35954 ~74%  brickland2/micro/vm-scalability/1T-anon-w-seq
  32472773          -99.9%      35954       TOTAL numa-vmstat.node0.numa_other

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
  51431667 ~ 0%    -100.0%          3 ~35%  brickland2/micro/vm-scalability/1T-anon-w-seq
  51431667         -100.0%          3       TOTAL numa-numastat.node1.other_node

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
     16988 ~ 9%     -99.6%         67 ~26%  brickland2/micro/vm-scalability/1T-anon-w-seq
     16988          -99.6%         67       TOTAL numa-meminfo.node3.Shmem

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
     16756 ~ 9%     -99.8%         38 ~36%  brickland2/micro/vm-scalability/1T-anon-w-seq
     16756          -99.8%         38       TOTAL numa-meminfo.node3.Inactive(anon)

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
     18184 ~ 4%     -98.2%        325 ~43%  brickland2/micro/vm-scalability/1T-anon-w-seq
     18184          -98.2%        325       TOTAL numa-meminfo.node2.Shmem

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
     17723 ~ 1%     -99.2%        142 ~98%  brickland2/micro/vm-scalability/1T-anon-w-seq
     17723          -99.2%        142       TOTAL numa-meminfo.node2.Inactive(anon)

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
       351 ~ 6%     -80.0%         70 ~ 5%  brickland2/micro/vm-scalability/1T-anon-w-seq
       351          -80.0%         70       TOTAL buddyinfo.Node.3.zone.Normal.9

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
  64760830 ~ 0%    -100.0%          0 ~122%  brickland2/micro/vm-scalability/1T-anon-w-seq
  64760830         -100.0%          0       TOTAL numa-numastat.node0.other_node

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
 2.166e+08 ~ 0%    -100.0%          4 ~26%  brickland2/micro/vm-scalability/1T-anon-w-seq
 2.166e+08         -100.0%          4       TOTAL proc-vmstat.numa_other

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
       314 ~13%     -71.8%         88 ~16%  brickland2/micro/vm-scalability/1T-anon-w-seq
       314          -71.8%         88       TOTAL buddyinfo.Node.2.zone.Normal.9

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
       349 ~ 7%     -72.5%         96 ~ 2%  brickland2/micro/vm-scalability/1T-anon-w-seq
       349          -72.5%         96       TOTAL pagetypeinfo.Node3.Normal.Movable.9

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
     22781 ~ 7%     -67.5%       7405 ~ 3%  brickland2/micro/vm-scalability/1T-anon-w-seq
     22781          -67.5%       7405       TOTAL interrupts.IWI

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
       444 ~ 2%     -64.4%        158 ~ 4%  brickland2/micro/vm-scalability/1T-anon-w-seq
       444          -64.4%        158       TOTAL pagetypeinfo.Node0.DMA32.Movable.7

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
       309 ~12%     -63.4%        113 ~12%  brickland2/micro/vm-scalability/1T-anon-w-seq
       309          -63.4%        113       TOTAL pagetypeinfo.Node2.Normal.Movable.9

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      6129 ~ 3%    +165.3%      16263 ~ 4%  brickland2/micro/vm-scalability/1T-anon-w-seq
      6129         +165.3%      16263       TOTAL pagetypeinfo.Node1.Normal.Movable.2

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      5168 ~ 3%    +154.8%      13172 ~ 6%  brickland2/micro/vm-scalability/1T-anon-w-seq
      5168         +154.8%      13172       TOTAL pagetypeinfo.Node1.Normal.Movable.1

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      6502 ~ 2%    +143.0%      15801 ~ 4%  brickland2/micro/vm-scalability/1T-anon-w-seq
      6502         +143.0%      15801       TOTAL pagetypeinfo.Node3.Normal.Movable.2

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      6434 ~ 2%    +145.2%      15776 ~ 2%  brickland2/micro/vm-scalability/1T-anon-w-seq
      6434         +145.2%      15776       TOTAL pagetypeinfo.Node2.Normal.Movable.2

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      5281 ~ 2%    +137.6%      12549 ~ 2%  brickland2/micro/vm-scalability/1T-anon-w-seq
      5281         +137.6%      12549       TOTAL pagetypeinfo.Node2.Normal.Movable.1

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
       452 ~ 2%     -58.5%        188 ~ 1%  brickland2/micro/vm-scalability/1T-anon-w-seq
       452          -58.5%        188       TOTAL buddyinfo.Node.0.zone.DMA32.7

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      5989 ~ 3%    +140.1%      14379 ~ 4%  brickland2/micro/vm-scalability/1T-anon-w-seq
      5989         +140.1%      14379       TOTAL pagetypeinfo.Node1.Normal.Movable.3

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      6370 ~ 1%    +130.4%      14678 ~ 4%  brickland2/micro/vm-scalability/1T-anon-w-seq
      6370         +130.4%      14678       TOTAL buddyinfo.Node.1.zone.Normal.2

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      6079 ~ 2%    +130.3%      14002 ~ 2%  brickland2/micro/vm-scalability/1T-anon-w-seq
      6079         +130.3%      14002       TOTAL pagetypeinfo.Node2.Normal.Movable.3

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
       648 ~ 2%     -56.2%        283 ~ 2%  brickland2/micro/vm-scalability/1T-anon-w-seq
       648          -56.2%        283       TOTAL pagetypeinfo.Node0.DMA32.Movable.6

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      6085 ~ 2%    +123.5%      13602 ~ 4%  brickland2/micro/vm-scalability/1T-anon-w-seq
      6085         +123.5%      13602       TOTAL pagetypeinfo.Node3.Normal.Movable.3

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
       655 ~ 1%     -55.5%        291 ~ 2%  brickland2/micro/vm-scalability/1T-anon-w-seq
       655          -55.5%        291       TOTAL buddyinfo.Node.0.zone.DMA32.6

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
       198 ~ 4%     -55.0%         89 ~14%  brickland2/micro/vm-scalability/1T-anon-w-seq
       198          -55.0%         89       TOTAL pagetypeinfo.Node0.Normal.Movable.9

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      3977 ~ 2%    +123.3%       8883 ~ 2%  brickland2/micro/vm-scalability/1T-anon-w-seq
      3977         +123.3%       8883       TOTAL pagetypeinfo.Node2.Normal.Movable.0

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      4071 ~ 3%    +121.7%       9026 ~ 6%  brickland2/micro/vm-scalability/1T-anon-w-seq
      4071         +121.7%       9026       TOTAL pagetypeinfo.Node1.Normal.Movable.0

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      5381 ~ 2%    +121.9%      11943 ~ 4%  brickland2/micro/vm-scalability/1T-anon-w-seq
      5381         +121.9%      11943       TOTAL buddyinfo.Node.1.zone.Normal.1

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      5350 ~ 2%    +112.8%      11384 ~ 4%  brickland2/micro/vm-scalability/1T-anon-w-seq
      5350         +112.8%      11384       TOTAL pagetypeinfo.Node3.Normal.Movable.1

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      6277 ~ 1%    +123.3%      14017 ~ 5%  brickland2/micro/vm-scalability/1T-anon-w-seq
      6277         +123.3%      14017       TOTAL pagetypeinfo.Node0.Normal.Movable.2

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      6669 ~ 1%    +112.4%      14165 ~ 3%  brickland2/micro/vm-scalability/1T-anon-w-seq
      6669         +112.4%      14165       TOTAL buddyinfo.Node.3.zone.Normal.2

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      6075 ~ 1%    +110.6%      12793 ~ 3%  brickland2/micro/vm-scalability/1T-anon-w-seq
      6075         +110.6%      12793       TOTAL buddyinfo.Node.1.zone.Normal.3

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      5318 ~ 1%    +114.1%      11385 ~ 5%  brickland2/micro/vm-scalability/1T-anon-w-seq
      5318         +114.1%      11385       TOTAL pagetypeinfo.Node0.Normal.Movable.1

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      6647 ~ 1%    +112.7%      14139 ~ 3%  brickland2/micro/vm-scalability/1T-anon-w-seq
      6647         +112.7%      14139       TOTAL buddyinfo.Node.2.zone.Normal.2

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      2012 ~ 2%    +106.1%       4148 ~ 2%  brickland2/micro/vm-scalability/1T-anon-w-seq
      2012         +106.1%       4148       TOTAL pagetypeinfo.Node2.Normal.Movable.5

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
       206 ~ 8%     -49.4%        104 ~13%  brickland2/micro/vm-scalability/1T-anon-w-seq
       206          -49.4%        104       TOTAL buddyinfo.Node.0.zone.Normal.9

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      6111 ~ 1%    +109.2%      12782 ~ 4%  brickland2/micro/vm-scalability/1T-anon-w-seq
      6111         +109.2%      12782       TOTAL pagetypeinfo.Node0.Normal.Movable.3

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      6107 ~ 1%     +98.4%      12117 ~ 2%  brickland2/micro/vm-scalability/1T-anon-w-seq
      6107          +98.4%      12117       TOTAL buddyinfo.Node.3.zone.Normal.3

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      5516 ~ 1%    +102.7%      11178 ~ 1%  brickland2/micro/vm-scalability/1T-anon-w-seq
      5516         +102.7%      11178       TOTAL buddyinfo.Node.2.zone.Normal.1

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      3949 ~ 2%     +97.4%       7796 ~ 5%  brickland2/micro/vm-scalability/1T-anon-w-seq
      3949          +97.4%       7796       TOTAL pagetypeinfo.Node3.Normal.Movable.0

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      6137 ~ 2%    +101.5%      12365 ~ 3%  brickland2/micro/vm-scalability/1T-anon-w-seq
      6137         +101.5%      12365       TOTAL buddyinfo.Node.2.zone.Normal.3

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      4576 ~ 2%     +99.2%       9117 ~ 2%  brickland2/micro/vm-scalability/1T-anon-w-seq
      4576          +99.2%       9117       TOTAL pagetypeinfo.Node2.Normal.Movable.4

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      2612 ~ 6%    +104.0%       5329 ~ 2%  brickland2/micro/vm-scalability/1T-anon-w-seq
      2612         +104.0%       5329       TOTAL proc-vmstat.nr_alloc_batch

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      1961 ~ 2%     +94.2%       3809 ~ 6%  brickland2/micro/vm-scalability/1T-anon-w-seq
      1961          +94.2%       3809       TOTAL pagetypeinfo.Node3.Normal.Movable.5

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      4064 ~ 2%     +91.0%       7764 ~ 1%  brickland2/micro/vm-scalability/1T-anon-w-seq
      4064          +91.0%       7764       TOTAL buddyinfo.Node.2.zone.Normal.0

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      4179 ~ 0%     +93.5%       8085 ~ 4%  brickland2/micro/vm-scalability/1T-anon-w-seq
      4179          +93.5%       8085       TOTAL pagetypeinfo.Node0.Normal.Movable.0

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      4416 ~ 2%     +91.7%       8467 ~ 5%  brickland2/micro/vm-scalability/1T-anon-w-seq
      4416          +91.7%       8467       TOTAL pagetypeinfo.Node3.Normal.Movable.4

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      1036 ~ 2%     +89.3%       1962 ~ 3%  brickland2/micro/vm-scalability/1T-anon-w-seq
      1036          +89.3%       1962       TOTAL pagetypeinfo.Node2.Normal.Movable.6

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      4191 ~ 2%     +93.3%       8101 ~ 4%  brickland2/micro/vm-scalability/1T-anon-w-seq
      4191          +93.3%       8101       TOTAL buddyinfo.Node.1.zone.Normal.0

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      4800 ~ 2%     +89.9%       9117 ~ 6%  brickland2/micro/vm-scalability/1T-anon-w-seq
      4800          +89.9%       9117       TOTAL pagetypeinfo.Node1.Normal.Movable.4

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      5530 ~ 1%     +84.4%      10199 ~ 3%  brickland2/micro/vm-scalability/1T-anon-w-seq
      5530          +84.4%      10199       TOTAL buddyinfo.Node.3.zone.Normal.1

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      2092 ~ 3%     +87.2%       3917 ~ 7%  brickland2/micro/vm-scalability/1T-anon-w-seq
      2092          +87.2%       3917       TOTAL pagetypeinfo.Node1.Normal.Movable.5

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
       846 ~ 6%     +86.7%       1580 ~ 8%  brickland2/micro/vm-scalability/1T-anon-w-seq
       846          +86.7%       1580       TOTAL numa-vmstat.node3.nr_alloc_batch

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      2026 ~ 3%     +71.5%       3475 ~ 2%  brickland2/micro/vm-scalability/1T-anon-w-seq
      2026          +71.5%       3475       TOTAL buddyinfo.Node.2.zone.Normal.5

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
       841 ~ 4%     +73.9%       1463 ~10%  brickland2/micro/vm-scalability/1T-anon-w-seq
       841          +73.9%       1463       TOTAL numa-vmstat.node2.nr_alloc_batch

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      1017 ~ 3%     +68.1%       1710 ~ 6%  brickland2/micro/vm-scalability/1T-anon-w-seq
      1017          +68.1%       1710       TOTAL pagetypeinfo.Node3.Normal.Movable.6

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
       335 ~ 6%     -45.0%        184 ~ 4%  brickland2/micro/vm-scalability/1T-anon-w-seq
       335          -45.0%        184       TOTAL buddyinfo.Node.3.zone.Normal.8

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      6400 ~ 2%     +77.2%      11339 ~ 4%  brickland2/micro/vm-scalability/1T-anon-w-seq
      6400          +77.2%      11339       TOTAL buddyinfo.Node.0.zone.Normal.2

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
       862 ~ 3%     -41.8%        502 ~ 3%  brickland2/micro/vm-scalability/1T-anon-w-seq
       862          -41.8%        502       TOTAL buddyinfo.Node.0.zone.DMA32.5

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      4938 ~ 1%     +77.2%       8752 ~ 4%  brickland2/micro/vm-scalability/1T-anon-w-seq
      4938          +77.2%       8752       TOTAL pagetypeinfo.Node0.Normal.Movable.4

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      4001 ~ 1%     +70.7%       6832 ~ 3%  brickland2/micro/vm-scalability/1T-anon-w-seq
      4001          +70.7%       6832       TOTAL buddyinfo.Node.3.zone.Normal.0

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
    317658 ~11%     -31.2%     218681 ~17%  brickland2/micro/vm-scalability/1T-anon-w-seq
    317658          -31.2%     218681       TOTAL softirqs.SCHED

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
   4113003 ~ 0%     -41.3%    2415897 ~ 1%  brickland2/micro/vm-scalability/1T-anon-w-seq
   4113003          -41.3%    2415897       TOTAL softirqs.TIMER

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      2192 ~ 1%     +70.7%       3744 ~ 4%  brickland2/micro/vm-scalability/1T-anon-w-seq
      2192          +70.7%       3744       TOTAL pagetypeinfo.Node0.Normal.Movable.5

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      4572 ~ 2%     +70.9%       7812 ~ 2%  brickland2/micro/vm-scalability/1T-anon-w-seq
      4572          +70.9%       7812       TOTAL buddyinfo.Node.2.zone.Normal.4

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      1026 ~ 3%     +69.5%       1739 ~ 8%  brickland2/micro/vm-scalability/1T-anon-w-seq
      1026          +69.5%       1739       TOTAL pagetypeinfo.Node1.Normal.Movable.6

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      6093 ~ 2%     +67.3%      10196 ~ 4%  brickland2/micro/vm-scalability/1T-anon-w-seq
      6093          +67.3%      10196       TOTAL buddyinfo.Node.0.zone.Normal.3

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
   8849176 ~ 0%     -40.3%    5279716 ~ 0%  brickland2/micro/vm-scalability/1T-anon-w-seq
   8849176          -40.3%    5279716       TOTAL interrupts.LOC

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      4380 ~ 1%     +68.3%       7372 ~ 3%  brickland2/micro/vm-scalability/1T-anon-w-seq
      4380          +68.3%       7372       TOTAL buddyinfo.Node.3.zone.Normal.4

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
       848 ~ 6%     +65.2%       1401 ~11%  brickland2/micro/vm-scalability/1T-anon-w-seq
       848          +65.2%       1401       TOTAL numa-vmstat.node1.nr_alloc_batch

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      5510 ~ 1%     +68.7%       9296 ~ 4%  brickland2/micro/vm-scalability/1T-anon-w-seq
      5510          +68.7%       9296       TOTAL buddyinfo.Node.0.zone.Normal.1

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      4828 ~ 1%     +64.3%       7933 ~ 3%  brickland2/micro/vm-scalability/1T-anon-w-seq
      4828          +64.3%       7933       TOTAL buddyinfo.Node.1.zone.Normal.4

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      1086 ~ 1%     +60.3%       1740 ~ 5%  brickland2/micro/vm-scalability/1T-anon-w-seq
      1086          +60.3%       1740       TOTAL pagetypeinfo.Node0.Normal.Movable.6

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      1951 ~ 1%     +61.3%       3146 ~ 3%  brickland2/micro/vm-scalability/1T-anon-w-seq
      1951          +61.3%       3146       TOTAL buddyinfo.Node.3.zone.Normal.5

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
       844 ~ 3%     -35.8%        542 ~ 2%  brickland2/micro/vm-scalability/1T-anon-w-seq
       844          -35.8%        542       TOTAL pagetypeinfo.Node0.DMA32.Movable.5

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      2106 ~ 1%     +58.6%       3340 ~ 4%  brickland2/micro/vm-scalability/1T-anon-w-seq
      2106          +58.6%       3340       TOTAL buddyinfo.Node.1.zone.Normal.5

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
       529 ~ 2%     +52.7%        808 ~ 8%  brickland2/micro/vm-scalability/1T-anon-w-seq
       529          +52.7%        808       TOTAL pagetypeinfo.Node2.Normal.Movable.7

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      1048 ~ 3%     +53.1%       1605 ~ 5%  brickland2/micro/vm-scalability/1T-anon-w-seq
      1048          +53.1%       1605       TOTAL buddyinfo.Node.2.zone.Normal.6

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
       327 ~ 0%     -34.6%        214 ~ 1%  brickland2/micro/vm-scalability/1T-anon-w-seq
       327          -34.6%        214       TOTAL uptime.boot

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      4259 ~ 1%     +52.1%       6480 ~ 4%  brickland2/micro/vm-scalability/1T-anon-w-seq
      4259          +52.1%       6480       TOTAL buddyinfo.Node.0.zone.Normal.0

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      4882 ~ 2%     +39.7%       6818 ~ 4%  brickland2/micro/vm-scalability/1T-anon-w-seq
      4882          +39.7%       6818       TOTAL buddyinfo.Node.0.zone.Normal.4

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
       482 ~ 3%     +39.2%        670 ~ 8%  brickland2/micro/vm-scalability/1T-anon-w-seq
       482          +39.2%        670       TOTAL pagetypeinfo.Node1.Normal.Movable.7

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      1029 ~ 2%     +39.9%       1441 ~ 4%  brickland2/micro/vm-scalability/1T-anon-w-seq
      1029          +39.9%       1441       TOTAL buddyinfo.Node.1.zone.Normal.6

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
       530 ~ 1%     +32.5%        702 ~ 6%  brickland2/micro/vm-scalability/1T-anon-w-seq
       530          +32.5%        702       TOTAL pagetypeinfo.Node0.Normal.Movable.7

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
       801 ~ 8%     +43.3%       1147 ~ 5%  brickland2/micro/vm-scalability/1T-anon-w-seq
       801          +43.3%       1147       TOTAL numa-vmstat.node0.nr_alloc_batch

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      1270 ~ 1%     -24.9%        953 ~ 4%  brickland2/micro/vm-scalability/1T-anon-w-seq
      1270          -24.9%        953       TOTAL buddyinfo.Node.0.zone.DMA32.0

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      2192 ~ 1%     +32.2%       2898 ~ 4%  brickland2/micro/vm-scalability/1T-anon-w-seq
      2192          +32.2%       2898       TOTAL buddyinfo.Node.0.zone.Normal.5

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      1021 ~ 3%     +31.6%       1344 ~ 2%  brickland2/micro/vm-scalability/1T-anon-w-seq
      1021          +31.6%       1344       TOTAL buddyinfo.Node.3.zone.Normal.6

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
 2.135e+08 ~ 0%     +26.6%  2.703e+08 ~ 0%  brickland2/micro/vm-scalability/1T-anon-w-seq
 2.135e+08          +26.6%  2.703e+08       TOTAL numa-numastat.node1.numa_hit

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
 2.135e+08 ~ 0%     +26.6%  2.703e+08 ~ 0%  brickland2/micro/vm-scalability/1T-anon-w-seq
 2.135e+08          +26.6%  2.703e+08       TOTAL numa-numastat.node1.local_node

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
     16161 ~ 0%     -20.7%      12816 ~ 0%  brickland2/micro/vm-scalability/1T-anon-w-seq
     16161          -20.7%      12816       TOTAL proc-vmstat.nr_tlb_local_flush_all

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
 1.072e+08 ~ 0%     +26.2%  1.352e+08 ~ 0%  brickland2/micro/vm-scalability/1T-anon-w-seq
 1.072e+08          +26.2%  1.352e+08       TOTAL numa-vmstat.node1.numa_local

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
 1.072e+08 ~ 0%     +26.2%  1.353e+08 ~ 0%  brickland2/micro/vm-scalability/1T-anon-w-seq
 1.072e+08          +26.2%  1.353e+08       TOTAL numa-vmstat.node1.numa_hit

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
 2.138e+08 ~ 0%     +25.2%  2.677e+08 ~ 0%  brickland2/micro/vm-scalability/1T-anon-w-seq
 2.138e+08          +25.2%  2.677e+08       TOTAL numa-numastat.node2.numa_hit

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
 2.138e+08 ~ 0%     +25.2%  2.677e+08 ~ 0%  brickland2/micro/vm-scalability/1T-anon-w-seq
 2.138e+08          +25.2%  2.677e+08       TOTAL numa-numastat.node2.local_node

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
 8.586e+08 ~ 0%     +25.2%  1.075e+09 ~ 0%  brickland2/micro/vm-scalability/1T-anon-w-seq
 8.586e+08          +25.2%  1.075e+09       TOTAL proc-vmstat.numa_hit

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
 8.586e+08 ~ 0%     +25.2%  1.075e+09 ~ 0%  brickland2/micro/vm-scalability/1T-anon-w-seq
 8.586e+08          +25.2%  1.075e+09       TOTAL proc-vmstat.numa_local

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
 1.074e+08 ~ 0%     +24.7%  1.339e+08 ~ 1%  brickland2/micro/vm-scalability/1T-anon-w-seq
 1.074e+08          +24.7%  1.339e+08       TOTAL numa-vmstat.node2.numa_local

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
 1.074e+08 ~ 0%     +24.7%  1.339e+08 ~ 1%  brickland2/micro/vm-scalability/1T-anon-w-seq
 1.074e+08          +24.7%  1.339e+08       TOTAL numa-vmstat.node2.numa_hit

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
 2.156e+08 ~ 0%     +24.4%  2.682e+08 ~ 0%  brickland2/micro/vm-scalability/1T-anon-w-seq
 2.156e+08          +24.4%  2.682e+08       TOTAL numa-numastat.node0.numa_hit

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
 2.156e+08 ~ 0%     +24.4%  2.682e+08 ~ 0%  brickland2/micro/vm-scalability/1T-anon-w-seq
 2.156e+08          +24.4%  2.682e+08       TOTAL numa-numastat.node0.local_node

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
 2.156e+08 ~ 0%     +24.6%  2.687e+08 ~ 0%  brickland2/micro/vm-scalability/1T-anon-w-seq
 2.156e+08          +24.6%  2.687e+08       TOTAL numa-numastat.node3.numa_hit

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
 2.156e+08 ~ 0%     +24.6%  2.687e+08 ~ 0%  brickland2/micro/vm-scalability/1T-anon-w-seq
 2.156e+08          +24.6%  2.687e+08       TOTAL numa-numastat.node3.local_node

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
 1.083e+08 ~ 0%     +24.2%  1.344e+08 ~ 0%  brickland2/micro/vm-scalability/1T-anon-w-seq
 1.083e+08          +24.2%  1.344e+08       TOTAL numa-vmstat.node3.numa_local

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
 1.083e+08 ~ 0%     +24.1%  1.345e+08 ~ 0%  brickland2/micro/vm-scalability/1T-anon-w-seq
 1.083e+08          +24.1%  1.345e+08       TOTAL numa-vmstat.node3.numa_hit

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
 1.083e+08 ~ 0%     +23.9%  1.342e+08 ~ 0%  brickland2/micro/vm-scalability/1T-anon-w-seq
 1.083e+08          +23.9%  1.342e+08       TOTAL numa-vmstat.node0.numa_local

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
 1.083e+08 ~ 0%     +24.0%  1.342e+08 ~ 0%  brickland2/micro/vm-scalability/1T-anon-w-seq
 1.083e+08          +24.0%  1.342e+08       TOTAL numa-vmstat.node0.numa_hit

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
       532 ~ 5%     +21.6%        646 ~ 6%  brickland2/micro/vm-scalability/1T-anon-w-seq
       532          +21.6%        646       TOTAL pagetypeinfo.Node3.Normal.Movable.7

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      1183 ~ 1%     +21.9%       1442 ~ 3%  brickland2/micro/vm-scalability/1T-anon-w-seq
      1183          +21.9%       1442       TOTAL pagetypeinfo.Node0.DMA32.Movable.3

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      1427 ~ 2%     -16.7%       1188 ~ 3%  brickland2/micro/vm-scalability/1T-anon-w-seq
      1427          -16.7%       1188       TOTAL buddyinfo.Node.0.zone.DMA32.1

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      1108 ~ 1%     +23.0%       1362 ~ 5%  brickland2/micro/vm-scalability/1T-anon-w-seq
      1108          +23.0%       1362       TOTAL buddyinfo.Node.0.zone.Normal.6

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
     52938 ~ 3%     +21.3%      64193 ~ 6%  brickland2/micro/vm-scalability/1T-anon-w-seq
     52938          +21.3%      64193       TOTAL numa-meminfo.node1.SUnreclaim

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
     13235 ~ 3%     +20.9%      15999 ~ 6%  brickland2/micro/vm-scalability/1T-anon-w-seq
     13235          +20.9%      15999       TOTAL numa-vmstat.node1.nr_slab_unreclaimable

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
     11461 ~ 7%     +15.1%      13193 ~ 6%  brickland2/micro/vm-scalability/1T-anon-w-seq
     11461          +15.1%      13193       TOTAL numa-meminfo.node2.SReclaimable

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      2865 ~ 7%     +15.1%       3297 ~ 6%  brickland2/micro/vm-scalability/1T-anon-w-seq
      2865          +15.1%       3297       TOTAL numa-vmstat.node2.nr_slab_reclaimable

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
       542 ~ 5%     +18.1%        640 ~11%  brickland2/micro/vm-scalability/1T-anon-w-seq
       542          +18.1%        640       TOTAL buddyinfo.Node.2.zone.Normal.7

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
       713 ~ 6%     -13.5%        617 ~ 0%  brickland2/micro/vm-scalability/1T-anon-w-seq
       713          -13.5%        617       TOTAL proc-vmstat.nr_tlb_remote_flush

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
    427342 ~ 6%      -9.7%     385983 ~ 4%  brickland2/micro/vm-scalability/1T-anon-w-seq
    427342           -9.7%     385983       TOTAL softirqs.RCU

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
     28839 ~ 1%     -15.5%      24378 ~ 4%  brickland2/micro/vm-scalability/1T-anon-w-seq
     28839          -15.5%      24378       TOTAL interrupts.RES

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
    499520 ~ 1%     -14.9%     425277 ~ 0%  brickland2/micro/vm-scalability/1T-anon-w-seq
    499520          -14.9%     425277       TOTAL proc-vmstat.nr_tlb_local_flush_one

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      8821 ~ 7%     -13.8%       7604 ~ 6%  brickland2/micro/vm-scalability/1T-anon-w-seq
      8821          -13.8%       7604       TOTAL numa-vmstat.node2.nr_slab_unreclaimable

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
     35283 ~ 7%     -13.8%      30420 ~ 6%  brickland2/micro/vm-scalability/1T-anon-w-seq
     35283          -13.8%      30420       TOTAL numa-meminfo.node2.SUnreclaim

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
     66494 ~ 1%     +16.7%      77567 ~ 6%  brickland2/micro/vm-scalability/1T-anon-w-seq
     66494          +16.7%      77567       TOTAL numa-meminfo.node1.Slab

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      1020 ~ 2%     +12.5%       1148 ~ 3%  brickland2/micro/vm-scalability/1T-anon-w-seq
      1020          +12.5%       1148       TOTAL pagetypeinfo.Node0.DMA32.Movable.4

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
   1828845 ~ 0%     -10.8%    1631171 ~ 2%  brickland2/micro/vm-scalability/1T-anon-w-seq
   1828845          -10.8%    1631171       TOTAL numa-vmstat.node0.nr_anon_pages

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
   7331140 ~ 0%     -12.0%    6449565 ~ 3%  brickland2/micro/vm-scalability/1T-anon-w-seq
   7331140          -12.0%    6449565       TOTAL numa-meminfo.node0.AnonPages

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
   1870212 ~ 0%      -9.9%    1684211 ~ 2%  brickland2/micro/vm-scalability/1T-anon-w-seq
   1870212           -9.9%    1684211       TOTAL numa-vmstat.node0.nr_active_anon

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
   7535346 ~ 0%     -11.1%    6700599 ~ 3%  brickland2/micro/vm-scalability/1T-anon-w-seq
   7535346          -11.1%    6700599       TOTAL numa-meminfo.node0.Active

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
   7503922 ~ 0%     -11.1%    6671209 ~ 3%  brickland2/micro/vm-scalability/1T-anon-w-seq
   7503922          -11.1%    6671209       TOTAL numa-meminfo.node0.Active(anon)

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
     57978 ~ 3%     +11.1%      64427 ~ 1%  brickland2/micro/vm-scalability/1T-anon-w-seq
     57978          +11.1%      64427       TOTAL slabinfo.anon_vma.active_objs

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
       408 ~ 5%     -11.4%        362 ~ 0%  brickland2/micro/vm-scalability/1T-anon-w-seq
       408          -11.4%        362       TOTAL proc-vmstat.nr_written

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      4732 ~ 0%     -10.2%       4247 ~ 2%  brickland2/micro/vm-scalability/1T-anon-w-seq
      4732          -10.2%       4247       TOTAL numa-vmstat.node0.nr_page_table_pages

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      1369 ~ 1%     +10.3%       1510 ~ 3%  brickland2/micro/vm-scalability/1T-anon-w-seq
      1369          +10.3%       1510       TOTAL pagetypeinfo.Node0.DMA32.Movable.2

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
     58406 ~ 3%     +10.5%      64555 ~ 1%  brickland2/micro/vm-scalability/1T-anon-w-seq
     58406          +10.5%      64555       TOTAL slabinfo.anon_vma.num_objs

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
   8097280 ~ 0%      -9.6%    7316439 ~ 3%  brickland2/micro/vm-scalability/1T-anon-w-seq
   8097280           -9.6%    7316439       TOTAL numa-meminfo.node0.MemUsed

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      1627 ~ 1%     -10.8%       1451 ~ 2%  brickland2/micro/vm-scalability/1T-anon-w-seq
      1627          -10.8%       1451       TOTAL numa-meminfo.node3.KernelStack

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
     19017 ~ 1%      -9.6%      17195 ~ 1%  brickland2/micro/vm-scalability/1T-anon-w-seq
     19017           -9.6%      17195       TOTAL numa-meminfo.node0.PageTables

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
     27062 ~ 0%     -49.6%      13638 ~ 0%  brickland2/micro/vm-scalability/1T-anon-w-seq
     27062          -49.6%      13638       TOTAL time.system_time

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
       278 ~ 0%     -40.6%        165 ~ 1%  brickland2/micro/vm-scalability/1T-anon-w-seq
       278          -40.6%        165       TOTAL time.elapsed_time

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
    106348 ~ 0%     -39.3%      64557 ~ 1%  brickland2/micro/vm-scalability/1T-anon-w-seq
    106348          -39.3%      64557       TOTAL time.involuntary_context_switches

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      1212 ~ 0%     +19.7%       1451 ~ 1%  brickland2/micro/vm-scalability/1T-anon-w-seq
      1212          +19.7%       1451       TOTAL vmstat.system.cs

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
     11098 ~ 0%      -4.4%      10614 ~ 1%  brickland2/micro/vm-scalability/1T-anon-w-seq
     11098           -4.4%      10614       TOTAL time.percent_of_cpu_this_job_got

8798cee2f90292c  fff4068cba484e6b0abe334ed  
---------------  -------------------------  
      3841 ~ 0%      +1.7%       3906 ~ 0%  brickland2/micro/vm-scalability/1T-anon-w-seq
      3841           +1.7%       3906       TOTAL time.user_time

Visualized numbers for all the GOOD/BAD commits during bisect:

                                  time.system_time

   28000 ++-----------------------------------------------------------------+
         *.*..*.*..*.*..*.*..*.*..*.*..*.*..*.*..*.*..*.*..*.*..*.*..*.*..*.*
   26000 ++                                                                 |
   24000 ++                                                                 |
         |                                                                  |
   22000 ++                                                                 |
         |                                                                  |
   20000 ++                                                                 |
         |                                                                  |
   18000 ++                                                                 |
   16000 ++                                                                 |
         |                                                                  |
   14000 ++     O    O                                                      |
         O O  O    O    O O  O O  O O  O                                    |
   12000 ++-----------------------------------------------------------------+


                          time.percent_of_cpu_this_job_got

   11200 ++-----------------------------------------------------------------+
   11100 *+*..*.*..*.*..*.  .*.*..*    *.*..*.*..*.*..*.*..*.*..*.*..*.*.. .*
         |                *.       :  +                                   * |
   11000 ++                        : +                                      |
   10900 ++                         *                                       |
   10800 ++                                                                 |
   10700 ++O  O O  O O       O    O    O                                    |
         |              O           O                                       |
   10600 O+                                                                 |
   10500 ++                                                                 |
   10400 ++                                                                 |
   10300 ++                    O                                            |
         |                                                                  |
   10200 ++               O                                                 |
   10100 ++-----------------------------------------------------------------+


                                 time.elapsed_time

   300 ++-------------------------------------------------------------------+
       |                                                                    |
   280 *+.*.*..*.*..*.*..*.*..*..*.*..*.*..*.*..*.*..*..*.*..*.*..*.*..*.*..*
       |                                                                    |
   260 ++                                                                   |
       |                                                                    |
   240 ++                                                                   |
       |                                                                    |
   220 ++                                                                   |
       |                                                                    |
   200 ++                                                                   |
       |                                                                    |
   180 ++                                                                   |
       |              O  O    O                                             |
   160 O+-O-O--O-O--O------O-----O-O--O-------------------------------------+


                           time.involuntary_context_switches

   110000 ++----------*------------------------*----------------------------+
   105000 *+*..*.*..*    *.*..*.*.*..*    *.*.   *.. .*.*..*.*..*.*..*.*..*.*
          |                           + ..          *                       |
   100000 ++                           *                                    |
    95000 ++                                                                |
          |                                                                 |
    90000 ++                                                                |
    85000 ++                                                                |
    80000 ++                                                                |
          |                                                                 |
    75000 ++                                                                |
    70000 ++                                                                |
          | O  O O  O O  O        O                                         |
    65000 O+               O  O O    O O                                    |
    60000 ++----------------------------------------------------------------+


                               vm-scalability.throughput

   5.5e+07 ++---------------------------------------------------------------+
           | O                                                              |
     5e+07 O+   O O  O O O  O O  O O O  O                                   |
           |                                                                |
           |                                                                |
   4.5e+07 ++                                                               |
           |                                                                |
     4e+07 ++                                                               |
           |                                                                |
   3.5e+07 ++                                                               |
           |                                                                |
           |                                                                |
     3e+07 ++                                                               |
           *.*..*.*..*.*.*..*.*..*.*.*..*.*..*.*..*.*.*..*.*..*.*.*..*.*..*.*
   2.5e+07 ++---------------------------------------------------------------+


                                  vmstat.system.cs

   1500 ++------------------------------------------------------------------+
        |                           O                                       |
   1450 ++   O  O O  O O    O         O                                     |
        |                 O      O                                          |
        O  O                   O                                            |
   1400 ++                                                                  |
        |                                                                   |
   1350 ++                                                                  |
        |                                                                   |
   1300 ++                                                                  |
        |                                                                   |
        |                                                                   |
   1250 ++        *..                                                       |
        | .*.    +    .*..*.*.. .*.. .*..*.*.. .*..*.*..*.*.. .*..*.*..*.   |
   1200 *+---*--*----*---------*----*---------*--------------*-----------*--*

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
