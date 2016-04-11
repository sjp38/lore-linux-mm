Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id A59056B0005
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 11:34:00 -0400 (EDT)
Received: by mail-wm0-f42.google.com with SMTP id n3so109992829wmn.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 08:34:00 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id kh8si29405749wjb.218.2016.04.11.08.33.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 08:33:59 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id n3so22173328wmn.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 08:33:59 -0700 (PDT)
Date: Mon, 11 Apr 2016 17:33:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 09/11] mm, compaction: Abstract compaction feedback to
 helpers
Message-ID: <20160411153357.GM23157@dhcp22.suse.cz>
References: <1459855533-4600-1-git-send-email-mhocko@kernel.org>
 <1459855533-4600-10-git-send-email-mhocko@kernel.org>
 <570BB719.2030007@suse.cz>
 <20160411151410.GL23157@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160411151410.GL23157@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Joonsoo Kim <js1304@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 11-04-16 17:14:10, Michal Hocko wrote:
> On Mon 11-04-16 16:39:21, Vlastimil Babka wrote:
> > On 04/05/2016 01:25 PM, Michal Hocko wrote:
[...]
> > >+	/*
> > >+	 * Checks for THP-specific high-order allocations and back off
> > >+	 * if the the compaction backed off
> > >+	 */
> > >+	if (is_thp_gfp_mask(gfp_mask) && compaction_withdrawn(compact_result))
> > >+		goto nopage;
> > 
> > The change of semantics for THP is not trivial here and should at least be
> > discussed in changelog. CONTENDED and DEFERRED is only subset of
> > compaction_withdrawn() as seen above.
> 
> True. My main motivation was to get rid of the compaction specific code
> from the allocator path as much as possible. I can drop the above hunk

I was thinking about this some more and will drop the hunk. I would
rather have this patch without side effects as much as possible. A
follow up patch can get rid of the specific checks and use a simpler
ones. I will post -fix patch to Andrew.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
