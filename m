Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 178968D001A
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 17:53:45 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so6044403eek.14
        for <linux-mm@kvack.org>; Thu, 22 Nov 2012 14:53:43 -0800 (PST)
Date: Thu, 22 Nov 2012 23:53:38 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 00/33] Latest numa/core release, v17
Message-ID: <20121122225338.GA1226@gmail.com>
References: <1353624594-1118-1-git-send-email-mingo@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1353624594-1118-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>



* Ingo Molnar <mingo@kernel.org> wrote:

> This release mainly addresses one of the regressions Linus
> (rightfully) complained about: the "4x JVM" SPECjbb run.
> 
> [ Note to testers: if possible please still run with
>   CONFIG_TRANSPARENT_HUGEPAGES=y enabled, to avoid the
>   !THP regression that is still not fully fixed.
>   It will be fixed next. ]

I forgot to include the Git link:

  git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git master

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
