Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f48.google.com (mail-qa0-f48.google.com [209.85.216.48])
	by kanga.kvack.org (Postfix) with ESMTP id 7511A6B011F
	for <linux-mm@kvack.org>; Tue, 11 Nov 2014 19:36:34 -0500 (EST)
Received: by mail-qa0-f48.google.com with SMTP id x12so7731855qac.7
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 16:36:34 -0800 (PST)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id j47si39296674qge.58.2014.11.11.16.36.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 11 Nov 2014 16:36:33 -0800 (PST)
Date: Tue, 11 Nov 2014 18:36:28 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [Bug 87891] New: kernel BUG at mm/slab.c:2625!
In-Reply-To: <20141111153120.9131c8e1459415afff8645bc@linux-foundation.org>
Message-ID: <alpine.DEB.2.11.1411111833220.8762@gentwo.org>
References: <bug-87891-27@https.bugzilla.kernel.org/> <20141111153120.9131c8e1459415afff8645bc@linux-foundation.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ming Lei <ming.lei@canonical.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Pauli Nieminen <suokkos@gmail.com>, Dave Airlie <airlied@linux.ie>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, bugzilla-daemon@bugzilla.kernel.org, luke-jr+linuxbugs@utopios.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org

On Tue, 11 Nov 2014, Andrew Morton wrote:

> There's no point in doing
>
> 	#define GFP_SLAB_BUG_MASK (__GFP_DMA32|__GFP_HIGHMEM|~__GFP_BITS_MASK)
>
> because __GFP_DMA32|__GFP_HIGHMEM are already part of ~__GFP_BITS_MASK.

?? ~__GFP_BITS_MASK means bits 25 to 31 are set.

__GFP_DMA32 is bit 2 and __GFP_HIGHMEM is bit 1.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
