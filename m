Message-ID: <48AAC54D.8020609@linux-foundation.org>
Date: Tue, 19 Aug 2008 08:06:21 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: sparsemem support for mips with highmem
References: <48A4AC39.7020707@sciatl.com>	<1218753308.23641.56.camel@nimitz>	<48A4C542.5000308@sciatl.com>	<20080815080331.GA6689@alpha.franken.de>	<1218815299.23641.80.camel@nimitz>	<48A5AADE.1050808@sciatl.com>	<20080815163302.GA9846@alpha.franken.de>	<48A5B9F1.3080201@sciatl.com>	<1218821875.23641.103.camel@nimitz>	<48A5C831.3070002@sciatl.com> <20080818094412.09086445.rdunlap@xenotime.net> <48A9E89C.4020408@linux-foundation.org> <48A9F047.7050906@cisco.com>
In-Reply-To: <48A9F047.7050906@cisco.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David VomLehn <dvomlehn@cisco.com>
Cc: Randy Dunlap <rdunlap@xenotime.net>, C Michael Sundius <Michael.sundius@sciatl.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, linux-mm@kvack.org, linux-mips@linux-mips.org, jfraser@broadcom.com, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

David VomLehn wrote:

> On MIPS processors, the kernel runs in unmapped memory, i.e. the TLB
> isn't even
> used, so I don't think you can use that trick. So, this comment doesn't
> apply to
> all processors.

In that case you have a choice between the overhead of sparsemem lookups in
every pfn_to_page or using TLB entries to create a virtually mapped memmap
which may create TLB pressure.

The virtually mapped memmap results in smaller code and is typically more
effective since the processor caches the TLB entries.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
