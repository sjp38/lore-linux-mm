Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id A73266B0034
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 07:15:07 -0400 (EDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 18 Jun 2013 16:37:19 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 2EF2BE004F
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 16:44:20 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5IBF0ku30998614
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 16:45:00 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5IBErGw029351
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 11:14:54 GMT
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [Bug 56881] New: MAP_HUGETLB mmap fails for certain sizes
In-Reply-To: <20130613142944.7fb7637c8a8622573e06c21b@linux-foundation.org>
References: <bug-56881-27@https.bugzilla.kernel.org/> <20130423132522.042fa8d27668bbca6a410a92@linux-foundation.org> <20130424081454.GA13994@cmpxchg.org> <1366816599-7fr82iw1-mutt-n-horiguchi@ah.jp.nec.com> <20130424153951.GQ2018@cmpxchg.org> <1366844735-kqynvvnu-mutt-n-horiguchi@ah.jp.nec.com> <87vc5jh6cv.fsf@linux.vnet.ibm.com> <20130613142944.7fb7637c8a8622573e06c21b@linux-foundation.org>
Date: Tue, 18 Jun 2013 16:44:52 +0530
Message-ID: <87hagvisb7.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, iceman_dvd@yahoo.com, Steven Truelove <steven.truelove@utoronto.ca>

Andrew Morton <akpm@linux-foundation.org> writes:

> On Wed, 12 Jun 2013 17:46:16 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
>
>> > From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> > Date: Wed, 24 Apr 2013 16:44:19 -0400
>> > Subject: [PATCH] hugetlbfs: fix mmap failure in unaligned size request
>> >
>> > As reported in https://bugzilla.kernel.org/show_bug.cgi?id=56881, current
>> > kernel returns -EINVAL unless a given mmap length is "almost" hugepage
>> > aligned. This is because in sys_mmap_pgoff() the given length is passed to
>> > vm_mmap_pgoff() as it is without being aligned with hugepage boundary.
>> >
>> > This is a regression introduced in commit 40716e29243d "hugetlbfs: fix
>> > alignment of huge page requests", where alignment code is pushed into
>> > hugetlb_file_setup() and the variable len in caller side is not changed.
>> >
>> > To fix this, this patch partially reverts that commit, and changes
>> > the type of parameter size from size_t to (size_t *) in order to
>> > align the size in caller side.
>> 
>> After the change af73e4d9506d3b797509f3c030e7dcd554f7d9c4 we have
>> alignment related failures in libhugetlbfs test suite. misalign test
>> fails with 3.10-rc5, while it works with 3.9.
>
> What does this mean.  Is 3.10-rc5 more strict, or less strict?
>
> If "less strict" then that's expected and old userspace should be OK
> with the change and the test should be updated (sorry).

3.10_rc5 is less strict. Also Naoya Horiguchi updated that relevant
changes to libhugetlbfs test is also posted at 

http://www.mail-archive.com/libhugetlbfs-devel@lists.sourceforge.net/msg13317.html

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
