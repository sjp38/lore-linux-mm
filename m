Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id EC1936B005D
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 03:14:56 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 0/5] Consider higher small zone and mmaped-pages stream
Date: Wed, 22 Aug 2012 16:15:12 +0900
Message-Id: <1345619717-5322-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>

This patchset solves two problem.

1. higher small memory zone - [2] and [3]
2. mmaped-pages stream reclaim efficiency [5]

[1] and [4] is minor fix which isn't related with
this series so it could be apply separately.

I wrote down each problem in each patch description.
Please look at each patch.

Test enviroment is following as

1. Intel(R) Core(TM)2 Duo CPU
2. 2G RAM and 400M movable zone
3. Test program:
   Hannes's mapped-file-stream.c with 78 processes per 1G.
   10 times exectuion.

Thanks.

Minchan Kim (5):
  [1] vmscan: Fix obsolete comment of balance_pgdat
  [2] vmscan: sleep only if backingdev is congested
  [3] vmscan: prevent excessive pageout of kswapd
  [4] vmscan: get rid of unnecessary nr_dirty ret variable
  [5] vmscan: accelerate to reclaim mapped-pages stream

 include/linux/mmzone.h |   23 +++++++++++++++
 mm/vmscan.c            |   77 ++++++++++++++++++++++++++++++++++++++----------
 2 files changed, 85 insertions(+), 15 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
