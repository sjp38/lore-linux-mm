Date: Thu, 20 Jul 2000 12:12:39 -0700 (PDT)
From: Ivan Passos <lists@cyclades.com>
Subject: Re: phys-to-virt kernel mapping and ioremap()
In-Reply-To: <20000720183534Z156966-31297+1096@vger.rutgers.edu>
Message-ID: <Pine.LNX.4.10.10007201208210.11710-100000@main.cyclades.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel Mailing list <linux-kernel@vger.rutgers.edu>
Cc: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 20 Jul 2000, Timur Tabi wrote:
> 
> > Timur> 1) Doesn't this mapping break the phys_to_virt and virt_to_phys
> > Timur> macros?
> > 
> > Those two macros are not defined on ioremap'ed regions so it is
> > irrelevant.
> 
> In that case, how do I do virt-to-phys and phys-to-virt translations on the
> memory addresses for ioremap'ed regions?

Why would you wanna do that for a PCI MMIO region??

1) ioremap(PCI_addr) returns a virtual address.
2) Use read[bwl], write[bwl], memcpy_toio, memcpy_fromio, memset_io ...
   with the obtained virtual address to access the MMIO region.

What else do you need?? Please let us know.

Regards,
Ivan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
