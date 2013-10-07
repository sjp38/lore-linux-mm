Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 7054C6B003C
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 08:47:38 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kq14so7234481pab.40
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 05:47:38 -0700 (PDT)
Message-ID: <5252AD5F.4040101@redhat.com>
Date: Mon, 07 Oct 2013 08:47:27 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 04/63] mm: numa: Do not account for a hinting fault if
 we raced
References: <1381141781-10992-1-git-send-email-mgorman@suse.de> <1381141781-10992-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-5-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 10/07/2013 06:28 AM, Mel Gorman wrote:
> If another task handled a hinting fault in parallel then do not double
> account for it.
> 
> Cc: stable <stable@vger.kernel.org>
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
