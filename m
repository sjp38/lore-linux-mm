Date: Mon, 14 May 2007 09:37:42 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/5] make slab gfp fair
In-Reply-To: <1179159011.2942.16.camel@lappy>
Message-ID: <Pine.LNX.4.64.0705140935530.10801@schroedinger.engr.sgi.com>
References: <20070514131904.440041502@chello.nl>
 <Pine.LNX.4.64.0705140852150.10442@schroedinger.engr.sgi.com>
 <1179159011.2942.16.camel@lappy>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Mon, 14 May 2007, Peter Zijlstra wrote:

> > Why does this have to handled by the slab allocators at all? If you have 
> > free pages in the page allocator then the slab allocators will be able to 
> > use that reserve.
> 
> Yes, too freely. GFP flags are only ever checked when you allocate a new
> page. Hence, if you have a low reaching alloc allocating a slab page;
> subsequent non critical GFP_KERNEL allocs can fill up that slab. Hence
> you would need to reserve a slab per object instead of the normal
> packing.

This is all about making one thread fail rather than another? Note that 
the allocations are a rather compex affair in the slab allocators. Per 
node and per cpu structures play a big role.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
