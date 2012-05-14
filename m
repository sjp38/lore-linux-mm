Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 40B366B00F5
	for <linux-mm@kvack.org>; Mon, 14 May 2012 14:16:01 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so9275339pbb.14
        for <linux-mm@kvack.org>; Mon, 14 May 2012 11:16:00 -0700 (PDT)
Date: Mon, 14 May 2012 11:15:56 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 1/6] memcg: fix error code in
 hugetlb_force_memcg_empty()
Message-ID: <20120514181556.GE2366@google.com>
References: <4FACDED0.3020400@jp.fujitsu.com>
 <4FACDFAE.5050808@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FACDFAE.5050808@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Han Ying <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Linux Kernel <linux-kernel@vger.kernel.org>

On Fri, May 11, 2012 at 06:45:18PM +0900, KAMEZAWA Hiroyuki wrote:
> -		if (cgroup_task_count(cgroup) || !list_empty(&cgroup->children))
> +		if (cgroup_task_count(cgroup)
> +			|| !list_empty(&cgroup->children)) {
> +			ret = -EBUSY;
>  			goto out;

Why break the line?  It doesn't go over 80 col.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
