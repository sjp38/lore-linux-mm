Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m8OIxG1k004445
	for <linux-mm@kvack.org>; Wed, 24 Sep 2008 14:59:16 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8OIxESQ193754
	for <linux-mm@kvack.org>; Wed, 24 Sep 2008 12:59:15 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8OIxDMi032212
	for <linux-mm@kvack.org>; Wed, 24 Sep 2008 12:59:14 -0600
Subject: Re: [PATCH 1/2] Report the pagesize backing a VMA in
	/proc/pid/smaps
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20080924171003.GD10837@csn.ul.ie>
References: <20080923211140.DC16.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080923194655.GA25542@csn.ul.ie>
	 <20080924210309.8C3B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080924154120.GA10837@csn.ul.ie> <1222272395.15523.3.camel@nimitz>
	 <20080924171003.GD10837@csn.ul.ie>
Content-Type: text/plain
Date: Wed, 24 Sep 2008 11:59:09 -0700
Message-Id: <1222282749.15523.59.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, agl@us.ibm.com, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-09-24 at 18:10 +0100, Mel Gorman wrote:
> On (24/09/08 09:06), Dave Hansen didst pronounce:
> > On Wed, 2008-09-24 at 16:41 +0100, Mel Gorman wrote:
> > > I admit it's ppc64-specific. In the latest patch series, I made this a
> > > separate patch so that it could be readily dropped again for this reason.
> > > Maybe an alternative would be to display MMUPageSize *only* where it differs
> > > from KernelPageSize. Would that be better or similarly confusing?
> > 
> > I would also think that any arch implementing fallback from large to
> > small pages in a hugetlbfs area (Adam needs to post his patches :) would
> > also use this.
> > 
> 
> Fair point. Maybe the thing to do is backburner this patch for the moment and
> reintroduce it when/if an architecture supports demotion? The KernelPageSize
> reporting in smaps and what the hpagesize in maps is still useful though
> I believe. Any comment?

I'd kinda prefer to see it normalized into a single place rather than
sprinkle it in each smaps file.  We should be able to figure out which
mount the file is from and, from there, maybe we need some per-mount
information exported.  

> (future stuff from here on)
> 
> In the future if demotion does happen then the MMUPageSize information may
> be genuinely useful instead of just a curious oddity on ppc64. As you point
> out, Adam (added to cc) has worked on this area (starting with x86 demotion)
> in the past but it's a while before it'll be considered for merging I believe.
> 
> That aside, more would need to be done with the page size reporting then
> anyway. For example, it maybe indicate how much of each pagesize is in a VMA
> or indicate that KernelPageSize is what is being requested but in reality
> it is mixed like;
> 
> KernelPageSize:		2048 kB (mixed)
> 
> or
> 
> KernelPageSize:		2048 kB * 5, 4096 kB * 20

Looks a bit verbose, but I agree with the sentiment.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
