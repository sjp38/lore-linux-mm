Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2A6166B026D
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 11:31:46 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id o80so84642581wme.1
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 08:31:46 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id n78si14699454lfg.49.2016.08.01.08.31.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Aug 2016 08:31:44 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id q128so26719040wma.1
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 08:31:44 -0700 (PDT)
Date: Mon, 1 Aug 2016 17:31:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: + mm-hugetlb-fix-race-when-migrate-pages.patch added to -mm tree
Message-ID: <20160801153143.GN13544@dhcp22.suse.cz>
References: <578eb28b.YbRUDGz5RloTVlrE%akpm@linux-foundation.org>
 <20160721074340.GA26398@dhcp22.suse.cz>
 <20160729112707.GB8031@dhcp22.suse.cz>
 <579C4A2E.4080009@huawei.com>
 <20160801110203.GB13544@dhcp22.suse.cz>
 <579F64E1.8030707@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <579F64E1.8030707@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: zhong jiang <zhongjiang@huawei.com>, qiuxishi@huawei.com, vbabka@suse.cz, mm-commits@vger.kernel.org, Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org

On Mon 01-08-16 23:04:01, zhong jiang wrote:
> On 2016/8/1 19:02, Michal Hocko wrote:
> > On Sat 30-07-16 14:33:18, zhong jiang wrote:
> >> On 2016/7/29 19:27, Michal Hocko wrote:
> >>> On Thu 21-07-16 09:43:40, Michal Hocko wrote:
> >>>> We have further discussed the patch and I believe it is not correct. See [1].
> >>>> I am proposing the following alternative.
> >>> Andrew, please drop the mm-hugetlb-fix-race-when-migrate-pages.patch. It
> >>> is clearly racy. Whether the BUG_ON update is really the right and
> >>> sufficient fix is not 100% clear yet and we are waiting for Zhong Jiang
> >>> testing.
> >> The issue is very hard to recur.  Without attaching any patch to
> >> kernel code. up to now, it still not happens to it.
> > Hmm, OK. So what do you propose? Are you OK with the BUG_ON change or do
> > you think that this needs a deeper fix?
>
>   yes,  I  agree  with your change.

OK, Andrew, could you merge
http://lkml.kernel.org/r/20160721074340.GA26398@dhcp22.suse.cz with ack
from Naoya
http://lkml.kernel.org/r/20160721081355.GB25398@hori1.linux.bs1.fc.nec.co.jp

Thanks!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
