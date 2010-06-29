Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 2F3596B01B8
	for <linux-mm@kvack.org>; Tue, 29 Jun 2010 11:25:35 -0400 (EDT)
Date: Tue, 29 Jun 2010 10:21:55 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [S+Q 00/16] SLUB with Queueing beats SLAB in hackbench
In-Reply-To: <AANLkTimQr0iNLr4uwZwx8F9jasIsi1yoyIR8r6etMtW8@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1006291020240.16135@router.home>
References: <20100625212026.810557229@quilx.com> <20100626022441.GC29809@laptop> <AANLkTinOsPXdFc36mVDva-x0a0--gdFJuvWFQARwvx6y@mail.gmail.com> <alpine.DEB.2.00.1006280510370.8725@router.home> <AANLkTimQr0iNLr4uwZwx8F9jasIsi1yoyIR8r6etMtW8@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jun 2010, Pekka Enberg wrote:

> I guess "netperf TCP_RR" is the most interesting one because that's a
> known benchmark where SLUB performs poorly when compared to SLAB.
> Mel's extensive slab benchmarks are also worth looking at:

I will look at it when I get time but I am vacation right now and sitting
in the hospital with my son who managed to get himself there on the first
day of the "vacation". Guess it will take a week or so at least.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
