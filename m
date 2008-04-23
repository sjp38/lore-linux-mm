Message-Id: <20080423015429.726163000@nick.local0.net>
References: <20080423015302.745723000@nick.local0.net>
Date: Wed, 23 Apr 2008 11:53:03 +1000
From: npiggin@suse.de
Subject: [patch 01/18] hugetlb: fix lockdep spew
Content-Disposition: inline; filename=hugetlb-copy-lockdep.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.orgakpm@linux-foundation.org
Cc: linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, nacc@us.ibm.com, abh@cray.com, wli@holomorphy.comlinux-mm@kvack.organdi@firstfloor.orgkniht@linux.vnet.ibm.comnacc@us.ibm.comabh@cray.comwli@holomorphy.com
List-ID: <linux-mm.kvack.org>

---
 mm/hugetlb.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c
+++ linux-2.6/mm/hugetlb.c
@@ -761,7 +761,7 @@ int copy_hugetlb_page_range(struct mm_st
 			continue;
 
 		spin_lock(&dst->page_table_lock);
-		spin_lock(&src->page_table_lock);
+		spin_lock_nested(&src->page_table_lock, SINGLE_DEPTH_NESTING);
 		if (!pte_none(*src_pte)) {
 			if (cow)
 				ptep_set_wrprotect(src, addr, src_pte);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
