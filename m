Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id AB1BA6B0012
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 16:55:54 -0400 (EDT)
Received: by gxk23 with SMTP id 23so630304gxk.14
        for <linux-mm@kvack.org>; Wed, 15 Jun 2011 13:55:52 -0700 (PDT)
References: <1308097798.17300.142.camel@schen9-DESK> <1308134200.15315.32.camel@twins> <1308135495.15315.38.camel@twins> <BANLkTikt88KnxTy8TuGGVrBVnXvsnL7nMQ@mail.gmail.com> <20110615122435.386731e0.akpm@linux-foundation.org> <20110615201611.GB4762@elte.hu>
In-Reply-To: <20110615201611.GB4762@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Subject: Re: REGRESSION: Performance regressions from switching anon_vma->lock to mutex
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 15 Jun 2011 13:55:25 -0700
Message-ID: <d3013ec4-8102-46a9-9e0d-e7253859ea38@email.android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Tim Chen <tim.c.chen@linux.intel.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Tony Luck <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, ak@linux.intel.com, shaohua.li@intel.com, alex.shi@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Rafael J. Wysocki" <rjw@sisk.pl>



Ingo Molnar <mingo@elte.hu> wrote:
>
>perf record -g will go a long way towards such a tool already - but i 
>think it would be useful to create a more top-alike view as well. 

perf record -g doesn't help when the issue is that we're recording a single process and the actual work is being done in another unrelated process that is just being woken up.

Sure, you can do a system wide recording, but that shows all kinds of unrelated noise and requires root permissions.

So those rcu threads really need to go.

      Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
