Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id D5DC36B00A7
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 09:10:17 -0500 (EST)
Received: by mail-ee0-f50.google.com with SMTP id c41so897623eek.23
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 06:10:17 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j47si1993544eeo.116.2013.12.13.06.10.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 13 Dec 2013 06:10:17 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 7/7] mm: page_alloc: Default allow file pages to use remote nodes for fair allocation policy
Date: Fri, 13 Dec 2013 14:10:07 +0000
Message-Id: <1386943807-29601-8-git-send-email-mgorman@suse.de>
In-Reply-To: <1386943807-29601-1-git-send-email-mgorman@suse.de>
References: <1386943807-29601-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Indications from Johannes that he wanted this. Needs some data and/or justification why
thrash protection needs it plus docs describing how MPOL_LOCAL is now different before
it should be considered finished. I do not necessarily agree this patch is necessary
but it's worth punting it out there for discussion and testing.

Not signed off
---
 mm/page_alloc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index bf49918..bce40c0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1885,7 +1885,8 @@ unsigned __bitwise__ zone_distribute_mode __read_mostly;
 #define DISTRIBUTE_STUPID_ANON	(DISTRIBUTE_LOCAL_ANON|DISTRIBUTE_REMOTE_ANON)
 #define DISTRIBUTE_STUPID_FILE	(DISTRIBUTE_LOCAL_FILE|DISTRIBUTE_REMOTE_FILE)
 #define DISTRIBUTE_STUPID_SLAB	(DISTRIBUTE_LOCAL_SLAB|DISTRIBUTE_REMOTE_SLAB)
-#define DISTRIBUTE_DEFAULT	(DISTRIBUTE_LOCAL_ANON|DISTRIBUTE_LOCAL_FILE|DISTRIBUTE_LOCAL_SLAB)
+#define DISTRIBUTE_DEFAULT	(DISTRIBUTE_LOCAL_ANON|DISTRIBUTE_LOCAL_FILE|DISTRIBUTE_LOCAL_SLAB| \
+				 DISTRIBUTE_REMOTE_FILE)
 
 /* Only these GFP flags are affected by the fair zone allocation policy */
 #define DISTRIBUTE_GFP_MASK	((GFP_MOVABLE_MASK|__GFP_PAGECACHE))
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
