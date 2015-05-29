Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 7B8456B0075
	for <linux-mm@kvack.org>; Fri, 29 May 2015 11:07:51 -0400 (EDT)
Received: by igbjd9 with SMTP id jd9so16494064igb.1
        for <linux-mm@kvack.org>; Fri, 29 May 2015 08:07:51 -0700 (PDT)
Received: from mail-ie0-x22e.google.com (mail-ie0-x22e.google.com. [2607:f8b0:4001:c03::22e])
        by mx.google.com with ESMTPS id e10si5020669ick.13.2015.05.29.08.07.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 May 2015 08:07:50 -0700 (PDT)
Received: by iebgx4 with SMTP id gx4so64888367ieb.0
        for <linux-mm@kvack.org>; Fri, 29 May 2015 08:07:50 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH] zpool: change pr_info to pr_debug
Date: Fri, 29 May 2015 11:07:13 -0400
Message-Id: <1432912033-16413-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kees Cook <keescook@chromium.org>, Minchan Kim <minchan@kernel.org>, Ganesh Mahendran <opensource.ganesh@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Streetman <ddstreet@ieee.org>

Change the pr_info() calls to pr_debug().  There's no need for the extra
verbosity in the log.  Also change the msg formats to be consistent.

Signed-off-by: Dan Streetman <ddstreet@ieee.org>
---
 mm/zpool.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/zpool.c b/mm/zpool.c
index bacdab6..6b1f103 100644
--- a/mm/zpool.c
+++ b/mm/zpool.c
@@ -147,7 +147,7 @@ struct zpool *zpool_create_pool(char *type, char *name, gfp_t gfp,
 	struct zpool_driver *driver;
 	struct zpool *zpool;
 
-	pr_info("creating pool type %s\n", type);
+	pr_debug("creating pool type %s\n", type);
 
 	driver = zpool_get_driver(type);
 
@@ -180,7 +180,7 @@ struct zpool *zpool_create_pool(char *type, char *name, gfp_t gfp,
 		return NULL;
 	}
 
-	pr_info("created %s pool\n", type);
+	pr_debug("created pool type %s\n", type);
 
 	spin_lock(&pools_lock);
 	list_add(&zpool->list, &pools_head);
@@ -202,7 +202,7 @@ struct zpool *zpool_create_pool(char *type, char *name, gfp_t gfp,
  */
 void zpool_destroy_pool(struct zpool *zpool)
 {
-	pr_info("destroying pool type %s\n", zpool->type);
+	pr_debug("destroying pool type %s\n", zpool->type);
 
 	spin_lock(&pools_lock);
 	list_del(&zpool->list);
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
