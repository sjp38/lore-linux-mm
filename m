Date: Wed, 16 May 2007 10:41:49 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Slab allocators: Define common size limitations
In-Reply-To: <Pine.LNX.4.62.0705160855470.24080@pademelon.sonytel.be>
Message-ID: <Pine.LNX.4.64.0705161039260.9142@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0705152313490.5832@schroedinger.engr.sgi.com>
 <Pine.LNX.4.62.0705160855470.24080@pademelon.sonytel.be>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Development <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux/PPC Development <linuxppc-dev@ozlabs.org>
List-ID: <linux-mm.kvack.org>

On Wed, 16 May 2007, Geert Uytterhoeven wrote:

> On Tue, 15 May 2007, Christoph Lameter wrote:
> > So define a common maximum size for kmalloc. For conveniences sake
> > we use the maximum size ever supported which is 32 MB. We limit the maximum
> > size to a lower limit if MAX_ORDER does not allow such large allocations.
> 
> What are the changes a large allocation will actually succeed?
> Is there an alignment rule for large allocations?
> 
> E.g. for one of the PS3 drivers I need a physically contiguous 256 KiB-aligned
> block of 256 KiB. Currently I'm using __alloc_bootmem() for that, but maybe
> kmalloc() becomes a suitable alternative now?

The chance of succeeding drops with the time that the system has been 
running. Typically these large allocs are used when the system is brought 
up. Maybe we will be able to successfully allocate these even after 
memory has gotten significant use when Mel's antifrag/defrag work has 
progressed more.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
