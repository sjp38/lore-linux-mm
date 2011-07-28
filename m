Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 057DF6B016A
	for <linux-mm@kvack.org>; Thu, 28 Jul 2011 06:56:35 -0400 (EDT)
Date: Thu, 28 Jul 2011 12:56:05 +0200
From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: Re: possible recursive locking detected cache_alloc_refill() +
 cache_flusharray()
Message-ID: <20110728105605.GA14687@Chamillionaire.breakpoint.cc>
References: <20110716211850.GA23917@breakpoint.cc>
 <alpine.LFD.2.02.1107172333340.2702@ionos>
 <alpine.DEB.2.00.1107201619540.3528@tiger>
 <1311168638.5345.80.camel@twins>
 <alpine.DEB.2.00.1107201642500.4921@tiger>
 <1311176680.29152.20.camel@twins>
 <alpine.DEB.2.00.1107281346060.2841@tiger>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1107281346060.2841@tiger>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Sebastian Siewior <sebastian@breakpoint.cc>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

* Pekka Enberg | 2011-07-28 13:46:23 [+0300]:

>On Wed, 20 Jul 2011, Peter Zijlstra wrote:
>> We just need to annotate the SLAB_DEBUG_OBJECTS slab with a different
>> key. Something like the below, except that doesn't quite cover cpu
>> hotplug yet I think.. /me pokes more
>>
>> Completely untested, hasn't even seen a compiler etc..
>
>Ping? Did someone send me a patch I can apply?

Yes, peter did. Please see following mail from
| 22.07.11 15:26  Peter Zijlstra 
in this thread.

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
