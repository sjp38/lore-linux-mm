Date: Mon, 25 Sep 2000 15:10:51 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: [patch] vmfixes-2.4.0-test9-B2
In-Reply-To: <20000925145856.A13011@athlon.random>
Message-ID: <Pine.LNX.4.21.0009251504220.6224-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2000, Andrea Arcangeli wrote:

> > yet another elevator algorithm we need a squeaky clean VM balancer above
> 
> FYI: My current tree (based on 2.4.0-test8-pre5) delivers 16mbyte/sec
> in the tiobench write test compared to clean 2.4.0-test8-pre5 that
> delivers 8mbyte/sec

great! I'm happy we have a fine-tuned elevator again.

> Also I I found the reason of your hang, it's the TASK_EXCLUSIVE in
> wait_for_request. The high part of the queue is reserved for reads.
> Now if a read completes and it wakeups a write you'll hang.

yep. But i dont understand why this makes any difference - the waitqueue
wakeup is FIFO, so any other request will eventually arrive. Could you
explain this bug a bit better?

> If you think I should delay those fixes to do something else I don't
> agree sorry.

no, i never ment it. I find it very good that those half-done changes are
cleaned up and the remaining bugs / performance problems are eliminated -
the first reports about bad write performance came right after the
original elevator patches went in, about 6 months ago.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
