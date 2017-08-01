Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E40216B0511
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 06:06:26 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 92so1639324wra.11
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 03:06:26 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 79si933226wmn.71.2017.08.01.03.06.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Aug 2017 03:06:25 -0700 (PDT)
Date: Tue, 1 Aug 2017 11:06:23 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v5 3/3] Revert "mm: numa: defer TLB flush for THP
 migration as long as possible"
Message-ID: <20170801100623.flalrk2t7jaik3fv@suse.de>
References: <20170731164325.235019-1-namit@vmware.com>
 <20170731164325.235019-4-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170731164325.235019-4-namit@vmware.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <namit@vmware.com>
Cc: linux-mm@kvack.org, nadav.amit@gmail.com, riel@redhat.com, luto@kernel.org, Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Mon, Jul 31, 2017 at 09:43:25AM -0700, Nadav Amit wrote:
> While deferring TLB flushes is a good practice, the reverted patch
> caused pending TLB flushes to be checked while the page-table lock is
> not taken. As a result, in architectures with weak memory model (PPC),
> Linux may miss a memory-barrier, miss the fact TLB flushes are pending,
> and cause (in theory) a memory corruption.
> 
> Since the alternative of using smp_mb__after_unlock_lock() was
> considered a bit open-coded, and the performance impact is expected to
> be small, the previous patch is reverted.
> 
> This reverts commit b0943d61b8fa420180f92f64ef67662b4f6cc493.
> 
> Suggested-by: Mel Gorman <mgorman@suse.de>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Rik van Riel <riel@redhat.com>
> Signed-off-by: Nadav Amit <namit@vmware.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
