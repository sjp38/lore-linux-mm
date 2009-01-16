Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7519D6B0089
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 16:46:32 -0500 (EST)
Received: from rtp-core-1.cisco.com (rtp-core-1.cisco.com [64.102.124.12])
	by rtp-dkim-2.cisco.com (8.12.11/8.12.11) with ESMTP id n0GLkUqq019357
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 16:46:30 -0500
Received: from sausatlsmtp1.sciatl.com (sausatlsmtp1.cisco.com [192.133.217.33])
	by rtp-core-1.cisco.com (8.13.8/8.13.8) with ESMTP id n0GLkUiB024161
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 21:46:30 GMT
Message-ID: <4971002D.2090907@cisco.com>
Date: Fri, 16 Jan 2009 13:46:21 -0800
From: Michael Sundius <msundius@cisco.com>
MIME-Version: 1.0
Subject: Re: sparsemem support for mips with highmem
References: <48A4AC39.7020707@sciatl.com>	<1218753308.23641.56.camel@nimitz>	 <48A4C542.5000308@sciatl.com>	<20080815080331.GA6689@alpha.franken.de>	 <1218815299.23641.80.camel@nimitz>	<48A5AADE.1050808@sciatl.com>	 <20080815163302.GA9846@alpha.franken.de>	<48A5B9F1.3080201@sciatl.com>	 <1218821875.23641.103.camel@nimitz>	<48A5C831.3070002@sciatl.com>	 <20080818094412.09086445.rdunlap@xenotime.net>	 <48A9E89C.4020408@linux-foundation.org> <1219094865.23641.118.camel@nimitz> <48A9EAA9.1080909@linux-foundation.org>
In-Reply-To: <48A9EAA9.1080909@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Randy Dunlap <rdunlap@xenotime.net>, "Sundius, Michael" <Michael.sundius@sciatl.com>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, linux-mm@kvack.org, linux-mips@linux-mips.org, jfraser@broadcom.com, Andy Whitcroft <apw@shadowen.org>, msundius@sundius.com
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
>
> Dave Hansen wrote:
> > On Mon, 2008-08-18 at 16:24 -0500, Christoph Lameter wrote:
> >> This overhead can be avoided by configuring sparsemem to use a 
> virtual vmemmap
> >> (CONFIG_SPARSEMEM_VMEMMAP). In that case it can be used for non 
> NUMA since the
> >> overhead is less than even FLATMEM.
> >
> > Is that all it takes these days, or do you need some other arch-specific
> > code to help out?
>
> Some information is in mm/sparse-vmemmap.c. Simplest configuration is 
> to use
> vmalloc for the populate function. Otherwise the arch can do what it 
> wants to
> reduce the overhead of virtual mappings (in the x86 case we use a 2M TLB
> entry, and since 2M TLBs are also used for the 1-1 physical mapping the
> overhead is the same as for 1-1 mappings).
>
>
Well, I finally gotten around to turning the vmemmap on for our 
sparsemem on Mips.

I have a question about what you said above and how that applies to mips.

you said that the simplest configuration is to use vmalloc for the 
populate function.
could you expand on that? (i didn't see that the populate function used 
vmalloc or maybe
we are talking about a different populate function).

I've noticed that from looking at the kernel, only 64 bit processors or 
at least processors
that use a 3 level page table have the vmemmap_populate() function 
implemented.

in looking at the function vmemmap_populate_basepages() (called by most 
vmemmap_populate funcs)
it seems to create a 3 level
page table. not sure what my question here is, but maybe what do I have 
to do to make
this work w/ mips which i understand uses only 2 levels can I just take 
out the part of
the function that sets up the middle level table?

Has anyone done this on mips?

mike





     - - - - -                              Cisco                            - - - - -         
This e-mail and any attachments may contain information which is confidential, 
proprietary, privileged or otherwise protected by law. The information is solely 
intended for the named addressee (or a person responsible for delivering it to 
the addressee). If you are not the intended recipient of this message, you are 
not authorized to read, print, retain, copy or disseminate this message or any 
part of it. If you have received this e-mail in error, please notify the sender 
immediately by return e-mail and delete it from your computer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
