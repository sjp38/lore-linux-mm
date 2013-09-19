Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 0A7E76B0037
	for <linux-mm@kvack.org>; Thu, 19 Sep 2013 13:16:59 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id fb10so9813783pad.23
        for <linux-mm@kvack.org>; Thu, 19 Sep 2013 10:16:59 -0700 (PDT)
Date: Thu, 19 Sep 2013 12:17:27 -0500
From: Alex Thorlton <athorlton@sgi.com>
Subject: Re: [PATCHv2 0/9] split page table lock for PMD tables
Message-ID: <20130919171727.GC6802@sgi.com>
References: <1379330740-5602-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1379330740-5602-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Eric W . Biederman" <ebiederm@xmission.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <ak@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Dave Jones <davej@redhat.com>, David Howells <dhowells@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Robin Holt <robinmholt@gmail.com>, Sedat Dilek <sedat.dilek@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Sep 16, 2013 at 02:25:31PM +0300, Kirill A. Shutemov wrote:
> Alex Thorlton noticed that some massivly threaded workloads work poorly,
> if THP enabled. This patchset fixes this by introducing split page table
> lock for PMD tables. hugetlbfs is not covered yet.
> 
> This patchset is based on work by Naoya Horiguchi.
> 
> Changes:
>  v2:
>   - reuse CONFIG_SPLIT_PTLOCK_CPUS for PMD split lock;
>   - s/huge_pmd_lock/pmd_lock/g;
>   - assume pgtable_pmd_page_ctor() can fail;
>   - fix format line in task_mem() for VmPTE;
> 
> Benchmark (from Alex): ftp://shell.sgi.com/collect/appsx_test/pthread_test.tar.gz
> Run on 4 socket Westmere with 128 GiB of RAM.

Kirill,

I'm hitting some performance issues with these patches on our larger
machines (>=128 cores/256 threads).  I've managed to livelock larger
systems with one of our tests (I'll publish this one soon), and I'm
actually seeing a performance hit on some of the smaller ones.  I'm
currently collecting some results to show the problems I'm hitting,
and trying to research what's causing the livelock.  For now I just
wanted to let you know that I'm seeing some issues.  I'll be in touch
with more details.

Sorry for the delayed response, I wanted to be really sure that I was
seeing problems before I put up a red flag.

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
