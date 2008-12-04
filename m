Date: Thu, 4 Dec 2008 10:27:22 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 1/1] Userspace I/O (UIO): Add support for userspace DMA
In-Reply-To: <1228379942.5092.14.camel@twins>
Message-ID: <Pine.LNX.4.64.0812041026340.6340@blonde.anvils>
References: <43FC624C55D8C746A914570B66D642610367F29B@cos-us-mb03.cos.agilent.com>
 <1228379942.5092.14.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: edward_estabrook@agilent.com, linux-kernel@vger.kernel.org, hjk@linutronix.de, gregkh@suse.de, edward.estabrook@gmail.com, linux-mm <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

On Thu, 4 Dec 2008, Peter Zijlstra wrote:
> On Wed, 2008-12-03 at 14:39 -0700, edward_estabrook@agilent.com wrote:
> > 
> > The gist of this implementation is to overload uio's mmap
> > functionality to allocate and map a new DMA region on demand.  The
> > bus-specific DMA address as returned by dma_alloc_coherent is made
> > available to userspace in the 1st long word of the newly created
> > region (as well as through the conventional 'addr' file in sysfs).  
> > 
> > To allocate a DMA region you use the following:
> > /* Pass this magic number to mmap as offset to dynamically allocate a
> > chunk of memory */ #define DMA_MEM_ALLOCATE_MMAP_OFFSET 0xFFFFF000UL
> > ...
> > Comments appreciated!
> 
> Yuck!
> 
> Why not create another special device that will give you DMA memory when
> you mmap it? That would also allow you to obtain the physical address
> without this utter horrid hack of writing it in the mmap'ed memory.
> 
> /dev/uioN-dma would seem like a fine name for that.

I couldn't agree more.  It sounds fine as a local hack for Edward to
try out some functionality he needed in a hurry; but as something
that should enter the mainline kernel in that form - no.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
