From: Daniel Phillips <phillips@innominate.de>
Subject: Re: Interesting item came up while working on FreeBSD's pageout daemon
Date: Fri, 29 Dec 2000 00:04:41 +0100
Content-Type: text/plain
References: <Pine.LNX.4.21.0012211741410.1613-100000@duckman.distro.conectiva>
In-Reply-To: <Pine.LNX.4.21.0012211741410.1613-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Message-Id: <00122900094502.00966@gimli>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Matthew Dillon <dillon@apollo.backplane.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 21 Dec 2000, Rik van Riel wrote:
> On Thu, 21 Dec 2000, Daniel Phillips wrote:
> > Matthew Dillon wrote:
> > >     My conclusion from this is that I was wrong before when I thought that
> > >     clean and dirty pages should be treated the same, and I was also wrong
> > >     trying to give clean pages 'ultimate' priority over dirty pages, but I
> > >     think I may be right giving dirty pages two go-arounds in the queue
> > >     before flushing.  Limiting the number of dirty page flushes allowed per
> > >     pass also works but has unwanted side effects.
> > 
> > Hi, I'm a newcomer to the mm world, but it looks like fun, so I'm
> > jumping in. :-)
> > 
> > It looks like what you really want are separate lru lists for
> > clean and dirty.  That way you can tune the rate at which dirty
> > vs clean pages are moved from active to inactive.
> 
> Let me clear up one thing. The whole clean/dirty story
> Matthew wrote down only goes for the *inactive* pages,
> not for the active ones...

Thanks for clearing that up, but it doesn't change the observation -
it still looks like he's keeping dirty pages 'on probation' twice as
long as before.  Having each page take an extra lap the inactive_dirty
list isn't exactly equivalent to just scanning the list more slowly,
but it's darn close.  Is there a fundamental difference?

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
