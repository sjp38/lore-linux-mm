Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 353546B0035
	for <linux-mm@kvack.org>; Fri, 29 Aug 2014 21:48:44 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fb1so7597210pad.41
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 18:48:43 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id wq6si2548340pac.179.2014.08.29.18.48.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Aug 2014 18:48:40 -0700 (PDT)
Message-ID: <54012D74.7010302@infradead.org>
Date: Fri, 29 Aug 2014 18:48:36 -0700
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: [PATCH -mmotm] mm: fix kmemcheck.c build errors
References: <5400fba1.732YclygYZprDXeI%akpm@linux-foundation.org>
In-Reply-To: <5400fba1.732YclygYZprDXeI%akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, Pekka Enberg <penberg@kernel.org>, Vegard Nossum <vegardno@ifi.uio.no>

From: Randy Dunlap <rdunlap@infradead.org>

Add header file to fix kmemcheck.c build errors:

../mm/kmemcheck.c:70:7: error: dereferencing pointer to incomplete type
../mm/kmemcheck.c:83:15: error: dereferencing pointer to incomplete type
../mm/kmemcheck.c:95:8: error: dereferencing pointer to incomplete type
../mm/kmemcheck.c:95:21: error: dereferencing pointer to incomplete type

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
---
 mm/kmemcheck.c |    1 +
 1 file changed, 1 insertion(+)

Index: mmotm-2014-0829-1515/mm/kmemcheck.c
===================================================================
--- mmotm-2014-0829-1515.orig/mm/kmemcheck.c
+++ mmotm-2014-0829-1515/mm/kmemcheck.c
@@ -2,6 +2,7 @@
 #include <linux/mm_types.h>
 #include <linux/mm.h>
 #include <linux/slab.h>
+#include <linux/slab_def.h>
 #include <linux/kmemcheck.h>
 
 void kmemcheck_alloc_shadow(struct page *page, int order, gfp_t flags, int node)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
