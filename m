Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1C3E76B0390
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 09:28:21 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id f98so135409017iod.18
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 06:28:21 -0700 (PDT)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id n67si11394736ith.121.2017.04.18.06.28.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Apr 2017 06:28:20 -0700 (PDT)
Date: Tue, 18 Apr 2017 08:28:17 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: copy_page() on a kmalloc-ed page with DEBUG_SLAB enabled (was
 "zram: do not use copy_page with non-page alinged address")
In-Reply-To: <20170418104222.GB558@jagdpanzerIV.localdomain>
Message-ID: <alpine.DEB.2.20.1704180825460.13506@east.gentwo.org>
References: <20170417014803.GC518@jagdpanzerIV.localdomain> <alpine.DEB.2.20.1704171016550.28407@east.gentwo.org> <20170418104222.GB558@jagdpanzerIV.localdomain>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Tue, 18 Apr 2017, Sergey Senozhatsky wrote:

> > Simple solution is to not allocate pages via the slab allocator but use
> > the page allocator for this. The page allocator provides proper alignment.
>
> sure, but at the same time it's not completely uncommon and unseen thing
>
> ~/_next$ git grep kmalloc | grep PAGE_SIZE | wc -l
> 75

Of course if you want a PAGE_SIZE object that is not really page aligned
etc then its definitely ok to use.

> not all, if any, of those pages get into copy_page(), of course. may be... hopefully.
> so may be a warning would make sense and save time some day. but up to MM
> people to decide.

Slab objects are copied using memcpy. copy_page is for pages aligned to
page boundaries and the arch code there may have additional expectations
that cannot be met by the slab allocators.

> p.s. Christoph, FYI, gmail automatically marked your message
>      as a spam message, for some reason.

Weird. Any more details as to why?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
