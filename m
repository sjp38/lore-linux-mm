Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 3598D8D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 09:30:02 -0400 (EDT)
Received: from canuck.infradead.org ([2001:4978:20e::1])
	by bombadil.infradead.org with esmtps (Exim 4.72 #1 (Red Hat Linux))
	id 1QCtxI-0004Oi-Gr
	for linux-mm@kvack.org; Thu, 21 Apr 2011 13:30:00 +0000
Received: from j77219.upc-j.chello.nl ([24.132.77.219] helo=dyad.programming.kicks-ass.net)
	by canuck.infradead.org with esmtpsa (Exim 4.72 #1 (Red Hat Linux))
	id 1QCtxH-00027n-IP
	for linux-mm@kvack.org; Thu, 21 Apr 2011 13:29:59 +0000
Subject: Re: [PATCH 14/20] mm: Remove i_mmap_lock lockbreak
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20110419130719.86093a27.akpm@linux-foundation.org>
References: <20110401121258.211963744@chello.nl>
	 <20110401121725.991633993@chello.nl>
	 <20110419130719.86093a27.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 21 Apr 2011 15:32:35 +0200
Message-ID: <1303392755.2035.141.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>

On Tue, 2011-04-19 at 13:07 -0700, Andrew Morton wrote:
> On Fri, 01 Apr 2011 14:13:12 +0200
> Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> 
> > Hugh says:
> >  "The only significant loser, I think, would be page reclaim (when
> >   concurrent with truncation): could spin for a long time waiting for
> >   the i_mmap_mutex it expects would soon be dropped? "
> > 
> > Counter points:
> >  - cpu contention makes the spin stop (need_resched())
> >  - zap pages should be freeing pages at a higher rate than reclaim
> >    ever can
> > 
> > I think the simplification of the truncate code is definately worth it.
> 
> Well, we don't need to guess.  These things are testable!

I suppose you're right, but I'm having a bit of a hard time coming up
with a sensible (reproducible) test case for the page reclaim part of
this problem set.

I'll try running 3 cyclic file scanners sized such that 2 exceed the
memory footprint of the machine and truncate the 3rd's file after
warming up.

That is, unless someone has a saner idea..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
