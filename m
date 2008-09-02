Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id m829vngQ005479
	for <linux-mm@kvack.org>; Tue, 2 Sep 2008 19:57:49 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m829wZoL3420308
	for <linux-mm@kvack.org>; Tue, 2 Sep 2008 19:58:35 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m829wYcF025805
	for <linux-mm@kvack.org>; Tue, 2 Sep 2008 19:58:34 +1000
Message-ID: <48BD0E4A.5040502@linux.vnet.ibm.com>
Date: Tue, 02 Sep 2008 15:28:34 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] Remove cgroup member from struct page
References: <20080831174756.GA25790@balbir.in.ibm.com> <200809011656.45190.nickpiggin@yahoo.com.au> <20080901161927.a1fe5afc.kamezawa.hiroyu@jp.fujitsu.com> <200809011743.42658.nickpiggin@yahoo.com.au> <48BD0641.4040705@linux.vnet.ibm.com> <20080902190256.1375f593.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080902190256.1375f593.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, hugh@veritas.com, menage@google.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Tue, 02 Sep 2008 14:54:17 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>> Nick Piggin wrote:
>>> That could be a reasonable solution.  Balbir has other concerns about
>>> this... so I think it is OK to try the radix tree approach first.
>> Thanks, Nick!
>>
>> Kamezawa-San, I would like to integrate the radix tree patches after review and
>> some more testing then integrate your patchset on top of it. Do you have any
>> objections/concerns with the suggested approach?
>>
> please show performance number first.

Yes, that is why said some more testing. I am running lmbench and kernbench on
it and some other tests, I'll get back with numbers.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
