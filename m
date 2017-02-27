Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5D5E86B0389
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 11:30:14 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id v77so39825225wmv.5
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 08:30:14 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o67si14046711wmo.87.2017.02.27.08.30.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 27 Feb 2017 08:30:13 -0800 (PST)
Date: Mon, 27 Feb 2017 17:30:10 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V5 3/6] mm: move MADV_FREE pages into LRU_INACTIVE_FILE
 list
Message-ID: <20170227163009.GM26504@dhcp22.suse.cz>
References: <cover.1487965799.git.shli@fb.com>
 <2f87063c1e9354677b7618c647abde77b07561e5.1487965799.git.shli@fb.com>
 <20170227062801.GB23612@bbox>
 <20170227161309.GB62304@shli-mbp.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170227161309.GB62304@shli-mbp.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Mon 27-02-17 08:13:10, Shaohua Li wrote:
> On Mon, Feb 27, 2017 at 03:28:01PM +0900, Minchan Kim wrote:
[...]
> > This patch doesn't address I pointed out in v4.
> > 
> > https://marc.info/?i=20170224233752.GB4635%40bbox
> > 
> > Let's discuss it if you still are against.
> 
> I really think a spearate patch makes the code clearer. There are a lot of
> places we introduce a function but don't use it immediately, if the way makes
> the code clearer. But anyway, I'll let Andrew decide if the two patches should
> be merged.

I agree that it is almost always _preferable_ to add new functions along
with their callers. In this particular case I would lean towards keeping
the separation the way Shaohua did it because it makes the code really
cleaner IMHO.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
