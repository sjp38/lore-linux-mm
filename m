Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6C06B6B057B
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 18:29:44 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id l3so3851002wrc.12
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 15:29:44 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q30si20409364wra.202.2017.08.01.15.29.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Aug 2017 15:29:43 -0700 (PDT)
Date: Tue, 1 Aug 2017 15:29:40 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 0/4] fix several TLB batch races
Message-Id: <20170801152940.ba91066bd570ed3eadd8d2fc@linux-foundation.org>
In-Reply-To: <1501566977-20293-1-git-send-email-minchan@kernel.org>
References: <1501566977-20293-1-git-send-email-minchan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team <kernel-team@lge.com>, Nadav Amit <nadav.amit@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, Andrea Arcangeli <aarcange@redhat.com>

On Tue,  1 Aug 2017 14:56:13 +0900 Minchan Kim <minchan@kernel.org> wrote:

> Nadav and Mel founded several subtle races caused by TLB batching.
> This patchset aims for solving thoses problems using embedding
> [inc|dec]_tlb_flush_pending to TLB batching API.
> With that, places to know TLB flush pending catch it up by
> using mm_tlb_flush_pending.
> 
> Each patch includes detailed description.
> 
> This patchset is based on v4.13-rc2-mmots-2017-07-28-16-10 +
> "[PATCH v5 0/3] mm: fixes of tlb_flush_pending races" from Nadav

Nadav is planning on doing a v4 of his patchset and it sounds like it
will be significantly different.

So I'll await that patch series.  Nadav, I think it would be best if
you were to integrate Minchan's patchset on top of yours and maintain the
whole set as a single series, please.  That way it all gets tested at
the same time and you're testing the hopefully-final result.  If that's
OK then please retain the various acks and reviewed-bys in the
changelogs.

And we'll need to figure out which kernel versions to fix.  Let's
target 4.13-rcX for now, and assess the feasibility and desirability of
backporting it all into -stable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
