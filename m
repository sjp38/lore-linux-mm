Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id D1CCA6B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 12:20:41 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id 123so115383514wmz.0
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 09:20:41 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h79si6688425wme.86.2016.01.26.09.20.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Jan 2016 09:20:40 -0800 (PST)
Date: Tue, 26 Jan 2016 18:20:51 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] proposals for topics
Message-ID: <20160126172051.GB6066@quack.suse.cz>
References: <20160125133357.GC23939@dhcp22.suse.cz>
 <20160125184559.GE29291@cmpxchg.org>
 <20160126095022.GC27563@dhcp22.suse.cz>
 <56A7AA0D.9040409@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56A7AA0D.9040409@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org

On Tue 26-01-16 18:17:01, Vlastimil Babka wrote:
> >>>- GFP_NOFS is another one which would be good to discuss. Its primary
> >>>   use is to prevent from reclaim recursion back into FS. This makes
> >>>   such an allocation context weaker and historically we haven't
> >>>   triggered OOM killer and rather hopelessly retry the request and
> >>>   rely on somebody else to make a progress for us. There are two issues
> >>>   here.
> >>>   First we shouldn't retry endlessly and rather fail the allocation and
> >>>   allow the FS to handle the error. As per my experiments most FS cope
> >>>   with that quite reasonably. Btrfs unfortunately handles many of those
> >>>   failures by BUG_ON which is really unfortunate.
> >>
> >>Are there any new datapoints on how to deal with failing allocations?
> >>IIRC the conclusion last time was that some filesystems simply can't
> >>support this without a reservation system - which I don't believe
> >>anybody is working on. Does it make sense to rehash this when nothing
> >>really changed since last time?
> >
> >There have been patches posted during the year to fortify those places
> >which cannot cope with allocation failures for ext[34] and testing
> >has shown that ext* resp. xfs are quite ready to see NOFS allocation
> >failures.
> 
> Hmm from last year I remember Dave Chinner saying there really are some
> places that can't handle failure, period? That's why all the discussions
> about reservations, and I would be surprised if all such places were gone
> today? Which of course doesn't mean that there couldn't be different NOFS
> places that can handle failures, which however don't happen in current
> implementation.

Well, but we have GFP_NOFAIL (or equivalent of thereof opencoded) in there.
So yes, there are GFP_NOFAIL | GFP_NOFS allocations and allocator must deal
with it somehow.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
