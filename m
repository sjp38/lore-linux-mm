Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6E5626B0031
	for <linux-mm@kvack.org>; Mon, 30 Sep 2013 21:15:38 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id jt11so6365006pbb.10
        for <linux-mm@kvack.org>; Mon, 30 Sep 2013 18:15:38 -0700 (PDT)
Date: Tue, 1 Oct 2013 10:16:30 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] mm, hugetlb: correct missing private flag clearing
Message-ID: <20131001011630.GA21009@lge.com>
References: <1380527985-18499-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20130930143514.63fc5b2b4316caed33e1c1b1@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130930143514.63fc5b2b4316caed33e1c1b1@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>

On Mon, Sep 30, 2013 at 02:35:14PM -0700, Andrew Morton wrote:
> On Mon, 30 Sep 2013 16:59:44 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> 
> > We should clear the page's private flag when returing the page to
> > the page allocator or the hugepage pool. This patch fixes it.
> > 
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > ---
> > Hello, Andrew.
> > 
> > I sent the new version of commit ('07443a8') before you did pull request,
> > but it isn't included. It may be losted :)
> > So I send this fix. IMO, this is good for v3.12.
> > 
> > Thanks.
> > 
> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > index b49579c..691f226 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -653,6 +653,7 @@ static void free_huge_page(struct page *page)
> >  	BUG_ON(page_count(page));
> >  	BUG_ON(page_mapcount(page));
> >  	restore_reserve = PagePrivate(page);
> > +	ClearPagePrivate(page);
> >  
> 
> You describe it as a fix, but what does it fix?  IOW, what are the
> user-visible effects of the change?
> 
> update_and_free_page() already clears PG_private, but afaict the bit
> remains unaltered if free_huge_page() takes the enqueue_huge_page()
> route.

Yes, you are right.
I attach another version having more explanation.
Please refer this and merge it.

Thanks.
------------------------->8---------------------------------
