Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id DC1265F004D
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 17:13:31 -0400 (EDT)
Date: Thu, 21 Oct 2010 16:13:28 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: vmscan: Do not run shrinkers for zones other than ZONE_NORMAL
In-Reply-To: <20101021135904.48a9c479.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1010211607430.32674@router.home>
References: <alpine.DEB.2.00.1010211255570.24115@router.home> <20101021124054.14b85e50.akpm@linux-foundation.org> <alpine.DEB.2.00.1010211455100.30295@router.home> <20101021131428.f2f7214a.akpm@linux-foundation.org> <alpine.DEB.2.00.1010211527050.32674@router.home>
 <20101021133636.68979e37.akpm@linux-foundation.org> <alpine.DEB.2.00.1010211547120.32674@router.home> <20101021135904.48a9c479.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: npiggin@kernel.dk, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Thu, 21 Oct 2010, Andrew Morton wrote:

> > With the per node patch we may be able to get some more finegrained slab
> > reclaim in the future. But the subsystems are still not distinguishing
> > caches per zone since slab allocations always occur from ZONE_NORMAL. So
> > what is the point of the additional calls?
> >
>
> In other words, you don't know!

Do you know what the point of calling slab_shrink() per zone in one
location (kswapd) vs. for each reclaim pass in direct reclaim is?

> Theoretical design arguments are all well and good.  But practical,
> empirical results rule, and we don't know the practical, empirical
> effects of this change upon our users.

If we want to use the shrinkers for node specific reclaim then we
need to have some sane methodology to this. Not only "we have done it this
way and we do not know why but it works". There seems to be already other
dark grown heuristics around slab_reclaim.

But maybe its better to throw the two changes together to make this one
patch for per node slab reclaim support.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
