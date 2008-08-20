Date: Tue, 19 Aug 2008 23:32:50 -0400
From: Kyle McMartin <kyle@mcmartin.ca>
Subject: Re: [patch] mm: rewrite vmap layer
Message-ID: <20080820033249.GA19241@phobos.i.cabal.ca>
References: <20080818133224.GA5258@wotan.suse.de> <20080818172446.9172ff98.akpm@linux-foundation.org> <20080819073719.GC30521@flint.arm.linux.org.uk> <20080819103952.GE16446@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080819103952.GE16446@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 19, 2008 at 12:39:52PM +0200, Nick Piggin wrote:
> > Second question - will ARMs separate module area still work with this
> > code in place (which allocates regions in a different address space
> > using __get_vm_area and __vmalloc_area)?
> 
> I hope so. The old APIs are still in place. You will actually get lazy
> unmapping, but that should be a transparent change unless you have any
> issues with the aliasing.
>  

x86_64 does this anyway, so if that's continuing to work, then it should
be fine.

r, Kyle

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
