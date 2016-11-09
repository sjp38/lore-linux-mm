Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 925656B0038
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 04:31:52 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id r68so98816909wmd.0
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 01:31:52 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.135])
        by mx.google.com with ESMTPS id g142si21372426wmd.9.2016.11.09.01.31.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Nov 2016 01:31:51 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] mm/hugetlb.c: mark alloc_gigantic_page stub inline
Date: Wed,  9 Nov 2016 10:24:10 +0100
Message-Id: <20161109092559.1407520-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Huang Shijie <shijie.huang@arm.com>, Steve Capper <steve.capper@arm.com>, Arnd Bergmann <arnd@arndb.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.com>, Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

A cleanup patch introduced a new stub helper function but
accidentally did not mark that 'inline' as all the other
stubs are here, and this causes a warning when it is
not used:

mm/hugetlb.c:1166:21: error: 'alloc_gigantic_page' defined but not used [-Werror=unused-function]

Fixes: akpm-current ("mm/hugetlb.c: rename some allocation functions")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 mm/hugetlb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 67faaca8c097..cb9e995affce 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1163,7 +1163,7 @@ static inline void destroy_compound_gigantic_page(struct page *page,
 						unsigned int order) { }
 static inline int alloc_fresh_gigantic_page(struct hstate *h,
 					nodemask_t *nodes_allowed) { return 0; }
-static struct page *alloc_gigantic_page(int nid, unsigned int order)
+static inline struct page *alloc_gigantic_page(int nid, unsigned int order)
 {
 	return NULL;
 }
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
