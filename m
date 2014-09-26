Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f48.google.com (mail-oi0-f48.google.com [209.85.218.48])
	by kanga.kvack.org (Postfix) with ESMTP id 3280D6B0038
	for <linux-mm@kvack.org>; Fri, 26 Sep 2014 06:40:10 -0400 (EDT)
Received: by mail-oi0-f48.google.com with SMTP id g201so1443997oib.35
        for <linux-mm@kvack.org>; Fri, 26 Sep 2014 03:40:09 -0700 (PDT)
Received: from mail-ob0-x231.google.com (mail-ob0-x231.google.com [2607:f8b0:4003:c01::231])
        by mx.google.com with ESMTPS id g5si7291180obn.30.2014.09.26.03.40.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 26 Sep 2014 03:40:09 -0700 (PDT)
Received: by mail-ob0-f177.google.com with SMTP id va2so7925113obc.36
        for <linux-mm@kvack.org>; Fri, 26 Sep 2014 03:40:09 -0700 (PDT)
Date: Fri, 26 Sep 2014 05:40:05 -0500
From: Chuck Ebbert <cebbert.lkml@gmail.com>
Subject: Re: page allocator bug in 3.16?
Message-ID: <20140926054005.5c7985c0@as>
In-Reply-To: <542512AD.9070304@vmware.com>
References: <54246506.50401@hurleysoftware.com>
	<20140925143555.1f276007@as>
	<5424AAD0.9010708@hurleysoftware.com>
	<542512AD.9070304@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Hellstrom <thellstrom@vmware.com>
Cc: Peter Hurley <peter@hurleysoftware.com>, Mel Gorman <mgorman@suse.de>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Maarten
 Lankhorst <maarten.lankhorst@canonical.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@kernel.org>, Hugh Dickens <hughd@google.com>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>

On Fri, 26 Sep 2014 09:15:57 +0200
Thomas Hellstrom <thellstrom@vmware.com> wrote:

> On 09/26/2014 01:52 AM, Peter Hurley wrote:
> > On 09/25/2014 03:35 PM, Chuck Ebbert wrote:
> >> There are six ttm patches queued for 3.16.4:
> >>
> >> drm-ttm-choose-a-pool-to-shrink-correctly-in-ttm_dma_pool_shrink_scan.patch
> >> drm-ttm-fix-handling-of-ttm_pl_flag_topdown-v2.patch
> >> drm-ttm-fix-possible-division-by-0-in-ttm_dma_pool_shrink_scan.patch
> >> drm-ttm-fix-possible-stack-overflow-by-recursive-shrinker-calls.patch
> >> drm-ttm-pass-gfp-flags-in-order-to-avoid-deadlock.patch
> >> drm-ttm-use-mutex_trylock-to-avoid-deadlock-inside-shrinker-functions.patch
> > Thanks for info, Chuck.
> >
> > Unfortunately, none of these fix TTM dma allocation doing CMA dma allocation,
> > which is the root problem.
> >
> > Regards,
> > Peter Hurley
> 
> The problem is not really in TTM but in CMA, There was a guy offering to
> fix this in the CMA code but I guess he didn't probably because he
> didn't receive any feedback.
> 

Yeah, the "solution" to this problem seems to be "don't enable CMA on
x86". Maybe it should even be disabled in the config system.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
