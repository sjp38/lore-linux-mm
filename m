Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 62D756B0005
	for <linux-mm@kvack.org>; Wed, 20 Jul 2016 09:00:58 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id 33so32112374lfw.1
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 06:00:58 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o5si875743wjs.198.2016.07.20.06.00.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Jul 2016 06:00:56 -0700 (PDT)
Date: Wed, 20 Jul 2016 15:00:56 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2] mm/hugetlb: fix race when migrate pages
Message-ID: <20160720130055.GL11249@dhcp22.suse.cz>
References: <1468935958-21810-1-git-send-email-zhongjiang@huawei.com>
 <20160720073859.GE11249@dhcp22.suse.cz>
 <578F4C7C.6000706@huawei.com>
 <20160720121645.GJ11249@dhcp22.suse.cz>
 <20160720124501.GK11249@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160720124501.GK11249@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: vbabka@suse.cz, qiuxishi@huawei.com, akpm@linux-foundation.org, linux-mm@kvack.org, Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>

On Wed 20-07-16 14:45:01, Michal Hocko wrote:
[...]
> I was talking to Mel (CCed) and he has raised a good question. So if you
> encounter a page under migration and fail to share the pmd with it how
> can you have a proper content of the target page in the end?

Hmm, I was staring into the code some more and it seems this would be OK
because we should hit hugetlb_no_page with the newel instantiated pmd
and associate it with a page from the radix tree. So unless I am missing
something the corruption shouldn't be possible.

I believe the post pmd_populate race is still there, though, so I
believe the approach should be rethought.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
