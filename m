Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 4CC046B0257
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 10:15:52 -0500 (EST)
Received: by mail-ig0-f170.google.com with SMTP id mv3so19693939igc.0
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 07:15:52 -0800 (PST)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id v76si20745605ioi.35.2015.12.10.07.15.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 10 Dec 2015 07:15:51 -0800 (PST)
Date: Thu, 10 Dec 2015 09:15:50 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH V2 8/9] slab: implement bulk free in SLAB allocator
In-Reply-To: <20151209215058.0ef5964a@redhat.com>
Message-ID: <alpine.DEB.2.20.1512100914580.15342@east.gentwo.org>
References: <20151208161751.21945.53936.stgit@firesoul> <20151208161903.21945.33876.stgit@firesoul> <alpine.DEB.2.20.1512090945570.30894@east.gentwo.org> <20151209195325.68eaf314@redhat.com> <alpine.DEB.2.20.1512091338240.7552@east.gentwo.org>
 <20151209215058.0ef5964a@redhat.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov@virtuozzo.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>

On Wed, 9 Dec 2015, Jesper Dangaard Brouer wrote:

> True. I was just so close submitting the network use-case to DaveM.
> Guess, that will have to wait if we choose this API change (and
> I'll have to wait another 3 month before the trees are in sync again).

why? Andrew can push that to next pretty soon and DaveM could carry that
patch too.

> > Then we need df.slab_cache or something.
>
> What about df.page->slab_cache (?)

Fine come up with a patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
