Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id BE9336B0034
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 04:43:30 -0400 (EDT)
Received: by mail-wi0-f174.google.com with SMTP id hj3so1599640wib.7
        for <linux-mm@kvack.org>; Tue, 03 Sep 2013 01:43:29 -0700 (PDT)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
In-Reply-To: <5225949C.9030201@colorfullife.com>
References: <CA+icZUXuw7QBn4CPLLuiVUjHin0m6GRdbczGw=bZY+Z60sXNow@mail.gmail.com>
	<521DE5D7.4040305@synopsys.com>
	<CA+icZUUrZG8pYqKcHY3DcYAuuw=vbdUvs6ZXDq5meBMjj6suFg@mail.gmail.com>
	<C2D7FE5348E1B147BCA15975FBA23075140FA3@IN01WEMBXA.internal.synopsys.com>
	<CA+icZUUn-r8iq6TVMAKmgJpQm4FhOE4b4QN_Yy=1L=0Up=rkBA@mail.gmail.com>
	<52205597.3090609@synopsys.com>
	<CA+icZUW=YXMC_2Qt=cYYz6w_fVW8TS4=Pvbx7BGtzjGt+31rLQ@mail.gmail.com>
	<C2D7FE5348E1B147BCA15975FBA230751411CB@IN01WEMBXA.internal.synopsys.com>
	<CALE5RAvaa4bb-9xAnBe07Yp2n+Nn4uGEgqpLrKMuOE8hhZv00Q@mail.gmail.com>
	<CAMJEocr1SgxQw0bEzB3Ti9bvRY74TE5y9e+PLUsAL1mJbK=-ew@mail.gmail.com>
	<CA+55aFy8tbBpac57fU4CN3jMDz46kCKT7+7GCpb18CscXuOnGA@mail.gmail.com>
	<C2D7FE5348E1B147BCA15975FBA230751413F4@IN01WEMBXA.internal.synopsys.com>
	<5224BCF6.2080401@colorfullife.com>
	<CA+icZUVc6fhW+TTB56x68LooS8DqhA8n3CQzgKkXQmbyH+ryUQ@mail.gmail.com>
	<C2D7FE5348E1B147BCA15975FBA2307514160B@IN01WEMBXA.internal.synopsys.com>
	<5225949C.9030201@colorfullife.com>
Date: Tue, 3 Sep 2013 10:43:29 +0200
Message-ID: <CA+icZUWPHR5Kkd_s1DyK+0jXAh8SobGjW_qeqUMrY4cSwkQmHQ@mail.gmail.com>
Subject: Re: ipc-msg broken again on 3.11-rc7?
From: Sedat Dilek <sedat.dilek@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: Vineet Gupta <Vineet.Gupta1@synopsys.com>, Linus Torvalds <torvalds@linux-foundation.org>, Davidlohr Bueso <dave.bueso@gmail.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, linux-next <linux-next@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Jonathan Gonzalez <jgonzalez@linets.cl>

On Tue, Sep 3, 2013 at 9:49 AM, Manfred Spraul <manfred@colorfullife.com> wrote:
> Hi Vineet,
>
>
> On 09/03/2013 09:34 AM, Vineet Gupta wrote:
>
> However assuming we are going ahead with debugging this - can you please
> confirm whether you see the issue on x86 as well as I have not tested that ?
> I vaguely remember one of your earlier posts suggested you did Thx, -Vineet
>
> I'm unable to reproduce the issue so far. I ran
> - something like 4000 stock msgctl08 with 4 cores on x86.
> - a few runs with modified msgctl08 with either slowed down reader or slowed
> down writer threads. (i.e.: force queue full or queue empty waits).
> - a few runs (modified&unmodified) with all but one core taken offline.
>

Cool.
Manfred, can you offer your modified test-cases, please?
Thanks in advance.

- Sedat -

> I have not yet tested with PREEMPT enabled.
>
> A few more ideas:
> - what is the output of ipcs -q? Are the queues empty or full?
> - what is the output of then WCHAN field with ps when it hangs?
> Something like
>  #ps -o pid,f,stat,pcpu,pmem,psr,wchan=WIDE-WCHAN -o comm,args
>
> --
>     Manfred

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
