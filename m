Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id EE4CB6B005D
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 16:44:34 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 0/8] page reclaim bits
Date: Wed, 12 Dec 2012 16:43:32 -0500
Message-Id: <1355348620-9382-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello,

I had these in my queue and on test machines for a while, but they got
deferred over and over, partly because of the kswapd issues.  I hope
it's not too late for 3.8, they should be fairly straight forward.

#1 takes the anon workingset protection with plenty file cache from
global reclaim, which was just merged into 3.8, and generalizes it to
include memcg reclaim.

#2-#6 are get_scan_count() fixes and cleanups.

#7 fixes reclaim-for-compaction to work against zones, not lruvecs,
since that is what compaction works against.  Practical impact only on
memcg setups, but confusing for everybody.

#8 puts ksm pages that are copied-on-swapin into their own separate
anon_vma.

Thanks!

 include/linux/swap.h |   2 +-
 mm/ksm.c             |   6 --
 mm/memory.c          |   5 +-
 mm/vmscan.c          | 268 +++++++++++++++++++++++++++----------------------
 4 files changed, 152 insertions(+), 129 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
