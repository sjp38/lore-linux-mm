Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f51.google.com (mail-vn0-f51.google.com [209.85.216.51])
	by kanga.kvack.org (Postfix) with ESMTP id C6AA26B0038
	for <linux-mm@kvack.org>; Sun, 26 Apr 2015 22:49:07 -0400 (EDT)
Received: by vnbf129 with SMTP id f129so10371640vnb.9
        for <linux-mm@kvack.org>; Sun, 26 Apr 2015 19:49:07 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id rn8si27940731vdb.105.2015.04.26.19.49.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Apr 2015 19:49:07 -0700 (PDT)
Message-ID: <553DA395.803@redhat.com>
Date: Sun, 26 Apr 2015 22:48:53 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] mm: Send one IPI per CPU to TLB flush multiple pages
 that were recently unmapped
References: <1429983942-4308-1-git-send-email-mgorman@suse.de> <1429983942-4308-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1429983942-4308-3-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>
Cc: Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On 04/25/2015 01:45 PM, Mel Gorman wrote:
> An IPI is sent to flush remote TLBs when a page is unmapped that was
> recently accessed by other CPUs. There are many circumstances where this
> happens but the obvious one is kswapd reclaiming pages belonging to a
> running process as kswapd and the task are likely running on separate CPUs.

> It's still a noticeable improvement with vmstat showing interrupts went
> from roughly 500K per second to 45K per second.
> 
> The patch will have no impact on workloads with no memory pressure or
> have relatively few mapped pages.
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
