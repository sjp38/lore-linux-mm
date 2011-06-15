Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id B3F7B6B0012
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 16:47:56 -0400 (EDT)
Received: by yia13 with SMTP id 13so630303yia.14
        for <linux-mm@kvack.org>; Wed, 15 Jun 2011 13:47:55 -0700 (PDT)
References: <1308097798.17300.142.camel@schen9-DESK> <1308134200.15315.32.camel@twins> <1308135495.15315.38.camel@twins> <BANLkTikt88KnxTy8TuGGVrBVnXvsnL7nMQ@mail.gmail.com> <20110615201216.GA4762@elte.hu> <20110615202956.GG2267@linux.vnet.ibm.com>
In-Reply-To: <20110615202956.GG2267@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Subject: Re: [GIT PULL] Re: REGRESSION: Performance regressions from switching anon_vma->lock to mutex
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 15 Jun 2011 13:47:33 -0700
Message-ID: <5a89bf11-4c80-418b-b2ff-ae904983ebb8@email.android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, Ingo Molnar <mingo@elte.hu>
Cc: Peter Zijlstra <peterz@infradead.org>, Tim Chen <tim.c.chen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Tony Luck <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, ak@linux.intel.com, shaohua.li@intel.com, alex.shi@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Rafael J. Wysocki" <rjw@sisk.pl>



"Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:
>
>It would be much lower risk to make the current code always use softirq
>if !RCU_BOOST -- last time I attempted the revert, it was quite hairy.

I don't care if it's a real revert or not, but I want the threads gone. Entirely. Not just the patch that uses softirqs for some things, and threads for the callbacks. No, I don't want the threads to show up or exist at all.

And to be sure, I'd like the code to set up and use the threads to actually compile away statically, so that there clearly isn't some way it's partially enabled.

        Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
