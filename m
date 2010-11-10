Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 548246B0088
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 03:48:39 -0500 (EST)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH 2/2] clean up set_page_dirty()
Date: Wed, 10 Nov 2010 17:00:28 +0800
Message-ID: <1289379628-14044-2-git-send-email-lliubbo@gmail.com>
In-Reply-To: <1289379628-14044-1-git-send-email-lliubbo@gmail.com>
References: <1289379628-14044-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: fengguang.wu@intel.com, linux-mm@kvack.org, kenchen@google.com, Bob Liu <lliubbo@gmail.com>
List-ID: <linux-mm.kvack.org>

Use TestSetPageDirty() to clean up set_page_dirty().

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 mm/page-writeback.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index e8f5f06..da86224 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1268,11 +1268,8 @@ int set_page_dirty(struct page *page)
 #endif
 		return (*spd)(page);
 	}
-	if (!PageDirty(page)) {
-		if (!TestSetPageDirty(page))
-			return 1;
-	}
-	return 0;
+
+	return !TestSetPageDirty(page);
 }
 EXPORT_SYMBOL(set_page_dirty);
 
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
