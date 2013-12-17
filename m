Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 66EC06B003D
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 01:11:44 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id lf10so4045109pab.28
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 22:11:44 -0800 (PST)
Received: from LGEAMRELO02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id ek3si10827702pbd.295.2013.12.16.22.11.40
        for <linux-mm@kvack.org>;
        Mon, 16 Dec 2013 22:11:41 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 5/5] zsmalloc: add maintainers
Date: Tue, 17 Dec 2013 15:12:03 +0900
Message-Id: <1387260723-15817-6-git-send-email-minchan@kernel.org>
In-Reply-To: <1387260723-15817-1-git-send-email-minchan@kernel.org>
References: <1387260723-15817-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nitin Gupta <ngupta@vflare.org>, linux-kernel@vger.kernel.org, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>

This patch adds maintainer information for zsmalloc into
the MAINTAINERS file.

Cc: Nitin Gupta <ngupta@vflare.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 MAINTAINERS |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 7b32aa4b5f04..af237d331765 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -9705,6 +9705,14 @@ M:	"Maciej W. Rozycki" <macro@linux-mips.org>
 S:	Maintained
 F:	drivers/tty/serial/zs.*
 
+ZSMALLOC COMPRESSED SLAB MEMORY ALLOCATOR
+M:	Minchan Kim <minchan@kernel.org>
+M:	Nitin Gupta <ngupta@vflare.org>
+L:	linux-mm@kvack.org
+S:	Maintained
+F:	mm/zsmalloc.c
+F:	include/linux/zsmalloc.h
+
 ZSWAP COMPRESSED SWAP CACHING
 M:	Seth Jennings <sjenning@linux.vnet.ibm.com>
 L:	linux-mm@kvack.org
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
