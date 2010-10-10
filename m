Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C57D46B006A
	for <linux-mm@kvack.org>; Sun, 10 Oct 2010 04:20:43 -0400 (EDT)
Date: Sun, 10 Oct 2010 10:20:39 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Results of my VFS scaling evaluation.
Message-ID: <20101010082038.GA17133@basil.fritz.box>
References: <1286580739.3153.57.camel@bobble.smo.corp.google.com>
 <20101009031609.GK4681@dastard>
 <87y6a6fsg4.fsf@basil.nowhere.org>
 <20101010073732.GA4097@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101010073732.GA4097@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Andi Kleen <andi@firstfloor.org>, Dave Chinner <david@fromorbit.com>, Frank Mayhar <fmayhar@google.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, mrubin@google.com, torvalds@linux-foundation.org, viro@zeniv.linux.org.uk
List-ID: <linux-mm.kvack.org>

> Certainly not for .37, where even the inode_lock splitup is pretty damn
> later.  Nick disappearing for a few weeks and others having to pick up
> the work to sort it out certainly doesn't help.  And the dcache_lock
> splitup is a much larget task than that anyway.  Getting that into .38
> is the enabler for doing more fancy things.  And as Dave mentioned at
> least in the writeback area it's much better to sort out the algorithmic
> problems now than to blindly split some locks up more.

I don't see why the algorithmic work can't be done in parallel 
to the lock split up?

Just the lock split up on its own gives us large gains here.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
