Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 815FC6B0258
	for <linux-mm@kvack.org>; Mon, 10 May 2010 01:02:45 -0400 (EDT)
Date: Mon, 10 May 2010 14:01:59 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: numa aware lmb and sparc stuff
Message-ID: <20100510050158.GA24592@linux-sh.org>
References: <1273466126.23699.23.camel@pasglop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1273466126.23699.23.camel@pasglop>
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: David Miller <davem@davemloft.net>, Yinghai Lu <yinghai@kernel.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, May 10, 2010 at 02:35:26PM +1000, Benjamin Herrenschmidt wrote:
> So unless i'm missing something, I should be able to completely remove
> lmb's reliance on that nid_range() callback and instead have lmb itself
> use the various early_node_map[] accessors such as
> for_each_active_range_index_in_nid() or similar.
> 
If you do this then you will also be coupling LMB with
ARCH_POPULATES_NODE_MAP, which the nid_range() callback offers an
alternative for (although since there aren't any architectures presently
using LMB that don't also set ARCH_POPULATES_NODE_MAP perhaps this is
ok). The nobootmem stuff also has a reliance on the early node map
already.

> If not, then I should be able to easily make that whole LMB numa thing
> completely arch neutral.
> 
I've just started sorting out some of the LMB/NUMA bits on SH now as
well, so I'd certainly be interested in any changes on top of Yinghai's
work you're planning on doing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
