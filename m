Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 16AAE6B0002
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 06:02:57 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 715403EE0AE
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 19:02:55 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 568A245DE52
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 19:02:55 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F6D545DE4F
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 19:02:55 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 339EA1DB8042
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 19:02:55 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D88401DB803E
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 19:02:54 +0900 (JST)
Message-ID: <51595B3C.5090900@jp.fujitsu.com>
Date: Mon, 01 Apr 2013 19:02:36 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: implement boost mode
References: <1364801670-10241-1-git-send-email-glommer@parallels.com> <51595311.7070509@jp.fujitsu.com> <515953AE.3000403@parallels.com> <20130401093740.GA30749@dhcp22.suse.cz>
In-Reply-To: <20130401093740.GA30749@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>

(2013/04/01 18:37), Michal Hocko wrote:
> On Mon 01-04-13 13:30:22, Glauber Costa wrote:
>> On 04/01/2013 01:27 PM, Kamezawa Hiroyuki wrote:
>>> (2013/04/01 16:34), Glauber Costa wrote:
>>>> There are scenarios in which we would like our programs to run faster.
>>>> It is a hassle, when they are contained in memcg, that some of its
>>>> allocations will fail and start triggering reclaim. This is not good
>>>> for the program, that will now be slower.
>>>>
>>>> This patch implements boost mode for memcg. It exposes a u64 file
>>>> "memcg boost". Every time you write anything to it, it will reduce the
>>>> counters by ~20 %. Note that we don't want to actually reclaim pages,
>>>> which would defeat the very goal of boost mode. We just make the
>>>> res_counters able to accomodate more.
>>>>
>>>> This file is also available in the root cgroup. But with a slightly
>>>> different effect. Writing to it will make more memory physically
>>>> available so our programs can profit.
>>>>
>>>> Please ack and apply.
>>>>
>>> Nack.
>>>
>>>> Signed-off-by: Glauber Costa <glommer@parallels.com>
>>>
>>> Please update limit temporary. If you need call-shrink-explicitly-by-user,
>>> I think you can add it.
>>>
>>
>> I don't want to shrink memory because that will make applications
>> slower. I want them to be faster, so they need to have more memory.
>> There is solid research backing up my approach:
>> http://www.dilbert.com/fast/2008-05-08/
>
> :)
>
;)

-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
