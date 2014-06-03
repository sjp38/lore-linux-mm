Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id DE96E6B0037
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 04:21:39 -0400 (EDT)
Received: by mail-lb0-f179.google.com with SMTP id c11so3180272lbj.38
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 01:21:38 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ro5si38639230lbb.24.2014.06.03.01.21.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jun 2014 01:21:38 -0700 (PDT)
Date: Tue, 3 Jun 2014 12:21:26 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm 8/8] slab: reap dead memcg caches aggressively
Message-ID: <20140603082124.GB6013@esperanza>
References: <cover.1401457502.git.vdavydov@parallels.com>
 <23a736c90a81e13a2252d35d9fc3dc04a9ed7d7c.1401457502.git.vdavydov@parallels.com>
 <20140602044154.GB17964@js1304-P5Q-DELUXE>
 <20140602121034.GB1039@esperanza>
 <CAAmzW4MiUmmqXFeiwVNPDmtOSf6U+9J_U4_ZAF4Qv9w=T4AMiA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <CAAmzW4MiUmmqXFeiwVNPDmtOSf6U+9J_U4_ZAF4Qv9w=T4AMiA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Mon, Jun 02, 2014 at 11:01:55PM +0900, Joonsoo Kim wrote:
> 2014-06-02 21:10 GMT+09:00 Vladimir Davydov <vdavydov@parallels.com>:
> > On Mon, Jun 02, 2014 at 01:41:55PM +0900, Joonsoo Kim wrote:
> >> According to my code reading, slabs_to_free() doesn't return number of
> >> free slabs. This bug is introduced by 0fa8103b. I think that it is
> >> better to fix it before applyting this patch. Otherwise, use n->free_objects
> >> instead of slabs_tofree() to achieve your purpose correctly.
> >
> > Hmm, I don't think slab_tofree() computes the number of free slabs
> > wrong. If we have N free objects, there may be
> > DIV_ROUND_UP(N,objs_per_slab) empty slabs at max, and that's exactly
> > what slab_tofree() does, no?
> 
[...]
> BTW, we don't need DIV_ROUND_UP. I think that just N / objs_per_slab is
> sufficient to get number of empty slabs at max. Am I missing too?

Yeah, you're right - DIV_ROUND_UP is obviously redundant, DIV would be
enough. Not a bug though.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
