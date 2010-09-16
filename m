Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 5A0EB6B007E
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 08:16:05 -0400 (EDT)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp02.in.ibm.com (8.14.4/8.13.1) with ESMTP id o8GC880J012683
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 17:38:08 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o8GC88Br2625644
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 17:38:08 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8GC87KK003514
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 22:08:07 +1000
Date: Thu, 16 Sep 2010 17:38:06 +0530
From: Ankita Garg <ankita@in.ibm.com>
Subject: Re: Reserved pages in PowerPC
Message-ID: <20100916120806.GJ2332@in.ibm.com>
Reply-To: Ankita Garg <ankita@in.ibm.com>
References: <20100916052311.GC2332@in.ibm.com>
 <1284631464.30449.85.camel@pasglop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1284631464.30449.85.camel@pasglop>
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: linuxppc-dev@ozlabs.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Ben,

On Thu, Sep 16, 2010 at 08:04:24PM +1000, Benjamin Herrenschmidt wrote:
> On Thu, 2010-09-16 at 10:53 +0530, Ankita Garg wrote:
> > 
> > With some debugging I found that that section has reserved pages. On
> > instrumenting the memblock_reserve() and reserve_bootmem() routines, I can see
> > that many of the memory areas are reserved for kernel and initrd by the
> > memblock reserve() itself. reserve_bootmem then looks at the pages already
> > reserved and marks them reserved. However, for the very last section, I see
> > that bootmem reserves it but I am unable to find a corresponding reservation
> > by the memblock code.
> 
> It's probably RTAS (firmware runtime services). I'ts instanciated at
> boot from prom_init and we do favor high addresses for it below 1G iirc.
>

Thanks Ben for taking a look at this. So I checked the rtas messages on
the serial console and see the following:

instantiating rtas at 0x000000000f632000... done

Which does not correspond to the higher addresses that I see as reserved
(observation on a 16G machine).

-- 
Regards,
Ankita Garg (ankita@in.ibm.com)
Linux Technology Center
IBM India Systems & Technology Labs,
Bangalore, India

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
