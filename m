Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 8D5666B00A9
	for <linux-mm@kvack.org>; Sat, 30 Jun 2012 11:19:51 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so7084407pbb.14
        for <linux-mm@kvack.org>; Sat, 30 Jun 2012 08:19:50 -0700 (PDT)
Message-ID: <4FEF1908.80701@gmail.com>
Date: Sat, 30 Jun 2012 23:19:36 +0800
From: Nai Xia <nai.xia@gmail.com>
Reply-To: nai.xia@gmail.com
MIME-Version: 1.0
Subject: Re: [PATCH 13/40] autonuma: CPU follow memory algorithm
References: <1340895238.28750.49.camel@twins> <CAJd=RBA+FPgB9iq07YG0Pd=tN65SGK1ifmj98tomBDbYeKOE-Q@mail.gmail.com> <20120629125517.GD32637@gmail.com> <4FEDDD0C.60609@redhat.com> <1340995986.28750.114.camel@twins> <CAPQyPG4R34bi0fXHBspSpR1+gDLj2PGYpPXNLPTTTBmrRL=m4g@mail.gmail.com> <20120630012338.GY6676@redhat.com> <CAPQyPG7Nx1Jdq7WBBDC41iRGOMx8CdQjcWTNOWyj1fzVeuRcgw@mail.gmail.com> <4FEE9310.1050908@redhat.com> <CAPQyPG50wtowNsPm1UADCNchY-gFk-cKW8oiU34L2REybhNoEg@mail.gmail.com> <20120630130446.GB6676@redhat.com>
In-Reply-To: <20120630130446.GB6676@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: dlaor@redhat.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>



On 2012a1'06ae??30ae?JPY 21:04, Andrea Arcangeli wrote:
> On Sat, Jun 30, 2012 at 02:58:29PM +0800, Nai Xia wrote:
>> OK, I think I'd stop discussing this topic now. Without strict and comprehensive
>> research on this topic, further arguments seems to me to be purely based on
>> imagination.
>
> I suggest to consider how ptep_clear_and_test_young works on the
> pte_young bit on the VM swapping code. Then apply your "concern" to
> the pte_young bit scan. If you can't NAK the swapping code in the
> kernel, well I guess you can't nack AutoNUMA as well because of that
> specific concern.
>
> And no I'm not saying this is trivial or obvious, I appreciate your
> thoughts a lot, just I'm quite convinced this is a subtle detail but
> an irrelevant one that gets lost in the noise.
>
>> If you insist on ignoring any constructive suggestions from others,
>> it's pretty much ok to do so.  But I (and possibly many others who are
>> watching)
>> am pretty much  possible to do a LOL to your development style.
>
> Well if you think answering your emails means ignoring your
> suggestions, be my guest.

Thanks for you kindness, I was just feeling a little bit uncomfortable
about Dor's tune of "Anyone can beat anything". It's OK now, since
anyone with eyes can easily find out I am not a spamming person on
this list.


Thanks,
Nai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
