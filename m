Date: Fri, 10 Mar 2000 18:41:47 -0500 (EST)
From: Chuck Lever <cel@monkey.org>
Subject: Re: a plea for mincore()/madvise()
In-Reply-To: <Pine.LNX.4.10.10003101340130.11037-100000@penguin.transmeta.com>
Message-ID: <Pine.BSO.4.10.10003101825170.10894-100000@funky.monkey.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: James Manning <jmm@computer.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 10 Mar 2000, Linus Torvalds wrote:
> What I meant is really that the different "advices" are totally different.
> MADV_DONTNEED is an operation that probably walks the page tables and just
> throws the pages out (or just marks them old and uniniteresting).
> Similarly MADV_WILLNEED implies more of a "start doing something now" kind
> of thing. Neither would be flags in vma->vm_flags, because neither of them
> are really all that much of a "save this state for future behaviour" kind
> of thing.
> 
> In contrast, MADV_RANDOM is a flag that you'd set in vma->vm_flags, and
> would tell the page-in logic to not pre-fetch, because it doesn't pay off.
> And MADV_SEQUENTIAL would probably tell the page-in logic to pre-fetch
> very aggressively.

ja, that's exactly what my patch does.  i'm still not sure what you don't
like about it.  i'm happy to make it do anything you want, but it sounds
like we are in agreement here.

my only sticking point is that i'm not sure what community consensus there
is about MADV_DONTNEED.  i'd like to create a patch that implements
everything except MADV_DONTNEED, then maybe we should have more discussion
about exactly how that will work and add it later.

> The mprotect() routines that walk the page tables makes sense for
> MADV_DONTNEED and MADV_WILLNEED. It makes no sense at all for MADV_RANDOM
> and MADV_SEQUENTIAL, other than the actual vma _splitting_ part (as
> opposed to the actual page table walking part).

> See? I don't think the different advices are really comparable. It's
> different cases.

no argument from me, dude.  i was under the impression that mprotect only
modifies the vmflags, which is why i considered it useful for
random/sequential/normal.  haven't looked too closely at mprotect, though.

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
