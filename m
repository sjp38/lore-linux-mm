Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id CD6AA6B00C2
	for <linux-mm@kvack.org>; Tue, 11 Nov 2014 19:49:16 -0500 (EST)
Received: by mail-ig0-f178.google.com with SMTP id a13so2042880igq.11
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 16:49:16 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f140si32109139ioe.105.2014.11.11.16.49.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Nov 2014 16:49:15 -0800 (PST)
Date: Tue, 11 Nov 2014 16:49:13 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 87891] New: kernel BUG at mm/slab.c:2625!
Message-Id: <20141111164913.3616531c21c91499871c46de@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.11.1411111833220.8762@gentwo.org>
References: <bug-87891-27@https.bugzilla.kernel.org/>
	<20141111153120.9131c8e1459415afff8645bc@linux-foundation.org>
	<alpine.DEB.2.11.1411111833220.8762@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Ming Lei <ming.lei@canonical.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Pauli Nieminen <suokkos@gmail.com>, Dave Airlie <airlied@linux.ie>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, bugzilla-daemon@bugzilla.kernel.org, luke-jr+linuxbugs@utopios.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org

On Tue, 11 Nov 2014 18:36:28 -0600 (CST) Christoph Lameter <cl@linux.com> wrote:

> On Tue, 11 Nov 2014, Andrew Morton wrote:
> 
> > There's no point in doing
> >
> > 	#define GFP_SLAB_BUG_MASK (__GFP_DMA32|__GFP_HIGHMEM|~__GFP_BITS_MASK)
> >
> > because __GFP_DMA32|__GFP_HIGHMEM are already part of ~__GFP_BITS_MASK.
> 
> ?? ~__GFP_BITS_MASK means bits 25 to 31 are set.
> 
> __GFP_DMA32 is bit 2 and __GFP_HIGHMEM is bit 1.

Ah, yes, OK.

I suppose it's possible that __GFP_HIGHMEM was set.

do_huge_pmd_anonymous_page
->pte_alloc_one
  ->alloc_pages(__userpte_alloc_gfp==__GFP_HIGHMEM)

but I haven't traced that through and that's 32-bit.

But anyway - Luke, please attach your .config to
https://bugzilla.kernel.org/show_bug.cgi?id=87891?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
