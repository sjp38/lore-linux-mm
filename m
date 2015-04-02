Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f182.google.com (mail-qc0-f182.google.com [209.85.216.182])
	by kanga.kvack.org (Postfix) with ESMTP id 078166B0038
	for <linux-mm@kvack.org>; Thu,  2 Apr 2015 07:50:02 -0400 (EDT)
Received: by qcay5 with SMTP id y5so64456139qca.1
        for <linux-mm@kvack.org>; Thu, 02 Apr 2015 04:50:01 -0700 (PDT)
Received: from mail-qc0-x22d.google.com (mail-qc0-x22d.google.com. [2607:f8b0:400d:c01::22d])
        by mx.google.com with ESMTPS id r128si4735352qha.44.2015.04.02.04.50.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Apr 2015 04:50:01 -0700 (PDT)
Received: by qcgx3 with SMTP id x3so64738606qcg.3
        for <linux-mm@kvack.org>; Thu, 02 Apr 2015 04:50:01 -0700 (PDT)
From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH] mm, mempool: use '%zu' for printing 'size_t' variable
Date: Thu,  2 Apr 2015 08:49:41 -0300
Message-Id: <1427975381-5044-1-git-send-email-festevam@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: rientjes@google.com, linux-mm@kvack.org, Fabio Estevam <fabio.estevam@freescale.com>

From: Fabio Estevam <fabio.estevam@freescale.com>

Commit 8b65aaa9c53404 ("mm, mempool: poison elements backed by page allocator") 
caused the following build warning on ARM:

mm/mempool.c:31:2: warning: format '%ld' expects argument of type 'long int', but argument 3 has type 'size_t' [-Wformat]

Use '%zu' for printing 'size_t' variable.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 mm/mempool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mempool.c b/mm/mempool.c
index 436628d..5a2f4f0 100644
--- a/mm/mempool.c
+++ b/mm/mempool.c
@@ -28,7 +28,7 @@ static void poison_error(mempool_t *pool, void *element, size_t size,
 	int i;
 
 	pr_err("BUG: mempool element poison mismatch\n");
-	pr_err("Mempool %p size %ld\n", pool, size);
+	pr_err("Mempool %p size %zu\n", pool, size);
 	pr_err(" nr=%d @ %p: %s0x", nr, element, start > 0 ? "... " : "");
 	for (i = start; i < end; i++)
 		pr_cont("%x ", *(u8 *)(element + i));
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
