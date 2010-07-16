Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 22BCB6B02A3
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 14:33:38 -0400 (EDT)
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6GIL1a7012657
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 14:21:01 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6GIXW3i1716346
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 14:33:32 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6GIXWqS004375
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 15:33:32 -0300
Subject: Re: [PATCH 1/5] v2 Split the memory_block structure
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <4C40A3BC.3060504@austin.ibm.com>
References: <4C3F53D1.3090001@austin.ibm.com>
	 <4C3F557F.3000304@austin.ibm.com> <1279300521.9207.222.camel@nimitz>
	 <4C40A3BC.3060504@austin.ibm.com>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Fri, 16 Jul 2010 11:33:30 -0700
Message-ID: <1279305210.9207.250.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nathan Fontenot <nfont@austin.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2010-07-16 at 13:23 -0500, Nathan Fontenot wrote:
> > If the memory_block's state was inferred to be the same as each
> > memory_block_section, couldn't we just keep a start and end phys_index
> > in the memory_block, and get away from having memory_block_sections at
> > all?
> 
> Oooohhh... I like.  Looking at the code it appears this is possible.  I'll
> try this out and include it in the next version of the patch.
> 
> Do you think we need to add an additional file to each memory block directory
> to indicate the number of memory sections in the memory block that are actually
> present? 

I think it's easiest to just say that each 'memory_block' can only hold
contiguous 'memory_block_sections', and we give either the start/end or
start/length pairs.  It gets a lot more complicated if we have to deal
with lots of holes.

I can just see the hardware designers reading this thread, with their
Dr. Evil laughs trying to come up with a reason to give us a couple of
terabytes of RAM with only every-other 16MB area populated. :)  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
