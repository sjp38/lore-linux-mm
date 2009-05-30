Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BA9136B009E
	for <linux-mm@kvack.org>; Sat, 30 May 2009 03:29:10 -0400 (EDT)
Date: Sat, 30 May 2009 00:29:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: More thoughts about hwpoison and pageflags compression
Message-Id: <20090530002930.2481164f.akpm@linux-foundation.org>
In-Reply-To: <20090530072758.GL1065@one.firstfloor.org>
References: <200905291135.124267638@firstfloor.org>
	<20090529225202.0c61a4b3@lxorguk.ukuu.org.uk>
	<20090530063710.GI1065@one.firstfloor.org>
	<20090529235302.ccf58d88.akpm@linux-foundation.org>
	<20090530072758.GL1065@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

On Sat, 30 May 2009 09:27:58 +0200 Andi Kleen <andi@firstfloor.org> wrote:

> On Fri, May 29, 2009 at 11:53:02PM -0700, Andrew Morton wrote:
> > On Sat, 30 May 2009 08:37:10 +0200 Andi Kleen <andi@firstfloor.org> wrote:
> > 
> > > So using a separate bit is a sensible choice imho.
> > 
> > Could you make the feature 64-bit-only and use one of bits 32-63?
> 
> We could, but these systems can run 32bit kernels too (although
> it's probably not a good idea). Ok it would be probably possible
> to make it 64bit only, but I would prefer to not do that.
> 
> Also even 32bit has still flags free and even if we run out there's an easy 
> path to free more (see my earlier writeup)

hm.  Maybe that should be proven sooner rather than later.

> So I don't see the pressing need to conserve every bit on 32bit.
> 
> > Did you consider making the poison tag external to the pageframe?  Some
> > hash(page*) into a bitmap or something?  If suitably designed, such
> > infrastructure could perhaps be reused to reclaim some existing page
> > flags.  Dave Hansen had such a patch a few years back.  Or maybe it
> > was Andy Whitcroft.
> 
> I considered it at some point, but it would have complicated the code
> and I preferred to keep it simple. The poison handler should be relatively
> straight forward and do its work quickly otherwise it might not isolate
> the page before it's actually used.

Well it's going to get complicated when we run out anyway.  And run out
we shall.

Plus we haven't looked into the complexity of the external flags yet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
