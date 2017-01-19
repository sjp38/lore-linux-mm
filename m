Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 82B7F6B0033
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 20:23:37 -0500 (EST)
Received: by mail-vk0-f69.google.com with SMTP id t8so16790208vke.3
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 17:23:37 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id w18si618973uaf.90.2017.01.18.17.23.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Jan 2017 17:23:36 -0800 (PST)
Subject: Re: [RFC] HWPOISON: soft offlining for non-lru movable page
References: <1484712054-7997-1-git-send-email-xieyisheng1@huawei.com>
 <20170118095148.GK7015@dhcp22.suse.cz>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <85bb8e26-dfd9-19da-5444-e67502de4080@huawei.com>
Date: Thu, 19 Jan 2017 09:21:49 +0800
MIME-Version: 1.0
In-Reply-To: <20170118095148.GK7015@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, guohanjun@huawei.com, qiuxishi@huawei.com



On 2017/1/18 17:51, Michal Hocko wrote:
> On Wed 18-01-17 12:00:54, Yisheng Xie wrote:
>> This patch is to extends soft offlining framework to support
>> non-lru page, which already support migration after
>> commit bda807d44454 ("mm: migrate: support non-lru movable page
>> migration")
>>
>> When memory corrected errors occur on a non-lru movable page,
>> we can choose to stop using it by migrating data onto another
>> page and disable the original (maybe half-broken) one.
> 
> soft_offline_movable_page duplicates quite a lot from
> __soft_offline_page. Would it be better to handle both cases in
> __soft_offline_page?
> 
Hi Michal,
Thanks for reviewing.
Yes, the most code of soft_offline_movable_page is duplicates with
__soft_offline_page, I use a single function to make code looks clear,
just as what soft_offline_hugetlb_page do.

I will try to make a v2 as your suggestion.

Thanks
Yisheng Xie.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
