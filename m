Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id CBB756B0071
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 11:08:30 -0400 (EDT)
Received: by qkbp125 with SMTP id p125so23475500qkb.2
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 08:08:30 -0700 (PDT)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [2001:558:fe21:29:69:252:207:35])
        by mx.google.com with ESMTPS id 145si4593375qhx.10.2015.06.17.08.08.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 17 Jun 2015 08:08:29 -0700 (PDT)
Date: Wed, 17 Jun 2015 10:08:28 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH V2 6/6] slub: add support for kmem_cache_debug in bulk
 calls
In-Reply-To: <20150617142934.11791.85352.stgit@devil>
Message-ID: <alpine.DEB.2.11.1506171006020.31991@east.gentwo.org>
References: <20150617142613.11791.76008.stgit@devil> <20150617142934.11791.85352.stgit@devil>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>


> Per request of Joonsoo Kim adding kmem debug support.

> bulk- PREVIOUS                  - THIS-PATCH
>   1 -  43 cycles(tsc) 10.811 ns -  44 cycles(tsc) 11.236 ns  improved  -2.3%
>   2 -  27 cycles(tsc)  6.867 ns -  28 cycles(tsc)  7.019 ns  improved  -3.7%
>   3 -  21 cycles(tsc)  5.496 ns -  22 cycles(tsc)  5.526 ns  improved  -4.8%
>   4 -  24 cycles(tsc)  6.038 ns -  19 cycles(tsc)  4.786 ns  improved  20.8%
>   8 -  17 cycles(tsc)  4.280 ns -  18 cycles(tsc)  4.572 ns  improved  -5.9%
>  16 -  17 cycles(tsc)  4.483 ns -  18 cycles(tsc)  4.658 ns  improved  -5.9%
>  30 -  18 cycles(tsc)  4.531 ns -  18 cycles(tsc)  4.568 ns  improved   0.0%
>  32 -  58 cycles(tsc) 14.586 ns -  65 cycles(tsc) 16.454 ns  improved -12.1%
>  34 -  53 cycles(tsc) 13.391 ns -  63 cycles(tsc) 15.932 ns  improved -18.9%
>  48 -  65 cycles(tsc) 16.268 ns -  50 cycles(tsc) 12.506 ns  improved  23.1%
>  64 -  53 cycles(tsc) 13.440 ns -  63 cycles(tsc) 15.929 ns  improved -18.9%
> 128 -  79 cycles(tsc) 19.899 ns -  86 cycles(tsc) 21.583 ns  improved  -8.9%
> 158 -  90 cycles(tsc) 22.732 ns -  90 cycles(tsc) 22.552 ns  improved   0.0%
> 250 -  95 cycles(tsc) 23.916 ns -  98 cycles(tsc) 24.589 ns  improved  -3.2%

Hmmm.... Can we afford these regressions?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
