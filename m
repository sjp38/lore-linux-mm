Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CEE726B0253
	for <linux-mm@kvack.org>; Thu,  5 May 2016 10:43:08 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 4so171517534pfw.0
        for <linux-mm@kvack.org>; Thu, 05 May 2016 07:43:08 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id us15si11759235pab.53.2016.05.05.07.43.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 May 2016 07:43:04 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] include <asm/sections.h> instead of <asm-generic/sections.h>
Date: Thu,  5 May 2016 16:42:59 +0200
Message-Id: <1462459379-21049-1-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, mhiramat@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

asm-generic headers are generic implementations for architecture specific
code and should not be included by common code.  Thus use the asm/ version
of sections.h to get at the linker sections.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 kernel/kprobes.c       | 2 +-
 kernel/printk/printk.c | 2 +-
 mm/memblock.c          | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/kernel/kprobes.c b/kernel/kprobes.c
index d10ab6b..d630954 100644
--- a/kernel/kprobes.c
+++ b/kernel/kprobes.c
@@ -49,7 +49,7 @@
 #include <linux/cpu.h>
 #include <linux/jump_label.h>
 
-#include <asm-generic/sections.h>
+#include <asm/sections.h>
 #include <asm/cacheflush.h>
 #include <asm/errno.h>
 #include <asm/uaccess.h>
diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
index bfbf284..3a7f696 100644
--- a/kernel/printk/printk.c
+++ b/kernel/printk/printk.c
@@ -48,7 +48,7 @@
 #include <linux/uio.h>
 
 #include <asm/uaccess.h>
-#include <asm-generic/sections.h>
+#include <asm/sections.h>
 
 #define CREATE_TRACE_POINTS
 #include <trace/events/printk.h>
diff --git a/mm/memblock.c b/mm/memblock.c
index b570ddd..7ed1ea1a 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -20,7 +20,7 @@
 #include <linux/seq_file.h>
 #include <linux/memblock.h>
 
-#include <asm-generic/sections.h>
+#include <asm/sections.h>
 #include <linux/io.h>
 
 #include "internal.h"
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
