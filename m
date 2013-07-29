Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 394516B0033
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 01:28:26 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v3 2/9] mm, hugetlb: trivial commenting fix
Date: Mon, 29 Jul 2013 14:28:14 +0900
Message-Id: <1375075701-5998-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1375075701-5998-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1375075701-5998-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

The name of the mutex written in comment is wrong.
Fix it.

Acked-by: Michal Hocko <mhocko@suse.cz>
Acked-by: Hillf Danton <dhillf@gmail.com>
Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index fc4988c..51564a8 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -135,9 +135,9 @@ static inline struct hugepage_subpool *subpool_vma(struct vm_area_struct *vma)
  *                    across the pages in a mapping.
  *
  * The region data structures are protected by a combination of the mmap_sem
- * and the hugetlb_instantion_mutex.  To access or modify a region the caller
+ * and the hugetlb_instantiation_mutex.  To access or modify a region the caller
  * must either hold the mmap_sem for write, or the mmap_sem for read and
- * the hugetlb_instantiation mutex:
+ * the hugetlb_instantiation_mutex:
  *
  *	down_write(&mm->mmap_sem);
  * or
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
