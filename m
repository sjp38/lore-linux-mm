Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 51C0E6B0047
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 03:13:45 -0500 (EST)
Date: Tue, 2 Mar 2010 03:13:40 -0500
From: Amerigo Wang <amwang@redhat.com>
Message-Id: <20100302081715.3856.29571.sendpatchset@localhost.localdomain>
Subject: [Patch] mm: use the same log level for show_mem()
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, Amerigo Wang <amwang@redhat.com>
List-ID: <linux-mm.kvack.org>


Use the same log level for printk's in show_mem(),
so that those messages can be shown completely
when using log level 6.

Signed-off-by: WANG Cong <amwang@redhat.com>

---
diff --git a/lib/show_mem.c b/lib/show_mem.c
index 238e72a..fdc77c8 100644
--- a/lib/show_mem.c
+++ b/lib/show_mem.c
@@ -15,7 +15,7 @@ void show_mem(void)
 	unsigned long total = 0, reserved = 0, shared = 0,
 		nonshared = 0, highmem = 0;
 
-	printk(KERN_INFO "Mem-Info:\n");
+	printk("Mem-Info:\n");
 	show_free_areas();
 
 	for_each_online_pgdat(pgdat) {
@@ -49,15 +49,15 @@ void show_mem(void)
 		pgdat_resize_unlock(pgdat, &flags);
 	}
 
-	printk(KERN_INFO "%lu pages RAM\n", total);
+	printk("%lu pages RAM\n", total);
 #ifdef CONFIG_HIGHMEM
-	printk(KERN_INFO "%lu pages HighMem\n", highmem);
+	printk("%lu pages HighMem\n", highmem);
 #endif
-	printk(KERN_INFO "%lu pages reserved\n", reserved);
-	printk(KERN_INFO "%lu pages shared\n", shared);
-	printk(KERN_INFO "%lu pages non-shared\n", nonshared);
+	printk("%lu pages reserved\n", reserved);
+	printk("%lu pages shared\n", shared);
+	printk("%lu pages non-shared\n", nonshared);
 #ifdef CONFIG_QUICKLIST
-	printk(KERN_INFO "%lu pages in pagetable cache\n",
+	printk("%lu pages in pagetable cache\n",
 		quicklist_total_size());
 #endif
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
