Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 77D936B004A
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 11:35:51 -0400 (EDT)
Message-ID: <4F6751F8.8070906@parallels.com>
Date: Mon, 19 Mar 2012 19:34:16 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/3] memcg: add methods to access pc->mem_cgroup
References: <4F66E6A5.10804@jp.fujitsu.com> <4F66E773.4000807@jp.fujitsu.com> <4F671138.3000508@parallels.com> <20120319153334.GC31213@tiehlicka.suse.cz>
In-Reply-To: <20120319153334.GC31213@tiehlicka.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Han Ying <yinghan@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, suleiman@google.com, n-horiguchi@ah.jp.nec.com, khlebnikov@openvz.org, Tejun Heo <tj@kernel.org>

On 03/19/2012 07:33 PM, Michal Hocko wrote:
> On Mon 19-03-12 14:58:00, Glauber Costa wrote:
>> On 03/19/2012 11:59 AM, KAMEZAWA Hiroyuki wrote:
>>> In order to encode pc->mem_cgroup and pc->flags to be in a word,
>>> access function to pc->mem_cgroup is required.
>>>
>>> This patch replaces access to pc->mem_cgroup with
>>>    pc_to_mem_cgroup(pc)          : pc->mem_cgroup
>>>    pc_set_mem_cgroup(pc, memcg)  : pc->mem_cgroup = memcg
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

The Changelog can be worked, that's for sure.
But thought as a style change, it does do good IMHO.

Of course this is an argument to get it in as much as it is an argument 
not to...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
