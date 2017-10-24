Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7C9B36B0033
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 06:06:41 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id z96so11400227wrb.21
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 03:06:41 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f3sor3616843wrf.46.2017.10.24.03.06.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Oct 2017 03:06:40 -0700 (PDT)
Date: Tue, 24 Oct 2017 12:06:37 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v3 3/8] lockdep: Remove BROKEN flag of
 LOCKDEP_CROSSRELEASE
Message-ID: <20171024100637.nryez5rgmykod54v@gmail.com>
References: <1508837889-16932-1-git-send-email-byungchul.park@lge.com>
 <1508837889-16932-4-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1508837889-16932-4-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: peterz@infradead.org, axboe@kernel.dk, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tj@kernel.org, johannes.berg@intel.com, oleg@redhat.com, amir73il@gmail.com, david@fromorbit.com, darrick.wong@oracle.com, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, hch@infradead.org, idryomov@gmail.com, kernel-team@lge.com


better changelog:

================>
Subject: locking/lockdep: Remove the BROKEN flag from CONFIG_LOCKDEP_CROSSRELEASE and CONFIG_LOCKDEP_COMPLETIONS
From: Byungchul Park <byungchul.park@lge.com>
Date: Tue, 24 Oct 2017 18:38:04 +0900

Now that the performance regression is fixed, re-enable
CONFIG_LOCKDEP_CROSSRELEASE=y and CONFIG_LOCKDEP_COMPLETIONS=y.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
