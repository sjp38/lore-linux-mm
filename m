Date: Tue, 28 Nov 2006 11:27:17 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Re: [RFC] Extract kmalloc.h and slob.h from slab.h
In-Reply-To: <84144f020611281124k85785caydbe45a20c4905f48@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0611281125500.9465@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0611272229290.6012@schroedinger.engr.sgi.com>
 <84144f020611280000w26d74321i2804b3d04b87762@mail.gmail.com>
 <Pine.LNX.4.64.0611281003190.8764@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0611282104170.32289@sbz-30.cs.Helsinki.FI>
 <Pine.LNX.4.64.0611281109150.9370@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0611282118140.1597@sbz-30.cs.Helsinki.FI>
 <84144f020611281124k85785caydbe45a20c4905f48@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: akpm@osdl.org, linux-mm@kvack.org, mpm@selenic.com, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

On Tue, 28 Nov 2006, Pekka Enberg wrote:

> Meaning new ones, of course. The existing ones should be fixed anyway
> so I don't see the point of maintaining the mistake done in
> <linux/slab.h> long time ago.

We may want to switch existing ones that do not need to define their own 
slabs. I doubt that slab.h is used directly by user space. We need to 
cover the indirect use.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
