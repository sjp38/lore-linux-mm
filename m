Date: Mon, 25 Sep 2000 15:30:10 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
In-Reply-To: <20000926002812.C5010@athlon.random>
Message-ID: <Pine.LNX.4.10.10009251528330.820-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Rik van Riel <riel@conectiva.com.br>, "Stephen C. Tweedie" <sct@redhat.com>, Ingo Molnar <mingo@elte.hu>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Tue, 26 Sep 2000, Andrea Arcangeli wrote:
> 
> I'm talking about the fact that if you have a file mmapped in 1.5G of RAM
> test9 will waste time rolling between LRUs 384000 pages, while classzone
> won't ever see 1 of those pages until you run low on fs cache.

What drugs are you on? Nobody looks at the LRU's until the system is low
on memory. Sure, there's some background activity, but what are you
talking about? It's only when you're low on memory that _either_ approach
starts looking at the LRU list.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
