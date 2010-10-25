Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 85D5D6B0087
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 03:49:39 -0400 (EDT)
Date: Mon, 25 Oct 2010 15:49:33 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [BUGFIX][PATCH] fix is_mem_section_removable() page_order
 BUG_ON check.
Message-ID: <20101025074933.GB5452@localhost>
References: <20101025153726.2ae9baec.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101025153726.2ae9baec.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 25, 2010 at 02:37:26PM +0800, KAMEZAWA Hiroyuki wrote:
> I wonder this should be for stable tree...but want to hear opinions before.
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> page_order() is called by memory hotplug's user interface to check 
> the section is removable or not. (is_mem_section_removable())
> 
> It calls page_order() withoug holding zone->lock.
> So, even if the caller does
> 
> 	if (PageBuddy(page))
> 		ret = page_order(page) ...
> The caller may hit BUG_ON().
> 
> For fixing this, there are 2 choices.
>   1. add zone->lock.
>   2. remove BUG_ON().

One more alternative might be to introduce a private
maybe_page_order() for is_mem_section_removable(). Not a big deal. 
 
> is_mem_section_removable() is used for some "advice" and doesn't need
> to be 100% accurate. This is_removable() can be called via user program..
> We don't want to take this important lock for long by user's request.
> So, this patch removes BUG_ON().

Acked-by: Wu Fengguang <fengguang.wu@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
