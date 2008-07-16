Date: Wed, 16 Jul 2008 11:11:59 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: [PATCH] - Fix kernel_physical_mapping_init() for large x86 systems 
Message-ID: <20080716161159.GA23870@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@elte.hu, tglx@linutronix.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Fix bug in kernel_physical_mapping_init() that causes kernel
page table to be built incorrectly for systems with greater
than 512GB of memory.

Signed-off-by: Jack Steiner <steiner@sgi.com>

---
 arch/x86/mm/init_64.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux/arch/x86/mm/init_64.c
===================================================================
--- linux.orig/arch/x86/mm/init_64.c	2008-07-15 16:43:49.000000000 -0500
+++ linux/arch/x86/mm/init_64.c	2008-07-16 11:00:25.000000000 -0500
@@ -644,7 +644,7 @@ static unsigned long __init kernel_physi
 		unsigned long pud_phys;
 		pud_t *pud;
 
-		next = start + PGDIR_SIZE;
+		next = (start + PGDIR_SIZE) & PGDIR_MASK;
 		if (next > end)
 			next = end;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
