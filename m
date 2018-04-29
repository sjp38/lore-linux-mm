Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: [PATCH] x86: Mark up large pm4/5 constants with UL
Date: Sun, 29 Apr 2018 12:48:32 +0100
Message-Id: <20180429114832.14552-1-chris@chris-wilson.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, intel-gfx@lists.freedesktop.org, Chris Wilson <chris@chris-wilson.co.uk>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>
List-ID: <linux-mm.kvack.org>

To silence sparse while maintaining compatibility with the assembly, use
_UL which conditionally only appends the UL suffix for C code.

Fixes: a7412546d8cb ("x86/mm: Adjust vmalloc base and size at boot-time")
Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@kernel.org>
---
 arch/x86/include/asm/pgtable_64_types.h | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/x86/include/asm/pgtable_64_types.h b/arch/x86/include/asm/pgtable_64_types.h
index d5c21a382475..40caf5eb9c18 100644
--- a/arch/x86/include/asm/pgtable_64_types.h
+++ b/arch/x86/include/asm/pgtable_64_types.h
@@ -105,14 +105,14 @@ extern unsigned int ptrs_per_p4d;
 #define LDT_PGD_ENTRY		(pgtable_l5_enabled ? LDT_PGD_ENTRY_L5 : LDT_PGD_ENTRY_L4)
 #define LDT_BASE_ADDR		(LDT_PGD_ENTRY << PGDIR_SHIFT)
 
-#define __VMALLOC_BASE_L4	0xffffc90000000000
-#define __VMALLOC_BASE_L5 	0xffa0000000000000
+#define __VMALLOC_BASE_L4	_UL(0xffffc90000000000)
+#define __VMALLOC_BASE_L5 	_UL(0xffa0000000000000)
 
 #define VMALLOC_SIZE_TB_L4	32UL
 #define VMALLOC_SIZE_TB_L5	12800UL
 
-#define __VMEMMAP_BASE_L4	0xffffea0000000000
-#define __VMEMMAP_BASE_L5	0xffd4000000000000
+#define __VMEMMAP_BASE_L4	_UL(0xffffea0000000000)
+#define __VMEMMAP_BASE_L5	_UL(0xffd4000000000000)
 
 #ifdef CONFIG_DYNAMIC_MEMORY_LAYOUT
 # define VMALLOC_START		vmalloc_base
-- 
2.17.0
