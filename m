Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id F14006B01C6
	for <linux-mm@kvack.org>; Tue, 29 Jun 2010 11:55:03 -0400 (EDT)
Message-ID: <4C2A1755.8070201@sgi.com>
Date: Tue, 29 Jun 2010 08:55:01 -0700
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [S+Q 00/16] SLUB with Queueing beats SLAB in hackbench
References: <20100625212026.810557229@quilx.com> <20100626022441.GC29809@laptop> <AANLkTinOsPXdFc36mVDva-x0a0--gdFJuvWFQARwvx6y@mail.gmail.com> <alpine.DEB.2.00.1006280510370.8725@router.home> <AANLkTimQr0iNLr4uwZwx8F9jasIsi1yoyIR8r6etMtW8@mail.gmail.com> <alpine.DEB.2.00.1006281152250.25490@chino.kir.corp.google.com> <alpine.DEB.2.00.1006291022090.16135@router.home>
In-Reply-To: <alpine.DEB.2.00.1006291022090.16135@router.home>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>



Christoph Lameter wrote:
> On Mon, 28 Jun 2010, David Rientjes wrote:
> 
>> In addition to that benchmark, which regresses on systems with larger
>> numbers of cpus, you had posted results for slub vs slab for kernbench,
>> aim9, and sysbench before slub was ever merged.  If you're going to use
>> slab-like queueing in slub, it would be interesting to see if these
>> particular benchmarks regress once again.
> 
> I do not have access to Itanium systems anymore. I hope Mike can run some
> benchmarks?
> 

Sure, but I won't have a lot of time as we're pushing out the first
customer UV systems and that's keeping me pretty busy.

If it's all packaged up and ready to run that would help a lot.

Thanks,
Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
