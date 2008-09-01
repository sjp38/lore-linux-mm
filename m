Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id m816Gu4d019138
	for <linux-mm@kvack.org>; Mon, 1 Sep 2008 11:46:56 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m816GphS1699972
	for <linux-mm@kvack.org>; Mon, 1 Sep 2008 11:46:56 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m816GpiG001466
	for <linux-mm@kvack.org>; Mon, 1 Sep 2008 11:46:51 +0530
Message-ID: <48BB88D5.2020109@linux.vnet.ibm.com>
Date: Mon, 01 Sep 2008 11:46:53 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] Remove cgroup member from struct page
References: <20080831174756.GA25790@balbir.in.ibm.com> <20080901090102.46b75141.kamezawa.hiroyu@jp.fujitsu.com> <48BB6160.4070904@linux.vnet.ibm.com> <20080901130351.f005d5b6.kamezawa.hiroyu@jp.fujitsu.com> <20080901141750.37101182.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080901141750.37101182.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, hugh@veritas.com, menage@google.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Mon, 1 Sep 2008 13:03:51 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>> That depends, if we can get the lockless page cgroup done quickly, I don't mind
>>> waiting, but if it is going to take longer, I would rather push these changes
>>> in. 
>> The development of lockless-page_cgroup is not stalled. I'm just waiting for
>> my 8cpu box comes back from maintainance...
>> If you want to see, I'll post v3 with brief result on small (2cpu) box.
>>
> This is current status (result of unixbench.)
> result of 2core/1socket x86-64 system.
> 
> ==
> [disabled]
> Execl Throughput                           3103.3 lps   (29.7 secs, 3 samples)
> C Compiler Throughput                      1052.0 lpm   (60.0 secs, 3 samples)
> Shell Scripts (1 concurrent)               5915.0 lpm   (60.0 secs, 3 samples)
> Shell Scripts (8 concurrent)               1142.7 lpm   (60.0 secs, 3 samples)
> Shell Scripts (16 concurrent)               586.0 lpm   (60.0 secs, 3 samples)
> Dc: sqrt(2) to 99 decimal places         131463.3 lpm   (30.0 secs, 3 samples)
> 
> [rc4mm1]
> Execl Throughput                           3004.4 lps   (29.6 secs, 3 samples)
> C Compiler Throughput                      1017.9 lpm   (60.0 secs, 3 samples)
> Shell Scripts (1 concurrent)               5726.3 lpm   (60.0 secs, 3 samples)
> Shell Scripts (8 concurrent)               1124.3 lpm   (60.0 secs, 3 samples)
> Shell Scripts (16 concurrent)               576.0 lpm   (60.0 secs, 3 samples)
> Dc: sqrt(2) to 99 decimal places         125446.5 lpm   (30.0 secs, 3 samples)
> 
> [lockless]
> Execl Throughput                           3041.0 lps   (29.8 secs, 3 samples)
> C Compiler Throughput                      1025.7 lpm   (60.0 secs, 3 samples)
> Shell Scripts (1 concurrent)               5713.6 lpm   (60.0 secs, 3 samples)
> Shell Scripts (8 concurrent)               1113.7 lpm   (60.0 secs, 3 samples)
> Shell Scripts (16 concurrent)               571.3 lpm   (60.0 secs, 3 samples)
> Dc: sqrt(2) to 99 decimal places         125417.9 lpm   (30.0 secs, 3 samples)
> ==
> 
> From this, single-thread results are good. multi-process results are not good ;)
> So, I think the number of atomic ops are reduced but I have should-be-fixed
> contention or cache-bouncing problem yet. I'd like to fix this and check on 8 core
> system when it is back.
> Recently, I wonder within-3%-overhead is realistic goal.

It would be nice to be under 3% and lower if possible. I know it is a hard goal
to achieve, but worth striving for. I'll try and extract some numbers with the
radix tree changes and see if I am adding to the overhead (in terms of time) :)

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
