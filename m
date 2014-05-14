Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 319686B0039
	for <linux-mm@kvack.org>; Wed, 14 May 2014 12:17:06 -0400 (EDT)
Received: by mail-ig0-f176.google.com with SMTP id hl10so6766234igb.3
        for <linux-mm@kvack.org>; Wed, 14 May 2014 09:17:06 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id nw2si1694436icc.75.2014.05.14.09.17.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 14 May 2014 09:17:05 -0700 (PDT)
Date: Wed, 14 May 2014 19:16:44 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] mm: fix some indenting in cmpxchg_double_slab()
Message-ID: <20140514161644.GF18082@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, kernel-janitors@vger.kernel.org

The return statement goes with the cmpxchg_double() condition so it
needs to be indented another tab.

Also these days the fashion is to line function parameters up, and it
looks nicer that way because then the "freelist_new" is not at the same
indent level as the "return 1;".

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/mm/slub.c b/mm/slub.c
index fdf0fe4..d96faa2 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -382,9 +382,9 @@ static inline bool __cmpxchg_double_slab(struct kmem_cache *s, struct page *page
     defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
 	if (s->flags & __CMPXCHG_DOUBLE) {
 		if (cmpxchg_double(&page->freelist, &page->counters,
-			freelist_old, counters_old,
-			freelist_new, counters_new))
-		return 1;
+				   freelist_old, counters_old,
+				   freelist_new, counters_new))
+			return 1;
 	} else
 #endif
 	{
@@ -418,9 +418,9 @@ static inline bool cmpxchg_double_slab(struct kmem_cache *s, struct page *page,
     defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
 	if (s->flags & __CMPXCHG_DOUBLE) {
 		if (cmpxchg_double(&page->freelist, &page->counters,
-			freelist_old, counters_old,
-			freelist_new, counters_new))
-		return 1;
+				   freelist_old, counters_old,
+				   freelist_new, counters_new))
+			return 1;
 	} else
 #endif
 	{

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
