Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 40D206B005A
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 11:37:29 -0400 (EDT)
Date: Tue, 26 Jun 2012 17:37:19 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] memcg: first step towards hierarchical controller
Message-ID: <20120626153719.GC27816@cmpxchg.org>
References: <1340717428-9009-1-git-send-email-glommer@parallels.com>
 <20120626141127.GA27816@cmpxchg.org>
 <4FE9D5C9.805@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FE9D5C9.805@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>

On Tue, Jun 26, 2012 at 07:31:21PM +0400, Glauber Costa wrote:
> On 06/26/2012 06:11 PM, Johannes Weiner wrote:
> >I find the warning message a bit terse.  Maybe include something like
> >"restructure the cgroup directory structure to match your accounting
> >requirements or complain to (linux-mm, cgroups list etc.)  if not
> >possible"
> 
> How about:
> 
> WARN_ONCE(!parent_memcg && memcg->use_hierarchy,
>    "Non-hierarchical memcg is considered for deprecation\n"
>    "Please consider reorganizing your tree to work with hierarchical
> accounting\n"
>    "If you have any reason not to, let us know at
> cgroups@vger.kernel.org\n");

Sounds good to me, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
