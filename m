Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id 250F96B0038
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 14:10:23 -0400 (EDT)
Received: by mail-ee0-f47.google.com with SMTP id b15so1838092eek.20
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 11:10:22 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id x47si41377139eel.13.2014.04.18.11.10.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 18 Apr 2014 11:10:21 -0700 (PDT)
Date: Fri, 18 Apr 2014 14:10:19 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 09/16] mm: page_alloc: Take the ALLOC_NO_WATERMARK check
 out of the fast path
Message-ID: <20140418181019.GF29210@cmpxchg.org>
References: <1397832643-14275-1-git-send-email-mgorman@suse.de>
 <1397832643-14275-10-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1397832643-14275-10-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Fri, Apr 18, 2014 at 03:50:36PM +0100, Mel Gorman wrote:
> ALLOC_NO_WATERMARK is set in a few cases. Always by kswapd, always for
> __GFP_MEMALLOC, sometimes for swap-over-nfs, tasks etc. Each of these cases
> are relatively rare events but the ALLOC_NO_WATERMARK check is an unlikely
> branch in the fast path.  This patch moves the check out of the fast path
> and after it has been determined that the watermarks have not been met. This
> helps the common fast path at the cost of making the slow path slower and
> hitting kswapd with a performance cost. It's a reasonable tradeoff.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
