Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 038C16B0036
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 06:04:24 -0500 (EST)
Received: by mail-wg0-f50.google.com with SMTP id z12so274545wgg.29
        for <linux-mm@kvack.org>; Fri, 14 Feb 2014 03:04:24 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lu12si865881wic.1.2014.02.14.03.04.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 14 Feb 2014 03:04:23 -0800 (PST)
Date: Fri, 14 Feb 2014 11:04:19 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH V2 1/2] mm/vmscan: restore sc->gfp_mask after promoting
 it to __GFP_HIGHMEM
Message-ID: <20140214110419.GA6732@suse.de>
References: <000101cf294f$eef39610$ccdac230$%yang@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <000101cf294f$eef39610$ccdac230$%yang@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, riel@redhat.com, 'Minchan Kim' <minchan@kernel.org>, weijie.yang.kh@gmail.com, 'Linux-MM' <linux-mm@kvack.org>, 'linux-kernel' <linux-kernel@vger.kernel.org>

On Fri, Feb 14, 2014 at 02:41:33PM +0800, Weijie Yang wrote:
> We promote sc->gfp_mask to __GFP_HIGHMEM to forcibly scan highmem if
> there are too many buffer_heads pinning highmem. see: cc715d99e5
> 
> This patch restores sc->gfp_mask to its caller original value after
> finishing the scan job, to avoid the impact on other invocations from
> its upper caller, such as vmpressure_prio(), shrink_slab().
> 
> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
