Date: Mon, 25 Sep 2000 16:18:13 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
In-Reply-To: <20000926010332.G5010@athlon.random>
Message-ID: <Pine.LNX.4.10.10009251617100.4587-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Rik van Riel <riel@conectiva.com.br>, "Stephen C. Tweedie" <sct@redhat.com>, Ingo Molnar <mingo@elte.hu>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Tue, 26 Sep 2000, Andrea Arcangeli wrote:
> 
> The machine will run low on memory as soon as I read 200mbyte from disk.

So? 

Yes, at that point we'll do the LRU dance. Then we won't be low on memory
any more, and we won't do the LRU dance any more. What's the magic in
zoneinfo that makes it not have to do the same thing?

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
