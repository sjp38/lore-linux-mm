Date: Fri, 25 Aug 2000 18:26:25 -0500
From: Timur Tabi <ttabi@interactivesi.com>
Subject: How does the kernel map physical to virtual addresses?
Message-Id: <20000825233718Z131190-247+15@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>, Linux Kernel Mailing list <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

When my driver wants to map virtual to physical (and vice versa) addresses, it
calls virt_to_phys and phys_to_virt. All these macros do is add or subtract a
constant (PAGE_OFFSET) to one address to get the other address.

How does the kernel configure the CPU (x86) to use this mapping?  I was under
the impression that the kernel creates a series of 4MB pages, using the x86's
4MB page feature.  For example, in a 64MB machine, there would be 16 PTEs (PGDs?
PMDs?), each one mapping a consecutive 4MB block of physical memory.  Is this
correct?  Somehow I believe that this is overly simplistic.

The reason I ask is that I'm confused as to what happens when a user process or
tries to allocate memory.  I assume that the VM uses 4KB pages for this
allocatation.  So do we end up with two virtual addresses pointing the same
physical memory?  

What happens if I use ioremap_nocache() on normal memory?  Is that memory
cached or uncached?  If I use the pointer obtained via phys_to_virt(), the
memory is cached.  But if I use the pointer returned from ioremap_nocache(), the
memory is uncached.  My understanding of x86 is that caching is based on
physical, not virtual addresses.  If so, it's not possible for a physical
address to be both cached and uncached at the same.

Could someone please straighten me out?



--
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please don't cc: me, because then I'll just get two copies of the same message.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
