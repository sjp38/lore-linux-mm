Date: Mon, 25 Sep 2000 19:23:21 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2
Message-ID: <20000925192321.H27677@athlon.random>
References: <Pine.LNX.4.10.10009250940540.1739-100000@penguin.transmeta.com> <Pine.LNX.4.21.0009251859160.9122-100000@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0009251859160.9122-100000@elte.hu>; from mingo@elte.hu on Mon, Sep 25, 2000 at 07:05:02PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Linus Torvalds <torvalds@transmeta.com>, Jens Axboe <axboe@suse.de>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 07:05:02PM +0200, Ingo Molnar wrote:
> yep - and Jens i'm sorry about the outburst. Until a bug is found it's
> unrealistic to blame anything.

I think the only bug maybe to blame in the elevator is the EXCLUSIVE wakeup
thing (and I've not benchmarked it alone to see if it makes any real world
performance difference but for sure its behaviour wasn't intentional). Anything
else related to the elevator internals should perform better than the old
elevator (aka the 2.2.15 one). The new elevator ordering algorithm returns me
much better numbers than the CSCAN one with tiobench. Also consider the latency
control at the moment is completly disabled as default so there are no barriers
unless you change that with elvtune.

Also I'm using -r 250 and -w 500 and it doesn't change really anything in the
numbers compared to too big values (but it fixes the starvation problem).

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
