Date: Thu, 24 Aug 2000 18:21:11 -0500
From: Timur Tabi <ttabi@interactivesi.com>
Subject: pgd/pmd/pte and x86 kernel virtual addresses
Message-Id: <20000824233129Z131177-247+8@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On x86, when running the kernel, all memory is mapped with a simple offset. 
The virtual address is merely an offset from the physical address.

Does that mean that the pgd/pmd/pte tables are still used?  Basically, what I'm
trying to do is find the pte for a given physical page.  That is, I'm looking
for a function that looks like this:

pte_t *find_pte(mem_map_t *mm);

Given a pointer to a mem_map_t, it returns the pointer to the pte_t for that
physical page.  Is there such a function?  I've found things like this:

#define pte_offset(dir, address) ((pte_t *) pmd_page(*(dir)) + \
			__pte_offset(address))

but what value do I use for "dir"?




--
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please don't cc: me, because then I'll just get two copies of the same message.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
