From: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Message-Id: <200102091947.LAA66193@google.engr.sgi.com>
Subject: Re: IOMMU setup vs DAC (PCI)
Date: Fri, 9 Feb 2001 11:47:20 -0800 (PST)
In-Reply-To: <200102091939.LAA08207@milano.cup.hp.com> from "Grant Grundler" at Feb 09, 2001 11:39:56 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Grant Grundler <grundler@cup.hp.com>
Cc: davem@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> My original quest was for an architecturally neutral way to pass
> 64-bit physical memory addresses back to a 64-bit capable card.
> 
> pci_dma_supported() interface provides the right hook for the
> driver to advertise device capabilities. dma_addr_t is defined
> in most arches (read x86) to be 32-bit. But IA64 (u64) and mips*
> (unsigned long) have broken ground here already. I'll explore
> further to see if parisc*-linux can in fact use "unsigned long".
> 
> But I'm still interested in any comments or insights.
> (ie am I out to lunch? ;^)

dma_addr_t should be unsigned long, which is 64 bits on 64 bit
architectures, so things are fine there.

On regular x86, dma_addr_t is u32, which still works.

The problem is really on x86 PAE. I think Alan also pointed out
that other architectures might have similar issues (ARM?). For
x86-PAE, dma_addr_t should really be u64/unsigned long long. The
only issue is that there are gcc bugs while dealing with 64 bit
quantities on x86, and performance implications.

Additionally, we have also talked in the past of making a typedef
for representing physical addresses. This typedef would be the 
same as the one to represent dma_addr_t.

Kanoj

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
