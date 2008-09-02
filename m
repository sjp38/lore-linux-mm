Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp05.in.ibm.com (8.13.1/8.13.1) with ESMTP id m82AClUA008453
	for <linux-mm@kvack.org>; Tue, 2 Sep 2008 15:42:47 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m82ACkt11855528
	for <linux-mm@kvack.org>; Tue, 2 Sep 2008 15:42:46 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m82ACk3a009190
	for <linux-mm@kvack.org>; Tue, 2 Sep 2008 15:42:46 +0530
Message-ID: <48BD119B.8020605@linux.vnet.ibm.com>
Date: Tue, 02 Sep 2008 15:42:43 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] Remove cgroup member from struct page
References: <20080831174756.GA25790@balbir.in.ibm.com> <200809011656.45190.nickpiggin@yahoo.com.au> <20080901161927.a1fe5afc.kamezawa.hiroyu@jp.fujitsu.com> <200809011743.42658.nickpiggin@yahoo.com.au> <48BD0641.4040705@linux.vnet.ibm.com> <20080902190256.1375f593.kamezawa.hiroyu@jp.fujitsu.com> <48BD0E4A.5040502@linux.vnet.ibm.com> <20080902190723.841841f0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080902190723.841841f0.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, hugh@veritas.com, menage@google.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Tue, 02 Sep 2008 15:28:34 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>> KAMEZAWA Hiroyuki wrote:
>>> On Tue, 02 Sep 2008 14:54:17 +0530
>>> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>>
>>>> Nick Piggin wrote:
>>>>> That could be a reasonable solution.  Balbir has other concerns about
>>>>> this... so I think it is OK to try the radix tree approach first.
>>>> Thanks, Nick!
>>>>
>>>> Kamezawa-San, I would like to integrate the radix tree patches after review and
>>>> some more testing then integrate your patchset on top of it. Do you have any
>>>> objections/concerns with the suggested approach?
>>>>
>>> please show performance number first.
>> Yes, that is why said some more testing. I am running lmbench and kernbench on
>> it and some other tests, I'll get back with numbers.
>>
> A test which is not suffer much from I/O is better.
> And please don't worry about my patches. I'll reschedule if yours goes first.
> 
Thanks, I'll try and find the right set of tests.
-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
