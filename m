Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 6B0796B0035
	for <linux-mm@kvack.org>; Sun, 15 Dec 2013 03:41:23 -0500 (EST)
Received: by mail-pb0-f44.google.com with SMTP id rq2so4232192pbb.31
        for <linux-mm@kvack.org>; Sun, 15 Dec 2013 00:41:23 -0800 (PST)
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com. [202.81.31.143])
        by mx.google.com with ESMTPS id im7si5823997pbd.281.2013.12.15.00.41.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 15 Dec 2013 00:41:22 -0800 (PST)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sun, 15 Dec 2013 18:41:18 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id A15982BB0053
	for <linux-mm@kvack.org>; Sun, 15 Dec 2013 19:41:14 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBF8Mu0j4194658
	for <linux-mm@kvack.org>; Sun, 15 Dec 2013 19:22:57 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBF8fCGr025665
	for <linux-mm@kvack.org>; Sun, 15 Dec 2013 19:41:12 +1100
Date: Sun, 15 Dec 2013 16:41:10 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v8 1/4] sched/numa: drop
 sysctl_numa_balancing_settle_count sysctl
Message-ID: <52ad6b32.0719450a.02eb.ffffb81bSMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1386833006-6600-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20131213180933.GS21999@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131213180933.GS21999@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Peter,
On Fri, Dec 13, 2013 at 07:09:33PM +0100, Peter Zijlstra wrote:
>On Thu, Dec 12, 2013 at 03:23:23PM +0800, Wanpeng Li wrote:
>> Changelog:
>>  v7 -> v8:
>>   * remove references to it in Documentation/sysctl/kernel.txt 
>
>Please do not put such bits in the changelog proper, but put them below
>the --- line, that way they disappear automagically.
>

Do you mean something like: 

commit 887c290e (sched/numa: Decide whether to favour task or group
weights
based on swap candidate relationships) drop the check against
sysctl_numa_balancing_settle_count, this patch remove the sysctl.

Acked-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Rik van Riel <riel@redhat.com>
Acked-by: David Rientjes <rientjes@google.com>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
Changelog:
 v7 -> v8:
   * remove references to it in Documentation/sysctl/kernel.txt
---
Documentation/sysctl/kernel.txt |    5 -----
include/linux/sched/sysctl.h    |    1 -
kernel/sched/fair.c             |    9 ---------
kernel/sysctl.c                 |    7 -------
4 files changed, 0 insertions(+), 22 deletions(-)

>Applied all 4, thanks!

Thanks. ;-)

Regards,
Wanpeng Li 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
