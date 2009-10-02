Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6FEA76B004D
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 05:19:14 -0400 (EDT)
Date: Fri, 2 Oct 2009 11:29:54 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [this_cpu_xx V3 00/19] Introduce per cpu atomic operations and
	avoid per cpu address arithmetic
Message-ID: <20091002092954.GA20779@elte.hu>
References: <20091001174033.576397715@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091001174033.576397715@gentwo.org>
Sender: owner-linux-mm@kvack.org
To: cl@linux-foundation.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, rusty@rustcorp.com.au, davem@davemloft.net, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


* cl@linux-foundation.org <cl@linux-foundation.org> wrote:

> V2->V3:
> - Available via git tree against latest upstream from
> 	 git://git.kernel.org/pub/scm/linux/kernel/git/christoph/percpu.git linus
> - Rework SLUB per cpu operations. Get rid of dynamic DMA slab creation
>   for CONFIG_ZONE_DMA
> - Create fallback framework so that 64 bit ops on 32 bit platforms
>   can fallback to the use of preempt or interrupt disable. 64 bit
>   platforms can use 64 bit atomic per cpu ops.

I'm going to ask you (again...) to post future versions of this patchset 
to lkml.

linux-mm is a limited forum and a lot of people who might be interested 
in percpu matters simply wont know about your patch-set. per-cpu is not 
just a VM matter, obviously - it affects architectures, core kernel 
code, etc. etc.

I happened to see your patch-set and have a couple of comments about it 
but i will wait with discussing the issues until you submit these 
patches properly.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
