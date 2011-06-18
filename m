Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2F1936B004A
	for <linux-mm@kvack.org>; Sat, 18 Jun 2011 04:09:01 -0400 (EDT)
Date: Sat, 18 Jun 2011 10:08:18 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: REGRESSION: Performance regressions from switching
 anon_vma->lock to mutex
Message-ID: <20110618080818.GA10351@elte.hu>
References: <BANLkTim5TPKQ9RdLYRxy=mphOVKw5EXvTA@mail.gmail.com>
 <1308255972.17300.450.camel@schen9-DESK>
 <BANLkTinptaydNvK4ZvGvy0KVLnRmmza7tA@mail.gmail.com>
 <BANLkTi=GPtwjQ-bYDNUYCwzW5h--y86Law@mail.gmail.com>
 <BANLkTim-dBjva9w7AajqggKT3iUVYG2euQ@mail.gmail.com>
 <BANLkTimLV8aCZ7snXT_Do+f4vRY0EkoS4A@mail.gmail.com>
 <BANLkTinUBTYWxrF5TCuDSQuFUAyivXJXjQ@mail.gmail.com>
 <1308310080.2355.19.camel@twins>
 <BANLkTin3onK+43LxODfbu-sdm-pFut0TKw@mail.gmail.com>
 <20110617194029.GA28954@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110617194029.GA28954@tassilo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Tim Chen <tim.c.chen@linux.intel.com>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, "Luck, Tony" <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, "Shi, Alex" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Rafael J. Wysocki" <rjw@sisk.pl>


* Andi Kleen <ak@linux.intel.com> wrote:

> On Fri, Jun 17, 2011 at 09:46:00AM -0700, Linus Torvalds wrote:
> > On Fri, Jun 17, 2011 at 4:28 AM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> > >
> > > Something like so? Compiles and runs the benchmark in question.
> > 
> > Oh, and can you do this with a commit log and sign-off, and I'll put
> > it in my "anon_vma-locking" branch that I have. I'm not going to
> > actually merge that branch into mainline until I've seen a few more
> > acks or more testing by Tim.
> > 
> > But if Tim's numbers hold up (-32% to +15% performance by just the
> > first one, and +15% isn't actually an improvement since tmpfs
> > read-ahead should have gotten us to +66%), I think we have to do this
> > just to avoid the performance regression.
> 
> You could also add the mutex "optimize caching protocol" 
> patch I posted earlier to that branch.
> 
> It didn't actually improve Tim's throughput number, but it made the 
> CPU consumption of the mutex go down.

Why have you ignored the negative feedback for that patch:

  http://marc.info/?i=20110617190705.GA26824@elte.hu

and why have you resent this patch without addressing that feedback?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
