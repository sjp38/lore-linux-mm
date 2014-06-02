Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id A77286B0031
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 08:10:50 -0400 (EDT)
Received: by mail-la0-f53.google.com with SMTP id ty20so2476321lab.26
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 05:10:49 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id d4si15986036laa.81.2014.06.02.05.10.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jun 2014 05:10:48 -0700 (PDT)
Date: Mon, 2 Jun 2014 16:10:36 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm 8/8] slab: reap dead memcg caches aggressively
Message-ID: <20140602121034.GB1039@esperanza>
References: <cover.1401457502.git.vdavydov@parallels.com>
 <23a736c90a81e13a2252d35d9fc3dc04a9ed7d7c.1401457502.git.vdavydov@parallels.com>
 <20140602044154.GB17964@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20140602044154.GB17964@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: akpm@linux-foundation.org, cl@linux.com, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jun 02, 2014 at 01:41:55PM +0900, Joonsoo Kim wrote:
> According to my code reading, slabs_to_free() doesn't return number of
> free slabs. This bug is introduced by 0fa8103b. I think that it is
> better to fix it before applyting this patch. Otherwise, use n->free_objects
> instead of slabs_tofree() to achieve your purpose correctly.

Hmm, I don't think slab_tofree() computes the number of free slabs
wrong. If we have N free objects, there may be
DIV_ROUND_UP(N,objs_per_slab) empty slabs at max, and that's exactly
what slab_tofree() does, no?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
