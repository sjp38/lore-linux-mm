Date: Sun, 24 Sep 2000 20:40:05 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: __GFP_IO && shrink_[d|i]cache_memory()?
In-Reply-To: <Pine.LNX.4.10.10009241101320.10311-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0009242038480.7843-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 24 Sep 2000, Linus Torvalds wrote:

> [...] I don't think shrinking the inode cache is actually illegal when
> GPF_IO isn't set. In fact, it's probably only the buffer cache itself
> that has to avoid recursion - the other stuff doesn't actually do any
> IO.

i just found this out by example, i'm running the shrink_[i|d]cache stuff
even if __GFP_IO is not set, and no problems so far. (and much better
balancing behavior)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
