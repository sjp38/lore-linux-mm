Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 3140C6B005D
	for <linux-mm@kvack.org>; Sat,  3 Nov 2012 05:38:56 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id c4so2745260eek.14
        for <linux-mm@kvack.org>; Sat, 03 Nov 2012 02:38:54 -0700 (PDT)
Message-ID: <5094E4A3.8020409@gmail.com>
Date: Sat, 03 Nov 2012 10:32:19 +0100
From: Marco Stornelli <marco.stornelli@gmail.com>
MIME-Version: 1.0
Subject: [PATCH 20/21] mm: drop vmtruncate
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux FS Devel <linux-fsdevel@vger.kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Removed vmtruncate

Signed-off-by: Marco Stornelli <marco.stornelli@gmail.com>
---
 include/linux/mm.h |    1 -
 mm/truncate.c      |   23 -----------------------
 2 files changed, 0 insertions(+), 24 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index fa06804..95f70bb 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -977,7 +977,6 @@ static inline void unmap_shared_mapping_range(struct address_space *mapping,
 
 extern void truncate_pagecache(struct inode *inode, loff_t old, loff_t new);
 extern void truncate_setsize(struct inode *inode, loff_t newsize);
-extern int vmtruncate(struct inode *inode, loff_t offset);
 void truncate_pagecache_range(struct inode *inode, loff_t offset, loff_t end);
 int truncate_inode_page(struct address_space *mapping, struct page *page);
 int generic_error_remove_page(struct address_space *mapping, struct page *page);
diff --git a/mm/truncate.c b/mm/truncate.c
index d51ce92..c75b736 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -577,29 +577,6 @@ void truncate_setsize(struct inode *inode, loff_t newsize)
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
