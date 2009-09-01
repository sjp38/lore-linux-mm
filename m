Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D4D3B6B004D
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 20:43:33 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n810haJ7003169
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 1 Sep 2009 09:43:36 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0181145DE51
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 09:43:36 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CA04845DE4F
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 09:43:35 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B3486E38004
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 09:43:35 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 66B82E38001
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 09:43:35 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mm/vsmcan: check shrink_active_list() sc->isolate_pages() return value.
In-Reply-To: <20090901091249.dcd3a8d1.minchan.kim@barrios-desktop>
References: <alpine.DEB.2.00.0908311639220.15607@kernelhack.brc.ubc.ca> <20090901091249.dcd3a8d1.minchan.kim@barrios-desktop>
Message-Id: <20090901094157.1A80.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  1 Sep 2009 09:43:23 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Vincent Li <macli@brc.ubc.ca>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> On Mon, 31 Aug 2009 17:01:03 -0700 (PDT)
> Vincent Li <macli@brc.ubc.ca> wrote:
> 
> > On Tue, 1 Sep 2009, Minchan Kim wrote:
> > 
> > > On Mon, 31 Aug 2009 15:54:01 -0700
> > > Vincent Li <macli@brc.ubc.ca> wrote:
> > > 
> > > > commit 5343daceec (If sc->isolate_pages() return 0...) make shrink_inactive_list handle
> > > > sc->isolate_pages() return value properly. Add similar proper return value check for
> > > > shrink_active_list() sc->isolate_pages().
> > > > 
> > > > Signed-off-by: Vincent Li <macli@brc.ubc.ca>
> > > Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> > > 
> > > You should have write down your patch's effect clearly
> > > in changelog although it's easy. ;-)
> > 
> > Yes, I should have. This patch is inspired by Kosaki's patch, I 
> > thought mentioning that commit would make this patch as follow-up work and 
> > changelog clear enough. Would following changelog ok?
> > 
> > ----
> > Add proper return value check for shrink_active_list() 
> > sc->isolate_pages(). 
> > 
> > When "nr_taken == 0"
> > 	1: nr_scan related statistics should still be caculated.
> > 	2: jump to the end of function and release zone->lru_lock.
> 
> It looks good than old. 
> In fact, What I wanted is your patch impact.
> 
> For example, 
> ----
> If we can't isolate pages from LRU list, 
> we don't have to account page movement, either.
> Already, in commit 5343daceec, KOSAKI did it about shrink_inactive_list.
> 
> This patch removes unnecessary overhead of page accouting 
> and locking in shrink_active_list as follow-up work of commit 5343daceec.
> ---

Vincent, can you please resubmit the patch with new description?
Plus, You can add my reviewed-by sign too.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
