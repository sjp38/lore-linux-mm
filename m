MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16899.15980.791820.132469@cargo.ozlabs.ibm.com>
Date: Fri, 4 Feb 2005 20:20:44 +1100
From: Paul Mackerras <paulus@samba.org>
Subject: Re: A scrub daemon (prezeroing)
In-Reply-To: <Pine.LNX.4.58.0502032220430.28851@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.58.0501211228430.26068@schroedinger.engr.sgi.com>
	<1106828124.19262.45.camel@hades.cambridge.redhat.com>
	<20050202153256.GA19615@logos.cnet>
	<Pine.LNX.4.58.0502021103410.12695@schroedinger.engr.sgi.com>
	<20050202163110.GB23132@logos.cnet>
	<Pine.LNX.4.61.0502022204140.2678@chimarrao.boston.redhat.com>
	<16898.46622.108835.631425@cargo.ozlabs.ibm.com>
	<Pine.LNX.4.58.0502031650590.26551@schroedinger.engr.sgi.com>
	<16899.2175.599702.827882@cargo.ozlabs.ibm.com>
	<Pine.LNX.4.58.0502032220430.28851@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Rik van Riel <riel@redhat.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, David Woodhouse <dwmw2@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter writes:

> If the program does not use these cache lines then you have wasted time
> in the page fault handler allocating and handling them. That is what
> prezeroing does for you.

The program is going to access at least one cache line of the new
page.  On my G5, it takes _less_ time to clear the whole page and pull
in one cache line from L2 cache to L1 than it does to pull in that
same cache line from memory.

> Yes but its a short burst that only occurs very infrequestly and it takes

It occurs just as often as we clear pages in the page fault handler.
We aren't clearing any fewer pages by prezeroing, we are just clearing
them a bit earlier.

> advantage of all the optimizations that modern memory subsystems have for
> linear accesses. And if hardware exists that can offload that from the cpu
> then the cpu caches are only minimally affected.

I can believe that prezeroing could provide a benefit on some
machines, but I don't think it will provide any on ppc64.

Paul.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
