Date: Fri, 18 Aug 2006 23:20:34 -0500
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH] Extract the allocpercpu functions from the slab allocator
Message-ID: <20060819042033.GC19707@waste.org>
References: <Pine.LNX.4.64.0608182108400.3097@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0608182108400.3097@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 18, 2006 at 09:14:06PM -0700, Christoph Lameter wrote:
> The allocpercpu functions __alloc_percpu and __free_percpu() are heavily 
> using the slab allocator. However, they are conceptually different 
> allocators that can be used independently from the slab. Currently the 
> slab code is duplicated in slob. This patch also 
> simplifies SLOB.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>

Nice.

Signed-off-by: Matt Mackall <mpm@selenic.com>

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
