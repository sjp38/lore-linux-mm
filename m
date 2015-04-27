Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 3E6A46B0038
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 04:08:55 -0400 (EDT)
Received: by wiax7 with SMTP id x7so77978543wia.0
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 01:08:54 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id di7si31970527wjc.113.2015.04.27.01.08.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 27 Apr 2015 01:08:53 -0700 (PDT)
Date: Mon, 27 Apr 2015 09:08:50 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/3] mm/page_alloc: don't break highest order freepage if
 steal
Message-ID: <20150427080850.GF2449@suse.de>
References: <1430119421-13536-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1430119421-13536-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>

On Mon, Apr 27, 2015 at 04:23:39PM +0900, Joonsoo Kim wrote:
> When we steal whole pageblock, we don't need to break highest order
> freepage. Perhaps, there is small order freepage so we can use it.
> 

The reason why the largest block is taken is to reduce the probability
there will be another fallback event in the near future. Early on, there
were a lot of tests conducted to measure the number of external fragmenting
events and take steps to reduce them. Stealing the largest highest order
freepage was one of those steps.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
