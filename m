Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 7F18A6B002D
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 03:06:30 -0500 (EST)
Received: by ywp17 with SMTP id 17so4818039ywp.14
        for <linux-mm@kvack.org>; Tue, 15 Nov 2011 00:06:28 -0800 (PST)
Message-ID: <4EC21D78.4080508@gmail.com>
Date: Tue, 15 Nov 2011 16:06:16 +0800
From: Wang Sheng-Hui <shhuiw@gmail.com>
MIME-Version: 1.0
Subject: [PATCH] mm: cleanup the comment for head/tail pages of compound pages
 in mm/page_alloc.c
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Per the void prep_compound_page(struct page *page, unsigned long order) code,
compound pages use PG_head/PG_tail, and only tail pages point at head page
using their ->first_page field.

Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
---
 mm/page_alloc.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6e8ecb6..f645ce8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -332,8 +332,8 @@ out:
  *
  * The remaining PAGE_SIZE pages are called "tail pages".
  *
- * All pages have PG_compound set.  All pages have their ->private pointing at
- * the head page (even the head page has this).
+ * Head page has PG_head set, and all tail pages have PG_tail set. All tail
+ * pages have their ->first_page pointing at the head page.
  *
  * The first tail page's ->lru.next holds the address of the compound page's
  * put_page() function.  Its ->lru.prev holds the order of allocation.
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
