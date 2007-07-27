From: David Howells <dhowells@redhat.com>
In-Reply-To: <1185493838.5495.144.camel@localhost.localdomain>
References: <1185493838.5495.144.camel@localhost.localdomain>
Subject: Re: [PATCH/RFC] remove frv usage of flush_tlb_pgtables()
Date: Fri, 27 Jul 2007 10:43:58 +0100
Message-ID: <21776.1185529438@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel list <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> frv is the last user in the tree of that dubious hook, and it's my
> understanding that it's not even needed. It's only called by memory.c
> free_pgd_range() which is always called within an mmu_gather, and
> tlb_flush() on frv will do a flush_tlb_mm(), which from my reading
> of the code, seems to do what flush_tlb_ptables() does, which is
> to clear the cached PGE.

Yeah...  I hadn't got around to killing myself yet.

Acked-By: David Howells <dhowells@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
