Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 165866B005A
	for <linux-mm@kvack.org>; Fri, 19 Jun 2009 03:09:05 -0400 (EDT)
Received: from toip5.srvr.bell.ca ([209.226.175.88])
          by tomts43-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20090618115953.TKGV11189.tomts43-srv.bellnexxia.net@toip5.srvr.bell.ca>
          for <linux-mm@kvack.org>; Thu, 18 Jun 2009 07:59:53 -0400
Date: Thu, 18 Jun 2009 07:59:46 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [this_cpu_xx V2 16/19] this_cpu: slub aggressive use of
	this_cpu operations in the hotpaths
Message-ID: <20090618115946.GA11108@Krystal>
References: <20090617203337.399182817@gentwo.org> <20090617203445.892030202@gentwo.org> <1245306801.12010.10.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
In-Reply-To: <1245306801.12010.10.camel@penberg-laptop>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: cl@linux-foundation.org, akpm@linux-foundation.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, mingo@elte.hu, rusty@rustcorp.com.au, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

* Pekka Enberg (penberg@cs.helsinki.fi) wrote:
> On Wed, 2009-06-17 at 16:33 -0400, cl@linux-foundation.org wrote:
> > Use this_cpu_* operations in the hotpath to avoid calculations of
> > kmem_cache_cpu pointer addresses.
> > 
> > It is not clear if this is always an advantage.
> > 
> > On x86 there is a tradeof: Multiple uses segment prefixes against an
> > address calculation and more register pressure.
> > 
> > On the other hand the use of prefixes is necessary if we want to use
> > Mathieus scheme for fastpaths that do not require interrupt disable.
> 
> On an unrelated note, it sure would be nice if the SLUB allocator didn't
> have to disable interrupts because then we could just get rid of the gfp
> masking there completely.
> 

The solution I had just gets rid of the irqoff for the fast path. The
slow path still needs to disable interrupts.

Mathieu

> 			Pekka
> 

-- 
Mathieu Desnoyers
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
