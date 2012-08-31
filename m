Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id C47E36B006C
	for <linux-mm@kvack.org>; Fri, 31 Aug 2012 10:10:54 -0400 (EDT)
Received: by bkcjc3 with SMTP id jc3so1594791bkc.14
        for <linux-mm@kvack.org>; Fri, 31 Aug 2012 07:10:53 -0700 (PDT)
Message-ID: <5040C461.4030409@gmail.com>
Date: Fri, 31 Aug 2012 16:04:17 +0200
From: Marco Stornelli <marco.stornelli@gmail.com>
MIME-Version: 1.0
Subject: [PATCH 21/21] mm: drop vmtruncate
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux FS Devel <linux-fsdevel@vger.kernel.org>
Cc: Guenter Roeck <linux@roeck-us.net>, Luca Tettamanti <kronos.it@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Removed vmtruncate.

Signed-off-by: Marco Stornelli <marco.stornelli@gmail.com>
---
 include/linux/mm.h |    1 -
 mm/truncate.c      |   23 -----------------------
 2 files changed, 0 insertions(+), 24 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 311be90..7eebde6 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -975,7 +975,6 @@ static inline void unmap_shared_mapping_range(struct address_space *mapping,
 
 extern void truncate_pagecache(struct inode *inode, loff_t old, loff_t new);
 extern void truncate_setsize(struct inode *inode, loff_t newsize);
-extern int vmtruncate(struct inode *inode, loff_t offset);
 void truncate_pagecache_range(struct inode *inode, loff_t offset, loff_t end);
 int truncate_inode_page(struct address_space *mapping, struct page *page);
 int generic_error_remove_page(struct address_space *mapping, struct page *page);
diff --git a/mm/truncate.c b/mm/truncate.c
index 75801ac..4e96354 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -580,29 +580,6 @@ void truncate_setsize(struct inode *inode, loff_t newsize)
 EXPORT_SYMBOL(truncate_setsize);
 
 /**
- * vmtruncate - unmap mappings "freed" by truncate() syscall
- * @inode: inode of the file used
- * @newsize: file offset to start truncating
- *
- * This function is deprecated and truncate_setsize or truncate_pagecache
- * should be used instead, together with filesystem specific block truncation.
- */
-int vmtruncate(struct inode *inode, loff_t newsize)
-{
-	int error;
-
-	error = inode_newsize_ok(inode, newsize);
-	if (error)
-		return error;
-
-	truncate_setsize(inode, newsize);
-	if (inode->i_op->truncate)
-		inode->i_op->truncate(inode);
-	return 0;
-}
-EXPORT_SYMBOL(vmtruncate);
-
-/**
  * truncate_pagecache_range - unmap and remove pagecache that is hole-punched
  * @inode: inode
  * @lstart: offset of beginning of hole
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
