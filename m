Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id BBAEA6B0069
	for <linux-mm@kvack.org>; Fri, 16 Sep 2016 14:33:01 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id u18so84732319ita.2
        for <linux-mm@kvack.org>; Fri, 16 Sep 2016 11:33:01 -0700 (PDT)
Received: from mail-oi0-x22d.google.com (mail-oi0-x22d.google.com. [2607:f8b0:4003:c06::22d])
        by mx.google.com with ESMTPS id l3si12027069otd.292.2016.09.16.11.33.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Sep 2016 11:33:00 -0700 (PDT)
Received: by mail-oi0-x22d.google.com with SMTP id q188so121794747oia.3
        for <linux-mm@kvack.org>; Fri, 16 Sep 2016 11:33:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160916132506.GB5035@twins.programming.kicks-ass.net>
References: <1473415175-20807-1-git-send-email-mgorman@techsingularity.net>
 <1473415175-20807-2-git-send-email-mgorman@techsingularity.net> <20160916132506.GB5035@twins.programming.kicks-ass.net>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 16 Sep 2016 11:33:00 -0700
Message-ID: <CA+55aFwoEMOweMaOjFk9+H04mFXnwGk7y6n86T2ZbF_CZOkKEg@mail.gmail.com>
Subject: Re: [PATCH 1/4] mm, vmscan: Batch removal of mappings under a single
 lock during reclaim
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Ying Huang <ying.huang@intel.com>, Michal Hocko <mhocko@kernel.org>

On Fri, Sep 16, 2016 at 6:25 AM, Peter Zijlstra <peterz@infradead.org> wrote:
>
> So, once upon a time, in a galaxy far away,..  I did a concurrent
> pagecache patch set that replaced the tree_lock with a per page bit-
> spinlock and fine grained locking in the radix tree.

I'd love to see the patch for that. I'd be a bit worried about extra
locking in the trivial cases (ie multi-level locking when we now take
just the single mapping lock), but if there is some smart reason why
that doesn't happen, then..

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
