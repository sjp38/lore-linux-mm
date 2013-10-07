Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 21DB06B0032
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 15:11:03 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id up15so7476214pbc.40
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 12:11:02 -0700 (PDT)
Message-ID: <5253073C.7010205@redhat.com>
Date: Mon, 07 Oct 2013 15:10:52 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 46/63] mm: numa: Do not group on RO pages
References: <1381141781-10992-1-git-send-email-mgorman@suse.de> <1381141781-10992-47-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-47-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 10/07/2013 06:29 AM, Mel Gorman wrote:
> From: Peter Zijlstra <peterz@infradead.org>
> 
> And here's a little something to make sure not the whole world ends up
> in a single group.
> 
> As while we don't migrate shared executable pages, we do scan/fault on
> them. And since everybody links to libc, everybody ends up in the same
> group.
> 
> [riel@redhat.com: mapcount 1]
> Suggested-by: Rik van Riel <riel@redhat.com>
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
