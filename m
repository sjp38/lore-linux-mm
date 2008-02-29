Date: Fri, 29 Feb 2008 11:41:30 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 6/8] slub: Adjust order boundaries and minimum objects
 per slab.
In-Reply-To: <47C7BFFA.9010402@cs.helsinki.fi>
Message-ID: <Pine.LNX.4.64.0802291139560.11084@schroedinger.engr.sgi.com>
References: <20080229044803.482012397@sgi.com> <20080229044819.800974712@sgi.com>
 <47C7BFFA.9010402@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Mel Gorman <mel@csn.ul.ie>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 29 Feb 2008, Pekka Enberg wrote:

> I can see why you want to change the defaults for big iron but why not keep
> the existing PAGE_SHIFT check which leaves embedded and regular desktop
> unchanged?

The defaults for slab are also 60 objects per slab. The PAGE_SHIFT says 
nothing about the big iron. Our new big irons have a page shift of 12 and 
are x86_64.

We could drop the limit if CONFIG_EMBEDDED is set but then this may waste 
space. A higher order allows slub to reach a higher object density (in 
particular for objects 500-2000 bytes size).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
