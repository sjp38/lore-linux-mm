Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 817B66B0265
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 04:06:26 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id r71so346559563ioi.3
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 01:06:26 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTP id g29si13135273ote.208.2016.07.18.01.06.19
        for <linux-mm@kvack.org>;
        Mon, 18 Jul 2016 01:06:25 -0700 (PDT)
Message-ID: <578C8C8A.8000007@huawei.com>
Date: Mon, 18 Jul 2016 16:00:10 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mem-hotplug: use GFP_HIGHUSER_MOVABLE in, alloc_migrate_target()
References: <57884EAA.9030603@huawei.com> <20160718055150.GF9460@js1304-P5Q-DELUXE>
In-Reply-To: <20160718055150.GF9460@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Naoya
 Horiguchi <n-horiguchi@ah.jp.nec.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2016/7/18 13:51, Joonsoo Kim wrote:

> On Fri, Jul 15, 2016 at 10:47:06AM +0800, Xishi Qiu wrote:
>> alloc_migrate_target() is called from migrate_pages(), and the page
>> is always from user space, so we can add __GFP_HIGHMEM directly.
> 
> No, all migratable pages are not from user space. For example,
> blockdev file cache has __GFP_MOVABLE and migratable but it has no
> __GFP_HIGHMEM and __GFP_USER.
> 

Hi Joonsoo,

So the original code "gfp_t gfp_mask = GFP_USER | __GFP_MOVABLE;"
is not correct?

> And, zram's memory isn't GFP_HIGHUSER_MOVABLE but has __GFP_MOVABLE.
> 

Can we distinguish __GFP_MOVABLE or GFP_HIGHUSER_MOVABLE when doing
mem-hotplug?

Thanks,
Xishi Qiu

> Thanks.
> 
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
