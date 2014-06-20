Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id 233566B0035
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 10:21:17 -0400 (EDT)
Received: by mail-qg0-f50.google.com with SMTP id j5so3437965qga.37
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 07:21:16 -0700 (PDT)
Received: from qmta05.emeryville.ca.mail.comcast.net (qmta05.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:48])
        by mx.google.com with ESMTP id 39si5866894qga.14.2014.06.20.07.21.15
        for <linux-mm@kvack.org>;
        Fri, 20 Jun 2014 07:21:16 -0700 (PDT)
Date: Fri, 20 Jun 2014 09:21:12 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [mmotm:master 74/230] mm/slab.h:299:10: error: 'struct kmem_cache'
 has no member named 'node'
In-Reply-To: <53a38f31.ttbTrpTZnPLPRHcz%fengguang.wu@intel.com>
Message-ID: <alpine.DEB.2.11.1406200916070.10271@gentwo.org>
References: <53a38f31.ttbTrpTZnPLPRHcz%fengguang.wu@intel.com>
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <alpine.DEB.2.11.1406200916072.10271@gentwo.org>
Content-Disposition: INLINE
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

Argh a SLOB configuration which does not use node specfic management data.

Subject: SLOB has no node specific management structures.

Do not provide the defintions for node management structures for SLOB.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slab.h
===================================================================
--- linux.orig/mm/slab.h	2014-06-20 09:17:22.582566992 -0500
+++ linux/mm/slab.h	2014-06-20 09:19:00.803449284 -0500
@@ -262,7 +262,7 @@ static inline struct kmem_cache *cache_f
 }
 #endif

-
+#ifndef CONFIG_SLOB
 /*
  * The slab lists for all objects.
  */
@@ -307,5 +307,7 @@ static inline struct kmem_cache_node *ge
 	for (__node = 0; __n = get_node(__s, __node), __node < nr_node_ids; __node++) \
 		 if (__n)

+#endif
+
 void *slab_next(struct seq_file *m, void *p, loff_t *pos);
 void slab_stop(struct seq_file *m, void *p);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
