Date: Mon, 23 May 2005 20:31:59 +0900 (JST)
Message-Id: <20050523.203159.01016468.taka@valinux.co.jp>
Subject: Re: [PATCH 0/6] CKRM: Memory controller for CKRM
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20050521000700.GA30327@chandralinux.beaverton.ibm.com>
References: <20050519163338.GC27270@chandralinux.beaverton.ibm.com>
	<20050520.142927.108372625.taka@valinux.co.jp>
	<20050521000700.GA30327@chandralinux.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: sekharan@us.ibm.com
Cc: ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Chandra,

> > > On Thu, May 19, 2005 at 10:43:25AM +0900, Hirokazu Takahashi wrote:
> > > > Hello,
> > > > 
> > > > It just looks like that once kswapd moves pages between the active lists
> > > > and the inactive lists, the pages happen to belong to the class
> > > > to which kswapd belong.
> > > 
> > > In refill_inactive_zone()(where pages are moved from active to inactive
> > > list), ckrm_zone(where the page came from) is where the inactive pages are 
> > > moved to.
> > 
> > Ah, I understood.
> > You have changed these functions not to call add_page_to_active_list() or
> > add_page_to_inactive_list() anymore.
> > 
> > Still, there may remain problems that mark_page_accessed() calls
> > add_page_to_active_list() to move pages between classes.
> > I guess this isn't good manner since some functions which call
> > mark_page_accessed(), like unmap_mapping_range_vma() or get_user_pages(),
> > may refer pages of the other classes.
> 
> You mean these functions are not called in the context of the task that
> is in the stack ?

No, in some cases though it doesn't seem to be serious.

You may take a look at unmap_mapping_range_tree() as an example.
It traverses mapping->i_mmap to find all related vma's to be
unmapped. And get_user_pages() has the parameter that indicates
which process space should be accessed.

Thanks,
Hirokazu Takahashi.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
