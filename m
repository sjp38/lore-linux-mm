Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id F3A736B0044
	for <linux-mm@kvack.org>; Thu, 16 Aug 2012 06:00:17 -0400 (EDT)
Message-ID: <502CC3F3.5060706@parallels.com>
Date: Thu, 16 Aug 2012 13:57:07 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 06/11] memcg: kmem controller infrastructure
References: <1344517279-30646-1-git-send-email-glommer@parallels.com> <1344517279-30646-7-git-send-email-glommer@parallels.com> <20120814172540.GD6905@dhcp22.suse.cz> <502B6F00.8040207@parallels.com> <20120815130952.GI23985@dhcp22.suse.cz> <502BABCF.7020608@parallels.com> <20120815142338.GL23985@dhcp22.suse.cz> <502BB1E1.5080403@parallels.com> <20120816095309.GB2817@dhcp22.suse.cz>
In-Reply-To: <20120816095309.GB2817@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>

On 08/16/2012 01:53 PM, Michal Hocko wrote:
> On Wed 15-08-12 18:27:45, Glauber Costa wrote:
>>
>>>>
>>>> I see now, you seem to be right.
>>>
>>> No I am not because it seems that I am really blind these days...
>>> We were doing this in mem_cgroup_do_charge for ages:
>>> 	if (!(gfp_mask & __GFP_WAIT))
>>>                 return CHARGE_WOULDBLOCK;
>>>
>>> /me goes to hide and get with further feedback with a clean head.
>>>
>>> Sorry about that.
>>>
>> I am as well, since I went to look at mem_cgroup_do_charge() and missed
>> that.
> 
> I thought we are not doing atomic allocations in user pages accounting
> but I was obviously wrong because at least shmem uses atomic
> allocations for ages.
> 
>> Do you have any other concerns specific to this patch ?
> 
> I understood you changed also handle thingy. So the patch should be
> correct.
> Do you plan to send an updated version?
> 
That depends more on you than on me! =)

Do you still have any concerns regarding the u+k charging as it stands
now? That would be the last big concern I heard during this iteration.

If you are happy with the answers you got so far, and believe it is
acceptable to proceed with the charging this way, I will be ready to
send an updated version soon.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
