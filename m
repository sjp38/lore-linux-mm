Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m8UJgDkV024051
	for <linux-mm@kvack.org>; Tue, 30 Sep 2008 15:42:13 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8UJg2Mu047886
	for <linux-mm@kvack.org>; Tue, 30 Sep 2008 13:42:11 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8UJg14H023237
	for <linux-mm@kvack.org>; Tue, 30 Sep 2008 13:42:02 -0600
Date: Tue, 30 Sep 2008 12:41:22 -0700
From: Gary Hade <garyhade@us.ibm.com>
Subject: Re: [PATCH] mm: show node to memory section relationship with
	symlinks in sysfs
Message-ID: <20080930194122.GA7123@us.ibm.com>
References: <20080929200509.GC21255@us.ibm.com> <20080930163324.44A7.E1E9C6FF@jp.fujitsu.com> <1222789837.17630.41.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1222789837.17630.41.camel@nimitz>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, Gary Hade <garyhade@us.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Badari Pulavarty <pbadari@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Chris McDermott <lcm@us.ibm.com>, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Greg KH <greg@kroah.com>, Nish Aravamudan <nish.aravamudan@gmail.com>
List-ID: <linux-mm.kvack.org>

On Tue, Sep 30, 2008 at 08:50:37AM -0700, Dave Hansen wrote:
> On Tue, 2008-09-30 at 17:06 +0900, Yasunori Goto wrote:
> > > +#define section_nr_to_nid(section_nr) pfn_to_nid(section_nr_to_pfn(section_nr))
> > >  #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
> > 
> > If the first page of the section is not valid, then this section_nr_to_nid()
> > doesn't return correct value.
> > 
> > I tested this patch. In my box, the start_pfn of node 1 is 1200400, but 
> > section_nr_to_pfn(mem_blk->phys_index) returns 1200000. As a result,
> > the section is linked to node 0.
> 
> Crap, I was worried about that.
> 
> Gary, this means that we have a N:1 relationship between NUMA nodes and
> sections.  This normally isn't a problem because sections don't really
> care about nodes and they layer underneath them.

So, using Yasunori-san's example the memory section starting at
pfn 1200000 actually resides on both node 0 and node 1.

> 
> We'll probably need multiple symlinks in each section directory.

or perhaps symlinks to the same section directory from >1 node directory.

Gary

-- 
Gary Hade
System x Enablement
IBM Linux Technology Center
503-578-4503  IBM T/L: 775-4503
garyhade@us.ibm.com
http://www.ibm.com/linux/ltc

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
