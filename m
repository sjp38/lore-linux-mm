Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id E859E6B0032
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 05:48:30 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id uo5so6805159pbc.23
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 02:48:30 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20131004203147.GE32110@sgi.com>
References: <1380287787-30252-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20131004201213.GB32110@sgi.com>
 <20131004202602.2D389E0090@blue.fi.intel.com>
 <20131004203147.GE32110@sgi.com>
Subject: Re: [PATCHv4 00/10] split page table lock for PMD tables
Content-Transfer-Encoding: 7bit
Message-Id: <20131007094820.13A0CE0090@blue.fi.intel.com>
Date: Mon,  7 Oct 2013 12:48:20 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Eric W . Biederman" <ebiederm@xmission.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <ak@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Dave Jones <davej@redhat.com>, David Howells <dhowells@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Robin Holt <robinmholt@gmail.com>, Sedat Dilek <sedat.dilek@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Alex Thorlton wrote:
> > > Sorry for the delay on these results.  I hit some strange issues with
> > > running thp_memscale on systems with either of the following
> > > combinations of configuration options set:
> > > 
> > > [thp off]
> > > HUGETLBFS=y
> > > HUGETLB_PAGE=y
> > > NUMA_BALANCING=y
> > > NUMA_BALANCING_DEFAULT_ENABLED=y
> > > 
> > > [thp on or off]
> > > HUGETLBFS=n
> > > HUGETLB_PAGE=n
> > > NUMA_BALANCING=y
> > > NUMA_BALANCING_DEFAULT_ENABLED=y
> > > 
> > > I'm getting segfaults intermittently, as well as some weird RCU sched
> > > errors.  This happens in vanilla 3.12-rc2, so it doesn't have anything
> > > to do with your patches, but I thought I'd let you know.  There didn't
> > > used to be any issues with this test, so I think there's a subtle kernel
> > > bug here.  That's, of course, an entirely separate issue though.
> > 
> > I'll take a look next week, if nobody does it before.
> 
> I'm starting a bisect now.  Not sure how long it'll take, but I'll keep
> you posted.

I don't see the issue. Could you share your kernel config?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
