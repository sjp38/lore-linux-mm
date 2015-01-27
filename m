Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f175.google.com (mail-ie0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 386F56B0071
	for <linux-mm@kvack.org>; Tue, 27 Jan 2015 12:02:14 -0500 (EST)
Received: by mail-ie0-f175.google.com with SMTP id ar1so16400799iec.6
        for <linux-mm@kvack.org>; Tue, 27 Jan 2015 09:02:14 -0800 (PST)
Received: from resqmta-po-07v.sys.comcast.net (resqmta-po-07v.sys.comcast.net. [2001:558:fe16:19:96:114:154:166])
        by mx.google.com with ESMTPS id f12si1537518icc.87.2015.01.27.09.02.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 27 Jan 2015 09:02:13 -0800 (PST)
Date: Tue, 27 Jan 2015 11:02:12 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -mm 1/3] slub: don't fail kmem_cache_shrink if slab
 placement optimization fails
In-Reply-To: <20150127125838.GD5165@esperanza>
Message-ID: <alpine.DEB.2.11.1501271100520.25124@gentwo.org>
References: <cover.1422275084.git.vdavydov@parallels.com> <3804a429071f939e6b4f654b6c6426c1fdd95f7e.1422275084.git.vdavydov@parallels.com> <alpine.DEB.2.11.1501260944550.15849@gentwo.org> <20150126170147.GB28978@esperanza> <alpine.DEB.2.11.1501261216120.16638@gentwo.org>
 <20150126193629.GA2660@esperanza> <alpine.DEB.2.11.1501261353020.16786@gentwo.org> <20150127125838.GD5165@esperanza>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 27 Jan 2015, Vladimir Davydov wrote:

> May be, we could remove this allocation at all then? I mean, always
> distribute slabs among constant number of buckets, say 32, like this:

The point of the sorting is to have the slab pages that only have a few
objects available at the beginning of the list. Allocations can then
easily reduce the size of hte partial page list.

What you could do is simply put all slab pages with more than 32 objects
available at the end of the list.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
