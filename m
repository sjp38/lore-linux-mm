Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 680916B0038
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:07:49 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id m188so17244943pga.22
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:07:49 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id z29si8360942pfj.340.2017.11.22.13.07.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 13:07:48 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 02/62] radix tree test suite: Remove ARRAY_SIZE
Date: Wed, 22 Nov 2017 13:06:39 -0800
Message-Id: <20171122210739.29916-3-willy@infradead.org>
In-Reply-To: <20171122210739.29916-1-willy@infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

This is now defined in tools/include/linux/kernel.h, so our
definition generates a warning.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 tools/testing/radix-tree/linux/kernel.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/tools/testing/radix-tree/linux/kernel.h b/tools/testing/radix-tree/linux/kernel.h
index c3bc3f364f68..426f32f28547 100644
--- a/tools/testing/radix-tree/linux/kernel.h
+++ b/tools/testing/radix-tree/linux/kernel.h
@@ -17,6 +17,4 @@
 #define pr_debug printk
 #define pr_cont printk
 
-#define ARRAY_SIZE(arr) (sizeof(arr) / sizeof((arr)[0]))
-
 #endif /* _KERNEL_H */
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
