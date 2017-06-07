Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9823C6B0279
	for <linux-mm@kvack.org>; Wed,  7 Jun 2017 02:17:24 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id o65so928576oif.15
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 23:17:24 -0700 (PDT)
Received: from mail-oi0-x22d.google.com (mail-oi0-x22d.google.com. [2607:f8b0:4003:c06::22d])
        by mx.google.com with ESMTPS id s6si337469otb.302.2017.06.06.23.17.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jun 2017 23:17:23 -0700 (PDT)
Received: by mail-oi0-x22d.google.com with SMTP id p7so1545248oif.2
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 23:17:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170607061216.GA5929@bbox>
References: <1496804917-7628-1-git-send-email-zhongjiang@huawei.com>
 <20170607035540.GA5687@bbox> <59378799.1050000@huawei.com> <20170607061216.GA5929@bbox>
From: vinayak menon <vinayakm.list@gmail.com>
Date: Wed, 7 Jun 2017 11:47:23 +0530
Message-ID: <CAOaiJ-k5c07J2mHyhUut+S3nqbjdXe+dYQgxBGn=wTmHEq5x2Q@mail.gmail.com>
Subject: Re: [PATCH] Revert "mm: vmpressure: fix sending wrong events on underflow"
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: zhong jiang <zhongjiang@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, mhocko@suse.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Wed, Jun 7, 2017 at 11:42 AM, Minchan Kim <minchan@kernel.org> wrote:
> On Wed, Jun 07, 2017 at 12:56:57PM +0800, zhong jiang wrote:
>> On 2017/6/7 11:55, Minchan Kim wrote:
>> > On Wed, Jun 07, 2017 at 11:08:37AM +0800, zhongjiang wrote:
>> >> This reverts commit e1587a4945408faa58d0485002c110eb2454740c.
>> >>
>> >> THP lru page is reclaimed , THP is split to normal page and loop again.
>> >> reclaimed pages should not be bigger than nr_scan.  because of each
>> >> loop will increase nr_scan counter.
>> > Unfortunately, there is still underflow issue caused by slab pages as
>> > Vinayak reported in description of e1587a4945408 so we cannot revert.
>> > Please correct comment instead of removing the logic.
>> >
>> > Thanks.
>>   we calculate the vmpressue based on the Lru page, exclude the slab pages by previous
>>   discussion.    is it not this?
>>
>
> IIRC, It is not merged into mainline although mmotm has it.

That's right Minchan. That patch was not mainlined.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
