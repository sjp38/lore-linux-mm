From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <8387205.1219419279212.kamezawa.hiroyu@jp.fujitsu.com>
Date: Sat, 23 Aug 2008 00:34:39 +0900 (JST)
Subject: Re: Re: [RFC][PATCH 0/14]  Mem+Swap Controller v2
In-Reply-To: <48AEBD06.5060704@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <48AEBD06.5060704@linux.vnet.ibm.com>
 <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

>> 11. memcgrp_id.patch
>>             .... give each mem_cgroup its own ID.
>
>To be honest, I think something like this needs to happen at the cgroups leve
l, no?
>
I think ..yes..maybe. In my patch, this ID is defines as [0-32677] and 0 for
invalid and 1 for root group. So, this is not designed for IDs for the whole
system wide cgroup. Kicking this out from memcontrol.c and move to some
kernel/xxx.c as "cgroup hierarchy ID support" may be an idea.
I'd like to wait for Paul and to hear his opinion.
Anyway, I like this idea (assign short ID to cgrp) for saving space from 8byte
s(pointer) to 2bytes(ID) to record cgroup's account information
in array.


>> 12. swap_cgroup_config.patch
>>             .... Add Kconfig and some macro for Mem+Swap Controller.
>> 13. swap_counter.patch
>>             .... modifies mem_counter to handle swaps.
>> 14. swap_account.patch
>>             .... account swap.
>
>This is too fast for me to review. I'll review this series anyway.
Thanks,

> I was also hoping to getting down to user space notifications for OOM
I want to see this :)

> and pagevec series.
lockless patch incudes operation like pagevec in lazy-lru-free and rcu
patch. It does batched lru operation at uncharge().
(I couldn't find a way to implement bached lru insertion at charge()
 without race condition.)

Thanks,
-Kame

>Let me see if I can do the latter quickly.
>

>-- 
>	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
