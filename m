Subject: Re: pte_pagenr/MAP_NR deleted in pre6
Date: Thu, 17 Aug 2000 20:19:59 +0100 (BST)
In-Reply-To: <200008171901.MAA23835@pizda.ninka.net> from "David S. Miller" at Aug 17, 2000 12:01:49 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E13PVCr-0003Vf-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: kanoj@google.engr.sgi.com, sct@redhat.com, roman@augan.com, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, rmk@arm.linux.org.uk, nico@cam.org, davidm@hpl.hp.com, alan@lxorguk.ukuu.org.uk
List-ID: <linux-mm.kvack.org>

>    Whatever you do, you either have to introduce paddr_t (which to me
>    seems more intuitive) or page_to_pfn. We can argue one way or
>    another, but paddr_t might give you type checking for free too ...
> 
> My only two gripes about paddr_t is that long long is not only
> expensive but has been also known to be buggy on 32-bit platforms.

Except for the x86 36bit abortion do we need a long long paddr_t on any
32bit platform ?

> Which reminds me, we need to schedule a field day early 2.5.x where
> virt_to_bus and bus_to_virt are exterminated, this is the only way we
> can move to drivers using page+offset correctly, forcing them through
> interface such as the pci_dma API instead.

So you'll be adding an isa_alloc_consistant, mca_alloc_consistent, 
m68k_motherboard_alloc_consistent , ....

And then of course I need virt_to_bus/bus_to_virt to poke at things like
hardware on a PC and to access the roms.

Its not trivial to exterminate. It really isnt. The PCI api is a tiny subset
of uses for those functions.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
