Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id CAA686B01B2
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 06:15:45 -0400 (EDT)
Date: Mon, 28 Jun 2010 05:12:32 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [S+Q 00/16] SLUB with Queueing beats SLAB in hackbench
In-Reply-To: <AANLkTinOsPXdFc36mVDva-x0a0--gdFJuvWFQARwvx6y@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1006280510370.8725@router.home>
References: <20100625212026.810557229@quilx.com> <20100626022441.GC29809@laptop> <AANLkTinOsPXdFc36mVDva-x0a0--gdFJuvWFQARwvx6y@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jun 2010, Pekka Enberg wrote:

> > Hackbench I don't think is that interesting. SLQB was beating SLAB
> > too.
>
> We've seen regressions pop up with hackbench so I think it's
> interesting. Not the most interesting one, for sure, nor conclusive.
>
Hackbench was frequently cited in performance tests. Which benchmarks
would be of interest?  I am off this week so dont expect a fast response
from me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
