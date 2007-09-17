Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id l8HKLqco018113
	for <linux-mm@kvack.org>; Tue, 18 Sep 2007 06:21:52 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8HKLqGM4694052
	for <linux-mm@kvack.org>; Tue, 18 Sep 2007 06:21:52 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8HKKM8C002666
	for <linux-mm@kvack.org>; Tue, 18 Sep 2007 06:20:22 +1000
Message-ID: <46EEE1C3.1010203@linux.vnet.ibm.com>
Date: Tue, 18 Sep 2007 01:51:23 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH/RFC 5/14] Reclaim Scalability:  Use an indexed array for
 LRU variables
References: <20070914205359.6536.98017.sendpatchset@localhost> <20070914205431.6536.43754.sendpatchset@localhost> <46EECE5C.3070801@linux.vnet.ibm.com> <46EED747.8090907@redhat.com>
In-Reply-To: <46EED747.8090907@redhat.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> Balbir Singh wrote:
> 
>> I wonder if it makes sense to have an array of the form
>>
>> struct reclaim_lists {
>>     struct list_head list[NR_LRU_LISTS];
>>     unsigned long nr_scan[NR_LRU_LISTS];
>>     reclaim_function_t list_reclaim_function[NR_LRU_LISTS];
>> }
>>
>> where reclaim_function is an array of reclaim functions for each list
>> (in our case shrink_active_list/shrink_inactive_list).
> 
> I am not convinced, since that does not give us any way
> to balance between the calls made to each function...
> 

Currently the balancing done is based on the number of pages
on each list, the priority and the pass. We could still do
that with the functions encapsulated. Am I missing something?

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
