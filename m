Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m7ILRlPL025248
	for <linux-mm@kvack.org>; Mon, 18 Aug 2008 17:27:47 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7ILRlC3241816
	for <linux-mm@kvack.org>; Mon, 18 Aug 2008 17:27:47 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7ILRlQw013779
	for <linux-mm@kvack.org>; Mon, 18 Aug 2008 17:27:47 -0400
Subject: Re: sparsemem support for mips with highmem
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <48A9E89C.4020408@linux-foundation.org>
References: <48A4AC39.7020707@sciatl.com>	<1218753308.23641.56.camel@nimitz>
	 <48A4C542.5000308@sciatl.com>	<20080815080331.GA6689@alpha.franken.de>
	 <1218815299.23641.80.camel@nimitz>	<48A5AADE.1050808@sciatl.com>
	 <20080815163302.GA9846@alpha.franken.de>	<48A5B9F1.3080201@sciatl.com>
	 <1218821875.23641.103.camel@nimitz>	<48A5C831.3070002@sciatl.com>
	 <20080818094412.09086445.rdunlap@xenotime.net>
	 <48A9E89C.4020408@linux-foundation.org>
Content-Type: text/plain
Date: Mon, 18 Aug 2008 14:27:45 -0700
Message-Id: <1219094865.23641.118.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Randy Dunlap <rdunlap@xenotime.net>, C Michael Sundius <Michael.sundius@sciatl.com>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, linux-mm@kvack.org, linux-mips@linux-mips.org, jfraser@broadcom.com, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-08-18 at 16:24 -0500, Christoph Lameter wrote:
> 
> This overhead can be avoided by configuring sparsemem to use a virtual vmemmap
> (CONFIG_SPARSEMEM_VMEMMAP). In that case it can be used for non NUMA since the
> overhead is less than even FLATMEM.

Is that all it takes these days, or do you need some other arch-specific
code to help out?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
