Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 12 of 13] gfp-repeat stop with TIF_MEMDIE
Message-Id: <74af3b1477511c7bd6a5.1199778643@v2.random>
In-Reply-To: <patchbomb.1199778631@v2.random>
Date: Tue, 08 Jan 2008 08:50:43 +0100
From: Andrea Arcangeli <andrea@cpushare.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User andrea@cpushare.com
# Date 1199692960 -3600
# Node ID 74af3b1477511c7bd6a526b47195ddf95a5424dc
# Parent  ecc696d359edebbfe35566510f78a4be445c8f67
gfp-repeat stop with TIF_MEMDIE

Let the GFP_REPEAT task quit if TIF_MEMDIE is set.

Signed-off-by: Andrea Arcangeli <andrea@suse.de>

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1617,7 +1617,8 @@ nofail_alloc:
 	if (!(gfp_mask & __GFP_NORETRY)) {
 		if ((order <= PAGE_ALLOC_COSTLY_ORDER) ||
 						(gfp_mask & __GFP_REPEAT))
-			do_retry = 1;
+			if (likely(!test_thread_flag(TIF_MEMDIE)))
+				do_retry = 1;
 		if (gfp_mask & __GFP_NOFAIL)
 			do_retry = 1;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
