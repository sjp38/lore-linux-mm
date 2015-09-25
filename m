Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id CC3E76B0253
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 21:04:26 -0400 (EDT)
Received: by qgx61 with SMTP id 61so58925438qgx.3
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 18:04:26 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m189si713365qhb.61.2015.09.24.18.04.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Sep 2015 18:04:26 -0700 (PDT)
Message-ID: <56049D97.6080106@redhat.com>
Date: Thu, 24 Sep 2015 21:04:23 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: numa balancing stuck in task_work_run
References: <5604665D.3030504@stratus.com> <560467B8.6000101@stratus.com>
In-Reply-To: <560467B8.6000101@stratus.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Lawrence <joe.lawrence@stratus.com>, Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org

On 09/24/2015 05:14 PM, Joe Lawrence wrote:
> [ +cc for linux-mm mailinglist address ]
> 
> On 09/24/2015 05:08 PM, Joe Lawrence wrote:
>> Hi Mel, Rik et al,
>>
>> We've encountered interesting NUMA balancing behavior on RHEL7.1,
>> reproduced with an upstream 4.2 kernel (of similar .config), that can
>> leave a user process trapped in the kernel performing task_numa_work.
>>
>> Our test group set up a server with 256GB memory running a program that
>> allocates and dirties ~50% of that memory.  They reported the following
>> condition when they attempted to kill the test process -- the signal was
>> never handled, instead traces showed the task stuck here:

Does the bug still happen with this patch applied?

https://git.kernel.org/cgit/linux/kernel/git/tip/tip.git/commit/?id=4620f8c1fda2af4ccbd11e194e2dd785f7d7f279

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
