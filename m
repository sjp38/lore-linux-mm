Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8CE1C6B0071
	for <linux-mm@kvack.org>; Sun, 10 Oct 2010 08:03:13 -0400 (EDT)
Date: Sun, 10 Oct 2010 14:03:09 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Results of my VFS scaling evaluation.
Message-ID: <20101010120309.GB8256@basil.fritz.box>
References: <1286580739.3153.57.camel@bobble.smo.corp.google.com>
 <20101009031609.GK4681@dastard>
 <87y6a6fsg4.fsf@basil.nowhere.org>
 <20101010073732.GA4097@infradead.org>
 <20101010082038.GA17133@basil.fritz.box>
 <20101010083749.GA8702@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101010083749.GA8702@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Andi Kleen <andi@firstfloor.org>, Dave Chinner <david@fromorbit.com>, Frank Mayhar <fmayhar@google.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, mrubin@google.com, torvalds@linux-foundation.org, viro@zeniv.linux.org.uk
List-ID: <linux-mm.kvack.org>

On Sun, Oct 10, 2010 at 04:37:49AM -0400, Christoph Hellwig wrote:
> On Sun, Oct 10, 2010 at 10:20:39AM +0200, Andi Kleen wrote:
> > > Certainly not for .37, where even the inode_lock splitup is pretty damn
> > > later.  Nick disappearing for a few weeks and others having to pick up
> > > the work to sort it out certainly doesn't help.  And the dcache_lock
> > > splitup is a much larget task than that anyway.  Getting that into .38
> > > is the enabler for doing more fancy things.  And as Dave mentioned at
> > > least in the writeback area it's much better to sort out the algorithmic
> > > problems now than to blindly split some locks up more.
> > 
> > I don't see why the algorithmic work can't be done in parallel 
> > to the lock split up?
> > 
> > Just the lock split up on its own gives us large gains here.
> 
> What about actually starting to test the stuff headed towards Al's tree
> to verify your assumptions?  It's nice to have a lot of people talking,

That's in the works. Previously all testing work was done
on Nick's patch series.

> but actually helping with review and testing would be more useful.

Well the constant refactoring is certainly not helping with testing.

Also what typically happens is that if we don't fix all the serious
VFS locking issues (like Nick's patch kit) we just move from one bottle 
neck to another.

> Yes, lots of things could be done in parallel, but it needs people to
> actually work on it.  And right now that's mostly Dave for the real
> work, with me trying to prepare a proper dcache series for .38, and Al
> doing some review.

It was not clear to me what was so horrible with Nick's original
patchkit?  Sure there were a few rough edges, but does it really
need to be fully redone?

It certainly held up great to lots of testing, both at our side
and apparently Google's too.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
