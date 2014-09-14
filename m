Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id EDC8F6B0035
	for <linux-mm@kvack.org>; Sun, 14 Sep 2014 03:58:15 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id kx10so4305116pab.38
        for <linux-mm@kvack.org>; Sun, 14 Sep 2014 00:58:15 -0700 (PDT)
Received: from mail-pd0-x232.google.com (mail-pd0-x232.google.com [2607:f8b0:400e:c02::232])
        by mx.google.com with ESMTPS id gx11si17015436pbd.107.2014.09.14.00.58.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 14 Sep 2014 00:58:15 -0700 (PDT)
Received: by mail-pd0-f178.google.com with SMTP id p10so4179782pdj.9
        for <linux-mm@kvack.org>; Sun, 14 Sep 2014 00:58:14 -0700 (PDT)
From: Wang Sheng-Hui <shhuiw@gmail.com>
Subject: [PATCH] mm: correct comment for fullness group computation in zsmalloc.c
Date: Sun, 14 Sep 2014 15:57:47 +0800
Message-Id: <1410681467-13891-1-git-send-email-shhuiw@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org
Cc: linux-mm@kvack.org, Wang Sheng-Hui <shhuiw@gmail.com>

The letter 'f' in "n <= N/f" stands for fullness_threshold_frac, not
1/fullness_threshold_frac.

Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
---
 mm/zsmalloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 94f38fa..287a8dc 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -175,7 +175,7 @@ enum fullness_group {
  *	n <= N / f, where
  * n = number of allocated objects
  * N = total number of objects zspage can store
- * f = 1/fullness_threshold_frac
+ * f = fullness_threshold_frac
  *
  * Similarly, we assign zspage to:
  *	ZS_ALMOST_FULL	when n > N / f
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
