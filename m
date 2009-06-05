Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 1F92A6B004D
	for <linux-mm@kvack.org>; Fri,  5 Jun 2009 10:30:45 -0400 (EDT)
Received: by rv-out-0708.google.com with SMTP id l33so144669rvb.6
        for <linux-mm@kvack.org>; Fri, 05 Jun 2009 07:30:43 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH][mmtom] remove annotation of gfp_mask in add_to_swap
Date: Fri,  5 Jun 2009 23:30:35 +0900
Message-Id: <1244212237-14128-1-git-send-email-minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

Hugh removed add_to_swap's gfp_mask argument.
(mm: remove gfp_mask from add_to_swap)
So we have to remove annotation of gfp_mask  of the function.

This patch cleans up add_to_swap function.
It doesn't affect behavior of function.

Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---
 mm/swap_state.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/mm/swap_state.c b/mm/swap_state.c
index b9ca029..b62e7f5 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -124,7 +124,6 @@ void __delete_from_swap_cache(struct page *page)
 /**
  * add_to_swap - allocate swap space for a page
  * @page: page we want to move to swap
- * @gfp_mask: memory allocation flags
  *
  * Allocate swap space for the page and add the page to the
  * swap cache.  Caller needs to hold the page lock. 
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
