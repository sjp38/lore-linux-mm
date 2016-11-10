Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1A480280253
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 11:36:48 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id i88so101222473pfk.3
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 08:36:48 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id d85si5748498pfb.163.2016.11.10.08.36.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Nov 2016 08:36:47 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] filemap: add comment for confusing logic in page_cache_tree_insert()
Date: Thu, 10 Nov 2016 19:36:40 +0300
Message-Id: <20161110163640.126124-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>

Unlike THP, hugetlb pages represented by one entry on radix-tree.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>
---
 mm/filemap.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 849f459ad078..7602e8fabf5e 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -169,7 +169,10 @@ static int page_cache_tree_insert(struct address_space *mapping,
 static void page_cache_tree_delete(struct address_space *mapping,
 				   struct page *page, void *shadow)
 {
-	int i, nr = PageHuge(page) ? 1 : hpage_nr_pages(page);
+	int i, nr;
+
+	/* hugetlb pages represented by one entry on radix-tree */
+	nr = PageHuge(page) ? 1 : hpage_nr_pages(page);
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(PageTail(page), page);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
