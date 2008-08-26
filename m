Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp03.in.ibm.com (8.13.1/8.13.1) with ESMTP id m7Q8ntDR022180
	for <linux-mm@kvack.org>; Tue, 26 Aug 2008 14:19:55 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7Q8ntrQ1806486
	for <linux-mm@kvack.org>; Tue, 26 Aug 2008 14:19:55 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id m7Q8ntP0024648
	for <linux-mm@kvack.org>; Tue, 26 Aug 2008 14:19:55 +0530
Message-ID: <48B3C3B2.3090205@linux.vnet.ibm.com>
Date: Tue, 26 Aug 2008 14:19:54 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 3/14]  memcg: atomic_flags
References: <48B38CDB.1070102@linux.vnet.ibm.com> <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com> <20080822203228.98adf408.kamezawa.hiroyu@jp.fujitsu.com> <27319629.1219740371105.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <27319629.1219740371105.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: linux-mm@kvack.org, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

kamezawa.hiroyu@jp.fujitsu.com wrote:
> ----- Original Message -----
>> KAMEZAWA Hiroyuki wrote:
>>> This patch makes page_cgroup->flags to be atomic_ops and define
>>> functions (and macros) to access it.
>>>
>>> This patch itself makes memcg slow but this patch's final purpose is 
>>> to remove lock_page_cgroup() and allowing fast access to page_cgroup.
>>>
>> That is a cause of worry, do the patches that follow help performance?
> By applying patchs for this and RCU and removing lock_page_cgroup(), I saw sma
> ll performance benefit.
> 
>> How do we
>> benefit from faster access to page_cgroup() if the memcg controller becomes s
> lower?
> No slow-down on my box but. But the cpu which I'm testing on is a bit old.
> I'd like to try newer CPU.
> As you know, I don't like slow-down very much ;)

I see, yes, I do know that you like to make things faster. BTW, you did not
comment on my comments below about the naming convention and using the __ variants
-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
