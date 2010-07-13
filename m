Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A2FBA6B02A4
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 16:47:09 -0400 (EDT)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6DKUx6i024453
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 16:30:59 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6DKl1x2138518
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 16:47:01 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6DKl0Ma030111
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 17:47:01 -0300
Subject: Re: [RFC] Tight check of pfn_valid on sparsemem
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20100713183932.GB31162@n2100.arm.linux.org.uk>
References: <20100712155348.GA2815@barrios-desktop>
	 <20100713121947.612bd656.kamezawa.hiroyu@jp.fujitsu.com>
	 <AANLkTiny7dz8ssDknI7y4JFcVP9SV1aNM7f0YMUxafv7@mail.gmail.com>
	 <20100713132312.a7dfb100.kamezawa.hiroyu@jp.fujitsu.com>
	 <AANLkTinVwmo5pemz86nXaQT3V_ujaPLOsyNeQIFhL0Vu@mail.gmail.com>
	 <20100713072009.GA19839@n2100.arm.linux.org.uk>
	 <20100713163417.17895202.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100713165808.e340e6dc.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100713170222.9369e649.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100713183932.GB31162@n2100.arm.linux.org.uk>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Tue, 13 Jul 2010 13:46:59 -0700
Message-ID: <1279054019.10995.18.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shaohua.li@intel.com>, Yakui Zhao <yakui.zhao@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, arm-kernel@lists.infradead.org, kgene.kim@samsung.com, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Tue, 2010-07-13 at 19:39 +0100, Russell King - ARM Linux wrote:
> On Tue, Jul 13, 2010 at 05:02:22PM +0900, KAMEZAWA Hiroyuki wrote:
> > How about stop using SPARSEMEM ? What's the benefit ? It just eats up
> > memory for mem_section[].
> 
> The problem with that approach is that sometimes the mem_map array
> doesn't fit into any memory banks.
> 
> We've gone around the loop of using flatmem with holes punched in it,
> to using discontigmem, and now to using sparsemem.  It seems none of
> these solutions does what we need for ARM.  I guess that's the price
> we pay for not having memory architected to be at any particular place
> in the physical memory map.

What's the ARM hardware's maximum addressable memory these days? 4GB?

A 4GB system would have 256 sections, which means 256*2*sizeof(unsigned
long) for the mem_section[].  That's a pretty small amount of RAM.

What sizes are the holes that are being punched these days?  Smaller
than 16MB?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
