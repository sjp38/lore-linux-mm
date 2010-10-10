Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 6C5726B0071
	for <linux-mm@kvack.org>; Sun, 10 Oct 2010 19:51:19 -0400 (EDT)
Date: Mon, 11 Oct 2010 10:50:39 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Results of my VFS scaling evaluation.
Message-ID: <20101010235039.GP4681@dastard>
References: <1286580739.3153.57.camel@bobble.smo.corp.google.com>
 <20101009031609.GK4681@dastard>
 <87y6a6fsg4.fsf@basil.nowhere.org>
 <20101010073732.GA4097@infradead.org>
 <20101010082038.GA17133@basil.fritz.box>
 <20101010083749.GA8702@infradead.org>
 <20101010120309.GB8256@basil.fritz.box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101010120309.GB8256@basil.fritz.box>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Christoph Hellwig <hch@infradead.org>, Frank Mayhar <fmayhar@google.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, mrubin@google.com, torvalds@linux-foundation.org, viro@zeniv.linux.org.uk
List-ID: <linux-mm.kvack.org>

On Sun, Oct 10, 2010 at 02:03:09PM +0200, Andi Kleen wrote:
> On Sun, Oct 10, 2010 at 04:37:49AM -0400, Christoph Hellwig wrote:
> > but actually helping with review and testing would be more useful.
> 
> Well the constant refactoring is certainly not helping with testing.

That is the way of review cycles. The need for significant
refactoring and reworking shows how much work the VFS maintainers
consider still needs to be done on the patch set.

> Also what typically happens is that if we don't fix all the serious
> VFS locking issues (like Nick's patch kit) we just move from one bottle 
> neck to another.

Sure, but at least there is a plan for dealing with them all and,
most importantly, people committed to pushing it forward.

Fundamentally, we need to understand the source of the lock
contention problems before trying to fix them. Nick just hit them
repeatedly with a big hammer until they went away....

> > Yes, lots of things could be done in parallel, but it needs people to
> > actually work on it.  And right now that's mostly Dave for the real
> > work, with me trying to prepare a proper dcache series for .38, and Al
> > doing some review.
> 
> It was not clear to me what was so horrible with Nick's original
> patchkit?  Sure there were a few rough edges, but does it really
> need to be fully redone?

I think the trylock mess is pretty much universally disliked by
anyone who looks at the VFS and writeback code on a daily basis. And
IMO the level of nested trylock looping is generally indicative of
getting the lock ordering strategy wrong in the first place.

Not to mention that as soon as I tried to re-order cleanups to the
front of the queue, it was pretty clear that it was going to be
unmaintainable, too.

> It certainly held up great to lots of testing, both at our side
> and apparently Google's too.

Not the least bit relevant, IMO, when the code ends up unmaintanable
in the long term.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
