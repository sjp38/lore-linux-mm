Subject: Re: pte_pagenr/MAP_NR deleted in pre6
Date: Thu, 17 Aug 2000 20:33:33 +0100 (BST)
In-Reply-To: <200008171920.MAA23931@pizda.ninka.net> from "David S. Miller" at Aug 17, 2000 12:20:50 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E13PVPz-0003Xl-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: alan@lxorguk.ukuu.org.uk, kanoj@google.engr.sgi.com, sct@redhat.com, roman@augan.com, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, rmk@arm.linux.org.uk, nico@cam.org, davidm@hpl.hp.com
List-ID: <linux-mm.kvack.org>

> I'll probably be adding isa_virt_to_bus, because when it is in fact
> "ISA like" the driver already knows that it must be certain that the

isa_alloc_consistent makes sense actually. Its needed for ISA bus masters
on ancient mips and other crap

> physical address is below the 16MB mark right?  Then the cases left on

16Mb for ISA - except on a few late 486 era boxes with magic extensions (which
we'd finalyl be able to use)

> x86 are MCA (which can use the ISA interface) and PCI drivers which

no MCA bus is 32bit - its closer to PCI than ISA. mca_alloc_consistent is 
doable and if some loon ever does do old IBM power boxes it will be needed
as they apparently arent cache coherent MCA

> drivers.  For example, BTTV still doesn't use the PCI dma stuff simply
> because nobody wishes to use their brains a little bit and encapsulate
> the user DMA stuff into a common spot (it's duplicated in 4 or 5
> drivers) which uses scatter gather lists with the DMA api.

BTTV doesnt use it because the current stuff works and for post 2.4 using
mmap_kiovec() and similar stuff probably will be a better solution - that
will also help us to push PCI bug awareness into pci not drivers

Also mmap_kiovec will let i810 and some other sound cards do scatter gather
buffers sensibly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
