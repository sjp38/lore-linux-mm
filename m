Date: Mon, 3 Mar 2008 15:36:27 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 7/8] slub: Make the order configurable for each slab
 cache
In-Reply-To: <47CC822E.8040702@cs.helsinki.fi>
Message-ID: <Pine.LNX.4.64.0803031535550.5611@schroedinger.engr.sgi.com>
References: <20080229044803.482012397@sgi.com>  <20080229044820.044485187@sgi.com>
 <47C7BEA8.4040906@cs.helsinki.fi>  <Pine.LNX.4.64.0802291137140.11084@schroedinger.engr.sgi.com>
 <84144f020803010147y489b06fdx479ed0af931de08b@mail.gmail.com>
 <Pine.LNX.4.64.0803030947300.6010@schroedinger.engr.sgi.com>
 <47CC822E.8040702@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Mel Gorman <mel@csn.ul.ie>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 4 Mar 2008, Pekka Enberg wrote:

> Hmm, I seem to be missing something here. For page size of 4KB, object size of
> 8KB, and min_order of zero, when I write zero order to
> /sys/kernel/slab/<cache>/order the kernel won't crash because...?

The slab allocator will override and force the use of order 1 allocations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
