MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16899.63089.492768.89353@cargo.ozlabs.ibm.com>
Date: Sat, 5 Feb 2005 09:25:53 +1100
From: Paul Mackerras <paulus@samba.org>
Subject: Re: A scrub daemon (prezeroing)
In-Reply-To: <Pine.LNX.4.58.0502040900450.759@schroedinger.engr.sgi.com>
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
	<16899.15980.791820.132469@cargo.ozlabs.ibm.com>
	<Pine.LNX.4.58.0502040900450.759@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Rik van Riel <riel@redhat.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, David Woodhouse <dwmw2@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter writes:

> scrubd clears pages of orders 7-4 by default. That means 2^4 to 2^7
> pages are cleared at once.

So are you saying that clearing an order 4 page will take measurably
less time than clearing 16 order 0 pages?  I find that hard to
believe.

Paul.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
