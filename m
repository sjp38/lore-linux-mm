Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id D92316B025F
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 15:51:07 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r5so1399591wmr.0
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 12:51:07 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id j4si20479088wmj.12.2016.06.06.12.51.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 12:51:06 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 02/10] mm: swap: unexport __pagevec_lru_add()
Date: Mon,  6 Jun 2016 15:48:28 -0400
Message-Id: <20160606194836.3624-3-hannes@cmpxchg.org>
In-Reply-To: <20160606194836.3624-1-hannes@cmpxchg.org>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com

There is currently no modular user of this function. We used to have
filesystems that open-coded the page cache instantiation, but luckily
they're all streamlined, and we don't want this to come back.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/swap.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/swap.c b/mm/swap.c
index 95916142fc46..d810c3d95c97 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -860,7 +860,6 @@ void __pagevec_lru_add(struct pagevec *pvec)
 {
 	pagevec_lru_move_fn(pvec, __pagevec_lru_add_fn, NULL);
 }
-EXPORT_SYMBOL(__pagevec_lru_add);
 
 /**
  * pagevec_lookup_entries - gang pagecache lookup
-- 
2.8.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
