Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B38046B0082
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 16:20:31 -0400 (EDT)
Subject: Re: REGRESSION: Performance regressions from switching
 anon_vma->lock to mutex
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <20110615201713.GC4762@elte.hu>
References: <1308097798.17300.142.camel@schen9-DESK>
	 <1308134200.15315.32.camel@twins> <1308135495.15315.38.camel@twins>
	 <BANLkTikt88KnxTy8TuGGVrBVnXvsnL7nMQ@mail.gmail.com>
	 <1308168784.17300.152.camel@schen9-DESK>  <20110615201713.GC4762@elte.hu>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 15 Jun 2011 13:21:05 -0700
Message-ID: <1308169265.17300.153.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Tony Luck <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, ak@linux.intel.com, shaohua.li@intel.com, alex.shi@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Rafael J. Wysocki" <rjw@sisk.pl>

On Wed, 2011-06-15 at 22:17 +0200, Ingo Molnar wrote:

> 
> have you used callgraph profiling (perf record -g) or flat profiling? 
> Flat profiling can be misleading when there's proxy work done.
> 

I've used callgraph profiling to see the call stack.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
