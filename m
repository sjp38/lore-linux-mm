Message-ID: <43E7E2FA.8010807@jp.fujitsu.com>
Date: Tue, 07 Feb 2006 08:59:54 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC] pearing off zone from physical memory layout [0/10]
References: <43E307DB.3000903@jp.fujitsu.com> <1139254063.6189.97.camel@localhost.localdomain>
In-Reply-To: <1139254063.6189.97.camel@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
> On Fri, 2006-02-03 at 16:35 +0900, KAMEZAWA Hiroyuki wrote:
>> This series of patches remove members from zone, which depends on physical
>> memory layout, zone_start_pfn, spanned_pages, zone_mem_map against 2.6.16-rc1.
>>
>> By this, zone's meaning will be changed from "a range of memory to be used
>> in a same manner" to "a group of memory to be used in a same manner".
> 
> This looks like pretty good stuff.  I especially like that it gets rid
> of that seqlock that I had to add for memory hotplug.  My only concern
> would be in the increased page_to_pfn() overhead.  Any data on that?
> 

I don't have any data, because I don't have a NUMA environment which needs this.
My x86 box is not NUMA and IA64 uses vmem_map, doesn't access zone->zone_mem_map.

Archs which needs test are alpha, arm, m32r, i386, parisc, x86_64.
(powerpc doesn't have DISCONTIGMEM config)

To make codes clean before asking test, I posted unify_pfn_to_page patch to lkml.
(I'll have to rewrite and repost it..)
After it goes, I'll post renewed patch as request-for-test.


sorry for Bad e-mail subject :(
Thanks,
-- Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
