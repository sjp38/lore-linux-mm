Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.12.10/8.12.9) with ESMTP id iAI2O6Kv455296
	for <linux-mm@kvack.org>; Wed, 17 Nov 2004 21:24:06 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iAI2O5b3284260
	for <linux-mm@kvack.org>; Wed, 17 Nov 2004 21:24:05 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id iAI2O5Hf024622
	for <linux-mm@kvack.org>; Wed, 17 Nov 2004 21:24:05 -0500
Subject: Re: [Lhms-devel] [RFC] fix for hot-add enabled SRAT/BIOS and numa
	KVA areas
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1100743722.26335.644.camel@knk>
References: <1100659057.26335.125.camel@knk>
	 <1100711519.5838.2.camel@localhost>  <1100743722.26335.644.camel@knk>
Content-Type: text/plain
Message-Id: <1100744644.17510.8.camel@localhost>
Mime-Version: 1.0
Date: Wed, 17 Nov 2004 18:24:04 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: keith <kmannth@us.ibm.com>
Cc: external hotplug mem list <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>, Chris McDermott <lcm@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2004-11-17 at 18:08, keith wrote:
>   I am not anticipating to support hot-add without config_nonlinear or
> something similar which should provide more flexibility in allocation of
> smaller section mem_maps.  This is only a issue when booted as a
> discontig system.  We don't even consult the SRAT when we boot flat
> (contiguous address space) so it is a non-issue.

Once a system has been running for any length of time, finding any
multi-order pages gets somewhat hard.  For a 16M section, you're still
talking about ~128k of mem_map, which is still an order 5 allocation. 
Nick's kswapd higher-order patches should help with this, though.

>   Wasting 500k of lowmem for memory that "might" be there is no good.  I
> don't think having to preallocate the mem_map for a hot-add is really
> that good.  What if the system never adds memory?  What if it only adds
> 8gig not 49g?  The system is crippled because it reserves the lmem_map
> it "might" do a hot add with?  

I have the feeling we'll eventually need a boot-time option for this
reservation.  Your patch, of course will work for now.  Do you want me
to pick it up in my tree?

>   I forgot the mention that without this patch my system does not boot
> with the hot-add support enabled in the bios.  

Why not?  I'm just curious what caused the actual failure.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
