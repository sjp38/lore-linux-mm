Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id CFEAB6B0033
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 16:22:12 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id q124so21762967wmg.2
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 13:22:12 -0800 (PST)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id u96si2369971wrc.316.2017.02.06.13.22.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Feb 2017 13:22:11 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 599561C2398
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 21:22:11 +0000 (GMT)
Date: Mon, 6 Feb 2017 21:22:10 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH] mm, page_alloc: use static global work_struct for draining
 per-cpu pages -fix
Message-ID: <20170206212210.s5ylsuidbpr44hkd@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

Remove obsolete comment. This is a fix for the mmotm patch
mm-page_alloc-use-static-global-work_struct-for-draining-per-cpu-pages.patch

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index aaa814fb8d3a..3b93879990fd 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2377,10 +2377,6 @@ void drain_all_pages(struct zone *zone)
 		mutex_lock(&pcpu_drain_mutex);
 	}
 
-	/*
-	 * As this can be called from reclaim context, do not reenter reclaim.
-	 * An allocation failure can be handled, it's simply slower
-	 */
 	get_online_cpus();
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
