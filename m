Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m8UFof4f019801
	for <linux-mm@kvack.org>; Tue, 30 Sep 2008 11:50:41 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8UFoeDk134450
	for <linux-mm@kvack.org>; Tue, 30 Sep 2008 11:50:41 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8UFoeMS004787
	for <linux-mm@kvack.org>; Tue, 30 Sep 2008 11:50:40 -0400
Subject: Re: [PATCH] mm: show node to memory section relationship with
	symlinks in sysfs
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20080930163324.44A7.E1E9C6FF@jp.fujitsu.com>
References: <20080929200509.GC21255@us.ibm.com>
	 <20080930163324.44A7.E1E9C6FF@jp.fujitsu.com>
Content-Type: text/plain
Date: Tue, 30 Sep 2008 08:50:37 -0700
Message-Id: <1222789837.17630.41.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Gary Hade <garyhade@us.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Badari Pulavarty <pbadari@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Chris McDermott <lcm@us.ibm.com>, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Greg KH <greg@kroah.com>, Nish Aravamudan <nish.aravamudan@gmail.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-09-30 at 17:06 +0900, Yasunori Goto wrote:
> > +#define section_nr_to_nid(section_nr) pfn_to_nid(section_nr_to_pfn(section_nr))
> >  #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
> 
> If the first page of the section is not valid, then this section_nr_to_nid()
> doesn't return correct value.
> 
> I tested this patch. In my box, the start_pfn of node 1 is 1200400, but 
> section_nr_to_pfn(mem_blk->phys_index) returns 1200000. As a result,
> the section is linked to node 0.

Crap, I was worried about that.

Gary, this means that we have a N:1 relationship between NUMA nodes and
sections.  This normally isn't a problem because sections don't really
care about nodes and they layer underneath them.

We'll probably need multiple symlinks in each section directory.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
