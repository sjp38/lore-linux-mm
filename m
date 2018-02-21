Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id ED5626B0003
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 13:52:58 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id p13so1090817plr.10
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 10:52:58 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m62si1189544pfm.41.2018.02.21.10.52.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Feb 2018 10:52:57 -0800 (PST)
Date: Wed, 21 Feb 2018 19:52:52 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 5/6] mm, hugetlb: further simplify hugetlb allocation API
Message-ID: <20180221185252.GJ2231@dhcp22.suse.cz>
References: <20180103093213.26329-1-mhocko@kernel.org>
 <20180103093213.26329-6-mhocko@kernel.org>
 <20180221042457.uolmhlmv5je5dqx7@xps>
 <20180221095526.GB2231@dhcp22.suse.cz>
 <20180221100107.GC2231@dhcp22.suse.cz>
 <20180221161914.ltssyoumwpyiwca6@xps>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180221161914.ltssyoumwpyiwca6@xps>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Rue <dan.rue@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, LKML <linux-kernel@vger.kernel.org>

On Wed 21-02-18 10:19:14, Dan Rue wrote:
> On Wed, Feb 21, 2018 at 11:01:07AM +0100, Michal Hocko wrote:
> > On Wed 21-02-18 10:55:26, Michal Hocko wrote:
> > > On Tue 20-02-18 22:24:57, Dan Rue wrote:
> > [...]
> > > > I bisected the failure to this commit. The problem is seen on multiple
> > > > architectures (tested x86-64 and arm64).
> > > 
> > > The patch shouldn't have introduced any functional changes IIRC. But let
> > > me have a look
> > 
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
> That did the trick. Confirmed fixed on v4.15-3389-g0c397daea1d4 and
> v4.16-rc2 with the above patch.

Thanks a lot for re-testing! Can I assume your Tested-by?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
