Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j7AGNpOY012200
	for <linux-mm@kvack.org>; Wed, 10 Aug 2005 12:23:51 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j7AGNl1t182116
	for <linux-mm@kvack.org>; Wed, 10 Aug 2005 12:23:51 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j7AGNldk000757
	for <linux-mm@kvack.org>; Wed, 10 Aug 2005 12:23:47 -0400
Subject: Re: [PATCH] gurantee DMA area for alloc_bootmem_low() ver. 2.
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1123643188.7069.8.camel@localhost>
References: <20050809194115.C370.Y-GOTO@jp.fujitsu.com>
	 <20050809211501.GB6235@w-mikek2.ibm.com>
	 <1123643188.7069.8.camel@localhost>
Content-Type: text/plain
Date: Wed, 10 Aug 2005 09:23:41 -0700
Message-Id: <1123691021.11313.2.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Kravetz <kravetz@us.ibm.com>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, "Martin J. Bligh" <mbligh@mbligh.org>, ia64 list <linux-ia64@vger.kernel.org>, "Luck, Tony" <tony.luck@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2005-08-09 at 20:06 -0700, Dave Hansen wrote: 
> On Tue, 2005-08-09 at 14:15 -0700, Mike Kravetz wrote:
> > On Tue, Aug 09, 2005 at 08:11:20PM +0900, Yasunori Goto wrote:
> > > I modified the patch which guarantees allocation of DMA area
> > > at alloc_bootmem_low().
> > 
> > I was going to replace more instances of __pa(MAX_DMA_ADDRESS) with
> > max_dma_physaddr().  However, when grepping for MAX_DMA_ADDRESS I
> > noticed instances of virt_to_phys(MAX_DMA_ADDRESS) as well.  Can
> > someone tell me what the differences are between __pa() and virt_to_phys().

One more thing is the obvious: __pa() is always a macro, and
virt_to_phys() is sometimes a function.  __pa() can, therefore, be used
in assembly.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
