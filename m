Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id E93FD6B0044
	for <linux-mm@kvack.org>; Mon, 21 May 2012 10:28:25 -0400 (EDT)
Date: Mon, 21 May 2012 15:28:22 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC][PATCH] hugetlb: fix resv_map leak in error path
Message-ID: <20120521142822.GF28631@csn.ul.ie>
References: <20120518184630.FF3307BD@kernel>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120518184630.FF3307BD@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: cl@linux.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, aarcange@redhat.com, kosaki.motohiro@jp.fujitsu.com, hughd@google.com, rientjes@google.com, adobriyan@gmail.com, akpm@linux-foundation.org

On Fri, May 18, 2012 at 11:46:30AM -0700, Dave Hansen wrote:
> 
> When called for anonymous (non-shared) mappings,
> hugetlb_reserve_pages() does a resv_map_alloc().  It depends on
> code in hugetlbfs's vm_ops->close() to release that allocation.
> 
> However, in the mmap() failure path, we do a plain unmap_region()
> without the remove_vma() which actually calls vm_ops->close().
> 
> This is a decent fix.  This leak could get reintroduced if
> new code (say, after hugetlb_reserve_pages() in
> hugetlbfs_file_mmap()) decides to return an error.  But, I think
> it would have to unroll the reservation anyway.
> 
> This hasn't been extensively tested.  Pretty much compile and
> boot tested along with Christoph's test case.
> 
> Comments?
> 
> Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>

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
