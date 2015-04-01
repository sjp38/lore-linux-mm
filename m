Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 811546B0038
	for <linux-mm@kvack.org>; Wed,  1 Apr 2015 11:19:24 -0400 (EDT)
Received: by widdi4 with SMTP id di4so48877694wid.0
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 08:19:24 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u4si2293320wif.83.2015.04.01.08.19.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 01 Apr 2015 08:19:22 -0700 (PDT)
Date: Wed, 1 Apr 2015 17:19:20 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 00/12] mm: page_alloc: improve OOM mechanism and policy
Message-ID: <20150401151920.GB23824@dhcp22.suse.cz>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
 <20150326195822.GB28129@dastard>
 <20150327150509.GA21119@cmpxchg.org>
 <20150330003240.GB28621@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150330003240.GB28621@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Theodore Ts'o <tytso@mit.edu>

On Mon 30-03-15 11:32:40, Dave Chinner wrote:
> On Fri, Mar 27, 2015 at 11:05:09AM -0400, Johannes Weiner wrote:
[...]
> > GFP_NOFS sites are currently one of the sites that can deadlock inside
> > the allocator, even though many of them seem to have fallback code.
> > My reasoning here is that if you *have* an exit strategy for failing
> > allocations that is smarter than hanging, we should probably use that.
> 
> We already do that for allocations where we can handle failure in
> GFP_NOFS conditions. It is, however, somewhat useless if we can't
> tell the allocator to try really hard if we've already had a failure
> and we are already in memory reclaim conditions (e.g. a shrinker
> trying to clean dirty objects so they can be reclaimed).
> 
> From that perspective, I think that this patch set aims force us
> away from handling fallbacks ourselves because a) it makes GFP_NOFS
> more likely to fail, and b) provides no mechanism to "try harder"
> when we really need the allocation to succeed.

You can ask for this "try harder" by __GFP_HIGH flag. Would that help
in your fallback case?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
