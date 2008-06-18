Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5IMXUwH019065
	for <linux-mm@kvack.org>; Wed, 18 Jun 2008 18:33:30 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5IMXUkq166848
	for <linux-mm@kvack.org>; Wed, 18 Jun 2008 16:33:30 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5IMXTF7018409
	for <linux-mm@kvack.org>; Wed, 18 Jun 2008 16:33:30 -0600
Message-Id: <20080618223329.009886485@linux.vnet.ibm.com>
References: <20080618223254.966080905@linux.vnet.ibm.com>
Date: Wed, 18 Jun 2008 17:32:56 -0500
From: shaggy@linux.vnet.ibm.com
Subject: [patch 2/6] powerpc: hash_huge_page() should get the WIMG bits from the lpte
Content-Disposition: inline; filename=hugetlbpage.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Mackerras <paulus@au1.ibm.com>, linux-mm@kvack.org, Linuxppc-dev@ozlabs.org, Jon Tollefson <kniht@linux.vnet.ibm.com>, Adam Litke <agl@us.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>Jon Tollefson <kniht@linux.vnet.ibm.com>Adam Litke <agl@us.ibm.com>Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

---

 arch/powerpc/mm/hugetlbpage.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

Index: linux-2.6.26-rc5/arch/powerpc/mm/hugetlbpage.c
===================================================================
--- linux-2.6.26-rc5.orig/arch/powerpc/mm/hugetlbpage.c
+++ linux-2.6.26-rc5/arch/powerpc/mm/hugetlbpage.c
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
