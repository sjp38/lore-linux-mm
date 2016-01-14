Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id 2D958828DF
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 11:21:55 -0500 (EST)
Received: by mail-ob0-f181.google.com with SMTP id is5so87165740obc.0
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 08:21:55 -0800 (PST)
Received: from mail-ob0-x244.google.com (mail-ob0-x244.google.com. [2607:f8b0:4003:c01::244])
        by mx.google.com with ESMTPS id p4si8262553oib.73.2016.01.14.08.21.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jan 2016 08:21:54 -0800 (PST)
Received: by mail-ob0-x244.google.com with SMTP id is5so8879996obc.3
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 08:21:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1601140924520.2145@east.gentwo.org>
References: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1452749069-15334-10-git-send-email-iamjoonsoo.kim@lge.com>
	<alpine.DEB.2.20.1601140924520.2145@east.gentwo.org>
Date: Fri, 15 Jan 2016 01:21:54 +0900
Message-ID: <CAAmzW4Mkpfc6_QO3qRqYZXEhAbZa3E2cXKivwyNmu0bm6kwhfQ@mail.gmail.com>
Subject: Re: [PATCH 09/16] mm/slab: put the freelist at the end of slab page
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

2016-01-15 0:26 GMT+09:00 Christoph Lameter <cl@linux.com>:
> On Thu, 14 Jan 2016, Joonsoo Kim wrote:
>
>> Currently, the freelist is at the front of slab page. This requires
>> extra space to meet object alignment requirement. If we put the freelist
>> at the end of slab page, object could start at page boundary and will
>> be at correct alignment. This is possible because freelist has
>> no alignment constraint itself.
>>
>> This gives us two benefits. It removes extra memory space
>> for the freelist alignment and remove complex calculation
>> at cache initialization step. I can't think notable drawback here.
>
>
> The third one is that the padding space at the end of the slab could
> actually be used for the freelist if it fits.

Yes.

> The drawback may be that the location of the freelist at the beginning of
> the page is more cache effective because the cache prefetcher may be able
> to get the following cachelines and effectively hit the first object.
> However, this is rather dubious speculation.

I think so, too. :)
If then, could you give me an ack?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
