Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 155A56B000A
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 16:38:05 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id u4-v6so6668847pgr.2
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 13:38:05 -0700 (PDT)
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTPS id g40-v6si2547309plb.169.2018.07.20.13.38.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 13:38:03 -0700 (PDT)
Subject: Re: [PATCH] mm: thp: remove use_zero_page sysfs knob
References: <1532110430-115278-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180720123243.6dfc95ba061cd06e05c0262e@linux-foundation.org>
 <alpine.DEB.2.21.1807201300290.224013@chino.kir.corp.google.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <3238b5d2-fd89-a6be-0382-027a24a4d3ad@linux.alibaba.com>
Date: Fri, 20 Jul 2018 13:37:47 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1807201300290.224013@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: kirill@shutemov.name, hughd@google.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 7/20/18 1:02 PM, David Rientjes wrote:
> On Fri, 20 Jul 2018, Andrew Morton wrote:
>
>>> By digging into the original review, it looks use_zero_page sysfs knob
>>> was added to help ease-of-testing and give user a way to mitigate
>>> refcounting overhead.
>>>
>>> It has been a few years since the knob was added at the first place, I
>>> think we are confident that it is stable enough. And, since commit
>>> 6fcb52a56ff60 ("thp: reduce usage of huge zero page's atomic counter"),
>>> it looks refcounting overhead has been reduced significantly.
>>>
>>> Other than the above, the value of the knob is always 1 (enabled by
>>> default), I'm supposed very few people turn it off by default.
>>>
>>> So, it sounds not worth to still keep this knob around.
>> Probably OK.  Might not be OK, nobody knows.
>>
>> It's been there for seven years so another six months won't kill us.
>> How about as an intermediate step we add a printk("use_zero_page is
>> scheduled for removal.  Please contact linux-mm@kvack.org if you need
>> it").
>>
> We disable the huge zero page through this interface, there were issues
> related to the huge zero page shrinker (probably best to never free a
> per-node huge zero page after allocated) and CVE-2017-1000405 for huge
> dirty COW.

Thanks for the information. It looks the CVE has been resolved by commit 
a8f97366452ed491d13cf1e44241bc0b5740b1f0 ("mm, thp: Do not make page 
table dirty unconditionally in touch_p[mu]d()"), which is in 4.15 already.

What was the shrinker related issue? I'm supposed it has been resolved, 
right?
