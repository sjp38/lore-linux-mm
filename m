Date: Mon, 14 May 2007 08:53:21 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/5] make slab gfp fair
In-Reply-To: <20070514131904.440041502@chello.nl>
Message-ID: <Pine.LNX.4.64.0705140852150.10442@schroedinger.engr.sgi.com>
References: <20070514131904.440041502@chello.nl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Mon, 14 May 2007, Peter Zijlstra wrote:

> In the interest of creating a reserve based allocator; we need to make the slab
> allocator (*sigh*, all three) fair with respect to GFP flags.

I am not sure what the point of all of this is. 

> That is, we need to protect memory from being used by easier gfp flags than it
> was allocated with. If our reserve is placed below GFP_ATOMIC, we do not want a
> GFP_KERNEL allocation to walk away with it - a scenario that is perfectly
> possible with the current allocators.

Why does this have to handled by the slab allocators at all? If you have 
free pages in the page allocator then the slab allocators will be able to 
use that reserve.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
