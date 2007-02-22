Date: Thu, 22 Feb 2007 15:01:30 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [RFC/PATCH] slab: free pages in a batch in drain_freelist
Message-ID: <Pine.LNX.4.64.0702221500420.22546@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka J Enberg <penberg@cs.helsinki.fi>Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Thu, 22 Feb 2007, Pekka J Enberg wrote:

> As suggested by William, free the actual pages in a batch so that we
> don't keep pounding on l3->list_lock.

This means holding the l3->list_lock for a prolonged time period. The 
existing code was done this way in order to make sure that the interrupt 
holdoffs are minimal.

There is no pounding. The cacheline with the list_lock is typically held 
until the draining is complete. While we drain the freelist we need to be 
able to respond to interrupts.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
