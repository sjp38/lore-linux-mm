Date: Tue, 5 Jun 2001 19:59:38 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: temp. mem mappings
Message-ID: <20010605195938.L26756@redhat.com>
References: <3B568C0B@MailAndNews.com> <LD7imD.A.DyE.aQSH7@dinero.interactivesi.com> <LD7imD.A.DyE.aQSH7@dinero.interactivesi.com> <20010605194136.K26756@redhat.com> <93UtRC.A.gWG.8oSH7@dinero.interactivesi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <93UtRC.A.gWG.8oSH7@dinero.interactivesi.com>; from ttabi@interactivesi.com on Tue, Jun 05, 2001 at 01:51:37PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Jun 05, 2001 at 01:51:37PM -0500, Timur Tabi wrote:

> > > Allocate a virtual memory area using vmalloc and then save and modify the
> > > pmd/pgd/pte to point to the physical memory you want.  To unmap, just undo the
> > > previous steps.
> > 
> > ioremap() is there for exactly that purpose. 
> 
> True, except that you can't use ioremap on normal memory, which is what I
> assumed he was trying to do.

Normal memory is identity-mapped very early in boot anyway (except for
highmem on large Intel boxes, that is, and kmap() works for that.)

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
