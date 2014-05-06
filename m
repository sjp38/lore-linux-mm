Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id D32EE6B005A
	for <linux-mm@kvack.org>; Tue,  6 May 2014 13:25:20 -0400 (EDT)
Received: by mail-qc0-f169.google.com with SMTP id e16so7281719qcx.0
        for <linux-mm@kvack.org>; Tue, 06 May 2014 10:25:20 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id t1si5441390qap.230.2014.05.06.10.25.18
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 10:25:18 -0700 (PDT)
Message-ID: <53691AF9.7080608@redhat.com>
Date: Tue, 06 May 2014 13:25:13 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 07/17] mm: page_alloc: Take the ALLOC_NO_WATERMARK check
 out of the fast path
References: <1398933888-4940-1-git-send-email-mgorman@suse.de> <1398933888-4940-8-git-send-email-mgorman@suse.de>
In-Reply-To: <1398933888-4940-8-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Linux Kernel <linux-kernel@vger.kernel.org>

On 05/01/2014 04:44 AM, Mel Gorman wrote:
> ALLOC_NO_WATERMARK is set in a few cases. Always by kswapd, always for
> __GFP_MEMALLOC, sometimes for swap-over-nfs, tasks etc. Each of these cases
> are relatively rare events but the ALLOC_NO_WATERMARK check is an unlikely
> branch in the fast path.  This patch moves the check out of the fast path
> and after it has been determined that the watermarks have not been met. This
> helps the common fast path at the cost of making the slow path slower and
> hitting kswapd with a performance cost. It's a reasonable tradeoff.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
