Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f176.google.com (mail-ie0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id 9D3BC6B0082
	for <linux-mm@kvack.org>; Thu, 29 Jan 2015 11:22:19 -0500 (EST)
Received: by mail-ie0-f176.google.com with SMTP id rd18so35421714iec.7
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 08:22:19 -0800 (PST)
Received: from resqmta-po-06v.sys.comcast.net (resqmta-po-06v.sys.comcast.net. [2001:558:fe16:19:96:114:154:165])
        by mx.google.com with ESMTPS id e4si1556567igg.22.2015.01.29.08.22.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 29 Jan 2015 08:22:18 -0800 (PST)
Date: Thu, 29 Jan 2015 10:22:16 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -mm v2 1/3] slub: never fail to shrink cache
In-Reply-To: <20150129161739.GE11463@esperanza>
Message-ID: <alpine.DEB.2.11.1501291021370.7986@gentwo.org>
References: <cover.1422461573.git.vdavydov@parallels.com> <012683fc3a0f9fb20a288986fd63fe9f6d25e8ee.1422461573.git.vdavydov@parallels.com> <20150128135752.afcb196d6ded7c16a79ed6fd@linux-foundation.org> <20150129080726.GB11463@esperanza>
 <alpine.DEB.2.11.1501290954230.7725@gentwo.org> <20150129161739.GE11463@esperanza>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 29 Jan 2015, Vladimir Davydov wrote:

> Yeah, but the tool just writes 1 to /sys/kernel/slab/cache/shrink, i.e.
> invokes shrink_store(), and I don't propose to remove slab placement
> optimization from there. What I propose is to move slab placement
> optimization from kmem_cache_shrink() to shrink_store(), because other
> users of kmem_cache_shrink() don't seem to need it at all - they just
> want to release empty slabs. Such a change wouldn't affect the behavior
> of `slabinfo -s` at all.

Well we have to go through the chain of partial slabs anyways so its easy
to do the optimization at that point.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
