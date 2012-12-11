Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id E291F6B002B
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 12:17:48 -0500 (EST)
Date: Tue, 11 Dec 2012 12:17:45 -0500
From: Dave Jones <davej@redhat.com>
Subject: [PATCH] Print loaded modules when we encounter a bad page map.
Message-ID: <20121211171745.GA17489@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Linux Kernel <linux-kernel@vger.kernel.org>

When we see reports like https://bugzilla.redhat.com/show_bug.cgi?id=883576
it might be useful to know what modules had been loaded, so they can be compared
with similar reports to see if there is a common suspect.

Signed-off-by: Dave Jones <davej@redhat.com>

diff --git a/mm/memory.c b/mm/memory.c
index 221fc9f..7fc8c01 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -57,6 +57,7 @@
 #include <linux/swapops.h>
 #include <linux/elf.h>
 #include <linux/gfp.h>
+#include <linux/module.h>
 
 #include <asm/io.h>
 #include <asm/pgalloc.h>
@@ -708,6 +709,7 @@ static void print_bad_pte(struct vm_area_struct *vma, unsigned long addr,
 	if (vma->vm_file && vma->vm_file->f_op)
 		print_symbol(KERN_ALERT "vma->vm_file->f_op->mmap: %s\n",
 				(unsigned long)vma->vm_file->f_op->mmap);
+	print_modules();
 	dump_stack();
 	add_taint(TAINT_BAD_PAGE);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
