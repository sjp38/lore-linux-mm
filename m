Date: Fri, 10 Mar 2000 16:14:10 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: a plea for mincore()/madvise()
In-Reply-To: <Pine.BSO.4.10.10003101825170.10894-100000@funky.monkey.org>
Message-ID: <Pine.LNX.4.10.10003101612470.906-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chuck Lever <cel@monkey.org>
Cc: James Manning <jmm@computer.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Fri, 10 Mar 2000, Chuck Lever wrote:
> 
> ja, that's exactly what my patch does.  i'm still not sure what you don't
> like about it.  i'm happy to make it do anything you want, but it sounds
> like we are in agreement here.

Ok. I may not have seen (or noticed) your patch, I've seen earlier patches
that didn't do that.

> my only sticking point is that i'm not sure what community consensus there
> is about MADV_DONTNEED.  i'd like to create a patch that implements
> everything except MADV_DONTNEED, then maybe we should have more discussion
> about exactly how that will work and add it later.

I'd like MADV_DONTNEED to just clear the page tables. If it was a private
mapping, all the modifications get lost. If it was a shared mapping,
modifications since the last msync() may or may not get lost. 

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
