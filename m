Date: Fri, 11 May 2007 15:03:37 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/2] scalable rw_mutex
Message-ID: <20070511140337.GA3515@infradead.org>
References: <20070511131541.992688403@chello.nl> <20070511132321.895740140@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070511132321.895740140@chello.nl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@tv-sign.ru>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Fri, May 11, 2007 at 03:15:42PM +0200, Peter Zijlstra wrote:
> Scalable reader/writer lock.
> 
> Its scalable in that the read count is a percpu counter and the reader fast
> path does not write to a shared cache-line.
> 
> Its not FIFO fair, but starvation proof by alternating readers and writers.

While this implementation looks pretty nice I really hate growing more
and more locking primitives.  Do we have any rwsem user that absolutley
needs FIFO semantics or could we convert all user over (in which case
the objection above is of course completely moot)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
