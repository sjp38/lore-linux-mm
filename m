Date: Mon, 9 Oct 2000 21:05:03 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
Message-ID: <20001009210503.C19583@athlon.random>
References: <20001009202844.A19583@athlon.random> <Pine.LNX.4.21.0010092040300.6338-100000@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0010092040300.6338-100000@elte.hu>; from mingo@elte.hu on Mon, Oct 09, 2000 at 08:42:26PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Byron Stanoszek <gandalf@winds.org>, Rik van Riel <riel@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Oct 09, 2000 at 08:42:26PM +0200, Ingo Molnar wrote:
> ignoring the kill would just preserve those bugs artificially.

If the oom killer kills a thing like init by mistake or init has a memleak
you'll notice both problems regardless of having a magic for init in a _very_
slow path so I don't buy your point.
.
For corretness init must not be killed ever, period.

So you have two choices:

o	math proof that the current algorithm without the magic can't end
	killing init (and I should be able to proof the other way around
	instead)

o	have a magic check for init

So the magic is _strictly_ necessary at the moment.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
