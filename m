Date: Fri, 11 May 2007 10:46:29 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [Bug 8464] New: autoreconf: page allocation failure. order:2,
 mode:0x84020
In-Reply-To: <20070511173811.GA8529@skynet.ie>
Message-ID: <Pine.LNX.4.64.0705111041080.8731@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0705101510500.13404@schroedinger.engr.sgi.com>
 <20070510221607.GA15084@skynet.ie> <Pine.LNX.4.64.0705101522250.13504@schroedinger.engr.sgi.com>
 <20070510224441.GA15332@skynet.ie> <Pine.LNX.4.64.0705101547020.14064@schroedinger.engr.sgi.com>
 <20070510230044.GB15332@skynet.ie> <Pine.LNX.4.64.0705101601220.14471@schroedinger.engr.sgi.com>
 <1178863002.24635.4.camel@rousalka.dyndns.org> <20070511090823.GA29273@skynet.ie>
 <1178884283.27195.1.camel@rousalka.dyndns.org> <20070511173811.GA8529@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Nicolas Mailhot <nicolas.mailhot@laposte.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "bugme-daemon@kernel-bugs.osdl.org" <bugme-daemon@bugzilla.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 11 May 2007, Mel Gorman wrote:

> Excellent. I am somewhat suprised by the result so I'd like to look at the
> alternative option with kswapd as well. Could you put that patch back in again
> please and try the following patch instead? The patch causes kswapd to reclaim
> at higher orders if it's requested to.  Christoph, can you look at the patch
> as well and make sure it's doing the right thing with respect to SLUB please?

Well this gives the impression that SLUB depends on larger orders. It 
*can* take advantage of higher order allocations. No must. It may be a 
performance benefit to be able to do higher order allocs though (it is not 
really established yet what kind of tradeoffs there are).

Looks fine to me. If this is stable then I want this to be merged ASAP 
(deal with the issues later???) .... Good stuff.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
