Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 9282560000B
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 15:02:36 -0400 (EDT)
Message-Id: <20100820190151.493325014@linux.com>
Date: Fri, 20 Aug 2010 14:01:51 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [S+Q Core 0/6] SLUB: Queueing Core
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

This is the core of the queueing for SLUB. More advanced stuff like
shared/alien caches and expiration is not included. 

Patches require the S+Q Cleanup V4 to be applied first.

1. Core (per cpu queues)

	Basic queues that are statically sized and only work as a per cpu queue

2. Resizable queues

	Allow dynamic resizing of the per cpu queues

3-5 some cleanups made possible by the above patches

6. Basic NUMA support

	This only implements the basic object based policy support for
	NUMA without additional optimizations.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
