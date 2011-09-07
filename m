Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7A4736B016A
	for <linux-mm@kvack.org>; Wed,  7 Sep 2011 10:12:36 -0400 (EDT)
Received: by gwm11 with SMTP id 11so6832345gwm.30
        for <linux-mm@kvack.org>; Wed, 07 Sep 2011 07:12:34 -0700 (PDT)
From: Wanlong Gao <wanlong.gao@gmail.com>
Subject: [PATCH] ksm: fix the comment of try_to_unmap_one()
Date: Wed,  7 Sep 2011 22:09:58 +0800
Message-Id: <1315404598-3141-1-git-send-email-wanlong.gao@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, hughd@google.com, Wanlong Gao <gaowanlong@cn.fujitsu.com>

From: Wanlong Gao <gaowanlong@cn.fujitsu.com>

try_to_unmap_one() is called by try_to_unmap_ksm(), too.

Signed-off-by: Wanlong Gao <gaowanlong@cn.fujitsu.com>
---
 mm/rmap.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 8005080..6541cf7 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1164,7 +1164,7 @@ void page_remove_rmap(struct page *page)
 
 /*
  * Subfunctions of try_to_unmap: try_to_unmap_one called
- * repeatedly from either try_to_unmap_anon or try_to_unmap_file.
+ * repeatedly from try_to_unmap_ksm, try_to_unmap_anon or try_to_unmap_file.
  */
 int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		     unsigned long address, enum ttu_flags flags)
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
