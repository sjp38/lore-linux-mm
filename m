Date: Fri, 27 Dec 2002 12:18:23 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: shared pagetable benchmarking
In-Reply-To: <47580000.1041020194@[10.1.1.5]>
Message-ID: <Pine.LNX.4.44.0212271213180.21930-100000@home.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmc@austin.ibm.com>
Cc: Daniel Phillips <phillips@arcor.de>, Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 27 Dec 2002, Dave McCracken wrote:
> 
> I gave Andrew a patch that does make it break even on small forks, by doing
> the copy at fork time when a process only has 3 pte pages.  My tests
> indicate that any process with 4 or more pte pages usually is faster by
> doing the share.

Ok, so it doesn't actually break even, it just disables itself. That's not 
the same thing in my book, but may of course be acceptable.

I'd personally be much happier if just the real cause for the rmap
slowdown was fixed, possibly by having it be done lazily (the shared page
table stuff tries to do the _copy_ of the rmap information lazily, but
maybe the real solution is to go one level further and just set the dang
things up lazily in the first place, since most of the time it's not even
needed).

That's clearly not 2.6.x material. But at this point I doubt that shared
page tables are either, unless they fix something more important than 
fork() speed for processes that are larger than 16MB.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
