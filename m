Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp05.au.ibm.com (8.13.1/8.13.1) with ESMTP id m5GCTLxI026721
	for <linux-mm@kvack.org>; Mon, 16 Jun 2008 22:29:21 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5GCTvkY304154
	for <linux-mm@kvack.org>; Mon, 16 Jun 2008 22:29:57 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5GCTusq018133
	for <linux-mm@kvack.org>; Mon, 16 Jun 2008 22:29:57 +1000
Message-ID: <48565CBA.2040309@linux.vnet.ibm.com>
Date: Mon, 16 Jun 2008 17:59:46 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 1/6] res_counter:  handle limit change
References: <48562AFF.9050804@linux.vnet.ibm.com> <20080613182714.265fe6d2.kamezawa.hiroyu@jp.fujitsu.com> <20080613182924.c73fe9eb.kamezawa.hiroyu@jp.fujitsu.com> <400765.1213607050433.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <400765.1213607050433.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, menage@google.com, xemul@openvz.org, yamamoto@valinux.co.jp, nishimura@mxp.nes.nec.co.jp, lizf@cn.fujitsu.com
List-ID: <linux-mm.kvack.org>

kamezawa.hiroyu@jp.fujitsu.com wrote:
> ----- Original Message -----
>> KAMEZAWA Hiroyuki wrote:
>>> Add a support to shrink_usage_at_limit_change feature to res_counter.
>>> memcg will use this to drop pages.
>>>
>>> Change log: xxx -> v4 (new file.)
>>>  - cut out the limit-change part from hierarchy patch set.
>>>  - add "retry_count" arguments to shrink_usage(). This allows that we don't
>>>    have to set the default retry loop count.
>>>  - res_counter_check_under_val() is added to support subsystem.
>>>  - res_counter_init() is res_counter_init_ops(cnt, NULL)
>>>
>>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>>
>> Does shrink_usage() really belong to res_counters? Could a task limiter, a
>> CPU/IO bandwidth controller use this callback? Resource Counters were designe
> d
>> to be generic and work across controllers. Isn't the memory controller a bett
> er
>> place for such ops.
>>
> Definitely No. I think counters which cannot be shrink should return -EBUSY
> by shrink_usage() when it cannot do it. 

Wouldn't that be all counters except for the memory controller RSS counter? I
can't see anyone besides the memory controller supporting shrink_usage().

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
