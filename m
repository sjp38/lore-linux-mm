Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5DC016B01CA
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 02:56:21 -0400 (EDT)
Subject: Re: [PATCH 15/35] x86, lmb: Add lmb_reserve_area_overlap_ok()
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <4C16C928.2000406@kernel.org>
References: <1273796396-29649-1-git-send-email-yinghai@kernel.org>
	 <1273796396-29649-16-git-send-email-yinghai@kernel.org>
	 <1273804337.21352.396.camel@pasglop> <4BECF158.5070200@oracle.com>
	 <1273825807.21352.601.camel@pasglop> <4BED7CE3.1020507@oracle.com>
	 <1273876234.21352.639.camel@pasglop>  <20100515073231.GB9877@elte.hu>
	 <1274056773.21352.700.camel@pasglop>  <4BF0DE0C.2000905@oracle.com>
	 <1274081072.21352.718.camel@pasglop>  <4BF17A50.1050905@oracle.com>
	 <1274133686.21352.755.camel@pasglop>  <4C09A9EA.6060005@oracle.com>
	 <1275702466.1931.1425.camel@pasglop>  <4C16C928.2000406@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 15 Jun 2010 16:55:43 +1000
Message-ID: <1276584943.2552.99.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Yinghai Lu <yinghai@kernel.org>
Cc: Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Paul Mundt <lethal@linux-sh.org>, Russell King <linux@arm.linux.org.uk>
List-ID: <linux-mm.kvack.org>

On Mon, 2010-06-14 at 17:28 -0700, Yinghai Lu wrote:
> On 06/04/2010 06:47 PM, Benjamin Herrenschmidt wrote:
> > On Fri, 2010-06-04 at 18:35 -0700, Yinghai Lu wrote:
> ..
> >> can you rebase powerpc/lmb, so we can put lmb for x86 changes to tip
> >> and next? 
> > 
> > I will. I've been kept busy with all sort of emergencies and the merge
> > window, but I will do that and a could of other things to it some time
> > next week.
> 
> Ping!

(Adding back the list)

I've updated the series (*) It's just a rebase from the previous one,
and one change: I don't allow resizing until after lmb_analyze() has run
since on various platforms, doing it too early such as when constructing
the memory array is risky as we haven't done the necessary lmb_reserve()
of whatever regions are unsuitable for allocation.

We can improve on that later, maybe by doing those reservations early,
before we add memory, or whatever, but that can wait.

Yinghai, is there any other chance you want me to do to the core ?

Another thing to add at some stage for ARM will be a default alloc base
in addition to limit, that constraints "standard" allocations.

(*) Usual place:

  git://git.kernel.org/pub/scm/linux/kernel/git/benh/powerpc.git lmb

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
