Date: Mon, 13 Mar 2000 09:43:39 +0100 (MET)
From: Richard Guenther <richard.guenther@student.uni-tuebingen.de>
Subject: Re: a plea for mincore()/madvise()
In-Reply-To: <qwwd7p1ioff.fsf@sap.com>
Message-ID: <Pine.LNX.4.10.10003130943040.2650-100000@linux17.zdv.uni-tuebingen.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <hans-christoph.rohland@sap.com>
Cc: Chuck Lever <cel@monkey.org>, Linus Torvalds <torvalds@transmeta.com>, James Manning <jmm@computer.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 11 Mar 2000, Christoph Rohland wrote:

> Chuck Lever <cel@monkey.org> writes:
> 
> > > I'd like MADV_DONTNEED to just clear the page tables. If it was a private
> > > mapping, all the modifications get lost. If it was a shared mapping,
> > > modifications since the last msync() may or may not get lost. 
> > 
> > i'll create a patch against 2.3.51-pre3 for madvise() and post it on the
> > mm list before sunday.  then we can argue about something we've both seen
> > :)
> > 
> > let me think some more about DONTNEED.  at the face of it, i agree with
> > your suggestion, but i may just exclude it from the patch until there is
> > more discussion here.
> 
> As stated before I would be very interested in a call (perhaps
> MADV_DONTNEED) which throws away shared (anon) memory pages.

I would like to have it throw away non anonymous shared pages, too.

Richard.

--
Richard Guenther <richard.guenther@student.uni-tuebingen.de>
WWW: http://www.anatom.uni-tuebingen.de/~richi/
The GLAME Project: http://www.glame.de/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
