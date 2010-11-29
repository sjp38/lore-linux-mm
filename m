Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A3DC56B0087
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 04:01:37 -0500 (EST)
Subject: Re: [PATCH 00/21] mm: Preemptibility -v6
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20101126143843.801484792@chello.nl>
References: <20101126143843.801484792@chello.nl>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 29 Nov 2010 20:00:20 +1100
Message-ID: <1291021220.32570.295.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>
List-ID: <linux-mm.kvack.org>


> Linus seems to want this to get some serious review and be pushed through
> Andrew (well, anybody but me actually, but since Andrew is mm master...)
> 
> Ben, Thomas, Andrew, can I trick you guys into looking at this stuff?

It's on my hot todo list this week :-)

I'd like to take out the rcu fix for ppc page table freeing tho and send
it to Linus now if you're ok with that.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
