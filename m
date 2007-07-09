Date: Mon, 9 Jul 2007 09:08:10 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 09/10] Remove the SLOB allocator for 2.6.23
In-Reply-To: <84144f020707090404l657a62c7x89d7d06b3dd6c34b@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0707090907010.13970@schroedinger.engr.sgi.com>
References: <20070708034952.022985379@sgi.com>  <20070708035018.074510057@sgi.com>
 <20070708075119.GA16631@elte.hu>  <20070708110224.9cd9df5b.akpm@linux-foundation.org>
  <4691A415.6040208@yahoo.com.au> <84144f020707090404l657a62c7x89d7d06b3dd6c34b@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, suresh.b.siddha@intel.com, corey.d.gough@intel.com, Matt Mackall <mpm@selenic.com>, Denis Vlasenko <vda.linux@googlemail.com>, Erik Andersen <andersen@codepoet.org>
List-ID: <linux-mm.kvack.org>

On Mon, 9 Jul 2007, Pekka Enberg wrote:

> I assume with "slab external fragmentation" you mean allocating a
> whole page for a slab when there are not enough objects to fill the
> whole thing thus wasting memory? We could try to combat that by
> packing multiple variable-sized slabs within a single page. Also,
> adding some non-power-of-two kmalloc caches might help with internal
> fragmentation.

Ther are already non-power-of-two kmalloc caches for 96 and 192 bytes 
sizes.
> 
> In any case, SLUB needs some serious tuning for smaller machines
> before we can get rid of SLOB.

Switch off CONFIG_SLUB_DEBUG to get memory savings.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
