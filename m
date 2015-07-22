Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 823A59003C7
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 19:54:16 -0400 (EDT)
Received: by wicmv11 with SMTP id mv11so1287589wic.0
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 16:54:16 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id nb13si6245953wic.58.2015.07.22.16.54.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 22 Jul 2015 16:54:15 -0700 (PDT)
Message-ID: <1437609241.3298.19.camel@stgolabs.net>
Subject: Re: [PATCH v4 00/10] hugetlbfs: add fallocate support
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Wed, 22 Jul 2015 16:54:01 -0700
In-Reply-To: <55B024C6.8010504@oracle.com>
References: <1437502184-14269-1-git-send-email-mike.kravetz@oracle.com>
	 <20150722150647.2597c7e5be9ee1eecc438b6f@linux-foundation.org>
	 <1437603594.3298.5.camel@stgolabs.net>
	 <20150722153023.e8f15eb4e490f79cc029c8cd@linux-foundation.org>
	 <55B024C6.8010504@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Eric B Munson <emunson@akamai.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>, Michal Hocko <mhocko@suse.cz>

On Wed, 2015-07-22 at 16:18 -0700, Mike Kravetz wrote:
> On 07/22/2015 03:30 PM, Andrew Morton wrote:
> > On Wed, 22 Jul 2015 15:19:54 -0700 Davidlohr Bueso <dave@stgolabs.net> wrote:
> >
> >>>
> >>> I didn't know that libhugetlbfs has tests.  I wonder if that makes
> >>> tools/testing/selftests/vm's hugetlbfstest harmful?
> >>
> >> Why harmful? Redundant, maybe(?).
> >
> > The presence of the in-kernel tests will cause people to add stuff to
> > them when it would be better if they were to apply that effort to
> > making libhugetlbfs better.  Or vice versa.
> >
> > Mike's work is an example.  Someone later makes a change to hugetlbfs, runs
> > the kernel selftest and says "yay, everything works", unaware that they
> > just broke fallocate support.
> >
> >> Does anyone even use selftests for
> >> hugetlbfs regression testing? Lets see, we also have these:
> >>
> >> - hugepage-{mmap,shm}.c
> >> - map_hugetlb.c
> >>
> >> There's probably a lot of room for improvement here.
> >
> > selftests is a pretty scrappy place.  It's partly a dumping ground for
> > things so useful test code doesn't just get lost and bitrotted.  Partly
> > a framework so people who add features can easily test them. Partly to
> > provide tools to architecture maintainers when they wire up new
> > syscalls and the like.
> >
> > Unless there's some good reason to retain the hugetlb part of
> > selftests, I'm thinking we should just remove it to avoid
> > distracting/misleading people.  Or possibly move the libhugetlbfs test
> > code into the kernel tree and maintain it there.
> 
> Adding Eric as he is the libhugetlbfs maintainer.
> 
> I think removing the hugetlb selftests in the kernel and pointing
> people to libhugetlbfs is the way to go.  From a very quick scan
> of the selftests, I would guess libhugetlbfs covers everything
> in those tests.

fwiw, I've been trying to push people towards this for a while. Ie:

commit 15610c86fa83ff778eb80d3cfaa71d6acceb628a
Author: Davidlohr Bueso <davidlohr@hp.com>
Date:   Wed Sep 11 14:21:48 2013 -0700

    hugepage: mention libhugetlbfs in doc
    
    Explicitly mention/recommend using the libhugetlbfs test cases when
    changing related kernel code.  Developers that are unaware of the project
    can easily miss this and introduce potential regressions that may or may
    not be caught by community review.
    
    Also do some cleanups that make the document visually easier to view at a
    first glance.
    
    Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

But generally speaking, I doubt this doc is read much.

> 
> I'm willing to verify the testing provided by selftests is included
> in libhugetlbfs, and remove selftests if that is the direction we
> want to take.

Ack to this idea and thanks for volunteering.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
