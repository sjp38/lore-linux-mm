Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 4E2966B0027
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 23:59:12 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id bg2so3570148pad.23
        for <linux-mm@kvack.org>; Mon, 08 Apr 2013 20:59:11 -0700 (PDT)
Date: Mon, 8 Apr 2013 20:59:07 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 13/12] memcg: don't need memcg->memcg_name
Message-ID: <20130409035907.GA4565@mtj.dyndns.org>
References: <5162648B.9070802@huawei.com>
 <51626584.7050405@huawei.com>
 <5163868B.3020905@jp.fujitsu.com>
 <5163887D.1040809@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5163887D.1040809@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

On Tue, Apr 09, 2013 at 11:18:21AM +0800, Li Zefan wrote:
> >> -		if (memcg->memcg_name)
> >> -			seq_printf(m, "%s:\n", memcg->memcg_name);
> >> +		ret = cgroup_path(memcg->css.cgroup, memcg_name, PAGE_SIZE);
> >> +		if (!ret)
> >> +			seq_printf(m, "%s:\n", memcg_name);
> >>   		else
> >>   			seq_printf(m, "%p (name lost):\n", memcg);
> >>   
> > 
> > I'm sorry for dawm question ...when this error happens ?
> > We may get ENAMETOOLONG even with PAGE_SIZE(>=4096bytes) buffer ?
> > 
> 
> It does no harm to check the return value, and we don't have to
> worry about if cgroup_path() will be changed to return some other
> errno like ENOMEM in the future.

Maybe change the function to return the length of the path regardless
of the specified buffer length?  ie. as in snprintf()?

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
