Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id EA3826B005A
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 11:34:05 -0400 (EDT)
Message-ID: <4FE9D5C9.805@parallels.com>
Date: Tue, 26 Jun 2012 19:31:21 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: first step towards hierarchical controller
References: <1340717428-9009-1-git-send-email-glommer@parallels.com> <20120626141127.GA27816@cmpxchg.org>
In-Reply-To: <20120626141127.GA27816@cmpxchg.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>

On 06/26/2012 06:11 PM, Johannes Weiner wrote:
> I find the warning message a bit terse.  Maybe include something like
> "restructure the cgroup directory structure to match your accounting
> requirements or complain to (linux-mm, cgroups list etc.)  if not
> possible"

How about:

WARN_ONCE(!parent_memcg && memcg->use_hierarchy,
    "Non-hierarchical memcg is considered for deprecation\n"
    "Please consider reorganizing your tree to work with hierarchical 
accounting\n"
    "If you have any reason not to, let us know at 
cgroups@vger.kernel.org\n");


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
