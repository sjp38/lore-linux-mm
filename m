Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 88B516B0070
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 11:05:55 -0400 (EDT)
Message-Id: <0000013a934eed6d-a9c1b247-dbbc-485d-b7cf-89aa36dcca57-000000@email.amazonses.com>
Date: Wed, 24 Oct 2012 15:05:54 +0000
From: Christoph Lameter <cl@linux.com>
Subject: CK4 [00/15] Sl[auo]b: Common kmalloc caches V4
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

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
