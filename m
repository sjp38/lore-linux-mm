Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 387CD6B006C
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 09:32:40 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id bj3so1980814pad.14
        for <linux-mm@kvack.org>; Thu, 22 Nov 2012 06:32:39 -0800 (PST)
Date: Thu, 22 Nov 2012 06:32:29 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/2] cgroup: helper do determine group name
Message-ID: <20121122143229.GA15930@mtj.dyndns.org>
References: <1353580190-14721-1-git-send-email-glommer@parallels.com>
 <1353580190-14721-2-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1353580190-14721-2-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, kamezawa.hiroyu@jp.fujitsu.com

On Thu, Nov 22, 2012 at 02:29:49PM +0400, Glauber Costa wrote:
> With more than one user, it is useful to have a helper function in the
> cgroup core to derive a group's name.
> 
> We'll just return a pointer, and it is not expected to get incredibly
> complicated. But it is useful to have it so we can abstract away the
> vfs relation from its users.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: Tejun Heo <tj@kernel.org>
> CC: Michal Hocko <mhocko@suse.cz>
> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Johannes Weiner <hannes@cmpxchg.org>
> ---
> Tejun:
> 
> I know the rcu is no longer necessary. I am using mhocko's tree,
> that doesn't seem to have your last stream of patches yet. If you
> approve the interface, we'll need a follow up on this to remove the
> rcu dereference of the dentry.

Yeap, looks good to me, but please add function comment on it.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
