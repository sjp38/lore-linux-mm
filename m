Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp04.in.ibm.com (8.13.1/8.13.1) with ESMTP id m89BmH8f029089
	for <linux-mm@kvack.org>; Tue, 9 Sep 2008 17:18:17 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m89BmGna1163462
	for <linux-mm@kvack.org>; Tue, 9 Sep 2008 17:18:16 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m89BmGxN002007
	for <linux-mm@kvack.org>; Tue, 9 Sep 2008 17:18:16 +0530
Message-ID: <48C66276.9020902@linux.vnet.ibm.com>
Date: Tue, 09 Sep 2008 04:48:06 -0700
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 6/14]  memcg: lockless page cgroup
References: <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com> <20080822203551.598a263c.kamezawa.hiroyu@jp.fujitsu.com> <20080909144007.48e6633a.nishimura@mxp.nes.nec.co.jp> <20080909165608.878d7182.kamezawa.hiroyu@jp.fujitsu.com> <20080909171154.f3cfdfd6.nishimura@mxp.nes.nec.co.jp> <20080909201115.b87f9bdb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080909201115.b87f9bdb.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Tue, 9 Sep 2008 17:11:54 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
>>> I'm sorry to say that I'll have to postpone this to remove
>>> page->page_cgroup pointer. I need some more performance-improvement
>>> effort to remove page->page_cgroup pointer without significant overhead.
>>>
>> No problem. I know about that :)
>>
> This is the latest result of lockless series. (on rc5-mmtom)
> (Don't trust shell script result...it seems too slow.)
> 
> ==on 2cpu/1socket x86-64 host==
> rc5-mm1
> ==
> Execl Throughput                           3006.5 lps   (29.8 secs, 3 samples)
> C Compiler Throughput                      1006.7 lpm   (60.0 secs, 3 samples)
> Shell Scripts (1 concurrent)               4863.7 lpm   (60.0 secs, 3 samples)
> Shell Scripts (8 concurrent)                943.7 lpm   (60.0 secs, 3 samples)
> Shell Scripts (16 concurrent)               482.7 lpm   (60.0 secs, 3 samples)
> Dc: sqrt(2) to 99 decimal places         124804.9 lpm   (30.0 secs, 3 samples)
> 
> lockless
> ==
> Execl Throughput                           3035.5 lps   (29.6 secs, 3 samples)
> C Compiler Throughput                      1010.3 lpm   (60.0 secs, 3 samples)
> Shell Scripts (1 concurrent)               4881.0 lpm   (60.0 secs, 3 samples)
> Shell Scripts (8 concurrent)                947.7 lpm   (60.0 secs, 3 samples)
> Shell Scripts (16 concurrent)               485.0 lpm   (60.0 secs, 3 samples)
> Dc: sqrt(2) to 99 decimal places         125437.9 lpm   (30.0 secs, 3 samples)
> ==
> 
> I'll try to build "remove-page-cgroup-pointer" patch on this
> and see what happens tomorrow. (And I think my 8cpu box will come back..

Looks good so far. Thanks for all the testing!

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
