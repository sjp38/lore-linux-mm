Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id C28016B0044
	for <linux-mm@kvack.org>; Wed,  5 Dec 2012 04:52:21 -0500 (EST)
Date: Wed, 5 Dec 2012 09:43:58 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 20/52] mm, numa: Implement migrate-on-fault lazy NUMA
 strategy for regular and THP pages
Message-ID: <20121205094332.GA2489@suse.de>
References: <1354473824-19229-1-git-send-email-mingo@kernel.org>
 <1354473824-19229-21-git-send-email-mingo@kernel.org>
 <alpine.DEB.2.00.1212041652240.13029@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1212041652240.13029@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On Tue, Dec 04, 2012 at 04:55:13PM -0800, David Rientjes wrote:
> Commit "mm, numa: Implement migrate-on-fault lazy NUMA strategy for 
> regular and THP pages" breaks the build because HPAGE_PMD_SHIFT and 
> HPAGE_PMD_MASK defined to explode without CONFIG_TRANSPARENT_HUGEPAGE:
> 
> mm/migrate.c: In function 'migrate_misplaced_transhuge_page_put':
> mm/migrate.c:1549: error: call to '__build_bug_failed' declared with attribute error: BUILD_BUG failed
> mm/migrate.c:1564: error: call to '__build_bug_failed' declared with attribute error: BUILD_BUG failed
> mm/migrate.c:1566: error: call to '__build_bug_failed' declared with attribute error: BUILD_BUG failed
> mm/migrate.c:1573: error: call to '__build_bug_failed' declared with attribute error: BUILD_BUG failed
> mm/migrate.c:1606: error: call to '__build_bug_failed' declared with attribute error: BUILD_BUG failed
> mm/migrate.c:1648: error: call to '__build_bug_failed' declared with attribute error: BUILD_BUG failed
> 
> CONFIG_NUMA_BALANCING allows compilation without enabling transparent 
> hugepages, so define the dummy function for such a configuration and only 
> define migrate_misplaced_transhuge_page_put() when transparent hugepages 
> are enabled.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Thanks David. I pushed the equivalent for the balancenuma tree and
should be included in the balancenuma-v10 tag or mm-balancenuma-v10r3
branch at
git://git.kernel.org/pub/scm/linux/kernel/git/mel/linux-balancenuma.git

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
