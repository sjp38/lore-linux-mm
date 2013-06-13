Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id F1FD86B0033
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 17:29:46 -0400 (EDT)
Date: Thu, 13 Jun 2013 14:29:44 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 56881] New: MAP_HUGETLB mmap fails for certain sizes
Message-Id: <20130613142944.7fb7637c8a8622573e06c21b@linux-foundation.org>
In-Reply-To: <87vc5jh6cv.fsf@linux.vnet.ibm.com>
References: <bug-56881-27@https.bugzilla.kernel.org/>
	<20130423132522.042fa8d27668bbca6a410a92@linux-foundation.org>
	<20130424081454.GA13994@cmpxchg.org>
	<1366816599-7fr82iw1-mutt-n-horiguchi@ah.jp.nec.com>
	<20130424153951.GQ2018@cmpxchg.org>
	<1366844735-kqynvvnu-mutt-n-horiguchi@ah.jp.nec.com>
	<87vc5jh6cv.fsf@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, iceman_dvd@yahoo.com, Steven Truelove <steven.truelove@utoronto.ca>

On Wed, 12 Jun 2013 17:46:16 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> > From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Date: Wed, 24 Apr 2013 16:44:19 -0400
> > Subject: [PATCH] hugetlbfs: fix mmap failure in unaligned size request
> >
> > As reported in https://bugzilla.kernel.org/show_bug.cgi?id=56881, current
> > kernel returns -EINVAL unless a given mmap length is "almost" hugepage
> > aligned. This is because in sys_mmap_pgoff() the given length is passed to
> > vm_mmap_pgoff() as it is without being aligned with hugepage boundary.
> >
> > This is a regression introduced in commit 40716e29243d "hugetlbfs: fix
> > alignment of huge page requests", where alignment code is pushed into
> > hugetlb_file_setup() and the variable len in caller side is not changed.
> >
> > To fix this, this patch partially reverts that commit, and changes
> > the type of parameter size from size_t to (size_t *) in order to
> > align the size in caller side.
> 
> After the change af73e4d9506d3b797509f3c030e7dcd554f7d9c4 we have
> alignment related failures in libhugetlbfs test suite. misalign test
> fails with 3.10-rc5, while it works with 3.9.

What does this mean.  Is 3.10-rc5 more strict, or less strict?

If "less strict" then that's expected and old userspace should be OK
with the change and the test should be updated (sorry).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
