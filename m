Date: Fri, 27 Jan 2006 10:17:49 +0000 (GMT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH] Compile error on x86 with hotplug but no highmem
Message-ID: <Pine.LNX.4.58.0601271014090.25836@skynet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Memory hotplug without highmem is meaningless but it is still an allowed
configuration. This is one possible fix. Another is to not allow memory
hotplug without high memory being available. Another is to take
online_page() outside of the #ifdef CONFIG_HIGHMEM block in init.c .


Signed-off-by: Mel Gorman <mel@csn.ul.ie>

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.16-rc1-mm3-clean/arch/i386/mm/init.c linux-2.6.16-rc1-mm3-nohighmemhotplug/arch/i386/mm/init.c
--- linux-2.6.16-rc1-mm3-clean/arch/i386/mm/init.c	2006-01-25 13:42:41.000000000 +0000
+++ linux-2.6.16-rc1-mm3-nohighmemhotplug/arch/i386/mm/init.c	2006-01-27 10:10:26.000000000 +0000
@@ -324,6 +324,7 @@ static void __init set_highmem_pages_ini
 #define kmap_init() do { } while (0)
 #define permanent_kmaps_init(pgd_base) do { } while (0)
 #define set_highmem_pages_init(bad_ppro) do { } while (0)
+void online_page(struct page *page) {}
 #endif /* CONFIG_HIGHMEM */

 unsigned long long __PAGE_KERNEL = _PAGE_KERNEL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
