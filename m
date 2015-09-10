Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 66C4C6B0038
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 08:30:00 -0400 (EDT)
Received: by padhk3 with SMTP id hk3so42093766pad.3
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 05:30:00 -0700 (PDT)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id op6si19104283pbb.239.2015.09.10.05.29.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Sep 2015 05:29:59 -0700 (PDT)
Received: by padhy16 with SMTP id hy16so42291992pad.1
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 05:29:59 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [RFC][PATCH] mm: make zbud znd zpool to depend on zswap
Date: Thu, 10 Sep 2015 21:28:48 +0900
Message-Id: <1441888128-10897-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjennings@variantweb.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

There are no zbud and zpool users besides zswap so enabling
(and building) CONFIG_ZPOOL and CONFIG_ZBUD make sense only
when CONFIG_ZSWAP is enabled. In other words, make those
options to depend on CONFIG_ZSWAP.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 mm/Kconfig | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/Kconfig b/mm/Kconfig
index 3455a8d..eb48422 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -563,6 +563,7 @@ config ZSWAP
 
 config ZPOOL
 	tristate "Common API for compressed memory storage"
+	depends on ZSWAP
 	default n
 	help
 	  Compressed memory storage API.  This allows using either zbud or
@@ -570,6 +571,7 @@ config ZPOOL
 
 config ZBUD
 	tristate "Low density storage for compressed pages"
+	depends on ZSWAP
 	default n
 	help
 	  A special purpose allocator for storing compressed pages.
-- 
2.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
