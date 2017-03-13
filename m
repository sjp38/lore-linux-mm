Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9C7C7280956
	for <linux-mm@kvack.org>; Sun, 12 Mar 2017 20:36:01 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id j5so275756670pfb.3
        for <linux-mm@kvack.org>; Sun, 12 Mar 2017 17:36:01 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 1si9842961pgr.272.2017.03.12.17.36.00
        for <linux-mm@kvack.org>;
        Sun, 12 Mar 2017 17:36:00 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v1 01/10] mm: remove unncessary ret in page_referenced
Date: Mon, 13 Mar 2017 09:35:44 +0900
Message-ID: <1489365353-28205-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1489365353-28205-1-git-send-email-minchan@kernel.org>
References: <1489365353-28205-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@lge.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>

Anyone doesn't use ret variable. Remove it.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/rmap.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 7d24bb9..9dbfa6f 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -807,7 +807,6 @@ int page_referenced(struct page *page,
 		    struct mem_cgroup *memcg,
 		    unsigned long *vm_flags)
 {
-	int ret;
 	int we_locked = 0;
 	struct page_referenced_arg pra = {
 		.mapcount = total_mapcount(page),
@@ -841,7 +840,7 @@ int page_referenced(struct page *page,
 		rwc.invalid_vma = invalid_page_referenced_vma;
 	}
 
-	ret = rmap_walk(page, &rwc);
+	rmap_walk(page, &rwc);
 	*vm_flags = pra.vm_flags;
 
 	if (we_locked)
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
