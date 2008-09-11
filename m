From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <14174529.1221145313517.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 12 Sep 2008 00:01:53 +0900 (JST)
Subject: Re: Re: Re: [RFC] [PATCH 8/9] memcg: remove page_cgroup pointer from memmap
In-Reply-To: <33551037.1221143889677.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <33551037.1221143889677.kamezawa.hiroyu@jp.fujitsu.com>
 <200809120000.37901.nickpiggin@yahoo.com.au>
 <20080911200855.94d33d3b.kamezawa.hiroyu@jp.fujitsu.com> <20080911202249.df6026ae.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, balbir@linux.vnet.ibm.com, xemul@openvz.org, hugh@veritas.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, menage@google.com
List-ID: <linux-mm.kvack.org>

>>On Thursday 11 September 2008 21:22, KAMEZAWA Hiroyuki wrote:
>>> Remove page_cgroup pointer from struct page.
>>>
>>> This patch removes page_cgroup pointer from struct page and make it be abl
e
>>> to get from pfn. Then, relationship of them is
>>>
>>> Before this:
>>>   pfn <-> struct page <-> struct page_cgroup.
>>> After this:
>>>   struct page <-> pfn -> struct page_cgroup -> struct page.
>>
>>So...
>>
>>pfn -> *hash* -> struct page_cgroup, right?
>>
>right.
>
>>While I don't think there is anything wrong with the approach, I
>>don't understand exactly where you guys are hoping to end up with
>>this?
>>
>No. but this is simple. I'd like to use linear mapping like
>sparsemem-vmemmap and HUGTLB kernel pages at the end.
>But it needs much more work and should be done in the future.
>(And it seems to have to depend on SPARSEMEM.)
>This is just a generic one.
>
This is my thinking, now.

Adding a patch for FLATMEM is very easy, maybe. (Just Do as Balbir's one.)

Adding a patch for DISCONTIGMEM is doubtful. I'm not sure how it's widely
used now.

When it comes to SPARSEMEM, our target is 64bit arch and we need 
SPARSEMEM_EXTREME...2 level table. Maybe not far different from current hash.

Our way should be linear mapping like SPARSEMEM_VMEMMAP. But it needs
arch dependent code and some difficulty to allocate virtual space,
which can be very Huge.
This should be updated one by one (for each arch.).

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
