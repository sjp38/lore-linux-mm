Date: Fri, 11 Feb 2005 19:26:01 -0800 (PST)
From: Ray Bryant <raybry@sgi.com>
Message-Id: <20050212032601.18524.38649.41919@tomahawk.engr.sgi.com>
In-Reply-To: <20050212032535.18524.12046.26397@tomahawk.engr.sgi.com>
References: <20050212032535.18524.12046.26397@tomahawk.engr.sgi.com>
Subject: [RFC 2.6.11-rc2-mm2 4/7] mm: manual page migration -- cleanup 4
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>, Hugh DIckins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Dave Hansen <haveblue@us.ibm.com>, Marcello Tosatti <marcello@cyclades.com>
Cc: Ray Bryant <raybry@sgi.com>, Ray Bryant <raybry@austin.rr.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Add some extern declarations to include/linux/mmigrate.h to
eliminate some "implicitly" declared warnings.

Signed-off-by:Ray Bryant <raybry@sgi.com>

Index: linux-2.6.11-rc2-mm2/include/linux/mmigrate.h
===================================================================
--- linux-2.6.11-rc2-mm2.orig/include/linux/mmigrate.h	2005-02-11 11:23:46.000000000 -0800
+++ linux-2.6.11-rc2-mm2/include/linux/mmigrate.h	2005-02-11 11:50:27.000000000 -0800
@@ -17,6 +17,9 @@ extern int page_migratable(struct page *
 					struct list_head *);
 extern struct page * migrate_onepage(struct page *, int nodeid);
 extern int try_to_migrate_pages(struct list_head *);
+extern int migration_duplicate(swp_entry_t);
+extern struct page * lookup_migration_cache(int);
+extern int migration_remove_reference(struct page *, int);
 
 #else
 static inline int generic_migrate_page(struct page *page, struct page *newpage,

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
