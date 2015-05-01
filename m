Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id 444876B0038
	for <linux-mm@kvack.org>; Fri,  1 May 2015 00:46:57 -0400 (EDT)
Received: by qgdy78 with SMTP id y78so34526812qgd.0
        for <linux-mm@kvack.org>; Thu, 30 Apr 2015 21:46:57 -0700 (PDT)
Received: from mail-qk0-x232.google.com (mail-qk0-x232.google.com. [2607:f8b0:400d:c09::232])
        by mx.google.com with ESMTPS id w30si3740887qge.103.2015.04.30.21.46.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Apr 2015 21:46:55 -0700 (PDT)
Received: by qku63 with SMTP id 63so46264759qku.3
        for <linux-mm@kvack.org>; Thu, 30 Apr 2015 21:46:55 -0700 (PDT)
From: Adir Kuhn <adirkuhn@gmail.com>
Subject: [PATCH] mm: swap: Fixed missing a blank line after declarations
Date: Fri,  1 May 2015 04:46:34 +0000
Message-Id: <1430455594-18341-1-git-send-email-adirkuhn@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rafael.j.wysocki@intel.com
Cc: linux-mm@kvack.org, Adir Kuhn <adirkuhn@gmail.com>

Fixed missing a blank line after declarations

Signed-off-by: Adir Kuhn <adirkuhn@gmail.com>
---
 mm/swap.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/swap.c b/mm/swap.c
index a7251a8..de83fca 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -451,6 +451,7 @@ static void pagevec_move_tail_fn(struct page *page, struct lruvec *lruvec,
 
 	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
 		enum lru_list lru = page_lru_base_type(page);
+
 		list_move_tail(&page->lru, &lruvec->lists[lru]);
 		(*pgmoved)++;
 	}
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
