Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 194C7C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 06:11:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D326E20823
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 06:11:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D326E20823
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5A71D8E00EF; Fri, 22 Feb 2019 01:11:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 52D6D8E00ED; Fri, 22 Feb 2019 01:11:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F5888E00EF; Fri, 22 Feb 2019 01:11:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id 114448E00ED
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 01:11:40 -0500 (EST)
Received: by mail-vk1-f199.google.com with SMTP id 202so592837vkv.11
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 22:11:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:cc:from:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding;
        bh=PH+w8D88mpOCj0IHX3DGEpE117Jqo6S1Yk/E/Yw6UJU=;
        b=eWMcmGdfivnGBrykZ7OluXKSfjB3khSoW9/NWS/pjFBwmABuuk4KV7mA5oWcB+fpE9
         AqNMtEHdQ75DU02WGqgfj7BiNaeMwo4gLAP6eSpR2F4Jc0iFN9fPIhx0GPeAMw+Zrk15
         bEYmPgAw1jLnOoVc0+NfumlNMHjrV2HmpA1kXnv8hUty7IhkshdUXMx41kVcOXl0nQOv
         vhtpIRQUaXWZ/8oiLtXtppAWoGs9iVrmRBZSil0uD/CqrwZG19uQbne5CJpjikW2nVBp
         fpPGHw/g4LsUdN7I+ugErx/iCeMRRoLA6npT7O6ozAniuViSwdze79vMLXHLHNg41ag9
         1Peg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jingxiangfeng@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jingxiangfeng@huawei.com
X-Gm-Message-State: AHQUAuaABHZ9A9yfjkmkLa9wqPES3kKHk9Z8FBMasViLbv0iO9dF6D64
	6W6/tuaYpx+p+WLsKkXeYYCC7drtqNWgMcB/5ckEWTVJk0xk5BQvd766pwOe1dOjLmSaqLBBsvE
	CpGxl2Ypv+mFYCe3QgqfruAe4NCnH/yQFi9RiNR8hKTQiON7mZmRVfC62gO4UCfrzhA==
X-Received: by 2002:a67:fdd8:: with SMTP id l24mr1331350vsq.236.1550815899684;
        Thu, 21 Feb 2019 22:11:39 -0800 (PST)
X-Google-Smtp-Source: AHgI3Iap7L1FtqJIWyDsm+leGFfPFsJN1mQMVP8yqvf+LR0hh8zryYKSYWVEAFgi5MuTMkhw9Kxx
X-Received: by 2002:a67:fdd8:: with SMTP id l24mr1331322vsq.236.1550815898721;
        Thu, 21 Feb 2019 22:11:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550815898; cv=none;
        d=google.com; s=arc-20160816;
        b=qDEj7nXCE8Ne3dXpBRe2nY8SYQiSUQDk5hJwWMPPmGn1nuNOf2SDWNtb6Jv6xyimhe
         r/1bCepILOyg63E9I+c4tXOG8MwqP0XjROH6nS2gltSMUzEmy2ChK/mmGQmhGUgDAqdA
         ZMCqpKM03fXennYyxS5lU0Zj8oAg09gvbLRbUonRJJjSFbbFo0nxz4fDhzJTA2EzFE7A
         tDlkbtEInimZEE9uuL0R9wMOQZ7hS7T/CvJ177jCG89lK7mSbij0FMNG1K682TBrnGxL
         9wSvDdi3KWf3gkc0G468lECtRMUdAtGGXZ57qR2KI7LbV54zI5RZqrxqt6P36W2MXllx
         ouNQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:from:cc:references:to:subject;
        bh=PH+w8D88mpOCj0IHX3DGEpE117Jqo6S1Yk/E/Yw6UJU=;
        b=S5MoBleim0ZEhdMexghdB1bnjklmqxR04KGlUKKgTlcdXiw5SZcj+yqsE88TRIqJ9g
         oVvY042hGR2cA6Bl4bt9CGgjc8xbuwdAtyQinGuEClXfncNF+yepV01lYkkpcXcMHNc1
         EneTTbdgFGLNuiWlfgZ6kmaDogYDSz4VrBpY13VSHloQrt6HOCEfq/1BGheWTRt9unp3
         aVZYgYcCCG/b5lBA5ji3nNoG5IVU+Ku9D6ZcHSw0UiU/AFyQKxYmXBR5S9IJ8asAK7L1
         A95A7z7IRhX4+h4P7Q5W94P38APOfIuIZSlkJqvt3wjzx1Dj2lA1DSBbknhvYaeVu7jV
         zSsw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jingxiangfeng@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jingxiangfeng@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id j5si127920vkh.7.2019.02.21.22.11.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 22:11:38 -0800 (PST)
Received-SPF: pass (google.com: domain of jingxiangfeng@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jingxiangfeng@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jingxiangfeng@huawei.com
Received: from DGGEMS410-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 88AC1DF5FCAF9ACBD1FC;
	Fri, 22 Feb 2019 14:11:34 +0800 (CST)
Received: from [127.0.0.1] (10.184.39.28) by DGGEMS410-HUB.china.huawei.com
 (10.3.19.210) with Microsoft SMTP Server id 14.3.408.0; Fri, 22 Feb 2019
 14:11:30 +0800
Subject: Re: [PATCH] mm/hugetlb: Fix unsigned overflow in
 __nr_hugepages_store_common()
To: Mike Kravetz <mike.kravetz@oracle.com>, Michal Hocko <mhocko@kernel.org>
References: <1550323872-119049-1-git-send-email-jingxiangfeng@huawei.com>
 <20190218092750.GF4525@dhcp22.suse.cz>
 <7ec68c26-3caf-0446-9c93-461025c51c01@oracle.com>
CC: <akpm@linux-foundation.org>, <hughd@google.com>,
	<n-horiguchi@ah.jp.nec.com>, <aarcange@redhat.com>,
	<kirill.shutemov@linux.intel.com>, <linux-kernel@vger.kernel.org>,
	<linux-mm@kvack.org>
From: Jing Xiangfeng <jingxiangfeng@huawei.com>
Message-ID: <5C6F9258.3000904@huawei.com>
Date: Fri, 22 Feb 2019 14:10:32 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:38.0) Gecko/20100101
 Thunderbird/38.1.0
MIME-Version: 1.0
In-Reply-To: <7ec68c26-3caf-0446-9c93-461025c51c01@oracle.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.184.39.28]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/2/20 7:45, Mike Kravetz wrote:
> On 2/18/19 1:27 AM, Michal Hocko wrote:
>> On Sat 16-02-19 21:31:12, Jingxiangfeng wrote:
>>> From: Jing Xiangfeng <jingxiangfeng@huawei.com>
>>>
>>> We can use the following command to dynamically allocate huge pages:
>>> 	echo NR_HUGEPAGES > /proc/sys/vm/nr_hugepages
>>> The count in  __nr_hugepages_store_common() is parsed from /proc/sys/vm/nr_hugepages,
>>> The maximum number of count is ULONG_MAX,
>>> the operation 'count += h->nr_huge_pages - h->nr_huge_pages_node[nid]' overflow and count will be a wrong number.
>>
>> Could you be more specific of what is the runtime effect on the
>> overflow? I haven't checked closer but I would assume that we will
>> simply shrink the pool size because count will become a small number.
>>
> 
> Well, the first thing to note is that this code only applies to case where
> someone is changing a node specific hugetlb count.  i.e.
> /sys/devices/system/node/node1/hugepages/hugepages-2048kB
> In this case, the calculated value of count is a maximum or minimum total
> number of huge pages.  However, only the number of huge pages on the specified
> node is adjusted to try and achieve this maximum or minimum.
> 
> So, in the case of overflow the number of huge pages on the specified node
> could be reduced.  I say 'could' because it really is dependent on previous
> values.  In some situations the node specific value will be increased.
> 
> Minor point is that the description in the commit message does not match
> the code changed.
> 
Thanks for your reply.as you said, the case is where someone is changing a node
specific hugetlb count when CONFIG_NUMA is enable. I will modify the commit message.

>> Is there any reason to report an error in that case? We do not report
>> errors when we cannot allocate the requested number of huge pages so why
>> is this case any different?
> 
> Another issue to consider is that h->nr_huge_pages is an unsigned long,
> and h->nr_huge_pages_node[] is an unsigned int.  The sysfs store routines
> treat them both as unsigned longs.  Ideally, the store routines should
> distinguish between the two.
> 
> In reality, an actual overflow is unlikely.  If my math is correct (not
> likely) it would take something like 8 Petabytes to overflow the node specific
> counts.
> 
> In the case of a user entering a crazy high value and causing an overflow,
> an error return might not be out of line.  Another option would be to simply
> set count to ULONG_MAX if we detect overflow (or UINT_MAX if we are paranoid)
> and continue on.  This may be more in line with user's intention of allocating
> as many huge pages as possible.
> 
> Thoughts?
> 
It is better to set count to ULONG_MAX if we detect overflow, and continue to
allocate as many huge pages as possible.
I will send v2 soon.

