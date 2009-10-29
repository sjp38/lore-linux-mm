Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id CCED76B004D
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 15:19:08 -0400 (EDT)
Subject: Re: [PATCH/RFC] slab:  handle memoryless nodes efficiently
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <alpine.DEB.1.10.0910291728200.30007@V090114053VZO-1>
References: <1256836094.16599.67.camel@useless.americas.hpqcorp.net>
	 <alpine.DEB.1.10.0910291728200.30007@V090114053VZO-1>
Content-Type: text/plain
Date: Thu, 29 Oct 2009 15:18:59 -0400
Message-Id: <1256843939.16599.71.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2009-10-29 at 17:30 -0400, Christoph Lameter wrote:
> Maybe better introduce an alternative to numa_node_id that refers to the
> next memory node?
> 
> numa_mem_node_id?
> 
> We can then use that in various subsystems and could use it consistently
> also in slab.c

Where should we put it?  In page_alloc.c that manages the zonelists.

> 
> One problem with such a scheme (and also this patch) is that multiple
> memory nodes may be at the same distance to a processor on a memoryless
> node. Should the allocation not take memory from any of these nodes?

Well, this is the case for normal page allocations as well, but we
choose one, in build_zonelists(), that we'll use whenever a page
allocation overflows the target node selected by the mempolicy.  So,
that seemed a reasonable node to use for slab allocations.  

Thoughts?

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
