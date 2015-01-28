Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id E93076B0038
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 12:32:35 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id et14so27765397pad.4
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 09:32:35 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id oc3si6564632pbb.130.2015.01.28.09.32.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Jan 2015 09:32:35 -0800 (PST)
Date: Wed, 28 Jan 2015 20:32:21 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm v2 1/3] slub: never fail to shrink cache
Message-ID: <20150128173221.GA16011@esperanza>
References: <cover.1422461573.git.vdavydov@parallels.com>
 <012683fc3a0f9fb20a288986fd63fe9f6d25e8ee.1422461573.git.vdavydov@parallels.com>
 <alpine.DEB.2.11.1501281034290.32147@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1501281034290.32147@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jan 28, 2015 at 10:37:09AM -0600, Christoph Lameter wrote:
> On Wed, 28 Jan 2015, Vladimir Davydov wrote:
> 
> > +			/* We do not keep full slabs on the list */
> > +			BUG_ON(free <= 0);
> 
> Well sorry we do actually keep a number of empty slabs on the partial
> lists. See the min_partial field in struct kmem_cache.

It's not about empty slabs, it's about full slabs: free == 0 means slab
is full.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
