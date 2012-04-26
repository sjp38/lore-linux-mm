Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 0D6F96B0044
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 20:10:31 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 7D2C43EE0BC
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 09:10:30 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 642252AEA83
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 09:10:30 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3EC7B266CC1
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 09:10:30 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 25F381DB8044
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 09:10:30 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D2E801DB803F
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 09:10:29 +0900 (JST)
Message-ID: <4F989207.5080208@jp.fujitsu.com>
Date: Thu, 26 Apr 2012 09:08:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 09/23] kmem slab accounting basic infrastructure
References: <1334959051-18203-1-git-send-email-glommer@parallels.com> <1334959051-18203-10-git-send-email-glommer@parallels.com> <4F975430.4090107@jp.fujitsu.com> <4F980C81.5060802@parallels.com>
In-Reply-To: <4F980C81.5060802@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>

(2012/04/25 23:38), Glauber Costa wrote:

> On 04/24/2012 10:32 PM, KAMEZAWA Hiroyuki wrote:
>> (2012/04/21 6:57), Glauber Costa wrote:
>>
>>> This patch adds the basic infrastructure for the accounting of the slab
>>> caches. To control that, the following files are created:
>>>
>>>   * memory.kmem.usage_in_bytes
>>>   * memory.kmem.limit_in_bytes
>>>   * memory.kmem.failcnt
>>>   * memory.kmem.max_usage_in_bytes
>>>
>>> They have the same meaning of their user memory counterparts. They reflect
>>> the state of the "kmem" res_counter.
>>>
>>> The code is not enabled until a limit is set. This can be tested by the flag
>>> "kmem_accounted". This means that after the patch is applied, no behavioral
>>> changes exists for whoever is still using memcg to control their memory usage.
>>>
>>
>> Hmm, res_counter never goes naeative ?
> 
> Why would it?
> 
> This one has more or less the same logic as the sock buffers.
> 
> If we are not accounted, the caches don't get created. If the caches
> don't get created, we don't release them. (this is modulo bugs, of course)

Okay. Please note how the logic works in description or Doc. 
It's a bit complicated part.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
