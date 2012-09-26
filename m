Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 8A1456B002B
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 16:01:37 -0400 (EDT)
Message-Id: <0000013a042b9643-79a4b149-7788-4920-9e60-dca224eb77cd-000000@email.amazonses.com>
Date: Wed, 26 Sep 2012 20:01:36 +0000
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
