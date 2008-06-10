Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5AM122u024326
	for <linux-mm@kvack.org>; Tue, 10 Jun 2008 18:01:02 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5AM12gt231230
	for <linux-mm@kvack.org>; Tue, 10 Jun 2008 18:01:02 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5AM125w005800
	for <linux-mm@kvack.org>; Tue, 10 Jun 2008 18:01:02 -0400
Date: Tue, 10 Jun 2008 18:01:01 -0400
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Message-Id: <20080610220101.10257.57966.sendpatchset@norville.austin.ibm.com>
In-Reply-To: <20080610220055.10257.84465.sendpatchset@norville.austin.ibm.com>
References: <20080610220055.10257.84465.sendpatchset@norville.austin.ibm.com>
Subject: [RFC:PATCH 01/06] powerpc: hash_huge_page() should get the WIMG bits from the lpte
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linuxppc-dev list <Linuxppc-dev@ozlabs.org>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Signed-off-by: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
---

 arch/powerpc/mm/hugetlbpage.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff -Nurp linux000/arch/powerpc/mm/hugetlbpage.c linux001/arch/powerpc/mm/hugetlbpage.c
--- linux000/arch/powerpc/mm/hugetlbpage.c	2008-04-16 21:49:44.000000000 -0500
+++ linux001/arch/powerpc/mm/hugetlbpage.c	2008-06-10 16:48:59.000000000 -0500
@@ -502,9 +502,8 @@ repeat:
 		new_pte = (new_pte & ~_PAGE_HPTEFLAGS) | _PAGE_HASHPTE;
 
 		/* Add in WIMG bits */
-		/* XXX We should store these in the pte */
-		/* --BenH: I think they are ... */
-		rflags |= _PAGE_COHERENT;
+		rflags |= (new_pte & (_PAGE_WRITETHRU | _PAGE_NO_CACHE |
+				      _PAGE_COHERENT | _PAGE_GUARDED));
 
 		/* Insert into the hash table, primary slot */
 		slot = ppc_md.hpte_insert(hpte_group, va, pa, rflags, 0,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
