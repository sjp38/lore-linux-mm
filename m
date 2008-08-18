Message-ID: <48A9E89C.4020408@linux-foundation.org>
Date: Mon, 18 Aug 2008 16:24:44 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: sparsemem support for mips with highmem
References: <48A4AC39.7020707@sciatl.com>	<1218753308.23641.56.camel@nimitz>	<48A4C542.5000308@sciatl.com>	<20080815080331.GA6689@alpha.franken.de>	<1218815299.23641.80.camel@nimitz>	<48A5AADE.1050808@sciatl.com>	<20080815163302.GA9846@alpha.franken.de>	<48A5B9F1.3080201@sciatl.com>	<1218821875.23641.103.camel@nimitz>	<48A5C831.3070002@sciatl.com> <20080818094412.09086445.rdunlap@xenotime.net>
In-Reply-To: <20080818094412.09086445.rdunlap@xenotime.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Randy Dunlap <rdunlap@xenotime.net>
Cc: C Michael Sundius <Michael.sundius@sciatl.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, linux-mm@kvack.org, linux-mips@linux-mips.org, jfraser@broadcom.com, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

Randy Dunlap wrote:

> +Sparsemem divides up physical memory in your system into N section of M
> 
>                                                             sections
> 
> +bytes. Page descriptors are created for only those sections that
> +actually exist (as far as the sparsemem code is concerned). This allows
> +for holes in the physical memory without having to waste space by
> +creating page discriptors for those pages that do not exist.
> 
>                descriptors
> 
> +When page_to_pfn() or pfn_to_page() are called there is a bit of overhead to
> +look up the proper memory section to get to the descriptors, but this
> +is small compared to the memory you are likely to save. So, it's not the
> +default, but should be used if you have big holes in physical memory.

This overhead can be avoided by configuring sparsemem to use a virtual vmemmap
(CONFIG_SPARSEMEM_VMEMMAP). In that case it can be used for non NUMA since the
overhead is less than even FLATMEM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
