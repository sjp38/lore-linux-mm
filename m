Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 89BDC6B0082
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 02:59:21 -0400 (EDT)
Received: by vws4 with SMTP id 4so1341925vws.14
        for <linux-mm@kvack.org>; Wed, 15 Jun 2011 23:59:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1308178420.15617.447.camel@calx>
References: <1308169466.15617.378.camel@calx>
	<BANLkTi=QG3ywRhSx=npioJx-d=yyf=o29A@mail.gmail.com>
	<1308171355.15617.401.camel@calx>
	<20110615.181148.650483947691740732.davem@davemloft.net>
	<1308178420.15617.447.camel@calx>
Date: Thu, 16 Jun 2011 09:59:19 +0300
Message-ID: <BANLkTikOM6=fWnUA1bNZOM-jwg=o=CL8Ug@mail.gmail.com>
Subject: Re: [PATCH] slob: push the min alignment to long long
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: David Miller <davem@davemloft.net>, sebastian@breakpoint.cc, cl@linux-foundation.org, linux-mm@kvack.org, netfilter@vger.kernel.org

On Thu, Jun 16, 2011 at 1:53 AM, Matt Mackall <mpm@selenic.com> wrote:
>> Blink... because the compiler doesn't provide a portable way to
>> do this, right? :-)
>
> Because I, on x86, cannot deduce the alignment requirements of, say,
> CRIS without doing significant research. So answering a question like
> "are there any architectures where assumption X fails" is obnoxiously
> hard, rather than being a grep.
>
> I also don't think it's a given there's a portable way to deduce the
> alignment requirements due to the existence of arch-specific quirks. If
> an arch wants to kmalloc its weird crypto or SIMD context and those want
> 128-bit alignment, we're not going to want to embed that knowledge in
> the generic code, but instead tweak an arch define.
>
> Also note that not having generic defaults forces each new architectures
> to (nominally) examine each assumption rather than discover they
> inherited an incorrect default somewhere down the road.

I don't agree. I think we should either provide defaults that work for
everyone and let architectures override them (which AFAICT Christoph's
patch does) or we flat out #error if architectures don't specify
alignment requirements. The current solution seems to be the worst one
from practical point of view.

This doesn't seem to be a *regression* per se so I'll queue
Christoph's patch for 3.1 and mark it for 3.0-stable.

                            Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
