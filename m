Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 14DF35F0040
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 14:12:31 -0400 (EDT)
Date: Thu, 21 Oct 2010 20:12:25 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: shrinkers: Add node to indicate where to target shrinking
Message-ID: <20101021181225.GA32737@basil.fritz.box>
References: <alpine.DEB.2.00.1010211255570.24115@router.home>
 <alpine.DEB.2.00.1010211259360.24115@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1010211259360.24115@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linux-foundation.org, npiggin@kernel.dk, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 21, 2010 at 01:00:37PM -0500, Christoph Lameter wrote:
> Add a field node to struct shrinker that can be used to indicate on which
> node the reclaim should occur. The node field also can be set to NUMA_NO_NODE
> in which case a reclaim pass over all nodes is desired.
> 
> NUMA_NO_NODE will be used for direct reclaim since reclaim is not specific
> there (Some issues are still left since we are not respecting boundaries of
> memory policies and cpusets).
> 
> A node will be supplied for kswap and zone reclaim invocations of zone reclaim.
> It is also possible then for the shrinker invocation from mm/memory-failure.c
> to indicate the node for which caches need to be shrunk.
> 
> After this patch it is possible to make shrinkers node aware by checking
> the node field of struct shrinker. If a shrinker does not support per node
> reclaim then it can still do global reclaim.

Thanks. Looks good and is definitely a step in the right direction. 
The memory-failure patch is ok for me if someone wants to merge it into
another tree.

Acked-by: Andi Kleen <ak@linux.intel.com>

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
