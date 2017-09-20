Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id B04706B0038
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 15:29:41 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id o77so5061449qke.1
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 12:29:41 -0700 (PDT)
Received: from mail.stoffel.org (mail.stoffel.org. [104.236.43.127])
        by mx.google.com with ESMTPS id p98si2524248qkh.473.2017.09.20.12.29.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Sep 2017 12:29:40 -0700 (PDT)
Date: Wed, 20 Sep 2017 15:29:09 -0400
From: John Stoffel <john@quad.stoffel.home>
Subject: Re: [PATCH 0/6] More graceful flusher thread memory reclaim wakeup
Message-ID: <20170920192909.GA27517@quad.stoffel.home>
References: <1505850787-18311-1-git-send-email-axboe@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1505850787-18311-1-git-send-email-axboe@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, clm@fb.com, jack@suse.cz

On Tue, Sep 19, 2017 at 01:53:01PM -0600, Jens Axboe wrote:
> We've had some issues with writeback in presence of memory reclaim
> at Facebook, and this patch set attempts to fix it up. The real
> functional change is the last patch in the series, the first 5 are
> prep and cleanup patches.
> 
> The basic idea is that we have callers that call
> wakeup_flusher_threads() with nr_pages == 0. This means 'writeback
> everything'. For memory reclaim situations, we can end up queuing
> a TON of these kinds of writeback units. This can cause softlockups
> and further memory issues, since we allocate huge amounts of
> struct wb_writeback_work to handle this writeback. Handle this
> situation more gracefully.

This looks nice, but do you have any numbers to show how this improves
things?  I read the patches, but I'm not strong enough to comment on
them at all.  But I am interested in how this improves writeback under
pressure, if at all.

John

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
