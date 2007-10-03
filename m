Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l93Gb9mH026878
	for <linux-mm@kvack.org>; Wed, 3 Oct 2007 12:37:09 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l93Gb8q5296618
	for <linux-mm@kvack.org>; Wed, 3 Oct 2007 10:37:08 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l93Gb8Id028767
	for <linux-mm@kvack.org>; Wed, 3 Oct 2007 10:37:08 -0600
Subject: Re: [RFC] PPC64 Exporting memory information through /proc/iomem
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20071004012547.42c457b7.kamezawa.hiroyu@jp.fujitsu.com>
References: <1191346196.6106.20.camel@dyn9047017100.beaverton.ibm.com>
	 <18178.52359.953289.638736@cargo.ozlabs.ibm.com>
	 <1191366653.6106.68.camel@dyn9047017100.beaverton.ibm.com>
	 <20071003101954.52308f22.kamezawa.hiroyu@jp.fujitsu.com>
	 <1191425735.6106.76.camel@dyn9047017100.beaverton.ibm.com>
	 <20071004012547.42c457b7.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Wed, 03 Oct 2007 09:40:14 -0700
Message-Id: <1191429615.6106.88.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: paulus@samba.org, linuxppc-dev@ozlabs.org, linux-mm <linux-mm@kvack.org>, anton@au1.ibm.com
List-ID: <linux-mm.kvack.org>

On Thu, 2007-10-04 at 01:25 +0900, KAMEZAWA Hiroyuki wrote:
> On Wed, 03 Oct 2007 08:35:35 -0700
> Badari Pulavarty <pbadari@us.ibm.com> wrote:
> 
> > On Wed, 2007-10-03 at 10:19 +0900, KAMEZAWA Hiroyuki wrote:
> > CONFIG_ARCH_HAS_VALID_MEMORY_RANGE. Then define own
> > find_next_system_ram() (rename to is_valid_memory_range()) - which
> > checks the given range is a valid memory range for memory-remove
> > or not. What do you think ?
> > 
> My concern is...
> Now, memory hot *add* makes use of resource(/proc/iomem) information for onlining
> memory.(See add_memory()->register_memory_resource() in mm/memoryhotplug.c)
> So, we'll have to consider changing it if we need.
> 
> Does PPC64 memory hot add registers new memory information to arch dependent
> information list ? It seems ppc64 registers hot-added memory information from
> *probe* file and registers it by add_memory()->register_memory_resource().

Yes. Thats what I realized after looking at the code. 
I have been concentrating on memory remove, never care about "add" :(
Let me take a closer look at "add" support for ppc.

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
