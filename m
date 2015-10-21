Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id DE9E76B0254
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 10:10:17 -0400 (EDT)
Received: by igdg1 with SMTP id g1so87086634igd.1
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 07:10:17 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id p10si7516593igy.75.2015.10.21.07.10.16
        for <linux-mm@kvack.org>;
        Wed, 21 Oct 2015 07:10:17 -0700 (PDT)
Date: Wed, 21 Oct 2015 20:58:56 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [RFC PATCH] mm, hugetlb: __alloc_buddy_huge_page_no_mpol() can be
 static
Message-ID: <20151021125856.GA100518@lkp-hsx03.intel.com>
References: <201510212038.HxPwijWe%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201510212038.HxPwijWe%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 hugetlb.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index c57d671..e1248f9 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1580,7 +1580,7 @@ static struct page *__alloc_buddy_huge_page(struct hstate *h,
  * NUMA_NO_NODE, which means that it may be allocated
  * anywhere.
  */
-struct page *__alloc_buddy_huge_page_no_mpol(struct hstate *h, int nid)
+static struct page *__alloc_buddy_huge_page_no_mpol(struct hstate *h, int nid)
 {
 	unsigned long addr = -1;
 
@@ -1590,7 +1590,7 @@ struct page *__alloc_buddy_huge_page_no_mpol(struct hstate *h, int nid)
 /*
  * Use the VMA's mpolicy to allocate a huge page from the buddy.
  */
-struct page *__alloc_buddy_huge_page_with_mpol(struct hstate *h,
+static struct page *__alloc_buddy_huge_page_with_mpol(struct hstate *h,
 		struct vm_area_struct *vma, unsigned long addr)
 {
 	return __alloc_buddy_huge_page(h, vma, addr, NUMA_NO_NODE);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
