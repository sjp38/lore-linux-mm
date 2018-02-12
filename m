Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id B82536B0266
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 11:46:23 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id f16so136804qth.20
        for <linux-mm@kvack.org>; Mon, 12 Feb 2018 08:46:23 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id r9si3664960qta.96.2018.02.12.08.46.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Feb 2018 08:46:14 -0800 (PST)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: mm-initialize-pages-on-demand-during-boot-fix2
Date: Mon, 12 Feb 2018 11:45:43 -0500
Message-Id: <20180212164543.26592-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, pasha.tatashin@oracle.com, m.mizuma@jp.fujitsu.com, akpm@linux-foundation.org, mhocko@suse.com, catalin.marinas@arm.com, takahiro.akashi@linaro.org, gi-oh.kim@profitbricks.com, heiko.carstens@de.ibm.com, baiyaowei@cmss.chinamobile.com, richard.weiyang@gmail.com, paul.burton@mips.com, miles.chen@mediatek.com, vbabka@suse.cz, mgorman@suse.de, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

fixes types mismatch warning reported by kbuild

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
---
 mm/page_alloc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b310a0587c3b..5a45255e3aa0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6354,8 +6354,8 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 	 * We start only with one section of pages, more pages are added as
 	 * needed until the rest of deferred pages are initialized.
 	 */
-	pgdat->static_init_pgcnt = min(PAGES_PER_SECTION,
-				       pgdat->node_spanned_pages);
+	pgdat->static_init_pgcnt = min_t(unsigned long, PAGES_PER_SECTION,
+					 pgdat->node_spanned_pages);
 	pgdat->first_deferred_pfn = ULONG_MAX;
 #endif
 	free_area_init_core(pgdat);
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
