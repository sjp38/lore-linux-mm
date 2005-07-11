Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j6BKVK2d013902
	for <linux-mm@kvack.org>; Mon, 11 Jul 2005 16:31:20 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j6BKVKOs128574
	for <linux-mm@kvack.org>; Mon, 11 Jul 2005 16:31:20 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j6BKVKrq004537
	for <linux-mm@kvack.org>; Mon, 11 Jul 2005 16:31:20 -0400
Subject: Re: [NUMA] /proc/<pid>/numa_maps to show on which nodes pages
	reside
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.62.0507111058270.21618@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0507081410520.16934@schroedinger.engr.sgi.com>
	 <1121102433.15095.26.camel@localhost>
	 <Pine.LNX.4.62.0507111058270.21618@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 11 Jul 2005 13:31:15 -0700
Message-Id: <1121113875.15095.45.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: linux-mm <linux-mm@kvack.org>, ia64 list <linux-ia64@vger.kernel.org>, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On Mon, 2005-07-11 at 11:02 -0700, Christoph Lameter wrote:
> On Mon, 11 Jul 2005, Dave Hansen wrote:
> 
> > So, if something like numa_maps existed, but pointed to the memory
> > object instead of the NUMA node directly, you could still easily derive
> > the NUMA node.  But, you'd also get information about which particular
> > bits of memory are being used.  That might be useful for a user that's
> > getting desperate to remove some memory and wants to kill some processes
> > that might be less than willing to release that memory.
> 
> We really need both I guess. If you dealing with a batch scheduler that
> wants to move memory around between nodes in order to optimize programs 
> then you nedd to have numa_maps. Maybe we need to have two: numa_maps 
> and memory_maps?

Well, my point was that, if we have two, the numa_maps can be completely
derived in userspace from the information in memory_maps plus sysfs
alone.  So, why increase the kernel's complexity with two
implementations that can do the exact same thing?  Yes, it might make
the batch scheduler do one more pathname lookup, but that's not the
kernel's problem :)

BTW, are you planning on using SPARSEMEM whenever NUMA is enabled in the
future?  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
