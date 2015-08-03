Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 30D819003C9
	for <linux-mm@kvack.org>; Sun,  2 Aug 2015 22:11:04 -0400 (EDT)
Received: by igbpg9 with SMTP id pg9so47276934igb.0
        for <linux-mm@kvack.org>; Sun, 02 Aug 2015 19:11:04 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id b7si4669572igf.27.2015.08.02.19.11.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 02 Aug 2015 19:11:03 -0700 (PDT)
Message-ID: <55BECC85.7050206@huawei.com>
Date: Mon, 3 Aug 2015 10:05:57 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add the block to the tail of the list in expand()
References: <55BB4027.7080200@huawei.com> <55BC0392.2070205@intel.com>
In-Reply-To: <55BC0392.2070205@intel.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, iamjoonsoo.kim@lge.com, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2015/8/1 7:24, Dave Hansen wrote:

> On 07/31/2015 02:30 AM, Xishi Qiu wrote:
>> __free_one_page() will judge whether the the next-highest order is free,
>> then add the block to the tail or not. So when we split large order block, 
>> add the small block to the tail, it will reduce fragment.
> 
> It's an interesting idea, but what does it do in practice?  Can you
> measure a decrease in fragmentation?
> 
> Further, the comment above the function says:
>  * The order of subdivision here is critical for the IO subsystem.
>  * Please do not alter this order without good reasons and regression
>  * testing.
> 
> Has there been regression testing?
> 
> Also, this might not do very much good in practice.  If you are
> splitting a high-order page, you are doing the split because the
> lower-order lists are empty.  So won't that list_add() be to an empty

Hi Dave,

I made a mistake, you are right, all the lower-order lists are empty,
so it is no sense to add to the tail.

Thanks,
Xishi Qiu

> list most of the time?  Or does the __rmqueue_fallback()
> largest->smallest logic dominate?
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
