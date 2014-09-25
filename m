Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f42.google.com (mail-oi0-f42.google.com [209.85.218.42])
	by kanga.kvack.org (Postfix) with ESMTP id C72106B0038
	for <linux-mm@kvack.org>; Thu, 25 Sep 2014 15:36:01 -0400 (EDT)
Received: by mail-oi0-f42.google.com with SMTP id u20so8407026oif.15
        for <linux-mm@kvack.org>; Thu, 25 Sep 2014 12:36:01 -0700 (PDT)
Received: from mail-oi0-x232.google.com (mail-oi0-x232.google.com [2607:f8b0:4003:c06::232])
        by mx.google.com with ESMTPS id ns6si4655770obc.22.2014.09.25.12.36.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 25 Sep 2014 12:36:00 -0700 (PDT)
Received: by mail-oi0-f50.google.com with SMTP id a141so7214085oig.37
        for <linux-mm@kvack.org>; Thu, 25 Sep 2014 12:36:00 -0700 (PDT)
Date: Thu, 25 Sep 2014 14:35:55 -0500
From: Chuck Ebbert <cebbert.lkml@gmail.com>
Subject: Re: page allocator bug in 3.16?
Message-ID: <20140925143555.1f276007@as>
In-Reply-To: <54246506.50401@hurleysoftware.com>
References: <54246506.50401@hurleysoftware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Hurley <peter@hurleysoftware.com>
Cc: Mel Gorman <mgorman@suse.de>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Maarten Lankhorst <maarten.lankhorst@canonical.com>, Thomas Hellstrom <thellstrom@vmware.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@kernel.org>, Hugh Dickens <hughd@google.com>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>

On Thu, 25 Sep 2014 14:55:02 -0400
Peter Hurley <peter@hurleysoftware.com> wrote:

> After several days uptime with a 3.16 kernel (generally running
> Thunderbird, emacs, kernel builds, several Chrome tabs on multiple
> desktop workspaces) I've been seeing some really extreme slowdowns.
> 
> Mostly the slowdowns are associated with gpu-related tasks, like
> opening new emacs windows, switching workspaces, laughing at internet
> gifs, etc. Because this x86_64 desktop is nouveau-based, I didn't pursue
> it right away -- 3.15 is the first time suspend has worked reliably.
> 
> This week I started looking into what the slowdown was and discovered
> it's happening during dma allocation through swiotlb (the cpus can do
> intel iommu but I don't use it because it's not the default for most users).
> 
> I'm still working on a bisection but each step takes 8+ hours to
> validate and even then I'm no longer sure I still have the 'bad'
> commit in the bisection. [edit: yup, I started over]
> 

There are six ttm patches queued for 3.16.4:

drm-ttm-choose-a-pool-to-shrink-correctly-in-ttm_dma_pool_shrink_scan.patch
drm-ttm-fix-handling-of-ttm_pl_flag_topdown-v2.patch
drm-ttm-fix-possible-division-by-0-in-ttm_dma_pool_shrink_scan.patch
drm-ttm-fix-possible-stack-overflow-by-recursive-shrinker-calls.patch
drm-ttm-pass-gfp-flags-in-order-to-avoid-deadlock.patch
drm-ttm-use-mutex_trylock-to-avoid-deadlock-inside-shrinker-functions.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
