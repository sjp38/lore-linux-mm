Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f169.google.com (mail-io0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id DEBA26B0253
	for <linux-mm@kvack.org>; Tue, 10 Nov 2015 11:17:18 -0500 (EST)
Received: by iodd200 with SMTP id d200so5936367iod.0
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 08:17:18 -0800 (PST)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id m25si5552847ioi.189.2015.11.10.08.17.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 10 Nov 2015 08:17:18 -0800 (PST)
Date: Tue, 10 Nov 2015 10:17:17 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH V3 1/2] slub: fix kmem cgroup bug in
 kmem_cache_alloc_bulk
In-Reply-To: <20151110165534.6154082e@redhat.com>
Message-ID: <alpine.DEB.2.20.1511101016390.8859@east.gentwo.org>
References: <20151109181604.8231.22983.stgit@firesoul> <20151109181703.8231.66384.stgit@firesoul> <20151109191335.GM31308@esperanza> <20151109212522.6b38988c@redhat.com> <20151110084633.GT31308@esperanza> <20151110165534.6154082e@redhat.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, 10 Nov 2015, Jesper Dangaard Brouer wrote:

> @@ -2563,7 +2563,7 @@ redo:
>         if (unlikely(gfpflags & __GFP_ZERO) && object)
>                 memset(object, 0, s->object_size);
>
> -       slab_post_alloc_hook(s, gfpflags, 1, object);
> +       slab_post_alloc_hook(s, gfpflags, 1, &object);
>
>         return object;
>  }
>
> But then the kernel cannot correctly boot?!?! (It dies in
> x86_perf_event_update+0x15.)  What did I miss???

Dont make the above change. object is a pointer to the object. It does not
matter if that is ** or *. Dont take the address.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
