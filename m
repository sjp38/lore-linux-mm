Subject: 
From: vignesh babu <vignesh.babu@wipro.com>
Reply-To: vignesh.babu@wipro.com
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Thu, 07 Jun 2007 15:15:23 +0530
Message-Id: <1181209523.10486.1.camel@merlin.linuxcoe.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: tony.luck@intel.com, rohit.seth@intel.com, kenneth.w.chen@intel.com
Cc: linux-ia64@vger.kernel.org, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Kernel Janitors List <kernel-janitors@lists.osdl.org>
List-ID: <linux-mm.kvack.org>

Replacing (n & (n-1)) in the context of power of 2 checks
with is_power_of_2

Signed-off-by: vignesh babu <vignesh.babu@wipro.com>
--- 
diff --git a/arch/ia64/mm/hugetlbpage.c b/arch/ia64/mm/hugetlbpage.c
index 1346b7f..d22861c 100644
--- a/arch/ia64/mm/hugetlbpage.c
+++ b/arch/ia64/mm/hugetlbpage.c
@@ -15,6 +15,7 @@
 #include <linux/pagemap.h>
 #include <linux/slab.h>
 #include <linux/sysctl.h>
+#include <linux/log2.h>
 #include <asm/mman.h>
 #include <asm/pgalloc.h>
 #include <asm/tlb.h>
@@ -182,7 +183,7 @@ static int __init hugetlb_setup_sz(char *str)
 		tr_pages = 0x15557000UL;
 
 	size = memparse(str, &str);
-	if (*str || (size & (size-1)) || !(tr_pages & size) ||
+	if (*str || !is_power_of_2(size) || !(tr_pages & size) ||
 		size <= PAGE_SIZE ||
 		size >= (1UL << PAGE_SHIFT << MAX_ORDER)) {
 		printk(KERN_WARNING "Invalid huge page size specified\n");

-- 
Vignesh Babu BM 
_____________________________________________________________ 
"Why is it that every time I'm with you, makes me believe in magic?"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
