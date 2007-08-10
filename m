From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 5/5] vmemmap ia64: convert to new helper based initialisation
References: <exportbomb.1186756801@pinky>
Message-Id: <E1IJVgN-0005Am-4m@localhost.localdomain>
Date: Fri, 10 Aug 2007 15:41:43 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, Nick Piggin <npiggin@suse.de>, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

Convert over to the new helper initialialisation and Kconfig options.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
 arch/ia64/Kconfig        |    5 +----
 arch/ia64/mm/discontig.c |    8 ++++++++
 2 files changed, 9 insertions(+), 4 deletions(-)
diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 92d2c2d..66fafbd 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -363,10 +363,7 @@ config ARCH_FLATMEM_ENABLE
 config ARCH_SPARSEMEM_ENABLE
 	def_bool y
 	depends on ARCH_DISCONTIGMEM_ENABLE
-
-config SPARSEMEM_VMEMMAP
-	def_bool y
-	depends on SPARSEMEM
+	select SPARSEMEM_VMEMMAP_ENABLE
 
 config ARCH_DISCONTIGMEM_DEFAULT
 	def_bool y if (IA64_SGI_SN2 || IA64_GENERIC || IA64_HP_ZX1 || IA64_HP_ZX1_SWIOTLB)
diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index 8a5c1c9..05b374c 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -715,3 +715,11 @@ void arch_refresh_nodedata(int update_node, pg_data_t *update_pgdat)
 	scatter_node_data();
 }
 #endif
+
+#ifdef CONFIG_SPARSEMEM_VMEMMAP
+int __meminit vmemmap_populate(struct page *start_page,
+						unsigned long size, int node)
+{
+	return vmemmap_populate_basepages(start_page, size, node);
+}
+#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
