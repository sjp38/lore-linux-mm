Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j4JGe1mD606164
	for <linux-mm@kvack.org>; Thu, 19 May 2005 12:40:02 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4JGe1cs219776
	for <linux-mm@kvack.org>; Thu, 19 May 2005 10:40:01 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j4JGe1ea001337
	for <linux-mm@kvack.org>; Thu, 19 May 2005 10:40:01 -0600
Date: Thu, 19 May 2005 09:33:38 -0700
From: Chandra Seetharaman <sekharan@us.ibm.com>
Subject: Re: [PATCH 0/6] CKRM: Memory controller for CKRM
Message-ID: <20050519163338.GC27270@chandralinux.beaverton.ibm.com>
References: <20050519003008.GC25076@chandralinux.beaverton.ibm.com> <20050519.104325.13596447.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050519.104325.13596447.taka@valinux.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 19, 2005 at 10:43:25AM +0900, Hirokazu Takahashi wrote:
> Hello,
> 
> It just looks like that once kswapd moves pages between the active lists
> and the inactive lists, the pages happen to belong to the class
> to which kswapd belong.

In refill_inactive_zone()(where pages are moved from active to inactive
list), ckrm_zone(where the page came from) is where the inactive pages are 
moved to.

I don't see how you concluded this. Can you point to the code.

> 
> Is this right behavior that you intend?

certainly not :)
> 
> > Hello ckrm-tech members,
> > 
> > Here is the latest CKRM Memory controller patch against the patchset Gerrit
> > released on 05/05/05.
> > 
> > I applied the feedback I got on/off the list. Made few fixes and some
> > cleanups. Details about the changes are in the appripriate patches.
> > 
> > It is tested on i386.
> > 
> > Currently disabled on NUMA.
> > 
> > Hello linux-mm members,
> > 
> > These are set of patches that provides the control of memory under the CKRM
> > framework(Details at http://ckrm.sf.net). I eagerly wait for your
> > feedback/comments/suggestions/concerns etc.,
> > 
> > To All,
> > 
> > I am looking for improvement suggestions
> >         - to not have a field in the page data structure for the mem
> >           controller
> 
> What do you think if you make each class owns inodes instead of pages
> in the page-cache?
> 
> > 	- to make vmscan.c cleaner.
> 
> 
> Thanks,
> Hirokazu Takahashi.
> 
> 
> 

-- 

----------------------------------------------------------------------
    Chandra Seetharaman               | Be careful what you choose....
              - sekharan@us.ibm.com   |      .......you may get it.
----------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
