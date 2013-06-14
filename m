Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 22E7D6B0039
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 07:10:44 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id lj1so554569pab.17
        for <linux-mm@kvack.org>; Fri, 14 Jun 2013 04:10:43 -0700 (PDT)
Date: Fri, 14 Jun 2013 20:10:34 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: vmscan: remove redundant querying to shrinker
Message-ID: <20130614111034.GA306@gmail.com>
References: <1371204471-13518-1-git-send-email-heesub.shin@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1371204471-13518-1-git-send-email-heesub.shin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heesub Shin <heesub.shin@samsung.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de, riel@redhat.com, kyungmin.park@samsung.com, d.j.shin@samsung.com, sunae.seo@samsung.com


Hello,

On Fri, Jun 14, 2013 at 07:07:51PM +0900, Heesub Shin wrote:
> shrink_slab() queries each slab cache to get the number of
> elements in it. In most cases such queries are cheap but,
> on some caches. For example, Android low-memory-killer,
> which is operates as a slab shrinker, does relatively
> long calculation once invoked and it is quite expensive.

LMK as shrinker is really bad, which everybody didn't want
when we reviewed it a few years ago so that's a one of reason
LMK couldn't be promoted to mainline yet. So your motivation is
already not atrractive. ;-)

> 
> This patch removes redundant queries to shrinker function
> in the loop of shrink batch.

I didn't review the patch and others don't want it, I guess.
Because slab shrink is under construction and many patches were
already merged into mmtom. Please look at latest mmotm tree.

	git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git

If you concern is still in there and it's really big concern of MM
we should take care, NOT LMK, plese, resend it.

Thanks.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
