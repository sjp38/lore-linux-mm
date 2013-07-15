Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id B22386B00AC
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 05:52:50 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 0/9] mm, hugetlb: clean-up and possible bug fix
Date: Mon, 15 Jul 2013 18:52:38 +0900
Message-Id: <1373881967-16153-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

First 5 patches are almost trivial clean-up patches.

The others are for fixing three bugs.
Perhaps, these problems are minor, because this codes are used
for a long time, and there is no bug reporting for these problems.

These patches are based on v3.10.0 and
passed sanity check of libhugetlbfs.

Thanks.

Joonsoo Kim (9):
  mm, hugetlb: move up the code which check availability of free huge
    page
  mm, hugetlb: trivial commenting fix
  mm, hugetlb: clean-up alloc_huge_page()
  mm, hugetlb: fix and clean-up node iteration code to alloc or free
  mm, hugetlb: remove redundant list_empty check in
    gather_surplus_pages()
  mm, hugetlb: do not use a page in page cache for cow optimization
  mm, hugetlb: add VM_NORESERVE check in vma_has_reserves()
  mm, hugetlb: remove decrement_hugepage_resv_vma()
  mm, hugetlb: decrement reserve count if VM_NORESERVE alloc page cache

 mm/hugetlb.c |  256 +++++++++++++++++++++++++++-------------------------------
 1 file changed, 117 insertions(+), 139 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
