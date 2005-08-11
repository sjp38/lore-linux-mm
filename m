Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j7BLESWY100046
	for <linux-mm@kvack.org>; Thu, 11 Aug 2005 17:14:31 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j7BLEg1Z209100
	for <linux-mm@kvack.org>; Thu, 11 Aug 2005 15:14:42 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j7BLERhJ003743
	for <linux-mm@kvack.org>; Thu, 11 Aug 2005 15:14:27 -0600
Date: Thu, 11 Aug 2005 14:14:19 -0700
From: Mike Kravetz <kravetz@us.ibm.com>
Subject: Re: [PATCH] gurantee DMA area for alloc_bootmem_low() ver. 2.
Message-ID: <20050811211419.GB5213@w-mikek2.ibm.com>
References: <20050809194115.C370.Y-GOTO@jp.fujitsu.com> <20050809211501.GB6235@w-mikek2.ibm.com> <Pine.LNX.4.62.0508111343300.19728@graphe.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.62.0508111343300.19728@graphe.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <christoph@lameter.com>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, "Martin J. Bligh" <mbligh@mbligh.org>, linux-ia64@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 11, 2005 at 01:46:22PM -0700, Christoph Lameter wrote:
> > I was going to replace more instances of __pa(MAX_DMA_ADDRESS) with
> > max_dma_physaddr().  However, when grepping for MAX_DMA_ADDRESS I
> > noticed instances of virt_to_phys(MAX_DMA_ADDRESS) as well.  Can
> > someone tell me what the differences are between __pa() and virt_to_phys().
> > I noticed that on some archs they are the same, but are different on
> > others.
> 
> On which arches do they differ?

In alphabetical order I first looked at alpha and things didn't look
the same in the '#ifndef USE_48_BIT_KSEG' case.  When I first looked
at this, I quit after looking at alpha.  However, I can't seem to easily
find other archs that differ.

-- 
Mike
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
