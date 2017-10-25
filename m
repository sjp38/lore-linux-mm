Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id BC82E6B0033
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 06:13:32 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v88so6802404wrb.22
        for <linux-mm@kvack.org>; Wed, 25 Oct 2017 03:13:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d17sor1116194wra.44.2017.10.25.03.13.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 25 Oct 2017 03:13:31 -0700 (PDT)
Date: Wed, 25 Oct 2017 12:13:28 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v5 9/9] block: Assign a lock_class per gendisk used for
 wait_for_completion()
Message-ID: <20171025101328.b6fg32m2oazh3zro@gmail.com>
References: <1508921765-15396-1-git-send-email-byungchul.park@lge.com>
 <1508921765-15396-10-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1508921765-15396-10-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>, Jens Axboe <axboe@kernel.dk>
Cc: peterz@infradead.org, johan@kernel.org, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tj@kernel.org, johannes.berg@intel.com, oleg@redhat.com, amir73il@gmail.com, david@fromorbit.com, darrick.wong@oracle.com, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, hch@infradead.org, idryomov@gmail.com, kernel-team@lge.com


* Byungchul Park <byungchul.park@lge.com> wrote:

> Darrick posted the following warning and Dave Chinner analyzed it:
> 
> > ======================================================
> > WARNING: possible circular locking dependency detected
> > 4.14.0-rc1-fixes #1 Tainted: G        W

> Reported-by: Darrick J. Wong <darrick.wong@oracle.com>
> Analyzed-by: Dave Chinner <david@fromorbit.com>
> Signed-off-by: Byungchul Park <byungchul.park@lge.com>
> ---
>  block/bio.c           |  2 +-
>  block/genhd.c         | 10 ++--------
>  include/linux/genhd.h | 22 ++++++++++++++++++++--
>  3 files changed, 23 insertions(+), 11 deletions(-)

Ok, this patch looks good to me now, I'll wait to get an Ack or Nak from Jens for 
these changes.

Jens: this patch has some dependencies in prior lockdep changes, so I'd like to 
carry it in the locking tree for a v4.15 merge.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
