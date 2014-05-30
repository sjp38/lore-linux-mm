Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f171.google.com (mail-vc0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id C41496B0035
	for <linux-mm@kvack.org>; Fri, 30 May 2014 10:46:36 -0400 (EDT)
Received: by mail-vc0-f171.google.com with SMTP id lc6so2198969vcb.2
        for <linux-mm@kvack.org>; Fri, 30 May 2014 07:46:36 -0700 (PDT)
Received: from qmta15.emeryville.ca.mail.comcast.net (qmta15.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:228])
        by mx.google.com with ESMTP id j8si3197143vek.54.2014.05.30.07.46.35
        for <linux-mm@kvack.org>;
        Fri, 30 May 2014 07:46:36 -0700 (PDT)
Date: Fri, 30 May 2014 09:46:33 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH -mm 4/8] slub: never fail kmem_cache_shrink
In-Reply-To: <ac8907cace921c3209aa821649349106f4f70b34.1401457502.git.vdavydov@parallels.com>
Message-ID: <alpine.DEB.2.10.1405300937560.11943@gentwo.org>
References: <cover.1401457502.git.vdavydov@parallels.com> <ac8907cace921c3209aa821649349106f4f70b34.1401457502.git.vdavydov@parallels.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 30 May 2014, Vladimir Davydov wrote:

> SLUB's kmem_cache_shrink not only removes empty slabs from the cache,
> but also sorts slabs by the number of objects in-use to cope with
> fragmentation. To achieve that, it tries to allocate a temporary array.
> If it fails, it will abort the whole procedure.

If we cannot allocate a kernel structure that is mostly less than a page
size then we have much more important things to worry about.

The maximum number of objects per slab is 512 on my system here.

> This is unacceptable for kmemcg, where we want to be sure that all empty
> slabs are removed from the cache on memcg offline, so let's just skip
> the de-fragmentation step if the allocation fails, but still get rid of
> empty slabs.

Lets just try the shrink and log the fact that it failed? Try again later?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
