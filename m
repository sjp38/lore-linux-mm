Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id E4DE56B0038
	for <linux-mm@kvack.org>; Tue, 13 May 2014 10:09:13 -0400 (EDT)
Received: by mail-ee0-f43.google.com with SMTP id d17so471367eek.2
        for <linux-mm@kvack.org>; Tue, 13 May 2014 07:09:13 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c6si13244348eem.210.2014.05.13.07.09.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 13 May 2014 07:09:12 -0700 (PDT)
Date: Tue, 13 May 2014 15:09:08 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 10/19] mm: page_alloc: Reduce number of times page_to_pfn
 is called
Message-ID: <20140513140908.GS23991@suse.de>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
 <1399974350-11089-11-git-send-email-mgorman@suse.de>
 <53721DC1.1040006@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <53721DC1.1040006@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Tue, May 13, 2014 at 03:27:29PM +0200, Vlastimil Babka wrote:
> On 05/13/2014 11:45 AM, Mel Gorman wrote:
> >In the free path we calculate page_to_pfn multiple times. Reduce that.
> >
> >Signed-off-by: Mel Gorman <mgorman@suse.de>
> >Acked-by: Rik van Riel <riel@redhat.com>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 
> Just two comments.
> I just don't like #define but I can live with that.

page_to_pfn is not available in that context due to header dependency
problems. It can be avoided by moving the two functions into mm/internal.h
so I'll do that. I cannot see why code outside of mm/ would be missing
with those bits anyway.

Thanks

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
