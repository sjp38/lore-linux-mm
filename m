Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 10F566B0069
	for <linux-mm@kvack.org>; Tue, 30 Sep 2014 18:48:44 -0400 (EDT)
Received: by mail-wg0-f45.google.com with SMTP id m15so3436284wgh.4
        for <linux-mm@kvack.org>; Tue, 30 Sep 2014 15:48:44 -0700 (PDT)
Received: from mail-wg0-x231.google.com (mail-wg0-x231.google.com [2a00:1450:400c:c00::231])
        by mx.google.com with ESMTPS id m13si18262291wiv.32.2014.09.30.15.48.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 30 Sep 2014 15:48:43 -0700 (PDT)
Received: by mail-wg0-f49.google.com with SMTP id x12so3406606wgg.20
        for <linux-mm@kvack.org>; Tue, 30 Sep 2014 15:48:43 -0700 (PDT)
From: Paul McQuade <paulmcquad@gmail.com>
Subject: [PATCH] mm: filemap Remove trailing whitespace
Date: Tue, 30 Sep 2014 23:48:29 +0100
Message-Id: <1412117309-20721-1-git-send-email-paulmcquad@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmcquad@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, sasha.levin@oracle.com, kirill.shutemov@linux.intel.com, mgorman@suse.de, riel@redhat.com, hannes@cmpxchg.org, viro@zeniv.linux.org.uk, akpm@linux-foundation.org

Remove 2 trailing whitespace errors

Signed-off-by: Paul McQuade <paulmcquad@gmail.com>
---
 mm/filemap.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 90effcd..30ffd32 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1744,7 +1744,7 @@ EXPORT_SYMBOL(generic_file_read_iter);
 static int page_cache_read(struct file *file, pgoff_t offset)
 {
 	struct address_space *mapping = file->f_mapping;
-	struct page *page; 
+	struct page *page;
 	int ret;
 
 	do {
@@ -1761,7 +1761,7 @@ static int page_cache_read(struct file *file, pgoff_t offset)
 		page_cache_release(page);
 
 	} while (ret == AOP_TRUNCATED_PAGE);
-		
+
 	return ret;
 }
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
