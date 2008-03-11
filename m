Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id m2BFxxiF010630
	for <linux-mm@kvack.org>; Wed, 12 Mar 2008 02:59:59 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2BFxn9r1388588
	for <linux-mm@kvack.org>; Wed, 12 Mar 2008 02:59:49 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2BFxm19027292
	for <linux-mm@kvack.org>; Wed, 12 Mar 2008 02:59:49 +1100
Message-ID: <47D6AC6A.1060404@linux.vnet.ibm.com>
Date: Tue, 11 Mar 2008 21:29:38 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] Make res_counter hierarchical
References: <47D16004.7050204@openvz.org> <20080308134514.434f38f4.kamezawa.hiroyu@jp.fujitsu.com> <47D63FBC.1010805@openvz.org> <6599ad830803110157u71fe6c3cse125d0202610413b@mail.gmail.com> <20080311181325.c0bf6b90.kamezawa.hiroyu@jp.fujitsu.com> <6599ad830803110211u1cb48874l30aa75d21dc2b23@mail.gmail.com> <47D64E0A.3090907@linux.vnet.ibm.com> <6599ad830803110856j5333f032n2e26fb51111a839c@mail.gmail.com>
In-Reply-To: <6599ad830803110856j5333f032n2e26fb51111a839c@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Linux Containers <containers@lists.osdl.org>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On Tue, Mar 11, 2008 at 2:16 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>> Paul Menage wrote:
>>  > On Tue, Mar 11, 2008 at 2:13 AM, KAMEZAWA Hiroyuki
>>  > <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>  >>  or remove all relationship among counters of *different* type of resources.
>>  >>  user-land-daemon will do enough jobs.
>>  >>
>>  >
>>  > Yes, that would be my preferred choice, if people agree that
>>  > hierarchically limiting overall virtual memory isn't useful. (I don't
>>  > think I have a use for it myself).
>>  >
>>
>>  Virtual limits are very useful. I have a patch ready to send out.
>>  They limit the amount of paging a cgroup can do (virtual limit - RSS limit).
> 
> Ah, from this should I assume that you're talking about virtual
> address space limits, not virtual memory limits?
> 
> My comment above was referring to Pavel's proposal to limit total
> virtual memory (RAM + swap) for a cgroup, and then limit swap as a
> subset of that, which basically makes it impossible to limit the RAM
> usage of cgroups properly if you also want to allow swap usage.
> 
> Virtual address space limits are somewhat orthogonal to that.
> 


Yes, I was referring to Virtual address limits (along the lines of RLIMIT_AS). I
guess it's just confusing terminology. I have patches for Virtual address
limits. I should send them out soon.


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
