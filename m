Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id CC7D46B0012
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 18:19:14 -0400 (EDT)
Message-ID: <4DF92FE1.5010208@linux.intel.com>
Date: Wed, 15 Jun 2011 15:19:13 -0700
From: Andi Kleen <ak@linux.intel.com>
MIME-Version: 1.0
Subject: Re: REGRESSION: Performance regressions from switching anon_vma->lock
 to mutex
References: <1308097798.17300.142.camel@schen9-DESK> <1308101214.15392.151.camel@sli10-conroe> <1308138750.15315.62.camel@twins> <20110615161827.GA11769@tassilo.jf.intel.com> <1308156337.2171.23.camel@laptop> <1308163398.17300.147.camel@schen9-DESK> <1308169937.15315.88.camel@twins> <4DF91CB9.5080504@linux.intel.com> <1308172336.17300.177.camel@schen9-DESK> <1308173849.15315.91.camel@twins> <87ea4bd7-8b16-4b24-8fcb-d8e9b6f421ec@email.android.com>
In-Reply-To: <87ea4bd7-8b16-4b24-8fcb-d8e9b6f421ec@email.android.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Tim Chen <tim.c.chen@linux.intel.com>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, "Luck, Tony" <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, "Shi, Alex" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Rafael J. Wysocki" <rjw@sisk.pl>


> Yeah, I think it's ridiculous to say that glibc is not doing something stupid and that it's a problem with kernel interfaces.
>
> Do the proc file parsing once and cache the result in a static variable. Doing it over and over again is just crazy.
>
> Adding new system calls because glibc is crazy is insane.

Caching doesn't help because the library gets reinitialized in every child
(it may already do caching, not fully sure for this; it does it for 
other sysconfs at least)

I don't think glibc is crazy in this. It has no other choice.

-Andi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
