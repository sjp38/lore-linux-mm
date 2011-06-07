Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 270BB6B0012
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 05:57:55 -0400 (EDT)
Date: Tue, 7 Jun 2011 10:57:49 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] mm: fix ENOSPC returned by handle_mm_fault()
Message-ID: <20110607095749.GD4372@csn.ul.ie>
References: <20110605134317.GF11521@ZenIV.linux.org.uk>
 <alpine.LSU.2.00.1106051141570.5792@sister.anvils>
 <20110605195025.GH11521@ZenIV.linux.org.uk>
 <alpine.LSU.2.00.1106051339001.8317@sister.anvils>
 <20110605221344.GJ11521@ZenIV.linux.org.uk>
 <alpine.LSU.2.00.1106052145370.17285@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1106052145370.17285@sister.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, Jun 05, 2011 at 10:03:13PM -0700, Hugh Dickins wrote:
> Al Viro observes that in the hugetlb case, handle_mm_fault() may return
> a value of the kind ENOSPC when its caller is expecting a value of the
> kind VM_FAULT_SIGBUS: fix alloc_huge_page()'s failure returns.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Acked-by: Al Viro <viro@zeniv.linux.org.uk>
> Cc: stable@kernel.org

Nicely spotted!

Acked-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
