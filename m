Date: Tue, 28 Nov 2006 11:11:58 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] Extract kmalloc.h and slob.h from slab.h
In-Reply-To: <Pine.LNX.4.64.0611282104170.32289@sbz-30.cs.Helsinki.FI>
Message-ID: <Pine.LNX.4.64.0611281109150.9370@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0611272229290.6012@schroedinger.engr.sgi.com>
 <84144f020611280000w26d74321i2804b3d04b87762@mail.gmail.com>
 <Pine.LNX.4.64.0611281003190.8764@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0611282104170.32289@sbz-30.cs.Helsinki.FI>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Cc: akpm@osdl.org, linux-mm@kvack.org, mpm@selenic.com, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

On Tue, 28 Nov 2006, Pekka J Enberg wrote:

> I don't think <linux/slab.h> should have either but I suppose there can be 
> other (broken) headers that include it and thus its safer not to remove 
> the guard clause just yet. However, if you wrap the include of 
> <linux/kmalloc.h> header inside the existing guard then we should be fine, 
> no?

There could be other header files used by user space where we would want 
to switch from slab.h to kmalloc.h in the future. All three header files 
are pretty low level and so we will have frequent includes. I think it is 
safer to have the guard in there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
