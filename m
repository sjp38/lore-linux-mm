Message-Id: <20070427202900.610748959@sgi.com>
References: <20070427202137.613097336@sgi.com>
Date: Fri, 27 Apr 2007 13:21:42 -0700
From: clameter@sgi.com
Subject: [patch 5/8] SLUB printk cleanup: add slab_err
Content-Disposition: inline; filename=slub_printk_add_slab_err
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Add a function to report on an error condition in a slab. This is similar
to object_err which reports on an error condition in an object.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |   13 +++++++++++++
 1 file changed, 13 insertions(+)

Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-04-27 10:33:06.000000000 -0700
+++ slub/mm/slub.c	2007-04-27 10:39:01.000000000 -0700
@@ -367,6 +367,19 @@ static void object_err(struct kmem_cache
 	dump_stack();
 }
 
+static void slab_err(struct kmem_cache *s, struct page *page, char *reason, ...)
+{
+	va_list args;
+	char buf[100];
+
+	va_start(args, reason);
+	vsnprintf(buf, sizeof(buf), reason, args);
+	va_end(args);
+	printk(KERN_ERR "*** SLUB %s: %s in slab @0x%p\n", s->name, buf,
+		page);
+	dump_stack();
+}
+
 static void init_object(struct kmem_cache *s, void *object, int active)
 {
 	u8 *p = object;

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
