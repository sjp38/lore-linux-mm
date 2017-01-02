Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id B1A0C6B0069
	for <linux-mm@kvack.org>; Mon,  2 Jan 2017 06:03:00 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id qs7so53152937wjc.4
        for <linux-mm@kvack.org>; Mon, 02 Jan 2017 03:03:00 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y4si72843715wjc.180.2017.01.02.03.02.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 02 Jan 2017 03:02:59 -0800 (PST)
Date: Mon, 2 Jan 2017 12:02:57 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] slab reclaim
Message-ID: <20170102110257.GB18058@quack2.suse.cz>
References: <20161228130949.GA11480@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161228130949.GA11480@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Hi!

On Wed 28-12-16 14:09:51, Michal Hocko wrote:
> I would like to propose the following for LSF/MM discussion. Both MM and
> FS people should be involved.
> 
> The current way of the slab reclaim is rather suboptimal from 2
> perspectives.
> 
> 1) The slab allocator relies on shrinkers to release pages but shrinkers
> are object rather than page based. This means that the memory reclaim
> asks to free some pages, slab asks shrinkers to free some objects
> and the result might be that nothing really gets freed even though
> shrinkers do their jobs properly because some objects are still pinning
> the page. This is not a new problem and it has been discussed in the
> past. Dave Chinner has even suggested a solution [1] which sounds like
> the right approach. There was no follow up and I believe we should
> into implementing it.
> 
> 2) The way we scale slab reclaim pressure depends on the regular LRU
> reclaim. There are workloads which do not general a lot of pages on LRUs
> while they still consume a lot of slab memory. We can end up even going
> OOM because the slab reclaim doesn't free up enough. I am not really
> sure how the proper solution should look like but either we need some
> way of slab consumption throttling or we need a more clever slab
> pressure estimation.
> 
> [1] https://lkml.org/lkml/2010/2/8/329.

I'm interested in this topic although I think it currently needs more
coding and experimenting than discussions...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
