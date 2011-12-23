Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 8499F6B004D
	for <linux-mm@kvack.org>; Fri, 23 Dec 2011 08:38:40 -0500 (EST)
Received: by werf1 with SMTP id f1so5462327wer.14
        for <linux-mm@kvack.org>; Fri, 23 Dec 2011 05:38:38 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 23 Dec 2011 21:38:38 +0800
Message-ID: <CAJd=RBCS3-PoFa3FUVwhiznPTQH5xq7fTYa3m01a0-buACQbCA@mail.gmail.com>
Subject: [PATCH] mm: hugetlb: avoid bogus counter of surplus huge page
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

From: Hillf Danton <dhillf@gmail.com>
Subject: [PATCH] mm: hugetlb: avoid bogus counter of surplus huge page

If we have to hand back the newly allocated huge page to page allocator,
for any reason, the changed counter should be recovered.

Cc: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Hillf Danton <dhillf@gmail.com>
---

--- a/mm/hugetlb.c	Tue Dec 20 21:26:30 2011
+++ b/mm/hugetlb.c	Fri Dec 23 21:18:06 2011
@@ -800,7 +800,7 @@ static struct page *alloc_buddy_huge_pag

 	if (page && arch_prepare_hugepage(page)) {
 		__free_pages(page, huge_page_order(h));
-		return NULL;
+		page = NULL;
 	}

 	spin_lock(&hugetlb_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
