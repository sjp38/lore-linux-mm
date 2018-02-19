Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3693F6B0299
	for <linux-mm@kvack.org>; Mon, 19 Feb 2018 14:46:25 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id u19so3703394pfl.3
        for <linux-mm@kvack.org>; Mon, 19 Feb 2018 11:46:25 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d5si5749899pgn.564.2018.02.19.11.46.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 19 Feb 2018 11:46:24 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v7 38/61] mm: Convert __do_page_cache_readahead to XArray
Date: Mon, 19 Feb 2018 11:45:33 -0800
Message-Id: <20180219194556.6575-39-willy@infradead.org>
In-Reply-To: <20180219194556.6575-1-willy@infradead.org>
References: <20180219194556.6575-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

This one is trivial.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 mm/readahead.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/readahead.c b/mm/readahead.c
index f64b31b3a84a..66bcaffd47f0 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -174,9 +174,7 @@ int __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
 		if (page_offset > end_index)
 			break;
 
-		rcu_read_lock();
-		page = radix_tree_lookup(&mapping->pages, page_offset);
-		rcu_read_unlock();
+		page = xa_load(&mapping->pages, page_offset);
 		if (page && !xa_is_value(page))
 			continue;
 
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
