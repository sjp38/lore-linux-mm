Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 285336B003D
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 00:24:23 -0500 (EST)
Date: Mon, 9 Feb 2009 21:23:56 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] mm fix page writeback accounting to fix oom condition
 under heavy I/O
In-Reply-To: <20090210033652.GA28435@Krystal>
Message-ID: <alpine.LFD.2.00.0902092120450.3048@localhost.localdomain>
References: <20090120122855.GF30821@kernel.dk> <20090120232748.GA10605@Krystal> <20090123220009.34DF.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20090210033652.GA28435@Krystal>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jens Axboe <jens.axboe@oracle.com>, akpm@linux-foundation.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@elte.hu>, thomas.pi@arcor.dea, Yuriy Lalym <ylalym@gmail.com>, ltt-dev@lists.casi.polymtl.ca, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Mon, 9 Feb 2009, Mathieu Desnoyers wrote:
> 
> So this patch fixes this behavior by only decrementing the page accounting
> _after_ the block I/O writepage has been done.

This makes no sense, really.

Or rather, I don't mind the notion of updating the counters only after IO 
per se, and _that_ part of it probably makes sense. But why is it that you 
only then fix up two of the call-sites. There's a lot more call-sites than 
that for this function. 

So if this really makes a big difference, that's an interesting starting 
point for discussion, but I don't see how this particular patch could 
possibly be the right thing to do.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
