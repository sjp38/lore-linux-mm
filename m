Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id C17E76B005A
	for <linux-mm@kvack.org>; Tue, 10 Jan 2012 04:25:48 -0500 (EST)
Date: Tue, 10 Jan 2012 09:25:43 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm/compaction : do optimazition when the migration
 scanner gets no page
Message-ID: <20120110092543.GA4118@suse.de>
References: <1325825861-3702-1-git-send-email-b32955@freescale.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1325825861-3702-1-git-send-email-b32955@freescale.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Shijie <b32955@freescale.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, shijie8@gmail.com

On Fri, Jan 06, 2012 at 12:57:41PM +0800, Huang Shijie wrote:
> In the real tests, there are maybe many times the cc->nr_migratepages is zero,
> but isolate_migratepages() returns ISOLATE_SUCCESS.

Odd choice of language. Are there or are there not many times that
cc->nr_migratepages is zero? It does not affect the patch but it is
a slightly confusing changelog.

> In order to get better performance, we should check the number of the
> really isolated pages. And do the optimazition for this case.
> 

It's not critical for this patch but in the future it is preferred if
the performance impact can be quantified if that is your justification
for merging. I would expect the performance impact of this patch to
be marginal.

> Also fix the confused comments(from Mel Gorman).
> 
> Tested this patch in MX6Q board.
> 
> Signed-off-by: Huang Shijie <b32955@freescale.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
