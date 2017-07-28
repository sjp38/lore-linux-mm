Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id AFFEF6B04E7
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 05:52:52 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id e204so12334236wma.2
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 02:52:52 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v76si3215292wmd.247.2017.07.28.02.52.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 28 Jul 2017 02:52:51 -0700 (PDT)
Date: Fri, 28 Jul 2017 10:52:49 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH] treewide: remove GFP_TEMPORARY allocation flag
Message-ID: <20170728095249.n62p5nhqbekjd5yn@suse.de>
References: <20170728091904.14627-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170728091904.14627-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, Neil Brown <neilb@suse.de>, Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Fri, Jul 28, 2017 at 11:19:04AM +0200, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> GFP_TEMPORARY has been introduced by e12ba74d8ff3 ("Group short-lived
> and reclaimable kernel allocations") along with __GFP_RECLAIMABLE. It's
> primary motivation was to allow users to tell that an allocation is
> short lived and so the allocator can try to place such allocations close
> together and prevent long term fragmentation. As much as this sounds
> like a reasonable semantic it becomes much less clear when to use the
> highlevel GFP_TEMPORARY allocation flag. How long is temporary? Can
> the context holding that memory sleep? Can it take locks? It seems
> there is no good answer for those questions.
> 
> The current implementation of GFP_TEMPORARY is basically
> GFP_KERNEL | __GFP_RECLAIMABLE which in itself is tricky because
> basically none of the existing caller provide a way to reclaim the
> allocated memory. So this is rather misleading and hard to evaluate for
> any benefits.
> 

At the time of the introduction, the users were all very short-lived
where short was for operations such as reading a proc file that discarded
buffers afterwards. However, it does seem to have misused over the last
few years and it was too easy to confuse "temporary" with "short lived"
and too easy to get confused about "how short lived is short lived?". On
that basis;

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
