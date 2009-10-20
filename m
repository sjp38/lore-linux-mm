Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BCA596B004F
	for <linux-mm@kvack.org>; Tue, 20 Oct 2009 03:19:38 -0400 (EDT)
Received: by pzk27 with SMTP id 27so1852788pzk.12
        for <linux-mm@kvack.org>; Tue, 20 Oct 2009 00:19:37 -0700 (PDT)
From: Huang Shijie <shijie8@gmail.com>
Subject: [PATCH] rmap : move the `out` to a more proper place
Date: Tue, 20 Oct 2009 15:14:19 +0800
Message-Id: <1256022859-23849-1-git-send-email-shijie8@gmail.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: hugh.dickins@tiscali.co.uk, fengguang.wu@intel.com, linux-mm@kvack.org, Huang Shijie <shijie8@gmail.com>
List-ID: <linux-mm.kvack.org>

When the code jumps to the `out' ,the referenced is still zero.
So there is no need to check it.

Signed-off-by: Huang Shijie <shijie8@gmail.com>
---
 mm/rmap.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index dd43373..fe99069 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -388,9 +388,10 @@ static int page_referenced_one(struct page *page,
 out_unmap:
 	(*mapcount)--;
 	pte_unmap_unlock(pte, ptl);
-out:
+
 	if (referenced)
 		*vm_flags |= vma->vm_flags;
+out:
 	return referenced;
 }
 
-- 
1.6.0.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
