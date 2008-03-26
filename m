Message-Id: <20080326013812.474773000@polaris-admin.engr.sgi.com>
References: <20080326013811.569646000@polaris-admin.engr.sgi.com>
Date: Tue, 25 Mar 2008 18:38:16 -0700
From: Mike Travis <travis@sgi.com>
Subject: [PATCH 05/12] init: move large array from stack to _initdata section
Content-Disposition: inline; filename=numa_initmem_init
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

Move large array "struct bootnode nodes" from stack to _initdata
section.

Based on:
	git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
	git://git.kernel.org/pub/scm/linux/kernel/git/x86/linux-2.6-x86.git

Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: H. Peter Anvin <hpa@zytor.com>

Signed-off-by: Mike Travis <travis@sgi.com>
---
 arch/x86/mm/numa_64.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- linux.trees.git.orig/arch/x86/mm/numa_64.c
+++ linux.trees.git/arch/x86/mm/numa_64.c
@@ -411,9 +411,10 @@ static int __init split_nodes_by_size(st
  * Sets up the system RAM area from start_pfn to end_pfn according to the
  * numa=fake command-line option.
  */
+static struct bootnode nodes[MAX_NUMNODES] __initdata;
+
 static int __init numa_emulation(unsigned long start_pfn, unsigned long end_pfn)
 {
-	struct bootnode nodes[MAX_NUMNODES];
 	u64 size, addr = start_pfn << PAGE_SHIFT;
 	u64 max_addr = end_pfn << PAGE_SHIFT;
 	int num_nodes = 0, num = 0, coeff_flag, coeff = -1, i;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
