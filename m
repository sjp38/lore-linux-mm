Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 128D86B00EE
	for <linux-mm@kvack.org>; Sat,  6 Aug 2011 14:18:42 -0400 (EDT)
Date: Sat, 6 Aug 2011 18:31:54 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] THP: mremap support and TLB optimization #2
Message-ID: <20110806163154.GE9770@redhat.com>
References: <20110728142631.GI3087@redhat.com>
 <20110805152516.GI9211@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110805152516.GI9211@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Fri, Aug 05, 2011 at 04:25:16PM +0100, Mel Gorman wrote:
> The meaning of the return values of -1, 0, 1 with the caller doing
> 
> if (err)
> ...
> else if (!err)
> 	...
> 
> is tricky to work out. split_huge_page only needs to be called if
> returning 0. Would it be possible to have the split_huge_page called in
> this function? The end of the function would then look like

I'm doing the cleanup but problem is to call split_huge_page in
move_huge_pmd I'd need to call move_huge_pmd even when extent <
HPAGE_PMD_SIZE. That's an unnecessary call... That is the reason of
the tristate.

Alternatively I could call split_huge_page even if move_huge_pmd
returns -1 (so making it return 0) but then it'd be another
unnecessary call.

Not sure anymore if it's worth removing the -1.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
