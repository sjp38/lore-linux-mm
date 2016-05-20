Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4802D6B0005
	for <linux-mm@kvack.org>; Fri, 20 May 2016 04:02:21 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id ga2so42860965lbc.0
        for <linux-mm@kvack.org>; Fri, 20 May 2016 01:02:21 -0700 (PDT)
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com. [74.125.82.41])
        by mx.google.com with ESMTPS id n66si5113538wmg.77.2016.05.20.01.02.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 May 2016 01:02:19 -0700 (PDT)
Received: by mail-wm0-f41.google.com with SMTP id w143so18216359wmw.0
        for <linux-mm@kvack.org>; Fri, 20 May 2016 01:02:19 -0700 (PDT)
Date: Fri, 20 May 2016 10:02:18 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: + mm-thp-avoid-unnecessary-swapin-in-khugepaged.patch added to
 -mm tree
Message-ID: <20160520080217.GG19172@dhcp22.suse.cz>
References: <20160517090254.GE14453@dhcp22.suse.cz>
 <20160519050038.GA16318@bbox>
 <20160519070357.GB26110@dhcp22.suse.cz>
 <20160519072751.GB16318@bbox>
 <20160519073957.GE26110@dhcp22.suse.cz>
 <20160520002155.GA2224@bbox>
 <20160520063917.GC19172@dhcp22.suse.cz>
 <20160520072624.GD6808@bbox>
 <20160520073432.GE19172@dhcp22.suse.cz>
 <20160520074450.GA14049@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160520074450.GA14049@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: akpm@linux-foundation.org, ebru.akagunduz@gmail.com, aarcange@redhat.com, aneesh.kumar@linux.vnet.ibm.com, boaz@plexistor.com, gorcunov@openvz.org, hannes@cmpxchg.org, hughd@google.com, iamjoonsoo.kim@lge.com, kirill.shutemov@linux.intel.com, mgorman@suse.de, n-horiguchi@ah.jp.nec.com, riel@redhat.com, rientjes@google.com, vbabka@suse.cz, mm-commits@vger.kernel.org, linux-mm@kvack.org

On Fri 20-05-16 16:44:50, Minchan Kim wrote:
> > > > That being said khugepaged_max_ptes_none = HPAGE_PMD_NR/2 sounds like a
> > > 
> > > max_ptes_none?
> > 
> > Not sure I understand what you mean here.
> 
> We are talking about max_ptes_swap and max_active_pages(i.e., pte_young)
> but suddenly you are saying max_ptes_none so I was curious it was just
> typo.

Because the default for pte_none resp. zero pages collapsing into THP is
khugepaged_max_ptes_none and the current default means that a single
present page is sufficient. That is way too optimistic. So I consider
this to be a good start. I am not so sure about minimum young pages
because that would probably require yet another tunable and we have more
than enough of them. Anyway I guess we are getting off-topic here...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
