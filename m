Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id DBB9C6B0069
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 04:31:56 -0400 (EDT)
Received: by dakp5 with SMTP id p5so8651928dak.14
        for <linux-mm@kvack.org>; Mon, 02 Jul 2012 01:31:56 -0700 (PDT)
Message-ID: <4FF15C6C.80009@gmail.com>
Date: Mon, 02 Jul 2012 16:31:40 +0800
From: Nai Xia <nai.xia@gmail.com>
Reply-To: nai.xia@gmail.com
MIME-Version: 1.0
Subject: Re: [PATCH 13/40] autonuma: CPU follow memory algorithm
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com> <1340888180-15355-14-git-send-email-aarcange@redhat.com> <1340895238.28750.49.camel@twins> <CAJd=RBA+FPgB9iq07YG0Pd=tN65SGK1ifmj98tomBDbYeKOE-Q@mail.gmail.com> <20120629125517.GD32637@gmail.com> <4FEDDD0C.60609@redhat.com> <1340995986.28750.114.camel@twins> <CAPQyPG4R34bi0fXHBspSpR1+gDLj2PGYpPXNLPTTTBmrRL=m4g@mail.gmail.com> <20120630012338.GY6676@redhat.com> <CAPQyPG7Nx1Jdq7WBBDC41iRGOMx8CdQjcWTNOWyj1fzVeuRcgw@mail.gmail.com> <20120630124816.GZ6676@redhat.com> <4FEF1703.1070506@gmail.com> <4FF14F62.2040702@redhat.com> <4FF15417.8020609@gmail.com> <4FF1590D.6020805@redhat.com>
In-Reply-To: <4FF1590D.6020805@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, dlaor@redhat.com, Ingo Molnar <mingo@kernel.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>



On 2012a1'07ae??02ae?JPY 16:17, Rik van Riel wrote:
> On 07/02/2012 03:56 AM, Nai Xia wrote:
>>
>>
>> On 2012a1'07ae??02ae?JPY 15:36, Rik van Riel wrote:
>>> On 06/30/2012 11:10 AM, Nai Xia wrote:
>>>
>>>> Yes, pte_numa or pte_young works the same way and they both can
>>>> answer the problem of "which pages were accessed since last scan".
>>>> For LRU, it's OK, it's quite enough. But for numa balancing it's NOT.
>>>
>>> Getting LRU right may be much more important than getting
>>> NUMA balancing right.
>>>
>>> Retrieving wrongly evicted data from disk can be a million
>>> of times slower than fetching data from RAM, while the
>>> penalty for accessing a remote NUMA node is only 20% or so.
>>>
>>>> We also should care about the hotness of the page sets, since if the
>>>> workloads are complex we should NOT be expecting that "if this page
>>>> is accessed once, then it's always in my CPU cache during the whole
>>>> last scan interval".
>>>>
>>>> The difference between LRU and the problem you are trying to deal
>>>> with looks so obvious to me, I am so worried that you are still
>>>> messing them up :(
>>>
>>> For autonuma, it may be fine to have a lower likelyhood of
>>> obtaining an optimum result, because the penalty for getting
>>> it wrong is so much lower.
>>
>> I said, I am actually want to see some detailed analysis
>> showing that this sampling is really playing an important role
>> in benchmarks as it claims to be. Not a quick
>> "lower likelyhood than optimum" conclusion.....
>>
>> Please, Rik, I know your points, you don't have to explain
>> anymore. But I just cannot follow without research data.
>
> What kind of data are you looking for?
>
> I have seen a lot of generic comments in your emails,
> and one gut feeling about Andrea's sampling algorithm,
> but I seem to have missed the details of exactly what
> you are looking for.
>
> Btw, I share your feeling that Andrea's sampling
> algorithm will probably not be able to distinguish
> between NUMA nodes that are very frequent users of
> a page, and NUMA nodes that use the same page much
> less frequently.
>
> However, I suspect that the penalty of getting it
> wrong will be fairly low, while the overhead of
> getting access frequency information will be
> prohibitively high. There is a reason nobody uses
> LRU nowadays, but a clock style algorithm instead.
>
>

I think I won't repeat myself again and again and
again and get lost in tons of words.

Thank you for your comments, Rik, and best wishes.
This is my last reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
