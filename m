Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 317AD6B0006
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 13:54:28 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id h193so1125396pfe.14
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 10:54:28 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r5si258735pgf.434.2018.02.21.10.54.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Feb 2018 10:54:27 -0800 (PST)
Date: Wed, 21 Feb 2018 19:54:25 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 5/6] mm, hugetlb: further simplify hugetlb allocation API
Message-ID: <20180221185425.GK2231@dhcp22.suse.cz>
References: <20180103093213.26329-1-mhocko@kernel.org>
 <20180103093213.26329-6-mhocko@kernel.org>
 <20180221042457.uolmhlmv5je5dqx7@xps>
 <20180221095526.GB2231@dhcp22.suse.cz>
 <20180221100107.GC2231@dhcp22.suse.cz>
 <840f8c4f-0994-fa7d-0b8d-ad2c8d77c67d@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <840f8c4f-0994-fa7d-0b8d-ad2c8d77c67d@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Dan Rue <dan.rue@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, LKML <linux-kernel@vger.kernel.org>

On Wed 21-02-18 09:59:40, Mike Kravetz wrote:
> On 02/21/2018 02:01 AM, Michal Hocko wrote:
> > On Wed 21-02-18 10:55:26, Michal Hocko wrote:
> > Hmm, I guess I can see it. Does the following help?
> > ---
> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > index 7c204e3d132b..a963f2034dfc 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -1583,7 +1583,7 @@ static struct page *alloc_surplus_huge_page(struct hstate *h, gfp_t gfp_mask,
> >  		page = NULL;
> >  	} else {
> >  		h->surplus_huge_pages++;
> > -		h->nr_huge_pages_node[page_to_nid(page)]++;
> > +		h->surplus_huge_pages_node[page_to_nid(page)]++;
> >  	}
> >  
> >  out_unlock:
> 
> I thought we had this corrected in a previous version of the patch.
> My apologies for not looking more closely at this version.

I must have screwed up when rebasing. I remember I was splitting this
patch...

> FWIW,
> Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
