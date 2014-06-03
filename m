Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id B42306B0031
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 10:48:54 -0400 (EDT)
Received: by mail-qg0-f48.google.com with SMTP id i50so13255239qgf.7
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 07:48:54 -0700 (PDT)
Received: from qmta13.emeryville.ca.mail.comcast.net (qmta13.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:243])
        by mx.google.com with ESMTP id q65si22437543qga.96.2014.06.03.07.48.53
        for <linux-mm@kvack.org>;
        Tue, 03 Jun 2014 07:48:54 -0700 (PDT)
Date: Tue, 3 Jun 2014 09:48:51 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH -mm 5/8] slab: remove kmem_cache_shrink retval
In-Reply-To: <20140603090623.GC6013@esperanza>
Message-ID: <alpine.DEB.2.10.1406030948310.13291@gentwo.org>
References: <cover.1401457502.git.vdavydov@parallels.com> <d2bbd28ae0f0c1807f9fe72d0443eccb739b8aa6.1401457502.git.vdavydov@parallels.com> <alpine.DEB.2.10.1405300947170.11943@gentwo.org> <20140531102740.GB25076@esperanza> <alpine.DEB.2.10.1406021014140.2987@gentwo.org>
 <20140603090623.GC6013@esperanza>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 3 Jun 2014, Vladimir Davydov wrote:

> Still, I really want to evict all empty slabs from cache on memcg
> offline for sure. Handling failures there means introducing a worker
> that will retry shrinking, but that seems to me as an unnecessary
> complication, because there's nothing that can prevent us from shrinking
> empty slabs from the cache, even if we merge slab defragmentation, isn't
> it?
>
> May be, it's worth introducing a special function, say kmem_cache_zap(),
> that will only evict empty slabs from the cache, plus disable empty
> slabs caching? This function would be called only from memcg offline for
> dead memcg caches.

I am fine with the lower impact version that you came up with later.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
