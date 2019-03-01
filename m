Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D307C10F03
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 07:46:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6446A218AE
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 07:46:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6446A218AE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F15928E0004; Fri,  1 Mar 2019 02:46:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EC1AC8E0001; Fri,  1 Mar 2019 02:46:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D89D28E0004; Fri,  1 Mar 2019 02:46:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id A5F358E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 02:46:43 -0500 (EST)
Received: by mail-vk1-f197.google.com with SMTP id 5so11969258vkg.20
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 23:46:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :date:from:user-agent:mime-version:to:cc:subject:references
         :in-reply-to:content-transfer-encoding;
        bh=BmTBy+EAZiuQvWEAs58q91QW2FPr7eHyeIPgjCdq61Q=;
        b=KZXaAvtpdcv3XT8r9/VRe7uQ7M7limQapZX+CGkvLCr0lg8uzRRA8ZPwXYyl3phxVQ
         vxoOtZMgNahX3lTRwJE3OaqkttID7XCiFRAq0fb2aseQp7AyBPiP459N9EB4AlXOXxa1
         v3RE5/u7HiakF+Xh8VzL4+kSWmlBh/XVfBs1/ckocaVsGFHynOQYVUQGxsdT0oLp+bET
         Q+naOJ6hMgHKkZDRFc/33VI+6fP9ieIW7ozQly4LBukTdxGwnPGKU5ZIp3jZYWrEjXCG
         U6QyasjPp8F0DypLFoRaszIr8XiEAaSfpC4YloO2KMYGm0EMzwyOHD4Ga1LogzbnLhqb
         EZGw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
X-Gm-Message-State: APjAAAWSGzHhrK3/dhoyI5SMBnv05NmLa4XDv0+1N6nqC/eG8tT0pu/+
	TN/W5PWNZ96MT4ZOkppRfPw+abVIBzLcmeSGAqQKsfKGMXRK8e3XXxj7E4d+fZvobO1W12Kl3Jp
	bfWoQkiBq6q3syzxanVxNzACRWoztb4LeBphE1cJsgGf2Xu8ZNlGr/ERMAGwM/OEqPQ==
X-Received: by 2002:ab0:3407:: with SMTP id z7mr1894445uap.115.1551426403332;
        Thu, 28 Feb 2019 23:46:43 -0800 (PST)
X-Google-Smtp-Source: APXvYqzHUIvWpKC63z09UMOiIZ/ORK2I1GsUS4NLv/Qs1dZis8XrQPsyDQ2CDgBEcUDnOnG7yW9m
X-Received: by 2002:ab0:3407:: with SMTP id z7mr1894417uap.115.1551426402595;
        Thu, 28 Feb 2019 23:46:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551426402; cv=none;
        d=google.com; s=arc-20160816;
        b=Ib3RIHmylyq0z/0CvtYJe65ePl9XxvpWvE+K+wvAl1IAyhN9XmjE6/TyV+BxWEkSXE
         T1TobC1WcUtHHsvbjlbg+sL5rAqT9gTB65BRrd9zmyi+VR1B0AFR2bUhxkDBosdb8guj
         CgkFApUecLP09U47emZwYoNd8rGeImxmZXNHnX08RaXTcZAIS4l+EzOm6ISuKA73KN74
         pqO7SuHMknTvgv4ORCa0PFtJ9rkmUzvzE4frnPQxPBly385j52NZdBcNLtuaCt1XZfzd
         nxvWv70E6TlNv4vKgE7OeCNzd5nlCT+uUXS2/dTJDyrmG7aNTv90gGAvJ7xoFqjcyaON
         yopA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:references:subject:cc:to
         :mime-version:user-agent:from:date:message-id;
        bh=BmTBy+EAZiuQvWEAs58q91QW2FPr7eHyeIPgjCdq61Q=;
        b=UDvGHBEh8foP2HTYd6DiPEaqionzbrKT13Cm7mBQUgw8hTpAFKk+BV1pqlMlYKH963
         ZauErk1WZdmIyqZMrHcopn9Ad++ExqrJ2ybxdBJ6ASr3okJMpB1BujynawInoaDi3niw
         b++l+2pOtjzxbY+QzHzOtEATRVFWykOJ0G6YZ+M3Cl4XSHdLixloCwG7M2wXsHJE8iaJ
         MC/gzExiaFAtrr1dKgK8C/A7uSyIbbLvPrrl4i6zv9cCo7Fl5nGc/nqWTNwRlBhSIy9x
         TvYZCsXMxde7fF0WAzxxxA9q6A0tPoibG4Ugv474ftFe6K94RNgL5E2Pa5H7S85WUnIQ
         KStA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id o22si3379976vsp.333.2019.02.28.23.46.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 23:46:42 -0800 (PST)
Received-SPF: pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from DGGEMS406-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 7C2AE9FC675B8F1EC746;
	Fri,  1 Mar 2019 15:46:38 +0800 (CST)
Received: from [127.0.0.1] (10.177.29.68) by DGGEMS406-HUB.china.huawei.com
 (10.3.19.206) with Microsoft SMTP Server id 14.3.408.0; Fri, 1 Mar 2019
 15:46:33 +0800
Message-ID: <5C78E357.5060808@huawei.com>
Date: Fri, 1 Mar 2019 15:46:31 +0800
From: zhong jiang <zhongjiang@huawei.com>
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20120428 Thunderbird/12.0.1
MIME-Version: 1.0
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
CC: "Kirill A. Shutemov" <kirill@shutemov.name>, "akpm@linux-foundation.org"
	<akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mhocko@suse.com" <mhocko@suse.com>, "hughd@google.com" <hughd@google.com>,
	"mhocko@kernel.org" <mhocko@kernel.org>
Subject: Re: [PATCH] mm: hwpoison: fix thp split handing in soft_offline_in_use_page()
References: <1551179880-65331-1-git-send-email-zhongjiang@huawei.com> <20190226135156.mifspmbdyr6m3hff@kshutemo-mobl1> <5C754E78.4050804@huawei.com> <20190301072919.GA3027@hori.linux.bs1.fc.nec.co.jp>
In-Reply-To: <20190301072919.GA3027@hori.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.177.29.68]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/3/1 15:29, Naoya Horiguchi wrote:
> On Tue, Feb 26, 2019 at 10:34:32PM +0800, zhong jiang wrote:
>> On 2019/2/26 21:51, Kirill A. Shutemov wrote:
>>> On Tue, Feb 26, 2019 at 07:18:00PM +0800, zhong jiang wrote:
>>>> From: zhongjiang <zhongjiang@huawei.com>
>>>>
>>>> When soft_offline_in_use_page() runs on a thp tail page after pmd is plit,
>>> s/plit/split/
>>>
>>>> we trigger the following VM_BUG_ON_PAGE():
>>>>
>>>> Memory failure: 0x3755ff: non anonymous thp
>>>> __get_any_page: 0x3755ff: unknown zero refcount page type 2fffff80000000
>>>> Soft offlining pfn 0x34d805 at process virtual address 0x20fff000
>>>> page:ffffea000d360140 count:0 mapcount:0 mapping:0000000000000000 index:0x1
>>>> flags: 0x2fffff80000000()
>>>> raw: 002fffff80000000 ffffea000d360108 ffffea000d360188 0000000000000000
>>>> raw: 0000000000000001 0000000000000000 00000000ffffffff 0000000000000000
>>>> page dumped because: VM_BUG_ON_PAGE(page_ref_count(page) == 0)
>>>> ------------[ cut here ]------------
>>>> kernel BUG at ./include/linux/mm.h:519!
>>>>
>>>> soft_offline_in_use_page() passed refcount and page lock from tail page to
>>>> head page, which is not needed because we can pass any subpage to
>>>> split_huge_page().
>>> I don't see a description of what is going wrong and why change will fixed
>>> it. From the description, it appears as it's cosmetic-only change.
>>>
>>> Please elaborate.
>> When soft_offline_in_use_page runs on a thp tail page after pmd is split,  
>> and we pass the head page to split_huge_page, Unfortunately, the tail page
>> can be free or count turn into zero.
> I guess that you have the similar fix on memory_failure() in your mind:
>
>   commit c3901e722b2975666f42748340df798114742d6d
>   Author: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>   Date:   Thu Nov 10 10:46:23 2016 -0800
>   
>       mm: hwpoison: fix thp split handling in memory_failure()
>
> So it seems that I somehow missed fixing soft offline when I wrote commit
> c3901e722b29, and now you find and fix that. Thank you very much.
> If you resend the patch with fixing typo, can you add some reference to
> c3901e722b29 in the patch description to show the linkage?
> And you can add the following tags:
Yep, I find that that is a similar issue. hence I refer to that description in the patch you
had mentioned.

I will add the above desprition you had mentioned in V2.

Thanks,
zhong jiang
> Fixes: 61f5d698cc97 ("mm: re-enable THP")
> Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>
> Thanks,
> Naoya Horiguchi
>
> .
>


