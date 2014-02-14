Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id C834A6B0031
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 09:15:57 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id cc10so506160wib.17
        for <linux-mm@kvack.org>; Fri, 14 Feb 2014 06:15:57 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id uu2si3979969wjc.15.2014.02.14.06.15.55
        for <linux-mm@kvack.org>;
        Fri, 14 Feb 2014 06:15:56 -0800 (PST)
Message-ID: <52FE2511.1010004@redhat.com>
Date: Fri, 14 Feb 2014 09:15:45 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2 1/2] mm/vmscan: restore sc->gfp_mask after promoting
 it to __GFP_HIGHMEM
References: <000101cf294f$eef39610$ccdac230$%yang@samsung.com>
In-Reply-To: <000101cf294f$eef39610$ccdac230$%yang@samsung.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>, 'Mel Gorman' <mgorman@suse.de>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Minchan Kim' <minchan@kernel.org>, weijie.yang.kh@gmail.com, 'Linux-MM' <linux-mm@kvack.org>, 'linux-kernel' <linux-kernel@vger.kernel.org>

On 02/14/2014 01:41 AM, Weijie Yang wrote:
> We promote sc->gfp_mask to __GFP_HIGHMEM to forcibly scan highmem if
> there are too many buffer_heads pinning highmem. see: cc715d99e5
> 
> This patch restores sc->gfp_mask to its caller original value after
> finishing the scan job, to avoid the impact on other invocations from
> its upper caller, such as vmpressure_prio(), shrink_slab().
> 
> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
