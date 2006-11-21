Date: Tue, 21 Nov 2006 12:36:58 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20061121203658.30802.49003.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20061121203647.30802.20845.sendpatchset@schroedinger.engr.sgi.com>
References: <20061121203647.30802.20845.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 2/6] Move vm_area_cachep to include/mm.h
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Move vm_area_cachep to linux/mm.h

vm_area_cachep is used to store vm_area_structs. So move to mm.h.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.19-rc5-mm2/include/linux/mm.h
===================================================================
--- linux-2.6.19-rc5-mm2.orig/include/linux/mm.h	2006-11-21 14:11:28.212876072 -0600
+++ linux-2.6.19-rc5-mm2/include/linux/mm.h	2006-11-21 14:14:21.660563147 -0600
@@ -114,6 +114,8 @@ struct vm_area_struct {
 #endif
 };
 
+extern struct kmem_cache *vm_area_cachep;
+
 /*
  * This struct defines the per-mm list of VMAs for uClinux. If CONFIG_MMU is
  * disabled, then there's a single shared list of VMAs maintained by the
Index: linux-2.6.19-rc5-mm2/include/linux/slab.h
===================================================================
--- linux-2.6.19-rc5-mm2.orig/include/linux/slab.h	2006-11-21 14:12:25.500080559 -0600
+++ linux-2.6.19-rc5-mm2/include/linux/slab.h	2006-11-21 14:13:54.237282393 -0600
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
