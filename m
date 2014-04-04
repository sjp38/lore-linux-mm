Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id EF0316B0031
	for <linux-mm@kvack.org>; Fri,  4 Apr 2014 20:21:14 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id r10so3991461pdi.7
        for <linux-mm@kvack.org>; Fri, 04 Apr 2014 17:21:14 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id jg5si388968pbb.383.2014.04.04.17.21.12
        for <linux-mm@kvack.org>;
        Fri, 04 Apr 2014 17:21:14 -0700 (PDT)
Date: Fri, 4 Apr 2014 21:59:08 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [mm] e04ddfd12aa: +9.4% ebizzy.throughput
Message-ID: <20140404135908.GB22386@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, lkp@01.org

Hi Davidlohr,

FYI, there are noticeable ebizzy throughput increases on commit
e04ddfd12aa03471eff7daf3bc2435c7cea8e21f ("mm: per-thread vma caching")

test case: lkp-st02/micro/ebizzy/200%-100-10

700141f349f2b05  e04ddfd12aa03471eff7daf3b  
---------------  -------------------------  
     23726 ~ 0%      +9.4%      25955 ~ 0%  TOTAL ebizzy.throughput
      1525 ~ 0%      +9.3%       1667 ~ 0%  TOTAL ebizzy.throughput.per_thread.max
      1428 ~ 0%      +9.1%       1558 ~ 0%  TOTAL ebizzy.throughput.per_thread.min
     14.42 ~ 0%      +8.1%      15.59 ~ 0%  TOTAL ebizzy.time.user
     65.29 ~ 0%      -1.8%      64.12 ~ 0%  TOTAL ebizzy.time.sys
      4290 ~17%     -28.4%       3073 ~22%  TOTAL slabinfo.buffer_head.active_objs
      4313 ~17%     -28.8%       3073 ~22%  TOTAL slabinfo.buffer_head.num_objs
    165372 ~ 0%      +9.2%     180527 ~ 0%  TOTAL vmstat.system.in
      1443 ~ 0%      +8.1%       1560 ~ 0%  TOTAL time.user_time
      6529 ~ 0%      -1.8%       6413 ~ 0%  TOTAL time.system_time

Legend:
	~XX%    - stddev percent
	[+-]XX% - change percent


                                  ebizzy.throughput

   26500 ++O-----------O---O------------------------------------------------+
         O   O O O O     O   O O O     O O                                  |
   26000 ++          O             O O      O     O                         |
         |                                 O  O O                           |
         |                                                                  |
   25500 ++                                                                 |
         |                                                                  |
   25000 ++                                                                 |
         |                                                                  |
   24500 ++                                                                 |
         |                                                                  |
         *.*.*.   .*. .*.*.*.   .*.*.       *.*.*.*.                        |
   24000 ++    *.*   *       *.*     *.*.*.*        *.*.*.*.*.*.            |
         |                                                      *.*.*.*.*.*.*
   23500 ++-----------------------------------------------------------------+


	[*] bisect-good sample
	[O] bisect-bad  sample

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
