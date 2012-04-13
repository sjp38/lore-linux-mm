Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 551C46B004A
	for <linux-mm@kvack.org>; Fri, 13 Apr 2012 18:19:30 -0400 (EDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sat, 14 Apr 2012 03:49:24 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3DMJMJO1908940
	for <linux-mm@kvack.org>; Sat, 14 Apr 2012 03:49:22 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3E3nARY015936
	for <linux-mm@kvack.org>; Sat, 14 Apr 2012 13:49:10 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v1 0/7] memcg remove pre_destroy
In-Reply-To: <20120413085014.GA9205@tiehlicka.suse.cz>
References: <4F86B9BE.8000105@jp.fujitsu.com> <20120412160642.GA13069@google.com> <877gxksrq1.fsf@skywalker.in.ibm.com> <4F876C70.7060600@jp.fujitsu.com> <20120413085014.GA9205@tiehlicka.suse.cz>User-Agent: Notmuch/0.11.1+346~g13d19c3 (http://notmuchmail.org) Emacs/23.3.1 (x86_64-pc-linux-gnu)
Date: Sat, 14 Apr 2012 03:49:15 +0530
Message-ID: <87vcl3gtr0.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Tejun Heo <tj@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Glauber Costa <glommer@parallels.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>

Michal Hocko <mhocko@suse.cz> writes:

> On Fri 13-04-12 08:59:44, KAMEZAWA Hiroyuki wrote:
>> (2012/04/13 3:57), Aneesh Kumar K.V wrote:
>> 
>> > Tejun Heo <tj@kernel.org> writes:
>> > 
>> >> Hello, KAMEZAWA.
>> >>
>> >> Thanks a lot for doing this.
>> >>
>> >> On Thu, Apr 12, 2012 at 08:17:18PM +0900, KAMEZAWA Hiroyuki wrote:
>> >>> In recent discussion, Tejun Heo, cgroup maintainer, has a plan to remove
>> >>> ->pre_destroy(). And now, in cgroup tree, pre_destroy() failure cause WARNING.
>> >>
>> >> Just to clarify, I'm not intending to ->pre_destroy() per-se but the
>> >> retry behavior of it, so ->pre_destroy() will be converted to return
>> >> void and called once on rmdir and rmdir will proceed no matter what.
>> >> Also, with the deprecated behavior flag set, pre_destroy() doesn't
>> >> trigger the warning message.
>> >>
>> >> Other than that, if memcg people are fine with the change, I'll be
>> >> happy to route the changes through cgroup/for-3.5 and stack rmdir
>> >> simplification patches on top.
>> >>
>> > 
>> > Any suggestion on how to take HugeTLB memcg extension patches [1]
>> > upstream. Current patch series I have is on top of cgroup/for-3.5
>> > because I need cgroup_add_files equivalent and cgroup/for-3.5 have
>> > changes around that. So if these memcg patches can also go on top of
>> > cgroup/for-3.5 then I can continue to work on top of cgroup/for-3.5 ?
>
> I would suggest working on top of memcg-devel tree or on top linux-next.
> Just pull the required patch-es from cgroup/for-3.5 tree before your
> work (I can include that into memcg-devel tree for you if you want).

I am expecting to have no conflicts with pending memcg changes. But I do
have conflicts with cgroup/for-3.5. That is the reason I decided to
rebase on top of cgroup/for-3.5. 


>
> Do you think this is a 3.5 material? I would rather wait some more. I
> didn't have time to look over it yet and there are still some unresolved
> issues so it sounds like too early for merging.


I would really like to get it merged for 3.5. I am ready to post V6 that
address all review feedback from V5 post. 


>
>> > Can HugeTLB memcg extension patches also go via this tree ? It
>> > should actually got via -mm. But then how do we take care of these
>> > dependencies ?
>
> You are not changing anything generic from cgroup so definitely go via
> Andrew.
>

agreed.


>> I'm not in hurry. To be honest, I cannot update patches until the next Wednesday.
>> So, If changes of cgroup tree you required are included in linux-next. Please post
>> your updated ones. I thought your latest version was near to be merged....
>> 
>> How do you think, Michal ?
>> Please post (and ask Andrew to pull it.) I'll review when I can.
>
> I would wait with pulling the patch after the review.
>

agreed. So I will do a v6 post and if we all agree with the changes it
can be pulled via -mm ?


>> I know yours and mine has some conflicts. I think my this series will
>> be onto your series. To do that, I hope your series are merged to
>> linux-next, 1st.
>> 

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
