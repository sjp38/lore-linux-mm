Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 89EE96B0253
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:07:49 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 70so17280869pgf.5
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:07:49 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id u6si14261267pgn.325.2017.11.22.13.07.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 13:07:48 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 08/62] Explicitly include radix-tree.h
Date: Wed, 22 Nov 2017 13:06:45 -0800
Message-Id: <20171122210739.29916-9-willy@infradead.org>
In-Reply-To: <20171122210739.29916-1-willy@infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

These three files use the radix tree, but rely on an implicit include
of radix-tree.h through fs.h.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 drivers/usb/host/xhci.h | 1 +
 include/linux/fscache.h | 1 +
 lib/dma-debug.c         | 1 +
 3 files changed, 3 insertions(+)

diff --git a/drivers/usb/host/xhci.h b/drivers/usb/host/xhci.h
index 99a014a920d3..054ce74524af 100644
--- a/drivers/usb/host/xhci.h
+++ b/drivers/usb/host/xhci.h
@@ -15,6 +15,7 @@
 #include <linux/usb.h>
 #include <linux/timer.h>
 #include <linux/kernel.h>
+#include <linux/radix-tree.h>
 #include <linux/usb/hcd.h>
 #include <linux/io-64-nonatomic-lo-hi.h>
 
diff --git a/include/linux/fscache.h b/include/linux/fscache.h
index f4ff47d4a893..6a2f631a913f 100644
--- a/include/linux/fscache.h
+++ b/include/linux/fscache.h
@@ -22,6 +22,7 @@
 #include <linux/list.h>
 #include <linux/pagemap.h>
 #include <linux/pagevec.h>
+#include <linux/radix-tree.h>
 
 #if defined(CONFIG_FSCACHE) || defined(CONFIG_FSCACHE_MODULE)
 #define fscache_available() (1)
diff --git a/lib/dma-debug.c b/lib/dma-debug.c
index 1b34d210452c..fb4af570ce04 100644
--- a/lib/dma-debug.c
+++ b/lib/dma-debug.c
@@ -22,6 +22,7 @@
 #include <linux/dma-mapping.h>
 #include <linux/sched/task.h>
 #include <linux/stacktrace.h>
+#include <linux/radix-tree.h>
 #include <linux/dma-debug.h>
 #include <linux/spinlock.h>
 #include <linux/vmalloc.h>
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
