Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j79LF6xk709850
	for <linux-mm@kvack.org>; Tue, 9 Aug 2005 17:15:07 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j79LFJFI268552
	for <linux-mm@kvack.org>; Tue, 9 Aug 2005 15:15:19 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j79LF6kW024358
	for <linux-mm@kvack.org>; Tue, 9 Aug 2005 15:15:06 -0600
Date: Tue, 9 Aug 2005 14:15:02 -0700
From: Mike Kravetz <kravetz@us.ibm.com>
Subject: Re: [PATCH] gurantee DMA area for alloc_bootmem_low() ver. 2.
Message-ID: <20050809211501.GB6235@w-mikek2.ibm.com>
References: <20050809194115.C370.Y-GOTO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050809194115.C370.Y-GOTO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, "Martin J. Bligh" <mbligh@mbligh.org>, linux-ia64@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 09, 2005 at 08:11:20PM +0900, Yasunori Goto wrote:
> I modified the patch which guarantees allocation of DMA area
> at alloc_bootmem_low().

Thanks!

I was going to replace more instances of __pa(MAX_DMA_ADDRESS) with
max_dma_physaddr().  However, when grepping for MAX_DMA_ADDRESS I
noticed instances of virt_to_phys(MAX_DMA_ADDRESS) as well.  Can
someone tell me what the differences are between __pa() and virt_to_phys().
I noticed that on some archs they are the same, but are different on
others.

-- 
Mike
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
