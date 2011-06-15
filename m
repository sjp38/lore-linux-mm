Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 0676E6B0012
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 14:42:43 -0400 (EDT)
Subject: Re: REGRESSION: Performance regressions from switching
 anon_vma->lock to mutex
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <1308156337.2171.23.camel@laptop>
References: <1308097798.17300.142.camel@schen9-DESK>
	 <1308101214.15392.151.camel@sli10-conroe> <1308138750.15315.62.camel@twins>
	 <20110615161827.GA11769@tassilo.jf.intel.com>
	 <1308156337.2171.23.camel@laptop>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 15 Jun 2011 11:43:18 -0700
Message-ID: <1308163398.17300.147.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andi Kleen <ak@linux.intel.com>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, "Luck, Tony" <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, "Shi, Alex" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Rafael J. Wysocki" <rjw@sisk.pl>

On Wed, 2011-06-15 at 18:45 +0200, Peter Zijlstra wrote:
> On Wed, 2011-06-15 at 09:18 -0700, Andi Kleen wrote:
> 
> > And in general it looks like blind conversion from spinlock to mutex
> > is a bad idea right now.
> 
> For 4 socket machines, maybe. On 2 sockets I cannot reproduce anything.
> 
> I wonder if its the fairness thing, the mutex spinners aren't fifo fair
> like the ticket locks are. It could be significant with larger socket
> count since their cacheline arbitration is more sucky.
> 
> 
> 

Peter,

Wonder if you can provide the profile on your run so I can compare with
what I got on 4 sockets?

Thanks.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
