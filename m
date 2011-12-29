Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 700F56B004D
	for <linux-mm@kvack.org>; Wed, 28 Dec 2011 23:33:18 -0500 (EST)
Received: by iacb35 with SMTP id b35so27614539iac.14
        for <linux-mm@kvack.org>; Wed, 28 Dec 2011 20:33:17 -0800 (PST)
Date: Wed, 28 Dec 2011 20:32:51 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 0/3] mm: three minor vmscan improvements
Message-ID: <alpine.LSU.2.00.1112282028160.1362@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

Here are three minor improvements in vmscan.c,
based on 3.2.0-rc6-next-20111222 minus Mel's 11/11
"mm: isolate pages for immediate reclaim on their own LRU"
and its two corrections.

[PATCH 1/3] mm: test PageSwapBacked in lumpy reclaim
[PATCH 2/3] mm: cond_resched in scan_mapping_unevictable_pages
[PATCH 3/3] mm: take pagevecs off reclaim stack

 include/linux/pagevec.h |    2 -
 mm/swap.c               |   19 -----------
 mm/vmscan.c             |   62 +++++++++++++++++++++++++-------------
 3 files changed, 42 insertions(+), 41 deletions(-)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
