Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id BA6EF6B005D
	for <linux-mm@kvack.org>; Thu, 16 Aug 2012 22:39:03 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 3B69D3EE0C5
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 11:39:02 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 07A6945DE53
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 11:39:02 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E379E45DD78
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 11:39:01 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D25AA1DB8043
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 11:39:01 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D5F51DB802C
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 11:39:01 +0900 (JST)
Message-ID: <502DAEAA.4000805@jp.fujitsu.com>
Date: Fri, 17 Aug 2012 11:38:34 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 04/11] kmem accounting basic infrastructure
References: <1344517279-30646-1-git-send-email-glommer@parallels.com> <1344517279-30646-5-git-send-email-glommer@parallels.com> <50253EA8.9080205@jp.fujitsu.com> <5028BCA3.6040506@parallels.com>
In-Reply-To: <5028BCA3.6040506@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>

(2012/08/13 17:36), Glauber Costa wrote:
> On 08/10/2012 09:02 PM, Kamezawa Hiroyuki wrote:
>> (2012/08/09 22:01), Glauber Costa wrote:
>>> This patch adds the basic infrastructure for the accounting of the slab
>>> caches. To control that, the following files are created:
>>>
>>>    * memory.kmem.usage_in_bytes
>>>    * memory.kmem.limit_in_bytes
>>>    * memory.kmem.failcnt
>>>    * memory.kmem.max_usage_in_bytes
>>>
>>> They have the same meaning of their user memory counterparts. They
>>> reflect the state of the "kmem" res_counter.
>>>
>>> The code is not enabled until a limit is set. This can be tested by the
>>> flag "kmem_accounted". This means that after the patch is applied, no
>>> behavioral changes exists for whoever is still using memcg to control
>>> their memory usage.
>>>
>>> We always account to both user and kernel resource_counters. This
>>> effectively means that an independent kernel limit is in place when the
>>> limit is set to a lower value than the user memory. A equal or higher
>>> value means that the user limit will always hit first, meaning that kmem
>>> is effectively unlimited.
>>>
>>> People who want to track kernel memory but not limit it, can set this
>>> limit to a very high number (like RESOURCE_MAX - 1page - that no one
>>> will ever hit, or equal to the user memory)
>>>
>>> Signed-off-by: Glauber Costa <glommer@parallels.com>
>>> CC: Michal Hocko <mhocko@suse.cz>
>>> CC: Johannes Weiner <hannes@cmpxchg.org>
>>> Reviewed-by: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>
>> Could you add  a patch for documentation of this new interface and a text
>> explaining the behavior of "kmem_accounting" ?
>>
>> Hm, my concern is the difference of behavior between user page accounting and
>> kmem accounting...but this is how tcp-accounting is working.
>>
>> Once you add Documentation, it's okay to add my Ack.
>>
> I plan to add documentation in a separate patch. Due to that, can I add
> your ack to this patch here?
> 
> Also, I find that the description text in patch0 grew to be quite
> informative and complete. I plan to add that to the documentation
> if that is ok with you
> 

Ack to this patch.

-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
