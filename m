Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f170.google.com (mail-lb0-f170.google.com [209.85.217.170])
	by kanga.kvack.org (Postfix) with ESMTP id 015C16B0031
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 15:01:15 -0400 (EDT)
Received: by mail-lb0-f170.google.com with SMTP id w7so3731879lbi.1
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 12:01:15 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id rd10si268239lbb.23.2014.06.03.12.01.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jun 2014 12:01:14 -0700 (PDT)
Date: Tue, 3 Jun 2014 23:00:59 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm 5/8] slab: remove kmem_cache_shrink retval
Message-ID: <20140603190056.GD6013@esperanza>
References: <cover.1401457502.git.vdavydov@parallels.com>
 <d2bbd28ae0f0c1807f9fe72d0443eccb739b8aa6.1401457502.git.vdavydov@parallels.com>
 <alpine.DEB.2.10.1405300947170.11943@gentwo.org>
 <20140531102740.GB25076@esperanza>
 <alpine.DEB.2.10.1406021014140.2987@gentwo.org>
 <20140603090623.GC6013@esperanza>
 <alpine.DEB.2.10.1406030948310.13291@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1406030948310.13291@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jun 03, 2014 at 09:48:51AM -0500, Christoph Lameter wrote:
> On Tue, 3 Jun 2014, Vladimir Davydov wrote:
> 
> > Still, I really want to evict all empty slabs from cache on memcg
> > offline for sure. Handling failures there means introducing a worker
> > that will retry shrinking, but that seems to me as an unnecessary
> > complication, because there's nothing that can prevent us from shrinking
> > empty slabs from the cache, even if we merge slab defragmentation, isn't
> > it?
> >
> > May be, it's worth introducing a special function, say kmem_cache_zap(),
> > that will only evict empty slabs from the cache, plus disable empty
> > slabs caching? This function would be called only from memcg offline for
> > dead memcg caches.
> 
> I am fine with the lower impact version that you came up with later.

Oh, I missed a couple of your previous e-mails, because our mail server
marked them (along with a hundred or so another messages :-) ) as junk
for some reason. Going to turn off the filter completely.

Sorry for being inconsistent and thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
