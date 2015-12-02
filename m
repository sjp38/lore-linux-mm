Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 920D76B0256
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 10:48:01 -0500 (EST)
Received: by obbnk6 with SMTP id nk6so35571660obb.2
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 07:48:01 -0800 (PST)
Received: from m50-138.163.com (m50-138.163.com. [123.125.50.138])
        by mx.google.com with ESMTP id qm8si3832358obb.27.2015.12.02.07.47.59
        for <linux-mm@kvack.org>;
        Wed, 02 Dec 2015 07:48:01 -0800 (PST)
From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH 2/3] mm/slab: use list_for_each_entry in cache_flusharray
Date: Wed,  2 Dec 2015 23:46:12 +0800
Message-Id: <22e322cb81d99e70674e9f833c5b6aa4e87714c6.1449070964.git.geliangtang@163.com>
In-Reply-To: <7e551749f5a50cef15a33320d6d33b9d0b0986bd.1449070964.git.geliangtang@163.com>
References: <7e551749f5a50cef15a33320d6d33b9d0b0986bd.1449070964.git.geliangtang@163.com>
In-Reply-To: <7e551749f5a50cef15a33320d6d33b9d0b0986bd.1449070964.git.geliangtang@163.com>
References: <7e551749f5a50cef15a33320d6d33b9d0b0986bd.1449070964.git.geliangtang@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Geliang Tang <geliangtang@163.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Simplify the code with list_for_each_entry().

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 mm/slab.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 6bb0466..5d5aa3b 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3338,17 +3338,12 @@ free_done:
 #if STATS
 	{
 		int i = 0;
-		struct list_head *p;
-
-		p = n->slabs_free.next;
-		while (p != &(n->slabs_free)) {
-			struct page *page;
+		struct page *page;
 
-			page = list_entry(p, struct page, lru);
+		list_for_each_entry(page, &n->slabs_free, lru) {
 			BUG_ON(page->active);
 
 			i++;
-			p = p->next;
 		}
 		STATS_SET_FREEABLE(cachep, i);
 	}
-- 
2.5.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
