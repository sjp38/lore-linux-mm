Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp02.in.ibm.com (8.13.1/8.13.1) with ESMTP id m5U4eWjd004213
	for <linux-mm@kvack.org>; Mon, 30 Jun 2008 10:10:32 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5U4dLd3815348
	for <linux-mm@kvack.org>; Mon, 30 Jun 2008 10:09:21 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id m5U4eVSq009432
	for <linux-mm@kvack.org>; Mon, 30 Jun 2008 10:10:32 +0530
Message-ID: <486863C6.6090304@linux.vnet.ibm.com>
Date: Mon, 30 Jun 2008 10:10:38 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC 0/5] Memory controller soft limit introduction (v3)
References: <20080627151808.31664.36047.sendpatchset@balbir-laptop> <20080628133615.a5fa16cf.kamezawa.hiroyu@jp.fujitsu.com> <4867174B.3090005@linux.vnet.ibm.com> <20080630102054.ee214765.kamezawa.hiroyu@jp.fujitsu.com> <486855DF.2070100@linux.vnet.ibm.com> <20080630125737.4b14785f.kamezawa.hiroyu@jp.fujitsu.com> <48685A72.3090102@linux.vnet.ibm.com> <20080630131920.68d2cc23.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080630131920.68d2cc23.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Mon, 30 Jun 2008 09:30:50 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>> KAMEZAWA Hiroyuki wrote:
>>> Hmm, that is the case where "share" works well. Why soft-limit ?
>>> i/o conroller doesn't support share ? (I don' know sorry.)
>>>
>> Share is a proportional allocation of a resource. Typically that resource is
>> soft-limits, but not necessarily. If we re-use resource counters, my expectation
>> is that
>>
>> A share implementation would under-neath use soft-limits.
>>
> Hmm...I don't convice at this point. (because it's future problem)
> At least, please find lock-less approach to check soft-limit.

I've been looking at improving res_counter scalability. One simple approach is
to convert the spin lock to rw spinlock so that reading data can happen in
parallel. The next step would be to explore RCU for resource counters.

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
