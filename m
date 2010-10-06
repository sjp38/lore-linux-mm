Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 68A5A6B004A
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 06:47:26 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [UnifiedV4 00/16] The Unified slab allocator (V4)
References: <20101005185725.088808842@linux.com>
Date: Wed, 06 Oct 2010 12:47:21 +0200
In-Reply-To: <20101005185725.088808842@linux.com> (Christoph Lameter's message
	of "Tue, 05 Oct 2010 13:57:25 -0500")
Message-ID: <87fwwjha2u.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter <cl@linux.com> writes:

Not looked at code so far, but just comments based on the 
description. But thanks for working on this, it's good
to have alternatives to the ugly slab.c

> V3->V4:
> - Lots of debugging
> - Performance optimizations (more would be good)...
> - Drop per slab locking in favor of per node locking for
>   partial lists (queuing implies freeing large amounts of objects
>   to per node lists of slab).

Is that really a good idea? Nodes (= sockets) are getting larger and 
larger and they are quite substantial SMPs by themselves now.
On Xeon 75xx you have 16 virtual CPUs per node.


> 1. SLUB accurately tracks cpu caches instead of assuming that there
>    is only a single cpu cache per node or system.
>
> 2. SLUB object expiration is tied into the page reclaim logic. There
>    is no periodic cache expiration.

Hmm, but that means that you could fill a lot of memory with caches
before they get pruned right? Is there another limit too?

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
