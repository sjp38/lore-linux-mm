Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e36.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id jBFLpGwx028727
	for <linux-mm@kvack.org>; Thu, 15 Dec 2005 16:51:16 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jBFLoN1f126326
	for <linux-mm@kvack.org>; Thu, 15 Dec 2005 14:50:23 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id jBFLpFxW005262
	for <linux-mm@kvack.org>; Thu, 15 Dec 2005 14:51:15 -0700
Message-ID: <43A1E551.1090403@us.ibm.com>
Date: Thu, 15 Dec 2005 13:51:13 -0800
From: Matthew Dobson <colpatch@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/6] Critical Page Pool
References: <439FCECA.3060909@us.ibm.com> <20051214100841.GA18381@elf.ucw.cz> <43A0406C.8020108@us.ibm.com> <20051215162601.GJ2904@elf.ucw.cz>
In-Reply-To: <20051215162601.GJ2904@elf.ucw.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@suse.cz>
Cc: linux-kernel@vger.kernel.org, andrea@suse.de, Sridhar Samudrala <sri@us.ibm.com>, Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Pavel Machek wrote:
>>>And as you noticed, it does not work for your original usage case,
>>>because reserved memory pool would have to be "sum of all network
>>>interface bandwidths * ammount of time expected to survive without
>>>network" which is way too much.
>>
>>Well, I never suggested it didn't work for my original usage case.  The
>>discussion we had is that it would be incredibly difficult to 100%
>>iron-clad guarantee that the pool would NEVER run out of pages.  But we can
>>size the pool, especially given a decent workload approximation, so as to
>>make failure far less likely.
> 
> 
> Perhaps you should add file in Documentation/ explaining it is not
> reliable?

That's a good suggestion.  I will rework the patch's additions to
Documentation/sysctl/vm.txt to be more clear about exactly what we're
providing.


>>>If you want few emergency pages for some strange hack you are doing
>>>(swapping over network?), just put swap into ramdisk and swapon() it
>>>when you are in emergency, or use memory hotplug and plug few more
>>>gigabytes into your machine. But don't go introducing infrastructure
>>>that _can't_ be used right.
>>
>>Well, that's basically the point of posting these patches as an RFC.  I'm
>>not quite so delusional as to think they're going to get picked up right
>>now.  I was, however, hoping for feedback to figure out how to design
>>infrastructure that *can* be used right, as well as trying to find other
>>potential users of such a feature.
> 
> 
> Well, we don't usually take infrastructure that has no in-kernel
> users, and example user would indeed be nice.
> 							Pavel

Understood.  I certainly wouldn't expect otherwise.  I'll see if I can get
Sridhar to post his networking changes that take advantage of this.

Thanks!

-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
