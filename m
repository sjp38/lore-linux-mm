Date: Mon, 13 Mar 2000 12:20:12 -0500 (EST)
From: Chuck Lever <cel@monkey.org>
Subject: Re: a plea for mincore()/madvise()
In-Reply-To: <14541.4418.281304.671792@dukat.scot.redhat.com>
Message-ID: <Pine.BSO.4.10.10003131215140.18890-100000@funky.monkey.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 13 Mar 2000, Stephen C. Tweedie wrote:
> > let me think some more about DONTNEED.  at the face of it, i agree with
> > your suggestion, but i may just exclude it from the patch until there is
> > more discussion here.
> 
> For what it's worth, Linus's request --- that DONTNEED throws stuff
> away without propagating dirty data --- is something that I've had big
> database folk asking us for more than once.

i believe that allowing an application to dispose of data this way is a
good idea, and that it's something that Linux should allow.  but there was
an interesting discussion here on linux-mm recently that described a
slightly different interface that would allow this and some other
functionality too.  i'd just like to study the suggestions a bit.

the rest of madvise is already implemented, i just have to port it to
2.3.51.  i'll post that piece of it soon.

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
