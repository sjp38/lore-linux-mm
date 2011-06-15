Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id DED416B0012
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 08:50:36 -0400 (EDT)
Subject: Re: REGRESSION: Performance regressions from switching
 anon_vma->lock to mutex
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1308138750.15315.62.camel@twins>
References: <1308097798.17300.142.camel@schen9-DESK>
	 <1308101214.15392.151.camel@sli10-conroe> <1308138750.15315.62.camel@twins>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 15 Jun 2011 14:49:36 +0200
Message-ID: <1308142176.15315.78.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, "Luck, Tony" <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, "ak@linux.intel.com" <ak@linux.intel.com>, "Shi, Alex" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Rafael J. Wysocki" <rjw@sisk.pl>

On Wed, 2011-06-15 at 13:52 +0200, Peter Zijlstra wrote:
> /me goes re-test without the sirq-rcu bits mixed in just to make sure.

I switched from PREEMPT=3Dn to PREEMPT_VOLUNTARY=3Dy, which seemed to make =
a
difference:

.39             257.651 messages/sec/core
-tip            254.976 messages/sec/core
    +linus      258.03  messages/sec/core
    +sirq       265.951 messages/sec/core


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
