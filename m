Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id EF0D26B0031
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 15:55:14 -0400 (EDT)
Message-ID: <0000013f4441888d-73dc2ac4-08a7-4f84-ba27-72a2840e201f-000000@email.amazonses.com>
Date: Fri, 14 Jun 2013 19:55:13 +0000
From: Christoph Lameter <cl@linux.com>
Subject: [3.11 0/4] Sl[auo]b: Patches for 3.11 V1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

This patchset contains

1. A patch that allows the compiling of slub without cpu partial support (for the realtime folks)

2. 3 more unification patches that create more common definitions in include/linux/slab.h and
   get rid of include/linux/slob_def.h.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
