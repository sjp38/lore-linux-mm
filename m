Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j7A36YRX512050
	for <linux-mm@kvack.org>; Tue, 9 Aug 2005 23:06:34 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j7A36kFI243312
	for <linux-mm@kvack.org>; Tue, 9 Aug 2005 21:06:46 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j7A36XKZ016562
	for <linux-mm@kvack.org>; Tue, 9 Aug 2005 21:06:33 -0600
Subject: Re: [PATCH] gurantee DMA area for alloc_bootmem_low() ver. 2.
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050809211501.GB6235@w-mikek2.ibm.com>
References: <20050809194115.C370.Y-GOTO@jp.fujitsu.com>
	 <20050809211501.GB6235@w-mikek2.ibm.com>
Content-Type: text/plain
Date: Tue, 09 Aug 2005 20:06:28 -0700
Message-Id: <1123643188.7069.8.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Kravetz <kravetz@us.ibm.com>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, "Martin J. Bligh" <mbligh@mbligh.org>, ia64 list <linux-ia64@vger.kernel.org>, "Luck, Tony" <tony.luck@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2005-08-09 at 14:15 -0700, Mike Kravetz wrote:
> On Tue, Aug 09, 2005 at 08:11:20PM +0900, Yasunori Goto wrote:
> > I modified the patch which guarantees allocation of DMA area
> > at alloc_bootmem_low().
> 
> I was going to replace more instances of __pa(MAX_DMA_ADDRESS) with
> max_dma_physaddr().  However, when grepping for MAX_DMA_ADDRESS I
> noticed instances of virt_to_phys(MAX_DMA_ADDRESS) as well.  Can
> someone tell me what the differences are between __pa() and virt_to_phys().

At least one is that virt_to_phys()'s argument is usually 'volatile'
while __pa() is not.  This, of course, varies from arch to arch. 

If somebody wants to go and rip __pa() out from all of the arches, I
won't be especially sorry :)

Actually, it would be nice to have one arch-generic version which is
just the usual (vaddr - PAGE_OFFSET).  That would probably take care of
80% of the individual implementations.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
