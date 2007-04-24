From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Tue, 24 Apr 2007 15:33:35 +1000
Subject: [PATCH 3/12] get_unmapped_area handles MAP_FIXED on arm
In-Reply-To: <1177392813.924664.32930750763.qpush@grosgo>
Message-Id: <20070424053337.C5FEBDDF09@ozlabs.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

ARM already had a case for MAP_FIXED in arch_get_unmapped_area() though
it was not called before. Fix the comment to reflect that it will now
be called.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

 arch/arm/mm/mmap.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

Index: linux-cell/arch/arm/mm/mmap.c
===================================================================
--- linux-cell.orig/arch/arm/mm/mmap.c	2007-03-22 14:59:51.000000000 +1100
+++ linux-cell/arch/arm/mm/mmap.c	2007-03-22 15:00:01.000000000 +1100
@@ -49,8 +49,7 @@ arch_get_unmapped_area(struct file *filp
 #endif
 
 	/*
-	 * We should enforce the MAP_FIXED case.  However, currently
-	 * the generic kernel code doesn't allow us to handle this.
+	 * We enforce the MAP_FIXED case.
 	 */
 	if (flags & MAP_FIXED) {
 		if (aliasing && flags & MAP_SHARED && addr & (SHMLBA - 1))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
