Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 6ABA76B02DE
	for <linux-mm@kvack.org>; Sun, 24 Jun 2012 12:45:07 -0400 (EDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sun, 24 Jun 2012 22:15:02 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5OGiwTx61079758
	for <linux-mm@kvack.org>; Sun, 24 Jun 2012 22:14:58 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5OMEVwm005956
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 03:44:32 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V9 11/15] hugetlb/cgroup: Add charge/uncharge routines for hugetlb cgroup
In-Reply-To: <20120622151121.917178eb.akpm@linux-foundation.org>
References: <1339583254-895-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1339583254-895-12-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <4FD9A79D.9030303@huawei.com> <20120622151121.917178eb.akpm@linux-foundation.org>
Date: Sun, 24 Jun 2012 22:14:51 +0530
Message-ID: <87txy07j7g.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizefan@huawei.com>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, mhocko@suse.cz, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org



Hi Andrew,

Andrew Morton <akpm@linux-foundation.org> writes:

> On Thu, 14 Jun 2012 16:58:05 +0800
> Li Zefan <lizefan@huawei.com> wrote:
>
>> > +int hugetlb_cgroup_charge_cgroup(int idx, unsigned long nr_pages,
>> 
>> > +				 struct hugetlb_cgroup **ptr)
>> > +{
>> > +	int ret = 0;
>> > +	struct res_counter *fail_res;
>> > +	struct hugetlb_cgroup *h_cg = NULL;
>> > +	unsigned long csize = nr_pages * PAGE_SIZE;
>> > +
>> > +	if (hugetlb_cgroup_disabled())
>> > +		goto done;
>> > +	/*
>> > +	 * We don't charge any cgroup if the compound page have less
>> > +	 * than 3 pages.
>> > +	 */
>> > +	if (huge_page_order(&hstates[idx]) < HUGETLB_CGROUP_MIN_ORDER)
>> > +		goto done;
>> > +again:
>> > +	rcu_read_lock();
>> > +	h_cg = hugetlb_cgroup_from_task(current);
>> > +	if (!h_cg)
>> 
>> 
>> In no circumstances should h_cg be NULL.
>> 
>
> Aneesh?

I missed this in the last review. Thanks for reminding. I will send a
patch addressing this and another related comment in
4FD9A6B6.50503@huawei.com as a separate mail.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
