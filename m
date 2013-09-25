Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 9F91F6B0031
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 23:32:22 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id g10so5439232pdj.40
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 20:32:22 -0700 (PDT)
Message-ID: <1380079935.2163.3.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH v5 0/6]  rwsem: performance optimizations
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Tue, 24 Sep 2013 20:32:15 -0700
In-Reply-To: <1380061341.3467.49.camel@schen9-DESK>
References: <1380061341.3467.49.camel@schen9-DESK>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Tue, 2013-09-24 at 15:22 -0700, Tim Chen wrote:
> We have incorporated various suggestions from Ingo for version 5 of this patchset
> and will like to have it merged if there are no objections.
> 
> In this patchset, we introduce two categories of optimizations to read
> write semaphore.  The first four patches from Alex Shi reduce cache bouncing of the
> sem->count field by doing a pre-read of the sem->count and avoid cmpxchg
> if possible.
> 
> The last two patches introduce similar optimistic spinning logic as
> the mutex code for the writer lock acquisition of rwsem.

Right. We address the general 'mutexes out perform writer-rwsems'
situations that has been seen in more than one case. Users now need not
worry about performance issues when choosing between these two locking
mechanisms.

Thanks,
Davidlohr


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
