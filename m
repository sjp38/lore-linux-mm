From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 4/5] vmemmap sparc64: convert to new config options
References: <exportbomb.1186756801@pinky>
Message-Id: <E1IJVg2-000553-Rf@localhost.localdomain>
Date: Fri, 10 Aug 2007 15:41:22 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, Nick Piggin <npiggin@suse.de>, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

Convert over to the new Kconfig options.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
 arch/sparc64/Kconfig   |    9 +--------
 arch/sparc64/mm/init.c |    4 ++--
 2 files changed, 3 insertions(+), 10 deletions(-)
diff --git a/arch/sparc64/Kconfig b/arch/sparc64/Kconfig
index 9953b4e..59c4d75 100644
--- a/arch/sparc64/Kconfig
+++ b/arch/sparc64/Kconfig
@@ -240,20 +240,13 @@ config ARCH_SELECT_MEMORY_MODEL
 
 config ARCH_SPARSEMEM_ENABLE
 	def_bool y
+	select SPARSEMEM_VMEMMAP_ENABLE
 
 config ARCH_SPARSEMEM_DEFAULT
 	def_bool y
 
 source "mm/Kconfig"
 
-config SPARSEMEM_VMEMMAP
-	def_bool y
-	depends on SPARSEMEM
-
-config ARCH_POPULATES_SPARSEMEM_VMEMMAP
-	def_bool y
-	depends on SPARSEMEM_VMEMMAP
-
 config ISA
 	bool
 	help
diff --git a/arch/sparc64/mm/init.c b/arch/sparc64/mm/init.c
index 19cac53..4e1df9a 100644
--- a/arch/sparc64/mm/init.c
+++ b/arch/sparc64/mm/init.c
@@ -1655,7 +1655,7 @@ EXPORT_SYMBOL(_PAGE_E);
 unsigned long _PAGE_CACHE __read_mostly;
 EXPORT_SYMBOL(_PAGE_CACHE);
 
-#ifdef CONFIG_ARCH_POPULATES_SPARSEMEM_VMEMMAP
+#ifdef CONFIG_SPARSEMEM_VMEMMAP
 
 #define VMEMMAP_CHUNK_SHIFT	22
 #define VMEMMAP_CHUNK		(1UL << VMEMMAP_CHUNK_SHIFT)
@@ -1705,7 +1705,7 @@ int __meminit vmemmap_populate(struct page *start, unsigned long nr, int node)
 	}
 	return 0;
 }
-#endif /* CONFIG_ARCH_POPULATES_SPARSEMEM_VMEMMAP */
+#endif /* CONFIG_SPARSEMEM_VMEMMAP */
 
 static void prot_init_common(unsigned long page_none,
 			     unsigned long page_shared,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
