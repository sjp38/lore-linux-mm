Subject: [PATCH] pte_alloc_kernel needs additional check
From: Paul Larson <plars@linuxtestproject.org>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 24 Feb 2003 15:54:39 -0600
Message-Id: <1046123680.13919.67.camel@plars>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

This applies against 2.5.63.
pte_alloc_kernel needs a check for pmd_present(*pmd) at the end.

Thanks,
Paul Larson

--- linux-2.5.63/mm/memory.c	Mon Feb 24 13:05:31 2003
+++ linux-2.5.63-fix/mm/memory.c	Mon Feb 24 15:45:05 2003
@@ -186,7 +186,9 @@
 		pmd_populate_kernel(mm, pmd, new);
 	}
 out:
-	return pte_offset_kernel(pmd, address);
+	if (pmd_present(*pmd))
+		return pte_offset_kernel(pmd, address);
+	return NULL;
 }
 #define PTE_TABLE_MASK	((PTRS_PER_PTE-1) * sizeof(pte_t))
 #define PMD_TABLE_MASK	((PTRS_PER_PMD-1) * sizeof(pmd_t))


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
