Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 6EE166B0044
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 12:06:48 -0400 (EDT)
Received: by dakh32 with SMTP id h32so2927225dak.9
        for <linux-mm@kvack.org>; Thu, 12 Apr 2012 09:06:47 -0700 (PDT)
Date: Thu, 12 Apr 2012 09:06:42 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v1 0/7] memcg remove pre_destroy
Message-ID: <20120412160642.GA13069@google.com>
References: <4F86B9BE.8000105@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F86B9BE.8000105@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Glauber Costa <glommer@parallels.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>

Hello, KAMEZAWA.

Thanks a lot for doing this.

On Thu, Apr 12, 2012 at 08:17:18PM +0900, KAMEZAWA Hiroyuki wrote:
> In recent discussion, Tejun Heo, cgroup maintainer, has a plan to remove
> ->pre_destroy(). And now, in cgroup tree, pre_destroy() failure cause WARNING.

Just to clarify, I'm not intending to ->pre_destroy() per-se but the
retry behavior of it, so ->pre_destroy() will be converted to return
void and called once on rmdir and rmdir will proceed no matter what.
Also, with the deprecated behavior flag set, pre_destroy() doesn't
trigger the warning message.

Other than that, if memcg people are fine with the change, I'll be
happy to route the changes through cgroup/for-3.5 and stack rmdir
simplification patches on top.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
