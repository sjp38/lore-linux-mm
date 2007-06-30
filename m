Date: Sat, 30 Jun 2007 11:42:44 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC] fsblock
Message-ID: <20070630104244.GC24123@infradead.org>
References: <20070624014528.GA17609@wotan.suse.de> <467DE00A.9080700@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <467DE00A.9080700@garzik.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jeff@garzik.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 23, 2007 at 11:07:54PM -0400, Jeff Garzik wrote:
> >- In line with the above item, filesystem block allocation is performed
> >  before a page is dirtied. In the buffer layer, mmap writes can dirty a
> >  page with no backing blocks which is a problem if the filesystem is
> >  ENOSPC (patches exist for buffer.c for this).
> 
> This raises an eyebrow...  The handling of ENOSPC prior to mmap write is 
> more an ABI behavior, so I don't see how this can be fixed with internal 
> changes, yet without changing behavior currently exported to userland 
> (and thus affecting code based on such assumptions).

Not really, the current behaviour is a bug.  And it's not actually buffer
layer specific - XFS now has a fix for that bug and it's generic enough
that everyone could use it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
