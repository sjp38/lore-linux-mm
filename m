Date: Tue, 5 Jun 2001 16:42:52 -0400
From: cohutta <cohutta@MailAndNews.com>
Subject: Re: temp. mem mappings
Message-ID: <3B581215@MailAndNews.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > > Allocate a virtual memory area using vmalloc and then save and
modify the
> > > pmd/pgd/pte to point to the physical memory you want.  To unmap,
just undo the
> > > previous steps.
> >
> > ioremap() is there for exactly that purpose.
>
> True, except that you can't use ioremap on normal memory, which is
what I
> assumed he was trying to do.

  Normal memory is identity-mapped very early in boot anyway (except for
  highmem on large Intel boxes, that is, and kmap() works for that.)
---

I don't really want to play with the page tables if i can help it.
I didn't use ioremap() because it's real system memory, not IO bus
memory.

How much normal memory is identity-mapped at boot on x86?
Is it more than 8 MB?

I'm trying to read some ACPI tables, like the FACP.
On my system, this is at physical address 0x3fffd7d7 (e.g.).

kmap() ends up calling set_pte(), which is close to what i am
already doing.  i'm having a problem on the unmap side when i
am done with the temporary mapping.

thanks.
/cohutta/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
