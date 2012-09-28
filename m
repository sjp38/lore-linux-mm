Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 580AB6B006E
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 09:51:27 -0400 (EDT)
Date: Fri, 28 Sep 2012 15:51:14 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [patch] mm, thp: fix mlock statistics
Message-ID: <20120928135114.GB19474@redhat.com>
References: <alpine.DEB.2.00.1209191818490.7879@chino.kir.corp.google.com>
 <alpine.LSU.2.00.1209192021270.28543@eggly.anvils>
 <alpine.DEB.2.00.1209261821380.7745@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1209261929270.8567@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1209261929270.8567@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org

On Wed, Sep 26, 2012 at 07:29:58PM -0700, David Rientjes wrote:
> NR_MLOCK is only accounted in single page units: there's no logic to
> handle transparent hugepages.  This patch checks the appropriate number
> of pages to adjust the statistics by so that the correct amount of memory
> is reflected.

*snip*

> Reported-by: Hugh Dickens <hughd@google.com>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/internal.h   |    3 ++-
>  mm/mlock.c      |    6 ++++--
>  mm/page_alloc.c |    2 +-
>  3 files changed, 7 insertions(+), 4 deletions(-)

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
