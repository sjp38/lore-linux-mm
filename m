Message-ID: <48A9EAA9.1080909@linux-foundation.org>
Date: Mon, 18 Aug 2008 16:33:29 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: sparsemem support for mips with highmem
References: <48A4AC39.7020707@sciatl.com>	<1218753308.23641.56.camel@nimitz>	 <48A4C542.5000308@sciatl.com>	<20080815080331.GA6689@alpha.franken.de>	 <1218815299.23641.80.camel@nimitz>	<48A5AADE.1050808@sciatl.com>	 <20080815163302.GA9846@alpha.franken.de>	<48A5B9F1.3080201@sciatl.com>	 <1218821875.23641.103.camel@nimitz>	<48A5C831.3070002@sciatl.com>	 <20080818094412.09086445.rdunlap@xenotime.net>	 <48A9E89C.4020408@linux-foundation.org> <1219094865.23641.118.camel@nimitz>
In-Reply-To: <1219094865.23641.118.camel@nimitz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Randy Dunlap <rdunlap@xenotime.net>, C Michael Sundius <Michael.sundius@sciatl.com>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, linux-mm@kvack.org, linux-mips@linux-mips.org, jfraser@broadcom.com, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
> On Mon, 2008-08-18 at 16:24 -0500, Christoph Lameter wrote:
>> This overhead can be avoided by configuring sparsemem to use a virtual vmemmap
>> (CONFIG_SPARSEMEM_VMEMMAP). In that case it can be used for non NUMA since the
>> overhead is less than even FLATMEM.
> 
> Is that all it takes these days, or do you need some other arch-specific
> code to help out?

Some information is in mm/sparse-vmemmap.c. Simplest configuration is to use
vmalloc for the populate function. Otherwise the arch can do what it wants to
reduce the overhead of virtual mappings (in the x86 case we use a 2M TLB
entry, and since 2M TLBs are also used for the 1-1 physical mapping the
overhead is the same as for 1-1 mappings).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
