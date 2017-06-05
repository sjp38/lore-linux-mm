Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3F1F56B0292
	for <linux-mm@kvack.org>; Sun,  4 Jun 2017 21:43:56 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 62so132131489pft.3
        for <linux-mm@kvack.org>; Sun, 04 Jun 2017 18:43:56 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id e6si6010187plk.0.2017.06.04.18.43.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Jun 2017 18:43:55 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id v14so4366473pgn.1
        for <linux-mm@kvack.org>; Sun, 04 Jun 2017 18:43:55 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH] mm/page_alloc: Trivial typo fix.
Date: Mon,  5 Jun 2017 09:43:50 +0800
Message-Id: <20170605014350.1973-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: trivial@kernel.org, akpm@linux-foundation.org, mhocko@suse.com
Cc: linux-mm@kvack.org, Wei Yang <richard.weiyang@gmail.com>

Looks there is no word "blamo", and it should be "blame".

This patch just fix the typo.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 07efbc3a8656..9ce765e6fe2f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3214,7 +3214,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	if (gfp_mask & __GFP_THISNODE)
 		goto out;
 
-	/* Exhausted what can be done so it's blamo time */
+	/* Exhausted what can be done so it's blame time */
 	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
 		*did_some_progress = 1;
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
