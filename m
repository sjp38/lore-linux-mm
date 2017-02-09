Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 89A7B6B0387
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 09:17:53 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id y143so6368207pfb.6
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 06:17:53 -0800 (PST)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id 197si10172003pgd.70.2017.02.09.06.17.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Feb 2017 06:17:52 -0800 (PST)
Received: by mail-pf0-x242.google.com with SMTP id f144so318414pfa.2
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 06:17:52 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH] mm/page_alloc: remove redundant init code for ZONE_MOVABLE
Date: Thu,  9 Feb 2017 22:17:31 +0800
Message-Id: <20170209141731.60208-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@techsingularity.net, mhocko@suse.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>

arch_zone_lowest/highest_possible_pfn[] is set to 0 and [ZONE_MOVABLE] is
skipped in the loop. No need to reset them to 0 again.

This patch just removes the redundant code.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/page_alloc.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 51c60c0eadcb..cc9695d14226 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6279,8 +6279,6 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
 
 		start_pfn = end_pfn;
 	}
-	arch_zone_lowest_possible_pfn[ZONE_MOVABLE] = 0;
-	arch_zone_highest_possible_pfn[ZONE_MOVABLE] = 0;
 
 	/* Find the PFNs that ZONE_MOVABLE begins at in each node */
 	memset(zone_movable_pfn, 0, sizeof(zone_movable_pfn));
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
