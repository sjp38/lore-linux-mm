Date: Tue, 18 Mar 2008 10:45:51 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [BUG] in 2.6.25-rc3 with 64k page size and SLUB_DEBUG_ON
In-Reply-To: <200803181744.58735.Jens.Osterkamp@gmx.de>
Message-ID: <Pine.LNX.4.64.0803181043390.21992@schroedinger.engr.sgi.com>
References: <200803061447.05797.Jens.Osterkamp@gmx.de>
 <200803121619.45708.Jens.Osterkamp@gmx.de> <Pine.LNX.4.64.0803121630110.10488@schroedinger.engr.sgi.com>
 <200803181744.58735.Jens.Osterkamp@gmx.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Osterkamp <Jens.Osterkamp@gmx.de>
Cc: Pekka J Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 18 Mar 2008, Jens Osterkamp wrote:

> Actually the caller expects exactly that. The kmalloc that I saw was coming
> from alloc_thread_info in dup_task_struct. For 4k pages this maps to 
> __get_free_pages whereas for 64k pages it maps to kmalloc.
> The result of __get_free_pages seem to be aligned and kmalloc (with slub_debug)
> of course not. That explains the 4k/64k difference and the crash I am seeing...
> but I can't think of a reasonable fix right now as I don't understand the
> reason for the difference in the allocation code (yet).

One simple solution is to create a special slab and specify the alignment 
you want. The other is to use the page allocator which also gives you 
guaranteed alignment.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
