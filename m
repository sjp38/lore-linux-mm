Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id iAI28iJT644224
	for <linux-mm@kvack.org>; Wed, 17 Nov 2004 21:08:44 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iAI28iQC212184
	for <linux-mm@kvack.org>; Wed, 17 Nov 2004 19:08:44 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id iAI28h9v025862
	for <linux-mm@kvack.org>; Wed, 17 Nov 2004 19:08:43 -0700
Subject: Re: [Lhms-devel] [RFC] fix for hot-add enabled SRAT/BIOS and numa
	KVA areas
From: keith <kmannth@us.ibm.com>
In-Reply-To: <1100711519.5838.2.camel@localhost>
References: <1100659057.26335.125.camel@knk>
	 <1100711519.5838.2.camel@localhost>
Content-Type: text/plain
Message-Id: <1100743722.26335.644.camel@knk>
Mime-Version: 1.0
Date: Wed, 17 Nov 2004 18:08:42 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: external hotplug mem list <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>, Chris McDermott <lcm@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2004-11-17 at 09:11, Dave Hansen wrote:
> On Tue, 2004-11-16 at 18:37, keith wrote:
> >   The numa KVA code used the node_start and node_end values (obtained
> > from the above memory ranges) to make it's lowmem reservations.  The
> > problem is that the lowmem area reserved is quite large.  It reserves
> > the entire a lmem_map large enough for 0x1000000 address space.  I don't
> > feel this is a great use of lowmem on my system :)
> 
> It does seem silly to waste all of that lowmem for memory that *might*
> be there, but what do you plan to do for contiguous address space (for
> mem_map) once the memory addition occurs?  We've always talked about
> having to preallocate mem_map space on 32-bit platforms and by your
> patch it appears that this isn't what you want to do.  
> 
> -- Dave

  I am not anticipating to support hot-add without config_nonlinear or
something similar which should provide more flexibility in allocation of
smaller section mem_maps.  This is only a issue when booted as a
discontig system.  We don't even consult the SRAT when we boot flat
(contiguous address space) so it is a non-issue.

  Wasting 500k of lowmem for memory that "might" be there is no good.  I
don't think having to preallocate the mem_map for a hot-add is really
that good.  What if the system never adds memory?  What if it only adds
8gig not 49g?  The system is crippled because it reserves the lmem_map
it "might" do a hot add with?  

  I forgot the mention that without this patch my system does not boot
with the hot-add support enabled in the bios.  

Thanks,
  Keith 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
