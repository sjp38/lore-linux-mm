Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id EE4F86B0044
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 18:41:23 -0400 (EDT)
Received: by dakh32 with SMTP id h32so8041262dak.9
        for <linux-mm@kvack.org>; Mon, 16 Apr 2012 15:41:23 -0700 (PDT)
Date: Mon, 16 Apr 2012 15:41:18 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v1 0/7] memcg remove pre_destroy
Message-ID: <20120416224118.GG12421@google.com>
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

On Thu, Apr 12, 2012 at 08:17:18PM +0900, KAMEZAWA Hiroyuki wrote:
> In recent discussion, Tejun Heo, cgroup maintainer, has a plan to remove
> ->pre_destroy(). And now, in cgroup tree, pre_destroy() failure cause WARNING.

I did a pretty shallow review of the patchset and other than the
unnecessary async destruction, my complaints are mostly trivial.  Ooh,
and the patchset doesn't apply cleanly on top of cgroup/for-3.5.

  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git for-3.5

Thank you!

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
