Subject: Re: [BUG] SLOB's krealloc() seems bust
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <alpine.LFD.2.00.0810071053540.3208@nehalem.linux-foundation.org>
References: <1223387841.26330.36.camel@lappy.programming.kicks-ass.net>
	 <48EB6D2C.30806@linux-foundation.org>  <1223391655.13453.344.camel@calx>
	 <1223395846.26330.55.camel@lappy.programming.kicks-ass.net>
	 <1223397455.13453.385.camel@calx>
	 <alpine.LFD.2.00.0810071053540.3208@nehalem.linux-foundation.org>
Content-Type: text/plain
Date: Tue, 07 Oct 2008 20:11:22 +0200
Message-Id: <1223403082.26330.78.camel@lappy.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, linux-kernel <linux-kernel@vger.kernel.org>, akpm <akpm@linuxfoundation.org>, Pekka J Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-10-07 at 10:57 -0700, Linus Torvalds wrote:

> Peter - can you check with that
> 
> >  	if (slob_page(sp))
> > -		return ((slob_t *)block - 1)->units + SLOB_UNIT;
> > +		return (((slob_t *)block - 1)->units - 1) * SLOB_UNIT;
> 
> thing using
> 
> -		return ((slob_t *)block - 1)->units + SLOB_UNIT;
> +		return ((slob_t *)block - 1)->units * SLOB_UNIT;
> 
> instead? 

went splat on the second run...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
