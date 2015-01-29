Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 1BB716B0078
	for <linux-mm@kvack.org>; Thu, 29 Jan 2015 10:56:01 -0500 (EST)
Received: by mail-qg0-f47.google.com with SMTP id z60so29981949qgd.6
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 07:56:01 -0800 (PST)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id c10si10671899qag.8.2015.01.29.07.55.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 29 Jan 2015 07:55:59 -0800 (PST)
Date: Thu, 29 Jan 2015 09:55:56 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -mm v2 1/3] slub: never fail to shrink cache
In-Reply-To: <20150129080726.GB11463@esperanza>
Message-ID: <alpine.DEB.2.11.1501290954230.7725@gentwo.org>
References: <cover.1422461573.git.vdavydov@parallels.com> <012683fc3a0f9fb20a288986fd63fe9f6d25e8ee.1422461573.git.vdavydov@parallels.com> <20150128135752.afcb196d6ded7c16a79ed6fd@linux-foundation.org> <20150129080726.GB11463@esperanza>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 29 Jan 2015, Vladimir Davydov wrote:

> Come to think of it, do we really need to optimize slab placement in
> kmem_cache_shrink? None of its users except shrink_store expects it -
> they just want to purge the cache before destruction, that's it. May be,
> we'd better move slab placement optimization to a separate SLUB's
> private function that would be called only by shrink_store, where we can
> put up with kmalloc failures? Christoph, what do you think?

The slabinfo tool invokes kmem_cache_shrink to optimize placement.

Run

	slabinfo -s

which can then be used to reduce the fragmentation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
