Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id EB8A36200BF
	for <linux-mm@kvack.org>; Mon, 10 May 2010 03:49:44 -0400 (EDT)
Subject: Re: numa aware lmb and sparc stuff
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20100510060316.GA12250@linux-sh.org>
References: <1273466126.23699.23.camel@pasglop>
	 <20100510050158.GA24592@linux-sh.org> <1273469363.23699.26.camel@pasglop>
	 <20100510060316.GA12250@linux-sh.org>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 10 May 2010 17:49:17 +1000
Message-ID: <1273477757.23699.84.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Paul Mundt <lethal@linux-sh.org>
Cc: David Miller <davem@davemloft.net>, Yinghai Lu <yinghai@kernel.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


> I wouldn't call it a limitation so much as a subtle dependency. All of
> the current platforms that are supporting NUMA are doing so along with
> ARCH_POPULATES_NODE_MAP, so in those cases making the early_node_map
> dependence explicit and generic will permit the killing off of
> architecture-private data structures and accounting for region sizes and
> node mappings.
> 
> The NUMA platforms that do not currently follow the
> ARCH_POPULATES_NODE_MAP semantics seem to already be in various states of
> disarray (generically broken, bitrotted, etc.). To that extent, perhaps
> it's also useful to have NUMA imply ARCH_POPULATES_NODE_MAP? New
> architectures that are going to opt for sparsemem or NUMA are likely
> going to end up down the ARCH_POPULATES_NODE_MAP path anyways I would
> imagine.

Ok so I had a chat with Dave and it looks like that won't do for sparc. 

They don't really have ranges. Or rather, they do in HW, but with their
hypervisor, you can get the pages all scattered in what they call "real
memory", so early_node_map[] doesn't work well.

So I'll rollback my changes in that area for now, put back the arch
callback, but I'll keep at hand a default variant that uses
early_node_map[] for the like of us.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
