Message-ID: <48AC244F.1030104@linux-foundation.org>
Date: Wed, 20 Aug 2008 09:03:59 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [patch] mm: rewrite vmap layer
References: <20080818133224.GA5258@wotan.suse.de> <48AADBDC.2000608@linux-foundation.org> <20080820090234.GA7018@wotan.suse.de>
In-Reply-To: <20080820090234.GA7018@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:

>> Or run purge_vma_area_lazy from keventd?
>  
> Right. But that's only needed if we want to vmap from irq context too
> (otherwise we can just do the purge check at vmap time).
> 
> Is there any good reason to be able to vmap or vunmap from interrupt
> time, though?

It would be good to have vunmap work in an interrupt context like other free
operations. One may hold spinlocks while freeing structure.

vmap from interrupt context would be useful f.e. for general fallback in the
page allocator to virtually mapped memory if no linear physical memory is
available (virtualizable compound pages). Without a vmap that can be run in an
interrupt context we cannot support GFP_ATOMIC allocs there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
