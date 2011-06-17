Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 05C8A6B0012
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 16:05:58 -0400 (EDT)
Date: Fri, 17 Jun 2011 13:04:34 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH] mm, memory-failure: Fix spinlock vs mutex order
Message-ID: <20110617200434.GC28954@tassilo.jf.intel.com>
References: <BANLkTim-dBjva9w7AajqggKT3iUVYG2euQ@mail.gmail.com>
 <BANLkTimLV8aCZ7snXT_Do+f4vRY0EkoS4A@mail.gmail.com>
 <BANLkTinUBTYWxrF5TCuDSQuFUAyivXJXjQ@mail.gmail.com>
 <1308310080.2355.19.camel@twins>
 <BANLkTim2bmPfeRT1tS7hx2Z85QHjPHwU3Q@mail.gmail.com>
 <alpine.LSU.2.00.1106171040460.7018@sister.anvils>
 <BANLkTim3vo0vpovV=5sU=GLxkotheB=Ryg@mail.gmail.com>
 <1308334688.12801.19.camel@laptop>
 <1308335557.12801.24.camel@laptop>
 <1308340385.12801.101.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1308340385.12801.101.camel@laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tim Chen <tim.c.chen@linux.intel.com>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, "Luck, Tony" <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, "Shi, Alex" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Rafael J. Wysocki" <rjw@sisk.pl>

> I thought about maybe using rcu, but then thought the thing is probably
> wanting to exclude new tasks as it wants to kill all mm users.

Probably both would work.

Looks good to me.  hwpoison patches are usually directly merged by Andrew 
these days.

Acked-by: Andi Kleen <ak@linux.intel.com>

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
