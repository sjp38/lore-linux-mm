Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id D80DD6B0279
	for <linux-mm@kvack.org>; Wed,  7 Jun 2017 02:52:59 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id p77so1986407ioe.11
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 23:52:59 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [45.249.212.187])
        by mx.google.com with ESMTPS id z89si1494270ita.121.2017.06.06.23.52.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 06 Jun 2017 23:52:58 -0700 (PDT)
Message-ID: <5937A000.8020306@huawei.com>
Date: Wed, 7 Jun 2017 14:41:04 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Revert "mm: vmpressure: fix sending wrong events on underflow"
References: <1496804917-7628-1-git-send-email-zhongjiang@huawei.com> <20170607035540.GA5687@bbox> <59378799.1050000@huawei.com> <20170607061216.GA5929@bbox> <CAOaiJ-k5c07J2mHyhUut+S3nqbjdXe+dYQgxBGn=wTmHEq5x2Q@mail.gmail.com>
In-Reply-To: <CAOaiJ-k5c07J2mHyhUut+S3nqbjdXe+dYQgxBGn=wTmHEq5x2Q@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vinayak menon <vinayakm.list@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, mhocko@suse.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On 2017/6/7 14:17, vinayak menon wrote:
> On Wed, Jun 7, 2017 at 11:42 AM, Minchan Kim <minchan@kernel.org> wrote:
>> On Wed, Jun 07, 2017 at 12:56:57PM +0800, zhong jiang wrote:
>>> On 2017/6/7 11:55, Minchan Kim wrote:
>>>> On Wed, Jun 07, 2017 at 11:08:37AM +0800, zhongjiang wrote:
>>>>> This reverts commit e1587a4945408faa58d0485002c110eb2454740c.
>>>>>
>>>>> THP lru page is reclaimed , THP is split to normal page and loop again.
>>>>> reclaimed pages should not be bigger than nr_scan.  because of each
>>>>> loop will increase nr_scan counter.
>>>> Unfortunately, there is still underflow issue caused by slab pages as
>>>> Vinayak reported in description of e1587a4945408 so we cannot revert.
>>>> Please correct comment instead of removing the logic.
>>>>
>>>> Thanks.
>>>   we calculate the vmpressue based on the Lru page, exclude the slab pages by previous
>>>   discussion.    is it not this?
>>>
>> IIRC, It is not merged into mainline although mmotm has it.
> That's right Minchan. That patch was not mainlined.
>
>
 Hi  Minchan and vinayak

 we should revert the patch (mm: vmpressure: fix sending wrong events on underflow), then
 apply the mmotm's related patch. or drop the mmotm's related patch, then corrent the comment.

 which one make more sense.  Maybe the latter is more feasible. Suggestion ?

 Thanks
 zhongjiang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
