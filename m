Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id F1FFC6B0039
	for <linux-mm@kvack.org>; Tue,  8 Oct 2013 05:56:18 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id bj1so8460798pad.7
        for <linux-mm@kvack.org>; Tue, 08 Oct 2013 02:56:18 -0700 (PDT)
Date: Tue, 8 Oct 2013 11:56:02 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCHv5 00/11] split page table lock for PMD tables
Message-ID: <20131008095602.GR3081@twins.programming.kicks-ass.net>
References: <1381154053-4848-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20131007160907.3a4aca3e7eae404767ed3a8e@linux-foundation.org>
 <20131008084927.BC193E0090@blue.fi.intel.com>
 <20131008090408.GF3295@gmail.com>
 <20131008095006.85E1DE0090@blue.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131008095006.85E1DE0090@blue.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Alex Thorlton <athorlton@sgi.com>, Ingo Molnar <mingo@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Eric W . Biederman" <ebiederm@xmission.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <ak@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Dave Jones <davej@redhat.com>, David Howells <dhowells@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Robin Holt <robinmholt@gmail.com>, Sedat Dilek <sedat.dilek@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Oct 08, 2013 at 12:50:06PM +0300, Kirill A. Shutemov wrote:
> I want to rework code around page->ptl a bit more:
>  - allow pgtable_page_ctor() to fail and modify callers to handle it;
>  - if sizeof(spinlock_t) > sizeof(long) allocate the spinlock_t
>    dynamically.
> 
> It will allow to use split lock with DEBUG_SPINLOCK and DEBUG_LOCK_ALLOC.
> And it will make -rt guys happier. ;)

Oh yes, if you've got the time to do that, that would be great. It would
reduce the -rt patch by one ugly hack.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
