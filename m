Date: Tue, 28 Nov 2006 21:07:06 +0200 (EET)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: [RFC] Extract kmalloc.h and slob.h from slab.h
In-Reply-To: <Pine.LNX.4.64.0611281003190.8764@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0611282104170.32289@sbz-30.cs.Helsinki.FI>
References: <Pine.LNX.4.64.0611272229290.6012@schroedinger.engr.sgi.com>
 <84144f020611280000w26d74321i2804b3d04b87762@mail.gmail.com>
 <Pine.LNX.4.64.0611281003190.8764@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, mpm@selenic.com, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

On Tue, 28 Nov 2006, Christoph Lameter wrote:
> What exactly is an in-kernel header?

One that is never ever included by userspace and thus does not need the 
guard clause.

On Tue, 28 Nov 2006, Christoph Lameter wrote:
> Why would slab.h be different from kmalloc.h? Yes currently kmalloc.h is 
> included by slab.h but in the future code that only relies on kmalloc can 
> just include kmalloc.h. Is it because it does not contain any constant 
> definitions?

I don't think <linux/slab.h> should have either but I suppose there can be 
other (broken) headers that include it and thus its safer not to remove 
the guard clause just yet. However, if you wrap the include of 
<linux/kmalloc.h> header inside the existing guard then we should be fine, 
no?

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
