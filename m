Date: Thu, 17 Aug 2000 12:41:52 -0700
Message-Id: <200008171941.MAA24042@pizda.ninka.net>
From: "David S. Miller" <davem@redhat.com>
In-reply-to: <200008171950.MAA45378@google.engr.sgi.com> (message from Kanoj
	Sarcar on Thu, 17 Aug 2000 12:50:40 -0700 (PDT))
Subject: Re: pte_pagenr/MAP_NR deleted in pre6
References: <200008171950.MAA45378@google.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kanoj@google.engr.sgi.com
Cc: alan@lxorguk.ukuu.org.uk, sct@redhat.com, roman@augan.com, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, rmk@arm.linux.org.uk, nico@cam.org, davidm@hpl.hp.com
List-ID: <linux-mm.kvack.org>

   So, unlike system vendors adding in dma mapping registers for PCI32
   devices to dma anywhere into their >32 bit physical address space, you 
   are assuming no vendor will ever have a mapping scheme for ISA devices
   that let them get over the 16MB mark? 

ISA is a dead hardware technology and therefore how it works is pretty
much fixed in stone.

Perhaps some older MIPS machines supporting ISA could benefit from
an API similar to the PCI dma stuff, as Alan mentioned.  But that is
the only case which has any merit in my mind.

Later,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
