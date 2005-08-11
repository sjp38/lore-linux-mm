Date: Thu, 11 Aug 2005 13:46:22 -0700 (PDT)
From: Christoph Lameter <christoph@lameter.com>
Subject: Re: [PATCH] gurantee DMA area for alloc_bootmem_low() ver. 2.
In-Reply-To: <20050809211501.GB6235@w-mikek2.ibm.com>
Message-ID: <Pine.LNX.4.62.0508111343300.19728@graphe.net>
References: <20050809194115.C370.Y-GOTO@jp.fujitsu.com>
 <20050809211501.GB6235@w-mikek2.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Kravetz <kravetz@us.ibm.com>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, "Martin J. Bligh" <mbligh@mbligh.org>, linux-ia64@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, 9 Aug 2005, Mike Kravetz wrote:

> I was going to replace more instances of __pa(MAX_DMA_ADDRESS) with
> max_dma_physaddr().  However, when grepping for MAX_DMA_ADDRESS I
> noticed instances of virt_to_phys(MAX_DMA_ADDRESS) as well.  Can
> someone tell me what the differences are between __pa() and virt_to_phys().
> I noticed that on some archs they are the same, but are different on
> others.

On which arches do they differ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
