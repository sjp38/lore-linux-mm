Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id D296444084A
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 13:09:38 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z45so25843008wrb.13
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 10:09:38 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e3si6934063wmd.89.2017.07.10.10.09.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Jul 2017 10:09:37 -0700 (PDT)
Date: Mon, 10 Jul 2017 19:09:34 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, vmscan: do not loop on too_many_isolated for ever
Message-ID: <20170710170933.GE7071@dhcp22.suse.cz>
References: <20170710074842.23175-1-mhocko@kernel.org>
 <1499695083.6130.38.camel@redhat.com>
 <20170710165859.GA12036@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170710165859.GA12036@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 10-07-17 12:58:59, Johannes Weiner wrote:
> On Mon, Jul 10, 2017 at 09:58:03AM -0400, Rik van Riel wrote:
> > On Mon, 2017-07-10 at 09:48 +0200, Michal Hocko wrote:
> > 
> > > Johannes and Rik had some concerns that this could lead to premature
> > > OOM kills. I agree with them that we need a better throttling
> > > mechanism. Until now we didn't give the issue described above a high
> > > priority because it usually required a really insane workload to
> > > trigger. But it seems that the issue can be reproduced also without
> > > having an insane number of competing threads [3].
> > 
> > My worries stand, but lets fix the real observed bug, and not worry
> > too much about the theoretical bug for now.
> > 
> > Acked-by: Rik van Riel <riel@redhat.com>
> 
> I agree with this.
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Thanks to both of you. Just to make it clear. I really do want to
address the throttling problem longterm properly. I do not have any
great ideas to be honest.  I am busy with other things so it might be
quite some time before I come up with something.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
