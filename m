Date: Mon, 9 Oct 2000 22:11:04 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
Message-ID: <20001009221104.J19583@athlon.random>
References: <20001009214214.G19583@athlon.random> <Pine.LNX.4.21.0010092156120.8045-100000@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0010092156120.8045-100000@elte.hu>; from mingo@elte.hu on Mon, Oct 09, 2000 at 10:06:02PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Rik van Riel <riel@conectiva.com.br>, Byron Stanoszek <gandalf@winds.org>, Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Oct 09, 2000 at 10:06:02PM +0200, Ingo Molnar wrote:
> i think the OOM algorithm should not kill processes that have
> process that has child processes likely results in unexpected behavior of

You just know what I think about those heuristics. I think all we need is a
per-task pagefault/allocation rate avoiding any other complication that tries
to do the right thing but that it will end doing the wrong thing eventually,
but obviously nobody agreeed with me and before I implement that myself it will
still take some time.

Even the total_vm information will be wrong for example if the task was a
netscape iconized and completly swapped out that wasn't running since two days.
Killing it is going to only delay the killing of the real offender that is
generating a flood of page faults at high frequency.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
