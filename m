Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id AAF3E6B009B
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 17:46:44 -0400 (EDT)
Message-Id: <0000013abdf0bc4f-60a5adea-76f5-4e6e-9cfb-965d4d4a2778-000000@email.amazonses.com>
Date: Thu, 1 Nov 2012 21:46:42 +0000
From: Christoph Lameter <cl@linux.com>
Subject: CK5 [00/18] Sl[auo]b: Common kmalloc caches V5
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

V4->V5:
 - More fixes and more renaming patches as requested by Joonso.
 - Fix bootup issue where the kmem_cache structure was moved after
   being put on a list.

V3->V4:
 - Further fixes of issues pointed out by Joonsoo and Glauber.

V2-V3:
- Further cleanup and reordering as suggested by Glauber

V1-V2:
- Clean up numerous things as suggested by Glauber.
- Add two more patches that extract more kmalloc stuff
  into common files.

This patchset cleans up the bootstrap of the allocators
and creates a common functions to handle the kmalloc
array. The results are more common data structures and
functions that will simplify further work
on having common functions for all allocators.

This patchset is against Pekka's slab/next tree as of today.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
