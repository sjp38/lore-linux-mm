Message-ID: <46EEEB14.3030107@redhat.com>
Date: Mon, 17 Sep 2007 17:01:08 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH/RFC 5/14] Reclaim Scalability:  Use an indexed array for
 LRU variables
References: <20070914205359.6536.98017.sendpatchset@localhost> <20070914205431.6536.43754.sendpatchset@localhost> <46EECE5C.3070801@linux.vnet.ibm.com> <46EED747.8090907@redhat.com> <46EEE1C3.1010203@linux.vnet.ibm.com>
In-Reply-To: <46EEE1C3.1010203@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
> Rik van Riel wrote:
>> Balbir Singh wrote:
>>
>>> I wonder if it makes sense to have an array of the form
>>>
>>> struct reclaim_lists {
>>>     struct list_head list[NR_LRU_LISTS];
>>>     unsigned long nr_scan[NR_LRU_LISTS];
>>>     reclaim_function_t list_reclaim_function[NR_LRU_LISTS];
>>> }
>>>
>>> where reclaim_function is an array of reclaim functions for each list
>>> (in our case shrink_active_list/shrink_inactive_list).
>> I am not convinced, since that does not give us any way
>> to balance between the calls made to each function...
> 
> Currently the balancing done is based on the number of pages
> on each list, the priority and the pass. We could still do
> that with the functions encapsulated. Am I missing something?

Yes, that balancing does not work very well in all
workloads and will need to be changed some time.

Your scheme would remove the flexibility needed
to make such fixes.

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
