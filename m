From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 3/5] vmemmap ppc64: convert to new config options
References: <exportbomb.1186756801@pinky>
Message-Id: <E1IJVfi-0004zn-Ka@localhost.localdomain>
Date: Fri, 10 Aug 2007 15:41:02 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, Nick Piggin <npiggin@suse.de>, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

Convert over to the new Kconfig options.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
 arch/powerpc/Kconfig      |    9 +--------
 arch/powerpc/mm/init_64.c |    3 +--
 2 files changed, 2 insertions(+), 10 deletions(-)
diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index f5124cf..111bc25 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -265,6 +265,7 @@ config ARCH_FLATMEM_ENABLE
 config ARCH_SPARSEMEM_ENABLE
 	def_bool y
 	depends on PPC64
+	select SPARSEMEM_VMEMMAP_ENABLE
 
 config ARCH_SPARSEMEM_DEFAULT
 	def_bool y
@@ -275,14 +276,6 @@ config ARCH_POPULATES_NODE_MAP
 
 source "mm/Kconfig"
 
-config SPARSEMEM_VMEMMAP
-	def_bool y
-	depends on SPARSEMEM
-
-config ARCH_POPULATES_SPARSEMEM_VMEMMAP
-	def_bool y
-	depends on SPARSEMEM_VMEMMAP
-
 config ARCH_MEMORY_PROBE
 	def_bool y
 	depends on MEMORY_HOTPLUG
diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
index 05c7e93..4f543f8 100644
--- a/arch/powerpc/mm/init_64.c
+++ b/arch/powerpc/mm/init_64.c
@@ -182,8 +182,7 @@ void pgtable_cache_init(void)
 	}
 }
 
-#ifdef CONFIG_ARCH_POPULATES_SPARSEMEM_VMEMMAP
-
+#ifdef CONFIG_SPARSEMEM_VMEMMAP
 /*
  * Given an address within the vmemmap, determine the pfn of the page that
  * represents the start of the section it is within.  Note that we have to

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
