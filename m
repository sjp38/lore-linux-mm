Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 71B5644084A
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 12:59:14 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 23so25773795wry.4
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 09:59:14 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id b25si10230745eda.91.2017.07.10.09.59.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 10 Jul 2017 09:59:13 -0700 (PDT)
Date: Mon, 10 Jul 2017 12:58:59 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm, vmscan: do not loop on too_many_isolated for ever
Message-ID: <20170710165859.GA12036@cmpxchg.org>
References: <20170710074842.23175-1-mhocko@kernel.org>
 <1499695083.6130.38.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1499695083.6130.38.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Mon, Jul 10, 2017 at 09:58:03AM -0400, Rik van Riel wrote:
> On Mon, 2017-07-10 at 09:48 +0200, Michal Hocko wrote:
> 
> > Johannes and Rik had some concerns that this could lead to premature
> > OOM kills. I agree with them that we need a better throttling
> > mechanism. Until now we didn't give the issue described above a high
> > priority because it usually required a really insane workload to
> > trigger. But it seems that the issue can be reproduced also without
> > having an insane number of competing threads [3].
> 
> My worries stand, but lets fix the real observed bug, and not worry
> too much about the theoretical bug for now.
> 
> Acked-by: Rik van Riel <riel@redhat.com>

I agree with this.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
