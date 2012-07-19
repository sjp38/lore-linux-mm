Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id BE0F36B004D
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 21:31:39 -0400 (EDT)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 19 Jul 2012 07:01:34 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6J1VV9m6488420
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 07:01:31 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6J70o1w008127
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 17:00:50 +1000
Date: Thu, 19 Jul 2012 09:31:29 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/memcg: wrap mem_cgroup_from_css function
Message-ID: <20120719013129.GC4306@kernel>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <a>
 <1342580730-25703-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20120718143612.e34dd3f3.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120718143612.e34dd3f3.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Gavin Shan <shangw@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org

On Wed, Jul 18, 2012 at 02:36:12PM -0700, Andrew Morton wrote:
>On Wed, 18 Jul 2012 11:05:30 +0800
>Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:
>
>> wrap mem_cgroup_from_css function to clarify get mem cgroup
>> from cgroup_subsys_state.
>
>This certainly adds clarity.
>
>But it also adds a little more type-safety - these container_of() calls
>can be invoked against *any* struct which has a field called "css". 
>With your patch, we add a check that the code is indeed using a
>cgroup_subsys_state*.  A small thing, but it's all good.
>
>
>I changed the patch title to the more idiomatic "memcg: add
>mem_cgroup_from_css() helper" and rewrote the changelog to
>
>: Add a mem_cgroup_from_css() helper to replace open-coded invokations of
>: container_of().  To clarify the code and to add a little more type safety.
>
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -396,6 +396,12 @@ static void mem_cgroup_put(struct mem_cgroup *memcg);
>>  #include <net/sock.h>
>>  #include <net/ip.h>
>>  
>> +static inline
>> +struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *s)
>> +{
>> +	return container_of(s, struct mem_cgroup, css);
>> +}
>
>And with great self-control, I avoided renaming this to
>memcg_from_css().  Sigh.  I guess all that extra typing has cardio
>benefits.

Thank you for your time, Andrew. :-)

Thanks & Best Regards,
Wanpeng Li

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
