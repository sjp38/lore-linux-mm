Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id C5A736B00A7
	for <linux-mm@kvack.org>; Sat, 30 Jun 2012 11:11:21 -0400 (EDT)
Received: by dakp5 with SMTP id p5so6871220dak.14
        for <linux-mm@kvack.org>; Sat, 30 Jun 2012 08:11:20 -0700 (PDT)
Message-ID: <4FEF1703.1070506@gmail.com>
Date: Sat, 30 Jun 2012 23:10:59 +0800
From: Nai Xia <nai.xia@gmail.com>
Reply-To: nai.xia@gmail.com
MIME-Version: 1.0
Subject: Re: [PATCH 13/40] autonuma: CPU follow memory algorithm
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com> <1340888180-15355-14-git-send-email-aarcange@redhat.com> <1340895238.28750.49.camel@twins> <CAJd=RBA+FPgB9iq07YG0Pd=tN65SGK1ifmj98tomBDbYeKOE-Q@mail.gmail.com> <20120629125517.GD32637@gmail.com> <4FEDDD0C.60609@redhat.com> <1340995986.28750.114.camel@twins> <CAPQyPG4R34bi0fXHBspSpR1+gDLj2PGYpPXNLPTTTBmrRL=m4g@mail.gmail.com> <20120630012338.GY6676@redhat.com> <CAPQyPG7Nx1Jdq7WBBDC41iRGOMx8CdQjcWTNOWyj1fzVeuRcgw@mail.gmail.com> <20120630124816.GZ6676@redhat.com>
In-Reply-To: <20120630124816.GZ6676@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, dlaor@redhat.com, Ingo Molnar <mingo@kernel.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>



On 2012a1'06ae??30ae?JPY 20:48, Andrea Arcangeli wrote:
> On Sat, Jun 30, 2012 at 10:43:41AM +0800, Nai Xia wrote:
>> Well, I think I am not convinced by your this many words. And surely
>> I  will NOT follow your reasoning of "Having information is always
>> good than nothing".  We all know that  an illy biased balancing is worse
>> than randomness:  at least randomness means "average, fair play, ...".
>
> The only way to get good performance like the hard bindings is to
> fully converge the load into one node (or as fewer nodes as possible),
> randomness won't get you very far in this case.

I think by now all people should all agree on that "converge the load
into one node" is correct. But I am just thinking your random sampling
is not doing its work. Your benchmark is good.

But just like my last post pointing out, I wonder if it's
only "converge the load into one node" playing a important role.
And if your random sampling is NOT really functioning as expected,
or having just a little gain in the whole benchmark. It may not
worth all its complexity.

>
>> With all uncertain things, I think only a comprehensive survey
>> of real world workloads can tell if my concern is significant or not.
>
> I welcome more real world tests.
>
> I'm just not particularly concerned about your concern. The young bit
> clearing during swapping would also be susceptible to your concern
> just to make another example. If that would be a problem swapping
> wouldn't possibly work ok either because pte_numa or pte_young works
> the same way. In fact pte_young is even less reliable because the scan
> frequency will be more variable so the phase effects will be even more
> visible.

You know what let me feel you are ignoring my words is that each
time you answer my mail with so many words, you keep losing my points
in the mail you answered:
Yes, pte_numa or pte_young works the same way and they both can
answer the problem of "which pages were accessed since last scan".
For LRU, it's OK, it's quite enough. But for numa balancing it's NOT.
We also should care about the hotness of the page sets, since if the
workloads are complex we should NOT be expecting that "if this page
is accessed once, then it's always in my CPU cache during the whole
last scan interval".

The difference between LRU and the problem you are trying to deal
with looks so obvious to me, I am so worried that you are still
messing them up :(


>
> The VM is an heuristic, it obviously doesn't need to be perfect at all
> times, what matters is the probability that it does the right thing.

Probability is just what I were talking about and expect you guys
to analyze, and the thing I am curious about.

Thanks,

Nai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
