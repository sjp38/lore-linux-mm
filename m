Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 365206B0033
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 19:06:57 -0400 (EDT)
Received: by mail-qe0-f44.google.com with SMTP id 6so1487900qeb.31
        for <linux-mm@kvack.org>; Wed, 05 Jun 2013 16:06:56 -0700 (PDT)
Date: Wed, 5 Jun 2013 16:06:51 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [patch 2/2] mm: memcontrol: factor out reclaim iterator loading
 and updating
Message-ID: <20130605230651.GO10693@mtj.dyndns.org>
References: <1370472826-29959-1-git-send-email-hannes@cmpxchg.org>
 <1370472826-29959-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1370472826-29959-2-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Jun 05, 2013 at 06:53:46PM -0400, Johannes Weiner wrote:
> mem_cgroup_iter() is too hard to follow.  Factor out the lockless
> reclaim iterator loading and updating so it's easier to follow the big
> picture.
> 
> Also document the iterator invalidation mechanism a bit more
> extensively.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
