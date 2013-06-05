Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 9FF2B6B0033
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 10:56:57 -0400 (EDT)
Date: Wed, 5 Jun 2013 16:56:55 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/3] memcg: simplify mem_cgroup_reclaim_iter
Message-ID: <20130605145655.GA3796@dhcp22.suse.cz>
References: <1370306679-13129-1-git-send-email-tj@kernel.org>
 <1370306679-13129-4-git-send-email-tj@kernel.org>
 <20130604131843.GF31242@dhcp22.suse.cz>
 <20130604205025.GG14916@htj.dyndns.org>
 <20130604212808.GB13231@dhcp22.suse.cz>
 <20130604215535.GM14916@htj.dyndns.org>
 <20130605073023.GB15997@dhcp22.suse.cz>
 <20130605082023.GG7303@mtj.dyndns.org>
 <20130605143949.GQ15576@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130605143949.GQ15576@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tejun Heo <tj@kernel.org>, bsingharora@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, lizefan@huawei.com

On Wed 05-06-13 10:39:49, Johannes Weiner wrote:
[...]
> You hate the barriers, so let's add a lock to access the iterator.
> That path is not too hot in most cases.

yes, basically only reclaimers use that path which makes it a slow path
by definition.

> On the other hand, the weak pointer is not too esoteric of a pattern
> and we can neatly abstract it into two functions: one that takes an
> iterator and returns a verified css reference or NULL, and one to
> invalidate pointers when called from the memcg destruction code.

would be nice.

> These two things should greatly simplify mem_cgroup_iter() while not
> completely abandoning all our optimizations.
> 
> What do you think?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
