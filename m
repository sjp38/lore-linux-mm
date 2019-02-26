Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8CE3C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 14:34:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6E9A72173C
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 14:34:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E9A72173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0DB7C8E0003; Tue, 26 Feb 2019 09:34:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 08B2F8E0001; Tue, 26 Feb 2019 09:34:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E96638E0003; Tue, 26 Feb 2019 09:34:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f69.google.com (mail-ua1-f69.google.com [209.85.222.69])
	by kanga.kvack.org (Postfix) with ESMTP id B5C068E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 09:34:40 -0500 (EST)
Received: by mail-ua1-f69.google.com with SMTP id c26so3030031uar.12
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 06:34:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :date:from:user-agent:mime-version:to:cc:subject:references
         :in-reply-to:content-transfer-encoding;
        bh=GtdpFM9VJfibiIRcE0dYG5hwsfFVvTTjoa0tjxpgkY4=;
        b=tpCIYsrSJOYF5AJejB4l4EXQbhakHdwSj6uSaD4yxuUNTM1YrXUH65BK3m+Q8rHYQN
         Tn4o9/OpPt71Fvn5hKFoc17auPgV3+SW9oV/z1O+BIlmUuPUoq/Q7Y1vfTdkSZ4CT6It
         kFvzw1U4F8PKG6NxpCrOTuR1UC/t27Iwui53bve/tlrjlQShm3633z4HOrFZBGdvU2/5
         oXmwqp/gGLJqYVKTkjd7M/ACFnIOl6pF8xDLCaiwRlIJo4rdQADpuVqUc7+Bb8U5ELfc
         6nJEuekIWjPRN4AL+BISrSWbQ79YzP5jYBVjJAqawf1a+Jxh1UqobR/IOOedo/rvWjd7
         8j8A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
X-Gm-Message-State: AHQUAuaUaMBET0w/j+fu5CRnO/9Vz/Lf3Ok1w/K5IKcQZOg6AYmXzrAB
	9C7MY/KgoBBFftPYMKLjPyhnF2cb+7+Tm0EimG/9uBhZOQKGrmtb8l8KvMUX7GNhJyYbTlwA+IS
	0xWhW4qr5NZUtH5/Ce9aH2/4PrvctTSqUdLxU8G7vD4WUNLQw2VQCRj0jHECnuRjFrQ==
X-Received: by 2002:ab0:28c6:: with SMTP id g6mr10793835uaq.109.1551191680373;
        Tue, 26 Feb 2019 06:34:40 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYhQYGF+8BD8XqbBynksvh03TuUNFm+tL4i+EGnIL40tWwmDkGWvf9jiAKeD4G7JZcvvj9z
X-Received: by 2002:ab0:28c6:: with SMTP id g6mr10793803uaq.109.1551191679751;
        Tue, 26 Feb 2019 06:34:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551191679; cv=none;
        d=google.com; s=arc-20160816;
        b=IiMjwefsQcqogcuBqizmAnsFA/82bbIy/Tf8jigg4RN4o0Grm7pwykEQT0srqzqUJm
         KFn2EFzX072CUD5QdASPgO+mm6i1NtwAynmMa2XIuSLVUTu7YzGDeZTxJxbvgpMVoPsE
         o56TTWHFyeUK8Xq5G6TCZzV+CUlHavFVMsdb+kha1/0VvnRizXGfVl6PIu7ocG4UIIBy
         e8iyH9KQGCuM+beLRdqvQ7Lma1KhyHFZ+1NzvZt4WG+9iOxEGeav2fFJ20wui7qCD4ef
         QAvwWt3z/3mjnX4K/7RyDMtAUZg8QaoqjKJguQjJJfrFROIIhXzjxahxVtP76Zjl68n0
         fWXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:references:subject:cc:to
         :mime-version:user-agent:from:date:message-id;
        bh=GtdpFM9VJfibiIRcE0dYG5hwsfFVvTTjoa0tjxpgkY4=;
        b=C8zY3DjUmdbuW9zGvKZmy12AThyzCJmPY9AWC0zbvovxDBOBD8cvMRUH+umvdkjXbc
         6GK+PhKIeOblw4IIjVCQWTiHRiAwEAfQheZAZk+VN/6x+vvL7B0189E2AcD1WwVZr1Lb
         znOLAM62hKBUvtWkPBF5SLu9+IND8HyfR52pjPAOAmUjCta123EMEh71VU8e6iBEet0B
         zEP/8TcUsSXUnMm8fzZyL8zv5CGkCHcL+OzOgXPHL/VAXkP46ziVSHT8JPiVcbYpcHZY
         e9A3f/wV5w63ae3HIYlI9MsqPUxz4aga4bqlzuIdCzufgEC/mkHp5kSh2/leKYRFXson
         gBIg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id t19si2279249vsp.267.2019.02.26.06.34.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 06:34:39 -0800 (PST)
Received-SPF: pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from DGGEMS413-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 84FAC77CDBC0C7823188;
	Tue, 26 Feb 2019 22:34:34 +0800 (CST)
Received: from [127.0.0.1] (10.177.29.68) by DGGEMS413-HUB.china.huawei.com
 (10.3.19.213) with Microsoft SMTP Server id 14.3.408.0; Tue, 26 Feb 2019
 22:34:33 +0800
Message-ID: <5C754E78.4050804@huawei.com>
Date: Tue, 26 Feb 2019 22:34:32 +0800
From: zhong jiang <zhongjiang@huawei.com>
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20120428 Thunderbird/12.0.1
MIME-Version: 1.0
To: "Kirill A. Shutemov" <kirill@shutemov.name>
CC: <n-horiguchi@ah.jp.nec.com>, <akpm@linux-foundation.org>,
	<linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, <mhocko@suse.com>,
	<hughd@google.com>, <mhocko@kernel.org>
Subject: Re: [PATCH] mm: hwpoison: fix thp split handing in soft_offline_in_use_page()
References: <1551179880-65331-1-git-send-email-zhongjiang@huawei.com> <20190226135156.mifspmbdyr6m3hff@kshutemo-mobl1>
In-Reply-To: <20190226135156.mifspmbdyr6m3hff@kshutemo-mobl1>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.177.29.68]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/2/26 21:51, Kirill A. Shutemov wrote:
> On Tue, Feb 26, 2019 at 07:18:00PM +0800, zhong jiang wrote:
>> From: zhongjiang <zhongjiang@huawei.com>
>>
>> When soft_offline_in_use_page() runs on a thp tail page after pmd is plit,
> s/plit/split/
>
>> we trigger the following VM_BUG_ON_PAGE():
>>
>> Memory failure: 0x3755ff: non anonymous thp
>> __get_any_page: 0x3755ff: unknown zero refcount page type 2fffff80000000
>> Soft offlining pfn 0x34d805 at process virtual address 0x20fff000
>> page:ffffea000d360140 count:0 mapcount:0 mapping:0000000000000000 index:0x1
>> flags: 0x2fffff80000000()
>> raw: 002fffff80000000 ffffea000d360108 ffffea000d360188 0000000000000000
>> raw: 0000000000000001 0000000000000000 00000000ffffffff 0000000000000000
>> page dumped because: VM_BUG_ON_PAGE(page_ref_count(page) == 0)
>> ------------[ cut here ]------------
>> kernel BUG at ./include/linux/mm.h:519!
>>
>> soft_offline_in_use_page() passed refcount and page lock from tail page to
>> head page, which is not needed because we can pass any subpage to
>> split_huge_page().
> I don't see a description of what is going wrong and why change will fixed
> it. From the description, it appears as it's cosmetic-only change.
>
> Please elaborate.
When soft_offline_in_use_page runs on a thp tail page after pmd is split,  
and we pass the head page to split_huge_page, Unfortunately, the tail page
can be free or count turn into zero.

Thanks,
zhong jiang



