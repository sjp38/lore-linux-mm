Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 96BF86B0035
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 04:34:15 -0500 (EST)
Received: by mail-pb0-f49.google.com with SMTP id jt11so9586452pbb.36
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 01:34:15 -0800 (PST)
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com. [202.81.31.143])
        by mx.google.com with ESMTPS id tr4si13014595pab.63.2013.12.11.01.34.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 11 Dec 2013 01:34:14 -0800 (PST)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 11 Dec 2013 19:34:11 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 8EEF02CE8040
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 20:34:08 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBB9FtDE53280782
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 20:15:56 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBB9Y7Fv019295
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 20:34:07 +1100
Date: Wed, 11 Dec 2013 17:34:05 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 8/8] sched/numa: drop unnecessary variable in
 task_weight
Message-ID: <52a83196.6494420a.5e2f.4829SMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1386723001-25408-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1386723001-25408-9-git-send-email-liwanp@linux.vnet.ibm.com>
 <20131211092123.GV11295@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131211092123.GV11295@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Dec 11, 2013 at 09:21:23AM +0000, Mel Gorman wrote:
>On Wed, Dec 11, 2013 at 08:50:01AM +0800, Wanpeng Li wrote:
>> Drop unnecessary total_faults variable in function task_weight to unify
>> task_weight and group_weight.
>> 
>> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>
>Nak.
>
>task_weight is called for tasks other than current. If p handles a fault
>in parallel then it can drop to 0 between when it's checked and used to
>divide resulting in an oops.

I see, thanks for your pointing out.

Regards,
Wanpeng Li 

>
>-- 
>Mel Gorman
>SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
