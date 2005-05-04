Date: Tue, 3 May 2005 18:23:47 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH/RFC 0/4] VM: Manual and Automatic page cache reclaim
Message-Id: <20050503182347.47abec55.akpm@osdl.org>
In-Reply-To: <20050503132102.GS19244@localhost>
References: <20050427150848.GR8018@localhost>
	<20050427233335.492d0b6f.akpm@osdl.org>
	<4277259C.6000207@engr.sgi.com>
	<20050503010846.508bbe62.akpm@osdl.org>
	<20050503132102.GS19244@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Hicks <mort@sgi.com>
Cc: raybry@engr.sgi.com, linux-mm@kvack.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

Martin Hicks <mort@sgi.com> wrote:
>
> 
> On Tue, May 03, 2005 at 01:08:46AM -0700, Andrew Morton wrote:
> > Ray Bryant <raybry@engr.sgi.com> wrote:
> > >
> > > ...
> > > One of the common responses to changes in the VM system for optimizations
> > > of this type is that we instead should devote our efforts to improving
> > > the VM system algorithms and that we are taking an "easy way out" by
> > > putting a hack into the VM system.
> > 
> > There's that plus the question which forever lurks around funky SGI patches:
> > 
> > 	How many machines in the world want this feature?
> > 
> > Because if the answer is "twelve" then gee it becomes hard to justify
> > merging things into the mainline kernel.  Particularly when they add
> > complexity to page reclaim.
> 
> And vendors seem hesitant because it isn't upstream.... chicken?  egg?
> 

That's between SGI and vendors, to some extent.  Generally, yes, I very
much want to keep vendor trees and the public tree in sync.  But a patch
like this is relatively intrusive, adds to long-term maintenance cost and
on the other hand is extremely specialised.  It's really hard to justify
adding this work to the public tree, IMO.

Which is why I'd like to see whether you can come up with something which
is either useful to a wider range of users or which adds less maintenance
complexity.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
