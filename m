Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id 0D0D86B00F0
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 06:03:34 -0400 (EDT)
Received: by mail-lb0-f175.google.com with SMTP id l4so3745485lbv.20
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 03:03:33 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ti10si41623708lbb.52.2014.06.10.03.03.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jun 2014 03:03:32 -0700 (PDT)
Date: Tue, 10 Jun 2014 14:03:15 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm v2 8/8] slab: make dead memcg caches discard free
 slabs immediately
Message-ID: <20140610100313.GA6293@esperanza>
References: <cover.1402060096.git.vdavydov@parallels.com>
 <27a202c6084d6bb19cc3e417793f05104b908ded.1402060096.git.vdavydov@parallels.com>
 <20140610074317.GE19036@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20140610074317.GE19036@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: akpm@linux-foundation.org, cl@linux.com, rientjes@google.com, penberg@kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi,

On Tue, Jun 10, 2014 at 04:43:17PM +0900, Joonsoo Kim wrote:
> You mentioned that disabling per cpu arrays would degrade performance.
> But, this patch is implemented to disable per cpu arrays. Is there any
> reason to do like this? How about not disabling per cpu arrays and
> others? Leaving it as is makes the patch less intrusive and has low
> impact on performance. I guess that amount of reclaimed memory has no
> big difference between both approaches.

Frankly, I incline to shrinking dead SLAB caches periodically from
cache_reap too, because it looks neater and less intrusive to me. Also
it has zero performance impact, which is nice.

However, Christoph proposed to disable per cpu arrays for dead caches,
similarly to SLUB, and I decided to give it a try, just to see the end
code we'd have with it.

I'm still not quite sure which way we should choose though...

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
