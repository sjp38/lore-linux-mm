Date: Thu, 24 Aug 2000 19:43:41 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: pgd/pmd/pte and x86 kernel virtual addresses
In-Reply-To: <20000824233129Z131177-247+8@kanga.kvack.org>
Message-ID: <Pine.LNX.3.96.1000824193751.16795A-100000@kanga.kvack.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 24 Aug 2000, Timur Tabi wrote:

> On x86, when running the kernel, all memory is mapped with a simple offset. 
> The virtual address is merely an offset from the physical address.

> Does that mean that the pgd/pmd/pte tables are still used?

x86 only uses two level page tables, so effectively only the pgd and pte
are used.  Unlike some CPUs like sparc, all virtual mappings do indeed
have entries in the pgd (but not always in the ptes).

>  Basically, what I'm
> trying to do is find the pte for a given physical page.  That is, I'm looking
> for a function that looks like this:
> 
> pte_t *find_pte(mem_map_t *mm);
> 
> Given a pointer to a mem_map_t, it returns the pointer to the pte_t for that
> physical page.  Is there such a function?  I've found things like this:

There is no such function, and there cannot be for kernel addresses
since on most x86s, the kernel makes use of 4MB pages to map chunks of
memory.  If you're looking for the user addresses associated with a
physical page, there are several ways of doing so, but none of them are
implemented in the current kernel.

Why do you need this/what are you trying to do?

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
