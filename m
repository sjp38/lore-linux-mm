Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 85A136B0038
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 15:07:57 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id f66so12057386oib.1
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 12:07:57 -0700 (PDT)
Received: from gateway32.websitewelcome.com (gateway32.websitewelcome.com. [192.185.145.107])
        by mx.google.com with ESMTPS id u19si529987ota.392.2017.10.20.12.07.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Oct 2017 12:07:56 -0700 (PDT)
Received: from cm12.websitewelcome.com (cm12.websitewelcome.com [100.42.49.8])
	by gateway32.websitewelcome.com (Postfix) with ESMTP id 1223CA7C51
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 14:07:56 -0500 (CDT)
Date: Fri, 20 Oct 2017 14:07:54 -0500
From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] mm: list_lru: mark expected switch fall-through
Message-ID: <20171020190754.GA24332@embeddedor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, "Gustavo A. R. Silva" <garsilva@embeddedor.com>

In preparation to enabling -Wimplicit-fallthrough, mark switch cases
where we are expecting to fall through.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
This code was tested by compilation only (GCC 7.2.0 was used).
Please, verify if the actual intention of the code is to fall through.

 mm/list_lru.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/list_lru.c b/mm/list_lru.c
index f8c7de8..278db98 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -222,6 +222,7 @@ __list_lru_walk_one(struct list_lru *lru, int nid, int memcg_idx,
 		switch (ret) {
 		case LRU_REMOVED_RETRY:
 			assert_spin_locked(&nlru->lock);
+			/* fall through */
 		case LRU_REMOVED:
 			isolated++;
 			nlru->nr_items--;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
