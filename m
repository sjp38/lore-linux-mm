Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m8OJNQZ4008082
	for <linux-mm@kvack.org>; Wed, 24 Sep 2008 15:23:26 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8OJNE5s018898
	for <linux-mm@kvack.org>; Wed, 24 Sep 2008 13:23:14 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8OJNDDp008048
	for <linux-mm@kvack.org>; Wed, 24 Sep 2008 13:23:13 -0600
Subject: Re: [PATCH 1/2] Report the pagesize backing a VMA in
	/proc/pid/smaps
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20080924191107.GA31324@csn.ul.ie>
References: <20080923211140.DC16.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080923194655.GA25542@csn.ul.ie>
	 <20080924210309.8C3B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080924154120.GA10837@csn.ul.ie> <1222272395.15523.3.camel@nimitz>
	 <20080924171003.GD10837@csn.ul.ie> <1222282749.15523.59.camel@nimitz>
	 <20080924191107.GA31324@csn.ul.ie>
Content-Type: text/plain
Date: Wed, 24 Sep 2008 12:23:10 -0700
Message-Id: <1222284190.15523.64.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, agl@us.ibm.com, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-09-24 at 20:11 +0100, Mel Gorman wrote:
> I don't get what you mean by it being sprinkled in each smaps file. How
> would you present the data?

1. figure out what the file path is from smaps
2. look up the mount
3. look up the page sizes from the mount's information

> > We should be able to figure out which
> > mount the file is from and, from there, maybe we need some per-mount
> > information exported.  
> 
> Per-mount information is already exported and you can infer the data about
> huge pagesizes. For example, if you know the default huge pagesize (from
> /proc/meminfo), and the file is on hugetlbfs (read maps, then /proc/mounts)
> and there is no pagesize= mount option (mounts again), you could guess what the
> hugepage that is backing a VMA is. Shared memory segments are a little harder
> but again, you can infer the information if you look around for long enough.
> 
> However, this is awkward and not very user-friendly. With the patches (minus
> MMUPageSize as I think we've agreed to postpone that), it's easy to see what
> pagesize is being used at a glance. Without it, you need to know a fair bit
> about hugepages are implemented in Linux to infer the information correctly.

I agree completely.  But, if we consider this a user ABI thing, then
we're stuck with it for a long time, and we better make it flexible
enough to at least contain the gunk we're planning on adding in a small
number of years, like the fallback.  We don't want to be adding this
stuff if it isn't going to be stable.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
