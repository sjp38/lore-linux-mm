Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D50D16B004D
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 00:40:03 -0400 (EDT)
Date: Mon, 31 Aug 2009 21:56:39 -0700 (PDT)
From: Vincent Li <macli@brc.ubc.ca>
Subject: Re: [PATCH] mm/vsmcan: check shrink_active_list() sc->isolate_pages()
 return value.
In-Reply-To: <20090901094157.1A80.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.00.0908312154130.27447@mail.selltech.ca>
References: <alpine.DEB.2.00.0908311639220.15607@kernelhack.brc.ubc.ca> <20090901091249.dcd3a8d1.minchan.kim@barrios-desktop> <20090901094157.1A80.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Vincent Li <macli@brc.ubc.ca>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 1 Sep 2009, KOSAKI Motohiro wrote:

> > On Mon, 31 Aug 2009 17:01:03 -0700 (PDT)
> > Vincent Li <macli@brc.ubc.ca> wrote:
> > 
> > > On Tue, 1 Sep 2009, Minchan Kim wrote:
> > > 
> > > > On Mon, 31 Aug 2009 15:54:01 -0700
> > > > Vincent Li <macli@brc.ubc.ca> wrote:
> > > > 
> > > > > commit 5343daceec (If sc->isolate_pages() return 0...) make shrink_inactive_list handle
> > > > > sc->isolate_pages() return value properly. Add similar proper return value check for
> > > > > shrink_active_list() sc->isolate_pages().
> > > > > 
> > > > > Signed-off-by: Vincent Li <macli@brc.ubc.ca>
> > > > Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> > > > 
> > > > You should have write down your patch's effect clearly
> > > > in changelog although it's easy. ;-)
> > > 
> > > Yes, I should have. This patch is inspired by Kosaki's patch, I 
> > > thought mentioning that commit would make this patch as follow-up work and 
> > > changelog clear enough. Would following changelog ok?
> > > 
> > > ----
> > > Add proper return value check for shrink_active_list() 
> > > sc->isolate_pages(). 
> > > 
> > > When "nr_taken == 0"
> > > 	1: nr_scan related statistics should still be caculated.
> > > 	2: jump to the end of function and release zone->lru_lock.
> > 
> > It looks good than old. 
> > In fact, What I wanted is your patch impact.
> > 
> > For example, 
> > ----
> > If we can't isolate pages from LRU list, 
> > we don't have to account page movement, either.
> > Already, in commit 5343daceec, KOSAKI did it about shrink_inactive_list.
> > 
> > This patch removes unnecessary overhead of page accouting 
> > and locking in shrink_active_list as follow-up work of commit 5343daceec.
> > ---
> 
> Vincent, can you please resubmit the patch with new description?
> Plus, You can add my reviewed-by sign too.

Ok, I will resubmit the patch with Kim's description and add reviewed-by 
sign. Thanks everyone for reviewing!

Vincent Li
Biomedical Research Center
University of British Columbia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
