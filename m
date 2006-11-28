Date: Tue, 28 Nov 2006 10:05:03 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] Extract kmalloc.h and slob.h from slab.h
In-Reply-To: <84144f020611280000w26d74321i2804b3d04b87762@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0611281003190.8764@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0611272229290.6012@schroedinger.engr.sgi.com>
 <84144f020611280000w26d74321i2804b3d04b87762@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: akpm@osdl.org, linux-mm@kvack.org, mpm@selenic.com, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

On Tue, 28 Nov 2006, Pekka Enberg wrote:

> On 11/28/06, Christoph Lameter <clameter@sgi.com> wrote:
> > @@ -0,0 +1,221 @@
> > +#ifndef _LINUX_KMALLOC_H
> > +#define        _LINUX_KMALLOC_H
> > +
> > +#include <linux/gfp.h>
> > +#include <asm/page.h>          /* kmalloc_sizes.h needs PAGE_SIZE */
> > +#include <asm/cache.h>         /* kmalloc_sizes.h needs L1_CACHE_BYTES */
> > +
> > +#ifdef __KERNEL__
> 
> This is an in-kernel header so why do we need the above #ifdef clause?

What exactly is an in-kernel header?

Why would slab.h be different from kmalloc.h? Yes currently kmalloc.h is 
included by slab.h but in the future code that only relies on kmalloc can 
just include kmalloc.h. Is it because it does not contain any constant 
definitions?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
