From: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Message-Id: <200008171950.MAA45378@google.engr.sgi.com>
Subject: Re: pte_pagenr/MAP_NR deleted in pre6
Date: Thu, 17 Aug 2000 12:50:40 -0700 (PDT)
In-Reply-To: <200008171920.MAA23931@pizda.ninka.net> from "David S. Miller" at Aug 17, 2000 12:20:50 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: alan@lxorguk.ukuu.org.uk, sct@redhat.com, roman@augan.com, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, rmk@arm.linux.org.uk, nico@cam.org, davidm@hpl.hp.com
List-ID: <linux-mm.kvack.org>

> 
>    So you'll be adding an isa_alloc_consistant, mca_alloc_consistent, 
>    m68k_motherboard_alloc_consistent , ....
> 
> I'll probably be adding isa_virt_to_bus, because when it is in fact
> "ISA like" the driver already knows that it must be certain that the
> physical address is below the 16MB mark right?  Then the cases left on
> x86 are MCA (which can use the ISA interface) and PCI drivers which
> must be updated to use the PCI dma API.
>

Just a minor nit. 

So, unlike system vendors adding in dma mapping registers for PCI32
devices to dma anywhere into their >32 bit physical address space, you 
are assuming no vendor will ever have a mapping scheme for ISA devices
that let them get over the 16MB mark? 

Of course, I am not aware of ISA that much anyway (and I hope I don't
have to!), so please ignore this if it doesn't make sense.

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
