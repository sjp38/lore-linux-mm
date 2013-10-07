Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id B95CC6B0032
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 15:07:02 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id q10so7525343pdj.35
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 12:07:02 -0700 (PDT)
Message-ID: <5253064B.3010405@redhat.com>
Date: Mon, 07 Oct 2013 15:06:51 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 38/63] sched: Introduce migrate_swap()
References: <1381141781-10992-1-git-send-email-mgorman@suse.de> <1381141781-10992-39-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-39-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 10/07/2013 06:29 AM, Mel Gorman wrote:
> From: Peter Zijlstra <peterz@infradead.org>
> 
> Use the new stop_two_cpus() to implement migrate_swap(), a function that
> flips two tasks between their respective cpus.
> 
> I'm fairly sure there's a less crude way than employing the stop_two_cpus()
> method, but everything I tried either got horribly fragile and/or complex. So
> keep it simple for now.
> 
> The notable detail is how we 'migrate' tasks that aren't runnable
> anymore. We'll make it appear like we migrated them before they went to
> sleep. The sole difference is the previous cpu in the wakeup path, so we
> override this.
> 
> Signed-off-by: Peter Zijlstra <peterz@infradead.org>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
