Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id DE42C6B004A
	for <linux-mm@kvack.org>; Mon, 12 Mar 2012 19:41:48 -0400 (EDT)
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 32/35] Move all declarations of free_initmem() to linux/mm.h
 [ver #2]
Date: Mon, 12 Mar 2012 23:41:33 +0000
Message-ID: <20120312234133.13888.21207.stgit@warthog.procyon.org.uk>
In-Reply-To: <20120312233602.13888.27659.stgit@warthog.procyon.org.uk>
References: <20120312233602.13888.27659.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paul.gortmaker@windriver.com, hpa@zytor.com
Cc: torvalds@linux-foundation.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, arnd@arndb.de, David Howells <dhowells@redhat.com>, linux-c6x-dev@linux-c6x.org, microblaze-uclinux@itee.uq.edu.au, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org

Move all declarations of free_initmem() to linux/mm.h so that there's only one
and it's used by everything.

Signed-off-by: David Howells <dhowells@redhat.com>
cc: linux-c6x-dev@linux-c6x.org
cc: microblaze-uclinux@itee.uq.edu.au
cc: linux-sh@vger.kernel.org
cc: sparclinux@vger.kernel.org
cc: x86@kernel.org
cc: linux-mm@kvack.org
---

 arch/c6x/include/asm/system.h        |    1 -
 arch/frv/include/asm/system.h        |    2 --
 arch/microblaze/include/asm/system.h |    1 -
 arch/sh/include/asm/system.h         |    1 -
 arch/sparc/mm/init_64.h              |    2 --
 arch/x86/include/asm/page_types.h    |    1 -
 include/linux/mm.h                   |    2 ++
 init/main.c                          |    1 -
 8 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/arch/c6x/include/asm/system.h b/arch/c6x/include/asm/system.h
index ccc4f86..0d84f9e 100644
--- a/arch/c6x/include/asm/system.h
+++ b/arch/c6x/include/asm/system.h
@@ -4,4 +4,3 @@
 #include <asm/exec.h>
 #include <asm/special_insns.h>
 #include <asm/switch_to.h>
-extern void free_initmem(void);
diff --git a/arch/frv/include/asm/system.h b/arch/frv/include/asm/system.h
index 5c707a2..659bcdb 100644
--- a/arch/frv/include/asm/system.h
+++ b/arch/frv/include/asm/system.h
@@ -1,6 +1,4 @@
-/* FILE TO BE DELETED. DO NOT ADD STUFF HERE! */
 #include <asm/barrier.h>
 #include <asm/cmpxchg.h>
 #include <asm/exec.h>
 #include <asm/switch_to.h>
-extern void free_initmem(void);
diff --git a/arch/microblaze/include/asm/system.h b/arch/microblaze/include/asm/system.h
index ccc4f86..0d84f9e 100644
--- a/arch/microblaze/include/asm/system.h
+++ b/arch/microblaze/include/asm/system.h
@@ -4,4 +4,3 @@
 #include <asm/exec.h>
 #include <asm/special_insns.h>
 #include <asm/switch_to.h>
-extern void free_initmem(void);
diff --git a/arch/sh/include/asm/system.h b/arch/sh/include/asm/system.h
index e2042aa..04268aa 100644
--- a/arch/sh/include/asm/system.h
+++ b/arch/sh/include/asm/system.h
@@ -6,4 +6,3 @@
 #include <asm/exec.h>
 #include <asm/switch_to.h>
 #include <asm/traps.h>
-void free_initmem(void);
diff --git a/arch/sparc/mm/init_64.h b/arch/sparc/mm/init_64.h
index 77d1b31..3e1ac8b 100644
--- a/arch/sparc/mm/init_64.h
+++ b/arch/sparc/mm/init_64.h
@@ -36,8 +36,6 @@ extern unsigned long kern_locked_tte_data;
 
 extern void prom_world(int enter);
 
-extern void free_initmem(void);
-
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
 #define VMEMMAP_CHUNK_SHIFT	22
 #define VMEMMAP_CHUNK		(1UL << VMEMMAP_CHUNK_SHIFT)
diff --git a/arch/x86/include/asm/page_types.h b/arch/x86/include/asm/page_types.h
index bce688d..e21fdd1 100644
--- a/arch/x86/include/asm/page_types.h
+++ b/arch/x86/include/asm/page_types.h
@@ -55,7 +55,6 @@ extern unsigned long init_memory_mapping(unsigned long start,
 					 unsigned long end);
 
 extern void initmem_init(void);
-extern void free_initmem(void);
 
 #endif	/* !__ASSEMBLY__ */
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 17b27cd..5fcaeaa 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1253,6 +1253,8 @@ static inline void pgtable_page_dtor(struct page *page)
 extern void free_area_init(unsigned long * zones_size);
 extern void free_area_init_node(int nid, unsigned long * zones_size,
 		unsigned long zone_start_pfn, unsigned long *zholes_size);
+extern void free_initmem(void);
+
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 /*
  * With CONFIG_HAVE_MEMBLOCK_NODE_MAP set, an architecture may initialise its
diff --git a/init/main.c b/init/main.c
index ff49a6d..de41307 100644
--- a/init/main.c
+++ b/init/main.c
@@ -87,7 +87,6 @@ extern void mca_init(void);
 extern void sbus_init(void);
 extern void prio_tree_init(void);
 extern void radix_tree_init(void);
-extern void free_initmem(void);
 #ifndef CONFIG_DEBUG_RODATA
 static inline void mark_rodata_ro(void) { }
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
