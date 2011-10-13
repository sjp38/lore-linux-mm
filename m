Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id DFA766B0179
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 17:03:01 -0400 (EDT)
Date: Thu, 13 Oct 2011 16:02:58 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH] Reduce vm_stat cacheline contention in
 __vm_enough_memory
In-Reply-To: <20111013135032.7c2c54cd.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1110131602020.26553@router.home>
References: <20111012160202.GA18666@sgi.com> <20111012120118.e948f40a.akpm@linux-foundation.org> <alpine.DEB.2.00.1110121452220.31218@router.home> <20111013152355.GB6966@sgi.com> <alpine.DEB.2.00.1110131052300.18473@router.home>
 <20111013135032.7c2c54cd.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dimitri Sivanich <sivanich@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>

On Thu, 13 Oct 2011, Andrew Morton wrote:

> > If there are no updates occurring for a while (due to increased deltas
> > and/or vmstat updates) then the vm_stat cacheline should be able to stay
> > in shared mode in multiple processors and the performance should increase.
> >
>
> We could cacheline align vm_stat[].  But the thing is pretty small - we
> couild put each entry in its own cacheline.

Which in turn would increase the cache footprint of some key kernel
functions (because they need multiple vm_stat entries) and cause eviction
of other cachelines that then reduce overall system performance again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
