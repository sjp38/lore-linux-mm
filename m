Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 086786B006E
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 15:18:57 -0400 (EDT)
Message-Id: <0000013a0e51400e-0719628d-3bba-404c-98a4-3409c79f7d62-000000@email.amazonses.com>
Date: Fri, 28 Sep 2012 19:18:56 +0000
From: Christoph Lameter <cl@linux.com>
Subject: CK2 [00/15] Sl[auo]b: Common kmalloc caches V2
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

V1-V2:
- Clean up numerous things as suggested by Glauber.
- Add two more patches that extract more kmalloc stuff
  into common files.

This patchset cleans up the bootstrap of the allocators
and creates a common functionis to handl the kmalloc
array. The results are more common data structures and
functions that will simplify further work
on having common functions for all allocators.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
