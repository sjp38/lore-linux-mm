Date: Wed, 16 May 2007 20:02:37 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/5] make slab gfp fair
In-Reply-To: <20070514131904.440041502@chello.nl>
Message-ID: <Pine.LNX.4.64.0705161957440.13458@schroedinger.engr.sgi.com>
References: <20070514131904.440041502@chello.nl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Mon, 14 May 2007, Peter Zijlstra wrote:

> 
> In the interest of creating a reserve based allocator; we need to make the slab
> allocator (*sigh*, all three) fair with respect to GFP flags.
> 
> That is, we need to protect memory from being used by easier gfp flags than it
> was allocated with. If our reserve is placed below GFP_ATOMIC, we do not want a
> GFP_KERNEL allocation to walk away with it - a scenario that is perfectly
> possible with the current allocators.

And the solution is to fail the allocation of the process which tries to 
walk away with it. The failing allocation will lead to the killing of the 
process right?

We already have an OOM killer which potentially kills random processes. We 
hate it.

Could you please modify the patchset to *avoid* failure conditions. This 
patchset here only manages failure conditions. The system should not get 
into the failure conditions in the first place! For that purpose you may 
want to put processes to sleep etc. But in order to do so you need to 
figure out which processes you need to make progress.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
