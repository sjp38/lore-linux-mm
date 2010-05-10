Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9E7486200BD
	for <linux-mm@kvack.org>; Mon, 10 May 2010 01:29:41 -0400 (EDT)
Subject: Re: numa aware lmb and sparc stuff
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20100510050158.GA24592@linux-sh.org>
References: <1273466126.23699.23.camel@pasglop>
	 <20100510050158.GA24592@linux-sh.org>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 10 May 2010 15:29:23 +1000
Message-ID: <1273469363.23699.26.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Paul Mundt <lethal@linux-sh.org>
Cc: David Miller <davem@davemloft.net>, Yinghai Lu <yinghai@kernel.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2010-05-10 at 14:01 +0900, Paul Mundt wrote:
> On Mon, May 10, 2010 at 02:35:26PM +1000, Benjamin Herrenschmidt wrote:
> > So unless i'm missing something, I should be able to completely remove
> > lmb's reliance on that nid_range() callback and instead have lmb itself
> > use the various early_node_map[] accessors such as
> > for_each_active_range_index_in_nid() or similar.
> > 
> If you do this then you will also be coupling LMB with
> ARCH_POPULATES_NODE_MAP, which the nid_range() callback offers an
> alternative for (although since there aren't any architectures presently
> using LMB that don't also set ARCH_POPULATES_NODE_MAP perhaps this is
> ok). The nobootmem stuff also has a reliance on the early node map
> already.

Right, my tentative implementation indeed requires
ARCH_POPULATES_NODE_MAP for lmb_alloc_nid() to be available (I even
documented it). Do you see that as a limitation in the long run ?

> > If not, then I should be able to easily make that whole LMB numa thing
> > completely arch neutral.
> > 
> I've just started sorting out some of the LMB/NUMA bits on SH now as
> well, so I'd certainly be interested in any changes on top of Yinghai's
> work you're planning on doing.

I'm not sure I plan to change things on -top- of Yinghai work. I'm still
maintaining a patch series that is rooted before Yinghai current one, as
I very very much dislike pretty much everything in there. Though I plan
to provide all the functionality he needs for his x86 port and
NO_BOOTMEM implementation.

I'll post my WIP series later today after I got a chance to do some
tests.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
