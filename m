Date: Fri, 17 Nov 2006 21:43:58 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20061118054358.8884.63823.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20061118054342.8884.12804.sendpatchset@schroedinger.engr.sgi.com>
References: <20061118054342.8884.12804.sendpatchset@schroedinger.engr.sgi.com>
Subject: [RFC 3/7] Move vm_area_cachep to mm.h
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <clameter@sgi.com>, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

Move vm_area_cachep to mm.h

vm_area_cachep is used to store vm_area_structs. So move to mm.h.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.19-rc5-mm2/include/linux/mm.h
===================================================================
--- linux-2.6.19-rc5-mm2.orig/include/linux/mm.h	2006-11-15 16:48:09.197243479 -0600
+++ linux-2.6.19-rc5-mm2/include/linux/mm.h	2006-11-17 23:03:55.571905748 -0600
@@ -114,6 +114,8 @@ struct vm_area_struct {
 #endif
 };
 
+extern kmem_cache_t	*vm_area_cachep;
+
 /*
  * This struct defines the per-mm list of VMAs for uClinux. If CONFIG_MMU is
  * disabled, then there's a single shared list of VMAs maintained by the
Index: linux-2.6.19-rc5-mm2/include/linux/slab.h
===================================================================
--- linux-2.6.19-rc5-mm2.orig/include/linux/slab.h	2006-11-17 23:03:51.817677214 -0600
+++ linux-2.6.19-rc5-mm2/include/linux/slab.h	2006-11-17 23:03:55.587532089 -0600
@@ -297,7 +297,6 @@ static inline void kmem_set_shrinker(kme
 #endif /* CONFIG_SLOB */
 
 /* System wide caches */
-extern kmem_cache_t	*vm_area_cachep;
 extern kmem_cache_t	*names_cachep;
 extern kmem_cache_t	*files_cachep;
 extern kmem_cache_t	*filp_cachep;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
