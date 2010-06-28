Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 4C3E76B01B2
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 02:18:37 -0400 (EDT)
Received: by bwz9 with SMTP id 9so619989bwz.14
        for <linux-mm@kvack.org>; Sun, 27 Jun 2010 23:18:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100626022441.GC29809@laptop>
References: <20100625212026.810557229@quilx.com>
	<20100626022441.GC29809@laptop>
Date: Mon, 28 Jun 2010 09:18:34 +0300
Message-ID: <AANLkTinOsPXdFc36mVDva-x0a0--gdFJuvWFQARwvx6y@mail.gmail.com>
Subject: Re: [S+Q 00/16] SLUB with Queueing beats SLAB in hackbench
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Sat, Jun 26, 2010 at 5:24 AM, Nick Piggin <npiggin@suse.de> wrote:
> On Fri, Jun 25, 2010 at 04:20:26PM -0500, Christoph Lameter wrote:
>> The following patchset cleans some pieces up and then equips SLUB with
>> per cpu queues that work similar to SLABs queues. With that approach
>> SLUB wins in hackbench:
>
> Hackbench I don't think is that interesting. SLQB was beating SLAB
> too.

We've seen regressions pop up with hackbench so I think it's
interesting. Not the most interesting one, for sure, nor conclusive.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
