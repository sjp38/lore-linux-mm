Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 12B226B0387
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 01:39:31 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id f21so82048794pgi.4
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 22:39:31 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 1si5817215pgt.210.2017.03.01.22.39.29
        for <linux-mm@kvack.org>;
        Wed, 01 Mar 2017 22:39:30 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 01/11] mm: use SWAP_SUCCESS instead of 0
Date: Thu,  2 Mar 2017 15:39:15 +0900
Message-Id: <1488436765-32350-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1488436765-32350-1-git-send-email-minchan@kernel.org>
References: <1488436765-32350-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>, "Kirill A . Shutemov" <kirill@shutemov.name>

SWAP_SUCCESS defined value 0 can be changed always so don't rely on
it. Instead, use explict macro.

Cc: Kirill A. Shutemov <kirill@shutemov.name>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/huge_memory.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 092cc5c..fe2ccd4 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2114,7 +2114,7 @@ static void freeze_page(struct page *page)
 		ttu_flags |= TTU_MIGRATION;
 
 	ret = try_to_unmap(page, ttu_flags);
-	VM_BUG_ON_PAGE(ret, page);
+	VM_BUG_ON_PAGE(ret != SWAP_SUCCESS, page);
 }
 
 static void unfreeze_page(struct page *page)
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
