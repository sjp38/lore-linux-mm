Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 5D6A66B003B
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 01:11:42 -0500 (EST)
Received: by mail-pd0-f170.google.com with SMTP id g10so6401089pdj.1
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 22:11:42 -0800 (PST)
Received: from LGEAMRELO02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id ek3si10827702pbd.295.2013.12.16.22.11.39
        for <linux-mm@kvack.org>;
        Mon, 16 Dec 2013 22:11:40 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 3/5] zsmalloc: add copyright
Date: Tue, 17 Dec 2013 15:12:01 +0900
Message-Id: <1387260723-15817-4-git-send-email-minchan@kernel.org>
In-Reply-To: <1387260723-15817-1-git-send-email-minchan@kernel.org>
References: <1387260723-15817-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nitin Gupta <ngupta@vflare.org>, linux-kernel@vger.kernel.org, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>

Add my copyright to the zsmalloc source code which I maintain.

Cc: Nitin Gupta <ngupta@vflare.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/zsmalloc.h |    1 +
 mm/zsmalloc.c            |    1 +
 2 files changed, 2 insertions(+)

diff --git a/include/linux/zsmalloc.h b/include/linux/zsmalloc.h
index c2eb174b97ee..e44d634e7fb7 100644
--- a/include/linux/zsmalloc.h
+++ b/include/linux/zsmalloc.h
@@ -2,6 +2,7 @@
  * zsmalloc memory allocator
  *
  * Copyright (C) 2011  Nitin Gupta
+ * Copyright (C) 2012, 2013 Minchan Kim
  *
  * This code is released using a dual license strategy: BSD/GPL
  * You can choose the license that better fits your requirements.
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 0202716ff6c2..faa6fd801110 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -2,6 +2,7 @@
  * zsmalloc memory allocator
  *
  * Copyright (C) 2011  Nitin Gupta
+ * Copyright (C) 2012, 2013 Minchan Kim
  *
  * This code is released using a dual license strategy: BSD/GPL
  * You can choose the license that better fits your requirements.
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
