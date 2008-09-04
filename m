Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m84NV1vg032345
	for <linux-mm@kvack.org>; Thu, 4 Sep 2008 19:31:01 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m84NV1Oj212800
	for <linux-mm@kvack.org>; Thu, 4 Sep 2008 17:31:01 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m84NV09q021237
	for <linux-mm@kvack.org>; Thu, 4 Sep 2008 17:31:01 -0600
Message-ID: <48C06FB4.1040100@us.ibm.com>
Date: Thu, 04 Sep 2008 16:31:00 -0700
From: Badari Pulavarty <pbadari@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Show memory section to node relationship in sysfs
References: <20080904202212.GB26795@us.ibm.com> <29495f1d0809041514y8cb4764h11aacd3a78cec58d@mail.gmail.com>
In-Reply-To: <29495f1d0809041514y8cb4764h11aacd3a78cec58d@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nish Aravamudan <nish.aravamudan@gmail.com>
Cc: Gary Hade <garyhade@us.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Chris McDermott <lcm@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Nish Aravamudan wrote:
> On 9/4/08, Gary Hade <garyhade@us.ibm.com> wrote:
>   
>> Show memory section to node relationship in sysfs
>>
>>  Add /sys/devices/system/memory/memoryX/node files to show
>>  the node on which each memory section resides.
>>     
>
> I think this patch needs an additional bit for Documentation/ABI
> (might be other parts of /sys/devices/system/memory missing from
> there).
>
>   
Yes. I added Documentation/ABI for "removable". We should update it for 
this too.
> Also, I wonder if it might not make more sense to use a symlink here? That is
>
> /sys/devices/system/memory/memoryX/node -> /sys/devices/system/node/nodeY ?
>
>   
Makes sense. Since we already have "node/nodeY", we might as well make 
use of it
instead of duplicating it.
> And then we could, potentially, have symlinks returning from the node
> side to indicate all memory sections on that node (might be handy for
> node offline?):
>
> /sys/devices/system/node/nodeX/memory1 -> /sys/devices/system/memory/memoryY
> /sys/devices/system/node/nodeX/memory2 -> /sys/devices/system/memory/memoryZ
>
>   
I don't think we need both. Gary wants to do "node removal/offline" and 
wants
to find out all the memory sections that belong to nodeX. May be this is a
a better interface. This way, we can quickly get through all the memory 
sections
without looking at all the sections. Gary ?
> Dunno, the latter probably should be a separate patch, but does seem
> more like the sysfs behavior (and the number (node or memory section)
> should be easily obtained from the symlinks via readlink, as opposed
> to cat with the current patch?).
>
> Thanks,
> Nish
>   

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
