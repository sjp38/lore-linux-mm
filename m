Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 6429C6B0070
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 20:11:43 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so22780032pac.2
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 17:11:43 -0700 (PDT)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com. [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id ka13si10951367pbb.16.2015.06.09.17.11.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 17:11:42 -0700 (PDT)
Received: by pdjn11 with SMTP id n11so24842088pdj.0
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 17:11:42 -0700 (PDT)
Date: Wed, 10 Jun 2015 09:11:51 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: show proportional swap share of the mapping
Message-ID: <20150610001151.GD13376@bgram>
References: <1433861031-13233-1-git-send-email-minchan@kernel.org>
 <20150610000609.GA596@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150610000609.GA596@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Bongkyu Kim <bongkyu.kim@lge.com>

On Wed, Jun 10, 2015 at 09:06:09AM +0900, Sergey Senozhatsky wrote:
> Hello,
> 
> On (06/09/15 23:43), Minchan Kim wrote:
> [..]
> > @@ -446,6 +446,7 @@ struct mem_size_stats {
> >  	unsigned long anonymous_thp;
> >  	unsigned long swap;
> >  	u64 pss;
> > +	u64 swap_pss;
> >  };
> >  
> >  static void smaps_account(struct mem_size_stats *mss, struct page *page,
> > @@ -492,9 +493,20 @@ static void smaps_pte_entry(pte_t *pte, unsigned long addr,
> >  	} else if (is_swap_pte(*pte)) {
> >  		swp_entry_t swpent = pte_to_swp_entry(*pte);
> >  
> > -		if (!non_swap_entry(swpent))
> > +		if (!non_swap_entry(swpent)) {
> > +			int mapcount;
> > +
> >  			mss->swap += PAGE_SIZE;
> > -		else if (is_migration_entry(swpent))
> > +			mapcount = swp_swapcount(swpent);
> 
> I think this will break swapless builds (CONFIG_SWAP=n builds).

Thanks for the catching.
Will fix!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
