Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 615206B004A
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 20:01:48 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 7F1193EE0BC
	for <linux-mm@kvack.org>; Fri, 13 Apr 2012 09:01:46 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6806745DE53
	for <linux-mm@kvack.org>; Fri, 13 Apr 2012 09:01:46 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5350245DE54
	for <linux-mm@kvack.org>; Fri, 13 Apr 2012 09:01:46 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 469211DB8044
	for <linux-mm@kvack.org>; Fri, 13 Apr 2012 09:01:46 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id EF29A1DB804E
	for <linux-mm@kvack.org>; Fri, 13 Apr 2012 09:01:45 +0900 (JST)
Message-ID: <4F876C70.7060600@jp.fujitsu.com>
Date: Fri, 13 Apr 2012 08:59:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v1 0/7] memcg remove pre_destroy
References: <4F86B9BE.8000105@jp.fujitsu.com> <20120412160642.GA13069@google.com>User-Agent: Notmuch/0.11.1+346~g13d19c3 (http://notmuchmail.org) Emacs/23.3.1 (x86_64-pc-linux-gnu) <877gxksrq1.fsf@skywalker.in.ibm.com>
In-Reply-To: <877gxksrq1.fsf@skywalker.in.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Tejun Heo <tj@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Glauber Costa <glommer@parallels.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>

(2012/04/13 3:57), Aneesh Kumar K.V wrote:

> Tejun Heo <tj@kernel.org> writes:
> 
>> Hello, KAMEZAWA.
>>
>> Thanks a lot for doing this.
>>
>> On Thu, Apr 12, 2012 at 08:17:18PM +0900, KAMEZAWA Hiroyuki wrote:
>>> In recent discussion, Tejun Heo, cgroup maintainer, has a plan to remove
>>> ->pre_destroy(). And now, in cgroup tree, pre_destroy() failure cause WARNING.
>>
>> Just to clarify, I'm not intending to ->pre_destroy() per-se but the
>> retry behavior of it, so ->pre_destroy() will be converted to return
>> void and called once on rmdir and rmdir will proceed no matter what.
>> Also, with the deprecated behavior flag set, pre_destroy() doesn't
>> trigger the warning message.
>>
>> Other than that, if memcg people are fine with the change, I'll be
>> happy to route the changes through cgroup/for-3.5 and stack rmdir
>> simplification patches on top.
>>
> 
> Any suggestion on how to take HugeTLB memcg extension patches [1]
> upstream. Current patch series I have is on top of cgroup/for-3.5
> because I need cgroup_add_files equivalent and cgroup/for-3.5 have
> changes around that. So if these memcg patches can also go on top of
> cgroup/for-3.5 then I can continue to work on top of cgroup/for-3.5 ?
> 
> Can HugeTLB memcg extension patches also go via this tree ? It
> should actually got via -mm. But then how do we take care of these
> dependencies ?
> 


I'm not in hurry. To be honest, I cannot update patches until the next Wednesday.
So, If changes of cgroup tree you required are included in linux-next. Please post
your updated ones. I thought your latest version was near to be merged....

How do you think, Michal ?
Please post (and ask Andrew to pull it.) I'll review when I can.

I know yours and mine has some conflicts. I think my this series will
be onto your series. To do that, I hope your series are merged to linux-next, 1st.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
