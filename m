Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9A5286B005A
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 05:35:36 -0400 (EDT)
Subject: Re: [PATCH v2] slab,slub: ignore __GFP_WAIT if we're booting or
 suspending
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <84144f020906120224v5ef44637pb849fd247eab84ea@mail.gmail.com>
References: <Pine.LNX.4.64.0906121113210.29129@melkki.cs.Helsinki.FI>
	 <Pine.LNX.4.64.0906121201490.30049@melkki.cs.Helsinki.FI>
	 <20090612091002.GA32052@elte.hu> <1244798515.7172.99.camel@pasglop>
	 <84144f020906120224v5ef44637pb849fd247eab84ea@mail.gmail.com>
Content-Type: text/plain
Date: Fri, 12 Jun 2009 19:36:29 +1000
Message-Id: <1244799389.7172.110.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, npiggin@suse.de, akpm@linux-foundation.org, cl@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, 2009-06-12 at 12:24 +0300, Pekka Enberg wrote:
> Hi Ben,
> 
> On Fri, Jun 12, 2009 at 12:21 PM, Benjamin
> Herrenschmidt<benh@kernel.crashing.org> wrote:
> > I really think we are looking for trouble (and a lot of hidden bugs) by
> > trying to "fix" all callers, in addition to making some code like
> > vmalloc() more failure prone because it's unconditionally changed from
> > GFP_KERNEL to GFP_NOWAIT.
> 
> It's a new API function vmalloc_node_boot() that uses GFP_NOWAIT so I
> don't share your concern that it's error prone.

But you didn't fix __get_vm_area_caller() which means my ioremap is
still broken...

Take a break, take a step back, and look at the big picture. Do you
really want to find all the needles in the haystack or just make sure
you wear gloves when handling the hay ? :-)

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
