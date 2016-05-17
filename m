Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 148126B0005
	for <linux-mm@kvack.org>; Mon, 16 May 2016 21:30:38 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b203so3714717pfb.1
        for <linux-mm@kvack.org>; Mon, 16 May 2016 18:30:38 -0700 (PDT)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id g63si564078pfa.6.2016.05.16.18.30.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 May 2016 18:30:37 -0700 (PDT)
Received: by mail-pa0-x243.google.com with SMTP id gh9so207849pac.0
        for <linux-mm@kvack.org>; Mon, 16 May 2016 18:30:37 -0700 (PDT)
Date: Tue, 17 May 2016 10:30:09 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v5 02/12] mm: migrate: support non-lru movable page
 migration
Message-ID: <20160517013009.GB497@swordfish>
References: <1462760433-32357-1-git-send-email-minchan@kernel.org>
 <1462760433-32357-3-git-send-email-minchan@kernel.org>
 <20160516071751.GA32079@swordfish>
 <20160517011850.GD31335@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160517011850.GD31335@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rafael Aquini <aquini@redhat.com>, virtualization@lists.linux-foundation.org, Jonathan Corbet <corbet@lwn.net>, John Einar Reitan <john.reitan@foss.arm.com>, dri-devel@lists.freedesktop.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Gioh Kim <gi-oh.kim@profitbricks.com>

On (05/17/16 10:18), Minchan Kim wrote:
[..]
> > >  #ifdef CONFIG_MIGRATION
> > >  
> > > +extern int PageMovable(struct page *page);
> > > +extern void __SetPageMovable(struct page *page, struct address_space *mapping);
> > > +extern void __ClearPageMovable(struct page *page);
> > >  extern void putback_movable_pages(struct list_head *l);
> > >  extern int migrate_page(struct address_space *,
> > >  			struct page *, struct page *, enum migrate_mode);
> > >  extern int migrate_pages(struct list_head *l, new_page_t new, free_page_t free,
> > >  		unsigned long private, enum migrate_mode mode, int reason);
> > > +extern bool isolate_movable_page(struct page *page, isolate_mode_t mode);
> > > +extern void putback_movable_page(struct page *page);
> > >  
> > >  extern int migrate_prep(void);
> > >  extern int migrate_prep_local(void);
> > 
> > given that some of Movable users can be built as modules, shouldn't
> > at least some of those symbols be exported via EXPORT_SYMBOL?
> 
> Those functions aim for VM compaction so driver shouldn't use it.
> Only driver should be aware of are __SetPageMovable and __CleraPageMovable.
> I will export them.
> 

and PageMovable(), probably?

zsmalloc():

	VM_BUG_ON_PAGE(!PageMovable(page), page);


> Thanks for the review, Sergey!

no prob! sorry, I'm a bit slow and late here.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
