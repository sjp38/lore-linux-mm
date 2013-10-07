Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id E036C6B0038
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 14:41:19 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id kl14so7613752pab.25
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 11:41:19 -0700 (PDT)
Message-ID: <5253003D.4070502@redhat.com>
Date: Mon, 07 Oct 2013 14:41:01 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 25/63] sched: Add infrastructure for split shared/private
 accounting of NUMA hinting faults
References: <1381141781-10992-1-git-send-email-mgorman@suse.de> <1381141781-10992-26-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-26-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 10/07/2013 06:29 AM, Mel Gorman wrote:
> Ideally it would be possible to distinguish between NUMA hinting faults
> that are private to a task and those that are shared.  This patch prepares
> infrastructure for separately accounting shared and private faults by
> allocating the necessary buffers and passing in relevant information. For
> now, all faults are treated as private and detection will be introduced
> later.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
