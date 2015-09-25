Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f173.google.com (mail-qk0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id 64A466B0253
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 13:38:51 -0400 (EDT)
Received: by qkap81 with SMTP id p81so45187222qka.2
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 10:38:51 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r84si3700343qkr.12.2015.09.25.10.38.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Sep 2015 10:38:50 -0700 (PDT)
Message-ID: <560586A8.4060901@redhat.com>
Date: Fri, 25 Sep 2015 13:38:48 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: numa balancing stuck in task_work_run
References: <5604665D.3030504@stratus.com> <560467B8.6000101@stratus.com> <56049D97.6080106@redhat.com> <560583F9.4040908@stratus.com>
In-Reply-To: <560583F9.4040908@stratus.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Lawrence <joe.lawrence@stratus.com>, Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org

On 09/25/2015 01:27 PM, Joe Lawrence wrote:
> On 09/24/2015 09:04 PM, Rik van Riel wrote:
>> On 09/24/2015 05:14 PM, Joe Lawrence wrote:
>>> [ +cc for linux-mm mailinglist address ]
>>>
>>> On 09/24/2015 05:08 PM, Joe Lawrence wrote:
>>>> Hi Mel, Rik et al,
>>>>
>>>> We've encountered interesting NUMA balancing behavior on RHEL7.1,
>>>> reproduced with an upstream 4.2 kernel (of similar .config), that can
>>>> leave a user process trapped in the kernel performing task_numa_work.
>>>>
>>>> Our test group set up a server with 256GB memory running a program that
>>>> allocates and dirties ~50% of that memory.  They reported the following
>>>> condition when they attempted to kill the test process -- the signal was
>>>> never handled, instead traces showed the task stuck here:
>>
>> Does the bug still happen with this patch applied?
>>
>> https://git.kernel.org/cgit/linux/kernel/git/tip/tip.git/commit/?id=4620f8c1fda2af4ccbd11e194e2dd785f7d7f279
>>
> 
> Hi Rik,
> 
> Success!  With 4620f8c1fda2 (-tip) cherry-picked on-top of 4.2, I could
> successfully kill off the memory test process, even when the
> numa_scan_period_max dropped to 140.
> 
> I also ran kicked off the est program and let continue overnight (it
> restarts itself after a given time) and several iterations ran without
> incident.

Glad to hear the issue is fixed in the latest -tip tree.

FWIW, that fix is also slated to show up in the next RHEL 7
update.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
