Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f41.google.com (mail-qa0-f41.google.com [209.85.216.41])
	by kanga.kvack.org (Postfix) with ESMTP id 5CDF56B0032
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 13:27:01 -0500 (EST)
Received: by mail-qa0-f41.google.com with SMTP id bm13so8013939qab.0
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 10:27:00 -0800 (PST)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id j7si14159591qaf.48.2015.01.26.10.26.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 26 Jan 2015 10:26:59 -0800 (PST)
Date: Mon, 26 Jan 2015 12:26:57 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -mm 2/3] slab: zap kmem_cache_shrink return value
In-Reply-To: <20150126170418.GC28978@esperanza>
Message-ID: <alpine.DEB.2.11.1501261226250.16638@gentwo.org>
References: <cover.1422275084.git.vdavydov@parallels.com> <b89d28384f8ec7865c3fefc2f025955d55798b78.1422275084.git.vdavydov@parallels.com> <alpine.DEB.2.11.1501260949150.15849@gentwo.org> <20150126170418.GC28978@esperanza>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 26 Jan 2015, Vladimir Davydov wrote:

> __cache_shrink() is used not only in __kmem_cache_shrink(), but also in
> SLAB's __kmem_cache_shutdown(), where we do need its return value to
> check if the cache is empty.

It could be useful to know if a slab is empty. So maybe leave
kmem_cache_shrink the way it is and instead fix up slub to return the
proper value?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
