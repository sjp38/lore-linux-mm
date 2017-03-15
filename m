Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 52EC76B0388
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 01:24:59 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id x127so14817293pgb.4
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 22:24:59 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id e7si696404pfa.53.2017.03.14.22.24.57
        for <linux-mm@kvack.org>;
        Tue, 14 Mar 2017 22:24:58 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 01/10] mm: remove unncessary ret in page_referenced
Date: Wed, 15 Mar 2017 14:24:44 +0900
Message-ID: <1489555493-14659-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1489555493-14659-1-git-send-email-minchan@kernel.org>
References: <1489555493-14659-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@lge.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>

Anyone doesn't use ret variable. Remove it.

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
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
