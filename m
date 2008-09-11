From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <29991128.1221137393330.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 11 Sep 2008 21:49:53 +0900 (JST)
Subject: Re: Re: [RFC] [PATCH 9/9] memcg: percpu page cgroup lookup cache
In-Reply-To: <200809112131.34414.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <200809112131.34414.nickpiggin@yahoo.com.au>
 <20080911200855.94d33d3b.kamezawa.hiroyu@jp.fujitsu.com> <20080911202407.752b5731.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, balbir@linux.vnet.ibm.com, xemul@openvz.org, hugh@veritas.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, menage@google.com
List-ID: <linux-mm.kvack.org>

----- Original Message -----
>On Thursday 11 September 2008 21:24, KAMEZAWA Hiroyuki wrote:
>> Use per-cpu cache for fast access to page_cgroup.
>> This patch is for making fastpath faster.
>>
>> Because page_cgroup is accessed when the page is allocated/freed,
>> we can assume several of continuous page_cgroup will be accessed soon.
>> (If not interleaved on NUMA...but in such case, alloc/free itself is slow.)
>>
>> We cache some set of page_cgroup's base pointer on per-cpu area and
>> use it when we hit.
>>
>> TODO:
>>  - memory/cpu hotplug support.
>
>How much does this help?
>
1-2% in unixbench's test (in 0/9) on 2core/1socket x86-64/SMP host.
(cpu is not the newest one.)
This per-cpu covers 32 * 128MB=4GB of area.
Using 256 bytes(32 entry) is over-kill ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
