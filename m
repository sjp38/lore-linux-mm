Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id DC9756B0005
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 10:27:24 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id s189so169119063vkh.0
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 07:27:24 -0700 (PDT)
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com. [74.125.82.42])
        by mx.google.com with ESMTPS id p41si5124229qtc.147.2016.07.21.07.27.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jul 2016 07:27:24 -0700 (PDT)
Received: by mail-wm0-f42.google.com with SMTP id i5so27569092wmg.0
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 07:27:24 -0700 (PDT)
Date: Thu, 21 Jul 2016 16:27:22 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: + mm-hugetlb-fix-race-when-migrate-pages.patch added to -mm tree
Message-ID: <20160721142722.GP26379@dhcp22.suse.cz>
References: <20160721112754.GH26379@dhcp22.suse.cz>
 <5790BCB1.4020800@huawei.com>
 <20160721123001.GI26379@dhcp22.suse.cz>
 <5790C3DB.8000505@huawei.com>
 <20160721125555.GJ26379@dhcp22.suse.cz>
 <5790CD52.6050200@huawei.com>
 <20160721134044.GL26379@dhcp22.suse.cz>
 <5790D4FF.8070907@huawei.com>
 <20160721140124.GN26379@dhcp22.suse.cz>
 <5790D8A3.3090808@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5790D8A3.3090808@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, akpm@linux-foundation.org, qiuxishi@huawei.com, vbabka@suse.cz, mm-commits@vger.kernel.org, Mike Kravetz <mike.kravetz@oracle.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org

On Thu 21-07-16 22:13:55, zhong jiang wrote:
> On 2016/7/21 22:01, Michal Hocko wrote:
> > On Thu 21-07-16 21:58:23, zhong jiang wrote:
> >> On 2016/7/21 21:40, Michal Hocko wrote:
> >>> On Thu 21-07-16 21:25:38, zhong jiang wrote:
> >>>> On 2016/7/21 20:55, Michal Hocko wrote:
> >>> [...]
> >>>>> OK, now I understand what you mean. So you mean that a different process
> >>>>> initiates the migration while this path copies to pte. That is certainly
> >>>>> possible but I still fail to see what is the problem about that.
> >>>>> huge_pte_alloc will return the identical pte whether it is regular or
> >>>>> migration one. So what exactly is the problem?
> >>>>>
> >>>> copy_hugetlb_page_range obtain the shared dst_pte, it may be not equal
> >>>> to the src_pte.  The dst_pte can come from other process sharing the
> >>>> mapping.
> >>> So you mean that the parent doesn't have the shared pte while the child
> >>> would get one?
> >>>  
> >>  no, parent must have the shared pte because the the child copy the
> >> parent. but parent is not the only source pte we can get. when we
> >> scan the maping->i_mmap, firstly ,it can obtain a shared pte from
> >> other process. but I am not sure.
> > But then all the shared ptes should be identical, no? Or am I missing
> > something?
>  all the shared ptes should be identical, but  there is  a possibility that new process
>  want to share the pte from other process ,  other than the parent,  For the first time
>  the process is about to share pte with it.   is it possiblity?

I do not see how. They are opperating on the same mapping so I really do
not see how different process makes any difference.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
