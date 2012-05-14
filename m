Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 95C866B004D
	for <linux-mm@kvack.org>; Mon, 14 May 2012 00:58:42 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so8049190pbb.14
        for <linux-mm@kvack.org>; Sun, 13 May 2012 21:58:41 -0700 (PDT)
Date: Sun, 13 May 2012 21:58:18 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 0/3] mm/memcg: trivia and more lruvec
Message-ID: <alpine.LSU.2.00.1205132152530.6148@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Here's a trivial renaming of two functions in Konstantin's patches;
some trivial little bits and pieces from my patches to vmscan.c now
on top of Konstantin's version; and the slightly more substantial
(but still functionally no different) use of lruvec instead of zone
pointer in lru_list functions.  Which I think takes us up to the
point beyond which Konstantin and I will need to settle differences
before proceeding further.

These I've diffed against 3.4.0-rc6-next-20120511, minus Ying's
"memcg: add mlock statistic in memory.stat" (and your fix to it)
that we already asked you to revert for now.

1/3 mm/memcg: get_lru_size not get_lruvec_size
2/3 mm: trivial cleanups in vmscan.c
3/3 mm/memcg: apply add/del_page to lruvec

 include/linux/memcontrol.h |   36 ++---------
 include/linux/mm_inline.h  |   20 +++---
 include/linux/swap.h       |    4 -
 mm/compaction.c            |    5 +
 mm/huge_memory.c           |    8 +-
 mm/memcontrol.c            |  111 +++++++++--------------------------
 mm/swap.c                  |   85 +++++++++++++-------------
 mm/vmscan.c                |   97 ++++++++++++++----------------
 8 files changed, 147 insertions(+), 219 deletions(-)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
