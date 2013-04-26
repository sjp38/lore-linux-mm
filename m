Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id F02D06B0002
	for <linux-mm@kvack.org>; Fri, 26 Apr 2013 06:17:16 -0400 (EDT)
Received: by mail-ob0-f174.google.com with SMTP id wc20so3397857obb.33
        for <linux-mm@kvack.org>; Fri, 26 Apr 2013 03:17:16 -0700 (PDT)
Message-ID: <517A5426.8050901@gmail.com>
Date: Fri, 26 Apr 2013 18:17:10 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: vmalloc fault
References: <517A4F1E.9070803@gmail.com> <517A5138.9040902@redhat.com>
In-Reply-To: <517A5138.9040902@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>

Morning Rik, so early.
On 04/26/2013 06:04 PM, Rik van Riel wrote:
> On 04/26/2013 05:55 AM, Simon Jeons wrote:
>> Hi all,
>>
>> 1. Why vmalloc fault need sync user process page table with kernel page
>> table instead of using kernel page table directly?
>
> Each process has its own PGD, into which both kernel and user
> PMDs (or PUDs) are mapped. It is possible the PGD is missing
> some pointers, that need to be filled in at fault time.

It seems that you miss my question. I mean why sync page table between 
user process and init_mm.pgd, can user process use init_mm.pgd page 
table directly when access vmalloc memory? ;-)

>
>> 2. Why do_swap_page doesn't set present flag?
>
> It does.  Look at how vm_get_page_prot works.

Got it.

>
>> 3. When enable DEBUG_PAGEALLOC(catch use-after-free bug), if user
>> process alloc pages from zone_normal(which is direct mapping) when
>> fallback, this page which allocated for user process will set present
>> flag in related pte, correct? but why also set present flag for kernel
>> direct mapping? Does kernel have any requirement to access it?
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
