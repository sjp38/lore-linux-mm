Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 69BE06B00AE
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 05:20:56 -0400 (EDT)
Received: by yxe36 with SMTP id 36so3075950yxe.11
        for <linux-mm@kvack.org>; Fri, 25 Sep 2009 02:20:57 -0700 (PDT)
From: Huang Shijie <shijie8@gmail.com>
Subject: [PATCH] memory : adjust the ugly comment
Date: Fri, 25 Sep 2009 17:20:51 +0800
Message-Id: <1253870451-4887-1-git-send-email-shijie8@gmail.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Huang Shijie <shijie8@gmail.com>
List-ID: <linux-mm.kvack.org>

The origin comment is too ugly, so modify it more beautiful.

Signed-off-by: Huang Shijie <shijie8@gmail.com>
---
 mm/memory.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 7e91b5f..6a38caa 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2405,7 +2405,10 @@ restart:
 }
 
 /**
- * unmap_mapping_range - unmap the portion of all mmaps in the specified address_space corresponding to the specified page range in the underlying file.
+ * unmap_mapping_range - unmap the portion of all mmaps in the specified
+ *	 		address_space corresponding to the specified page range
+ * 			in the underlying file.
+ *
  * @mapping: the address space containing mmaps to be unmapped.
  * @holebegin: byte in first page to unmap, relative to the start of
  * the underlying file.  This will be rounded down to a PAGE_SIZE
-- 
1.6.0.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
