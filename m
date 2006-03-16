Date: Wed, 15 Mar 2006 17:48:07 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: page migration reorg patch
In-Reply-To: <Pine.LNX.4.64.0603151736380.30472@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0603151747290.30472@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603151736380.30472@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Missing migrate.h:

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.16-rc6/include/linux/migrate.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.16-rc6/include/linux/migrate.h	2006-03-15 17:46:12.000000000 -0800
@@ -0,0 +1,31 @@
+#ifndef _LINUX_MIGRATE_H
+#define _LINUX_MIGRATE_H
+
+#include <linux/config.h>
+#include <linux/mm.h>
+
+#ifdef CONFIG_MIGRATION
+extern int isolate_lru_page(struct page *p);
+extern int putback_lru_pages(struct list_head *l);
+extern int migrate_page(struct page *, struct page *);
+extern void migrate_page_copy(struct page *, struct page *);
+extern int migrate_page_remove_references(struct page *, struct page *, int);
+extern int migrate_pages(struct list_head *l, struct list_head *t,
+		struct list_head *moved, struct list_head *failed);
+int migrate_pages_to(struct list_head *pagelist,
+			struct vm_area_struct *vma, int dest);
+extern int fail_migrate_page(struct page *, struct page *);
+
+#else
+
+static inline int isolate_lru_page(struct page *p) { return -ENOSYS; }
+static inline int putback_lru_pages(struct list_head *l) { return 0; }
+static inline int migrate_pages(struct list_head *l, struct list_head *t,
+	struct list_head *moved, struct list_head *failed) { return -ENOSYS; }
+
+/* Possible settings for the migrate_page() method in address_operations */
+#define migrate_page NULL
+#define fail_migrate_page NULL
+
+#endif /* CONFIG_MIGRATION */
+#endif /* _LINUX_MIGRATE_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
