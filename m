Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id CAA09994
	for <linux-mm@kvack.org>; Sun, 2 Feb 2003 02:57:10 -0800 (PST)
Date: Sun, 2 Feb 2003 02:57:17 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: hugepage patches
Message-Id: <20030202025717.62aff484.akpm@digeo.com>
In-Reply-To: <20030131151501.7273a9bf.akpm@digeo.com>
References: <20030131151501.7273a9bf.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: davem@redhat.com, rohit.seth@intel.com, davidm@napali.hpl.hp.com, anton@samba.org, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

11/4

ia32 hugetlb cleanup

- whitespace

- remove unneeded spinlocking no-op.




 i386/mm/hugetlbpage.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff -puN arch/i386/mm/hugetlbpage.c~hugetlbpage-cleanup arch/i386/mm/hugetlbpage.c
--- 25/arch/i386/mm/hugetlbpage.c~hugetlbpage-cleanup	2003-02-01 22:06:04.000000000 -0800
+++ 25-akpm/arch/i386/mm/hugetlbpage.c	2003-02-01 22:06:25.000000000 -0800
@@ -248,7 +248,9 @@ void huge_page_release(struct page *page
 	free_huge_page(page);
 }
 
-void unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start, unsigned long end)
+void
+unmap_hugepage_range(struct vm_area_struct *vma,
+		unsigned long start, unsigned long end)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long address;
@@ -258,8 +260,6 @@ void unmap_hugepage_range(struct vm_area
 	BUG_ON(start & (HPAGE_SIZE - 1));
 	BUG_ON(end & (HPAGE_SIZE - 1));
 
-	spin_lock(&htlbpage_lock);
-	spin_unlock(&htlbpage_lock);
 	for (address = start; address < end; address += HPAGE_SIZE) {
 		pte = huge_pte_offset(mm, address);
 		if (pte_none(*pte))
@@ -272,7 +272,9 @@ void unmap_hugepage_range(struct vm_area
 	flush_tlb_range(vma, start, end);
 }
 
-void zap_hugepage_range(struct vm_area_struct *vma, unsigned long start, unsigned long length)
+void
+zap_hugepage_range(struct vm_area_struct *vma,
+		unsigned long start, unsigned long length)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	spin_lock(&mm->page_table_lock);

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
