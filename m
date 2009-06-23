Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 3CBC26B004F
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 18:06:41 -0400 (EDT)
Subject: Re: [PATCH] Hugepages should be accounted as unevictable pages.
From: Alok Kataria <akataria@vmware.com>
Reply-To: akataria@vmware.com
In-Reply-To: <4A414F55.2040808@redhat.com>
References: <20090623093459.2204.A69D9226@jp.fujitsu.com>
	 <1245732411.18339.6.camel@alok-dev1>
	 <20090623135017.220D.A69D9226@jp.fujitsu.com>
	 <20090623141147.8f2cef18.kamezawa.hiroyu@jp.fujitsu.com>
	 <1245736441.18339.21.camel@alok-dev1>  <4A41481D.1060607@redhat.com>
	 <1245793331.24110.33.camel@alok-dev1>  <4A414F55.2040808@redhat.com>
Content-Type: text/plain
Date: Tue, 23 Jun 2009 15:06:51 -0700
Message-Id: <1245794811.24110.41.camel@alok-dev1>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Tue, 2009-06-23 at 14:55 -0700, Rik van Riel wrote:
> Alok Kataria wrote:
> > On Tue, 2009-06-23 at 14:24 -0700, Rik van Riel wrote:
> 
> >> I can see something reasonable on both sides of this
> >> particular debate.  However, even with this patch the
> >> "unevictable" statistic does not reclaim the total
> >> number of pages that are unevictable pages from a
> >> zone, so I am not sure how it helps you achieve your
> >> goal.
> > 
> > Yes but most of the other memory (page table and others) which is
> > unevictable is actually static in nature.  IOW, the amount of this other
> > kind of kernel unevictable pages can be actually interpolated from the
> > amount of physical memory on the system. 
> 
> That would be a fair argument, if it were true.
> 
> Things like page tables and dentry/inode caches vary
> according to the use case and are allocated as needed.
> They are in no way "static in nature".
> 

Maybe static was the wrong word to use here. 
What i meant was that you could always calculate the *maximum* amount of
memory that is going to be used by page table and can also determine the
% of memory that will be used by slab caches. 
So that ways you should be statically able to tell that no more than 'X'
amount of memory is going to be locked here.
Will again like to stress that "X" is not the exact amount that is
locked here but the one which can be. 

OTOH, for hugepages and mlocked pages you need to read the exact counts
as this can change according to user selection. 

Thanks,
Alok


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
