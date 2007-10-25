Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9P4p9pv017892
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 00:51:09 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9P4p9Yu083996
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 22:51:09 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9P4p89D012327
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 22:51:08 -0600
Message-ID: <472020C8.4090007@us.ibm.com>
Date: Wed, 24 Oct 2007 21:51:20 -0700
From: Badari <pbadari@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/2] Export memblock migrate type to /sysfs
References: <1193243860.30836.22.camel@dyn9047017100.beaverton.ibm.com> <20071025093531.d2357422.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071025093531.d2357422.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: melgor@ie.ibm.com, haveblue@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Wed, 24 Oct 2007 09:37:40 -0700
> Badari Pulavarty <pbadari@us.ibm.com> wrote:
>
>   
>> Hi,
>>
>> Now that grouping of pages by mobility is in mainline, I would like 
>> to make use of it for selection memory blocks for hotplug memory remove.
>> Following set of patches exports memblock's migrate type to /sysfs. 
>> This would be useful for user-level agent for selecting memory blocks
>> to try to remove.
>>
>> 	[PATCH 1/2] Fix migratetype_names[] and make it available
>> 	[PATCH 2/2] Add mem_type in /syfs to show memblock migrate type
>>
>>     
> At first, I welcome this patch. Thanks :)
>   
>> Todo:
>>
>> 	Currently, we decide the memblock's migrate type looking at
>> first page of memblock. But on some architectures (x86_64), each
>> memblock can contain multiple groupings of pages by mobility. Is it
>> important to address ?
>>     
>
> Hmm, that is a problem annoying me. There is 2 points.
>
> 1. In such arch, we'll have to use ZONE_MOVABLE for hot-removable.
> 2. But from view of showing information to users, more precice is better
>    of course.
>
> How about showing information as following ?
> ==
> %cat ./memory/memory0/mem_type
>  1 0 0 0 0
> %
> as 
>  Reserved Unmovable Movable Reserve Isolate
>
>   
Personally, I have no problem. But its against the rules of /sysfs - 
"one value per file" rule :(
I would say, lets keep it simple for now and extend it if needed.

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
