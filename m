Date: Thu, 12 Jun 2008 02:45:11 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 12/21] hugetlb: introduce pud_huge
Message-ID: <20080612004510.GA29611@wotan.suse.de>
References: <20080604112939.789444496@amd.local0.net> <20080604113112.524988294@amd.local0.net> <20080611161622.aa650b88.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080611161622.aa650b88.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 11, 2008 at 04:16:22PM -0700, Andrew Morton wrote:
> On Wed, 04 Jun 2008 21:29:51 +1000
> npiggin@suse.de wrote:
> 
> > Straight forward extensions for huge pages located in the PUD
> > instead of PMDs.
> 
> s390:
> 
> mm/built-in.o: In function `follow_page':
> : undefined reference to `pud_huge'
> mm/built-in.o: In function `apply_to_page_range':
> : undefined reference to `pud_huge'

Oh, I should have grepped... here:

---
Index: linux-2.6/arch/s390/mm/hugetlbpage.c
===================================================================
--- linux-2.6.orig/arch/s390/mm/hugetlbpage.c	2008-06-12 10:39:10.000000000 +1000
+++ linux-2.6/arch/s390/mm/hugetlbpage.c	2008-06-12 10:39:24.000000000 +1000
@@ -120,6 +120,11 @@ int pmd_huge(pmd_t pmd)
 	return !!(pmd_val(pmd) & _SEGMENT_ENTRY_LARGE);
 }
 
+int pud_huge(pud_t pud)
+{
+	return 0;
+}
+
 struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
 			     pmd_t *pmdp, int write)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
