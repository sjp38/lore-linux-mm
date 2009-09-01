Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B64A56B004D
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 20:13:33 -0400 (EDT)
Received: by ewy12 with SMTP id 12so4892341ewy.24
        for <linux-mm@kvack.org>; Mon, 31 Aug 2009 17:13:35 -0700 (PDT)
Date: Tue, 1 Sep 2009 09:12:49 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] mm/vsmcan: check shrink_active_list()
 sc->isolate_pages() return value.
Message-Id: <20090901091249.dcd3a8d1.minchan.kim@barrios-desktop>
In-Reply-To: <alpine.DEB.2.00.0908311639220.15607@kernelhack.brc.ubc.ca>
References: <1251759241-15167-1-git-send-email-macli@brc.ubc.ca>
	<20090901082926.61872690.minchan.kim@barrios-desktop>
	<alpine.DEB.2.00.0908311639220.15607@kernelhack.brc.ubc.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Vincent Li <macli@brc.ubc.ca>
Cc: Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 31 Aug 2009 17:01:03 -0700 (PDT)
Vincent Li <macli@brc.ubc.ca> wrote:

> On Tue, 1 Sep 2009, Minchan Kim wrote:
> 
> > On Mon, 31 Aug 2009 15:54:01 -0700
> > Vincent Li <macli@brc.ubc.ca> wrote:
> > 
> > > commit 5343daceec (If sc->isolate_pages() return 0...) make shrink_inactive_list handle
> > > sc->isolate_pages() return value properly. Add similar proper return value check for
> > > shrink_active_list() sc->isolate_pages().
> > > 
> > > Signed-off-by: Vincent Li <macli@brc.ubc.ca>
> > Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> > 
> > You should have write down your patch's effect clearly
> > in changelog although it's easy. ;-)
> 
> Yes, I should have. This patch is inspired by Kosaki's patch, I 
> thought mentioning that commit would make this patch as follow-up work and 
> changelog clear enough. Would following changelog ok?
> 
> ----
> Add proper return value check for shrink_active_list() 
> sc->isolate_pages(). 
> 
> When "nr_taken == 0"
> 	1: nr_scan related statistics should still be caculated.
> 	2: jump to the end of function and release zone->lru_lock.

It looks good than old. 
In fact, What I wanted is your patch impact.

For example, 
----
If we can't isolate pages from LRU list, 
we don't have to account page movement, either.
Already, in commit 5343daceec, KOSAKI did it about shrink_inactive_list.

This patch removes unnecessary overhead of page accouting 
and locking in shrink_active_list as follow-up work of commit 5343daceec.
---



> ----
> Regards,
> 
> Vincent Li
> Biomedical Research Center
> University of British Columbia


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
