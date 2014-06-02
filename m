Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f179.google.com (mail-vc0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id 88EDF6B0031
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 10:01:56 -0400 (EDT)
Received: by mail-vc0-f179.google.com with SMTP id ij19so661633vcb.10
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 07:01:56 -0700 (PDT)
Received: from mail-vc0-x234.google.com (mail-vc0-x234.google.com [2607:f8b0:400c:c03::234])
        by mx.google.com with ESMTPS id ej4si7894883vdb.27.2014.06.02.07.01.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Jun 2014 07:01:55 -0700 (PDT)
Received: by mail-vc0-f180.google.com with SMTP id hq11so3129436vcb.39
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 07:01:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140602121034.GB1039@esperanza>
References: <cover.1401457502.git.vdavydov@parallels.com>
	<23a736c90a81e13a2252d35d9fc3dc04a9ed7d7c.1401457502.git.vdavydov@parallels.com>
	<20140602044154.GB17964@js1304-P5Q-DELUXE>
	<20140602121034.GB1039@esperanza>
Date: Mon, 2 Jun 2014 23:01:55 +0900
Message-ID: <CAAmzW4MiUmmqXFeiwVNPDmtOSf6U+9J_U4_ZAF4Qv9w=T4AMiA@mail.gmail.com>
Subject: Re: [PATCH -mm 8/8] slab: reap dead memcg caches aggressively
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

2014-06-02 21:10 GMT+09:00 Vladimir Davydov <vdavydov@parallels.com>:
> On Mon, Jun 02, 2014 at 01:41:55PM +0900, Joonsoo Kim wrote:
>> According to my code reading, slabs_to_free() doesn't return number of
>> free slabs. This bug is introduced by 0fa8103b. I think that it is
>> better to fix it before applyting this patch. Otherwise, use n->free_objects
>> instead of slabs_tofree() to achieve your purpose correctly.
>
> Hmm, I don't think slab_tofree() computes the number of free slabs
> wrong. If we have N free objects, there may be
> DIV_ROUND_UP(N,objs_per_slab) empty slabs at max, and that's exactly
> what slab_tofree() does, no?

Oops... Sorry for wrong comment.
You are right. Please ignore my comment. :)

BTW, we don't need DIV_ROUND_UP. I think that just N / objs_per_slab is
sufficient to get number of empty slabs at max. Am I missing too?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
