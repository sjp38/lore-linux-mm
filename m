Subject: Re: a plea for mincore()/madvise()
References: <Pine.BSO.4.10.10003101932390.16717-100000@funky.monkey.org>
From: Christoph Rohland <hans-christoph.rohland@sap.com>
Date: 11 Mar 2000 15:14:44 +0100
In-Reply-To: Chuck Lever's message of "Fri, 10 Mar 2000 19:39:03 -0500 (EST)"
Message-ID: <qwwd7p1ioff.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chuck Lever <cel@monkey.org>
Cc: Linus Torvalds <torvalds@transmeta.com>, James Manning <jmm@computer.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Chuck Lever <cel@monkey.org> writes:

> > I'd like MADV_DONTNEED to just clear the page tables. If it was a private
> > mapping, all the modifications get lost. If it was a shared mapping,
> > modifications since the last msync() may or may not get lost. 
> 
> i'll create a patch against 2.3.51-pre3 for madvise() and post it on the
> mm list before sunday.  then we can argue about something we've both seen
> :)
> 
> let me think some more about DONTNEED.  at the face of it, i agree with
> your suggestion, but i may just exclude it from the patch until there is
> more discussion here.

As stated before I would be very interested in a call (perhaps
MADV_DONTNEED) which throws away shared (anon) memory pages.

Greetings
		Christoph
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
