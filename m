Date: Mon, 25 Sep 2000 15:02:58 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: the new VM
In-Reply-To: <20000925150258.B13011@athlon.random>
Message-ID: <Pine.LNX.4.21.0009251501020.6224-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2000, Andrea Arcangeli wrote:

> Sorry I totally disagree. If GFP_KERNEL are garanteeded to succeed
> that is a showstopper bug. [...]

why?

> machine power for simulations runs out of memory all the time. If you
> put this kind of obvious deadlock into the main kernel allocator

FYI, i havent put it there.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
