From: "David S. Miller" <davem@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14980.19083.144384.865666@pizda.ninka.net>
Date: Fri, 9 Feb 2001 11:52:43 -0800 (PST)
Subject: Re: IOMMU setup vs DAC (PCI)
In-Reply-To: <200102091947.LAA66193@google.engr.sgi.com>
References: <200102091939.LAA08207@milano.cup.hp.com>
	<200102091947.LAA66193@google.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Grant Grundler <grundler@cup.hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Kanoj Sarcar writes:
 > dma_addr_t should be unsigned long, which is 64 bits on 64 bit
 > architectures, so things are fine there.
 > 
 > On regular x86, dma_addr_t is u32, which still works.

It's 32-bit on sparc64 since 32-bit DMA addresses are all
we need since the IOMMU is used for anything.

In fact, if your architecture is doing nothing other
than PCI, you _OUGHT_ to make it 32-bit even on 64-bit
platforms because the PCI dma interface does not support
64-bit DACs in any way shape or form until 2.5.x in then
a new dma64_addr_t type will be used to denote a DAC
address.

Later,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
