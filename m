Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1A19E6B004D
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 02:32:25 -0400 (EDT)
Subject: Re: [this_cpu_xx V2 16/19] this_cpu: slub aggressive use of
 this_cpu operations in the hotpaths
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <20090617203445.892030202@gentwo.org>
References: <20090617203337.399182817@gentwo.org>
	 <20090617203445.892030202@gentwo.org>
Date: Thu, 18 Jun 2009 09:33:21 +0300
Message-Id: <1245306801.12010.10.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: cl@linux-foundation.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>, Tejun Heo <tj@kernel.org>, mingo@elte.hu, rusty@rustcorp.com.au, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

On Wed, 2009-06-17 at 16:33 -0400, cl@linux-foundation.org wrote:
> Use this_cpu_* operations in the hotpath to avoid calculations of
> kmem_cache_cpu pointer addresses.
> 
> It is not clear if this is always an advantage.
> 
> On x86 there is a tradeof: Multiple uses segment prefixes against an
> address calculation and more register pressure.
> 
> On the other hand the use of prefixes is necessary if we want to use
> Mathieus scheme for fastpaths that do not require interrupt disable.

On an unrelated note, it sure would be nice if the SLUB allocator didn't
have to disable interrupts because then we could just get rid of the gfp
masking there completely.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
