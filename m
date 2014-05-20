Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 573ED6B0036
	for <linux-mm@kvack.org>; Tue, 20 May 2014 04:36:08 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id ey11so116678pad.32
        for <linux-mm@kvack.org>; Tue, 20 May 2014 01:36:08 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id bc1si23584416pad.0.2014.05.20.01.29.35
        for <linux-mm@kvack.org>;
        Tue, 20 May 2014 01:29:36 -0700 (PDT)
Date: Tue, 20 May 2014 17:32:06 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH] arm: dma-mapping: fallback allocation for cma failure
Message-ID: <20140520083206.GA8927@js1304-P5Q-DELUXE>
References: <537AEEDB.2000001@lge.com>
 <20140520065222.GB8315@js1304-P5Q-DELUXE>
 <537AFED0.4010401@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <537AFED0.4010401@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Heesub Shin <heesub.shin@samsung.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, =?utf-8?B?7J206rG07Zi4?= <gunho.lee@lge.com>

On Tue, May 20, 2014 at 04:05:52PM +0900, Gioh Kim wrote:
> That case, device-specific coherent memory allocation, is handled at dma_alloc_coherent in arm_dma_alloc.
> __dma_alloc handles only general coherent memory allocation.
> 
> I'm sorry missing mention about it.
> 

Hello,

AFAIK, *coherent* memory allocation is different with *contiguous* memory
allocation(CMA). So we need to handle the case I mentioned.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
