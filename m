Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A46AA6B0005
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 11:14:42 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id w128so275536688pfd.3
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 08:14:42 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id h5si35595534pfj.2.2016.08.01.08.14.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 01 Aug 2016 08:14:41 -0700 (PDT)
Message-ID: <579F64E1.8030707@huawei.com>
Date: Mon, 1 Aug 2016 23:04:01 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: + mm-hugetlb-fix-race-when-migrate-pages.patch added to -mm tree
References: <578eb28b.YbRUDGz5RloTVlrE%akpm@linux-foundation.org> <20160721074340.GA26398@dhcp22.suse.cz> <20160729112707.GB8031@dhcp22.suse.cz> <579C4A2E.4080009@huawei.com> <20160801110203.GB13544@dhcp22.suse.cz>
In-Reply-To: <20160801110203.GB13544@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, qiuxishi@huawei.com, vbabka@suse.cz, mm-commits@vger.kernel.org, Mike Kravetz <mike.kravetz@oracle.com>, Naoya
 Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org

On 2016/8/1 19:02, Michal Hocko wrote:
> On Sat 30-07-16 14:33:18, zhong jiang wrote:
>> On 2016/7/29 19:27, Michal Hocko wrote:
>>> On Thu 21-07-16 09:43:40, Michal Hocko wrote:
>>>> We have further discussed the patch and I believe it is not correct. See [1].
>>>> I am proposing the following alternative.
>>> Andrew, please drop the mm-hugetlb-fix-race-when-migrate-pages.patch. It
>>> is clearly racy. Whether the BUG_ON update is really the right and
>>> sufficient fix is not 100% clear yet and we are waiting for Zhong Jiang
>>> testing.
>> The issue is very hard to recur.  Without attaching any patch to
>> kernel code. up to now, it still not happens to it.
> Hmm, OK. So what do you propose? Are you OK with the BUG_ON change or do
> you think that this needs a deeper fix?
  yes,  I  agree  with your change.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
