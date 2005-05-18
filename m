Date: Wed, 18 May 2005 09:43:48 -0700
From: Matt Tolentino <metolent@snoqualmie.dp.intel.com>
Message-Id: <200505181643.j4IGhm7S026977@snoqualmie.dp.intel.com>
Subject: Re: [patch 2/4] add x86-64 Kconfig options for sparsemem
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ak@muc.de, metolent@snoqualmie.dp.intel.com
Cc: akpm@osdl.org, apw@shadowen.org, haveblue@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>On Wed, May 18, 2005 at 08:24:41AM -0700, Matt Tolentino wrote:
>> 
>> Add the requisite arch specific Kconfig options to enable 
>> the use of the sparsemem implementation for NUMA kernels
>> on x86-64.
>
>How much did you test sparsemem on x86-64 NUMA ? 
>
>There are various cases that probably need to be checked,
>AMD with SRAT, AMD without SRAT, AMD with more than 4GB RAM, 
>Summit(?), NUMA EMULATION etc.
>
>If all that works I would have no problem with removing the
>old code.

As my disclaimer said, this has only been tested using
the NUMA EMULATION config option.  That's a big part of
the reason for sending this out  - to get further testing 
on real x86-64 NUMA systems, but without breaking the
current discontigmem code.  

I expect to be able to test this on at least one AMD system
at the local University systems lab, but haven't had a
chance to do so yet.

matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
