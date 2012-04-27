Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id A8D316B00F0
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 14:16:47 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so1545260pbc.14
        for <linux-mm@kvack.org>; Fri, 27 Apr 2012 11:16:47 -0700 (PDT)
Date: Fri, 27 Apr 2012 11:16:42 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC][PATCH 0/7 v2] memcg: prevent failure in pre_destroy()
Message-ID: <20120427181642.GG26595@google.com>
References: <4F9A327A.6050409@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F9A327A.6050409@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Glauber Costa <glommer@parallels.com>, Han Ying <yinghan@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyuki@gmail.com

Hello,

On Fri, Apr 27, 2012 at 02:45:30PM +0900, KAMEZAWA Hiroyuki wrote:
> This is a v2 patch for preventing failure in memcg->pre_destroy().
> With this patch, ->pre_destroy() will never return error code and
> users will not see warning at rmdir(). And this work will simplify
> memcg->pre_destroy(), largely.
> 
> This patch is based on linux-next + hugetlb memory control patches.

Ergh... can you please set up a git branch somewhere for review
purposes?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
