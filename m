Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 139556B004D
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 14:20:15 -0400 (EDT)
Date: Wed, 21 Mar 2012 13:20:11 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Patch workqueue: create new slab cache instead of hacking
In-Reply-To: <1332353119.9433.2.camel@edumazet-glaptop>
Message-ID: <alpine.DEB.2.00.1203211319100.25567@router.home>
References: <1332238884-6237-1-git-send-email-laijs@cn.fujitsu.com> <1332238884-6237-7-git-send-email-laijs@cn.fujitsu.com> <20120320154619.GA5684@google.com> <4F6944D9.5090002@cn.fujitsu.com> <CAOS58YPydFUap4HjuRATxza6VZgyrXmQHVxR83G7GRJL50ZTRQ@mail.gmail.com>
 <alpine.DEB.2.00.1203210910450.20482@router.home> <1332341381.7893.17.camel@edumazet-glaptop> <alpine.DEB.2.00.1203210959500.21932@router.home> <1332345859.5330.8.camel@edumazet-glaptop> <alpine.DEB.2.00.1203211253520.21932@router.home>
 <1332353119.9433.2.camel@edumazet-glaptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Tejun Heo <tj@kernel.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 21 Mar 2012, Eric Dumazet wrote:

> On Wed, 2012-03-21 at 12:54 -0500, Christoph Lameter wrote:
> > On Wed, 21 Mar 2012, Eric Dumazet wrote:
> >
> > > On Wed, 2012-03-21 at 10:03 -0500, Christoph Lameter wrote:
> > > > On Wed, 21 Mar 2012, Eric Dumazet wrote:
> > > >
> > > > > Creating a dedicated cache for few objects ? Thats a lot of overhead, at
> > > > > least for SLAB (no merges of caches)
> > > >
> > > > Its some overhead for SLAB (a lot is what? If you tune down the per cpu
> > > > caches it should be a couple of pages) but its none for SLUB.
> > >
> > > SLAB overhead per cache is O(CPUS * nr_node_ids)  (unless alien caches
> > > are disabled)
> >
> > nr_node_ids==2 in the standard case these days. Alien caches are minimal.
>
>
> Thats not true. Some machines use lots of nodes (fake nodes) for various
> reasons.

Which is not a typical use case.

> And they cant disable alien caches for performance reasons.

Ok then lets genericize the slub merge in some form so that it works for
all slab allocators.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
