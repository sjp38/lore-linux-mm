Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D3AEC6B025E
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 05:39:10 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p2so3180958pfk.13
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 02:39:10 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id l8si6591795pgs.829.2017.10.18.02.39.09
        for <linux-mm@kvack.org>;
        Wed, 18 Oct 2017 02:39:09 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: Fix false positive by LOCKDEP_CROSSRELEASE
Date: Wed, 18 Oct 2017 18:38:49 +0900
Message-Id: <1508319532-24655-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tj@kernel.org, johannes.berg@intel.com, oleg@redhat.com, amir73il@gmail.com, david@fromorbit.com, darrick.wong@oracle.com, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, hch@infradead.org, idryomov@gmail.com, kernel-team@lge.com

Several false positives were reported, so I tried to fix them.

It would be appreciated if you tell me if it works as expected, or let
me know your opinion.

Thank you,
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
