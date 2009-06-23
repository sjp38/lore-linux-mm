Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 92A6A6B0055
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 17:40:56 -0400 (EDT)
Subject: Re: [PATCH] Hugepages should be accounted as unevictable pages.
From: Alok Kataria <akataria@vmware.com>
Reply-To: akataria@vmware.com
In-Reply-To: <4A41481D.1060607@redhat.com>
References: <20090623093459.2204.A69D9226@jp.fujitsu.com>
	 <1245732411.18339.6.camel@alok-dev1>
	 <20090623135017.220D.A69D9226@jp.fujitsu.com>
	 <20090623141147.8f2cef18.kamezawa.hiroyu@jp.fujitsu.com>
	 <1245736441.18339.21.camel@alok-dev1>  <4A41481D.1060607@redhat.com>
Content-Type: text/plain
Date: Tue, 23 Jun 2009 14:42:11 -0700
Message-Id: <1245793331.24110.33.camel@alok-dev1>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Tue, 2009-06-23 at 14:24 -0700, Rik van Riel wrote:
> Alok Kataria wrote:
> 
> > Both, while working on an module I noticed that there is no way direct
> > way to get any information regarding the total number of unrecliamable
> > (unevictable) pages in the system. While reading through the kernel
> > sources i came across this unevictalbe LRU framework and thought that
> > this should actually work towards providing  total unevictalbe pages in
> > the system irrespective of where they reside.
> 
> The unevictable count tells you how many _userspace_
> pages are not evictable.
> 
> There are countless accounted and unaccounted kernel
> allocations that show up (or not) in other fields in
> /proc/meminfo.
> 

> I can see something reasonable on both sides of this
> particular debate.  However, even with this patch the
> "unevictable" statistic does not reclaim the total
> number of pages that are unevictable pages from a
> zone, so I am not sure how it helps you achieve your
> goal.
> 

Yes but most of the other memory (page table and others) which is
unevictable is actually static in nature.  IOW, the amount of this other
kind of kernel unevictable pages can be actually interpolated from the
amount of physical memory on the system. 

One thing that i forgot to mention earlier is that, I just need a way to
provide a hint about the total locked memory  on the system and it
doesn't need to be the exact number at that point in time.

Lee, due to this reason lazy culling of unevictable pages is fine too. 

Hugepages, similar to mlocked pages, are special because the user could
specify how much memory it wants to reserve for this purpose. So that
needs to be taken into consideration i.e it cannot be calculated in some
way. 

Thanks,
Alok


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
