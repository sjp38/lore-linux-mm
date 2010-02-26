Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D6B656B009E
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 15:09:25 -0500 (EST)
Message-Id: <20100226200859.883128265@redhat.com>
Date: Fri, 26 Feb 2010 21:04:40 +0100
From: aarcange@redhat.com
Subject: [patch 07/35] add native_set_pmd_at
References: <20100226200433.516502198@redhat.com>
Content-Disposition: inline; filename=native_set_pmd_at
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Used by paravirt and not paravirt set_pmd_at.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
---
 arch/x86/include/asm/pgtable.h |    6 ++++++
 1 file changed, 6 insertions(+)

--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -528,6 +528,12 @@ static inline void native_set_pte_at(str
 	native_set_pte(ptep, pte);
 }
 
+static inline void native_set_pmd_at(struct mm_struct *mm, unsigned long addr,
+				     pmd_t *pmdp , pmd_t pmd)
+{
+	native_set_pmd(pmdp, pmd);
+}
+
 #ifndef CONFIG_PARAVIRT
 /*
  * Rules for using pte_update - it must be called after any PTE update which

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
