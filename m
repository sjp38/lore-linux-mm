Date: Fri, 10 Mar 2000 19:39:03 -0500 (EST)
From: Chuck Lever <cel@monkey.org>
Subject: Re: a plea for mincore()/madvise()
In-Reply-To: <Pine.LNX.4.10.10003101612470.906-100000@penguin.transmeta.com>
Message-ID: <Pine.BSO.4.10.10003101932390.16717-100000@funky.monkey.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: James Manning <jmm@computer.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 10 Mar 2000, Linus Torvalds wrote:
> On Fri, 10 Mar 2000, Chuck Lever wrote:
> > ja, that's exactly what my patch does.  i'm still not sure what you don't
> > like about it.  i'm happy to make it do anything you want, but it sounds
> > like we are in agreement here.
> 
> Ok. I may not have seen (or noticed) your patch, I've seen earlier patches
> that didn't do that.
> 
> > my only sticking point is that i'm not sure what community consensus there
> > is about MADV_DONTNEED.  i'd like to create a patch that implements
> > everything except MADV_DONTNEED, then maybe we should have more discussion
> > about exactly how that will work and add it later.
> 
> I'd like MADV_DONTNEED to just clear the page tables. If it was a private
> mapping, all the modifications get lost. If it was a shared mapping,
> modifications since the last msync() may or may not get lost. 

i'll create a patch against 2.3.51-pre3 for madvise() and post it on the
mm list before sunday.  then we can argue about something we've both seen
:)

let me think some more about DONTNEED.  at the face of it, i agree with
your suggestion, but i may just exclude it from the patch until there is
more discussion here.

	- Chuck Lever
--
corporate:	<chuckl@netscape.com>
personal:	<chucklever@netscape.net> or <cel@monkey.org>

The Linux Scalability project:
	http://www.citi.umich.edu/projects/linux-scalability/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
