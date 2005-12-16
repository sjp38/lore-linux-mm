Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id jBG53Sqm027982
	for <linux-mm@kvack.org>; Fri, 16 Dec 2005 00:03:28 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jBG53QbF124510
	for <linux-mm@kvack.org>; Fri, 16 Dec 2005 00:03:28 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11/8.13.3) with ESMTP id jBG52kfp017424
	for <linux-mm@kvack.org>; Fri, 16 Dec 2005 00:02:46 -0500
Message-ID: <43A24A6F.5090907@us.ibm.com>
Date: Thu, 15 Dec 2005 21:02:39 -0800
From: Sridhar Samudrala <sri@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/6] Critical Page Pool
References: <439FCECA.3060909@us.ibm.com> <20051214100841.GA18381@elf.ucw.cz> <43A0406C.8020108@us.ibm.com> <20051215162601.GJ2904@elf.ucw.cz> <43A1E551.1090403@us.ibm.com>
In-Reply-To: <43A1E551.1090403@us.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dobson <colpatch@us.ibm.com>
Cc: Pavel Machek <pavel@suse.cz>, linux-kernel@vger.kernel.org, andrea@suse.de, Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Matthew Dobson wrote:

>Pavel Machek wrote:
>  
>
>>>>And as you noticed, it does not work for your original usage case,
>>>>because reserved memory pool would have to be "sum of all network
>>>>interface bandwidths * ammount of time expected to survive without
>>>>network" which is way too much.
>>>>        
>>>>
>>>Well, I never suggested it didn't work for my original usage case.  The
>>>discussion we had is that it would be incredibly difficult to 100%
>>>iron-clad guarantee that the pool would NEVER run out of pages.  But we can
>>>size the pool, especially given a decent workload approximation, so as to
>>>make failure far less likely.
>>>      
>>>
>>Perhaps you should add file in Documentation/ explaining it is not
>>reliable?
>>    
>>
>
>That's a good suggestion.  I will rework the patch's additions to
>Documentation/sysctl/vm.txt to be more clear about exactly what we're
>providing.
>
>
>  
>
>>>>If you want few emergency pages for some strange hack you are doing
>>>>(swapping over network?), just put swap into ramdisk and swapon() it
>>>>when you are in emergency, or use memory hotplug and plug few more
>>>>gigabytes into your machine. But don't go introducing infrastructure
>>>>that _can't_ be used right.
>>>>        
>>>>
>>>Well, that's basically the point of posting these patches as an RFC.  I'm
>>>not quite so delusional as to think they're going to get picked up right
>>>now.  I was, however, hoping for feedback to figure out how to design
>>>infrastructure that *can* be used right, as well as trying to find other
>>>potential users of such a feature.
>>>      
>>>
>>Well, we don't usually take infrastructure that has no in-kernel
>>users, and example user would indeed be nice.
>>							Pavel
>>    
>>
>
>Understood.  I certainly wouldn't expect otherwise.  I'll see if I can get
>Sridhar to post his networking changes that take advantage of this.
>  
>
I have posted these patches yesterday on lkml and netdev and here is a 
link to the thread.
    http://thread.gmane.org/gmane.linux.kernel/357835
  
Thanks
Sridhar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
