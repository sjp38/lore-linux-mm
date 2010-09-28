Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id CF55F6B0047
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 06:28:58 -0400 (EDT)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp05.in.ibm.com (8.14.4/8.13.1) with ESMTP id o8SASpgb005088
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 15:58:51 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o8SASpNb4599986
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 15:58:51 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8SASpgI009098
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 20:28:51 +1000
Date: Tue, 28 Sep 2010 15:58:51 +0530
From: Ankita Garg <ankita@in.ibm.com>
Subject: Re: Reserved pages in PowerPC
Message-ID: <20100928102851.GF1990@in.ibm.com>
Reply-To: Ankita Garg <ankita@in.ibm.com>
References: <20100916052311.GC2332@in.ibm.com>
 <1284631464.30449.85.camel@pasglop>
 <20100916120806.GJ2332@in.ibm.com>
 <1284673951.30449.93.camel@pasglop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1284673951.30449.93.camel@pasglop>
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: linuxppc-dev@ozlabs.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Ben,

On Fri, Sep 17, 2010 at 07:52:31AM +1000, Benjamin Herrenschmidt wrote:
> On Thu, 2010-09-16 at 17:38 +0530, Ankita Garg wrote:
> > Thanks Ben for taking a look at this. So I checked the rtas messages
> > on
> > the serial console and see the following:
> > 
> > instantiating rtas at 0x000000000f632000... done
> > 
> > Which does not correspond to the higher addresses that I see as
> > reserved
> > (observation on a 16G machine). 
> 
> Well, I'd suggest you audit prom_init.c which builds the reserve map,
> and the various memblock_reserve() calls in prom.c
>

I studied and instrumented memblock_reserve() and also reserve_mem().
However, all the reserved addresses seem to correspond to lower memory.
I also observed that these reserved addresses are accessed quite rapidly
when a workload is being run.. 

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
