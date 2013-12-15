Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id F39926B003D
	for <linux-mm@kvack.org>; Sun, 15 Dec 2013 18:58:15 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id rd3so2180419pab.21
        for <linux-mm@kvack.org>; Sun, 15 Dec 2013 15:58:15 -0800 (PST)
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com. [202.81.31.140])
        by mx.google.com with ESMTPS id vb7si7308107pbc.302.2013.12.15.15.58.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 15 Dec 2013 15:58:14 -0800 (PST)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 16 Dec 2013 09:58:09 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 778B72BB0053
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 10:58:07 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBFNvsRR65601688
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 10:57:54 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBFNw66q016886
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 10:58:06 +1100
Date: Mon, 16 Dec 2013 07:58:04 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v8 1/4] sched/numa: drop
 sysctl_numa_balancing_settle_count sysctl
Message-ID: <52ae4216.67ed440a.577e.ffff88e8SMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1386833006-6600-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20131213180933.GS21999@twins.programming.kicks-ass.net>
 <20131215084110.GA4316@hacker.(null)>
 <20131215165643.GC16438@laptop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131215165643.GC16438@laptop.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, Dec 15, 2013 at 05:56:43PM +0100, Peter Zijlstra wrote:
>On Sun, Dec 15, 2013 at 04:41:10PM +0800, Wanpeng Li wrote:
>> Do you mean something like: 
>> 
>> commit 887c290e (sched/numa: Decide whether to favour task or group
>> weights
>> based on swap candidate relationships) drop the check against
>> sysctl_numa_balancing_settle_count, this patch remove the sysctl.
>> 
>> Acked-by: Mel Gorman <mgorman@suse.de>
>> Reviewed-by: Rik van Riel <riel@redhat.com>
>> Acked-by: David Rientjes <rientjes@google.com>
>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>> ---
>> Changelog:
>>  v7 -> v8:
>>    * remove references to it in Documentation/sysctl/kernel.txt
>> ---
>
>No need to insert another --- line, just the one below the SoB,
>
>> Documentation/sysctl/kernel.txt |    5 -----
>> include/linux/sched/sysctl.h    |    1 -
>> kernel/sched/fair.c             |    9 ---------
>> kernel/sysctl.c                 |    7 -------
>> 4 files changed, 0 insertions(+), 22 deletions(-)
>
>Everything between --- and the patch proper (usually started with an
>Index line or other diff syntax thingy), including this diffstat you
>have, will be made to disappear.
>
>But yes indeed. The Changelog should describe the patch as is, and the
>differences between this and the previous version are relevant only to
>the reviewer who saw the previous version too. But once we commit the
>patch, the previous version ceases to exist (in the commit history) and
>therefore such comments loose their intrinsic meaning and should go away
>too.

Thanks for your great explanation. ;-)

Regards,
Wanpeng Li 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
