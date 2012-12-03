Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id A37B26B005D
	for <linux-mm@kvack.org>; Mon,  3 Dec 2012 00:09:43 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so1222506eaa.14
        for <linux-mm@kvack.org>; Sun, 02 Dec 2012 21:09:42 -0800 (PST)
Date: Mon, 3 Dec 2012 06:09:37 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 00/52] RFC: Unified NUMA balancing tree, v1
Message-ID: <20121203050937.GA26629@gmail.com>
References: <1354473824-19229-1-git-send-email-mingo@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1354473824-19229-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>


The unified NUMA Git tree can be found in the -tip numa/base 
branch:

  git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git numa/base

The PROT_NONE -v18 numa/core tree can be found in tip:master:

  git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git master

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
