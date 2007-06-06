Date: Wed, 6 Jun 2007 13:28:40 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: SLUB: Use ilog2 instead of series of constant comparisons.
In-Reply-To: <20070606131121.a8f7be78.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0706061326020.12565@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0705211250410.27950@schroedinger.engr.sgi.com>
 <20070606100817.7af24b74.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0706061053290.11553@schroedinger.engr.sgi.com>
 <20070606131121.a8f7be78.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Andy Whitcroft <apw@shadowen.org>, Martin Bligh <mbligh@mbligh.org>
List-ID: <linux-mm.kvack.org>

On Wed, 6 Jun 2007, Andrew Morton wrote:

> > There is also nothing special in CalcNTLMv2_partial_mac_key(). Two 
> > kmallocs of 33 bytes and 132 bytes each.
> 
> Yes, the code all looks OK.  I suspect this is another case of the compiler
> failing to remove unreachable stuff.

Sigh.

The patch was already in 2.6.22-rc3-mm1. Why did the patch pass the 
testing during that release cycle?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
