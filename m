Subject: Re: pte_pagenr/MAP_NR deleted in pre6
Date: Thu, 17 Aug 2000 20:24:04 +0100 (BST)
In-Reply-To: <E13PVCr-0003Vf-00@the-village.bc.nu> from "Alan Cox" at Aug 17, 2000 08:19:59 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E13PVGo-0003XA-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: "David S. Miller" <davem@redhat.com>, kanoj@google.engr.sgi.com, sct@redhat.com, roman@augan.com, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, rmk@arm.linux.org.uk, nico@cam.org, davidm@hpl.hp.com
List-ID: <linux-mm.kvack.org>

> > can move to drivers using page+offset correctly, forcing them through
> > interface such as the pci_dma API instead.
> 
> So you'll be adding an isa_alloc_consistant, mca_alloc_consistent, 
> m68k_motherboard_alloc_consistent , ....
> 
> And then of course I need virt_to_bus/bus_to_virt to poke at things like
> hardware on a PC and to access the roms.

Umm wait - for those its hidden inside the ioremap so private.. so its just
the mca/zorro/whateverbus ones

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
