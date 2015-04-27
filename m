Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 0459F6B006E
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 03:33:18 -0400 (EDT)
Received: by igblo3 with SMTP id lo3so55342810igb.1
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 00:33:17 -0700 (PDT)
Received: from mail-ie0-x229.google.com (mail-ie0-x229.google.com. [2607:f8b0:4001:c03::229])
        by mx.google.com with ESMTPS id o3si15423789icv.34.2015.04.27.00.33.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Apr 2015 00:33:17 -0700 (PDT)
Received: by iejt8 with SMTP id t8so120259073iej.2
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 00:33:17 -0700 (PDT)
From: Derek Robson <robsonde@gmail.com>
Subject: [PATCH] mm: fixed whitespace style errors in failslab.c
Date: Mon, 27 Apr 2015 19:33:13 +1200
Message-Id: <1430119993-7358-1-git-send-email-robsonde@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Derek Robson <robsonde@gmail.com>

This patch fixes a white space issue found with checkpatch.pl in failslab.c
ERROR: code indent should use tabs where possible

Added a tab to replace the spaces to meet the preferred style.

Signed-off-by: Derek Robson <robsonde@gmail.com>
---
 mm/failslab.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/failslab.c b/mm/failslab.c
index fefaaba..2064225 100644
--- a/mm/failslab.c
+++ b/mm/failslab.c
@@ -16,7 +16,7 @@ bool should_failslab(size_t size, gfp_t gfpflags, unsigned long cache_flags)
 	if (gfpflags & __GFP_NOFAIL)
 		return false;
 
-        if (failslab.ignore_gfp_wait && (gfpflags & __GFP_WAIT))
+	if (failslab.ignore_gfp_wait && (gfpflags & __GFP_WAIT))
 		return false;
 
 	if (failslab.cache_filter && !(cache_flags & SLAB_FAILSLAB))
-- 
2.3.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
