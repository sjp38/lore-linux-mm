Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 850786B0253
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 16:00:33 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id x83so15713845wma.2
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 13:00:33 -0700 (PDT)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id b3si534331wje.193.2016.07.08.13.00.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jul 2016 13:00:32 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id EF8A11C325E
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 21:00:31 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 1/3] mm, meminit: Remove early_page_nid_uninitialised
Date: Fri,  8 Jul 2016 21:00:29 +0100
Message-Id: <1468008031-3848-2-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1468008031-3848-1-git-send-email-mgorman@techsingularity.net>
References: <1468008031-3848-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

The helper early_page_nid_uninitialised() has been dead since commit
974a786e63c9 ("mm, page_alloc: remove MIGRATE_RESERVE") so remove the
dead code.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 13 -------------
 1 file changed, 13 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c1069efcc4d7..a19527aa4243 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -292,14 +292,6 @@ static inline bool __meminit early_page_uninitialised(unsigned long pfn)
 	return false;
 }
 
-static inline bool early_page_nid_uninitialised(unsigned long pfn, int nid)
-{
-	if (pfn >= NODE_DATA(nid)->first_deferred_pfn)
-		return true;
-
-	return false;
-}
-
 /*
  * Returns false when the remaining initialisation should be deferred until
  * later in the boot cycle when it can be parallelised.
@@ -339,11 +331,6 @@ static inline bool early_page_uninitialised(unsigned long pfn)
 	return false;
 }
 
-static inline bool early_page_nid_uninitialised(unsigned long pfn, int nid)
-{
-	return false;
-}
-
 static inline bool update_defer_init(pg_data_t *pgdat,
 				unsigned long pfn, unsigned long zone_end,
 				unsigned long *nr_initialised)
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
