Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 433C76B0074
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 10:52:40 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so1041eek.14
        for <linux-mm@kvack.org>; Tue, 13 Nov 2012 07:52:38 -0800 (PST)
Date: Tue, 13 Nov 2012 16:52:32 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: [patch 00/31] Latest numa/core patches, v15
Message-ID: <20121113155232.GA28466@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>

Hi,

This is the latest iteration of our numa/core patches, which 
implements adaptive NUMA affinity balancing.

Changes in this version:

    https://lkml.org/lkml/2012/11/12/315

Performance figures:

    https://lkml.org/lkml/2012/11/12/330

Any review feedback, comments and test results are welcome!

For testing purposes I'd suggest using the latest tip:master 
integration tree, which has the latest numa/core tree merged:

   git pull git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git master

(But you can also directly use the tip:numa/core tree as well.)

Thanks,

    Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
