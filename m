Date: Mon, 29 Jul 2002 03:37:12 -0400 (EDT)
From: Vladimir Dergachev <volodya@mindspring.com>
Reply-To: Vladimir Dergachev <volodya@mindspring.com>
Subject: Re: [RFC] start_aggressive_readahead
In-Reply-To: <3D44F01A.C7AAA1B4@zip.com.au>
Message-ID: <Pine.LNX.4.44.0207290330280.19060-100000@node2.localnet.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


> > > - It shrinks the window size in response to "misses"  - if
> > >   userspace requests a page which is *not* inside the previously-requested
> > >   window, the future window size is shrunk by 25%
> >
> > This one seems wierd.  If I reference a page that could have been in a
> > larger read-ahead window, shouldn't I make the window *larger* so that
> > next time, it *will* be in the window?
>
> That's true.  If the application is walking across a file
> touching every fifth page, readahead will stabilise at
> its minimum window size, which is less than five pages and
> we lose bigtime.   I'm not sure how to fix that while retaining
> some sanity in the code.

I am curious: which applications do you know of that actually do this ?

What about growing the window even if there is a miss as long as misses
are sequential and not further than a fixed amount from the window ?

                          Vladimir Dergachev


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
