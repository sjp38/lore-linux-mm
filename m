Message-ID: <41DEBB96.3030607@sgi.com>
Date: Fri, 07 Jan 2005 10:40:54 -0600
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: page migration patch
References: <41D99743.5000601@sgi.com>	<1104781061.25994.19.camel@localhost>	 <41D9A7DB.2020306@sgi.com> <20050104.234207.74734492.taka@valinux.co.jp>	 <41DAD2AF.80604@sgi.com> <1104860456.7581.21.camel@localhost> <41DADFB9.2090607@sgi.com>
In-Reply-To: <41DADFB9.2090607@sgi.com>
Content-Type: multipart/mixed;
 boundary="------------090707020708050900010008"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------090707020708050900010008
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Dave,

Attached is a trivial little patch that fixes the names on
the initial #ifdef and #define in linux/include/mmigrate.h
to match that file's name (it appears this was copied over from
some memory hotplug patch and was never updated....)

-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------

--------------090707020708050900010008
Content-Type: text/plain;
 name="fix-include-name-in-mmigrate.h.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="fix-include-name-in-mmigrate.h.patch"

Index: linux-2.6.10-rc2-mm4-page-migration-only/include/linux/mmigrate.h
===================================================================
--- linux-2.6.10-rc2-mm4-page-migration-only.orig/include/linux/mmigrate.h	2004-12-23 17:04:41.000000000 -0800
+++ linux-2.6.10-rc2-mm4-page-migration-only/include/linux/mmigrate.h	2005-01-07 08:33:40.000000000 -0800
@@ -1,5 +1,5 @@
-#ifndef _LINUX_MEMHOTPLUG_H
-#define _LINUX_MEMHOTPLUG_H
+#ifndef _LINUX_MMIGRATE_H
+#define _LINUX_MMIGRATE_H
 
 #include <linux/config.h>
 #include <linux/mm.h>
@@ -35,4 +35,4 @@ extern void arch_migrate_page(struct pag
 static inline void arch_migrate_page(struct page *page, struct page *newpage) {}
 #endif
 
-#endif /* _LINUX_MEMHOTPLUG_H */
+#endif /* _LINUX_MMIGRATE_H */

--------------090707020708050900010008--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
