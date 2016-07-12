Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 17B416B0253
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 20:58:27 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id q2so2166840pap.1
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 17:58:27 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id cr4si802385pad.76.2016.07.11.17.58.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jul 2016 17:58:26 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] memblock: include <asm/sections.h> instead of <asm-generic/sections.h>
Date: Tue, 12 Jul 2016 09:58:23 +0900
Message-Id: <1468285103-7470-1-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

asm-generic headers are generic implementations for architecture specific
code and should not be included by common code.  Thus use the asm/ version
of sections.h to get at the linker sections.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/memblock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index ac12489..5d700e4 100644
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
