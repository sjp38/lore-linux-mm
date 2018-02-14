Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B123F6B0006
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 15:11:59 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id r1so2336887pgp.2
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 12:11:59 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q11si118597pgp.400.2018.02.14.12.11.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Feb 2018 12:11:58 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v2 1/8] mm: Add kernel-doc for kvfree
Date: Wed, 14 Feb 2018 12:11:47 -0800
Message-Id: <20180214201154.10186-2-willy@infradead.org>
In-Reply-To: <20180214201154.10186-1-willy@infradead.org>
References: <20180214201154.10186-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Joe Perches <joe@perches.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 mm/util.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/mm/util.c b/mm/util.c
index c1250501364f..dc4c7b551aaf 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -430,6 +430,16 @@ void *kvmalloc_node(size_t size, gfp_t flags, int node)
 }
 EXPORT_SYMBOL(kvmalloc_node);
 
+/**
+ * kvfree() - Free memory.
+ * @addr: Pointer to allocated memory.
+ *
+ * kvfree frees memory allocated by any of vmalloc(), kmalloc() or
+ * kvmalloc().  It is slightly more efficient to use kfree() or vfree()
+ * if you are certain that you know which one to use.
+ *
+ * Context: Any context except NMI.
+ */
 void kvfree(const void *addr)
 {
 	if (is_vmalloc_addr(addr))
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
