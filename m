Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 637A06B0087
	for <linux-mm@kvack.org>; Tue, 13 May 2014 01:25:49 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id rr13so558935pbb.39
        for <linux-mm@kvack.org>; Mon, 12 May 2014 22:25:49 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id vr7si12120366pab.117.2014.05.12.22.25.47
        for <linux-mm@kvack.org>;
        Mon, 12 May 2014 22:25:48 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 2/2] zsmalloc: make zsmalloc module-buildable
Date: Tue, 13 May 2014 14:28:07 +0900
Message-Id: <1399958887-8432-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1399958887-8432-1-git-send-email-minchan@kernel.org>
References: <1399958887-8432-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-mm@kvack.org, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>

Now, we can build zsmalloc as module because unmap_kernel_range
was exported.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index 30cb6cb008f5..709a77a0fb55 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -558,7 +558,7 @@ config MEM_SOFT_DIRTY
 	  See Documentation/vm/soft-dirty.txt for more details.
 
 config ZSMALLOC
-	bool "Memory allocator for compressed pages"
+	tristate "Memory allocator for compressed pages"
 	depends on MMU
 	default n
 	help
-- 
1.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
