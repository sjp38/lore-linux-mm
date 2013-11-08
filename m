Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id AA0E86B0200
	for <linux-mm@kvack.org>; Fri,  8 Nov 2013 18:43:17 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id lf10so2871815pab.6
        for <linux-mm@kvack.org>; Fri, 08 Nov 2013 15:43:17 -0800 (PST)
Received: from psmtp.com ([74.125.245.155])
        by mx.google.com with SMTP id do4si902622pbc.17.2013.11.08.15.43.09
        for <linux-mm@kvack.org>;
        Fri, 08 Nov 2013 15:43:10 -0800 (PST)
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: [PATCH 03/24] mm/bootmem: remove duplicated declaration of __free_pages_bootmem()
Date: Fri, 8 Nov 2013 18:41:39 -0500
Message-ID: <1383954120-24368-4-git-send-email-santosh.shilimkar@ti.com>
In-Reply-To: <1383954120-24368-1-git-send-email-santosh.shilimkar@ti.com>
References: <1383954120-24368-1-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Grygorii Strashko <grygorii.strashko@ti.com>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Santosh Shilimkar <santosh.shilimkar@ti.com>

From: Grygorii Strashko <grygorii.strashko@ti.com>

The __free_pages_bootmem is used internally by MM core and
already defined in internal.h. So, remove duplicated declaration.

Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
---
 include/linux/bootmem.h |    1 -
 1 file changed, 1 deletion(-)

diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
index f1f07d3..55d52fb 100644
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -52,7 +52,6 @@ extern void free_bootmem_node(pg_data_t *pgdat,
 			      unsigned long size);
 extern void free_bootmem(unsigned long physaddr, unsigned long size);
 extern void free_bootmem_late(unsigned long physaddr, unsigned long size);
-extern void __free_pages_bootmem(struct page *page, unsigned int order);
 
 /*
  * Flags for reserve_bootmem (also if CONFIG_HAVE_ARCH_BOOTMEM_NODE,
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
