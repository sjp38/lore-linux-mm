Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 874006B004A
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 10:40:47 -0400 (EDT)
Message-ID: <4F980C81.5060802@parallels.com>
Date: Wed, 25 Apr 2012 11:38:57 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 09/23] kmem slab accounting basic infrastructure
References: <1334959051-18203-1-git-send-email-glommer@parallels.com> <1334959051-18203-10-git-send-email-glommer@parallels.com> <4F975430.4090107@jp.fujitsu.com>
In-Reply-To: <4F975430.4090107@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>

On 04/24/2012 10:32 PM, KAMEZAWA Hiroyuki wrote:
> (2012/04/21 6:57), Glauber Costa wrote:
> 
>> This patch adds the basic infrastructure for the accounting of the slab
>> caches. To control that, the following files are created:
>>
>>   * memory.kmem.usage_in_bytes
>>   * memory.kmem.limit_in_bytes
>>   * memory.kmem.failcnt
>>   * memory.kmem.max_usage_in_bytes
>>
>> They have the same meaning of their user memory counterparts. They reflect
>> the state of the "kmem" res_counter.
>>
>> The code is not enabled until a limit is set. This can be tested by the flag
>> "kmem_accounted". This means that after the patch is applied, no behavioral
>> changes exists for whoever is still using memcg to control their memory usage.
>>
> 
> Hmm, res_counter never goes naeative ?

Why would it?

This one has more or less the same logic as the sock buffers.

If we are not accounted, the caches don't get created. If the caches
don't get created, we don't release them. (this is modulo bugs, of course)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
