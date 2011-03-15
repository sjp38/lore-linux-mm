Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D0E9D8D0039
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 18:53:29 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [PATCH 11/13] mm: use list_move() instead of list_del()/list_add() combination
Date: Wed, 16 Mar 2011 00:53:23 +0200
Message-Id: <1300229605-14499-11-git-send-email-kirill@shutemov.name>
In-Reply-To: <1300229605-14499-1-git-send-email-kirill@shutemov.name>
References: <1300229605-14499-1-git-send-email-kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Rik van Riel <riel@redhat.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org
---
 mm/page_alloc.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index cdef1d4..55fa2ae 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -863,9 +863,8 @@ static int move_freepages(struct zone *zone,
 		}
 
 		order = page_order(page);
-		list_del(&page->lru);
-		list_add(&page->lru,
-			&zone->free_area[order].free_list[migratetype]);
+		list_move(&page->lru,
+			  &zone->free_area[order].free_list[migratetype]);
 		page += 1 << order;
 		pages_moved += 1 << order;
 	}
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
