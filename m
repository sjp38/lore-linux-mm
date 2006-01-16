Date: Mon, 16 Jan 2006 08:05:39 -0500 (EST)
From: Rik van Riel <riel@redhat.com>
Subject: Re: use-once-cleanup testing
In-Reply-To: <43C883AA.30101@cyberone.com.au>
Message-ID: <Pine.LNX.4.63.0601160803550.10902@cuia.boston.redhat.com>
References: <20060114000533.GA4111@dmt.cnet> <43C883AA.30101@cyberone.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, akpm@osdl.org, Peter Zijlstra <peter@programming.kicks-ass.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 14 Jan 2006, Nick Piggin wrote:

> Yes, I found that also doing use-once on mapped pages caused fairly huge 
> slowdowns in some cases. File IO could much more easily cause X and its 
> applications to get swapped out.

We can get rid of that effect easily by adding reclaim_mapped
logic to the inactive list scan.  The zone previous_priority
will keep track of what to do when we start a scan...

> Possibly. I think moving unmapped use-once over to PG_useonce first, and
> tidying the weird warts and special cases (that don't make sense) from
> vmscan is a good first step.

Agreed, cleaning up the code first will make it a lot easier
to make improvements bit by bit.

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
