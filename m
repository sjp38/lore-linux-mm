Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f170.google.com (mail-ie0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 16CE36B0032
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 14:53:35 -0500 (EST)
Received: by mail-ie0-f170.google.com with SMTP id y20so10929383ier.1
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 11:53:34 -0800 (PST)
Received: from resqmta-po-06v.sys.comcast.net (resqmta-po-06v.sys.comcast.net. [2001:558:fe16:19:96:114:154:165])
        by mx.google.com with ESMTPS id t5si7876025igm.14.2015.01.26.11.53.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 26 Jan 2015 11:53:34 -0800 (PST)
Date: Mon, 26 Jan 2015 13:53:32 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -mm 1/3] slub: don't fail kmem_cache_shrink if slab
 placement optimization fails
In-Reply-To: <20150126193629.GA2660@esperanza>
Message-ID: <alpine.DEB.2.11.1501261353020.16786@gentwo.org>
References: <cover.1422275084.git.vdavydov@parallels.com> <3804a429071f939e6b4f654b6c6426c1fdd95f7e.1422275084.git.vdavydov@parallels.com> <alpine.DEB.2.11.1501260944550.15849@gentwo.org> <20150126170147.GB28978@esperanza> <alpine.DEB.2.11.1501261216120.16638@gentwo.org>
 <20150126193629.GA2660@esperanza>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 26 Jan 2015, Vladimir Davydov wrote:

> We could do that, but IMO that would only complicate the code w/o
> yielding any real benefits. This function is slow and called rarely
> anyway, so I don't think there is any point to optimize out a page
> allocation here.

I think you already have the code there. Simply allow the sizeing of the
empty_page[] array. And rename it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
