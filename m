Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f177.google.com (mail-io0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id 8953C828DF
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 10:32:21 -0500 (EST)
Received: by mail-io0-f177.google.com with SMTP id 1so409369387ion.1
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 07:32:21 -0800 (PST)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id c1si9465208igx.104.2016.01.14.07.32.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 14 Jan 2016 07:32:20 -0800 (PST)
Date: Thu, 14 Jan 2016 09:32:19 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 16/16] mm/slab: introduce new slab management type,
 OBJFREELIST_SLAB
In-Reply-To: <1452749069-15334-17-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.20.1601140929280.2145@east.gentwo.org>
References: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com> <1452749069-15334-17-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 14 Jan 2016, Joonsoo Kim wrote:

> SLAB needs a array to manage freed objects in a slab. It is only used
> if some objects are freed so we can use free object itself as this array.
> This requires additional branch in somewhat critical lock path to check
> if it is first freed object or not but that's all we need. Benefits is
> that we can save extra memory usage and reduce some computational
> overhead by allocating a management array when new slab is created.

Hmmm... But then you need to have an offset in the page struct to
figure out where the freelist starts. One additional level of indirection.
Seems to have some negative impact on performance.

> In my system, without enabling CONFIG_DEBUG_SLAB, Almost caches become
> OBJFREELIST_SLAB and NORMAL_SLAB (using leftover) which doesn't waste
> memory. Following is the result of number of caches with specific slab
> management type.

Sounds good.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
