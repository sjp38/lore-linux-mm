Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 077386B0292
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 06:50:25 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id d5so33763024pfg.3
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 03:50:24 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id t20si374619plj.397.2017.08.11.03.50.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Aug 2017 03:50:23 -0700 (PDT)
Date: Fri, 11 Aug 2017 12:50:15 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v6 3/7] Revert "mm: numa: defer TLB flush for THP
 migration as long as possible"
Message-ID: <20170811105015.4njdpy3il76g5uuk@hirez.programming.kicks-ass.net>
References: <20170802000818.4760-1-namit@vmware.com>
 <20170802000818.4760-4-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170802000818.4760-4-namit@vmware.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <namit@vmware.com>
Cc: linux-mm@kvack.org, nadav.amit@gmail.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andy Lutomirski <luto@kernel.org>

On Tue, Aug 01, 2017 at 05:08:14PM -0700, Nadav Amit wrote:
> While deferring TLB flushes is a good practice, the reverted patch
> caused pending TLB flushes to be checked while the page-table lock is
> not taken. As a result, in architectures with weak memory model (PPC),
> Linux may miss a memory-barrier, miss the fact TLB flushes are pending,
> and cause (in theory) a memory corruption.
> 
> Since the alternative of using smp_mb__after_unlock_lock() was
> considered a bit open-coded, and the performance impact is expected to
> be small, the previous patch is reverted.

FWIW this Changelog sucks arse; you completely fail to explain the
broken ordering.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
