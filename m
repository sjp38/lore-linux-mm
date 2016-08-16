Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 533876B0263
	for <linux-mm@kvack.org>; Mon, 15 Aug 2016 22:51:35 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id o124so149772903pfg.1
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 19:51:35 -0700 (PDT)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id s9si29617091pfi.100.2016.08.15.19.51.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Aug 2016 19:51:34 -0700 (PDT)
Received: by mail-pa0-x242.google.com with SMTP id cf3so4468307pad.2
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 19:51:34 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v2 4/6] mm/page_ext: rename offset to index
Date: Tue, 16 Aug 2016 11:51:17 +0900
Message-Id: <1471315879-32294-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1471315879-32294-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1471315879-32294-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Here, 'offset' means entry index in page_ext array. Following patch
will use 'offset' for field offset in each entry so rename current
'offset' to prevent confusion.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_ext.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/page_ext.c b/mm/page_ext.c
index 44a4c02..1629282 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -102,7 +102,7 @@ void __meminit pgdat_page_ext_init(struct pglist_data *pgdat)
 struct page_ext *lookup_page_ext(struct page *page)
 {
 	unsigned long pfn = page_to_pfn(page);
-	unsigned long offset;
+	unsigned long index;
 	struct page_ext *base;
 
 	base = NODE_DATA(page_to_nid(page))->node_page_ext;
@@ -119,9 +119,9 @@ struct page_ext *lookup_page_ext(struct page *page)
 	if (unlikely(!base))
 		return NULL;
 #endif
-	offset = pfn - round_down(node_start_pfn(page_to_nid(page)),
+	index = pfn - round_down(node_start_pfn(page_to_nid(page)),
 					MAX_ORDER_NR_PAGES);
-	return base + offset;
+	return base + index;
 }
 
 static int __init alloc_node_page_ext(int nid)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
