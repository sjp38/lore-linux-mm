Subject: Re: phys-to-virt kernel mapping and ioremap()
References: <20000720174852Z156962-31297+1037@vger.rutgers.edu>
From: Jes Sorensen <jes@linuxcare.com>
Date: 20 Jul 2000 20:41:51 +0200
In-Reply-To: Timur Tabi's message of "Thu, 20 Jul 2000 13:06:21 -0500"
Message-ID: <d31z0osky8.fsf@lxplus015.cern.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: Linux MM mailing list <linux-mm@kvack.org>, Linux Kernel Mailing list <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

>>>>> "Timur" == Timur Tabi <ttabi@interactivesi.com> writes:

Timur> I'm studying the code for __ioremap and I'm confused by
Timur> something.  The phys_to_virt and virt_to_phys macros are very
Timur> simple.  Basically, in kernel space, the virtual address is an
Timur> offset of the physical address, so it's very simple.

You are making a bad assumption here, that PCI shared memory can be
treated as regular memory which it cannot.

Timur> 1) Doesn't this mapping break the phys_to_virt and virt_to_phys
Timur> macros?

Those two macros are not defined on ioremap'ed regions so it is
irrelevant.

Timur> 2) kmalloc takes real physical memory from the kernel heap.
Timur> But then the virtual addresses are remapped to other physical
Timur> memory.  What happens to the physical memory that kmalloc
Timur> allocated?  Why isn't it freed?

I asume it is used to generate page tables for the io memory it is
mapping, but I haven't looked at the code.

Jes
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
