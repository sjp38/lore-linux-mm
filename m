Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id CF5F36B0038
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 11:31:45 -0500 (EST)
Received: by mail-qc0-f174.google.com with SMTP id s11so17208630qcv.5
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 08:31:45 -0800 (PST)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id s4si1674937qat.58.2015.01.28.08.31.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 28 Jan 2015 08:31:45 -0800 (PST)
Date: Wed, 28 Jan 2015 10:31:43 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -mm v2 1/3] slub: never fail to shrink cache
In-Reply-To: <012683fc3a0f9fb20a288986fd63fe9f6d25e8ee.1422461573.git.vdavydov@parallels.com>
Message-ID: <alpine.DEB.2.11.1501281031190.32147@gentwo.org>
References: <cover.1422461573.git.vdavydov@parallels.com> <012683fc3a0f9fb20a288986fd63fe9f6d25e8ee.1422461573.git.vdavydov@parallels.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 28 Jan 2015, Vladimir Davydov wrote:

> This patch therefore makes __kmem_cache_shrink() allocate the array on
> stack instead of calling kmalloc, which may fail. The array size is
> chosen to be equal to 32, because most SLUB caches store not more than
> 32 objects per slab page. Slab pages with <= 32 free objects are sorted
> using the array by the number of objects in use and promoted to the head
> of the partial list, while slab pages with > 32 free objects are left in
> the end of the list without any ordering imposed on them.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
