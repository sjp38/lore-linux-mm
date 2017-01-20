Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0034E6B0033
	for <linux-mm@kvack.org>; Fri, 20 Jan 2017 04:55:57 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id z67so89551305pgb.0
        for <linux-mm@kvack.org>; Fri, 20 Jan 2017 01:55:57 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id x3si6337981pfi.274.2017.01.20.01.55.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 Jan 2017 01:55:57 -0800 (PST)
Subject: Re: [RFC] HWPOISON: soft offlining for non-lru movable page
References: <1484712054-7997-1-git-send-email-xieyisheng1@huawei.com>
 <20170118094530.GA29579@hori1.linux.bs1.fc.nec.co.jp>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <ccf71cb7-3a12-0bf4-ad79-b235f6df94c6@huawei.com>
Date: Fri, 20 Jan 2017 17:52:13 +0800
MIME-Version: 1.0
In-Reply-To: <20170118094530.GA29579@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mhocko@suse.com" <mhocko@suse.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "minchan@kernel.org" <minchan@kernel.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "guohanjun@huawei.com" <guohanjun@huawei.com>, "qiuxishi@huawei.com" <qiuxishi@huawei.com>

Hi Naoya,

On 2017/1/18 17:45, Naoya Horiguchi wrote:
> On Wed, Jan 18, 2017 at 12:00:54PM +0800, Yisheng Xie wrote:
>> This patch is to extends soft offlining framework to support
>> non-lru page, which already support migration after
>> commit bda807d44454 ("mm: migrate: support non-lru movable page
>> migration")
>>
>> When memory corrected errors occur on a non-lru movable page,
>> we can choose to stop using it by migrating data onto another
>> page and disable the original (maybe half-broken) one.
>>
>> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
> 
> It looks OK in my quick glance. I'll do some testing more tomorrow.
> 
Thanks for reviewing.
I have do some basic test like offline movable page and unpoison it.
Do you have some test suit or test suggestion? So I can do some more
test of it for double check? Very thanks for that.

Thanks
Yisheng Xie.

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
