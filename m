Date: Fri, 7 Mar 2008 14:59:36 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [BUG] in 2.6.25-rc3 with 64k page size and SLUB_DEBUG_ON
In-Reply-To: <200803072330.46448.Jens.Osterkamp@gmx.de>
Message-ID: <Pine.LNX.4.64.0803071453170.9654@schroedinger.engr.sgi.com>
References: <200803061447.05797.Jens.Osterkamp@gmx.de>
 <200803071320.58439.Jens.Osterkamp@gmx.de> <Pine.LNX.4.64.0803071434240.9017@sbz-30.cs.Helsinki.FI>
 <200803072330.46448.Jens.Osterkamp@gmx.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <Pine.LNX.4.64.0803071458091.9654@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Osterkamp <Jens.Osterkamp@gmx.de>
Cc: Pekka J Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 7 Mar 2008, Jens Osterkamp wrote:

> 0xc000000000056f08 is in copy_process (/home/auto/jens/kernels/linux-2.6.25-rc3/include/linux/slub_def.h:209).
> 204                             struct kmem_cache *s = kmalloc_slab(size);
> 205
> 206                             if (!s)
> 207                                     return ZERO_SIZE_PTR;
> 208
> 209                             return kmem_cache_alloc(s, flags);
> 210                     }
> 211             }
> 212             return __kmalloc(size, flags);
> 213     }
> 
> which is in the middle of kmalloc.

Its in the middle of inline code generated within the function that calls 
kmalloc. Its not in kmalloc per se.

Can you figure out what the value of size is here? I suspect we are doing 
a lookup here in kmalloc_caches with an invalid offset.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
