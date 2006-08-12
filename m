From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Sat, 12 Aug 2006 16:14:25 +0200
Message-Id: <20060812141425.30842.35004.sendpatchset@lappy>
In-Reply-To: <20060812141415.30842.78695.sendpatchset@lappy>
References: <20060812141415.30842.78695.sendpatchset@lappy>
Subject: [RFC][PATCH 1/4] pfn_to_kaddr() for UML
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Cc: Indan Zupancic <indan@nul.nu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Evgeniy Polyakov <johnpol@2ka.mipt.ru>, Daniel Phillips <phillips@google.com>, Rik van Riel <riel@redhat.com>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

Update UML with a proper 'pfn_to_kaddr()' definition, the SROG allocator
uses it.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Daniel Phillips <phillips@google.com>

---
 include/asm-um/page.h |    2 ++
 1 file changed, 2 insertions(+)

Index: linux-2.6/include/asm-um/page.h
===================================================================
--- linux-2.6.orig/include/asm-um/page.h
+++ linux-2.6/include/asm-um/page.h
@@ -111,6 +111,8 @@ extern unsigned long uml_physmem;
 #define pfn_valid(pfn) ((pfn) < max_mapnr)
 #define virt_addr_valid(v) pfn_valid(phys_to_pfn(__pa(v)))
 
+#define pfn_to_kaddr(pfn)	__va((pfn) << PAGE_SHIFT)
+
 extern struct page *arch_validate(struct page *page, gfp_t mask, int order);
 #define HAVE_ARCH_VALIDATE
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
