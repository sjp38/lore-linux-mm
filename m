Date: Thu, 24 May 2007 12:44:07 -0500
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [patch 1/3] slob: rework freelist handling
Message-ID: <20070524174406.GZ11115@waste.org>
References: <20070523195824.GF11115@waste.org> <Pine.LNX.4.64.0705231300070.21541@schroedinger.engr.sgi.com> <20070523210612.GI11115@waste.org> <Pine.LNX.4.64.0705231524140.22666@schroedinger.engr.sgi.com> <20070523224206.GN11115@waste.org> <Pine.LNX.4.64.0705231544310.22857@schroedinger.engr.sgi.com> <20070524061153.GP11115@waste.org> <Pine.LNX.4.64.0705240928020.27844@schroedinger.engr.sgi.com> <20070524172251.GX11115@waste.org> <Pine.LNX.4.64.0705241024200.29173@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705241024200.29173@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, May 24, 2007 at 10:27:54AM -0700, Christoph Lameter wrote:
> On Thu, 24 May 2007, Matt Mackall wrote:
> 
> > That's C) above. But you haven't answered the real question: why
> > bother? RECLAIMABLE is a bogus number and the VM treats it as such. We
> > can make no judgment on how much memory we can actually reclaim from
> > looking at reclaimable - it might very easily all be pinned.
> 
> The memory was allocated from a slab that has SLAB_ACCOUNT_RECLAIM set. It 
> is the responsibility of the slab allocator to properly account for these.

You keep asserting this, but the fact is if I ripped out all the
SLAB_ACCOUNT_RECLAIM logic, the kernel would be unaffected.

Because RECLAIM IS JUST A HINT. And not a very good one.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
