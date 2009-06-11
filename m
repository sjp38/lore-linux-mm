Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 613516B004D
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 19:29:41 -0400 (EDT)
Date: Thu, 11 Jun 2009 16:30:06 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/3] Fix malloc() stall in zone_reclaim() and bring
 behaviour more in line with expectations V3
Message-Id: <20090611163006.e985639f.akpm@linux-foundation.org>
In-Reply-To: <1244717273-15176-1-git-send-email-mel@csn.ul.ie>
References: <1244717273-15176-1-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, cl@linux-foundation.org, fengguang.wu@intel.com, linuxram@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 11 Jun 2009 11:47:50 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> The big change with this release is that the patch reintroducing
> zone_reclaim_interval has been dropped as Ram reports the malloc() stalls
> have been resolved. If this bug occurs again, the counter will be there to
> help us identify the situation.

What is the exact relationship between this work and the somewhat
mangled "[PATCH for mmotm 0/5] introduce swap-backed-file-mapped count
and fix
vmscan-change-the-number-of-the-unmapped-files-in-zone-reclaim.patch"
series?

That five-patch series had me thinking that it was time to drop 

vmscan-change-the-number-of-the-unmapped-files-in-zone-reclaim.patch
vmscan-drop-pf_swapwrite-from-zone_reclaim.patch
vmscan-zone_reclaim-use-may_swap.patch

(they can be removed cleanly, but I haven't tried compiling the result)

but your series is based on those.

We have 142 MM patches queued, and we need to merge next week.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
