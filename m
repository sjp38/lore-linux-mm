Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9CC395F0040
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 16:57:50 -0400 (EDT)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id o9LKvk5A025778
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 13:57:46 -0700
Received: from pwi2 (pwi2.prod.google.com [10.241.219.2])
	by kpbe11.cbf.corp.google.com with ESMTP id o9LKviMD002357
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 13:57:45 -0700
Received: by pwi2 with SMTP id 2so210870pwi.21
        for <linux-mm@kvack.org>; Thu, 21 Oct 2010 13:57:44 -0700 (PDT)
Date: Thu, 21 Oct 2010 13:57:41 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: shrinkers: Add node to indicate where to target shrinking
In-Reply-To: <alpine.DEB.2.00.1010211259360.24115@router.home>
Message-ID: <alpine.DEB.2.00.1010211353540.17944@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1010211255570.24115@router.home> <alpine.DEB.2.00.1010211259360.24115@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linux-foundation.org, npiggin@kernel.dk, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Thu, 21 Oct 2010, Christoph Lameter wrote:

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
> 

This sets us up for node-targeted shrinking, but nothing is currently 
using it.  Do you have a patch (perhaps from Andi?) that can immediately 
use it?  That would be a compelling reason to merge this.

It needs to be rebased anyway since patch 1 had a fixup patch to fold (and 
the changelog needs to be updated there) that this depends on.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
