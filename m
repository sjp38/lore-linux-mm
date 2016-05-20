Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9B3B36B0005
	for <linux-mm@kvack.org>; Fri, 20 May 2016 04:26:23 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 203so204388454pfy.2
        for <linux-mm@kvack.org>; Fri, 20 May 2016 01:26:23 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id uy8si26400146pab.145.2016.05.20.01.26.21
        for <linux-mm@kvack.org>;
        Fri, 20 May 2016 01:26:22 -0700 (PDT)
Date: Fri, 20 May 2016 17:26:19 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: + mm-thp-avoid-unnecessary-swapin-in-khugepaged.patch added to
 -mm tree
Message-ID: <20160520082619.GB14049@bbox>
References: <20160519050038.GA16318@bbox>
 <20160519070357.GB26110@dhcp22.suse.cz>
 <20160519072751.GB16318@bbox>
 <20160519073957.GE26110@dhcp22.suse.cz>
 <20160520002155.GA2224@bbox>
 <20160520063917.GC19172@dhcp22.suse.cz>
 <20160520072624.GD6808@bbox>
 <20160520073432.GE19172@dhcp22.suse.cz>
 <20160520074450.GA14049@bbox>
 <20160520080217.GG19172@dhcp22.suse.cz>
MIME-Version: 1.0
In-Reply-To: <20160520080217.GG19172@dhcp22.suse.cz>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, ebru.akagunduz@gmail.com, aarcange@redhat.com, aneesh.kumar@linux.vnet.ibm.com, boaz@plexistor.com, gorcunov@openvz.org, hannes@cmpxchg.org, hughd@google.com, iamjoonsoo.kim@lge.com, kirill.shutemov@linux.intel.com, mgorman@suse.de, n-horiguchi@ah.jp.nec.com, riel@redhat.com, rientjes@google.com, vbabka@suse.cz, mm-commits@vger.kernel.org, linux-mm@kvack.org

On Fri, May 20, 2016 at 10:02:18AM +0200, Michal Hocko wrote:
> On Fri 20-05-16 16:44:50, Minchan Kim wrote:
> > > > > That being said khugepaged_max_ptes_none = HPAGE_PMD_NR/2 sounds like a
> > > > 
> > > > max_ptes_none?
> > > 
> > > Not sure I understand what you mean here.
> > 
> > We are talking about max_ptes_swap and max_active_pages(i.e., pte_young)
> > but suddenly you are saying max_ptes_none so I was curious it was just
> > typo.
> 
> Because the default for pte_none resp. zero pages collapsing into THP is
> khugepaged_max_ptes_none and the current default means that a single
> present page is sufficient. That is way too optimistic. So I consider
> this to be a good start. I am not so sure about minimum young pages
> because that would probably require yet another tunable and we have more
> than enough of them. Anyway I guess we are getting off-topic here...

Optimistic swapin collapsing

1. it could be too optimisitic to lose the gain due to evicting workingset
2. let's detect memory pressure
3. current allocstall magic is not a good idea.
4. let's change the design from optimistic to conservative
5. how we can be conservative
6. two things - detect hot pages and threshold of swap pte
7. threhsold of swap pte is already done so remained thing is detect hot page
8. how to detect hot page - let's use young bit
9. Now, we are conservatie so we will swap in when it's worth
10. let's remove allocstall magic

I think it's not off-topic.
Anyway, it's just my thought and don't have any real workload and objection.
Feel free to ignore.

> -- 
> Michal Hocko
> SUSE Labs
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
