Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B42736B01E3
	for <linux-mm@kvack.org>; Thu, 13 May 2010 14:03:04 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e4.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o4DHnxRv016598
	for <linux-mm@kvack.org>; Thu, 13 May 2010 13:49:59 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o4DI2VLD161020
	for <linux-mm@kvack.org>; Thu, 13 May 2010 14:02:31 -0400
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o4DI2KZR007243
	for <linux-mm@kvack.org>; Thu, 13 May 2010 12:02:21 -0600
Subject: Re: [RFC, 6/7] NUMA hotplug emulator
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20100513165603.GC25212@suse.de>
References: <20100513120016.GG2169@shaohui> <20100513165603.GC25212@suse.de>
Content-Type: text/plain
Date: Thu, 13 May 2010 11:02:17 -0700
Message-Id: <1273773737.13285.7771.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg KH <gregkh@suse.de>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andi Kleen <ak@linux.intel.com>, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Thu, 2010-05-13 at 09:56 -0700, Greg KH wrote:
> On Thu, May 13, 2010 at 08:00:16PM +0800, Shaohui Zheng wrote:
> > hotplug emulator:extend memory probe interface to support NUMA
> > 
> > Extend memory probe interface to support an extra paramter nid,
> > the reserved memory can be added into this node if node exists.
> > 
> > Add a memory section(128M) to node 3(boots with mem=1024m)
> > 
> >       echo 0x40000000,3 > memory/probe

I dunno.  If we're going to put multiple values into the file now and
add to the ABI, can we be more explicit about it?

	echo "physical_address=0x40000000 numa_node=3" > memory/probe

I'd *GREATLY* prefer that over this new syntax.  The existing mechanism
is obtuse enough, and the ',3' makes it more so.

We should have the code around to parse arguments like that, too, since
we use it for the boot command-line.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
