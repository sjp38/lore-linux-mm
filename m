Message-ID: <4434C12A.4000108@redhat.com>
Date: Thu, 06 Apr 2006 03:20:10 -0400
From: Hideo AOKI <haoki@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 1/3] mm: An enhancement of OVERCOMMIT_GUESS
References: <4434570F.9030507@redhat.com> <20060406094533.b340f633.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20060406094533.b340f633.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Kamezawa-san,

Thank you for your comments.

KAMEZAWA Hiroyuki wrote:
> Hi, AOKI-san
> 
> On Wed, 05 Apr 2006 19:47:27 -0400
> Hideo AOKI <haoki@redhat.com> wrote:
> 
> 
>>Hello Andrew,
>>
>>Could you apply my patches to your tree?
>>
>>These patches are an enhancement of OVERCOMMIT_GUESS algorithm in
>>__vm_enough_memory(). The detailed description is in attached patch.
> 
> I think adding a function like this is more simple way.
> (call this istead of nr_free_pages().)
> ==
> int nr_available_memory() 
> {
> 	unsigned long sum = 0;
> 	for_each_zone(zone) {
> 		if (zone->free_pages > zone->pages_high)
> 			sum += zone->free_pages - zone->pages_high;
> 	}
> 	return sum;
> }
> ==

I like your idea. But, in the function, I think we need to care
lowmem_reserve too.

Since __vm_enough_memory() doesn't know zone and cpuset information,
we have to guess proper value of lowmem_reserve in each zone
like I did in calculate_totalreserve_pages() in my patch.
Do you think that we can do this calculation every time?

If it is good enough, I'll make revised patch.


> BTW, vm_enough_memory() doesn't eat cpuset information ?

I think this is another point which we should improve.

Best regards,
Hideo Aoki

---
Hideo Aoki, Hitachi Computer Products (America) Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
