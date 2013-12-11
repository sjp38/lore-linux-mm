Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id E602F6B0035
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 04:42:07 -0500 (EST)
Received: by mail-pb0-f52.google.com with SMTP id uo5so9614378pbc.39
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 01:42:07 -0800 (PST)
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com. [202.81.31.147])
        by mx.google.com with ESMTPS id eb3si13017467pbc.236.2013.12.11.01.42.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 11 Dec 2013 01:42:06 -0800 (PST)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 11 Dec 2013 19:42:01 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id C04F62BB0054
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 20:41:59 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBB9NlgO53280878
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 20:23:47 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBB9fwPO030686
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 20:41:59 +1100
Date: Wed, 11 Dec 2013 17:41:56 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 7/8] sched/numa: fix record hinting faults check
Message-ID: <52a8336e.23b6440a.5215.37a6SMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1386723001-25408-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1386723001-25408-8-git-send-email-liwanp@linux.vnet.ibm.com>
 <20131211091422.GU11295@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131211091422.GU11295@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Mel,
On Wed, Dec 11, 2013 at 09:14:22AM +0000, Mel Gorman wrote:
>On Wed, Dec 11, 2013 at 08:50:00AM +0800, Wanpeng Li wrote:
>> Adjust numa_scan_period in task_numa_placement, depending on how much useful
>> work the numa code can do. The local faults and remote faults should be used
>> to check if there is record hinting faults instead of local faults and shared
>> faults. This patch fix it.
>> 
>> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>
>This potentially has the side-effect of making it easier to reduce the
>scan rate because it'll only take the most recent scan window into
>account. The existing code takes recent shared accesses into account.

The local/remote and share/private both accumulate the just finished
scan window, why takes the most recent scan window into account will 
reduce the scan rate than takes recent shared accesses into account?

>What sort of tests did you do on this patch and what was the result?

I find this by codes review, I can drop this patch if your point is
correct. ;-)

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
