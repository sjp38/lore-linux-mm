Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f175.google.com (mail-ie0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 13AED6B0038
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 11:37:12 -0500 (EST)
Received: by mail-ie0-f175.google.com with SMTP id ar1so22887765iec.6
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 08:37:11 -0800 (PST)
Received: from resqmta-po-05v.sys.comcast.net (resqmta-po-05v.sys.comcast.net. [2001:558:fe16:19:96:114:154:164])
        by mx.google.com with ESMTPS id l27si3801809iod.86.2015.01.28.08.37.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 28 Jan 2015 08:37:11 -0800 (PST)
Date: Wed, 28 Jan 2015 10:37:09 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -mm v2 1/3] slub: never fail to shrink cache
In-Reply-To: <012683fc3a0f9fb20a288986fd63fe9f6d25e8ee.1422461573.git.vdavydov@parallels.com>
Message-ID: <alpine.DEB.2.11.1501281034290.32147@gentwo.org>
References: <cover.1422461573.git.vdavydov@parallels.com> <012683fc3a0f9fb20a288986fd63fe9f6d25e8ee.1422461573.git.vdavydov@parallels.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 28 Jan 2015, Vladimir Davydov wrote:

> +			/* We do not keep full slabs on the list */
> +			BUG_ON(free <= 0);

Well sorry we do actually keep a number of empty slabs on the partial
lists. See the min_partial field in struct kmem_cache.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
