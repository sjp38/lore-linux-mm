From: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Message-Id: <200102092007.MAA70445@google.engr.sgi.com>
Subject: Re: IOMMU setup vs DAC (PCI)
Date: Fri, 9 Feb 2001 12:07:09 -0800 (PST)
In-Reply-To: <14980.19083.144384.865666@pizda.ninka.net> from "David S. Miller" at Feb 09, 2001 11:52:43 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: Grant Grundler <grundler@cup.hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> 
> Kanoj Sarcar writes:
>  > dma_addr_t should be unsigned long, which is 64 bits on 64 bit
>  > architectures, so things are fine there.
>  > 
>  > On regular x86, dma_addr_t is u32, which still works.
> 
> It's 32-bit on sparc64 since 32-bit DMA addresses are all
> we need since the IOMMU is used for anything.

Ok.

> 
> In fact, if your architecture is doing nothing other
> than PCI, you _OUGHT_ to make it 32-bit even on 64-bit
> platforms because the PCI dma interface does not support
> 64-bit DACs in any way shape or form until 2.5.x in then
> a new dma64_addr_t type will be used to denote a DAC
> address.

Way I look at it, if you have a 64 bit platform which has
hardware to send PCI64 data to any piece of memory, then
it would be sad if software were to limit you and say "No,
PCI64 dma data must go within this piece of (low) memory
which the kernel can address with 32 bits". Because, this
assumes usage of bounce buffers, which is not pretty 
performance wise.

In some cases (in 2.4, prior to dma64_addr_t), if arch 
code can figure out a device is A64, the driver does support
A64, then it can privately decide to use A64 style mapping
and pci_dma operations for that pci_dev. Is there a problem
with this approach?

Kanoj

> 
> Later,
> David S. Miller
> davem@redhat.com
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
