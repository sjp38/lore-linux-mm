Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id CE6686B005C
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 02:20:59 -0400 (EDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 15 Jun 2012 11:50:56 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5F6Ks7u13697458
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 11:50:54 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5FBpOWc029754
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 21:51:26 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V9 09/15] mm/hugetlb: Add new HugeTLB cgroup
In-Reply-To: <4FD9A6B6.50503@huawei.com>
References: <1339583254-895-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1339583254-895-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <4FD9A6B6.50503@huawei.com>
Date: Fri, 15 Jun 2012 11:50:52 +0530
Message-ID: <87mx45m6yj.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

Li Zefan <lizefan@huawei.com> writes:

>> +static inline
>
>> +struct hugetlb_cgroup *hugetlb_cgroup_from_css(struct cgroup_subsys_state *s)
>> +{
>> +	if (s)
>
>
> Neither cgroup_subsys_state() or task_subsys_state() will ever return NULL,
> so here 's' won't be NULL.
>

That is a change that didn't get updated when i dropped page_cgroup
changes. I had a series that tracked in page_cgroup
cgroup_subsys_state. I will send an fix on top.

Thanks for the review.
-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
