Date: Mon, 25 Sep 2000 16:13:57 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: [patch] vmfixes-2.4.0-test9-B2
In-Reply-To: <20000925161358.J22882@athlon.random>
Message-ID: <Pine.LNX.4.21.0009251612180.9122-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2000, Andrea Arcangeli wrote:

> I was _only_ talking about the blkdev hangs [...]

i guess this was just miscommunication. It never 'hung', it just performed
reads with 20k/sec or so. (without any writes being done in the
background.) A 'hang' for me is a deadlock or lockup, not a slowdown.

> that caused you to unplug the queue at each reschedule in tux and that
> Eric reported me for the SG driver (and I very much hope that with
> EXCLUSIVE gone away and the wait_on_* fixed those hangs will go away
> because I don't see anything else wrong at this moment).

okay, i'll test this.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
