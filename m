Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id DF01A6B0032
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 15:28:35 -0500 (EST)
Received: by mail-ig0-f182.google.com with SMTP id r10so736597igi.3
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 12:28:35 -0800 (PST)
Received: from resqmta-po-01v.sys.comcast.net (resqmta-po-01v.sys.comcast.net. [2001:558:fe16:19:96:114:154:160])
        by mx.google.com with ESMTPS id o129si2904061ioo.14.2015.01.26.12.28.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 26 Jan 2015 12:28:35 -0800 (PST)
Date: Mon, 26 Jan 2015 14:28:33 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -mm 2/3] slab: zap kmem_cache_shrink return value
In-Reply-To: <20150126201602.GA3317@esperanza>
Message-ID: <alpine.DEB.2.11.1501261427310.17468@gentwo.org>
References: <cover.1422275084.git.vdavydov@parallels.com> <b89d28384f8ec7865c3fefc2f025955d55798b78.1422275084.git.vdavydov@parallels.com> <alpine.DEB.2.11.1501260949150.15849@gentwo.org> <20150126170418.GC28978@esperanza> <alpine.DEB.2.11.1501261226250.16638@gentwo.org>
 <20150126194838.GB2660@esperanza> <alpine.DEB.2.11.1501261353480.16786@gentwo.org> <20150126201602.GA3317@esperanza>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 26 Jan 2015, Vladimir Davydov wrote:

> Right, but I just don't see why a subsystem using a kmem_cache would
> need to check whether there are any objects left in the cache. I mean,
> it should somehow keep track of the objects it's allocated anyway, e.g.
> by linking them in a list. That means it must already have a way to
> check if it is safe to destroy its cache or not.

The acpi subsystem did that at some point.

> Suppose we leave the return value as is. A subsystem, right before going
> to destroy a cache, calls kmem_cache_shrink, which returns 1 (slab is
> not empty). What is it supposed to do then?

That is up to the subsystem. If it has a means of tracking down the
missing object then it can deal with it. If not then it cannot shutdown
the cache and do a proper recovery action.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
