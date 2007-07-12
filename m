Message-ID: <46957BE1.1010104@yahoo.com.au>
Date: Thu, 12 Jul 2007 10:54:57 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: fault vs invalidate race (Re: -mm merge plans for 2.6.23)
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>
In-Reply-To: <20070710013152.ef2cd200.akpm@linux-foundation.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

> mm-fix-fault-vs-invalidate-race-for-linear-mappings.patch
> mm-merge-populate-and-nopage-into-fault-fixes-nonlinear.patch
> mm-merge-nopfn-into-fault.patch
> convert-hugetlbfs-to-use-vm_ops-fault.patch
> mm-remove-legacy-cruft.patch
> mm-debug-check-for-the-fault-vs-invalidate-race.patch
> mm-fix-clear_page_dirty_for_io-vs-fault-race.patch
> invalidate_mapping_pages-add-cond_resched.patch
> ocfs2-release-page-lock-before-calling-page_mkwrite.patch
> document-page_mkwrite-locking.patch
> 
>  The fault-vs-invalidate race fix.  I have belatedly learned that these need
>  more work, so their state is uncertain.

The more work may turn out being too much for you (although it is nothing
exactly tricky that would introduce subtle bugs, it is a fair amont of churn).

However, in that case we can still merge these two:

mm-fix-fault-vs-invalidate-race-for-linear-mappings.patch
mm-fix-clear_page_dirty_for_io-vs-fault-race.patch

Which fix real bugs that need fixing (and will at least help to get some of
my patches off your hands).

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
