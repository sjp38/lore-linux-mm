Date: Thu, 24 May 2007 10:27:54 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 1/3] slob: rework freelist handling
In-Reply-To: <20070524172251.GX11115@waste.org>
Message-ID: <Pine.LNX.4.64.0705241024200.29173@schroedinger.engr.sgi.com>
References: <20070523183224.GD11115@waste.org>
 <Pine.LNX.4.64.0705231208380.21222@schroedinger.engr.sgi.com>
 <20070523195824.GF11115@waste.org> <Pine.LNX.4.64.0705231300070.21541@schroedinger.engr.sgi.com>
 <20070523210612.GI11115@waste.org> <Pine.LNX.4.64.0705231524140.22666@schroedinger.engr.sgi.com>
 <20070523224206.GN11115@waste.org> <Pine.LNX.4.64.0705231544310.22857@schroedinger.engr.sgi.com>
 <20070524061153.GP11115@waste.org> <Pine.LNX.4.64.0705240928020.27844@schroedinger.engr.sgi.com>
 <20070524172251.GX11115@waste.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 24 May 2007, Matt Mackall wrote:

> That's C) above. But you haven't answered the real question: why
> bother? RECLAIMABLE is a bogus number and the VM treats it as such. We
> can make no judgment on how much memory we can actually reclaim from
> looking at reclaimable - it might very easily all be pinned.

The memory was allocated from a slab that has SLAB_ACCOUNT_RECLAIM set. It 
is the responsibility of the slab allocator to properly account for these.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
