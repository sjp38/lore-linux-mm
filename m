Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 42F096B0044
	for <linux-mm@kvack.org>; Tue, 20 Mar 2012 21:08:18 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id D36673EE0B5
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 10:08:16 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id BC05B45DE52
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 10:08:16 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A666E45DE4D
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 10:08:16 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9B376E08002
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 10:08:16 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 553471DB8037
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 10:08:16 +0900 (JST)
Message-ID: <4F692997.50901@jp.fujitsu.com>
Date: Wed, 21 Mar 2012 10:06:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/3] memcg: add methods to access pc->mem_cgroup
References: <4F66E6A5.10804@jp.fujitsu.com> <4F66E773.4000807@jp.fujitsu.com> <4F671138.3000508@parallels.com> <20120319153334.GC31213@tiehlicka.suse.cz>
In-Reply-To: <20120319153334.GC31213@tiehlicka.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Han Ying <yinghan@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, suleiman@google.com, n-horiguchi@ah.jp.nec.com, khlebnikov@openvz.org, Tejun Heo <tj@kernel.org>

(2012/03/20 0:33), Michal Hocko wrote:

> On Mon 19-03-12 14:58:00, Glauber Costa wrote:
>> On 03/19/2012 11:59 AM, KAMEZAWA Hiroyuki wrote:
>>> In order to encode pc->mem_cgroup and pc->flags to be in a word,
>>> access function to pc->mem_cgroup is required.
>>>
>>> This patch replaces access to pc->mem_cgroup with
>>>   pc_to_mem_cgroup(pc)          : pc->mem_cgroup
>>>   pc_set_mem_cgroup(pc, memcg)  : pc->mem_cgroup = memcg
>>>
>>> Following patch will remove pc->mem_cgroup.
>>>
>>> Signed-off-by: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
>> Kame,
>>
>> I can't see a reason not to merge this patch right now, regardless of
>> the other ones.
>  
> I am not so sure about that. The patch doesn't do much on its own and
> reference to the "following patch" might be confusing. Does it actually
> help to rush it now?


Hm. it sounds I should post full series (removing RFC) and finish
page cgroup diet all ASAP.

I'll continue updates and tests.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
