Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 2BFF06B00EA
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 08:12:52 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id C70EB3EE0C2
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 21:12:50 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id AC97845DD78
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 21:12:50 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 807A045DE50
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 21:12:50 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 710281DB8042
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 21:12:50 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 241651DB803C
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 21:12:50 +0900 (JST)
Message-ID: <4F67225B.9010002@jp.fujitsu.com>
Date: Mon, 19 Mar 2012 21:11:07 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/3] memcg: add methods to access pc->mem_cgroup
References: <4F66E6A5.10804@jp.fujitsu.com> <4F66E773.4000807@jp.fujitsu.com> <4F671138.3000508@parallels.com>
In-Reply-To: <4F671138.3000508@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Han Ying <yinghan@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, suleiman@google.com, n-horiguchi@ah.jp.nec.com, khlebnikov@openvz.org, Tejun Heo <tj@kernel.org>

(2012/03/19 19:58), Glauber Costa wrote:

> On 03/19/2012 11:59 AM, KAMEZAWA Hiroyuki wrote:
>> In order to encode pc->mem_cgroup and pc->flags to be in a word,
>> access function to pc->mem_cgroup is required.
>>
>> This patch replaces access to pc->mem_cgroup with
>>   pc_to_mem_cgroup(pc)          : pc->mem_cgroup
>>   pc_set_mem_cgroup(pc, memcg)  : pc->mem_cgroup = memcg
>>
>> Following patch will remove pc->mem_cgroup.
>>
>> Signed-off-by: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> Kame,
> 
> I can't see a reason not to merge this patch right now, regardless of
> the other ones.
> 

Ok, if names of functions seems good, I'll post again.

Thanks,
-Kame 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
