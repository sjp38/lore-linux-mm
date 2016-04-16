Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4D6586B0005
	for <linux-mm@kvack.org>; Sat, 16 Apr 2016 03:21:56 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id d19so82039524lfb.0
        for <linux-mm@kvack.org>; Sat, 16 Apr 2016 00:21:56 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id cq9si9872249wjb.58.2016.04.16.00.21.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 16 Apr 2016 00:21:54 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id EFAE8987B8
	for <linux-mm@kvack.org>; Sat, 16 Apr 2016 07:21:53 +0000 (UTC)
Date: Sat, 16 Apr 2016 08:21:52 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 12/28] mm, page_alloc: Remove unnecessary initialisation from
 __alloc_pages_nodemask()
Message-ID: <20160416072152.GH32073@techsingularity.net>
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

page is guaranteed to be set before it is read with or without the
initialisation.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f5ddb342c967..df03ccc7f07c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3348,7 +3348,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 			struct zonelist *zonelist, nodemask_t *nodemask)
 {
 	struct zoneref *preferred_zoneref;
-	struct page *page = NULL;
+	struct page *page;
 	unsigned int cpuset_mems_cookie;
 	unsigned int alloc_flags = ALLOC_WMARK_LOW|ALLOC_FAIR;
 	gfp_t alloc_mask; /* The gfp_t that was actually used for allocation */
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
