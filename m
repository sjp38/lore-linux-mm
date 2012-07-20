Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 33CC36B005D
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 15:56:49 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so8278573pbb.14
        for <linux-mm@kvack.org>; Fri, 20 Jul 2012 12:56:48 -0700 (PDT)
Date: Fri, 20 Jul 2012 12:56:43 -0700
From: Tejun Heo <htejun@gmail.com>
Subject: Re: + hugetlb-cgroup-simplify-pre_destroy-callback.patch added to
 -mm tree
Message-ID: <20120720195643.GC21218@google.com>
References: <20120718212637.133475C0050@hpza9.eem.corp.google.com>
 <20120719113915.GC2864@tiehlicka.suse.cz>
 <87r4s8gcwe.fsf@skywalker.in.ibm.com>
 <20120719123820.GG2864@tiehlicka.suse.cz>
 <87ipdjc15j.fsf@skywalker.in.ibm.com>
 <20120720080639.GC12434@tiehlicka.suse.cz>
 <87d33qmeb9.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87d33qmeb9.fsf@skywalker.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Michal Hocko <mhocko@suse.cz>, akpm@linux-foundation.org, mm-commits@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, liwanp@linux.vnet.ibm.com, Li Zefan <lizefan@huawei.com>, cgroups mailinglist <cgroups@vger.kernel.org>, linux-mm@kvack.org

On Sat, Jul 21, 2012 at 12:48:34AM +0530, Aneesh Kumar K.V wrote:
> Does cgroup_rmdir do a cgroup_task_count check ? I do see that it check
> cgroup->childern and cgroup->count. But cgroup->count is not same as
> task_count right ?
> 
> May be we need to push the task_count check also to rmdir so that
> pre_destory doesn't need to check this 

task_count implies cgroup refcnt which cgroup core does check.  No
need to worry about that, ->children or whatever from memcg.  As soon
as the deprecated behavior is gone, everything will be okay;
otherwise, it's a bug in cgroup core.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
