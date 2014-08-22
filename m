Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 60F226B0035
	for <linux-mm@kvack.org>; Fri, 22 Aug 2014 00:03:11 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id eu11so15745725pac.4
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 21:03:10 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id nr8si39016253pdb.213.2014.08.21.21.03.09
        for <linux-mm@kvack.org>;
        Thu, 21 Aug 2014 21:03:10 -0700 (PDT)
Date: Fri, 22 Aug 2014 12:04:20 +0800
From: Wanpeng Li <wanpeng.li@linux.intel.com>
Subject: Re: [PATCH 0/6] mm/hugetlb: gigantic hugetlb page pools shrink
 supporting
Message-ID: <20140822040420.GA4756@kernel>
Reply-To: Wanpeng Li <wanpeng.li@linux.intel.com>
References: <1365066554-29195-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130411232907.GC29398@hacker.(null)>
 <20130412152237.GM16732@two.firstfloor.org>
 <20140821233729.GB2420@kernel>
 <53F69E26.1090408@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53F69E26.1090408@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Aug 22, 2014 at 09:34:30AM +0800, Zhang Yanfei wrote:
>Hello Wanpeng
>
>On 08/22/2014 07:37 AM, Wanpeng Li wrote:
>> Hi Andi,
>> On Fri, Apr 12, 2013 at 05:22:37PM +0200, Andi Kleen wrote:
>>> On Fri, Apr 12, 2013 at 07:29:07AM +0800, Wanpeng Li wrote:
>>>> Ping Andi,
>>>> On Thu, Apr 04, 2013 at 05:09:08PM +0800, Wanpeng Li wrote:
>>>>> order >= MAX_ORDER pages are only allocated at boot stage using the 
>>>>> bootmem allocator with the "hugepages=xxx" option. These pages are never 
>>>>> free after boot by default since it would be a one-way street(>= MAX_ORDER
>>>>> pages cannot be allocated later), but if administrator confirm not to 
>>>>> use these gigantic pages any more, these pinned pages will waste memory
>>>>> since other users can't grab free pages from gigantic hugetlb pool even
>>>>> if OOM, it's not flexible.  The patchset add hugetlb gigantic page pools
>>>>> shrink supporting. Administrator can enable knob exported in sysctl to
>>>>> permit to shrink gigantic hugetlb pool.
>>>
>>>
>>> I originally didn't allow this because it's only one way and it seemed
>>> dubious.  I've been recently working on a new patchkit to allocate
>>> GB pages from CMA. With that freeing actually makes sense, as 
>>> the pages can be reallocated.
>>>
>> 
>> More than one year past, If your allocate GB pages from CMA merged? 
>
>commit 944d9fec8d7aee3f2e16573e9b6a16634b33f403
>Author: Luiz Capitulino <lcapitulino@redhat.com>
>Date:   Wed Jun 4 16:07:13 2014 -0700
>
>    hugetlb: add support for gigantic page allocation at runtime
>
>

Ah, thanks for your pointing out.

Regards,
Wanpeng Li 

>> 
>> Regards,
>> Wanpeng Li 
>> 
>>> -Andi
>>>
>>> --
>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>> see: http://www.linux-mm.org/ .
>>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
>> .
>> 
>
>
>-- 
>Thanks.
>Zhang Yanfei
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
