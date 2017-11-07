Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id E51746B0297
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 04:06:38 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id c21so7407044wrg.16
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 01:06:38 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 92si738808edn.391.2017.11.07.01.06.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Nov 2017 01:06:37 -0800 (PST)
Date: Tue, 7 Nov 2017 10:06:35 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, sparse: do not swamp log with huge vmemmap
 allocation failures
Message-ID: <20171107090635.c27thtse2lchjgvb@dhcp22.suse.cz>
References: <20171106092228.31098-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171106092228.31098-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Dohh, forgot to git add the follow up fix on top of Johannes' original
diff so it didn't make it into the finall commit. Could you fold this
into the patch Andrew, please?

Sorry about that.
---
diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index 3f85084cb8bb..9a745e2a6f9a 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -62,7 +62,7 @@ void * __meminit vmemmap_alloc_block(unsigned long size, int node)
 			return page_address(page);
 
 		if (!warned) {
-			warn_alloc(gfp_mask, NULL, "vmemmap alloc failure: order:%u", order);
+			warn_alloc(gfp_mask & ~__GFP_NOWARN, NULL, "vmemmap alloc failure: order:%u", order);
 			warned = true;
 		}
 		return NULL;
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
