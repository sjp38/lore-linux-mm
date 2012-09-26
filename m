Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 79A4E6B002B
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 15:12:20 -0400 (EDT)
Message-Id: <0000013a03fe75d9-fa42a2fe-0742-47bd-99ee-5d2886e30436-000000@email.amazonses.com>
Date: Wed, 26 Sep 2012 19:12:19 +0000
From: Christoph Lameter <cl@linux.com>
Subject: CK1 [00/13] [RFC] Sl[auo]b: Common kmalloc caches V1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

This patchset cleans up the bootstrap of the allocators
and creates a common function to set up the
kmalloc array. The results are more common
data structures that will simplify further work
on having common functions for all allocators.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
