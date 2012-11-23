Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id DE0B56B0044
	for <linux-mm@kvack.org>; Fri, 23 Nov 2012 09:00:54 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so7006676pbc.14
        for <linux-mm@kvack.org>; Fri, 23 Nov 2012 06:00:54 -0800 (PST)
Date: Fri, 23 Nov 2012 06:00:48 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/2] memcg: debugging facility to access dangling memcgs.
Message-ID: <20121123140048.GU15971@htj.dyndns.org>
References: <1353580190-14721-1-git-send-email-glommer@parallels.com>
 <1353580190-14721-3-git-send-email-glommer@parallels.com>
 <20121123092010.GD24698@dhcp22.suse.cz>
 <50AF42F0.6040407@parallels.com>
 <20121123103307.GH24698@dhcp22.suse.cz>
 <50AF51D1.6040702@parallels.com>
 <20121123105154.GK24698@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121123105154.GK24698@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com

On Fri, Nov 23, 2012 at 11:51:54AM +0100, Michal Hocko wrote:
> > Fully agreed. I am implementing this because Kame suggested. I promptly
> > agreed because I remembered how many times I asked myself "Who is
> > holding this?" and had to go put some printks all over...
> 
> So please make it configurable, off by default and be explicit about its
> usefulness.

And please make the file name explicitly indicate that it's a debug
thing, so that someone doesn't grow a messy dependency on it for
whatever reason.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
