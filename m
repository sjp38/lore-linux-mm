Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9EE5360000B
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 13:08:21 -0400 (EDT)
Date: Fri, 20 Aug 2010 12:08:16 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [S+Q Cleanup3 4/6] slub: Dynamically size kmalloc cache
 allocations
In-Reply-To: <alpine.DEB.2.00.1008191638390.29676@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1008201206390.32757@router.home>
References: <20100819203324.549566024@linux.com> <20100819203438.745611155@linux.com> <alpine.DEB.2.00.1008191405230.18994@chino.kir.corp.google.com> <alpine.DEB.2.00.1008191627100.5611@router.home> <alpine.DEB.2.00.1008191600240.25634@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1008191819420.7903@router.home> <alpine.DEB.2.00.1008191638390.29676@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Aug 2010, David Rientjes wrote:

> On Thu, 19 Aug 2010, Christoph Lameter wrote:
>
> > Right. I will merge this correctly for the next release that has all
> > patches acked by you.
> >
>
> It would really be nice to get rid of all the #ifdefs in kmem_cache_init()
> for CONFIG_NUMA by extracting them to helper functions if you're
> interested.

That is difficult since the code segments share global and local
variables. Also the location of the kmem_cache_node structure
differs since it is embedded in the SMP case. We could just drop that
optimization. Then it would be easy to drop lots of NUMA specifics in the
allocator.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
