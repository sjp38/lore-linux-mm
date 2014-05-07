Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id 399096B0035
	for <linux-mm@kvack.org>; Wed,  7 May 2014 11:14:13 -0400 (EDT)
Received: by mail-ee0-f50.google.com with SMTP id e51so846320eek.37
        for <linux-mm@kvack.org>; Wed, 07 May 2014 08:14:12 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y41si16668429eel.20.2014.05.07.08.14.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 May 2014 08:14:09 -0700 (PDT)
Date: Wed, 7 May 2014 17:14:08 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 5/9] mm: memcontrol: use root_mem_cgroup res_counter
Message-ID: <20140507151408.GK9489@dhcp22.suse.cz>
References: <1398889543-23671-1-git-send-email-hannes@cmpxchg.org>
 <1398889543-23671-6-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1398889543-23671-6-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 30-04-14 16:25:39, Johannes Weiner wrote:
> The root_mem_cgroup res_counter is never charged itself: there is no
> limit at the root level anyway, and any statistics are generated on
> demand by summing up the counters of all other cgroups.  This was an
> optimization to keep down costs on systems that don't create specific
> cgroups, but with per-cpu charge caches the res_counter operations do
> not even show up on in profiles anymore.  Just remove it and simplify
> the code.

It seems that only kmem and tcp thingy are left but those looks much
harder and they are not directly related.

root_mem_cgroup use also seems to be correct.

I have to look at this closer and that will be no sooner than on Monday
as I am off for the rest of the week.
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
