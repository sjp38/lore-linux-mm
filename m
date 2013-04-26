Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id C213E6B0002
	for <linux-mm@kvack.org>; Fri, 26 Apr 2013 06:19:55 -0400 (EDT)
Message-ID: <517A54C3.9020403@redhat.com>
Date: Fri, 26 Apr 2013 06:19:47 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: vmalloc fault
References: <517A4F1E.9070803@gmail.com> <517A5138.9040902@redhat.com> <517A5426.8050901@gmail.com>
In-Reply-To: <517A5426.8050901@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>

On 04/26/2013 06:17 AM, Simon Jeons wrote:
> Morning Rik, so early.
> On 04/26/2013 06:04 PM, Rik van Riel wrote:
>> On 04/26/2013 05:55 AM, Simon Jeons wrote:
>>> Hi all,
>>>
>>> 1. Why vmalloc fault need sync user process page table with kernel page
>>> table instead of using kernel page table directly?
>>
>> Each process has its own PGD, into which both kernel and user
>> PMDs (or PUDs) are mapped. It is possible the PGD is missing
>> some pointers, that need to be filled in at fault time.
>
> It seems that you miss my question. I mean why sync page table between
> user process and init_mm.pgd, can user process use init_mm.pgd page
> table directly when access vmalloc memory? ;-)

init_mm.pgd is never used as an actual mmu context after bootup.

>>
>>> 2. Why do_swap_page doesn't set present flag?
>>
>> It does.  Look at how vm_get_page_prot works.
>
> Got it.
>
>>
>>> 3. When enable DEBUG_PAGEALLOC(catch use-after-free bug), if user
>>> process alloc pages from zone_normal(which is direct mapping) when
>>> fallback, this page which allocated for user process will set present
>>> flag in related pte, correct? but why also set present flag for kernel
>>> direct mapping? Does kernel have any requirement to access it?
>>
>>
>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
