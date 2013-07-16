Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id F41A26B0033
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 21:42:12 -0400 (EDT)
Date: Tue, 16 Jul 2013 10:42:14 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 5/9] mm, hugetlb: remove redundant list_empty check in
 gather_surplus_pages()
Message-ID: <20130716014214.GF2430@lge.com>
References: <1373881967-16153-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1373881967-16153-6-git-send-email-iamjoonsoo.kim@lge.com>
 <87vc4bj3nn.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87vc4bj3nn.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 15, 2013 at 08:01:24PM +0530, Aneesh Kumar K.V wrote:
> Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:
> 
> > If list is empty, list_for_each_entry_safe() doesn't do anything.
> > So, this check is redundant. Remove it.
> >
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> 
> 
> >
> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > index a838e6b..d4a1695 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -1019,10 +1019,8 @@ free:
> >  	spin_unlock(&hugetlb_lock);
> >
> >  	/* Free unnecessary surplus pages to the buddy allocator */
> > -	if (!list_empty(&surplus_list)) {
> > -		list_for_each_entry_safe(page, tmp, &surplus_list, lru) {
> > -			put_page(page);
> > -		}
> > +	list_for_each_entry_safe(page, tmp, &surplus_list, lru) {
> > +		put_page(page);
> >  	}
> 
> You can now remove '{' 

Okay.
I will do that.

Thanks.

> 
> 
> >  	spin_lock(&hugetlb_lock);
> >
> > -- 
> > 1.7.9.5
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
