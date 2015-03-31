Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 4C35A6B0032
	for <linux-mm@kvack.org>; Tue, 31 Mar 2015 00:45:34 -0400 (EDT)
Received: by pactp5 with SMTP id tp5so7733803pac.1
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 21:45:34 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id nx13si15668461pdb.150.2015.03.30.21.45.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Mar 2015 21:45:33 -0700 (PDT)
Received: by padcy3 with SMTP id cy3so7656735pad.3
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 21:45:32 -0700 (PDT)
Date: Tue, 31 Mar 2015 13:45:25 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 3/4] mm: move lazy free pages to inactive list
Message-ID: <20150331044525.GB16825@blaptop>
References: <1426036838-18154-1-git-send-email-minchan@kernel.org>
 <1426036838-18154-3-git-send-email-minchan@kernel.org>
 <20150320154358.51bcf3cbceeb8fbbdb2b58e5@linux-foundation.org>
 <20150330053502.GB3008@blaptop>
 <20150330142010.5d14fbc07e05180cc3ecce5c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150330142010.5d14fbc07e05180cc3ecce5c@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Yalin.Wang@sonymobile.com

Hello Andrew,

On Mon, Mar 30, 2015 at 02:20:10PM -0700, Andrew Morton wrote:
> On Mon, 30 Mar 2015 14:35:02 +0900 Minchan Kim <minchan@kernel.org> wrote:
> 
> > --- a/mm/swap.c
> > +++ b/mm/swap.c
> > @@ -866,6 +866,13 @@ void deactivate_file_page(struct page *page)
> >  	}
> >  }
> >  
> > +/**
> > + * deactivate_page - deactivate a page
> > + * @page: page to deactivate
> > + *
> > + * This function moves @page to inactive list if @page was on active list and
> > + * was not unevictable page to accelerate to reclaim @page.
> > + */
> >  void deactivate_page(struct page *page)
> >  {
> >  	if (PageLRU(page) && PageActive(page) && !PageUnevictable(page)) {
> 
> Thanks.
> 
> deactivate_page() doesn't look at or alter PageReferenced().  Should it?

Absolutely true. Thanks.
Here it goes.
