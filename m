Date: Fri, 9 Feb 2001 11:39:56 -0800 (PST)
From: Grant Grundler <grundler@cup.hp.com>
Message-Id: <200102091939.LAA08207@milano.cup.hp.com>
Subject: IOMMU setup vs DAC (PCI)
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: davem@redhat.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dave (Miller),

Matthew Wilcox and I had the following conversation:

<ggg> willy: how do systems which support dual address cycle PCI (ie 64-bit
  addressing) access hi-mem (>4GB)?  bounce-buffers?
* ggg is wondering if any recent changes define a 64-bit type for dma_addr_t
<willy> ggg: the IOMMU is used to map a 32-bit PCI address to a 64-bit
  address-bus address
<ggg> willy: what if I design a board that doesn't *have* an IOMMU?
<willy> except on x86 where bounce buffers get used.
<ggg> IOMMU has a performance cost.
<willy> so does DAC.
<ggg> DAC is cheap compared to IOMMU overhead.
<willy> i'll have to take your word for that.
<ggg> DAC doesn't cost the CPU anything and IOMMU mgt does.
<willy> but how much mgt needs to be done?  if you're doing a 4k read from
  disc, it's surely cheaper?
<ggg> IOMMU also has to R/W TLB and get flushed in certain circumstances - ie
  extra PIO to the IOMMU
<ggg> willy: no way.
<ggg> willy: setup time on IOMMU kills you.
<ggg> try bigger reads and we can argue. I don't know where the tradeoff is for
  parisc IOMMU's.
<willy> i'm the wrong person to be arguing with.  davem/rth/linus/sct/mingo
  are the people.
<ggg> willy: ok.
* ggg sends mail to davem
<willy> linux-mm might be the right list to argue this on.
<ggg> ok. what's the full email addr?
<ggg> vger.kernel.org?
<willy> @kvack.org
<ggg> ok tnx.

My original quest was for an architecturally neutral way to pass
64-bit physical memory addresses back to a 64-bit capable card.

pci_dma_supported() interface provides the right hook for the
driver to advertise device capabilities. dma_addr_t is defined
in most arches (read x86) to be 32-bit. But IA64 (u64) and mips*
(unsigned long) have broken ground here already. I'll explore
further to see if parisc*-linux can in fact use "unsigned long".

But I'm still interested in any comments or insights.
(ie am I out to lunch? ;^)

thanks,
grant

Grant Grundler
parisc-linux {PCI|IOMMU|SMP} hacker
+1.408.447.7253
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
