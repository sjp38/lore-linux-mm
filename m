Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 7606E6B0032
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 14:48:51 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id ft15so13784986pdb.5
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 11:48:51 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id nu5si13292188pbc.197.2015.01.26.11.48.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jan 2015 11:48:50 -0800 (PST)
Date: Mon, 26 Jan 2015 22:48:38 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm 2/3] slab: zap kmem_cache_shrink return value
Message-ID: <20150126194838.GB2660@esperanza>
References: <cover.1422275084.git.vdavydov@parallels.com>
 <b89d28384f8ec7865c3fefc2f025955d55798b78.1422275084.git.vdavydov@parallels.com>
 <alpine.DEB.2.11.1501260949150.15849@gentwo.org>
 <20150126170418.GC28978@esperanza>
 <alpine.DEB.2.11.1501261226250.16638@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1501261226250.16638@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jan 26, 2015 at 12:26:57PM -0600, Christoph Lameter wrote:
> On Mon, 26 Jan 2015, Vladimir Davydov wrote:
> 
> > __cache_shrink() is used not only in __kmem_cache_shrink(), but also in
> > SLAB's __kmem_cache_shutdown(), where we do need its return value to
> > check if the cache is empty.
> 
> It could be useful to know if a slab is empty. So maybe leave
> kmem_cache_shrink the way it is and instead fix up slub to return the
> proper value?

Hmm, why? The return value has existed since this function was
introduced, but nobody seems to have ever used it outside the slab core.
Besides, this check is racy, so IMO we shouldn't encourage users of the
API to rely on it. That said, I believe we should drop the return value
for now. If anybody ever needs it, we can reintroduce it.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
