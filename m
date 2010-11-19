Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A87BC6B004A
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 06:35:20 -0500 (EST)
Date: Fri, 19 Nov 2010 11:35:03 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] mm: remove call to find_vma in pagewalk for
	non-hugetlbfs
Message-ID: <20101119113503.GF28613@csn.ul.ie>
References: <1290127197-20360-1-git-send-email-dsterba@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1290127197-20360-1-git-send-email-dsterba@suse.cz>
Sender: owner-linux-mm@kvack.org
To: David Sterba <dsterba@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andi Kleen <ak@linux.intel.com>, Andy Whitcroft <apw@canonical.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Matt Mackall <mpm@selenic.com>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 19, 2010 at 01:39:57AM +0100, David Sterba wrote:
> Commit d33b9f45 introduces a check if a vma is a hugetlbfs one and
> later in 5dc37642 is moved under #ifdef CONFIG_HUGETLB_PAGE but
> a needless find_vma call is left behind and it's result not used
> anywhere else in the function.
> 
> The sideefect of caching vma for @addr inside walk->mm is neither
> utilized in walk_page_range() nor in called functions.
> 
> Signed-off-by: David Sterba <dsterba@suse.cz>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Andi Kleen <ak@linux.intel.com>
> Cc: Andy Whitcroft <apw@canonical.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>
> Cc: Matt Mackall <mpm@selenic.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Wu Fengguang <fengguang.wu@intel.com>

Well spotted.

Acked-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
