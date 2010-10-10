Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E13A06B006A
	for <linux-mm@kvack.org>; Sun, 10 Oct 2010 04:38:08 -0400 (EDT)
Date: Sun, 10 Oct 2010 04:37:49 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Results of my VFS scaling evaluation.
Message-ID: <20101010083749.GA8702@infradead.org>
References: <1286580739.3153.57.camel@bobble.smo.corp.google.com>
 <20101009031609.GK4681@dastard>
 <87y6a6fsg4.fsf@basil.nowhere.org>
 <20101010073732.GA4097@infradead.org>
 <20101010082038.GA17133@basil.fritz.box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101010082038.GA17133@basil.fritz.box>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Frank Mayhar <fmayhar@google.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, mrubin@google.com, torvalds@linux-foundation.org, viro@zeniv.linux.org.uk
List-ID: <linux-mm.kvack.org>

On Sun, Oct 10, 2010 at 10:20:39AM +0200, Andi Kleen wrote:
> > Certainly not for .37, where even the inode_lock splitup is pretty damn
> > later.  Nick disappearing for a few weeks and others having to pick up
> > the work to sort it out certainly doesn't help.  And the dcache_lock
> > splitup is a much larget task than that anyway.  Getting that into .38
> > is the enabler for doing more fancy things.  And as Dave mentioned at
> > least in the writeback area it's much better to sort out the algorithmic
> > problems now than to blindly split some locks up more.
> 
> I don't see why the algorithmic work can't be done in parallel 
> to the lock split up?
> 
> Just the lock split up on its own gives us large gains here.

What about actually starting to test the stuff headed towards Al's tree
to verify your assumptions?  It's nice to have a lot of people talking,
but actually helping with review and testing would be more useful.

Yes, lots of things could be done in parallel, but it needs people to
actually work on it.  And right now that's mostly Dave for the real
work, with me trying to prepare a proper dcache series for .38, and Al
doing some review.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
