Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id CF2616B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 05:42:29 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id t88so4180084pfg.17
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 02:42:29 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o23sor5314864pll.46.2017.12.19.02.42.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Dec 2017 02:42:28 -0800 (PST)
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: [PATCH] zsmalloc: add fs.h include
Date: Tue, 19 Dec 2017 19:42:19 +0900
Message-Id: <20171219104219.3017-1-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

`struct file_system_type' and alloc_anon_inode() function are
defined in fs.h, include it directly.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 mm/zsmalloc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 685049a9048d..683c0651098c 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -53,6 +53,7 @@
 #include <linux/mount.h>
 #include <linux/migrate.h>
 #include <linux/pagemap.h>
+#include <linux/fs.h>
 
 #define ZSPAGE_MAGIC	0x58
 
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
