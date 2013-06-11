Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 3F6AC6B0033
	for <linux-mm@kvack.org>; Tue, 11 Jun 2013 04:00:57 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id kx10so2941903pab.27
        for <linux-mm@kvack.org>; Tue, 11 Jun 2013 01:00:56 -0700 (PDT)
Date: Tue, 11 Jun 2013 01:00:49 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/3] memcg: simplify mem_cgroup_reclaim_iter
Message-ID: <20130611080049.GF22530@mtj.dyndns.org>
References: <20130607005242.GB16160@htj.dyndns.org>
 <20130607073754.GA8117@dhcp22.suse.cz>
 <20130607232557.GL14781@mtj.dyndns.org>
 <20130610080208.GB5138@dhcp22.suse.cz>
 <20130610195426.GC12461@mtj.dyndns.org>
 <20130610204801.GA21003@dhcp22.suse.cz>
 <20130610231358.GD12461@mtj.dyndns.org>
 <20130611072743.GB24031@dhcp22.suse.cz>
 <20130611074404.GE22530@mtj.dyndns.org>
 <20130611075540.GD24031@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130611075540.GD24031@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, bsingharora@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, lizefan@huawei.com

Hello,

On Tue, Jun 11, 2013 at 09:55:40AM +0200, Michal Hocko wrote:
> > Anyways, I think we're getting too deep into details but one more
> > thing, what do you mean by "non-NULL new cache"?
> 
> If you replace cached memcg by a new (non-NULL) one then all the parents
> up the hierarchy can reuse the same replacement and do not have to
> search again.

As finding the next one to visit is pretty cheap, it isn't likely to
be a big difference but yeah we can definitely re-use the first
non-NULL next for all further ancestors.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
