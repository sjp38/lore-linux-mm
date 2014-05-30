Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f179.google.com (mail-vc0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id D59906B0035
	for <linux-mm@kvack.org>; Fri, 30 May 2014 10:49:58 -0400 (EDT)
Received: by mail-vc0-f179.google.com with SMTP id im17so2217067vcb.10
        for <linux-mm@kvack.org>; Fri, 30 May 2014 07:49:58 -0700 (PDT)
Received: from qmta12.emeryville.ca.mail.comcast.net (qmta12.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:227])
        by mx.google.com with ESMTP id j8si3201471vcr.60.2014.05.30.07.49.58
        for <linux-mm@kvack.org>;
        Fri, 30 May 2014 07:49:58 -0700 (PDT)
Date: Fri, 30 May 2014 09:49:55 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH -mm 5/8] slab: remove kmem_cache_shrink retval
In-Reply-To: <d2bbd28ae0f0c1807f9fe72d0443eccb739b8aa6.1401457502.git.vdavydov@parallels.com>
Message-ID: <alpine.DEB.2.10.1405300947170.11943@gentwo.org>
References: <cover.1401457502.git.vdavydov@parallels.com> <d2bbd28ae0f0c1807f9fe72d0443eccb739b8aa6.1401457502.git.vdavydov@parallels.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 30 May 2014, Vladimir Davydov wrote:

> First, nobody uses it. Second, it differs across the implementations:
> for SLUB it always returns 0, for SLAB it returns 0 if the cache appears
> to be empty. So let's get rid of it.

Well slub returns an error code if it fails. I am all in favor of making
it consistent. The indication in SLAB that the slab is empty may be
useful. May return error code or the number of slab pages in use?

Some of the code that is shared by the allocators here could be moved into
mm/slab_common.c. Put kmem_cache_shrink there and then have
__kmem_cache_shrink to the allocator specific things?
x

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
