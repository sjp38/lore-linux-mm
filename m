Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 5EFB16B0062
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 03:56:23 -0400 (EDT)
Received: by dakp5 with SMTP id p5so8606458dak.14
        for <linux-mm@kvack.org>; Mon, 02 Jul 2012 00:56:22 -0700 (PDT)
Message-ID: <4FF15417.8020609@gmail.com>
Date: Mon, 02 Jul 2012 15:56:07 +0800
From: Nai Xia <nai.xia@gmail.com>
Reply-To: nai.xia@gmail.com
MIME-Version: 1.0
Subject: Re: [PATCH 13/40] autonuma: CPU follow memory algorithm
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com> <1340888180-15355-14-git-send-email-aarcange@redhat.com> <1340895238.28750.49.camel@twins> <CAJd=RBA+FPgB9iq07YG0Pd=tN65SGK1ifmj98tomBDbYeKOE-Q@mail.gmail.com> <20120629125517.GD32637@gmail.com> <4FEDDD0C.60609@redhat.com> <1340995986.28750.114.camel@twins> <CAPQyPG4R34bi0fXHBspSpR1+gDLj2PGYpPXNLPTTTBmrRL=m4g@mail.gmail.com> <20120630012338.GY6676@redhat.com> <CAPQyPG7Nx1Jdq7WBBDC41iRGOMx8CdQjcWTNOWyj1fzVeuRcgw@mail.gmail.com> <20120630124816.GZ6676@redhat.com> <4FEF1703.1070506@gmail.com> <4FF14F62.2040702@redhat.com>
In-Reply-To: <4FF14F62.2040702@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, dlaor@redhat.com, Ingo Molnar <mingo@kernel.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>



On 2012a1'07ae??02ae?JPY 15:36, Rik van Riel wrote:
> On 06/30/2012 11:10 AM, Nai Xia wrote:
>
>> Yes, pte_numa or pte_young works the same way and they both can
>> answer the problem of "which pages were accessed since last scan".
>> For LRU, it's OK, it's quite enough. But for numa balancing it's NOT.
>
> Getting LRU right may be much more important than getting
> NUMA balancing right.
>
> Retrieving wrongly evicted data from disk can be a million
> of times slower than fetching data from RAM, while the
> penalty for accessing a remote NUMA node is only 20% or so.
>
>> We also should care about the hotness of the page sets, since if the
>> workloads are complex we should NOT be expecting that "if this page
>> is accessed once, then it's always in my CPU cache during the whole
>> last scan interval".
>>
>> The difference between LRU and the problem you are trying to deal
>> with looks so obvious to me, I am so worried that you are still
>> messing them up :(
>
> For autonuma, it may be fine to have a lower likelyhood of
> obtaining an optimum result, because the penalty for getting
> it wrong is so much lower.

I said, I am actually want to see some detailed analysis
showing that this sampling is really playing an important role
in benchmarks as it claims to be. Not a quick
"lower likelyhood than optimum" conclusion.....

Please, Rik, I know your points, you don't have to explain
anymore. But I just cannot follow without research data.

If you think I am wrong. It's ok to ignore me from now.....

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
