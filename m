Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id C7E6F6B004A
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 05:13:59 -0400 (EDT)
Date: Fri, 17 Jun 2011 11:13:19 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: REGRESSION: Performance regressions from switching
 anon_vma->lock to mutex
Message-ID: <20110617091319.GA11719@elte.hu>
References: <1308169937.15315.88.camel@twins>
 <4DF91CB9.5080504@linux.intel.com>
 <1308172336.17300.177.camel@schen9-DESK>
 <1308173849.15315.91.camel@twins>
 <87ea4bd7-8b16-4b24-8fcb-d8e9b6f421ec@email.android.com>
 <4DF92FE1.5010208@linux.intel.com>
 <BANLkTi=Tw6je7zpi4L=pE0JJpZfeEC9Jsg@mail.gmail.com>
 <4DFA6442.9000103@linux.intel.com>
 <BANLkTin_46==epHKUbWJ55bt3mPaJieV2Q@mail.gmail.com>
 <4DFA9EA4.4010904@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4DFA9EA4.4010904@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Tim Chen <tim.c.chen@linux.intel.com>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, "Luck, Tony" <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, "Shi, Alex" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, "Rafael J. Wysocki" <rjw@sisk.pl>


* Andi Kleen <ak@linux.intel.com> wrote:

> > I tried to send uli a patch to just add caching. No go. I sent 
> > *another* patch to at least make glibc use a sane interface (and 
> > the cache if it needs to fall back on /proc/stat for some legacy 
> > reason). We'll see what happens.
> 
> FWIW a rerun with this modified LD_PRELOAD that does caching seems 
> to have the same performance as the version that does 
> sched_getaffinity.
> 
> So you're right. Caching indeed helps and my assumption that the 
> child would only do it once was incorrect.

You should have known that your assumption was wrong not just from a 
quick look at the strace output or a quick look at the glibc sources, 
but also because i pointed out the caching angle to you in the 
sysconf() discussion:

  http://lkml.org/lkml/2011/5/14/9

repeatedly:

  http://lkml.org/lkml/2011/5/17/149

and Denys Vlasenko pointed out the caching angle as well:

  http://lkml.org/lkml/2011/5/17/183

But you kept pushing for your new syscall for upstream integration, 
ignoring all contrary evidence and ignoring all contrary feedback, 
without even *once* checking where and how it would integrate into 
glibc ...

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
