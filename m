Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id C50EE6B0031
	for <linux-mm@kvack.org>; Fri,  7 Jun 2013 19:26:02 -0400 (EDT)
Received: by mail-qa0-f54.google.com with SMTP id n20so1396003qaj.13
        for <linux-mm@kvack.org>; Fri, 07 Jun 2013 16:26:01 -0700 (PDT)
Date: Fri, 7 Jun 2013 16:25:57 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/3] memcg: simplify mem_cgroup_reclaim_iter
Message-ID: <20130607232557.GL14781@mtj.dyndns.org>
References: <20130605143949.GQ15576@cmpxchg.org>
 <20130605172212.GA10693@mtj.dyndns.org>
 <20130605194552.GI15721@cmpxchg.org>
 <20130605200612.GH10693@mtj.dyndns.org>
 <20130605211704.GJ15721@cmpxchg.org>
 <20130605222021.GL10693@mtj.dyndns.org>
 <20130605222709.GM10693@mtj.dyndns.org>
 <20130606115031.GE7909@dhcp22.suse.cz>
 <20130607005242.GB16160@htj.dyndns.org>
 <20130607073754.GA8117@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130607073754.GA8117@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, bsingharora@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, lizefan@huawei.com

Hello, Michal.

On Fri, Jun 07, 2013 at 09:37:54AM +0200, Michal Hocko wrote:
> > Oh yeah, it is racy.  That's what I meant by "not having to be
> > completely strict".  The race window is small enough and it's not like
> > we're messing up refcnt or may end up with use-after-free. 
> 
> But it would potentially pin (aka leak) the memcg for ever.

It wouldn't be anything systemetic tho - race condition's likliness is
low and increases with the frequency of reclaim iteration, which at
the same time means that it's likely to remedy itself pretty soon.
I'm doubtful it'd matter.  If it's still bothering, we sure can do it
from RCU callback.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
