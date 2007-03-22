From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 22 Mar 2007 17:00:37 +1100
Subject: [RFC/PATCH 4/15] get_unmapped_area handles MAP_FIXED on frv 
In-Reply-To: <1174543217.531981.572863804039.qpush@grosgo>
Message-Id: <20070322060219.2907DDDF2F@ozlabs.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

---

 arch/frv/mm/elf-fdpic.c |    4 ++++
 1 file changed, 4 insertions(+)

Index: linux-cell/arch/frv/mm/elf-fdpic.c
===================================================================
--- linux-cell.orig/arch/frv/mm/elf-fdpic.c	2007-03-22 15:00:50.000000000 +1100
+++ linux-cell/arch/frv/mm/elf-fdpic.c	2007-03-22 15:01:06.000000000 +1100
@@ -64,6 +64,10 @@ unsigned long arch_get_unmapped_area(str
 	if (len > TASK_SIZE)
 		return -ENOMEM;
 
+	/* handle MAP_FIXED */
+	if (flags & MAP_FIXED)
+		return addr;
+
 	/* only honour a hint if we're not going to clobber something doing so */
 	if (addr) {
 		addr = PAGE_ALIGN(addr);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
