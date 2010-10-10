Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 631246B0085
	for <linux-mm@kvack.org>; Sun, 10 Oct 2010 03:37:50 -0400 (EDT)
Date: Sun, 10 Oct 2010 03:37:32 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Results of my VFS scaling evaluation.
Message-ID: <20101010073732.GA4097@infradead.org>
References: <1286580739.3153.57.camel@bobble.smo.corp.google.com>
 <20101009031609.GK4681@dastard>
 <87y6a6fsg4.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87y6a6fsg4.fsf@basil.nowhere.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Dave Chinner <david@fromorbit.com>, Frank Mayhar <fmayhar@google.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, mrubin@google.com, torvalds@linux-foundation.org, viro@zeniv.linux.org.uk
List-ID: <linux-mm.kvack.org>

On Sun, Oct 10, 2010 at 08:54:51AM +0200, Andi Kleen wrote:
> That would be over 6 months just to make even a little progress.

I think that's unfair.  There's been absolutely no work from Nick to
get things mergeable since 2.6.35-rc days where we gave him that
feedback.  We now have had Dave pick it up and sort out various issues
with the third or so of the patchset he needed most to sort the lock
contention problems in the workloads he saw, and we'll get large
improvements for those for .37.  The dcache_lock splitup alone is
another massive task that needs a lot more work, too.  I've started
reviewing it and already fixed tons issues in in and the surrounding
code.  

> Sorry, I am not convinced yet that any progress in this area has to be
> that glacial. Linus indicated last time he wanted to move faster on the
> VFS improvements. And the locking as it stands today is certainly a
> major problem.
> 
> Maybe it's possible to come up with a way to integrate this faster?

Certainly not for .37, where even the inode_lock splitup is pretty damn
later.  Nick disappearing for a few weeks and others having to pick up
the work to sort it out certainly doesn't help.  And the dcache_lock
splitup is a much larget task than that anyway.  Getting that into .38
is the enabler for doing more fancy things.  And as Dave mentioned at
least in the writeback area it's much better to sort out the algorithmic
problems now than to blindly split some locks up more.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
