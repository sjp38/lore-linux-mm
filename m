Message-ID: <47CFAD69.6000909@openvz.org>
Date: Thu, 06 Mar 2008 11:38:01 +0300
From: Pavel Emelyanov <xemul@openvz.org>
MIME-Version: 1.0
Subject: Re: [RFC/PATCH] cgroup swap subsystem
References: <47CE36A9.3060204@mxp.nes.nec.co.jp>	<47CE5AE2.2050303@openvz.org>	<Pine.LNX.4.64.0803051400000.22243@blonde.site>	<47CEAAB4.8070208@openvz.org>	<20080306093324.77c6d7f4.kamezawa.hiroyu@jp.fujitsu.com>	<47CFA941.4070507@openvz.org> <20080306173347.f6c5c84c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080306173347.f6c5c84c.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, balbir@linux.vnet.ibm.com
Cc: Hugh Dickins <hugh@veritas.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, containers@lists.osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Thu, 06 Mar 2008 11:20:17 +0300
> Pavel Emelyanov <xemul@openvz.org> wrote:
> 
>> KAMEZAWA Hiroyuki wrote:
>>> On Wed, 05 Mar 2008 17:14:12 +0300
>>> Pavel Emelyanov <xemul@openvz.org> wrote:
>>>>> Strongly agree.  Nobody's interested in swap as such: it's just
>>>>> secondary memory, where RAM is primary memory.  People want to
>>>>> control memory as the sum of the two; and I expect they may also
>>>>> want to control primary memory (all that the current memcg does)
>>>>> within that.  I wonder if such nesting of limits fits easily
>>>>> into cgroups or will be problematic.
>>>> This nesting would affect the res_couter abstraction, not the
>>>> cgroup infrastructure. Current design of resource counters doesn't
>>>> allow for such thing, but the extension is a couple-of-lines patch :)
>>>>
>>> IMHO, keeping res_counter simple is better.
>>>
>>> Is this kind of new entry in mem_cgroup not good ?
>>> ==
>>> struct mem_cgroup {
>>> 	...
>>> 	struct res_counter	memory_limit.
>>> 	struct res_counter	swap_limit.
>>> 	..
>>> }
>> I meant the same thing actually. By "nesting would affect" I
>> meant, that we might want to make res_counters hierarchical.
>>
>> That would kill two birds with one stone - we will make a true
>> hierarchical memory accounting and let charging of two counters
>> with one call.
> 
> Hierarchical res_counter makes sense.
> Making it in simple/reasonable style will be our challenge. 

I have this in my TODO list. Since this is not so urgent, then if you
don't mind I can prepare the patches next week - after I set the git 
tree up. This change doesn't seem that big.

> Thanks,
> -Kame
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
