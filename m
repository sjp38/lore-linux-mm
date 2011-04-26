Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8D5149000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 12:25:59 -0400 (EDT)
Received: by mail-iy0-f169.google.com with SMTP id 42so951630iyh.14
        for <linux-mm@kvack.org>; Tue, 26 Apr 2011 09:25:58 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [RFC 4/8] Make clear description of putback_lru_page
Date: Wed, 27 Apr 2011 01:25:21 +0900
Message-Id: <bb2acc3882594cf54689d9e29c61077ff581c533.1303833417.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1303833415.git.minchan.kim@gmail.com>
References: <cover.1303833415.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1303833415.git.minchan.kim@gmail.com>
References: <cover.1303833415.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

Commonly, putback_lru_page is used with isolated_lru_page.
The isolated_lru_page picks the page in middle of LRU and
putback_lru_page insert the lru in head of LRU.
It means it could make LRU churning so we have to be very careful.
Let's clear description of putback_lru_page.

Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/migrate.c |    2 +-
 mm/vmscan.c  |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 34132f8..819d233 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -68,7 +68,7 @@ int migrate_prep_local(void)
 }
 
 /*
- * Add isolated pages on the list back to the LRU under page lock
+ * Add isolated pages on the list back to the LRU's head under page lock
  * to avoid leaking evictable pages back onto unevictable list.
  */
 void putback_lru_pages(struct list_head *l)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index e8d6190..5196f0c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -551,10 +551,10 @@ int remove_mapping(struct address_space *mapping, struct page *page)
 }
 
 /**
- * putback_lru_page - put previously isolated page onto appropriate LRU list
+ * putback_lru_page - put previously isolated page onto appropriate LRU list's head
  * @page: page to be put back to appropriate lru list
  *
- * Add previously isolated @page to appropriate LRU list.
+ * Add previously isolated @page to appropriate LRU list's head
  * Page may still be unevictable for other reasons.
  *
  * lru_lock must not be held, interrupts must be enabled.
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
