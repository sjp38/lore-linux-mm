Date: Mon, 25 Sep 2000 16:29:42 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: [patch] vmfixes-2.4.0-test9-B2
In-Reply-To: <20000925161358.J22882@athlon.random>
Message-ID: <Pine.LNX.4.21.0009251628030.9122-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2000, Andrea Arcangeli wrote:

> driver (and I very much hope that with EXCLUSIVE gone away and the
> wait_on_* fixed those hangs will go away because I don't see anything else
> wrong at this moment).

the EXCLUSIVE thing only optimizes the wakeup, it's not semantic! How
better is it to let 100 processes race for one freed-up request slot?
There is no guarantee at all that the reader will win. If reads and writes
racing for request slots ever becomes a problem then we should introduce a
separate read and write waitqueue.

the EXCLUSIVE thing was noticed by Dimitris i think, and it makes tons of
(performance) sense.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
