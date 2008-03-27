From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: vmalloc: Return page array on vunmap
Date: Thu, 27 Mar 2008 23:22:20 +1100
References: <Pine.LNX.4.64.0803262117320.2794@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0803262117320.2794@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200803272322.20493.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thursday 27 March 2008 15:18, Christoph Lameter wrote:
> Make vunmap return the page array that was used at vmap. This is useful
> if one has no structures to track the page array but simply stores the
> virtual address somewhere. The disposition of the page array can then
> be decided upon by the caller after vunmap has torn down the mapping.
>
> vfree() may now also be used instead of vunmap. vfree() will release the
> page array after vunmap'ping it. If vfree() is called to free the page
> array then the page array must either be
>
> 1. Allocated via the slab allocator
>
> 2. Allocated via vmalloc but then VM_VPAGES must have been passed at
>    vunmap to specify that a vfree is needed.

Is this really for something important? Because vmap/vunmap is so slow
and unscalable that it is pretty well unusable for any kind of dynamic
allocations. I have mostly rewritten it so it is a lot more scalable,
but all these little patches will make annoying rejects... Can it wait?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
