Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9E4D26B0047
	for <linux-mm@kvack.org>; Sat,  6 Feb 2010 02:25:11 -0500 (EST)
Date: Sat, 6 Feb 2010 08:25:08 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [1/4] SLAB: Handle node-not-up case in fallback_alloc()
Message-ID: <20100206072508.GN29555@one.firstfloor.org>
References: <201002031039.710275915@firstfloor.org> <20100203213912.D3081B1620@basil.firstfloor.org> <alpine.DEB.2.00.1002051251390.2376@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1002051251390.2376@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andi Kleen <andi@firstfloor.org>, submit@firstfloor.org, linux-kernel@vger.kernel.org, haicheng.li@intel.com, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 05, 2010 at 01:06:56PM -0800, David Rientjes wrote:
> On Wed, 3 Feb 2010, Andi Kleen wrote:
> 
> > When fallback_alloc() runs the node of the CPU might not be initialized yet.
> > Handle this case by allocating in another node.
> > 
> 
> That other node must be allowed by current's cpuset, otherwise 
> kmem_getpages() will fail when get_page_from_freelist() iterates only over 
> unallowed nodes.

All theses cases are really only interesting in the memory hotplug path
itself (afterwards the slab is working anyways and memory is there)
and if someone sets funny cpusets for those he gets what he deserves ...

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
