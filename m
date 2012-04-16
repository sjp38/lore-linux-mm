Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id F06ED6B0044
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 18:38:04 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so8645168pbc.14
        for <linux-mm@kvack.org>; Mon, 16 Apr 2012 15:38:04 -0700 (PDT)
Date: Mon, 16 Apr 2012 15:38:00 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 6/7] memcg: remove pre_destroy()
Message-ID: <20120416223800.GF12421@google.com>
References: <4F86B9BE.8000105@jp.fujitsu.com>
 <4F86BCCE.5050802@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F86BCCE.5050802@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Glauber Costa <glommer@parallels.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>

Hello,

On Thu, Apr 12, 2012 at 08:30:22PM +0900, KAMEZAWA Hiroyuki wrote:
> +/*
> + * This function is called after ->destroy(). So, we cannot access cgroup
> + * of this memcg.
> + */
> +static void mem_cgroup_recharge(struct work_struct *work)

So, ->pre_destroy per-se isn't gonna go away.  It's just gonna be this
callback which cgroup core uses to unilaterally notify that the cgroup
is going away, so no need to do this cleanup asynchronously from
->destroy().  It's okay to keep doing it synchronously from
->pre_destroy().  The only thing is that it can't fail.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
