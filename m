Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 1BFE76B0031
	for <linux-mm@kvack.org>; Mon, 10 Jun 2013 19:14:04 -0400 (EDT)
Received: by mail-qc0-f172.google.com with SMTP id j10so3982473qcx.17
        for <linux-mm@kvack.org>; Mon, 10 Jun 2013 16:14:03 -0700 (PDT)
Date: Mon, 10 Jun 2013 16:13:58 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/3] memcg: simplify mem_cgroup_reclaim_iter
Message-ID: <20130610231358.GD12461@mtj.dyndns.org>
References: <20130605211704.GJ15721@cmpxchg.org>
 <20130605222021.GL10693@mtj.dyndns.org>
 <20130605222709.GM10693@mtj.dyndns.org>
 <20130606115031.GE7909@dhcp22.suse.cz>
 <20130607005242.GB16160@htj.dyndns.org>
 <20130607073754.GA8117@dhcp22.suse.cz>
 <20130607232557.GL14781@mtj.dyndns.org>
 <20130610080208.GB5138@dhcp22.suse.cz>
 <20130610195426.GC12461@mtj.dyndns.org>
 <20130610204801.GA21003@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130610204801.GA21003@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, bsingharora@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, lizefan@huawei.com

Hey,

On Mon, Jun 10, 2013 at 10:48:01PM +0200, Michal Hocko wrote:
> > Ooh, right, we don't need cleanup of the cached cursors on destruction
> > if we get this correct - especially if we make cursors point to the
> > next cgroup to visit as self is always the first one to visit. 
> 
> You would need to pin the next-to-visit memcg as well, so you need a
> cleanup on the removal.

But that'd be one of the descendants of the said cgroup and there can
no descendant left when the cgroup is being removed.  What am I
missing?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
