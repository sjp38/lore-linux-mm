Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1F1526B0078
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 17:52:44 -0400 (EDT)
Subject: Re: Reserved pages in PowerPC
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20100916120806.GJ2332@in.ibm.com>
References: <20100916052311.GC2332@in.ibm.com>
	 <1284631464.30449.85.camel@pasglop>  <20100916120806.GJ2332@in.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 17 Sep 2010 07:52:31 +1000
Message-ID: <1284673951.30449.93.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ankita Garg <ankita@in.ibm.com>
Cc: linuxppc-dev@ozlabs.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2010-09-16 at 17:38 +0530, Ankita Garg wrote:
> Thanks Ben for taking a look at this. So I checked the rtas messages
> on
> the serial console and see the following:
> 
> instantiating rtas at 0x000000000f632000... done
> 
> Which does not correspond to the higher addresses that I see as
> reserved
> (observation on a 16G machine). 

Well, I'd suggest you audit prom_init.c which builds the reserve map,
and the various memblock_reserve() calls in prom.c

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
