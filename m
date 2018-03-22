Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 851706B000E
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 11:32:14 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p10so4777044pfl.22
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 08:32:14 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 65-v6si6447994plb.573.2018.03.22.08.32.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 22 Mar 2018 08:32:13 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v2 4/8] page_frag_cache: Rename fragsz to size
Date: Thu, 22 Mar 2018 08:31:53 -0700
Message-Id: <20180322153157.10447-5-willy@infradead.org>
In-Reply-To: <20180322153157.10447-1-willy@infradead.org>
References: <20180322153157.10447-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, netdev@vger.kernel.org, linux-mm@kvack.org, Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

The 'size' variable name used to be used for the page size.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 mm/page_alloc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c9fc76135dd8..5a2e3e293079 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4403,7 +4403,7 @@ void __page_frag_cache_drain(struct page *page, unsigned int count)
 EXPORT_SYMBOL(__page_frag_cache_drain);
 
 void *page_frag_alloc(struct page_frag_cache *pfc,
-		      unsigned int fragsz, gfp_t gfp_mask)
+		      unsigned int size, gfp_t gfp_mask)
 {
 	struct page *page;
 	int offset;
@@ -4415,7 +4415,7 @@ void *page_frag_alloc(struct page_frag_cache *pfc,
 			return NULL;
 	}
 
-	offset = pfc->offset - fragsz;
+	offset = pfc->offset - size;
 	if (unlikely(offset < 0))
 		goto refill;
 
-- 
2.16.2
