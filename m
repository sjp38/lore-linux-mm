Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j4L0Deua024624
	for <linux-mm@kvack.org>; Fri, 20 May 2005 20:13:40 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4L0Dewj260132
	for <linux-mm@kvack.org>; Fri, 20 May 2005 18:13:40 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j4L0DdMj022215
	for <linux-mm@kvack.org>; Fri, 20 May 2005 18:13:39 -0600
Date: Fri, 20 May 2005 17:07:00 -0700
From: Chandra Seetharaman <sekharan@us.ibm.com>
Subject: Re: [PATCH 0/6] CKRM: Memory controller for CKRM
Message-ID: <20050521000700.GA30327@chandralinux.beaverton.ibm.com>
References: <20050519003008.GC25076@chandralinux.beaverton.ibm.com> <20050519.104325.13596447.taka@valinux.co.jp> <20050519163338.GC27270@chandralinux.beaverton.ibm.com> <20050520.142927.108372625.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050520.142927.108372625.taka@valinux.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 20, 2005 at 02:29:27PM +0900, Hirokazu Takahashi wrote:
> Hi Chandra,
> 
> > On Thu, May 19, 2005 at 10:43:25AM +0900, Hirokazu Takahashi wrote:
> > > Hello,
> > > 
> > > It just looks like that once kswapd moves pages between the active lists
> > > and the inactive lists, the pages happen to belong to the class
> > > to which kswapd belong.
> > 
> > In refill_inactive_zone()(where pages are moved from active to inactive
> > list), ckrm_zone(where the page came from) is where the inactive pages are 
> > moved to.
> 
> Ah, I understood.
> You have changed these functions not to call add_page_to_active_list() or
> add_page_to_inactive_list() anymore.
> 
> Still, there may remain problems that mark_page_accessed() calls
> add_page_to_active_list() to move pages between classes.
> I guess this isn't good manner since some functions which call
> mark_page_accessed(), like unmap_mapping_range_vma() or get_user_pages(),
> may refer pages of the other classes.

You mean these functions are not called in the context of the task that
is in the stack ?

> 
<snip>
> > > > 
> > > > I am looking for improvement suggestions
> > > >         - to not have a field in the page data structure for the mem
> > > >           controller
> > > 
> > > What do you think if you make each class owns inodes instead of pages
> > > in the page-cache?

I think i missed to answer this question in the earlier reply.

do you mean a controller for managing inodes ?
> > > 
> > > > 	- to make vmscan.c cleaner.
> 
> 
> Thanks,
> Hirokazu Takahashi.

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
