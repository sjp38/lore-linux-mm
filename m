Subject: Re: [PATCH/RFC] remove frv usage of flush_tlb_pgtables()
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <21776.1185529438@redhat.com>
References: <1185493838.5495.144.camel@localhost.localdomain>
	 <21776.1185529438@redhat.com>
Content-Type: text/plain
Date: Fri, 27 Jul 2007 22:37:54 +1000
Message-Id: <1185539874.5495.225.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel list <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2007-07-27 at 10:43 +0100, David Howells wrote:
> > frv is the last user in the tree of that dubious hook, and it's my
> > understanding that it's not even needed. It's only called by
> memory.c
> > free_pgd_range() which is always called within an mmu_gather, and
> > tlb_flush() on frv will do a flush_tlb_mm(), which from my reading
> > of the code, seems to do what flush_tlb_ptables() does, which is
> > to clear the cached PGE.
> 
> Yeah...  I hadn't got around to killing myself yet.

Ahem... hopefully you won't get around to it any time soon :-)

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
