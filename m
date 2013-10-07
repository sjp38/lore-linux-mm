Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 78D8E6B0037
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 19:09:12 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id v10so7783122pde.24
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 16:09:12 -0700 (PDT)
Date: Mon, 7 Oct 2013 16:09:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv5 00/11] split page table lock for PMD tables
Message-Id: <20131007160907.3a4aca3e7eae404767ed3a8e@linux-foundation.org>
In-Reply-To: <1381154053-4848-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1381154053-4848-1-git-send-email-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Alex Thorlton <athorlton@sgi.com>, Ingo Molnar <mingo@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Eric W . Biederman" <ebiederm@xmission.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <ak@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Dave Jones <davej@redhat.com>, David Howells <dhowells@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Robin Holt <robinmholt@gmail.com>, Sedat Dilek <sedat.dilek@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon,  7 Oct 2013 16:54:02 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> Alex Thorlton noticed that some massively threaded workloads work poorly,
> if THP enabled. This patchset fixes this by introducing split page table
> lock for PMD tables. hugetlbfs is not covered yet.
> 
> This patchset is based on work by Naoya Horiguchi.

I think I'll summarise the results thusly:

: THP off, v3.12-rc2: 18.059261877 seconds time elapsed
: THP off, patched:   16.768027318 seconds time elapsed
: 
: THP on, v3.12-rc2:  42.162306788 seconds time elapsed
: THP on, patched:    8.397885779 seconds time elapsed
: 
: HUGETLB, v3.12-rc2: 47.574936948 seconds time elapsed
: HUGETLB, patched:   19.447481153 seconds time elapsed

What sort of machines are we talking about here?  Can mortals expect to
see such results on their hardware, or is this mainly on SGI nuttyware?

I'm seeing very few reviewed-by's and acked-by's in here, which is a
bit surprising and disappointing for a large patchset at v5.  Are you
sure none were missed?

The new code is enabled only for x86.  Why is this?  What must arch
maintainers do to enable it?  Have you any particular suggestions,
warnings etc to make their lives easier?

I assume the patchset won't damage bisectability?  If our bisecter has
only the first eight patches applied, the fact that
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK cannot be enabled protects from
failures?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
