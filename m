Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 377E26B0047
	for <linux-mm@kvack.org>; Wed,  8 Sep 2010 07:23:17 -0400 (EDT)
Date: Wed, 8 Sep 2010 12:23:01 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/3] [BUGFIX] memory hotplug: fix next block
	calculation in is_removable
Message-ID: <20100908112301.GD29263@csn.ul.ie>
References: <20100906144019.946d3c49.kamezawa.hiroyu@jp.fujitsu.com> <20100907102813.d633b8ef.kamezawa.hiroyu@jp.fujitsu.com> <20100907103244.35eb6b71.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100907103244.35eb6b71.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, fengguang.wu@intel.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, andi.kleen@intel.com, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, Sep 07, 2010 at 10:32:44AM +0900, KAMEZAWA Hiroyuki wrote:
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> next_active_pageblock() is for finding next _used_ freeblock. It skips
> several blocks when it finds there are a chunk of free pages lager than
> pageblock. But it has 2 bugs.
> 
>   1. We have no lock. page_order(page) - pageblock_order can be minus.
>   2. pageblocks_stride += is wrong. it should skip page_order(p) of pages.
> 
> Changelog: 2010/09/07
>  - fix range check of order returned by page_order().
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
