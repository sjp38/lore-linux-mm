Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id D71C56B0005
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 04:08:31 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id p63so15850636wmp.1
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 01:08:31 -0800 (PST)
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com. [74.125.82.48])
        by mx.google.com with ESMTPS id s197si22625185wmb.1.2016.01.27.01.08.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jan 2016 01:08:30 -0800 (PST)
Received: by mail-wm0-f48.google.com with SMTP id l65so136367730wmf.1
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 01:08:30 -0800 (PST)
Date: Wed, 27 Jan 2016 10:08:29 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] proposals for topics
Message-ID: <20160127090828.GA13951@dhcp22.suse.cz>
References: <20160125133357.GC23939@dhcp22.suse.cz>
 <20160125184559.GE29291@cmpxchg.org>
 <20160126095022.GC27563@dhcp22.suse.cz>
 <56A7AA0D.9040409@suse.cz>
 <20160126172051.GB6066@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160126172051.GB6066@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org

On Tue 26-01-16 18:20:51, Jan Kara wrote:
> On Tue 26-01-16 18:17:01, Vlastimil Babka wrote:
[...]
> > Hmm from last year I remember Dave Chinner saying there really are some
> > places that can't handle failure, period? That's why all the discussions
> > about reservations, and I would be surprised if all such places were gone
> > today? Which of course doesn't mean that there couldn't be different NOFS
> > places that can handle failures, which however don't happen in current
> > implementation.
> 
> Well, but we have GFP_NOFAIL (or equivalent of thereof opencoded) in there.
> So yes, there are GFP_NOFAIL | GFP_NOFS allocations and allocator must deal
> with it somehow.

Yes, the allocator deals with them in two ways. a) it allows to trigger
the OOM killer and b) gives them access to memory reserves. So while
the reservation system sounds like a more robust plan long term but we
have a way forward right now and distinguish must not fail and do have a
fallback method already.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
