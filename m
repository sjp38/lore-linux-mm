Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m8527YsQ010645
	for <linux-mm@kvack.org>; Thu, 4 Sep 2008 22:07:34 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m8527XCY174738
	for <linux-mm@kvack.org>; Thu, 4 Sep 2008 22:07:33 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8527Xlv013138
	for <linux-mm@kvack.org>; Thu, 4 Sep 2008 22:07:33 -0400
Date: Thu, 4 Sep 2008 19:07:29 -0700
From: Gary Hade <garyhade@us.ibm.com>
Subject: Re: [PATCH] Show memory section to node relationship in sysfs
Message-ID: <20080905020729.GG26795@us.ibm.com>
References: <20080904202212.GB26795@us.ibm.com> <29495f1d0809041514y8cb4764h11aacd3a78cec58d@mail.gmail.com> <48C06FB4.1040100@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <48C06FB4.1040100@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Nish Aravamudan <nish.aravamudan@gmail.com>, Gary Hade <garyhade@us.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Chris McDermott <lcm@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, Sep 04, 2008 at 04:31:00PM -0700, Badari Pulavarty wrote:
> Nish Aravamudan wrote:
>> On 9/4/08, Gary Hade <garyhade@us.ibm.com> wrote:
>>   
>>> Show memory section to node relationship in sysfs
>>>
>>>  Add /sys/devices/system/memory/memoryX/node files to show
>>>  the node on which each memory section resides.
>>>     
>>
>> I think this patch needs an additional bit for Documentation/ABI
>> (might be other parts of /sys/devices/system/memory missing from
>> there).
>>
>>   
> Yes. I added Documentation/ABI for "removable". We should update it for  
> this too.
>> Also, I wonder if it might not make more sense to use a symlink here? That is
>>
>> /sys/devices/system/memory/memoryX/node -> /sys/devices/system/node/nodeY ?
>>
>>   
> Makes sense. Since we already have "node/nodeY", we might as well make  
> use of it
> instead of duplicating it.
>> And then we could, potentially, have symlinks returning from the node
>> side to indicate all memory sections on that node (might be handy for
>> node offline?):
>>
>> /sys/devices/system/node/nodeX/memory1 -> /sys/devices/system/memory/memoryY
>> /sys/devices/system/node/nodeX/memory2 -> /sys/devices/system/memory/memoryZ
>>
>>   
> I don't think we need both. Gary wants to do "node removal/offline" and  
> wants
> to find out all the memory sections that belong to nodeX. May be this is a
> a better interface. This way, we can quickly get through all the memory  
> sections without looking at all the sections. Gary ?

Yes, either way would work fine but I think symlinks in the
/sys/devices/system/node/nodeX directories would make the
script or program driven memory section offlining complete
a little more quickly.  However, if we do this we might want to
make the symlink names to match the memory section directory names.
  /sys/devices/system/node/nodeX/memoryY -> /sys/devices/system/memory/memoryY
  /sys/devices/system/node/nodeX/memoryZ -> /sys/devices/system/memory/memoryZ
Do you or others have a preference?

Thanks,
Gary

-- 
Gary Hade
System x Enablement
IBM Linux Technology Center
503-578-4503  IBM T/L: 775-4503
garyhade@us.ibm.com
http://www.ibm.com/linux/ltc

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
