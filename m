Date: Thu, 17 Aug 2000 12:20:50 -0700
Message-Id: <200008171920.MAA23931@pizda.ninka.net>
From: "David S. Miller" <davem@redhat.com>
In-reply-to: <E13PVCr-0003Vf-00@the-village.bc.nu> (message from Alan Cox on
	Thu, 17 Aug 2000 20:19:59 +0100 (BST))
Subject: Re: pte_pagenr/MAP_NR deleted in pre6
References: <E13PVCr-0003Vf-00@the-village.bc.nu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: alan@lxorguk.ukuu.org.uk
Cc: kanoj@google.engr.sgi.com, sct@redhat.com, roman@augan.com, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, rmk@arm.linux.org.uk, nico@cam.org, davidm@hpl.hp.com
List-ID: <linux-mm.kvack.org>

   > My only two gripes about paddr_t is that long long is not only
   > expensive but has been also known to be buggy on 32-bit platforms.

   Except for the x86 36bit abortion do we need a long long paddr_t on any
   32bit platform ?

Sparc32, mips32...

   > Which reminds me, we need to schedule a field day early 2.5.x where
   > virt_to_bus and bus_to_virt are exterminated, this is the only way we
   > can move to drivers using page+offset correctly, forcing them through
   > interface such as the pci_dma API instead.

   So you'll be adding an isa_alloc_consistant, mca_alloc_consistent, 
   m68k_motherboard_alloc_consistent , ....

I'll probably be adding isa_virt_to_bus, because when it is in fact
"ISA like" the driver already knows that it must be certain that the
physical address is below the 16MB mark right?  Then the cases left on
x86 are MCA (which can use the ISA interface) and PCI drivers which
must be updated to use the PCI dma API.

Just like I did for SBUS, the m68k folks can deal with their issues
any way they like.

   Its not trivial to exterminate.

I think it is.  What's not trivial is getting bozos to clean up their
drivers.  For example, BTTV still doesn't use the PCI dma stuff simply
because nobody wishes to use their brains a little bit and encapsulate
the user DMA stuff into a common spot (it's duplicated in 4 or 5
drivers) which uses scatter gather lists with the DMA api.

Later,
David S. Miller
davem@redhat.com


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
