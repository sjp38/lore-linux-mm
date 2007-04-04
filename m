From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 04 Apr 2007 14:02:19 +1000
Subject: [PATCH 9/14] get_unmapped_area handles MAP_FIXED on x86_64
In-Reply-To: <1175659331.690672.592289266160.qpush@grosgo>
Message-Id: <20070404040230.93B50DDEA3@ozlabs.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-arch@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

---

 arch/x86_64/kernel/sys_x86_64.c |    3 +++
 1 file changed, 3 insertions(+)

Index: linux-cell/arch/x86_64/kernel/sys_x86_64.c
===================================================================
--- linux-cell.orig/arch/x86_64/kernel/sys_x86_64.c	2007-03-22 16:10:10.000000000 +1100
+++ linux-cell/arch/x86_64/kernel/sys_x86_64.c	2007-03-22 16:11:06.000000000 +1100
@@ -93,6 +93,9 @@ arch_get_unmapped_area(struct file *filp
 	unsigned long start_addr;
 	unsigned long begin, end;
 	
+	if (flags & MAP_FIXED)
+		return addr;
+
 	find_start_end(flags, &begin, &end); 
 
 	if (len > end)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
