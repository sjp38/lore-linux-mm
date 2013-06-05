Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 367446B0034
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 04:55:33 -0400 (EDT)
Date: Wed, 5 Jun 2013 10:55:31 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/3] memcg: simplify mem_cgroup_reclaim_iter
Message-ID: <20130605085531.GG15997@dhcp22.suse.cz>
References: <1370306679-13129-1-git-send-email-tj@kernel.org>
 <1370306679-13129-4-git-send-email-tj@kernel.org>
 <20130604131843.GF31242@dhcp22.suse.cz>
 <20130604205025.GG14916@htj.dyndns.org>
 <20130604212808.GB13231@dhcp22.suse.cz>
 <20130604215535.GM14916@htj.dyndns.org>
 <20130605073023.GB15997@dhcp22.suse.cz>
 <20130605082023.GG7303@mtj.dyndns.org>
 <20130605083628.GE15997@dhcp22.suse.cz>
 <20130605084456.GA7990@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130605084456.GA7990@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: hannes@cmpxchg.org, bsingharora@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, lizefan@huawei.com

On Wed 05-06-13 01:44:56, Tejun Heo wrote:
[...]
> > alive. Sorry, I do not like it at all. I find it much better to clean up
> > when the group is removed. Because doing things asynchronously just
> > makes it more obscure. There is no reason to do such a thing on the
> > background when we know _when_ to do the cleanup and that is definitely
> > _not a hot path_.
> 
> Yeah, that's true.  I just wanna avoid the barrier dancing.  Only one
> of the ancestors can cache a memcg, right?

No. All of them on the way up hierarchy. Basically each parent which
ever triggered the reclaim caches reclaimers.

> Walking up the tree scanning for cached ones and putting them should
> work?  Is that what you were suggesting?

That was my first version of the patch I linked in the previous email.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
