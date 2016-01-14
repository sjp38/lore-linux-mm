Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id BD3D0828DF
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 11:24:08 -0500 (EST)
Received: by mail-ob0-f172.google.com with SMTP id ba1so497434550obb.3
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 08:24:08 -0800 (PST)
Received: from mail-oi0-x243.google.com (mail-oi0-x243.google.com. [2607:f8b0:4003:c06::243])
        by mx.google.com with ESMTPS id h188si8301308oia.5.2016.01.14.08.24.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jan 2016 08:24:08 -0800 (PST)
Received: by mail-oi0-x243.google.com with SMTP id x140so7822505oif.1
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 08:24:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1601140929280.2145@east.gentwo.org>
References: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1452749069-15334-17-git-send-email-iamjoonsoo.kim@lge.com>
	<alpine.DEB.2.20.1601140929280.2145@east.gentwo.org>
Date: Fri, 15 Jan 2016 01:24:08 +0900
Message-ID: <CAAmzW4NijZF7m-ivOPjmRZxSCukHET78SM5Qpvb6Y56atoZ-yQ@mail.gmail.com>
Subject: Re: [PATCH 16/16] mm/slab: introduce new slab management type, OBJFREELIST_SLAB
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

2016-01-15 0:32 GMT+09:00 Christoph Lameter <cl@linux.com>:
> On Thu, 14 Jan 2016, Joonsoo Kim wrote:
>
>> SLAB needs a array to manage freed objects in a slab. It is only used
>> if some objects are freed so we can use free object itself as this array.
>> This requires additional branch in somewhat critical lock path to check
>> if it is first freed object or not but that's all we need. Benefits is
>> that we can save extra memory usage and reduce some computational
>> overhead by allocating a management array when new slab is created.
>
> Hmmm... But then you need to have an offset in the page struct to
> figure out where the freelist starts. One additional level of indirection.
> Seems to have some negative impact on performance.

SLAB already keeps the pointer where the freelist starts in the page struct.
So, there is no *additional* negative impact on performance.

>> In my system, without enabling CONFIG_DEBUG_SLAB, Almost caches become
>> OBJFREELIST_SLAB and NORMAL_SLAB (using leftover) which doesn't waste
>> memory. Following is the result of number of caches with specific slab
>> management type.
>
> Sounds good.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
