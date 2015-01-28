Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id 51DF86B0038
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 14:19:58 -0500 (EST)
Received: by mail-qc0-f181.google.com with SMTP id l6so17939088qcy.12
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 11:19:58 -0800 (PST)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id d7si6367256qcq.47.2015.01.28.11.19.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 28 Jan 2015 11:19:57 -0800 (PST)
Date: Wed, 28 Jan 2015 13:19:54 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -mm v2 2/3] slub: fix kmem_cache_shrink return value
In-Reply-To: <20150128174639.GB16011@esperanza>
Message-ID: <alpine.DEB.2.11.1501281319350.32767@gentwo.org>
References: <cover.1422461573.git.vdavydov@parallels.com> <7ee54d0d26f6c61e2ecf50300ee955610749b344.1422461573.git.vdavydov@parallels.com> <alpine.DEB.2.11.1501281032220.32147@gentwo.org> <20150128174639.GB16011@esperanza>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 28 Jan 2015, Vladimir Davydov wrote:

> Yeah, right. In addition to that I misplaced the check - it should go
> after discard_slab, where we decrement nr_slabs. Here goes the updated
> patch:
>
> From: Vladimir Davydov <vdavydov@parallels.com>
> Subject: [PATCH] slub: fix kmem_cache_shrink return value
>
> It is supposed to return 0 if the cache has no remaining objects and 1
> otherwise, while currently it always returns 0. Fix it.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
