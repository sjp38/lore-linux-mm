From: lord@sgi.com
Message-Id: <200006281652.LAA19162@jen.americas.sgi.com>
Subject: Re: kmap_kiobuf() 
In-reply-to: Your message of "Wed, 28 Jun 2000 12:24:06 EDT
Date: Wed, 28 Jun 2000 11:52:40 -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: David Woodhouse <dwmw2@infradead.org>, lord@sgi.com, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Wed, 28 Jun 2000, David Woodhouse wrote:
> 
> > MM is not exactly my field - I just know I want to be able to lock down a 
> > user's buffer and treat it as if it were in kernel-space, passing its 
> > address to functions which expect kernel buffers.
> 
> Then pass in a kiovec (we're planning on adding a rw_kiovec file op!) and
> use kmap/kmap_atomic on individual pages as required.  As to providing
> larger kmaps, I have yet to be convinced that providing primatives for
> dealing with objects larger than PAGE_SIZE is a Good Idea. 
> 
> 		-ben

I agree with trying to minimize things which require TLB flushes, we just
have 112 thousand lines of existing code (OK, lots of comments in that)
which wants to use things bigger than a page, and use them in ways which
are sometimes not going to be amenable to rewriting to use an array of pages,
not to mention rewriting would destabilize the code base.

I am not a VM guy either, Ben, is the cost of the TLB flush mostly in
the synchronization between CPUs, or is it just expensive anyway you
look at it?


Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
