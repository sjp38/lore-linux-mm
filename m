Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 1F60E6B004D
	for <linux-mm@kvack.org>; Mon,  3 Dec 2012 04:25:34 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so1772291eek.14
        for <linux-mm@kvack.org>; Mon, 03 Dec 2012 01:25:32 -0800 (PST)
Date: Mon, 3 Dec 2012 10:25:26 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: [GIT] Unified NUMA balancing tree, v2
Message-ID: <20121203092526.GA14136@gmail.com>
References: <1354473824-19229-1-git-send-email-mingo@kernel.org>
 <20121203050937.GA26629@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121203050937.GA26629@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>


I've pushed out a new update into:

   git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git numa/base

which eliminates a few integration kinks/bugs in -v1:

 - I unified the THP migration code
 - there's also an MPOL_BIND bugfix.
 - added the fixed hiwater_rss patch.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
