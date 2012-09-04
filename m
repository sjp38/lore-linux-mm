Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 4CA756B005D
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 14:22:54 -0400 (EDT)
Received: by dadi14 with SMTP id i14so4884518dad.14
        for <linux-mm@kvack.org>; Tue, 04 Sep 2012 11:22:53 -0700 (PDT)
Date: Tue, 4 Sep 2012 11:22:54 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2] memcg: first step towards hierarchical controller
Message-ID: <20120904182254.GA3638@dhcp-172-17-108-109.mtv.corp.google.com>
References: <1346687211-31848-1-git-send-email-glommer@parallels.com>
 <20120903170806.GA21682@dhcp22.suse.cz>
 <5045BD25.10301@parallels.com>
 <20120904130905.GA15683@dhcp22.suse.cz>
 <504601B8.2050907@parallels.com>
 <20120904143552.GB15683@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120904143552.GB15683@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@parallels.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, Dave Jones <davej@redhat.com>, Ben Hutchings <ben@decadent.org.uk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lennart Poettering <lennart@poettering.net>, Kay Sievers <kay.sievers@vrfy.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

Hello,

On Tue, Sep 04, 2012 at 04:35:52PM +0200, Michal Hocko wrote:
...
> The problem is that we don't know whether somebody has an use case which
> cannot be transformed like that. Therefore this patch starts the slow
> transition to hierarchical only memory controller by warning users who
> are using flat hierarchies. The warning triggers only if a subgroup of
> non-root group is created with use_hierarchy==0.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

I think this could work as the first step.  Regardless of the involved
steps, the goal is 1. finding out whether there are use cases or users
of flat hierarchy (ugh... even the name is stupid :) and 2. if so,
push them to stop doing that and give them time to do so.  While
userland growing "echo 1" to use_hierarchy isn't optimal, it isn't the
end of the world and something which can be taken care of by the
distros.

That said, I don't see how different this is from the staged way I
suggested other than requiring "echo 1" instead of a mount option.  At
any rate, the two aren't mutually exclusive and this looks good to me.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
