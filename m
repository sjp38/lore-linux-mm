Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j6BHKrTr006743
	for <linux-mm@kvack.org>; Mon, 11 Jul 2005 13:20:53 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j6BHKcOs241744
	for <linux-mm@kvack.org>; Mon, 11 Jul 2005 13:20:53 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j6BHKbqv007000
	for <linux-mm@kvack.org>; Mon, 11 Jul 2005 13:20:37 -0400
Subject: Re: [NUMA] /proc/<pid>/numa_maps to show on which nodes pages
	reside
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.62.0507081410520.16934@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0507081410520.16934@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 11 Jul 2005 10:20:33 -0700
Message-Id: <1121102433.15095.26.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: linux-mm <linux-mm@kvack.org>, ia64 list <linux-ia64@vger.kernel.org>, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On Fri, 2005-07-08 at 14:11 -0700, Christoph Lameter wrote:
> I inherited a large code base from Ray for page migration. There was a
> small patch in there that I find to be very useful since it allows the display
> of the locality of the pages in use by a process. I reworked that patch and came
> up with a /proc/<pid>/numa_maps that gives more information about the vma's of
> a process. numa_maps is indexes by the start address found in /proc/<pid>/maps.
> F.e. with this patch you can see the page use of the "getty" process:

That looks quite useful.  However, it *is* confined to helping NUMA
systems, and I think some modifications could allow it to be used for
memory hotplug.

We're planning to have memory laid out
in /sys/devices/system/memory/memoryXXX, where each memory object has a
fixed size.  If NUMA is on, these objects also point back to their
owning NUMA node.

So, if something like numa_maps existed, but pointed to the memory
object instead of the NUMA node directly, you could still easily derive
the NUMA node.  But, you'd also get information about which particular
bits of memory are being used.  That might be useful for a user that's
getting desperate to remove some memory and wants to kill some processes
that might be less than willing to release that memory.

The downside is that we'll have to get that sysfs stuff working for !
SPARSEMEM configurations.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
