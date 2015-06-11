Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id E273E6B0032
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 11:02:58 -0400 (EDT)
Received: by wibdq8 with SMTP id dq8so11867077wib.1
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 08:02:58 -0700 (PDT)
Received: from mail-wg0-x229.google.com (mail-wg0-x229.google.com. [2a00:1450:400c:c00::229])
        by mx.google.com with ESMTPS id ft2si2398813wic.78.2015.06.11.08.02.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jun 2015 08:02:57 -0700 (PDT)
Received: by wgme6 with SMTP id e6so6902754wgm.2
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 08:02:56 -0700 (PDT)
Date: Thu, 11 Jun 2015 17:02:51 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 2/4] mm: Send one IPI per CPU to TLB flush all entries
 after unmapping pages
Message-ID: <20150611150250.GA14086@gmail.com>
References: <1433871118-15207-1-git-send-email-mgorman@suse.de>
 <1433871118-15207-3-git-send-email-mgorman@suse.de>
 <20150610083332.GA25605@gmail.com>
 <20150610085950.GB26425@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150610085950.GB26425@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


* Mel Gorman <mgorman@suse.de> wrote:

> > In the full-flushing case (v6 without patch 4) the batching limit is 
> > 'infinite', we'll batch as long as possible, right?
> 
> No because we must flush before pages are freed so the maximum batching is 
> related to SWAP_CLUSTER_MAX. If we free a page before the flush then in theory 
> the page can be reallocated and a stale TLB entry can allow access to unrelated 
> data. It would be almost impossible to trigger corruption this way but it's a 
> concern.

Well, could we say double SWAP_CLUSTER_MAX to further reduce the IPI rate?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
