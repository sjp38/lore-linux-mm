Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 14BA96B006C
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 06:56:48 -0400 (EDT)
Received: by wibg7 with SMTP id g7so104679301wib.1
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 03:56:47 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ja14si4507714wic.0.2015.03.25.03.56.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 25 Mar 2015 03:56:46 -0700 (PDT)
Date: Wed, 25 Mar 2015 10:56:40 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFCv2] mm: page allocation for less fragmentation
Message-ID: <20150325105640.GI4701@suse.de>
References: <1427251155-12322-1-git-send-email-gioh.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1427251155-12322-1-git-send-email-gioh.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>
Cc: akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, rientjes@google.com, vdavydov@parallels.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gunho.lee@lge.com

On Wed, Mar 25, 2015 at 11:39:15AM +0900, Gioh Kim wrote:
> My driver allocates more than 40MB pages via alloc_page() at a time and
> maps them at virtual address. Totally it uses 300~400MB pages.
> 
> If I run a heavy load test for a few days in 1GB memory system, I cannot allocate even order=3 pages
> because-of the external fragmentation.
> 
> I thought I needed a anti-fragmentation solution for my driver.
> But there is no allocation function that considers fragmentation.
> The compaction is not helpful because it is only for movable pages, not unmovable pages.
> 
> This patch proposes a allocation function allocates only pages in the same pageblock.
> 

Is this not what CMA is for? Or creating a MOVABLE zone?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
