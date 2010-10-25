Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5ED866B004A
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 13:03:37 -0400 (EDT)
Date: Mon, 25 Oct 2010 18:03:21 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [BUGFIX][PATCH] fix is_mem_section_removable() page_order
	BUG_ON check.
Message-ID: <20101025170321.GA5383@csn.ul.ie>
References: <20101025153726.2ae9baec.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101025153726.2ae9baec.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

On Mon, Oct 25, 2010 at 03:37:26PM +0900, KAMEZAWA Hiroyuki wrote:
> I wonder this should be for stable tree...but want to hear opinions before.

Because it's VM_BUG_ON instead of BUG_ON, I don't think it's something
we are likely to see triggered on stable kernels. It is worth
introducing a VM_WARN_ON do you think to catch really bad callers, ones
where it is not advisory?

Whether such a helper was introduced or not though, this does fix a real
problem so;

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
