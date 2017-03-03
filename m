Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2501A6B0389
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 22:03:03 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id j5so103540521pfb.3
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 19:03:03 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id 33si9157453plb.317.2017.03.02.19.03.01
        for <linux-mm@kvack.org>;
        Thu, 02 Mar 2017 19:03:02 -0800 (PST)
Date: Fri, 3 Mar 2017 12:03:00 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 02/11] mm: remove unncessary ret in page_referenced
Message-ID: <20170303030300.GE3503@bbox>
References: <1488436765-32350-1-git-send-email-minchan@kernel.org>
 <1488436765-32350-3-git-send-email-minchan@kernel.org>
 <2baf1168-0f84-b80d-5fb9-9d13c618c9f1@linux.vnet.ibm.com>
MIME-Version: 1.0
In-Reply-To: <2baf1168-0f84-b80d-5fb9-9d13c618c9f1@linux.vnet.ibm.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>

On Thu, Mar 02, 2017 at 08:03:16PM +0530, Anshuman Khandual wrote:
> On 03/02/2017 12:09 PM, Minchan Kim wrote:
> > Anyone doesn't use ret variable. Remove it.
> > 
> 
> This change is correct. But not sure how this is related to
> try_to_unmap() clean up though.

In this patchset, I made rmap_walk void function with upcoming
patch so it's a preparation step for it.

> 
> 
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  mm/rmap.c | 3 +--
> >  1 file changed, 1 insertion(+), 2 deletions(-)
> > 
> > diff --git a/mm/rmap.c b/mm/rmap.c
> > index bb45712..8076347 100644
> > --- a/mm/rmap.c
> > +++ b/mm/rmap.c
> > @@ -805,7 +805,6 @@ int page_referenced(struct page *page,
> >  		    struct mem_cgroup *memcg,
> >  		    unsigned long *vm_flags)
> >  {
> > -	int ret;
> >  	int we_locked = 0;
> >  	struct page_referenced_arg pra = {
> >  		.mapcount = total_mapcount(page),
> > @@ -839,7 +838,7 @@ int page_referenced(struct page *page,
> >  		rwc.invalid_vma = invalid_page_referenced_vma;
> >  	}
> >  
> > -	ret = rmap_walk(page, &rwc);
> > +	rmap_walk(page, &rwc);
> >  	*vm_flags = pra.vm_flags;
> >  
> >  	if (we_locked)
> > 
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
