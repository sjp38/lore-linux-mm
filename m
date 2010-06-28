Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 93891600227
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 10:46:46 -0400 (EDT)
Subject: Re: [S+Q 00/16] SLUB with Queueing beats SLAB in hackbench
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <AANLkTinOsPXdFc36mVDva-x0a0--gdFJuvWFQARwvx6y@mail.gmail.com>
References: <20100625212026.810557229@quilx.com>
	 <20100626022441.GC29809@laptop>
	 <AANLkTinOsPXdFc36mVDva-x0a0--gdFJuvWFQARwvx6y@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 28 Jun 2010 09:46:42 -0500
Message-ID: <1277736402.28498.2972.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Nick Piggin <npiggin@suse.de>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2010-06-28 at 09:18 +0300, Pekka Enberg wrote:
> On Sat, Jun 26, 2010 at 5:24 AM, Nick Piggin <npiggin@suse.de> wrote:
> > On Fri, Jun 25, 2010 at 04:20:26PM -0500, Christoph Lameter wrote:
> >> The following patchset cleans some pieces up and then equips SLUB with
> >> per cpu queues that work similar to SLABs queues. With that approach
> >> SLUB wins in hackbench:
> >
> > Hackbench I don't think is that interesting. SLQB was beating SLAB
> > too.
> 
> We've seen regressions pop up with hackbench so I think it's
> interesting. Not the most interesting one, for sure, nor conclusive.

Looks like most of the stuff up to 12 is a good idea.

Christoph, is there any test where this is likely to lose substantial
ground to SLUB without queueing? Can we characterize that? We're in
danger now of getting into the situation where we can't drop SLUB for
the same reasons we can't drop SLAB - big performance regressions.

-- 
Mathematics is the supreme nostalgia of our time.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
