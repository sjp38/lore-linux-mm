Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 32BBF6B01F2
	for <linux-mm@kvack.org>; Fri, 14 May 2010 14:43:10 -0400 (EDT)
Message-Id: <20100514183908.118952419@quilx.com>
Date: Fri, 14 May 2010 13:39:08 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [RFC SLEB 00/10] [RFC] SLEB: The Enhanced Slab Allocator
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

SLEB is a merging of SLUB with some queuing concepts from SLAB and a new way
of managing objects in the slabs using bitmaps. It uses a percpu queue so that
free operations can be properly buffered and a bitmap for managing the
free/allocated state in the slabs. It is slightly more inefficient than
SLUB (due to the need to place large bitmaps --sized a few words--in some
slab pages if there are more than BITS_PER_LONG objects in a slab) but in
general does compete well with SLUB in terms of space use.

The SLAB scheme of not touching the object during management is adopted.
SLEB can efficiently free and allocate cache cold objects without
causing cache misses.

There are numerous SLAB schemes that are not supported. Those could be
added if needed and if they really make a difference.

WARNING: This only ran successfully using hackbench in a kvm instance so far.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
