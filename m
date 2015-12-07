Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f169.google.com (mail-io0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 4370A6B0257
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 09:57:54 -0500 (EST)
Received: by ioir85 with SMTP id r85so183284842ioi.1
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 06:57:54 -0800 (PST)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id p19si21988503igs.16.2015.12.07.06.57.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 07 Dec 2015 06:57:53 -0800 (PST)
Date: Mon, 7 Dec 2015 08:57:52 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 1/2] slab: implement bulk alloc in SLAB allocator
In-Reply-To: <20151207112057.1566dd5c@redhat.com>
Message-ID: <alpine.DEB.2.20.1512070856290.8762@east.gentwo.org>
References: <20151203155600.3589.86568.stgit@firesoul> <20151203155637.3589.62609.stgit@firesoul> <alpine.DEB.2.20.1512041106410.21819@east.gentwo.org> <20151207112057.1566dd5c@redhat.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov@virtuozzo.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, 7 Dec 2015, Jesper Dangaard Brouer wrote:

> A question: SLAB takes the "boot_cache" into account before calling
> should_failslab(), but SLUB does not.  Should we also do so for SLUB?

Not necessary in SLUB.

> Besides, maybe we can consolidate first loop and replace it with
> slab_post_alloc_hook()?

Ok.

> Or should we create trace calls that are specific to bulk'ing?
> (which would allow us to study/record bulk sizes)

I would prefer that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
