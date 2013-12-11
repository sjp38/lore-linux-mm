Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id A529D6B0036
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 04:21:27 -0500 (EST)
Received: by mail-wg0-f51.google.com with SMTP id b13so6163720wgh.30
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 01:21:26 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id e2si18155698eeg.30.2013.12.11.01.21.26
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 01:21:26 -0800 (PST)
Date: Wed, 11 Dec 2013 09:21:23 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v5 8/8] sched/numa: drop unnecessary variable in
 task_weight
Message-ID: <20131211092123.GV11295@suse.de>
References: <1386723001-25408-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1386723001-25408-9-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1386723001-25408-9-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Dec 11, 2013 at 08:50:01AM +0800, Wanpeng Li wrote:
> Drop unnecessary total_faults variable in function task_weight to unify
> task_weight and group_weight.
> 
> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Nak.

task_weight is called for tasks other than current. If p handles a fault
in parallel then it can drop to 0 between when it's checked and used to
divide resulting in an oops.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
