Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A59796B0082
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 16:17:44 -0400 (EDT)
Date: Wed, 15 Jun 2011 22:17:13 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: REGRESSION: Performance regressions from switching
 anon_vma->lock to mutex
Message-ID: <20110615201713.GC4762@elte.hu>
References: <1308097798.17300.142.camel@schen9-DESK>
 <1308134200.15315.32.camel@twins>
 <1308135495.15315.38.camel@twins>
 <BANLkTikt88KnxTy8TuGGVrBVnXvsnL7nMQ@mail.gmail.com>
 <1308168784.17300.152.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1308168784.17300.152.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Tony Luck <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, ak@linux.intel.com, shaohua.li@intel.com, alex.shi@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Rafael J. Wysocki" <rjw@sisk.pl>


* Tim Chen <tim.c.chen@linux.intel.com> wrote:

> On Wed, 2011-06-15 at 12:11 -0700, Linus Torvalds wrote:
> 
> > 
> > And it results in real problems. For example, if you use "perf record"
> > to see what the hell is up, the use of kernel threads for RCU
> > callbacks means that the RCU cost is never even seen. I don't know how
> > Tim did his profiling to figure out the costs, and I don't know how he
> > decided that the spinlock to semaphore conversion was the culprit, but
> > it is entirely possible that Tim didn't actually bisect the problem,
> > but instead used "perf record" on the exim task, saw that the
> > semaphore costs had gone up, and decided that it must be the
> > conversion.
> > 
> 
> Yes, I was using perf to do the profiling. I thought that the mutex 
> conversion was the most likely culprit based on the change in 
> profile.

have you used callgraph profiling (perf record -g) or flat profiling? 
Flat profiling can be misleading when there's proxy work done.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
