Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 118246B0521
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 07:05:48 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id q198so6032310qke.13
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 04:05:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g125si13012088qkd.327.2017.08.01.04.05.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Aug 2017 04:05:47 -0700 (PDT)
Message-ID: <1501585545.4073.81.camel@redhat.com>
Subject: Re: [PATCH v5 3/3] Revert "mm: numa: defer TLB flush for THP
 migration as long as possible"
From: Rik van Riel <riel@redhat.com>
Date: Tue, 01 Aug 2017 07:05:45 -0400
In-Reply-To: <20170731164325.235019-4-namit@vmware.com>
References: <20170731164325.235019-1-namit@vmware.com>
	 <20170731164325.235019-4-namit@vmware.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <namit@vmware.com>, linux-mm@kvack.org
Cc: nadav.amit@gmail.com, mgorman@suse.de, luto@kernel.org, Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Mon, 2017-07-31 at 09:43 -0700, Nadav Amit wrote:
> While deferring TLB flushes is a good practice, the reverted patch
> caused pending TLB flushes to be checked while the page-table lock is
> not taken. As a result, in architectures with weak memory model
> (PPC),
> Linux may miss a memory-barrier, miss the fact TLB flushes are
> pending,
> and cause (in theory) a memory corruption.
> 
> Since the alternative of using smp_mb__after_unlock_lock() was
> considered a bit open-coded, and the performance impact is expected
> to
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
> 
Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
