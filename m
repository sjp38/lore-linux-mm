Subject: Re: pte_pagenr/MAP_NR deleted in pre6
Date: Thu, 17 Aug 2000 20:56:05 +0100 (BST)
In-Reply-To: <200008171950.MAA45378@google.engr.sgi.com> from "Kanoj Sarcar" at Aug 17, 2000 12:50:40 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E13PVlo-0003bV-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: "David S. Miller" <davem@redhat.com>, alan@lxorguk.ukuu.org.uk, sct@redhat.com, roman@augan.com, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, rmk@arm.linux.org.uk, nico@cam.org, davidm@hpl.hp.com
List-ID: <linux-mm.kvack.org>

> So, unlike system vendors adding in dma mapping registers for PCI32
> devices to dma anywhere into their >32 bit physical address space, you 
> are assuming no vendor will ever have a mapping scheme for ISA devices
> that let them get over the 16MB mark? 

They did. Even on a few x86 boards. Supporting those bits of weirdness are
not important. If the ISA 16Mb window is offset someone can wrap it in their
arch specific isa_alloc_consistent code..



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
