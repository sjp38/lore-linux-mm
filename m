Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 2743B6B0096
	for <linux-mm@kvack.org>; Thu, 11 Nov 2010 03:40:15 -0500 (EST)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id oAB8eAh9009678
	for <linux-mm@kvack.org>; Thu, 11 Nov 2010 00:40:11 -0800
Received: from pvg6 (pvg6.prod.google.com [10.241.210.134])
	by wpaz9.hot.corp.google.com with ESMTP id oAB8e8mP028467
	for <linux-mm@kvack.org>; Thu, 11 Nov 2010 00:40:08 -0800
Received: by pvg6 with SMTP id 6so396783pvg.23
        for <linux-mm@kvack.org>; Thu, 11 Nov 2010 00:40:08 -0800 (PST)
Date: Thu, 11 Nov 2010 00:40:04 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v3] fix __set_page_dirty_no_writeback() return value
In-Reply-To: <alpine.DEB.2.00.1011102340450.7571@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1011110039210.16401@chino.kir.corp.google.com>
References: <1289445963-29664-1-git-send-email-lliubbo@gmail.com> <alpine.DEB.2.00.1011102340450.7571@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, Ken Chen <kenchen@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 10 Nov 2010, David Rientjes wrote:

> > diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> > index bf85062..1ebfb86 100644
> > --- a/mm/page-writeback.c
> > +++ b/mm/page-writeback.c
> > @@ -1158,7 +1158,7 @@ EXPORT_SYMBOL(write_one_page);
> >  int __set_page_dirty_no_writeback(struct page *page)
> >  {
> >  	if (!PageDirty(page))
> > -		SetPageDirty(page);
> > +		return !TestSetPageDirty(page);
> >  	return 0;
> >  }
> 
> No need for a conditional, just return !TestSetPageDirty(page).
> 

Oops, just read Andrew's reply to v1 of the patch about the cacheline 
invalidation of bts, sorry for the noise.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
