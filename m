Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 61B3E6B0099
	for <linux-mm@kvack.org>; Wed,  6 Jun 2012 06:54:36 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id wd18so13312502obb.14
        for <linux-mm@kvack.org>; Wed, 06 Jun 2012 03:54:36 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH 09/11] mm: frontswap: remove unused variable in init
Date: Wed,  6 Jun 2012 12:55:13 +0200
Message-Id: <1338980115-2394-9-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1338980115-2394-1-git-send-email-levinsasha928@gmail.com>
References: <1338980115-2394-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: konrad.wilk@oracle.com, dan.magenheimer@oracle.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 mm/frontswap.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/mm/frontswap.c b/mm/frontswap.c
index b98df99..c0cd8bc 100644
--- a/mm/frontswap.c
+++ b/mm/frontswap.c
@@ -321,8 +321,6 @@ EXPORT_SYMBOL(frontswap_curr_pages);
 
 static int __init init_frontswap(void)
 {
-	int err = 0;
-
 #ifdef CONFIG_DEBUG_FS
 	struct dentry *root = debugfs_create_dir("frontswap", NULL);
 	if (root == NULL)
@@ -334,7 +332,7 @@ static int __init init_frontswap(void)
 	debugfs_create_u64("invalidates", S_IRUGO,
 				root, &frontswap_invalidates);
 #endif
-	return err;
+	return 0;
 }
 
 module_init(init_frontswap);
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
