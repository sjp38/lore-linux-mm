Date: Tue, 5 Jun 2001 19:41:36 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: temp. mem mappings
Message-ID: <20010605194136.K26756@redhat.com>
References: <3B568C0B@MailAndNews.com> <LD7imD.A.DyE.aQSH7@dinero.interactivesi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <LD7imD.A.DyE.aQSH7@dinero.interactivesi.com>; from ttabi@interactivesi.com on Tue, Jun 05, 2001 at 01:25:27PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Jun 05, 2001 at 01:25:27PM -0500, Timur Tabi wrote:
> ** Reply to message from cohutta <cohutta@MailAndNews.com> on Tue, 5 Jun 2001
> 13:54:15 -0400
> 
> > what is the a preferred/correct method to map and unmap memory
> > temporarily?
> 
> Allocate a virtual memory area using vmalloc and then save and modify the
> pmd/pgd/pte to point to the physical memory you want.  To unmap, just undo the
> previous steps.

ioremap() is there for exactly that purpose.  Playing with page
tables directly is most definitely frowned upon and is unlikely to
lead to portable code.  ioremap() will take a physical address and
return the new virtual address, and ioremap_nocache() additionally
specifies the memory as being uncachable (via page table flags) so
that it can be used for PCI control register remapping.

Both functions are declared in <asm/io.h> and are available on both
2.2 and 2.4.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
