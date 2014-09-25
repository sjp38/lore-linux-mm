Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id B6D3182BDC
	for <linux-mm@kvack.org>; Thu, 25 Sep 2014 19:52:54 -0400 (EDT)
Received: by mail-qc0-f174.google.com with SMTP id i8so4821816qcq.33
        for <linux-mm@kvack.org>; Thu, 25 Sep 2014 16:52:54 -0700 (PDT)
Received: from n23.mail01.mtsvc.net (mailout32.mail01.mtsvc.net. [216.70.64.70])
        by mx.google.com with ESMTPS id i2si4276115qaz.37.2014.09.25.16.52.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Sep 2014 16:52:54 -0700 (PDT)
Message-ID: <5424AAD0.9010708@hurleysoftware.com>
Date: Thu, 25 Sep 2014 19:52:48 -0400
From: Peter Hurley <peter@hurleysoftware.com>
MIME-Version: 1.0
Subject: Re: page allocator bug in 3.16?
References: <54246506.50401@hurleysoftware.com> <20140925143555.1f276007@as>
In-Reply-To: <20140925143555.1f276007@as>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chuck Ebbert <cebbert.lkml@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Maarten Lankhorst <maarten.lankhorst@canonical.com>, Thomas Hellstrom <thellstrom@vmware.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@kernel.org>, Hugh Dickens <hughd@google.com>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>

On 09/25/2014 03:35 PM, Chuck Ebbert wrote:
> There are six ttm patches queued for 3.16.4:
> 
> drm-ttm-choose-a-pool-to-shrink-correctly-in-ttm_dma_pool_shrink_scan.patch
> drm-ttm-fix-handling-of-ttm_pl_flag_topdown-v2.patch
> drm-ttm-fix-possible-division-by-0-in-ttm_dma_pool_shrink_scan.patch
> drm-ttm-fix-possible-stack-overflow-by-recursive-shrinker-calls.patch
> drm-ttm-pass-gfp-flags-in-order-to-avoid-deadlock.patch
> drm-ttm-use-mutex_trylock-to-avoid-deadlock-inside-shrinker-functions.patch

Thanks for info, Chuck.

Unfortunately, none of these fix TTM dma allocation doing CMA dma allocation,
which is the root problem.

Regards,
Peter Hurley

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
