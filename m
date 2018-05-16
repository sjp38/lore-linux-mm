Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 10CF46B035E
	for <linux-mm@kvack.org>; Wed, 16 May 2018 16:41:46 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id s3-v6so1304916pfh.0
        for <linux-mm@kvack.org>; Wed, 16 May 2018 13:41:46 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q7-v6si2695968pgv.658.2018.05.16.13.41.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 16 May 2018 13:41:45 -0700 (PDT)
Subject: Re: [PATCH] mm: save two stranding bit in gfp_mask
References: <20180516202023.167627-1-shakeelb@google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <90167afa-ecfb-c5ef-3554-ddb7e6ac9728@suse.cz>
Date: Wed, 16 May 2018 22:39:39 +0200
MIME-Version: 1.0
In-Reply-To: <20180516202023.167627-1-shakeelb@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Mel Gorman <mgorman@techsingularity.net>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 05/16/2018 10:20 PM, Shakeel Butt wrote:
> ___GFP_COLD and ___GFP_OTHER_NODE were removed but their bits were
> stranded. Slide existing gfp masks to make those two bits available.

Well, there are already available for hypothetical new flags. Is there
anything that benefits from a smaller __GFP_BITS_SHIFT? Otherwise no big
objection, besides the churn. Maybe move the last (well, before
NOLOCKDEP) two flags to the "holes" instead of shifting everything? That
would be closer to what compaction does...
There's also an ongoing effort to make the lowest 4 flags a number,
would that mean more free bits and churn soon?
I would also dislike having to learn new numbers for typical flag
combinations to recognize them in oom reports/alloc failures, but
somebody had the great idea to print those symbolically, so nevermind.

Vlastimil

> Signed-off-by: Shakeel Butt <shakeelb@google.com>
