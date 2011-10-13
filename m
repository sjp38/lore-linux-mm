Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id ED32E6B0037
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 04:26:26 -0400 (EDT)
Message-ID: <4E96A091.4000705@parallels.com>
Date: Thu, 13 Oct 2011 12:25:53 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 3/8] foundations of per-cgroup memory pressure controlling.
References: <1318242268-2234-1-git-send-email-glommer@parallels.com> <1318242268-2234-4-git-send-email-glommer@parallels.com> <20111013145353.161009ea.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111013145353.161009ea.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org

On 10/13/2011 09:53 AM, KAMEZAWA Hiroyuki wrote:
> On Mon, 10 Oct 2011 14:24:23 +0400
> Glauber Costa<glommer@parallels.com>  wrote:
>
>> This patch converts struct sock fields memory_pressure,
>> memory_allocated, sockets_allocated, and sysctl_mem (now prot_mem)
>> to function pointers, receiving a struct mem_cgroup parameter.
>>
>> enter_memory_pressure is kept the same, since all its callers
>> have socket a context, and the kmem_cgroup can be derived from
>> the socket itself.
>>
>> To keep things working, the patch convert all users of those fields
>> to use acessor functions.
>>
>> In my benchmarks I didn't see a significant performance difference
>> with this patch applied compared to a baseline (around 1 % diff, thus
>> inside error margin).
>>
>> Signed-off-by: Glauber Costa<glommer@parallels.com>
>> CC: David S. Miller<davem@davemloft.net>
>> CC: Hiroyouki Kamezawa<kamezawa.hiroyu@jp.fujitsu.com>
>> CC: Eric W. Biederman<ebiederm@xmission.com>
>
> Reviewed-by: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
>
> a nitpick.
>
>
>>   #ifdef CONFIG_INET
>> +enum {
>> +	UNDER_LIMIT,
>> +	OVER_LIMIT,
>> +};
>> +
>
> It may be better to move this to res_counter.h or memcontrol.h
>
Sorry Kame,

It is in memcontrol.h already. What exactly do you mean here ?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
