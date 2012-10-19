Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id BBA586B005D
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 10:25:52 -0400 (EDT)
Message-Id: <0000013a796a7726-47a5176e-5010-472a-b0f8-83a3f1112de9-000000@email.amazonses.com>
Date: Fri, 19 Oct 2012 14:25:51 +0000
From: Christoph Lameter <cl@linux.com>
Subject: CK2 [00/15] Sl[auo]b: Common kmalloc caches V3
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

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

This patchset is against Pekka's slab/next tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
