Date: Fri, 11 Feb 2005 19:25:54 -0800 (PST)
From: Ray Bryant <raybry@sgi.com>
Message-Id: <20050212032554.18524.15452.35627@tomahawk.engr.sgi.com>
In-Reply-To: <20050212032535.18524.12046.26397@tomahawk.engr.sgi.com>
References: <20050212032535.18524.12046.26397@tomahawk.engr.sgi.com>
Subject: [RFC 2.6.11-rc2-mm2 3/7] mm: manual page migration -- cleanup 3
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>, Hugh DIckins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Dave Hansen <haveblue@us.ibm.com>, Marcello Tosatti <marcello@cyclades.com>
Cc: Ray Bryant <raybry@sgi.com>, Ray Bryant <raybry@austin.rr.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Fix a trivial error in include/linux/mmigrate.h

Signed-off-by: Ray Bryant <raybry@sgi.com>

Index: linux-2.6.11-rc2-mm2/include/linux/mmigrate.h
===================================================================
--- linux-2.6.11-rc2-mm2.orig/include/linux/mmigrate.h	2005-02-11 10:08:10.000000000 -0800
+++ linux-2.6.11-rc2-mm2/include/linux/mmigrate.h	2005-02-11 11:22:34.000000000 -0800
@@ -1,5 +1,5 @@
-#ifndef _LINUX_MEMHOTPLUG_H
-#define _LINUX_MEMHOTPLUG_H
+#ifndef _LINUX_MMIGRATE_H
+#define _LINUX_MMIGRATE_H
 
 #include <linux/config.h>
 #include <linux/mm.h>
@@ -36,4 +36,4 @@ extern void arch_migrate_page(struct pag
 static inline void arch_migrate_page(struct page *page, struct page *newpage) {}
 #endif
 
-#endif /* _LINUX_MEMHOTPLUG_H */
+#endif /* _LINUX_MMIGRATE_H */

-- 
Best Regards,
Ray
-----------------------------------------------
Ray Bryant                       raybry@sgi.com
The box said: "Requires Windows 98 or better",
           so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
