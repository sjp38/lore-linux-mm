Date: Mon, 25 Sep 2000 18:02:18 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: the new VMt
In-Reply-To: <20000925174138.D25814@athlon.random>
Message-ID: <Pine.LNX.4.21.0009251747190.9122-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2000, Andrea Arcangeli wrote:

> Ingo's point is that the underlined line won't ever happen in the
> first place

please dont misinterpret my point ...

Frankly, how often do we allocate multi-order pages? I've just made quick
statistics wrt. how allocation orders are distributed on a more or less
typical system:

	(ALLOC ORDER)
	0: 167081
	1: 850
	2: 16
	3: 25
	4: 0
	5: 1
	6: 0
	7: 2
	8: 13
	9: 5

ie. 99.45% of all allocations are single-page! 0.50% is the 8kb
task-structure. The rest is 0.05%.

i'm not talking about 4MB contiguous physical allocations having to
succeed on a 8MB box. I'm talking about 99% of the simple allocation
points not having to worry about a NULL pointer. (not checking for NULL is
one of the most common allocation-related bug that beats low-RAM systems.)

	Ingo


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
