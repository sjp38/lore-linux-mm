Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 87B7D6B0038
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 21:53:37 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id 72so13419917oik.6
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 18:53:37 -0800 (PST)
Received: from mxct.zte.com.cn (out1.zte.com.cn. [202.103.147.172])
        by mx.google.com with ESMTPS id s203si11235146oif.248.2017.11.27.18.53.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Nov 2017 18:53:36 -0800 (PST)
From: Jiang Biao <jiang.biao2@zte.com.cn>
Subject: [PATCH] mm/vmscan: change return type of is_page_cache_freeable from int to bool
Date: Tue, 28 Nov 2017 10:48:27 +0800
Message-Id: <1511837307-56494-1-git-send-email-jiang.biao2@zte.com.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, jiang.biao2@zte.com.cn, zhong.weidong@zte.com.cn

Using bool for the return type of is_page_cache_freeable() should be
more appropriate.

Signed-off-by: Jiang Biao <jiang.biao2@zte.com.cn>
---
 mm/vmscan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index eb2f031..5fe63ed 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -530,7 +530,7 @@ void drop_slab(void)
 		drop_slab_node(nid);
 }
 
-static inline int is_page_cache_freeable(struct page *page)
+static inline bool is_page_cache_freeable(struct page *page)
 {
 	/*
 	 * A freeable page cache page is referenced only by the caller
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
