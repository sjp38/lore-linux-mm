Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D00276B0082
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 16:16:58 -0400 (EDT)
Date: Wed, 15 Jun 2011 22:16:11 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: REGRESSION: Performance regressions from switching
 anon_vma->lock to mutex
Message-ID: <20110615201611.GB4762@elte.hu>
References: <1308097798.17300.142.camel@schen9-DESK>
 <1308134200.15315.32.camel@twins>
 <1308135495.15315.38.camel@twins>
 <BANLkTikt88KnxTy8TuGGVrBVnXvsnL7nMQ@mail.gmail.com>
 <20110615122435.386731e0.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110615122435.386731e0.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Tim Chen <tim.c.chen@linux.intel.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Tony Luck <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, ak@linux.intel.com, shaohua.li@intel.com, alex.shi@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Rafael J. Wysocki" <rjw@sisk.pl>


* Andrew Morton <akpm@linux-foundation.org> wrote:

> It could be that if more things move away from dedicated threads 
> and into worker threads, we'll need to build a separate accounting 
> system so we can see how much time worker threads are spending on a 
> per-handler basis.  Which means a new top-like tool, etc.

perf record -g will go a long way towards such a tool already - but i 
think it would be useful to create a more top-alike view as well. 

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
