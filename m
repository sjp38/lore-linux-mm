Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 252196B0038
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 21:57:35 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id q126so113523194pga.0
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 18:57:35 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id v15si9161990plk.133.2017.03.02.18.57.33
        for <linux-mm@kvack.org>;
        Thu, 02 Mar 2017 18:57:34 -0800 (PST)
Date: Fri, 3 Mar 2017 11:57:31 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 03/11] mm: remove SWAP_DIRTY in ttu
Message-ID: <20170303025731.GC3503@bbox>
References: <1488436765-32350-1-git-send-email-minchan@kernel.org>
 <1488436765-32350-4-git-send-email-minchan@kernel.org>
 <079901d29327$77698f60$663cae20$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <079901d29327$77698f60$663cae20$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Michal Hocko' <mhocko@suse.com>, 'Shaohua Li' <shli@kernel.org>

Hi Hillf,

On Thu, Mar 02, 2017 at 03:34:45PM +0800, Hillf Danton wrote:
> 
> On March 02, 2017 2:39 PM Minchan Kim wrote: 
> > @@ -1424,7 +1424,8 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
> >  			} else if (!PageSwapBacked(page)) {
> >  				/* dirty MADV_FREE page */
> 
> Nit: enrich the comment please.

I guess what you wanted is not my patch doing but one merged already
so I just sent a small clean patch against of patch merged onto mmotm
to make thig logic clear. You are already Cced in there so you can
see it. Hope it well. If you want others, please tell me.
I will do something to make it clear.

Thanks for the review.

> >  				set_pte_at(mm, address, pvmw.pte, pteval);
> > -				ret = SWAP_DIRTY;
> > +				SetPageSwapBacked(page);
> > +				ret = SWAP_FAIL;
> >  				page_vma_mapped_walk_done(&pvmw);
> >  				break;
> >  			}
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
