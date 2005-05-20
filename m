Date: Fri, 20 May 2005 14:29:27 +0900 (JST)
Message-Id: <20050520.142927.108372625.taka@valinux.co.jp>
Subject: Re: [PATCH 0/6] CKRM: Memory controller for CKRM
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20050519163338.GC27270@chandralinux.beaverton.ibm.com>
References: <20050519003008.GC25076@chandralinux.beaverton.ibm.com>
	<20050519.104325.13596447.taka@valinux.co.jp>
	<20050519163338.GC27270@chandralinux.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: sekharan@us.ibm.com
Cc: ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Chandra,

> On Thu, May 19, 2005 at 10:43:25AM +0900, Hirokazu Takahashi wrote:
> > Hello,
> > 
> > It just looks like that once kswapd moves pages between the active lists
> > and the inactive lists, the pages happen to belong to the class
> > to which kswapd belong.
> 
> In refill_inactive_zone()(where pages are moved from active to inactive
> list), ckrm_zone(where the page came from) is where the inactive pages are 
> moved to.

Ah, I understood.
You have changed these functions not to call add_page_to_active_list() or
add_page_to_inactive_list() anymore.

Still, there may remain problems that mark_page_accessed() calls
add_page_to_active_list() to move pages between classes.
I guess this isn't good manner since some functions which call
mark_page_accessed(), like unmap_mapping_range_vma() or get_user_pages(),
may refer pages of the other classes.

> I don't see how you concluded this. Can you point to the code.
> 
> > 
> > Is this right behavior that you intend?
> 
> certainly not :)
> > 
> > > Hello ckrm-tech members,
> > > 
> > > Here is the latest CKRM Memory controller patch against the patchset Gerrit
> > > released on 05/05/05.
> > > 
> > > I applied the feedback I got on/off the list. Made few fixes and some
> > > cleanups. Details about the changes are in the appripriate patches.
> > > 
> > > It is tested on i386.
> > > 
> > > Currently disabled on NUMA.
> > > 
> > > Hello linux-mm members,
> > > 
> > > These are set of patches that provides the control of memory under the CKRM
> > > framework(Details at http://ckrm.sf.net). I eagerly wait for your
> > > feedback/comments/suggestions/concerns etc.,
> > > 
> > > To All,
> > > 
> > > I am looking for improvement suggestions
> > >         - to not have a field in the page data structure for the mem
> > >           controller
> > 
> > What do you think if you make each class owns inodes instead of pages
> > in the page-cache?
> > 
> > > 	- to make vmscan.c cleaner.


Thanks,
Hirokazu Takahashi.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
