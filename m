Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id ACC856B0032
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 11:42:36 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id fa1so1479502pad.5
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 08:42:36 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20130926105052.0205AE0090@blue.fi.intel.com>
References: <1379330740-5602-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20130919171727.GC6802@sgi.com>
 <20130920123137.BE2F7E0090@blue.fi.intel.com>
 <20130924164443.GB2940@sgi.com>
 <20130926105052.0205AE0090@blue.fi.intel.com>
Subject: Re: [PATCHv2 0/9] split page table lock for PMD tables
Content-Transfer-Encoding: 7bit
Message-Id: <20130926154224.D2CFFE0090@blue.fi.intel.com>
Date: Thu, 26 Sep 2013 18:42:24 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Eric W . Biederman" <ebiederm@xmission.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <ak@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Dave Jones <davej@redhat.com>, David Howells <dhowells@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Robin Holt <robinmholt@gmail.com>, Sedat Dilek <sedat.dilek@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Kirill A. Shutemov wrote:
> Alex Thorlton wrote:
> > > THP off:
> > > --------
> ...
> > >       36.540185552 seconds time elapsed                                          ( +- 18.36% )
> > 
> > I'm assuming this was THP off, no patchset, correct?
> 
> Yes. But THP off patched is *very* close to this, so I didn't post it separately.
> 
> > Here are my results from this test on 3.12-rc1:
> ...
> >     1138.759708820 seconds time elapsed                                          ( +-  0.47% )
> > 
> > And the same test on 3.12-rc1 with your patchset:
> > 
> >  Performance counter stats for './runt -t -c 512 -b 512m' (5 runs):
> ...
> >     1115.214191126 seconds time elapsed                                          ( +-  0.18% )
> > 
> > Looks like we're getting a mild performance increase here, but we still
> > have a problem.
> 
> Let me guess: you have HUGETLBFS enabled in your config, right? ;)
> 
> HUGETLBFS hasn't converted to new locking and we disable split pmd lock if
> HUGETLBFS is enabled.
> 
> I'm going to convert HUGETLBFS too, but it might take some time.

Okay, here is a bit reworked patch from Naoya Horiguchi.
It might need more cleanup.

Please, test and review.
