Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id jA9Nchea010487
	for <linux-mm@kvack.org>; Wed, 9 Nov 2005 18:38:43 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id jA9Nchh4087334
	for <linux-mm@kvack.org>; Wed, 9 Nov 2005 18:38:43 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id jA9NcgGJ021972
	for <linux-mm@kvack.org>; Wed, 9 Nov 2005 18:38:43 -0500
Subject: [PATCH 2/4] Hugetlb: Rename find_lock_page to
	find_or_alloc_huge_page
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <1131578925.28383.9.camel@localhost.localdomain>
References: <1131578925.28383.9.camel@localhost.localdomain>
Content-Type: text/plain
Date: Wed, 09 Nov 2005 17:37:52 -0600
Message-Id: <1131579472.28383.20.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Gibson <david@gibson.dropbear.id.au>, wli@holomorphy.com, hugh@veritas.com, rohit.seth@intel.com, kenneth.w.chen@intel.com, "ADAM G. LITKE [imap]" <agl@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2005-10-26 at 12:00 +1000, David Gibson wrote:
- find_lock_huge_page() isn't a great name, since it does extra things
  not analagous to find_lock_page().  Rename it
  find_or_alloc_huge_page() which is closer to the mark.

Original post by David Gibson <david@gibson.dropbear.id.au>

Version 2: Wed 9 Nov 2005
	Split into a separate patch

Signed-off-by: David Gibson <david@gibson.dropbear.id.au>
Signed-off-by: Adam Litke <agl@us.ibm.com>
---
 hugetlb.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)
diff -upN reference/mm/hugetlb.c current/mm/hugetlb.c
--- reference/mm/hugetlb.c
+++ current/mm/hugetlb.c
@@ -339,8 +339,8 @@ void unmap_hugepage_range(struct vm_area
 	flush_tlb_range(vma, start, end);
 }
 
-static struct page *find_lock_huge_page(struct address_space *mapping,
-			unsigned long idx)
+static struct page *find_or_alloc_huge_page(struct address_space *mapping,
+						unsigned long idx)
 {
 	struct page *page;
 	int err;
@@ -392,7 +392,7 @@ int hugetlb_fault(struct mm_struct *mm, 
 	 * Use page lock to guard against racing truncation
 	 * before we get page_table_lock.
 	 */
-	page = find_lock_huge_page(mapping, idx);
+	page = find_or_alloc_huge_page(mapping, idx);
 	if (!page)
 		goto out;
 

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
