Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 715776B0032
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 15:07:13 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id et14so47860987pad.1
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 12:07:13 -0800 (PST)
Received: from na01-bl2-obe.outbound.protection.outlook.com (mail-bl2on0143.outbound.protection.outlook.com. [65.55.169.143])
        by mx.google.com with ESMTPS id n9si1346817pdo.38.2015.01.20.12.07.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 20 Jan 2015 12:07:12 -0800 (PST)
Date: Tue, 20 Jan 2015 14:01:42 -0600
From: Kim Phillips <kim.phillips@freescale.com>
Subject: [PATCH 1/2] mm/slub: fix typo
Message-ID: <20150120140142.cd2e32d83d66459562bd1717@freescale.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org


Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
---
 mm/slub.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index fe376fe..a64cc1b 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2512,7 +2512,7 @@ EXPORT_SYMBOL(kmem_cache_alloc_node_trace);
 #endif
 
 /*
- * Slow patch handling. This may still be called frequently since objects
+ * Slow path handling. This may still be called frequently since objects
  * have a longer lifetime than the cpu slabs in most processing loads.
  *
  * So we still attempt to reduce cache line usage. Just take the slab
-- 
2.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
