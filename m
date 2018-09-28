Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8C20F8E0001
	for <linux-mm@kvack.org>; Fri, 28 Sep 2018 04:06:55 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id t36-v6so1271283oti.12
        for <linux-mm@kvack.org>; Fri, 28 Sep 2018 01:06:55 -0700 (PDT)
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id n13-v6si2468952ota.180.2018.09.28.01.06.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Sep 2018 01:06:54 -0700 (PDT)
Message-ID: <5BADE115.7020701@huawei.com>
Date: Fri, 28 Sep 2018 16:06:45 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [STABLE PATCH] slub: make ->cpu_partial unsigned int
References: <1538059420-14439-1-git-send-email-zhongjiang@huawei.com> <20180927154647.GB31654@kroah.com>
In-Reply-To: <20180927154647.GB31654@kroah.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linux-foundation.org>
Cc: iamjoonsoo.kim@lge.com, rientjes@google.com, cl@linux.com, penberg@kernel.org, akpm@linux-foundation.org, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On 2018/9/27 23:46, Greg KH wrote:
> On Thu, Sep 27, 2018 at 10:43:40PM +0800, zhong jiang wrote:
>> From: Alexey Dobriyan <adobriyan@gmail.com>
>>
>>         /*
>>          * cpu_partial determined the maximum number of objects
>>          * kept in the per cpu partial lists of a processor.
>>          */
>>
>> Can't be negative.
>>
>> I hit a real issue that it will result in a large number of memory leak.
>> Because Freeing slabs are in interrupt context. So it can trigger this issue.
>> put_cpu_partial can be interrupted more than once.
>> due to a union struct of lru and pobjects in struct page, when other core handles
>> page->lru list, for eaxmple, remove_partial in freeing slab code flow, It will
>> result in pobjects being a negative value(0xdead0000). Therefore, a large number
>> of slabs will be added to per_cpu partial list.
>>
>> I had posted the issue to community before. The detailed issue description is as follows.
>>
>> Link: https://www.spinics.net/lists/kernel/msg2870979.html
>>
>> After applying the patch, The issue is fixed. So the patch is a effective bugfix.
>> It should go into stable.
> <formletter>
>
> This is not the correct way to submit patches for inclusion in the
> stable kernel tree.  Please read:
>     https://www.kernel.org/doc/html/latest/process/stable-kernel-rules.html
> for how to do this properly.
>
> </formletter>
Will resend with proper format.

Thanks,
zhong jiang
