Message-Id: <20080430044319.612279708@sgi.com>
References: <20080430044251.266380837@sgi.com>
Date: Tue, 29 Apr 2008 21:42:54 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [03/11] vmallocinfo: Support display of virtualized compound pages
Content-Disposition: inline; filename=vcp_vmalloc_type
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Add another flag to the vmalloc subsystem to mark vmalloc areas used
for virtualized compound pages. Display vcompound in /proc/vmallocinfo.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/vmalloc.h |    1 +
 mm/vmalloc.c            |    3 +++
 2 files changed, 4 insertions(+)

Index: linux-2.6.25-rc8-mm2/include/linux/vmalloc.h
===================================================================
--- linux-2.6.25-rc8-mm2.orig/include/linux/vmalloc.h	2008-04-14 20:01:25.295741503 -0700
+++ linux-2.6.25-rc8-mm2/include/linux/vmalloc.h	2008-04-14 20:01:27.465740891 -0700
@@ -12,6 +12,7 @@ struct vm_area_struct;
 #define VM_MAP		0x00000004	/* vmap()ed pages */
 #define VM_USERMAP	0x00000008	/* suitable for remap_vmalloc_range */
 #define VM_VPAGES	0x00000010	/* buffer for pages was vmalloc'ed */
+#define VM_VCOMPOUND	0x00000020	/* Virtualized Compound Page */
 /* bits [20..32] reserved for arch specific ioremap internals */
 
 /*
Index: linux-2.6.25-rc8-mm2/mm/vmalloc.c
===================================================================
--- linux-2.6.25-rc8-mm2.orig/mm/vmalloc.c	2008-04-14 20:01:25.295741503 -0700
+++ linux-2.6.25-rc8-mm2/mm/vmalloc.c	2008-04-14 20:01:27.485750108 -0700
@@ -972,6 +972,9 @@ static int s_show(struct seq_file *m, vo
 	if (v->flags & VM_VPAGES)
 		seq_printf(m, " vpages");
 
+	if (v->flags & VM_VCOMPOUND)
+		seq_printf(m, " vcompound");
+
 	seq_putc(m, '\n');
 	return 0;
 }

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
