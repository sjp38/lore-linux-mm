Date: Tue, 26 Sep 2000 01:03:32 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
Message-ID: <20000926010332.G5010@athlon.random>
References: <20000926002812.C5010@athlon.random> <Pine.LNX.4.10.10009251528330.820-100000@penguin.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.10.10009251528330.820-100000@penguin.transmeta.com>; from torvalds@transmeta.com on Mon, Sep 25, 2000 at 03:30:10PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@conectiva.com.br>, "Stephen C. Tweedie" <sct@redhat.com>, Ingo Molnar <mingo@elte.hu>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 03:30:10PM -0700, Linus Torvalds wrote:
> On Tue, 26 Sep 2000, Andrea Arcangeli wrote:
> > 
> > I'm talking about the fact that if you have a file mmapped in 1.5G of RAM
> > test9 will waste time rolling between LRUs 384000 pages, while classzone
> > won't ever see 1 of those pages until you run low on fs cache.
> 
> What drugs are you on? Nobody looks at the LRU's until the system is low
> on memory. Sure, there's some background activity, but what are you

The system is low on memory when you run `free` and you see a value
< freepages_high*PAGE_SIZE in the "free" column first row.

> talking about? It's only when you're low on memory that _either_ approach
> starts looking at the LRU list.

The machine will run low on memory as soon as I read 200mbyte from disk.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
