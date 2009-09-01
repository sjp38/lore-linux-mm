Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 8297B6B004D
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 20:02:18 -0400 (EDT)
Date: Mon, 31 Aug 2009 17:01:03 -0700 (PDT)
From: Vincent Li <macli@brc.ubc.ca>
Subject: Re: [PATCH] mm/vsmcan: check shrink_active_list() sc->isolate_pages()
 return value.
In-Reply-To: <20090901082926.61872690.minchan.kim@barrios-desktop>
Message-ID: <alpine.DEB.2.00.0908311639220.15607@kernelhack.brc.ubc.ca>
References: <1251759241-15167-1-git-send-email-macli@brc.ubc.ca> <20090901082926.61872690.minchan.kim@barrios-desktop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Vincent Li <macli@brc.ubc.ca>, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 1 Sep 2009, Minchan Kim wrote:

> On Mon, 31 Aug 2009 15:54:01 -0700
> Vincent Li <macli@brc.ubc.ca> wrote:
> 
> > commit 5343daceec (If sc->isolate_pages() return 0...) make shrink_inactive_list handle
> > sc->isolate_pages() return value properly. Add similar proper return value check for
> > shrink_active_list() sc->isolate_pages().
> > 
> > Signed-off-by: Vincent Li <macli@brc.ubc.ca>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> 
> You should have write down your patch's effect clearly
> in changelog although it's easy. ;-)

Yes, I should have. This patch is inspired by Kosaki's patch, I 
thought mentioning that commit would make this patch as follow-up work and 
changelog clear enough. Would following changelog ok?

----
Add proper return value check for shrink_active_list() 
sc->isolate_pages(). 

When "nr_taken == 0"
	1: nr_scan related statistics should still be caculated.
	2: jump to the end of function and release zone->lru_lock.
----
Regards,

Vincent Li
Biomedical Research Center
University of British Columbia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
