Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 9FD556B0005
	for <linux-mm@kvack.org>; Tue, 26 Feb 2013 12:03:39 -0500 (EST)
From: Phillip Susi <psusi@ubuntu.com>
Subject: [PATCH] mm: fix SYNC_FILE_RANGE_WRITE to not block
Date: Tue, 26 Feb 2013 12:03:30 -0500
Message-Id: <1361898210-1980-1-git-send-email-psusi@ubuntu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Phillip Susi <psusi@ubuntu.com>

This mode of sync_file_range isn't supposed to block.

Signed-off-by: Phillip Susi <psusi@ubuntu.com>
---
 mm/filemap.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index c571bae..c5e2036 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -232,7 +232,7 @@ EXPORT_SYMBOL(filemap_fdatawrite);
 int filemap_fdatawrite_range(struct address_space *mapping, loff_t start,
 				loff_t end)
 {
-	return __filemap_fdatawrite_range(mapping, start, end, WB_SYNC_ALL);
+	return __filemap_fdatawrite_range(mapping, start, end, WB_SYNC_NONE);
 }
 EXPORT_SYMBOL(filemap_fdatawrite_range);
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
