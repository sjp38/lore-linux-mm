Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id B97A26B0032
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 06:28:09 -0400 (EDT)
Received: by wibbg6 with SMTP id bg6so58403067wib.0
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 03:28:09 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g1si9204817wjy.65.2015.03.26.03.28.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 26 Mar 2015 03:28:08 -0700 (PDT)
Date: Thu, 26 Mar 2015 10:28:03 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFCv2] mm: page allocation for less fragmentation
Message-ID: <20150326102803.GL4701@suse.de>
References: <1427251155-12322-1-git-send-email-gioh.kim@lge.com>
 <20150325105640.GI4701@suse.de>
 <551325A6.5000405@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <551325A6.5000405@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>
Cc: akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, rientjes@google.com, vdavydov@parallels.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gunho.lee@lge.com

On Thu, Mar 26, 2015 at 06:16:22AM +0900, Gioh Kim wrote:
> 
> 
> 2015-03-25 ?????? 7:56??? Mel Gorman ???(???) ??? ???:
> >On Wed, Mar 25, 2015 at 11:39:15AM +0900, Gioh Kim wrote:
> >>My driver allocates more than 40MB pages via alloc_page() at a time and
> >>maps them at virtual address. Totally it uses 300~400MB pages.
> >>
> >>If I run a heavy load test for a few days in 1GB memory system, I cannot allocate even order=3 pages
> >>because-of the external fragmentation.
> >>
> >>I thought I needed a anti-fragmentation solution for my driver.
> >>But there is no allocation function that considers fragmentation.
> >>The compaction is not helpful because it is only for movable pages, not unmovable pages.
> >>
> >>This patch proposes a allocation function allocates only pages in the same pageblock.
> >>
> >
> >Is this not what CMA is for? Or creating a MOVABLE zone?
> 
> It's not related to CMA and MOVABLE zone.
> It's for compaction and anti-fragmentation for any zone.
> 

Create a CMA area, allow your driver to use it use alloc_contig_range.
As it is, this is creating another contiguous range allocation function
with no in-kernel users.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
