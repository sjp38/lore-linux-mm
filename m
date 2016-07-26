Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id DBF496B0005
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 03:58:50 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id p41so135222847lfi.0
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 00:58:50 -0700 (PDT)
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com. [74.125.82.46])
        by mx.google.com with ESMTPS id a9si18605290wjx.25.2016.07.26.00.58.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jul 2016 00:58:49 -0700 (PDT)
Received: by mail-wm0-f46.google.com with SMTP id q128so162261978wma.1
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 00:58:49 -0700 (PDT)
Date: Tue, 26 Jul 2016 09:58:48 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: + mm-hugetlb-fix-race-when-migrate-pages.patch added to -mm tree
Message-ID: <20160726075847.GG32462@dhcp22.suse.cz>
References: <5790C3DB.8000505@huawei.com>
 <20160721125555.GJ26379@dhcp22.suse.cz>
 <5790CD52.6050200@huawei.com>
 <20160721134044.GL26379@dhcp22.suse.cz>
 <5790D4FF.8070907@huawei.com>
 <20160721140124.GN26379@dhcp22.suse.cz>
 <5790D8A3.3090808@huawei.com>
 <20160721142722.GP26379@dhcp22.suse.cz>
 <5790DD4B.2060000@huawei.com>
 <20160722071737.GA3785@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160722071737.GA3785@hori1.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "qiuxishi@huawei.com" <qiuxishi@huawei.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "mm-commits@vger.kernel.org" <mm-commits@vger.kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri 22-07-16 07:17:37, Naoya Horiguchi wrote:
[...]
> I think that (src_pte != dst_pte) can happen and that's ok if there's no
> migration entry. 

We have discussed that with Naoya off-list and couldn't find a scenario
when parent would have !shared pmd while child would have it. The only
plausible scenario was that parent created and poppulated mapping smaller
than 1G and then enlarged it later on so the child would see sharedable
pud. This doesn't seem to be possible because vma_merge would bail out
due to VM_SPECIAL check.

> But even if we have both of normal entry and migration entry
> for one hugepage, that still looks fine to me because the running migration
> operation fails (because there remains mapcounts on the source hugepage),
> and all migration entries are turned back to normal entries pointing to the
> source hugepage.

Agreed.

> Could you try to see and share what happens on your workload with
> Michal's patch?

Zhong Jiang did you have chance to retest with the BUG_ON changed?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
