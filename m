Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 7D7976B00A3
	for <linux-mm@kvack.org>; Sat, 30 Jun 2012 08:49:11 -0400 (EDT)
Date: Sat, 30 Jun 2012 14:48:16 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 13/40] autonuma: CPU follow memory algorithm
Message-ID: <20120630124816.GZ6676@redhat.com>
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com>
 <1340888180-15355-14-git-send-email-aarcange@redhat.com>
 <1340895238.28750.49.camel@twins>
 <CAJd=RBA+FPgB9iq07YG0Pd=tN65SGK1ifmj98tomBDbYeKOE-Q@mail.gmail.com>
 <20120629125517.GD32637@gmail.com>
 <4FEDDD0C.60609@redhat.com>
 <1340995986.28750.114.camel@twins>
 <CAPQyPG4R34bi0fXHBspSpR1+gDLj2PGYpPXNLPTTTBmrRL=m4g@mail.gmail.com>
 <20120630012338.GY6676@redhat.com>
 <CAPQyPG7Nx1Jdq7WBBDC41iRGOMx8CdQjcWTNOWyj1fzVeuRcgw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPQyPG7Nx1Jdq7WBBDC41iRGOMx8CdQjcWTNOWyj1fzVeuRcgw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nai Xia <nai.xia@gmail.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, dlaor@redhat.com, Ingo Molnar <mingo@kernel.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Sat, Jun 30, 2012 at 10:43:41AM +0800, Nai Xia wrote:
> Well, I think I am not convinced by your this many words. And surely
> I  will NOT follow your reasoning of "Having information is always
> good than nothing".  We all know that  an illy biased balancing is worse
> than randomness:  at least randomness means "average, fair play, ...".

The only way to get good performance like the hard bindings is to
fully converge the load into one node (or as fewer nodes as possible),
randomness won't get you very far in this case.

> With all uncertain things, I think only a comprehensive survey
> of real world workloads can tell if my concern is significant or not.

I welcome more real world tests.

I'm just not particularly concerned about your concern. The young bit
clearing during swapping would also be susceptible to your concern
just to make another example. If that would be a problem swapping
wouldn't possibly work ok either because pte_numa or pte_young works
the same way. In fact pte_young is even less reliable because the scan
frequency will be more variable so the phase effects will be even more
visible.

The VM is an heuristic, it obviously doesn't need to be perfect at all
times, what matters is the probability that it does the right thing.

> So I think my suggestion to you is:  Show world some solid and sound
> real world proof that your approximation is > 90% accurate, just like
> the pioneers already did to LRU(This problem is surely different from
> LRU. ).  Tons of words, will not do this.

http://www.kernel.org/pub/linux/kernel/people/andrea/autonuma/autonuma_bench-20120530.pdf
http://dl.dropbox.com/u/82832537/kvm-numa-comparison-0.png

There's more but I haven't updated them yet.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
