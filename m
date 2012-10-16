Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 02B7C6B005A
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 07:48:25 -0400 (EDT)
From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCHv3 4/6] mm: reuse kbasename() functionality
Date: Tue, 16 Oct 2012 14:48:12 +0300
Message-Id: <1350388094-18805-6-git-send-email-andriy.shevchenko@linux.intel.com>
In-Reply-To: <1350388094-18805-1-git-send-email-andriy.shevchenko@linux.intel.com>
References: <1350388094-18805-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Joe Perches <joe@perches.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>, linux-mm@kvack.org

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Cc: linux-mm@kvack.org
---
 mm/memory.c |    8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 5823f29..06158b7 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -58,6 +58,7 @@
 #include <linux/elf.h>
 #include <linux/gfp.h>
 #include <linux/migrate.h>
+#include <linux/string.h>
 
 #include <asm/io.h>
 #include <asm/pgalloc.h>
@@ -4034,15 +4035,12 @@ void print_vma_addr(char *prefix, unsigned long ip)
 		struct file *f = vma->vm_file;
 		char *buf = (char *)__get_free_page(GFP_KERNEL);
 		if (buf) {
-			char *p, *s;
+			char *p;
 
 			p = d_path(&f->f_path, buf, PAGE_SIZE);
 			if (IS_ERR(p))
 				p = "?";
-			s = strrchr(p, '/');
-			if (s)
-				p = s+1;
-			printk("%s%s[%lx+%lx]", prefix, p,
+			printk("%s%s[%lx+%lx]", prefix, kbasename(p),
 					vma->vm_start,
 					vma->vm_end - vma->vm_start);
 			free_page((unsigned long)buf);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
