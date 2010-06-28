Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 22BC1600227
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 11:18:27 -0400 (EDT)
Received: by bwz9 with SMTP id 9so888249bwz.14
        for <linux-mm@kvack.org>; Mon, 28 Jun 2010 08:18:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1006280510370.8725@router.home>
References: <20100625212026.810557229@quilx.com>
	<20100626022441.GC29809@laptop>
	<AANLkTinOsPXdFc36mVDva-x0a0--gdFJuvWFQARwvx6y@mail.gmail.com>
	<alpine.DEB.2.00.1006280510370.8725@router.home>
Date: Mon, 28 Jun 2010 18:18:24 +0300
Message-ID: <AANLkTimQr0iNLr4uwZwx8F9jasIsi1yoyIR8r6etMtW8@mail.gmail.com>
Subject: Re: [S+Q 00/16] SLUB with Queueing beats SLAB in hackbench
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jun 2010, Pekka Enberg wrote:
>> > Hackbench I don't think is that interesting. SLQB was beating SLAB
>> > too.
>>
>> We've seen regressions pop up with hackbench so I think it's
>> interesting. Not the most interesting one, for sure, nor conclusive.

On Mon, Jun 28, 2010 at 1:12 PM, Christoph Lameter
<cl@linux-foundation.org> wrote:
> Hackbench was frequently cited in performance tests. Which benchmarks
> would be of interest? =A0I am off this week so dont expect a fast respons=
e
> from me.

I guess "netperf TCP_RR" is the most interesting one because that's a
known benchmark where SLUB performs poorly when compared to SLAB.
Mel's extensive slab benchmarks are also worth looking at:

http://lkml.indiana.edu/hypermail/linux/kernel/0902.0/00745.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
