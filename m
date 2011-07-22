Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C513B6B004A
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 04:17:59 -0400 (EDT)
Received: by fxh2 with SMTP id 2so4911760fxh.9
        for <linux-mm@kvack.org>; Fri, 22 Jul 2011 01:17:57 -0700 (PDT)
Date: Fri, 22 Jul 2011 11:17:29 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: possible recursive locking detected cache_alloc_refill() +
 cache_flusharray()
In-Reply-To: <20110721071459.GA2961@breakpoint.cc>
Message-ID: <alpine.DEB.2.00.1107221116420.2996@tiger>
References: <20110716211850.GA23917@breakpoint.cc> <alpine.LFD.2.02.1107172333340.2702@ionos> <alpine.DEB.2.00.1107201619540.3528@tiger> <1311168638.5345.80.camel@twins> <alpine.DEB.2.00.1107201642500.4921@tiger> <1311176680.29152.20.camel@twins>
 <20110721071459.GA2961@breakpoint.cc>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Siewior <sebastian@breakpoint.cc>
Cc: Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

On Thu, 21 Jul 2011, Sebastian Siewior wrote:
> * Thus spake Peter Zijlstra (peterz@infradead.org):
>> We just need to annotate the SLAB_DEBUG_OBJECTS slab with a different
>> key. Something like the below, except that doesn't quite cover cpu
>> hotplug yet I think.. /me pokes more
>>
>> Completely untested, hasn't even seen a compiler etc..
>
> This fix on-top passes the compiler and the splash on boot is also gone.

Can someone send me a patch I can apply to slab.git? Alternatively, 
lockdep tree can pick it up:

Acked-by: Pekka Enberg <penberg@kernel.org>

 			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
