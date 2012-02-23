Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 79CB86B004A
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 16:50:09 -0500 (EST)
Date: Thu, 23 Feb 2012 13:50:07 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm 1/2] mm: fix quadratic behaviour in
 get_unmapped_area_topdown
Message-Id: <20120223135007.a4dceeb2.akpm@linux-foundation.org>
In-Reply-To: <20120223145636.616bef1c@cuia.bos.redhat.com>
References: <20120223145417.261225fd@cuia.bos.redhat.com>
	<20120223145636.616bef1c@cuia.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, hughd@google.com, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>

On Thu, 23 Feb 2012 14:56:36 -0500
Rik van Riel <riel@redhat.com> wrote:

> When we look for a VMA smaller than the cached_hole_size, we set the
> starting search address to mm->mmap_base, to try and find our hole.
> 
> However, even in the case where we fall through and found nothing at
> the mm->free_area_cache, we still reset the search address to mm->mmap_base.
> This bug results in quadratic behaviour, with observed mmap times of 0.4
> seconds for processes that have very fragmented memory.
> 
> If there is no hole small enough for us to fit the VMA, and we have
> no good spot for us right at mm->free_area_cache, we are much better
> off continuing the search down from mm->free_area_cache, instead of
> all the way from the top.

This has been at least partially addressed in recent patches from Xiao
Guangrong.  Please review his five-patch series starting with "[PATCH
1/5] hugetlbfs: fix hugetlb_get_unmapped_area".

I've already merged those patches and we need to work out what way to
go.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
